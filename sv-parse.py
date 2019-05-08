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

readpath = "testing_results.csv"
writepath = "sv_performance_metrics.csv"
num_neurons = 16
image_low = 60000
image_high = 70000
num_images = image_high - image_low
input_winner = np.zeros(num_images)
numspikes = np.zeros([num_neurons, 10]) #number of times each neuron spikes
sum_all = 0
sum_max = 0
i = 0
with open(readpath, "r") as csvfile:
	readCSV = csv.reader(csvfile, delimiter=' ')
	for row in readCSV:
		input_winner[i] = int(row[0])
		i += 1
for i in range(image_low, image_high):
	neuron = math.floor(input_winner[i-image_low])
	target = math.floor(mnist.target[i])
	if(neuron > -1 and neuron < num_neurons):
		numspikes[neuron, target] = numspikes[neuron, target] + 1
with open(writepath, "w") as output:
	writer = csv.writer(output, lineterminator='\n')
	writer.writerow(["", "MNIST Data Labels"])
	writer.writerow(["Neuron", "0", "1","2","3","4","5","6","7","8","9", "Max", "Totals"])
	for i in range(num_neurons):
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
