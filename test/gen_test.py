"""
Use this file to generate MNIST test set.
"""
import tensorflow as tf
import numpy as np
import sys

path = sys.argv[1]

mnist = tf.keras.datasets.mnist

(x_train, y_train), (x_test, y_test) = mnist.load_data()

for i in range(len(x_test)):
    filename = path + "x_test_" + str(i).zfill(5)
    x_test[i].flatten(order='C').astype('uint8').tofile(filename)
