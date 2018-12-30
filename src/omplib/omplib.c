#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>

#include "omplib.h"

int get_tid(void)
{
	return omp_get_thread_num();
}

int get_total_threads(void)
{
	return omp_get_num_threads();
}

double gettime(void)
{
	return omp_get_wtime();
}

void allocate_lock(omp_lock_t *lock)
{
	omp_init_lock(lock);
}

void deallocate_lock(omp_lock_t *lock)
{
	omp_destroy_lock(lock);
}

void set_lock(omp_lock_t *lock)
{
	omp_set_lock(lock);
}

void unset_lock(omp_lock_t *lock)
{
	omp_unset_lock(lock);
}
