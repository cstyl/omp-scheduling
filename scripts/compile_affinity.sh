#!/bin/bash

# compiles and runs affinity scheduling for different versions
# version 1: constant stepsize with critical
# version 2: constant stepsize with locks
# version 3: variable stepsize with critical
# version 4: variable stepsize with locks
CC="icc"
CCFLAGS="-O3 -qopenmp -std=c99 -Wall"
INCLUDES="-Iincludes"
SRC="src"
OBJ="obj"
BIN="bin"
FILES="loops_affinity"
DEFINE=(" " "-DLOCK")
LIB="-lm"

BIN_NAME=("critical" "lock")

#compile reference
echo "${CC} ${CCFLAGS} ${INCLUDES} -o ${OBJ}/ref.o -c ${SRC}/ref.c"
${CC} ${CCFLAGS} ${INCLUDES} -o ${OBJ}/ref.o -c ${SRC}/ref.c
#link reference
echo "${CC} ${CCFLAGS} -o ${OBJ}/loops_scheduling.o ${BIN}/scheduling ${LIB}"
${CC} ${CCFLAGS} -o ${BIN}/ref ${OBJ}/ref.o ${LIB}

#compile scheduling using runtime option
echo "${CC} ${CCFLAGS} -DRUNTIME ${INCLUDES} -o ${OBJ}/loops_scheduling.o -c ${SRC}/loops_scheduling.c"
${CC} ${CCFLAGS} -DRUNTIME ${INCLUDES} -o ${OBJ}/loops_scheduling.o -c ${SRC}/loops_scheduling.c
#link scheduling
echo "${CC} ${CCFLAGS} -o ${OBJ}/loops_scheduling.o ${BIN}/scheduling ${LIB}"
${CC} ${CCFLAGS} -o ${BIN}/scheduling ${OBJ}/loops_scheduling.o ${LIB}

#compile best scheduling
echo "${CC} ${CCFLAGS} ${INCLUDES} -o ${OBJ}/loops_scheduling.o -c ${SRC}/loops_scheduling.c"
${CC} ${CCFLAGS} ${INCLUDES} -o ${OBJ}/loops_scheduling.o -c ${SRC}/loops_scheduling.c
#link best scheduling
echo "${CC} ${CCFLAGS} -o ${OBJ}/loops_scheduling.o ${BIN}/scheduling_best ${LIB}"
${CC} ${CCFLAGS} -o ${BIN}/scheduling_best ${OBJ}/loops_scheduling.o ${LIB}

for i in $(seq -w 0 1)
do
	#compile all versions of affinity
	echo "${CC} ${CCFLAGS} ${DEFINE[${i}]} ${INCLUDES} -o ${OBJ}/loops_affinity_${i}.o -c ${SRC}/loops_affinity.c"
	${CC} ${CCFLAGS} ${DEFINE[${i}]} ${INCLUDES} -o ${OBJ}/loops_affinity_${i}.o -c ${SRC}/loops_affinity.c
	#link
	echo "${CC} ${CCFLAGS} -o ${BIN}/affinity_${BIN_NAME[${i}]} ${OBJ}/loops_affinity_${i}.o ${LIB}"
	${CC} ${CCFLAGS} -o ${BIN}/affinity_${BIN_NAME[${i}]} ${OBJ}/loops_affinity_${i}.o ${LIB}
done