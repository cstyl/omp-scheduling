#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

#include "resources.h"
#include "affinity.h"
#include "workload.h"
#include "omplib.h"
#include "mem.h"

void init_affinity(thread_str *t, local_str *local);
void end_affinity(thread_str *t, local_str *local);

void initialise_thread(local_str *local);
void initialise_global_queues(thread_str *t, local_str local);

bound_str get_bounds(bound_str space, int current_block, int total_blocks, int offset);
int get_stepsize(int low, int high, int total_blocks);
int get_most_loaded_thread(int *next_lo, bound_str *local, int nthreads);
bound_str get_work(thread_str *t, int thread_id, int nthreads);

void runloop_affinity(int loopid)
{
  	thread_str t;
  	t.global.lo = 0;
  	t.global.hi = N;

	#pragma omp parallel default(none) shared(loopid, t) 
  	{
  		local_str local;

  		init_affinity(&t, &local);

		while(1)
		{
			if(local.affinity)
			{
				local.most_loaded = get_most_loaded_thread(t.next_lo, t.local, local.nthreads);
				if(local.most_loaded == DONE)
					break;
			}

			local.current = get_work(&t, local.most_loaded, local.nthreads);

  			if(local.current.hi>= t.local[local.most_loaded].hi)
  			{
  				local.current.hi = t.local[local.most_loaded].hi;
  				local.affinity = TRUE;
  			}

  			execute_work(loopid, local.current.lo, local.current.hi);
		}

		end_affinity(&t, &local);
  	} // end pragma 
}

void init_affinity(thread_str *t, local_str *local)
{
	initialise_thread(local);
	
    #pragma omp single
    {
      	// allocate required memory for all threads
    	malloc_structure(t, *local);
    }

	initialise_global_queues(t, *local);
	
	/* make sure all the threads have initialised their shared data */
	#pragma omp barrier	
}

void end_affinity(thread_str *t, local_str *local)
{
	#pragma omp barrier

#ifdef LOCK
		deallocate_lock(&t->lock[local->tid]);
		#pragma omp barrier	// ensure all locks are deallocated before freeing memory
#endif
	    #pragma omp single
	    {
	      	// deallocates required memory for all threads
	    	free_structure(t);
	    }
}

void initialise_thread(local_str *local)
{
	local->tid = get_tid();
	local->nthreads = get_total_threads();
	local->most_loaded = local->tid;
	local->affinity = FALSE;
}

void initialise_global_queues(thread_str *t, local_str local)
{
#ifdef LOCK
	allocate_lock(&t->lock[local.tid]);
#endif
	t->local[local.most_loaded] = get_bounds(t->global, local.most_loaded, local.nthreads, 0);		
	t->next_lo[local.most_loaded] = t->local[local.most_loaded].lo;
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

bound_str get_work(thread_str *t, int thread_id, int nthreads)
{
	bound_str c;
	int stepsize;
	
#ifdef LOCK
	set_lock(&t->lock[thread_id]);
#else
	#pragma omp critical
	{
#endif
		c.lo = t->next_lo[thread_id];
			
  		stepsize = get_stepsize(c.lo, t->local[thread_id].hi, nthreads);
  		t->next_lo[thread_id] += stepsize;

#ifdef LOCK
	unset_lock(&t->lock[thread_id]);
#else
	} // end of critical
#endif			

	c.hi = c.lo + stepsize;

  	return c;	
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