#
# C compiler and options for Intel
#
CC = icc

# Uncomment below to compile the affinity scheduler with locks
# DEFINE += -DLOCK -DAFFINITY -DRUNTIME -DBEST_SCHEDULE -DBEST_SCHEDULE_LOOP2
DEFINE =

CCFLAGS = -O3 -qopenmp -std=c99
CCFLAGS += -Wall
LIB= -lm -qopenmp


SRC = src
OBJ = obj
BIN = bin
RES = res
OUT = out
SCRIPTS = scripts
INC = includes

AFF = $(SRC)/affinity
LOOPS = $(SRC)/loops
OMPLIB = $(SRC)/omplib

PBS = $(SCRIPTS)/pbs
PERF = $(SCRIPTS)/performance
PLOTS = $(SCRIPTS)/plots

VPATH = $(SRC) $(OBJ) $(BIN) $(RES) $(OUT) $(SCR) $(INC) \
		$(AFF) $(LOOPS) $(OMPLIB)

INCLUDES += -I$(INC) -I$(AFF) -I$(LOOPS) -I$(OMPLIB)

OMPLIB_OBJ = $(OBJ)/omplib.o
LOOPS_OBJ = $(OBJ)/workload.o
AFFINITY_OBJ = $(OBJ)/affinity.o $(OBJ)/mem.o

MAIN_OBJ = $(OBJ)/main.o

## all: compile and create the executables
.PHONY: all
all: dir
	@make $(BIN)/serial -B
	@make $(BIN)/runtime DEFINE=-DRUNTIME -B
	@make $(BIN)/best_schedule DEFINE=-DBEST_SCHEDULE -B
	@make $(BIN)/best_schedule_loop2 DEFINE=-DBEST_SCHEDULE_LOOP2 -B
	@make $(BIN)/affinity DEFINE=-DAFFINITY -B
	@make $(BIN)/affinity_lock DEFINE=-DAFFINITY DEFINE+=-DLOCK -B

## dir: create necessary directories
.PHONY: dir
dir:
	@mkdir -p $(OBJ) $(BIN) $(OUT)

## run_tests_front: Runs all tests on the front end
.PHONY: run_tests_front
run_tests_front: runtime_test best_schedule_test best_schedule_loop2_test affinity_schedule_test performance_comparison_test

## run_tests_back: Runs all tests on the back end
.PHONY: run_tests_back
run_tests_back: runtime_test_back best_schedule_test_back best_schedule_loop2_test_back affinity_schedule_test_back performance_comparison_test_back

## plot_tests: Plots all test results
.PHONY: plot_tests
plot_tests: plot_runtime_test plot_best_schedule_test plot_best_schedule_loop2_test plot_affinity_schedule_test plot_performance_comparison_test

# Performance tests on the front end
runtime_test:
	chmod u+x $(PERF)/runtime.sh
	./$(PERF)/runtime.sh

best_schedule_test:
	chmod u+x $(PERF)/best_schedule.sh
	./$(PERF)/best_schedule.sh

best_schedule_loop2_test:
	chmod u+x $(PERF)/best_schedule_loop2.sh
	./$(PERF)/best_schedule_loop2.sh

affinity_schedule_test:
	chmod u+x $(PERF)/affinity_schedule.sh
	./$(PERF)/affinity_schedule.sh

performance_comparison_test:
	chmod u+x $(PERF)/performance_comparison.sh
	./$(PERF)/performance_comparison.sh

# Performance tests on the back end
runtime_test_back:
	chmod u+x $(PERF)/runtime.sh
	chmod u+x $(PBS)/runtime.pbs
	qsub ./$(PBS)/runtime.pbs

best_schedule_test_back:
	chmod u+x $(PERF)/best_schedule.sh
	chmod u+x $(PBS)/best_schedule.pbs
	qsub ./$(PBS)/best_schedule.pbs

best_schedule_loop2_test_back:
	chmod u+x $(PERF)/best_schedule_loop2.sh
	chmod u+x $(PBS)/best_schedule_loop2.pbs
	qsub ./$(PBS)/best_schedule_loop2.pbs

affinity_schedule_test_back:
	chmod u+x $(PERF)/affinity_schedule.sh
	chmod u+x $(PBS)/affinity_schedule.pbs
	qsub ./$(PBS)/affinity_schedule.pbs

performance_comparison_test_back:
	chmod u+x $(PERF)/performance_comparison.sh
	chmod u+x $(PBS)/performance_comparison.pbs
	qsub ./$(PBS)/performance_comparison.pbs

# Plot the test results
plot_runtime_test:
	python $(PLOTS)/plot_runtime.py

plot_best_schedule_test:
	python $(PLOTS)/plot_best_schedule.py

plot_best_schedule_loop2_test:
	python $(PLOTS)/plot_best_schedule_loop2.py

plot_affinity_schedule_test:
	python $(PLOTS)/plot_affinity_schedule.py

plot_performance_comparison_test:
	python $(PLOTS)/plot_performance_comparison.py

# compile all c files and create the output files
$(OBJ)/%.o: %.c
	$(CC) $(CCFLAGS) $(DEFINE) $(INCLUDES) -o $@ -c $<

# link the output files to create the executable
$(BIN)/serial: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

$(BIN)/runtime: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

$(BIN)/best_schedule: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

$(BIN)/best_schedule_loop2: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

$(BIN)/affinity: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(AFFINITY_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

$(BIN)/affinity_lock: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(AFFINITY_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

## clean: clean directory
.PHONY: clean
clean:
	@rm -rf $(OBJ) $(BIN) $(OUT)

# help: prints each repice's purpose
.PHONY: help
help: Makefile
	@sed -n 's/^##//p' $<
