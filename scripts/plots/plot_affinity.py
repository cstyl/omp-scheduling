import numpy as np
import matplotlib.pyplot as plt

print("Running plot_affinity script..")

maindir = 'res/affinity/'
filename = 'results_affinity.csv'
file = maindir + filename

print("Reading input data from " + file + "..")

data = np.genfromtxt(file, delimiter=',', skip_header=1)

print("Input completed..")

# need to get data for each version
versions = ["Critical", "Locks"]
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
	plt.plot(threads, avg_time[1,:,loop_idx], '-^', label=versions[1])
	plt.xlabel('Number of Threads')
	plt.ylabel('Time (s)')
	plt.legend()
	plt.grid(True)
	plt.savefig(maindir + 'execution_time_' + loop_name + '.eps', format='eps', dpi=1000)
	plt.close()

	print("Execution time plot for " + loop_name + " completed..")

plt.figure()
plt.plot(threads, avg_time[0,0,0]/avg_time[0,:,0], '-*', label=versions[0] + '_' + loops[0])
plt.plot(threads, avg_time[1,0,0]/avg_time[1,:,0], '-o', label=versions[1] + '_' + loops[0])
plt.plot(threads, avg_time[0,0,1]/avg_time[0,:,1], '-^', label=versions[0] + '_' + loops[1])
plt.plot(threads, avg_time[1,0,1]/avg_time[1,:,1], '-+', label=versions[1] + '_' + loops[1])
plt.plot(threads, threads, '--')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up (times)')
plt.ylim([0,20])
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'speed_up.eps', format='eps', dpi=1000)
plt.close()

print("Speed-up plot completed..")

plt.figure()
plt.plot(threads, (avg_time[0,0,0]/avg_time[0,:,0]) / threads * 100, '-*', label=versions[0] + '_' + loops[0])
plt.plot(threads, (avg_time[1,0,0]/avg_time[1,:,0]) / threads * 100, '-o', label=versions[1] + '_' + loops[0])
plt.plot(threads, (avg_time[0,0,1]/avg_time[0,:,1]) / threads * 100, '-^', label=versions[0] + '_' + loops[1])
plt.plot(threads, (avg_time[1,0,1]/avg_time[1,:,1]) / threads * 100, '-+', label=versions[1] + '_' + loops[1])
plt.plot(threads, [100, 100, 100, 100, 100, 100, 100], '--')
plt.xlabel('Number of Threads')
plt.ylabel('Efficiency (%)')
plt.ylim([40,110])
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'efficiency.eps', format='eps', dpi=1000)
plt.close()

print("Efficiency plot completed..")
print("plot_affinity script completed..")

