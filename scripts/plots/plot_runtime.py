import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='Read number of repetitions and working directory')
parser.add_argument('-r', dest='reps', type=int, help='Enter the number of the repetitions performed')
args = parser.parse_args()

reps = args.reps

maindir = 'res/runtime/'
filename = 'runtime_results.csv'
file = maindir + filename

data = np.genfromtxt(file, delimiter=',', skip_header=1)

kind = ['static', 'dynamic', 'guided']
chunksize=[1, 2, 4, 8, 16, 32, 64]
avg_time_loop1 = np.zeros((len(chunksize),len(kind)))
avg_time_loop2 = np.zeros((len(chunksize),len(kind)))

for num, label in enumerate(kind):
	# read kind type column
	blocks = data[:,1]
	# get data that only match the current kind type
	kind_data = data[blocks==num+1,:]

	for idx in len(chunksize):
		# get data that only match the current chunksize
		blocks = kind_data[:,2]
		chunk_data = kind_data[blocks==chunksize[idx],:]
		# take the average time for each chunksize
		avg_time_loop1[idx,num] = np.mean(chunk_data[:,4])
		avg_time_loop2[idx,num] = np.mean(chunk_data[:,6])

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
plt.savefig(maindir + 'runtime_loop1.eps', format='eps', dpi=1000)
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
plt.savefig(maindir + 'runtime_loop2.eps', format='eps', dpi=1000)
plt.close()
