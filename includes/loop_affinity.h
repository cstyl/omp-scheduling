#ifndef __LOOP_AFFINITY_H__
#define __LOOP_AFFINITY_H__
#include <stdio.h>
#include <stdlib.h>
#include <math.h>


#define MALLOC(ptr, elements, type) \
({\
    ptr = NULL;\
    ptr  = (type *) malloc(elements * sizeof(type));\
    if(ptr == NULL)\
    {\
        fprintf(stderr, "ERROR::%s:%d:%s: Memory allocation did not complete successfully!\n", __FILE__, __LINE__,__func__);\
        return 1;\
    }\
})

#define FREE(ptr) \
({\
    free(ptr);\
    if(ptr == NULL)\
    {\
        fprintf(stderr, "ERROR::%s:%d:%s: Memory deallocation did not complete successfully!\n", __FILE__, __LINE__,__func__);\
        return 1;\
    }else{\
        ptr = NULL;\
    }\
})

#define CHECK_ERROR(error) \
({\
    if(error!=0)\
    {\
        printf("Error is %d\n", error);\
        return error;\
    }\
})


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

#endif  //__LOOP_AFFINITY_H__