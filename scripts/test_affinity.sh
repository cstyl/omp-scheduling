#!/bin/bash
EXEC=("affinity_critical" "affinity_lock")
THREADS="1 2 4 6 8 12 16"
REPS=10

cd res
mkdir -p affinity
cd ..

outfile="res/affinity/results_affinity.csv"
testfile="out/aff_test_results.txt"
last_element_file="out/aff_temp_results.txt"
merge_element_file="out/aff_temp_results2.txt"

printf "exec, num_threads, reps, res1, t1, res2, t2 \n" > $outfile

for i in `seq 0 1`
do
	ver=$((i + 4))
	for j in ${THREADS}
	do
		echo "Running bin/${EXEC[${i}]} on ${j} threads"
		for k in `seq 0 $REPS`
		do
			echo "Starting repetition ${k}"
			echo "${ver}, ${j}, ${k}," > $testfile
			# run the code
			bin/${EXEC[${i}]} -n ${j} > $last_element_file
			# get last element of each line
			awk '{print $NF}' $last_element_file > $merge_element_file
			# combine 4 lines into 1, separated by commas
			awk 'NR%4{printf "%s, ",$0;next;}1' $merge_element_file >> $testfile 
			# combine 2 lines into 1, separated by commas 
			awk 'NR%2{printf "%s ",$0;next;}1' $testfile >> $outfile
		done
	done		
done

# remove intermediate files
rm -f $testfile $last_element_file $merge_element_file