#ifndef __MEM_H__
#define __MEM_H__

#include "affinity_structs.h"

int malloc_structure(thread_str *t, local_str local);
int free_structure(thread_str *t);

#endif	//__MEM_H__