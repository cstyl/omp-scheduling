#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <omp.h> 

#include "loop_affinity.h"

#define N 729
#define reps 1000

#define FALSE 0
#define TRUE 1

#define DONE -1


double a[N][N], b[N][N], c[N];
int jmax[N];  

void runloop(int loopid, thread_str *t) ;

void init1(void);
void init2(void);
void loop1chunk(int, int);
void loop2chunk(int, int);
void valid1(void);
void valid2(void);

int read_user_inputs(int an, char **av, int *nthreads);

int malloc_structure(thread_str *t);
int free_structure(thread_str *t);

bound_str get_bounds(bound_str space, int current_block, int total_blocks, int offset);
int get_stepsize(int low, int high, int total_blocks);
int get_most_loaded_thread(int *next_lo, bound_str *local, int nthreads);
bound_str get_work(thread_str *t, int thread_id, int nthreads);

#ifdef LOCK
	int lock_init(thread_str *t);
	int lock_destroy(thread_str *t);
#endif

int main(int argc, char *argv[]) { 

	thread_str affinity;
	int error_status = 0, nthreads;

	error_status = read_user_inputs(argc, argv, &affinity.nthreads);
	CHECK_ERROR(error_status);

	// set the number of threads according to the user input
	omp_set_num_threads(affinity.nthreads);

	error_status = malloc_structure(&affinity);
	CHECK_ERROR(error_status);
	
	affinity.global.lo = 0;
	affinity.global.hi = N;

#ifdef LOCK
	error_status = lock_init(&affinity);
	CHECK_ERROR(error_status);
#endif

	double start1,start2,end1,end2;
	int r;

	init1(); 

	start1 = omp_get_wtime(); 

	for (r=0; r<reps; r++)
	{ 
		runloop(1, &affinity);
  	} 

  	end1  = omp_get_wtime();  

  	valid1(); 

  	printf("Total time for %d reps of loop 1 = %f\n",reps, (float)(end1-start1)); 

  	init2(); 

  	start2 = omp_get_wtime(); 

  	for (r=0; r<reps; r++)
  	{ 
		runloop(2, &affinity);
  	} 

  	end2  = omp_get_wtime(); 

  	valid2(); 

  	printf("Total time for %d reps of loop 2 = %f\n",reps, (float)(end2-start2)); 

#ifdef LOCK
	error_status = lock_destroy(&affinity);
	CHECK_ERROR(error_status);
#endif

	error_status = free_structure(&affinity);
	CHECK_ERROR(error_status);
  
  	return 0;
} 

int malloc_structure(thread_str *t)
{
	MALLOC(t->local,   t->nthreads, bound_str);
	MALLOC(t->next_lo,   t->nthreads, int);

#ifdef LOCK
	MALLOC(t->lock,	   t->nthreads, omp_lock_t);
#endif

	return 0;    
}

int free_structure(thread_str *t)
{
	FREE(t->local);
	FREE(t->next_lo);

#ifdef LOCK
	FREE(t->lock);
#endif
	
	return 0;    
}


void init1(void)
{
  	int i,j; 

  	for (i=0; i<N; i++)
  	{ 
		for (j=0; j<N; j++)
		{ 
	  		a[i][j] = 0.0; 
	  		b[i][j] = 3.142*(i+j); 
		}
  	}

}

void init2(void)
{ 
  	int i,j, expr; 

  	for (i=0; i<N; i++)
  	{ 
		expr =  i%( 3*(i/30) + 1); 
		if ( expr == 0) 
		{ 
	  		jmax[i] = N;
		}
		else 
		{
	  		jmax[i] = 1; 
		}
		c[i] = 0.0;
  	}

  	for (i=0; i<N; i++)
  	{ 
		for (j=0; j<N; j++)
		{ 
	  		b[i][j] = (double) (i*j+1) / (double) (N*N); 
		}
  	}
 
} 

bound_str get_bounds(bound_str space, int current_block, int total_blocks, int offset)
{
	bound_str boundaries;
	int ipt = get_stepsize(space.lo, space.hi, total_blocks);
	
	boundaries.lo = current_block * ipt + offset;
	boundaries.hi = (current_block+1) * ipt + offset;
	
	if (boundaries.hi > space.hi) boundaries.hi = space.hi; 

	return boundaries;
}

int get_stepsize(int low, int high, int total_blocks)
{
	return (int) ceil((double)(high - low)/(double)total_blocks); 
}

