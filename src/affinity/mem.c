#include "mem.h"

int malloc_structure(thread_str *t, local_str local)
{
	MALLOC(t->local,   local.nthreads, bound_str);
	MALLOC(t->next_lo, local.nthreads, int);

#ifdef LOCK
	MALLOC(t->lock,	   local.nthreads, omp_lock_t);
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