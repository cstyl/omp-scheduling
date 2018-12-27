#!/bin/bash
REPS=10

LOOP1=("static,4" "dynamic,4" "guided,16")
LOOP2=("static,8" "dynamic,16" "guided,8")
THREADS="1 2 4 6 8 12 16"
cd res
mkdir -p affinity
cd ..

outfile1="res/affinity/results_scheduling_loop1.csv"
outfile2="res/affinity/results_scheduling_loop2.csv"
testfile="out/scheduling_test_results.txt"
last_element_file="out/scheduling_temp_results.txt"
merge_element_file="out/scheduling_temp_results2.txt"

# printf "exec, num_threads, reps, res1, t1, res2, t2 \n" > $outfile1

# # measure loop 1 first
# for i in `seq 0 2`; do
# 	ver=$((i + 1))
# 	export OMP_SCHEDULE="${LOOP1[$i]}"
# 	echo "Running schedule $OMP_SCHEDULE"
# 	for j in ${THREADS}; do
# 		export OMP_NUM_THREADS="${j}"
# 		echo "Running on $OMP_NUM_THREADS threads"
# 		for k in `seq 0 $REPS`; do
# 			echo "Starting repetition $k"
# 			echo "${ver}, $j, $k," > $testfile
# 			# run the code
# 			bin/scheduling > $last_element_file
# 			# get last element of each line
# 			awk '{print $NF}' $last_element_file > $merge_element_file
# 			# combine 4 lines into 1, separated by commas
# 			awk 'NR%4{printf "%s, ",$0;next;}1' $merge_element_file >> $testfile 
# 			# combine 2 lines into 1, separated by commas 
# 			awk 'NR%2{printf "%s ",$0;next;}1' $testfile >> $outfile1			
# 		done
# 	done
# done

printf "exec, num_threads, reps, res1, t1, res2, t2 \n" > $outfile2

# measure loop 1 first
for i in `seq 0 2`; do
	ver=$((i + 1))
	export OMP_SCHEDULE="${LOOP2[$i]}"
	echo "Running schedule $OMP_SCHEDULE"
	for j in ${THREADS}; do
		export OMP_NUM_THREADS="${j}"
		echo "Running on $OMP_NUM_THREADS threads"
		for k in `seq 0 $REPS`; do
			echo "Starting repetition $k"
			echo "${ver}, $j, $k," > $testfile
			# run the code
			bin/scheduling > $last_element_file
			# get last element of each line
			awk '{print $NF}' $last_element_file > $merge_element_file
			# combine 4 lines into 1, separated by commas
			awk 'NR%4{printf "%s, ",$0;next;}1' $merge_element_file >> $testfile 
			# combine 2 lines into 1, separated by commas 
			awk 'NR%2{printf "%s ",$0;next;}1' $testfile >> $outfile2			
		done
	done
done

# remove intermediate files
rm -f $testfile $last_element_file $merge_element_file
