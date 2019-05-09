import math
import numpy as np
from scipy import signal
import csv
import random
import matplotlib.pyplot as plt

#Layer may not be both the first layer and an output layer
class FirstLayer: 
	def __init__ (self, layer_id, training_raw_data, training_target):
		self.layer_id = layer_id
		self.raw_data = training_raw_data
		self.target = training_target
		self.on_center = np.zeros(self.raw_data.shape)
		self.off_center = np.zeros(self.raw_data.shape)
		self.on_center_spikes = np.zeros(self.raw_data.shape)
		self.off_center_spikes = np.zeros(self.raw_data.shape)
		self.ffi_stats = np.zeros(70000)
	def preprocess_all (self, num_images, threshold ) :
	


		return

						
	def preprocess (self, num_images, receptive_field, receptive_field_size, threshold, num_bits=3 ):
		self.ffi_stats = np.zeros(70000)
		for i in range (0, num_images): #image
			for field in range(receptive_field_size * receptive_field_size):
				j = math.floor(receptive_field[0] + field/receptive_field_size)
				k = math.floor(receptive_field[1] + field%receptive_field_size)
			#for j in range(receptive_field[0], receptive_field[0] + receptive_field_size): #rows
			#	for k in range (receptive_field[1], receptive_field[1] + receptive_field_size): #columns
				average = 0
				count = 0
				for l in range (-1, 2): #row offset
					for m in range(-1, 2): #column offset
						if (j + l >= 0) and (j + l < 28) and (k + m >= 0) and (k + m < 28) and ((l != 0) or (m!=0)):
							count += 1
							average += self.raw_data[i, j+l, k+m]
				if(count != 0):
					average = math.floor(average / count)
				if(j >= 0 and j < 28 and k >= 0 and k < 28):
					if self.raw_data[i, j, k] > average and count > 0:
						#on center cell spike
						#on-center-cell = difference
						#off-center-cell = no_spike
						self.ffi_stats[i] += 1
						self.on_center[i, j, k] = abs(self.raw_data[i, j, k] - average)
						self.off_center[i, j, k] = -9999
												
					elif self.raw_data[i, j, k] < average and count > 0:
						#off center cell spike
						#off-center-cell = -1 * difference
						#on-center-cell = no_spike
						self.ffi_stats[i] += 1
						self.on_center[i, j, k] = -9999
						self.off_center[i, j, k] = abs(average - self.raw_data[i, j, k])

					else:
						#on-center-cell = no_spike
						#off-center-cell = no_spike
						self.on_center[i, j, k] = -9999
						self.off_center[i, j, k] = -9999		
			max_on = np.amax(self.on_center[i])
			max_off = np.amax(self.off_center[i])

	#	for i in range (0, num_images): #image
			if(max_on > 0):
				self.on_center_spikes[i] = ((max_on - self.on_center[i]) * 7) / max_on
			else:
				self.on_center_spikes[i] -= 1
				
			if(max_off > 0):
				self.off_center_spikes[i] = ((max_off - self.off_center[i]) * 7) / max_off
			else:
				self.off_center_spikes[i] -= 1
				

			
			
		return 

	


	
		
	def write_spiketimes(self, path, receptive_field, receptive_field_size, num_images):
		l = list(range(70000))
		random.shuffle(l)
		#Assuming res is a list of lists
		with open(path, "w") as output:
			writer = csv.writer(output, lineterminator='\n')
			for image in range(num_images):


				for i in range(receptive_field_size * receptive_field_size):
					
					spiketimes = []
					spikeval = math.floor(self.on_center_spikes[l[image], math.floor(receptive_field[0] + i/receptive_field_size), math.floor(receptive_field[1] + i%receptive_field_size)])

					spiketimes.append(spikeval)
					writer.writerows([spiketimes])
					spiketimes = []
					spikeval = math.floor(self.off_center_spikes[l[image], math.floor(receptive_field[0] + i/receptive_field_size), math.floor(receptive_field[1] + i%receptive_field_size)])

					spiketimes.append(spikeval)
					writer.writerows([spiketimes])
					

			
		return
		
	def write_images(self, num_images):
		for i in range(num_images):
			image = self.raw_data[i]
			plt.imsave(("images/training_%d.png" % i), image, cmap="gray")
	
		return
