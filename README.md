# Scheduling policies in OpenMP

This is a repository where various scheduling policies available in **OpenMP** are investigated. The investigation is performed for two different workloads, one that is slightly unbalanced called `loop1` and the other one that is very unbalanced with the most of the work concentrated in the first few iterations, called `loop2`.

The following schedulers provided by OpenMP are investigated:
- `STATIC,n`
- `DYNAMIC,n`
- `GUIDED,n`

where `n` is the selected chunksize.

Additionally, a scheduler was designed by hand called `affinity` scheduler aiming to combine the characteristics of the afformentioned schedulers and compare the performance.

## What is included
- `includes/`:  Contains the header file called `resources.h` necessary for the development of the code. Additionally, contains `affinity_structs.h` and `macros.h` necessary for the development of the *affinity* scheduler.
- `src/main.c`: The main source file used to execute each scheduling option for the two available workloads.
- `src/loops/`: Contains all the functions relevant to the workload, i.e initialisation and validation as well as execution of the workload.
- `src/omplib/`: Contains wrap functions of **OpenMP** commands in an effort to hide the APIs functions.
- `src/affinity/`: Contains all the functions used to develop the *affinity* scheduler.

## Options
The designed *affinity* scheduler comes in two versions. The first one uses `critical regions` in order to synchronize the threads while the second `locks`. One can choose between the two versions by compiling the code with different `DEFINE` flag. Moreover, one can also choose between which scheduler to use to measure its performance. In other words, one can use another `DEFINE` flag to choose between the `best_scheduling` option chosen for each workload or choose to determine the scheduling option on the runtime.

The following options are available:
- `-DRUNTIME`: Choose to select the scheduling option on the runtime.
- `-DBEST_SCHEDULE`: Choose to use the best scheduling option determined for each workload.
- `-DBEST_SCHEDULE_LOOP2`: Choose to use the best scheduling option determined for each workload after a further investigation of `loop2`.
- `-DAFFINITY`: Choose to use affinity scheduler.
	- `-DLOCK`: If set, the affinity scheduler with locks is used, otherwise the one with critical regions.

Note that one should only choose one of the four main options shown above. In case no option is selected, the `serial` version of the code is being executed.


## Usage

