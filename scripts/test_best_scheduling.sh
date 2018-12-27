#!/bin/bash
REPS=10
THREADS="1 2 4 6 8 12 16"

cd res
mkdir -p affinity
cd ..

outfile="res/affinity/results_scheduling_best.csv"
testfile="out/best_scheduling_test_results.txt"
last_element_file="out/best_scheduling_temp_results.txt"
merge_element_file="out/best_scheduling_temp_results2.txt"

printf "exec, num_threads, reps, res1, t1, res2, t2 \n" > $outfile

# run reference
echo "Running bin/scheduling_best ..."
for j in ${THREADS}; do
	export OMP_NUM_THREADS="${j}"
	echo "Running on $OMP_NUM_THREADS threads"
	for k in `seq 0 $REPS`
	do
		echo "Starting repetition ${k}"
		echo "6, $j, ${k}," > $testfile
		# run the code
		bin/scheduling_best > $last_element_file
		# get last element of each line
		awk '{print $NF}' $last_element_file > $merge_element_file
		# combine 4 lines into 1, separated by commas
		awk 'NR%4{printf "%s, ",$0;next;}1' $merge_element_file >> $testfile 
		# combine 2 lines into 1, separated by commas 
		awk 'NR%2{printf "%s ",$0;next;}1' $testfile >> $outfile
	done
done


# remove intermediate files
rm -f $testfile $last_element_file $merge_element_file