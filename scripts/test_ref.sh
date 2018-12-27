#!/bin/bash
REPS=10

cd res
mkdir -p affinity
cd ..

outfile="res/affinity/results_ref.csv"
testfile="out/ref_test_results.txt"
last_element_file="out/ref_temp_results.txt"
merge_element_file="out/ref_temp_results2.txt"

printf "exec, num_threads, reps, res1, t1, res2, t2 \n" > $outfile

# run reference
echo "Running bin/ref ..."
for k in `seq 0 $REPS`
do
	echo "Starting repetition ${k}"
	echo "0, 1, ${k}," > $testfile
	# run the code
	bin/ref > $last_element_file
	# get last element of each line
	awk '{print $NF}' $last_element_file > $merge_element_file
	# combine 4 lines into 1, separated by commas
	awk 'NR%4{printf "%s, ",$0;next;}1' $merge_element_file >> $testfile 
	# combine 2 lines into 1, separated by commas 
	awk 'NR%2{printf "%s ",$0;next;}1' $testfile >> $outfile
done


# remove intermediate files
rm -f $testfile $last_element_file $merge_element_file