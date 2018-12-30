#ifndef __OMPLIB_H__
#define __OMPLIB_H__

int get_tid(void);
int get_total_threads(void);
double gettime(void);

void allocate_lock(omp_lock_t *lock);
void deallocate_lock(omp_lock_t *lock);
void set_lock(omp_lock_t *lock);
void unset_lock(omp_lock_t *lock);

#endif	//__OMPLIB_H__