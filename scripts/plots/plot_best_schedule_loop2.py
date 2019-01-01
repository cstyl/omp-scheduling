import numpy as np
import matplotlib.pyplot as plt

print("Running plot_best_schedule_loop2 script..")

maindir = 'res/best_loop2/'
filename = 'best_loop2_results.csv'
file = maindir + filename

print("Reading input data from " + file + "..")

data = np.genfromtxt(file, delimiter=',', skip_header=1)

print("Input completed..")

kind = ['static', 'dynamic', 'guided']
chunksize=[1, 2, 4, 8, 16, 32, 64]
threads=[1, 2, 4, 6, 8, 16]
avg_time_loop2 = np.zeros((len(chunksize),len(threads)))
speed_up_loop2 = np.zeros((len(chunksize),len(threads)))

for numc, size in enumerate(chunksize):
	# read kind type column
	blocks = data[:,0]
	# get data that only match the current chunksize
	kind_data = data[blocks==size,:]
	for numt, thread in enumerate(threads):
		# read number of threads column
		blocks = kind_data[:,1]
		thread_data = kind_data[blocks==thread,:]

		avg_time_loop2[numc,numt] = np.mean(thread_data[:,6])

for numc, chunk in enumerate(chunksize):
	speed_up_loop2[numc,:] = avg_time_loop2[numc,0] / avg_time_loop2[numc,:]

#speed up vs number of threads
plt.figure()
plt.plot(threads, speed_up_loop2[0,:], '-*', label='dynamic,1')
plt.plot(threads, speed_up_loop2[1,:], '-+', label='dynamic,2')
plt.plot(threads, speed_up_loop2[2,:], '-o', label='dynamic,4')
plt.plot(threads, speed_up_loop2[3,:], '-^', label='dynamic,8')
plt.plot(threads, speed_up_loop2[4,:], '-<', label='dynamic,16')
plt.plot(threads, speed_up_loop2[5,:], '->', label='dynamic,32')
plt.plot(threads, speed_up_loop2[6,:], '-.', label='dynamic,64')
plt.plot(threads, threads, '--')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up')
plt.legend(loc=2)
plt.grid(True)
plt.savefig(maindir + 'best_loop2_results.eps', format='eps', dpi=1000)
plt.close()

print("Speed up for plot loop2 completed..")

print("plot_best_schedule_loop2 script completed..")
