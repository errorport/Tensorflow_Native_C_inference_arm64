'''
Intuition: https://github.com/harmanpreet93/keras-model-to-cpp
'''

import os
os.environ['TF_CPP_MIN_LOG_LEVEL']='3'
import numpy as np
np.random.seed(1337)
import keras
from keras.models import Sequential
from tensorflow.keras.models import load_model, model_from_json
import json
import argparse

np.set_printoptions(threshold=np.inf)
parser = argparse.ArgumentParser(
    description='Convert TF model to C.')

parser.add_argument('-a', '--architecture', help="JSON with model architecture", required=True)
parser.add_argument('-w', '--weights', help="Model weights in HDF5 format", required=True)
parser.add_argument('-o', '--output', help="Ouput file name", required=True)
parser.add_argument('-v', '--verbose', help="Verbose", required=False)
args = parser.parse_args()

print('Read architecture from', args.architecture)
print('Read weights from', args.weights)
print('Writing to', args.output)

arch = open(args.architecture).read()
model = model_from_json(arch)
model.load_weights(args.weights)
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
arch = json.loads(arch)

with open(args.output+'.h', 'w') as fout:    
    fout.write('// This methodology is originated from https://github.com/harmanpreet93/keras-model-to-cpp.\n\n')
    fout.write('#ifndef MODEL__H\n#define MODEL__H\n\n')
    fout.write('#include <stdint.h>\n')
    fout.write('#include <math.h>\n')

    print('layers ' + str(len(model.layers)) + '\n')
    fout.write('#define LAYERS ' + str(len(model.layers)) + '\n')
    features = model.get_weights()[0].shape[0]
    fout.write('#define FEATURES ' + str(features) + '\n')
    fout.write('uint16_t layer_sizes[LAYERS][2];\n\n')
    fout.write('float_t* thetaMap[LAYERS];\n')

    fout.write('#endif /* MODEL__H */\n')


with open(args.output+'.c', 'w') as fout:

    layers = []
    print('arch_config:', arch["config"]['layers'])
    for ind, l in enumerate(arch["config"]['layers']):
        if args.verbose:
            print(ind, l)
        print('layer ' + str(ind) + ' ' + l['class_name'] + '\n')
        fout.write('// LAYER_' + str(ind) + ' ' + l['class_name'] + ' activation dimensions:\n')

        if args.verbose:
            print(str(ind), l['class_name'])
        layers += [l['class_name']]
        if l['class_name'] == 'Flatten':
            fout.write('// Input layer has no activations.')
            fout.write('layer_sizes['+ str(ind)  +'] = [0, 0];\n')
        if l['class_name'] == 'Dense':
            W = model.layers[ind].get_weights()[0]
            if args.verbose:
                print(W.shape)
            print('Layer ' + str(int) + ' activations:', str(W.shape[0]) + ', ' + str(W.shape[1]) + '\n')
            fout.write('layer_sizes['+ str(ind) +'][0] = '\
                + str(W.shape[0]) + ';\n'\
                + 'layer_sizes[' + str(ind) + '][1] = '\
                + str(W.shape[1]) +';\n')
            fout.write('float_t theta_'+ str(ind)  +'[' + str(W.shape[0]) + ', ' + str(W.shape[1]) +'];\n')


    theta_index = 0
    for ind, l in enumerate(arch["config"]['layers']):
        if l['class_name'] == 'Dense':
            W = model.layers[ind].get_weights()[0]
            for w in W:
                fout.write('theta_' + str(ind) + '['+ str(theta_index) +'] = ')
                fout.write('[')
                for w_i in w:
                    fout.write(str(w_i)+', ')
                fout.write('];\n')
                theta_index += 1
            #fout.write('// Weights of layer '+ str(ind) +'\n')
            #fout.write(str(model.layers[ind].get_weights()[1]).replace(' ',',') + '\n')

