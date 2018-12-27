# Threaded Programming

## What is included

The `src/loops_affinity.c` file contains the sumbitted version of the affinity scheduling implementation.
The structure definition is included in `includes/loop_affinity.h`.
Raw data from the experiments are included in `res/affinity` along with figures included in the report.

## Usage
### Compiling and running affinity scheduler
```sh
$ make affinity $THREADS=n
```
where n is the number of threads to execute the scheduler on.
If the `CCFLAGS += -DLOCK` at the top of the `Makefile` is commented, the version with critical region will be compiled and executed. To compile and execute the version with locks, uncomment the line and run again the same make recipy.

```sh
$ make clean
```
to create a clean directory.