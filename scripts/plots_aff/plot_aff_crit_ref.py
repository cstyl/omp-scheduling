import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='Read number of repetitions and working directory')
parser.add_argument('-r', dest='reps', type=int, help='Enter the number of the repetitions performed')
parser.add_argument('-d', dest='dir', type=str, help='Enter the working directory')

args = parser.parse_args()

reps = args.reps
maindir = args.dir

filename_aff = 'results_affinity.csv'
file_aff = maindir + filename_aff
filename_ref = 'results_ref.csv'
file_ref = maindir + filename_ref

data_aff = np.genfromtxt(file_aff, delimiter=',', skip_header=1)
data_ref = np.genfromtxt(file_ref, delimiter=',', skip_header=1)

# need to get data for each version
versions = ["ref", "aff"]
threads = [1, 2, 4, 6, 8, 16, 32, 64]
loops = [1, 2]

avg_time = np.zeros((len(versions),len(threads), len(loops)))

for num,version in enumerate(versions):
	# get data for each version
	if(version=='ref'):
		blocks = data_ref[:,0]
		version = 0
		version_data = data_ref[blocks==0,:]
	else if(version=='aff'):
		blocks = data_aff[:,0]
		version = 1
		version_data = data_aff[blocks==4,:]

	# get data per thread number and average their timings
	for num_t, thread_num in enumerate(threads):
		blocks = version_data[:,1]
		thread_data = version_data[blocks==thread_num,:]

		avg_time[version,num_t,0] = np.mean(thread_data[:,4])
		avg_time[version,num_t,1] = np.mean(thread_data[:,6])

fig, ax = plt.subplots()
lims = [
    np.min([ax.get_xlim(), ax.get_ylim()]),  # min of both axes
    np.max([ax.get_xlim(), ax.get_ylim()]),  # max of both axes
]
ax.plot(lims, lims, 'k-', label='ideal')
ax.plot(threads, avg_time[0,:,0]/avg_time[1,:,0], '-*', label='loop1')
ax.plot(threads, avg_time[0,:,1]avg_time[1,:,1], '-*', label='loop2')
ax.set_xlabel('Number of Threads')
ax.set_ylabel('Speed-Up (times)')
ax.legend()
ax.grid(True)
fig.savefig(maindir + 'ref_vs_aff.eps', format='eps', dpi=1000)
fig.close()