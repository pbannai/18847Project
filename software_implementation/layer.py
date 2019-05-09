import math
import numpy as np
import matplotlib.pyplot as plt
import csv
import random
class Layer():
	def __init__(self, layer_id, prev_layer, num_images, wmax, num_neurons, num_spikes, random_gen, mag_tiebreak):  
		self.layer_id = layer_id
		self.prev_layer = prev_layer
		self.N,_,_ = self.prev_layer.raw_data.shape
		self.no_spike = -1
		self.inhibited = np.zeros(num_spikes)
		self.weights = np.zeros([num_neurons, num_spikes]) #assuming 1 neuron per receptive field
		self.wmax = wmax
		self.wmin = 0
		#randomize the weights
		for i in range(0, num_neurons):
			for j in range(0, num_spikes):
				if(random_gen != 0):
					self.weights[i, j] = math.floor(random.random() * (self.wmax - 4) + 4)
				else:
					self.weights[i, j] = math.floor(0)
		self.excitation = np.zeros(num_neurons)
		self.on_center = self.prev_layer.on_center_spikes
		self.off_center = self.prev_layer.off_center_spikes
		self.winning_neuron = np.zeros([num_images, 2])
		self.winning_neuron -= 1
		self.num_images = num_images
		self.num_neurons = num_neurons
		self.num_spikes = num_spikes
		self.purity_cumulative = 0.0
		self.coverage_cumulative = 0.0
		self.num_runs = 0.0
		self.random_gen = random_gen
		self.mag_tiebreak = mag_tiebreak
	def reset(self): 
		# Reset the network, clearing out any accumulator variables, etc
		#due to how my class is setup, reset is currently useless
		#randomize the weights
		for i in range(0, self.num_neurons):
			for j in range(0, self.num_spikes):
				if(self.random_gen != 0):
					self.weights[i, j] = math.floor(random.random() * (self.wmax - 4) + 4)
				else:
					self.weights[i, j] = math.floor(0)

		return
		
	def reset_stats(self):
		self.purity_cumulative = 0.0
		self.coverage_cumulative = 0.0
		self.num_runs = 0.0
		return
		
	def process_image(self, image_low, image_high,  rmax, threshold, receptive_field, receptive_field_size, training):
		self.winning_neuron = np.zeros([self.num_images, 2])
		self.winning_neuron -= 1
		LISTOFVALUES = list(range(image_low, image_high))
		random.shuffle(LISTOFVALUES)
		for x in range(image_low, image_high):
			if(self.prev_layer.ffi_stats[x] <= rmax):
				if(training > 0):
					image = LISTOFVALUES[x - image_low]
				else:
					image = x
				#calculate feed forward inhibition
				self.excitation = np.zeros(self.num_neurons)
				self.excitation -= 1
				self.inhibited = np.zeros(self.num_spikes)
				response = np.zeros([self.num_neurons, 8]) #temporal response at times 0-7
				for loopvar in range(receptive_field_size * receptive_field_size):
					i = receptive_field[0] + math.floor(loopvar / receptive_field_size)
					j = receptive_field[1] + loopvar % receptive_field_size
					if(i >= 0 and i <28 and j >=0 and j <28):
						mag_index = -1
						time_index = -1
						if(self.prev_layer.on_center_spikes[image, i, j] > -1 and self.prev_layer.on_center_spikes[image, i, j] < 7):
							self.inhibited[2 * loopvar] = self.prev_layer.on_center_spikes[image, i, j]
							self.inhibited[2 * loopvar+1] = -1

							mag_index = 2 * loopvar
							time_index = math.floor(self.inhibited[2 * loopvar ])
						elif(self.prev_layer.off_center_spikes[image, i, j] > -1 and self.prev_layer.off_center_spikes[image, i, j] < 7):
							self.inhibited[2 * loopvar+1] = self.prev_layer.off_center_spikes[image, i, j]
							self.inhibited[2 * loopvar] = -1
							mag_index = 2 * loopvar + 1
							time_index = math.floor(self.inhibited[2 * loopvar + 1])
						else:
							self.inhibited[2 * loopvar] = -1
							self.inhibited[2 * loopvar+1] = -1

						if(time_index > -1 and mag_index > -1):							
							for neuron in range(self.num_neurons):
									response[neuron, time_index:len(response[neuron])-1] += self.weights[neuron, mag_index]


				#lateral inhibition
				winning_time = -1
				self.winning_neuron[image, 0] = -1
				self.winning_neuron[image, 1] = -1
				for i in range(self.num_neurons):
					for j in range(8):
						if(response[i, j] >= threshold and self.excitation[i] < 0):
							self.excitation[i] = j
					if(self.excitation[i] > -1 and (self.excitation[i] <= winning_time or winning_time <0 or self.winning_neuron[image, 0] < 0)):
						winning_time = math.floor(self.excitation[i])
						self.winning_neuron[image, 0] = i

				self.winning_neuron[image, 1] = winning_time
				
				#training
				if(training > 0):
				
					for i in range(self.num_neurons):
						#this neuron had its output spike and won lateral inhibition
						if(math.floor(self.winning_neuron[image, 0]) == math.floor(i)):
							#check inputs
							for j in range(self.num_spikes):
								#input spike
								if(self.inhibited[j] > -1):
									self.weights[i, j] = self.wmax
								#no input spike
								else:
									self.weights[i, j] = 0
						#this neuron had an output spike but was inhibited
						elif(self.excitation[i] > -1):
							for j in range(self.num_spikes):
								#input spike
								if(self.inhibited[j]  > -1): 
									self.weights[i, j] = 0
								
						#no pre-inhibition neuron spike	
						else:
							for j in range(self.num_spikes):
								#input spike and can increment
								if(self.inhibited[j] > -1 and self.weights[i, j] < self.wmax):
									self.weights[i, j] = self.weights[i, j] + 1

									
		return


	def write_weights(self, path): 
		with open(path, "w") as output:
			writer = csv.writer(output, lineterminator='\n')
			for i in range(self.num_neurons):
				weights  = []
				weights.append(self.weights[i])
				writer.writerow(weights)

			
		return
	def num_wmax(self, neuron):
		res = 0
		for i in range(self.num_spikes):
			if(self.weights[neuron, i] == wmax):
				res += 1
		return res
	def stdp_update_rule(self, prev_layer_spiketime, image):
		#
		# Calculate the weight change here
		#
		#no output spike
		for i in range(self.num_neurons):
			#this neuron had its output spike and won lateral inhibition
			if(math.floor(self.winning_neuron[image, 0]) == math.floor(i)):
				#check inputs
				for j in range(self.num_spikes):
					#input spike
					if(self.inhibited[j] > -1):
						self.weights[i, j] = self.wmax
					#no input spike
					else:
						self.weights[i, j] = 0
			#this neuron had an output spike but was inhibited
			elif(self.excitation[i] > -1):
				#check inputs
				for j in range(self.num_spikes):
					#input spike
					if(self.inhibited[j]  > -1):
						self.weights[i, j] = 0
					#no input spike
					else:
						self.weights[i, j] = self.weights[i, j]		
			#no pre-inhibition neuron spike	
			else:
				#check inputs
				for j in range(self.num_spikes):
					#input spike and can increment
					if(self.inhibited[j] > -1 and self.weights[i, j] < self.wmax):
						self.weights[i, j] = self.weights[i, j] + 1
					#no input spike
					else:
						self.weights[i, j] = self.weights[i, j]		
		return

	def calculate_metrics(self, path, image_low, image_high): 
		# create a file with: image_number, spike_position, spike_time
		numspikes = np.zeros([self.num_neurons, 10]) #number of times each neuron spikes
		sum_all = 0
		sum_max = 0
		for i in range(image_low, image_high):
			neuron = math.floor(self.winning_neuron[i, 0])
			target = math.floor(self.prev_layer.target[i])
			if(neuron > self.no_spike):
				numspikes[neuron, target] = numspikes[neuron, target] + 1
		with open(path, "w") as output:
			writer = csv.writer(output, lineterminator='\n')
			writer.writerow(["", "MNIST Data Labels"])
			writer.writerow(["Neuron", "0", "1","2","3","4","5","6","7","8","9", "Max", "Totals"])
			for i in range(self.num_neurons):
				sum = 0
				for j in range(10):
					sum = sum + numspikes[i, j]
				sum_all = sum_all + sum
				sum_max = sum_max + np.amax(numspikes[i])
				writer.writerow(["%d" % i, "%d" % numspikes[i, 0], "%d" % numspikes[i, 1], "%d" % numspikes[i, 2],
								 "%d" % numspikes[i, 3], "%d" % numspikes[i, 4], "%d" % numspikes[i, 5],
								  "%d" % numspikes[i, 6], "%d" % numspikes[i, 7], "%d" % numspikes[i, 8],
								   "%d" % numspikes[i, 9], "%d" % np.amax(numspikes[i]), "%d" % sum])
			purity = 0
			if(math.floor(sum_all) > 0):
				purity = math.floor(sum_max) / math.floor(sum_all)
			coverage = sum_all / (image_high - image_low)
			writer.writerow(["Sum Max:", "%d" % sum_max])
			writer.writerow(["Sum All:", "%d" % sum_all])			
			writer.writerow(["Purity:", "{:1.5f}".format(purity)])
			print(["Purity:", "{:1.5f}".format(purity)])
			writer.writerow(["Coverage:", "{:1.5f}".format(coverage)])
			print(["Coverage:", "{:1.5f}".format(coverage)])
			self.purity_cumulative += purity
			self.coverage_cumulative += coverage
			self.num_runs += 1
		return
		
	def print_average_stats(self):
		purity = self.purity_cumulative / self.num_runs

		coverage = self.coverage_cumulative / self.num_runs
		print("Average Purity: %1.5f" % purity);
		print("Average Coverage: %1.5f" % coverage);
		
		
		return