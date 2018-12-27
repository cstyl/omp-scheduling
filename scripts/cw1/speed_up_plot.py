import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='Read number of repetitions and working directory')
parser.add_argument('-r', dest='reps', type=int, help='Enter the number of the repetitions performed')
parser.add_argument('-d', dest='dir', type=str, help='Enter the working directory')

args = parser.parse_args()

reps = args.reps
maindir = args.dir

filename = 'best_schedule_results.csv'
file = maindir + filename

data = np.genfromtxt(file, delimiter=',', skip_header=1)

kind_label=[1, 2, 3] # corresponds to static, dynamic and guided
kind = ['static', 'dynamic', 'guided']
threads=[1, 2, 4, 6, 8, 16]
avg_time_loop1 = np.zeros((1,6))
avg_time_loop2 = np.zeros((1,6))

for num, thread in enumerate(threads):
	# read number of threads column
	blocks = data[:,0]
	# get data that only match the thread number
	thread_data = data[blocks==thread,:]
	# print(thread_data)
	# take the average time for each thread number
	avg_time_loop1[0,num] = np.mean(thread_data[:,3])
	avg_time_loop2[0,num] = np.mean(thread_data[:,5])

speed_up_loop1 = avg_time_loop1[0,0] / avg_time_loop1
speed_up_loop2 = avg_time_loop2[0,0] / avg_time_loop2

#speed up vs number of threads
plt.figure()
plt.plot(threads, speed_up_loop1[0,:], '-*', label='Loop 1')
plt.plot(threads, speed_up_loop2[0,:], '-*', label='Loop 2')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up (times)')
# plt.legend(loc=2)
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'best_schedule_results_' + str(reps) + '.eps', format='eps', dpi=1000)
plt.close()
