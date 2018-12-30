#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <omp.h> 

#include "resources.h"
#include "workload.h"
#include "omplib.h"
#ifdef AFFINITY
	#include "affinity.h"
#endif

int main(int argc, char *argv[]) { 
	time_str l1,l2;
  	int r;

  	init1(); 

  	l1.start = gettime(); 

  	for (r=0; r<reps; r++){ 
#ifdef AFFINITY
  		runloop_affinity(1);
#else
    	runloop(1);
#endif
  	} 

  	l1.end  = gettime();  

  	valid1(); 

  	printf("Total time for %d reps of loop 1 = %f\n",reps, (float)(l1.end-l1.start)); 


  	init2(); 

  	l2.start = gettime(); 

  	for (r=0; r<reps; r++){ 
#ifdef AFFINITY
  		runloop_affinity(2);
#else
    	runloop(2);
#endif
  	} 

  	l2.end  = gettime(); 

  	valid2(); 

  	printf("Total time for %d reps of loop 2 = %f\n",reps, (float)(l2.end-l2.start)); 

  	return 0;
}

