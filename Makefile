#
# C compiler and options for Intel
#
CC = icc

CCFLAGS = -O3 -qopenmp -std=c99
CCFLAGS += -Wall
# Uncomment below to compile the affinity scheduler with locks
CCFLAGS += -DLOCK
LIB= -lm
#
# C compiler and options for PGI 
#
#CC=     pgcc -O3 -mp -tp=px
#LIB=	-lm

#
# C compiler and options for GNU 
#
#CC=     gcc -O3 -fopenmp
#LIB=	-lm

SRC = src
OBJ = obj
BIN = bin
RES = res
OUT = out
SCR = scripts
INC = includes

VPATH = $(SRC) $(OBJ) $(BIN) $(RES) $(OUT) $(SCR) $(INC)
INCLUDES += -I $(INC)
#
# Object files
#
SCH_OBJ = $(OBJ)/loops_scheduling.o
AFF_OBJ = $(OBJ)/loops_affinity.o
REF_OBJ = $(OBJ)/ref.o

all: clean $(BIN)/loops_scheduling $(BIN)/loops_affinity

.PHONY: ref 
ref: $(BIN)/ref
	$(BIN)/ref

.PHONY: run
run: $(BIN)/loops_affinity $(BIN)/loops_scheduling
	$(BIN)/loops_affinity
	$(BIN)/loops_scheduling

affinity: $(BIN)/loops_affinity
	$(BIN)/loops_affinity	

scheduling: $(BIN)/loops_scheduling
	$(BIN)/loops_scheduling

plot:
	python scripts/plot_results.py -r 1 -d res/find_schedule/
	python scripts/plot_results.py -r 10 -d res/find_schedule/

best_plot:
	python scripts/speed_up_plot.py -r 10 -d res/best_schedule/
#
# Compile
#
$(BIN)/ref:   $(REF_OBJ)
	$(CC) $(CCFLAGS) -o $@ $(REF_OBJ) $(LIB)

$(BIN)/loops_affinity:   $(AFF_OBJ)
	$(CC) $(CCFLAGS) -o $@ $(AFF_OBJ) $(LIB)

$(BIN)/loops_scheduling:   $(SCH_OBJ)
	$(CC) $(CCFLAGS) -o $@ $(SCH_OBJ) $(LIB)

$(OBJ)/%.o: %.c
	$(CC) $(CCFLAGS) $(INCLUDES) -o $@ -c $<

#
# Clean out object files and the executable.
#
clean:
	rm -rf $(OBJ) $(BIN) $(OUT)
	mkdir -p $(OBJ) $(BIN) $(OUT)
