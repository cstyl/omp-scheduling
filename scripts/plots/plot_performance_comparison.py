import numpy as np
import matplotlib.pyplot as plt

print("Running plot_performance_comparison script..")

maindir = 'res/comparison/'
filename = 'results_comparison.csv'
file = maindir + filename

print("Reading input data from " + file + "..")

data = np.genfromtxt(file, delimiter=',', skip_header=1)

print("Input completed..")

# need to get data for each version
versions = ["Best_sch", "Best_loop2", "Critical", "Locks"]
threads = [1, 2, 4, 6, 8, 12, 16]
loops = ["loop1", "loop2"]

avg_time = np.zeros((len(versions),len(threads), len(loops)))

for num,version in enumerate(versions):
	# get data for each version
	blocks = data[:,0]
	version_data = data[blocks==num,:]

	# get data per thread number and average their timings
	for num_t, thread_num in enumerate(threads):
		blocks = version_data[:,1]
		thread_data = version_data[blocks==thread_num,:]

		avg_time[num,num_t,0] = np.mean(thread_data[:,4])
		avg_time[num,num_t,1] = np.mean(thread_data[:,6])


for loop_idx, loop_name in enumerate(loops):
	plt.figure()
	plt.plot(threads, avg_time[0,:,loop_idx], '-*', label=versions[0])
	plt.plot(threads, avg_time[1,:,loop_idx], '-o', label=versions[1])
	plt.plot(threads, avg_time[2,:,loop_idx], '-^', label=versions[2])
	plt.plot(threads, avg_time[3,:,loop_idx], '-+', label=versions[3])
	plt.xlabel('Number of Threads')
	plt.ylabel('Time (s)')
	plt.legend()
	plt.grid(True)
	plt.savefig(maindir + 'execution_time_' + loop_name + '.eps', format='eps', dpi=1000)
	plt.close()

	print("Execution time plot for " + loop_name + " completed..")

	plt.figure()
	plt.plot(threads, avg_time[0,0,loop_idx]/avg_time[0,:,loop_idx], '-*', label=versions[0])
	plt.plot(threads, avg_time[1,0,loop_idx]/avg_time[1,:,loop_idx], '-o', label=versions[1])
	plt.plot(threads, avg_time[2,0,loop_idx]/avg_time[2,:,loop_idx], '-^', label=versions[2])
	plt.plot(threads, avg_time[3,0,loop_idx]/avg_time[3,:,loop_idx], '-+', label=versions[3])
	plt.plot(threads, threads, '--')
	plt.xlabel('Number of Threads')
	plt.ylabel('Speed Up (times)')
	plt.ylim([0,20])
	plt.legend()
	plt.grid(True)
	plt.savefig(maindir + 'speed_up_' + loop_name + '.eps', format='eps', dpi=1000)
	plt.close()

	print("Speed up for plot " + loop_name + " completed..")

	plt.figure()
	plt.plot(threads, (avg_time[0,0,loop_idx]/avg_time[0,:,loop_idx]) / threads * 100, '-*', label=versions[0])
	plt.plot(threads, (avg_time[1,0,loop_idx]/avg_time[1,:,loop_idx]) / threads * 100, '-o', label=versions[1])
	plt.plot(threads, (avg_time[2,0,loop_idx]/avg_time[2,:,loop_idx]) / threads * 100, '-^', label=versions[2])
	plt.plot(threads, (avg_time[3,0,loop_idx]/avg_time[3,:,loop_idx]) / threads * 100, '-+', label=versions[3])
	plt.plot(threads, [100, 100, 100, 100, 100, 100, 100], '--')
	plt.xlabel('Number of Threads')
	plt.ylabel('Efficiency (%)')
	plt.ylim([40,110])
	plt.legend()
	plt.grid(True)
	plt.savefig(maindir + 'efficiency_' + loop_name + '.eps', format='eps', dpi=1000)
	plt.close()

	print("Efficiency plot for " + loop_name + " completed..")

print("plot_performance_comparison script completed..")
