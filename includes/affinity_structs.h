#ifndef __LOOP_AFFINITY_H__
#define __LOOP_AFFINITY_H__
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

#include "macros.h"

typedef struct boundary_struct
{
    int lo;
    int hi;
} bound_str;

typedef struct thread_struct
{
    bound_str global;
    bound_str *local;
    int *next_lo;
    int nthreads;
#ifdef LOCK
    omp_lock_t *lock;
#endif
} thread_str;

typedef struct local_struct
{
    int tid;
    int nthreads;
    bound_str current;
    int stepsize, most_loaded;
    int affinity;
} local_str;

#endif  //__LOOP_AFFINITY_H__