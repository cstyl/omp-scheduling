#!/bin/bash
resdir="res/runtime"		# directory where results are placed
outdir="out"					# directory for any temporary output files

KIND=(static dynamic guided)	# tested kinds of scheduling
CHUNKSIZE="1 2 4 8 16 32 64"	# chunksize of each kind
THREADS=4						# max number of threads
REPS=10							# number of repetitions of each combination

outfile="${resdir}/runtime_results.csv"
testfile="${outdir}/test_results.txt"
last_element_file="${outdir}/temp_results.txt"
merge_element_file="${outdir}/temp_results2.txt"
best_option_file="${outdir}/best_option.txt"

echo "Running runtime script"
printf "num_threads, kind, chunksize, reps, t1, res1, t2, res2 \n" > $outfile

export OMP_NUM_THREADS=${THREADS}
# run program for all kinds of schedules for a predifined chunksizes.
# repeat each run REPS times for a more robust timings
for i in `seq -w 0 $((${#KIND[@]}-1))`; do
	for j in ${CHUNKSIZE}; do
		export OMP_SCHEDULE="${KIND[$i]},$j"
		echo "Running schedule $OMP_SCHEDULE"
		for k in $(seq -w 1 ${REPS}); do
			echo "Starting repetition $k"
			echo "$OMP_NUM_THREADS, $[i+1], $j, $k," > $testfile
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
