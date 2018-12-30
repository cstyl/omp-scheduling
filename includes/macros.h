#ifndef __MACROS_H__
#define __MACROS_H__

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

#endif	//__MACROS_H__