#ifndef __WORKLOAD_H__
#define __WORKLOAD_H__

void runloop(int loopid);
void init1(void);
void init2(void);
void execute_work(int loopid, int lo, int hi);
void loop1chunk(int lo, int hi);
void loop2chunk(int lo, int hi);
void valid1(void);
void valid2(void);

#endif	//__WORKLOAD_H__