import numpy as np
import matplotlib.pyplot as plt
import argparse

print("Running plot_best_schedule script..")

parser = argparse.ArgumentParser(description='Read number of repetitions')
parser.add_argument('-r', dest='reps', type=int, help='Enter the number of the repetitions performed')
args = parser.parse_args()

reps = args.reps

maindir = 'res/best_schedule/'
filename = 'best_schedule_results.csv'
file = maindir + filename

print("Reading input data from " + file + "..")

data = np.genfromtxt(file, delimiter=',', skip_header=1)

print("Input completed..")

kind = ['static', 'dynamic', 'guided']
threads=[1, 2, 4, 6, 8, 16]
avg_time = np.zeros((2,len(threads)))
speed_up = np.zeros((2,len(threads)))

for num, thread in enumerate(threads):
	# read number of threads column
	blocks = data[:,0]
	# get data that only match the thread number
	thread_data = data[blocks==thread,:]
	# take the average time for each thread number
	avg_time[0,num] = np.mean(thread_data[:,3])
	avg_time[1,num] = np.mean(thread_data[:,5])

speed_up[0,:] = avg_time[0,0] / avg_time[0,:]
speed_up[1,:] = avg_time[1,0] / avg_time[1,:]

#speed up vs number of threads
plt.figure()
plt.plot(threads, speed_up[0,:], '-*', label='Loop 1')
plt.plot(threads, speed_up[1,:], '-*', label='Loop 2')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up (times)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'best_schedule_results.eps', format='eps', dpi=1000)
plt.close()

print("Speed up for plot for loop1 and loop2 completed..")
print("plot_best_schedule script completed..")
