import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import fetch_mldata
import firstlayer as firstlayer
import layer as layer
import csv
import random
import math

mnist = fetch_mldata('MNIST original')
N, _ = mnist.data.shape

# Reshape the data to be square
mnist.square_data = mnist.data.reshape(N,28,28)

receptive_field_a = [4, 4]
receptive_field_b = [12, 12]
#custom
receptive_field_c = [0, 0]


num_trials = 1
receptive_field_size = 5
wmax = 7
num_neurons = 16
num_spikes = math.floor(receptive_field_size * receptive_field_size * 2)
neuron_learning_threshold = [60]
neuron_testing_threshold =  [60]
rmax = 25
threshold = 1
num_images = 70000
training_images = 60000


layer1 = firstlayer.FirstLayer(1, mnist.square_data, mnist.target)


#Copied from Lab 1, create filters


layer1.preprocess(70000, receptive_field_b, receptive_field_size, threshold)
#layer1.write_spiketimes("training_spikes.csv", receptive_field_b, receptive_field_size, num_images)


old_tb_zero_init = layer.Layer(2, layer1, num_images, wmax, num_neurons, num_spikes, 0, 0) 


#learn image
l = list(range(training_images))
#2nd receptive field
print("finished preprocessing")
for j in range(len(neuron_learning_threshold)):
	random.shuffle(l)
	old_tb_zero_init.process_image(0, training_images, rmax, neuron_learning_threshold[j], receptive_field_b, receptive_field_size, 1)
	old_tb_zero_init.write_weights("rf_12_12_weights_oz_%d.csv" %j)

	print("finished training")
	#find winning neurons with learned weights
	#for i in range(training_images, num_images):
	old_tb_zero_init.process_image(training_images, num_images, rmax, neuron_testing_threshold[j], receptive_field_b, receptive_field_size, 0)

		
	old_tb_zero_init.calculate_metrics("rf_12_12_neurons_oz_%d.csv" % j, training_images, num_images)
	old_tb_zero_init.reset()


	print("finished trial %d" % j)
	
print("")
print("Old tiebreak, initialize to zero:")
old_tb_zero_init.print_average_stats(); 
print("")
#print("New tiebreak, initialize to zero:")
#new_tb_zero_init.print_average_stats();
print("")
#print("Old tiebreak, initialize to random:")
#old_tb_rand_init.print_average_stats();
#print("New tiebreak, initialize to random:")
#new_tb_rand_init.print_average_stats();
#print("")



