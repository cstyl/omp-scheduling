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
SCR = scripts
INC = includes

AFF = $(SRC)/affinity
LOOPS = $(SRC)/loops
OMPLIB = $(SRC)/omplib

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

plot:
	python scripts/plot_results.py -r 1 -d res/find_schedule/
	python scripts/plot_results.py -r 10 -d res/find_schedule/

best_plot:
	python scripts/speed_up_plot.py -r 10 -d res/best_schedule/

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
