#
# C compiler and options for Intel
#
CC = icc

# Uncomment below to compile the affinity scheduler with locks
# DEFINE += -DLOCK -DAFFINITY -DRUNTIME -DBEST_SCHEDULE
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
#
# Object files
#
OMPLIB_OBJ = $(OBJ)/omplib.o
LOOPS_OBJ = $(OBJ)/workload.o
AFFINITY_OBJ = $(OBJ)/affinity.o $(OBJ)/mem.o

MAIN_OBJ = $(OBJ)/main.o

all: dir
	make $(BIN)/serial -B
	make $(BIN)/runtime DEFINE=-DRUNTIME -B
	make $(BIN)/best_schedule DEFINE=-DBEST_SCHEDULE -B
	make $(BIN)/affinity DEFINE=-DAFFINITY -B
	make $(BIN)/affinity_lock DEFINE=-DAFFINITY DEFINE+=-DLOCK -B

dir:
	mkdir -p $(OBJ) $(BIN) $(OUT)

plot:
	python scripts/plot_results.py -r 1 -d res/find_schedule/
	python scripts/plot_results.py -r 10 -d res/find_schedule/

best_plot:
	python scripts/speed_up_plot.py -r 10 -d res/best_schedule/
#
# Compile
#
$(OBJ)/%.o: %.c
	$(CC) $(CCFLAGS) $(DEFINE) $(INCLUDES) -o $@ -c $<

#
# Link
#	
$(BIN)/serial: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(MAIN_OBJ)
	$(CC) $^ -o $@ $(LIB)

$(BIN)/runtime: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(MAIN_OBJ)
	$(CC)  $^ -o $@ $(LIB)

$(BIN)/best_schedule: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

$(BIN)/affinity: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(AFFINITY_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

$(BIN)/affinity_lock: $(OMPLIB_OBJ) $(LOOPS_OBJ) $(AFFINITY_OBJ) $(MAIN_OBJ)
	$(CC) $(CCFLAGS) $^ -o $@ $(LIB)

#
# Clean out object files and the executable.
#
clean:
	rm -rf $(OBJ) $(BIN) $(OUT)
