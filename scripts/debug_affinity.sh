#!/bin/bash

CC="gcc"
CCFLAGS="-O1 -g -fopenmp -std=c99 -Wall"
INCLUDES="-Iincludes"
SRC="src"
OBJ="obj"
BIN="bin"
FILES="loops_affinity"
DEFINE=(" " "-DLOCK")
LIB="-lm"

BIN_NAME=("critical_debug" "lock_debug")

for i in $(seq -w 0 1)
do
	#compile all versions of affinity
	echo "${CC} ${CCFLAGS} ${DEFINE[${i}]} ${INCLUDES} -o ${OBJ}/loops_affinity_${i}.o -c ${SRC}/loops_affinity.c"
	${CC} ${CCFLAGS} ${DEFINE[${i}]} ${INCLUDES} -o ${OBJ}/loops_affinity_${i}.o -c ${SRC}/loops_affinity.c
	#link
	echo "${CC} ${CCFLAGS} -o ${BIN}/affinity_${BIN_NAME[${i}]} ${OBJ}/loops_affinity_${i}.o ${LIB}"
	${CC} ${CCFLAGS} -o ${BIN}/affinity_${BIN_NAME[${i}]} ${OBJ}/loops_affinity_${i}.o ${LIB}
done