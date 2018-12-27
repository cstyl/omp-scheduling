import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='Read number of repetitions and working directory')
parser.add_argument('-r', dest='reps', type=int, help='Enter the number of the repetitions performed')
parser.add_argument('-d', dest='dir', type=str, help='Enter the working directory')

args = parser.parse_args()

reps = args.reps
maindir = args.dir

filename = 'schedule_results_' + str(reps) + '.csv'
file = maindir + filename

data = np.genfromtxt(file, delimiter=',', skip_header=1)

kind_label=[1, 2, 3] # corresponds to static, dynamic and guided
kind = ['static', 'dynamic', 'guided']
chunksize=[1, 2, 4, 8, 16, 32, 64]
avg_time_loop1 = np.zeros((7,3))
avg_time_loop2 = np.zeros((7,3))

for num, label in enumerate(kind):
	# read kind type column
	blocks = data[:,1]
	# get data that only match the current kind type
	kind_data = data[blocks==num+1,:]

	idx = 0

	for j in chunksize:
		# get data that only match the current chunksize
		blocks = kind_data[:,2]
		chunk_data = kind_data[blocks==j,:]
		# take the average time for each chunksize
		avg_time_loop1[idx,num] = np.mean(chunk_data[:,5])
		avg_time_loop2[idx,num] = np.mean(chunk_data[:,7])
		idx += 1

# get best option for loop 1
min_l1 = np.argmin(avg_time_loop1)
best_chunk_l1 = chunksize[min_l1//3]
best_kind_l1 = kind[min_l1%3]
# get best option for loop 1
min_l2 = np.argmin(avg_time_loop2)
best_chunk_l2 = chunksize[min_l2//3]
best_kind_l2 = kind[min_l2%3]

print(best_kind_l1,",",best_chunk_l1)
print(best_kind_l2,",",best_chunk_l2)
#time vs chunksize
plt.figure()
plt.plot(chunksize, avg_time_loop1[:,0], '-*', label='Static')
plt.plot(chunksize, avg_time_loop1[:,1], '-*', label='Dynamic')
plt.plot(chunksize, avg_time_loop1[:,2], '-*', label='Guided')
plt.xlabel('Chunksize')
plt.ylabel('Time (s)')
# plt.legend(loc=2)
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'schedule_results_' + str(reps) + '_loop1' + '.eps', format='eps', dpi=1000)
plt.close()

#time vs chunksize
plt.figure()
plt.plot(chunksize, avg_time_loop2[:,0], '-*', label='Static')
plt.plot(chunksize, avg_time_loop2[:,1], '-*', label='Dynamic')
plt.plot(chunksize, avg_time_loop2[:,2], '-*', label='Guided')
plt.xlabel('Chunksize')
plt.ylabel('Time (s)')
# plt.legend(loc=2)
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'schedule_results_' + str(reps) + '_loop2' + '.eps', format='eps', dpi=1000)
plt.close()
