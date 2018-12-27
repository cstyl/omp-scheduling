import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser(description='Read number of repetitions and working directory')
parser.add_argument('-r', dest='reps', type=int, help='Enter the number of the repetitions performed')
parser.add_argument('-d', dest='dir', type=str, help='Enter the working directory')

args = parser.parse_args()

reps = args.reps
maindir = args.dir

filename = 'results.csv'
file = maindir + filename

data = np.genfromtxt(file, delimiter=',', skip_header=1)

# need to get data for each version
versions = ["scheduling", "affinity_0", "affinity_1", "affinity_2", "affinity_3"]
threads = [1, 2, 4, 6, 8, 16, 32, 64]
loops = [1, 2]

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


plt.figure()
plt.plot(threads, avg_time[1,:,0], '-*', label='Static,Critical')
plt.plot(threads, avg_time[2,:,0], '-*', label='Static,Lock')
plt.xlabel('Number of Threads')
plt.ylabel('Time (s)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'static_step_loop1.eps', format='eps', dpi=1000)
plt.close()

plt.figure()
plt.plot(threads, avg_time[1,:,1], '-*', label='Static,Critical')
plt.plot(threads, avg_time[2,:,1], '-*', label='Static,Lock')
plt.xlabel('Number of Threads')
plt.ylabel('Time (s)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'static_step_loop2.eps', format='eps', dpi=1000)
plt.close()

plt.figure()
plt.plot(threads, avg_time[1,:,0]/avg_time[2,:,0], '-*', label='Loop1')
plt.plot(threads, avg_time[1,:,1]/avg_time[2,:,1], '-*', label='Loop2')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up (times)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'static_step_speed_up.eps', format='eps', dpi=1000)
plt.close()




plt.figure()
plt.plot(threads, avg_time[3,:,0], '-*', label='Variable,Critical')
plt.plot(threads, avg_time[4,:,0], '-*', label='Variable,Lock')
plt.xlabel('Number of Threads')
plt.ylabel('Time (s)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'variable_step_loop1.eps', format='eps', dpi=1000)
plt.close()

plt.figure()
plt.plot(threads, avg_time[3,:,1], '-*', label='Variable,Critical')
plt.plot(threads, avg_time[4,:,1], '-*', label='Variable,Lock')
plt.xlabel('Number of Threads')
plt.ylabel('Time (s)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'variable_step_loop2.eps', format='eps', dpi=1000)
plt.close()

plt.figure()
plt.plot(threads, avg_time[3,:,0]/avg_time[4,:,0], '-*', label='Loop1')
plt.plot(threads, avg_time[3,:,1]/avg_time[4,:,1], '-*', label='Loop2')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up (times)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'variable_step_speed_up.eps', format='eps', dpi=1000)
plt.close()




# compare lock implementations
plt.figure()
plt.plot(threads, avg_time[4,:,0]/avg_time[2,:,0], '-*', label='Loop1')
plt.plot(threads, avg_time[4,:,1]/avg_time[2,:,1], '-*', label='Loop2')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up (times)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'speed_up_affinity_locks.eps', format='eps', dpi=1000)
plt.close()


# compare best implementations with dynamic
plt.figure()
plt.plot(threads, avg_time[2,:,0], '-*', label='Static,Lock')
plt.plot(threads, avg_time[4,:,0], '-*', label='Variable,Lock')
plt.plot(threads, avg_time[0,:,0], '-*', label='Dynamic')
plt.xlabel('Number of Threads')
plt.ylabel('Time (s)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'comp_loop1.eps', format='eps', dpi=1000)
plt.close()

plt.figure()
plt.plot(threads, avg_time[2,:,1], '-*', label='Static,Lock')
plt.plot(threads, avg_time[4,:,1], '-*', label='Variable,Lock')
plt.plot(threads, avg_time[0,:,1], '-*', label='Dynamic')
plt.xlabel('Number of Threads')
plt.ylabel('Time (s)')
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'comp_loop2.eps', format='eps', dpi=1000)
plt.close()


plt.figure()
plt.plot(threads, avg_time[0,:,0]/avg_time[2,:,0], '-*', label='Static,Lock,Loop1')
plt.plot(threads, avg_time[0,:,0]/avg_time[4,:,0], '-*', label='Variable,Lock,Loop1')
plt.plot(threads, avg_time[0,:,1]/avg_time[2,:,1], '-*', label='Static,Lock,Loop2')
plt.plot(threads, avg_time[0,:,1]/avg_time[4,:,1], '-*', label='Variable,Lock,Loop2')
plt.xlabel('Number of Threads')
plt.ylabel('Speed Up (times)')
plt.ylim([0,30])
plt.legend()
plt.grid(True)
plt.savefig(maindir + 'speed_up_best.eps', format='eps', dpi=1000)
plt.close()