### Prerequisites:
- Compiler: [icc](https://software.intel.com/sites/default/files/m/d/4/1/d/8/icc.txt)
- Build Tool: [make](https://www.gnu.org/software/make/)

### Building

To compile all the available versions of the code use:
```sh
$ make all
```
This will create all the necessary directories for the code to be executed. All the versions of the code are compiled using the different options showed above. This will result in the following executables:
- `bin/serial`: Serial version of the code.
- `bin/runtime`: Parallel version of the code where scheduling can be determined on the runtime. Note that only the scheduling options provided by **OpenMP** can be selected.
- `bin/best_schedule`: The best scheduling options provided by **OpenMP** are used for each workload.
- `bin/best_schedule_loop2`: The best scheduling options provided by **OpenMP** are used for each workload after the best schedule option for `loop2` was tunned based on its chunksize.
- `bin/affinity`: The affinity scheduler with critical regions is used.
- `bin/affinity_lock`: The affinity scheduler with locks is used.

Alternatively, one can compile each version as follows:
Create the required directories using:
```sh
$ make dir
```
Build the serial version:
```sh
$ make bin/serial -B
icc -O3 -qopenmp -std=c99 -Wall  -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/omplib.o -c src/omplib/omplib.c
icc -O3 -qopenmp -std=c99 -Wall  -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/workload.o -c src/loops/workload.c
icc -O3 -qopenmp -std=c99 -Wall  -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/main.o -c src/main.c
icc obj/omplib.o obj/workload.o obj/main.o -o bin/serial -lm -qopenmp
```

Build the runtime version:
```sh
$ make bin/runtime DEFINE=-DRUNTIME -B
icc -O3 -qopenmp -std=c99 -Wall -DRUNTIME -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/omplib.o -c src/omplib/omplib.c
icc -O3 -qopenmp -std=c99 -Wall -DRUNTIME -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/workload.o -c src/loops/workload.c
icc -O3 -qopenmp -std=c99 -Wall -DRUNTIME -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/main.o -c src/main.c
icc  obj/omplib.o obj/workload.o obj/main.o -o bin/runtime -lm -qopenmp
```

Build the best_scheduling version:
```sh
$ make bin/best_schedule DEFINE=-DBEST_SCHEDULE -B
icc -O3 -qopenmp -std=c99 -Wall -DBEST_SCHEDULE -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/omplib.o -c src/omplib/omplib.c
icc -O3 -qopenmp -std=c99 -Wall -DBEST_SCHEDULE -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/workload.o -c src/loops/workload.c
icc -O3 -qopenmp -std=c99 -Wall -DBEST_SCHEDULE -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/main.o -c src/main.c
icc -O3 -qopenmp -std=c99 -Wall obj/omplib.o obj/workload.o obj/main.o -o bin/best_schedule -lm -qopenmp
```

Build the best_scheduling version for loop2:
```sh
$ make bin/best_schedule_loop2 DEFINE=-DBEST_SCHEDULE_LOOP2 -B
icc -O3 -qopenmp -std=c99 -Wall -DBEST_SCHEDULE_LOOP2 -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/omplib.o -c src/omplib/omplib.c
icc -O3 -qopenmp -std=c99 -Wall -DBEST_SCHEDULE_LOOP2 -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/workload.o -c src/loops/workload.c
icc -O3 -qopenmp -std=c99 -Wall -DBEST_SCHEDULE_LOOP2 -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/main.o -c src/main.c
icc -O3 -qopenmp -std=c99 -Wall obj/omplib.o obj/workload.o obj/main.o -o bin/best_schedule_loop2 -lm -qopenmp
```

Build the affinity version with critical regions:
```sh
$ make bin/affinity DEFINE=-DAFFINITY -B
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/omplib.o -c src/omplib/omplib.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/workload.o -c src/loops/workload.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/affinity.o -c src/affinity/affinity.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/mem.o -c src/affinity/mem.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/main.o -c src/main.c
icc -O3 -qopenmp -std=c99 -Wall obj/omplib.o obj/workload.o obj/affinity.o obj/mem.o obj/main.o -o bin/affinity -lm -qopenmp
```

Build the affinity version with locks:
```sh
$ make bin/affinity_lock DEFINE=-DAFFINITY DEFINE+=-DLOCK -B
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -DLOCK -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/omplib.o -c src/omplib/omplib.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -DLOCK -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/workload.o -c src/loops/workload.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -DLOCK -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/affinity.o -c src/affinity/affinity.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -DLOCK -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/mem.o -c src/affinity/mem.c
icc -O3 -qopenmp -std=c99 -Wall -DAFFINITY -DLOCK -Iincludes -Isrc/affinity -Isrc/loops -Isrc/omplib -o obj/main.o -c src/main.c
icc -O3 -qopenmp -std=c99 -Wall obj/omplib.o obj/workload.o obj/affinity.o obj/mem.o obj/main.o -o bin/affinity_lock -lm -qopenmp
```

### Cleaning

To clean the project run:
```sh
$ make clean
```

### Running
To execute the serial code:
```sh
$ ./bin/serial
```

To execute the parallel code one has to choose the number of threads the code will be executed on. This can be done using:
```sh
$ export OMP_NUM_THREADS=$(THREADS)
```
where `$(THREADS)` is the number of threads selected.

To executed the runtime version:
```sh
$ export OMP_SCHEDULE=$(KIND,n)
$ ./bin/runtime
```
where `$(KIND,n)` is the selected scheduling option and chunksize used.

The available scheduling options are:
- `STATIC,n`: Static scheduler
- `DYNAMIC,n`: Dynamic scheduler
- `GUIDED,n`: Guided scheduler
where `n` is the selected chunksize.

**Example:**
```sh
$ export OMP_NUM_THREADS=4
$ export OMP_SCHEDULE=DYNAMIC,2
$ ./bin/runtime
```
This will execute the code on *4 threads* using a *dynamic* scheduler with *chunkisize of 2* for each workload.

To executed the best_scheduling version:
```sh
$ ./bin/best_schedule
```
This will execute the code with `GUIDED,16` for `loop1` and `DYNAMIC,8` for `loop2`.

To executed the best_scheduling_loop2 version:
```sh
$ ./bin/best_schedule_loop2
```
This will execute the code with `GUIDED,16` for `loop1` and `DYNAMIC,4` for `loop2`.

To executed the affinity version with critical regions use:
```sh
$ ./bin/affinity
```

To executed the affinity version with locks use:
```sh
$ ./bin/affinity_lock
```

## Tests

### Determining the best scheduling option for each workload on constant number of threads

#### Executing the test

#### Ploting the results

### Evaluating the performance of the selected best option on variable number of threads

#### Executing the test

#### Ploting the results

### Evaluating the performance of loop2 by tunning its chunksize

#### Executing the test

#### Ploting the results

### Evaluating the performance of affinity scheduling

#### Executing the test

#### Ploting the results
