#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

#include "resources.h"
#include "workload.h"  

void runloop(int loopid)
{
    int lo = 0;
    int hi = N;
    
    execute_work(loopid, lo, hi);
}

void init1(void){
	int i,j; 


	for (i=0; i<N; i++){ 
		for (j=0; j<N; j++){ 
  			a[i][j] = 0.0; 
	  		b[i][j] = 3.142*(i+j); 
		}
	}
}

void init2(void){ 
  	int i,j, expr; 

  	for (i=0; i<N; i++){ 
    	expr =  i%( 3*(i/30) + 1); 
    	if ( expr == 0) { 
      		jmax[i] = N;
    	}
    	else {
      		jmax[i] = 1; 
    	}
    	c[i] = 0.0;
	}

  	for (i=0; i<N; i++){ 
		for (j=0; j<N; j++){ 
      		b[i][j] = (double) (i*j+1) / (double) (N*N); 
    	}
  	}
} 

void execute_work(int loopid, int lo, int hi)
{
  	switch (loopid) 
  	{ 
	 	case 1: loop1chunk(lo,hi); break;
	 	case 2: loop2chunk(lo,hi); break;
  	}	
}

void loop1chunk(int lo, int hi) { 
  	int i,j; 

#ifdef RUNTIME
  #pragma omp parallel for schedule(runtime) \
                           shared(a,b,lo,hi) private(i,j) \
                           default(none)
#elif defined BEST_SCHEDULE
  #pragma omp parallel for schedule(guided, 16) \
                           shared(a,b,lo,hi) private(i,j) \
                           default(none)
#elif defined BEST_SCHEDULE_LOOP2
  #pragma omp parallel for schedule(guided, 16) \
                           shared(a,b,lo,hi) private(i,j) \
                           default(none)
#else
/* Serial Code executed */                          
#endif
    for (i=lo; i<hi; i++){ 
      	for (j=N-1; j>i; j--){
        	a[i][j] += cos(b[i][j]);
      	} 
    }

} 


void loop2chunk(int lo, int hi) {
  	int i,j,k; 
  	double rN2; 

  	rN2 = 1.0 / (double) (N*N);  

#ifdef RUNTIME
  #pragma omp parallel for schedule(runtime) \
                           shared(jmax, c, b, rN2,lo,hi) private(i,j,k) \
                           default(none)
#elif defined BEST_SCHEDULE
  #pragma omp parallel for schedule(dynamic,8) \
                           shared(jmax, c, b, rN2,lo,hi) private(i,j,k) \
                           default(none) 
#elif defined BEST_SCHEDULE_LOOP2
  #pragma omp parallel for schedule(dynamic,4) \
                           shared(jmax, c, b, rN2,lo,hi) private(i,j,k) \
                           default(none)                          
#else
/* Serial Code executed */   
#endif
    for (i=lo; i<hi; i++){ 
      	for (j=0; j < jmax[i]; j++){
        	for (k=0; k<j; k++){ 
  	       		c[i] += (k+1) * log (b[i][j]) * rN2;
        	} 
      	}
    }

}

void valid1(void) { 
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


void valid2(void) { 
  	int i; 
  	double sumc; 
  
  	sumc= 0.0; 
  	for (i=0; i<N; i++){ 
    	sumc += c[i];
  	}
  	printf("Loop 2 check: Sum of c is %f\n", sumc);
} 
