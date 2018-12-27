import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='Read number of repetitions and working directory')
parser.add_argument('-r', dest='reps', type=int, help='Enter the number of the repetitions performed')
parser.add_argument('-d', dest='dir', type=str, help='Enter the working directory')

args = parser.parse_args()

reps = args.reps
maindir = args.dir

filename = 'best_loop2_results.csv'
file = maindir + filename

data = np.genfromtxt(file, delimiter=',', skip_header=1)

kind_label=[1, 2, 3] # corresponds to static, dynamic and guided
kind = ['static', 'dynamic', 'guided']
chunksize=[1, 2, 4, 8, 16, 32, 64]
threads=[1, 2, 4, 6, 8, 16]
avg_time_loop2 = np.zeros((7,6))
# avg_time_loop1 = np.zeros((7,6))

for numc, size in enumerate(chunksize):
	# read kind type column
	blocks = data[:,0]
	# get data that only match the current chunksize
	kind_data = data[blocks==size,:]

	for numt, thread in enumerate(threads):
		read number of threads column
		blocks = data[:,1]
		thread_data = data[blocks==thread,:]
		avg_time_loop2[numc,numt] = np.mean(thread_data[:,5])
		# avg_time_loop1[numc,numt] = np.mean(thread_data[:,3])

for numc in enumerate(chunksize):
	speed_up_loop2[numc,:] = avg_time_loop2[numc,0] / avg_time_loop2[numc,:]
	# speed_up_loop1[numc,:] = avg_time_loop2[numc,0] / avg_time_loop2[numc,:]

#speed up vs number of threads
plt.figure()
plt.plot(threads, speed_up_loop2[0,:], '-*', label='dynamic,1')
plt.plot(threads, speed_up_loop2[1,:], '-*', label='dynamic,2')
plt.plot(threads, speed_up_loop2[2,:], '-*', label='dynamic,4')
plt.plot(threads, speed_up_loop2[3,:], '-*', label='dynamic,8')
plt.plot(threads, speed_up_loop2[4,:], '-*', label='dynamic,16')
plt.plot(threads, speed_up_loop2[5,:], '-*', label='dynamic,32')
plt.plot(threads, speed_up_loop2[6,:], '-*', label='dynamic,64')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up')
# plt.legend(loc=2)
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'best_loop2_results.eps', format='eps', dpi=1000)
plt.close()

# #speed up vs number of threads
# plt.figure()
# plt.plot(threads, speed_up_loop1[0,:], '-*', label='guided,1')
# plt.plot(threads, speed_up_loop1[1,:], '-*', label='guided,2')
# plt.plot(threads, speed_up_loop1[2,:], '-*', label='guided,4')
# plt.plot(threads, speed_up_loop1[3,:], '-*', label='guided,8')
# plt.plot(threads, speed_up_loop1[4,:], '-*', label='guided,16')
# plt.plot(threads, speed_up_loop1[5,:], '-*', label='guided,32')
# plt.plot(threads, speed_up_loop1[6,:], '-*', label='guided,64')
# plt.xlabel('Number of Threads')
# plt.ylabel('Speed Up')
# # plt.legend(loc=2)
# plt.legend()
# plt.grid(True)
# plt.savefig(maindir + 'best_loop1_results.eps', format='eps', dpi=1000)
# plt.close()