int lock_init(thread_str *t)
{
	int i;

	for(i=0; i < t->nthreads; i++)
	{
		omp_init_lock(&t->lock[i]);
	}

	return 0;
}

int lock_destroy(thread_str *t)
{
	int i;

	for(i=0; i < t->nthreads; i++)
	{
		omp_destroy_lock(&t->lock[i]);
	}
	
	return 0;
}

bound_str get_work(thread_str *t, int thread_id, int nthreads)
{
	bound_str c;
	int stepsize;
	
#ifdef LOCK
	omp_set_lock(&t->lock[thread_id]);
#else
	#pragma omp critical
	{
#endif
		c.lo = t->next_lo[thread_id];
			
  		stepsize = get_stepsize(c.lo, t->local[thread_id].hi, nthreads);
  		t->next_lo[thread_id] += stepsize;

#ifdef LOCK
	omp_unset_lock(&t->lock[thread_id]);
#else
	} // end of critical
#endif			

	c.hi = c.lo + stepsize;

  	return c;	
}


void runloop(int loopid, thread_str *t)  
{

	#pragma omp parallel default(none) shared(loopid, t) 
  	{
		int myid  = omp_get_thread_num();
		int nthreads = omp_get_num_threads();
		bound_str current;
		int stepsize, most_loaded = myid;
		int affinity = FALSE;

		t->local[most_loaded] = get_bounds(t->global, most_loaded, nthreads, 0);		
		t->next_lo[most_loaded] = t->local[most_loaded].lo;
		
		/* make sure all the threads have initialised their shared data */
		#pragma omp barrier

		while(1)
		{
			if(affinity)
			{
				most_loaded = get_most_loaded_thread(t->next_lo, t->local, nthreads);
				if(most_loaded == DONE)
					break;
			}

			current = get_work(t, most_loaded, nthreads);

  			if(current.hi>= t->local[most_loaded].hi)
  			{
  				current.hi = t->local[most_loaded].hi;
  				affinity = TRUE;
  			}

		  	switch (loopid) 
		  	{ 
			 	case 1: loop1chunk(current.lo, current.hi); break;
			 	case 2: loop2chunk(current.lo, current.hi); break;
		  	}	
		}

  	} // end pragma
}


int get_most_loaded_thread(int *next_lo, bound_str *local, int nthreads)
{
	int max_rem = 0, rem;
	int i, most_loaded=DONE;
	
	for(i=0; i<nthreads; i++)
	{

		rem = local[i].hi - next_lo[i];

		if(rem > max_rem)
		{
			max_rem = rem;
			most_loaded = i;
		}
	}

	return most_loaded;

}

void loop1chunk(int lo, int hi) 
{ 
  	int i,j; 
  
  	for (i=lo; i<hi; i++)
  	{ 
		for (j=N-1; j>i; j--)
		{
	  		a[i][j] += cos(b[i][j]);
		} 
  	}

} 

void loop2chunk(int lo, int hi) 
{
  	int i,j,k; 
  	double rN2; 

  	rN2 = 1.0 / (double) (N*N);  

  	for (i=lo; i<hi; i++)
  	{ 
		for (j=0; j < jmax[i]; j++)
		{
	  		for (k=0; k<j; k++)
	  		{ 
				c[i] += (k+1) * log (b[i][j]) * rN2;
	  		} 
		}
  	}

}

void valid1(void) 
{ 
  	int i,j; 
  	double suma; 
  
  	suma= 0.0; 
  	for (i=0; i<N; i++){ 
		for (j=0; j<N; j++){ 
	  		suma += a[i][j];
		}
  	}
  	printf("Loop 1 check: Sum of a is %lf\n", suma);

} 

void valid2(void) 
{ 
  	int i; 
  	double sumc; 
  
  	sumc= 0.0; 
  	for (i=0; i<N; i++)
  	{ 
		sumc += c[i];
  	}
  	printf("Loop 2 check: Sum of c is %f\n", sumc);
} 

int read_user_inputs(int an, char **av, int *nthreads)
{
	int ai = 1;

	if(an==1)
	{
		fprintf(stderr, "Please specify the number of threads using -n option.\n");
		return 1;
	}

	ai = 1;

	while(ai<an)
	{
		if(!strcmp(av[ai],"-n"))
		{
			*nthreads = atoi(av[ai+1]);
			// fprintf(stderr, "Running on %d threads.\n", *nthreads);
			ai+=2;
		}else
		{
			fprintf(stderr, "Invalid command line argument. Please only specify the number of threads using -n.\n");;
			return 1;
		}
	}

	return 0;

}
 