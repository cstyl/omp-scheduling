#!/bin/bash
resdir="res/best_loop2"			# directory where results are placed
outdir="out"					# directory for any temporary output files

KIND=(static dynamic guided)	# tested kinds of scheduling
THREADS="1 2 4 6 8 16"			# max number of threads			
CHUNKSIZE="1 2 4 8 16 32 64"	# chunksize of each kind		
REPS=10							# number of repetitions of each combination

outfile="${resdir}/best_loop2_results.csv"
testfile="${outdir}/best_test_results.txt"
last_element_file="${outdir}/best_temp_results.txt"
merge_element_file="${outdir}/best_temp_results2.txt"

echo "Running best_schedule script"
printf "chunksize, num_threads, reps, t1, res1, t2, res2 \n" > $outfile

# run program for all kinds of schedules for a predifined chunksizes.
# repeat each run REPS times for a more robust timings
for i in ${CHUNKSIZE}; do
	export OMP_SCHEDULE="dynamic,$i"
	for j in ${THREADS}; do
		export OMP_NUM_THREADS=${j}
		echo "Running on $OMP_NUM_THREADS threads"
		for k in $(seq -w 1 ${REPS}); do
			echo "Starting repetition ${k}"
			echo "${i}, $OMP_NUM_THREADS, ${k}," > $testfile
			# run the code
			bin/runtime > $last_element_file
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
