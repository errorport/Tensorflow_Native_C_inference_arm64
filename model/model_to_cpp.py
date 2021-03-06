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
print('Writing to', args.output, '[.h, .c]')

arch = open(args.architecture).read()
model = model_from_json(arch)
model.load_weights(args.weights)
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
arch = json.loads(arch)

header_str = ""
source_str = ""
node_str = ""
activation_str = ""
alpha_str = ""

header_str += '// This methodology is originated from https://github.com/harmanpreet93/keras-model-to-cpp.\n\n'
header_str += '#ifndef __MODEL__H\n'
header_str += '#define __MODEL__H\n'
header_str += '#include <stdint.h>\n'
header_str += '#include <math.h>\n'
header_str += '\n'
header_str += '#define LAYERS ' + str(len(model.layers)) + '\n'
features = model.get_weights()[0].shape[0]
outputs = model.get_weights()[-1].shape[0]
header_str += '#define FEATURES ' + str(features) + '\n'
header_str += '#define OUTPUTS ' + str(outputs) + '\n'
header_str += 'extern const uint16_t numnodes[LAYERS];\n'
header_str += 'typedef enum {NONE, RELU, SOFTMAX, SIGMOID}ACTIVATION_FUNC;\n'
header_str += 'extern const ACTIVATION_FUNC activation_functions[LAYERS];\n'
header_str += 'extern const uint16_t layer_sizes[LAYERS][2];\n'

source_str += '#include "model.h"\n'
source_str += 'const uint16_t layer_sizes[LAYERS][2] = {\n'

for ind, l in enumerate(arch["config"]['layers']):
    if l['class_name'] == 'Flatten':
        source_str += '{0, 0},\n'
    if l['class_name'] == 'Dense':
        W = model.layers[ind].get_weights()[0]
        source_str += '{'+ str(W.shape[0]) +', '+ str(W.shape[1])+'},\n'
source_str += '}; // end of layer_sizes\n'

for ind, l in enumerate(arch["config"]['layers']):
    nodes = features # in case of the input layer.
    activation = 'NONE'
    if l['class_name'] == 'Dense':
        activation = model.layers[ind].get_config()['activation'].upper()
        W = model.layers[ind].get_weights()[0]
        B = model.layers[ind].get_weights()[1]
        nodes = len(B)
        header_str += 'extern const float theta_'+ str(ind) +' [' + str(W.shape[0]) + '][' + str(W.shape[1]) +'];\n' 
        source_str += 'const float theta_'+ str(ind)  +' [' + str(W.shape[0]) + '][' + str(W.shape[1]) +'] = {\n'
        theta_index = 0
        for w in W:
            source_str += '{'
            for w_i in w:
                source_str += str(w_i)+', '
            source_str += '},\n'
            theta_index += 1
        source_str += '}; // end of theta_'+ str(ind) +'\n'

        header_str += 'extern const float beta_'+ str(ind)  +' [' + str(len(B)) + '];\n'
        source_str += 'const float beta_'+ str(ind)  +' [' + str(len(B)) + '] = {\n'
        for b in B:
            source_str += str(b)+', '
        source_str += '}; // end of beta_'+ str(ind) +'\n'
    activation_str += activation + ', '

    header_str += 'float alpha_'+ str(ind)  +' [' + str(nodes) + '];\n'
    source_str += 'float alpha_'+ str(ind)  +' [' + str(nodes) + '] = {\n'
    for a in range(nodes):
        source_str += '0, '
    node_str += str(nodes) + ', '
    source_str += '}; // end of alpha_'+ str(ind) +'\n'


header_str += 'extern const float_t* weightMap[LAYERS-1];\n'
source_str += 'const float_t* weightMap[LAYERS-1] = {\n'
for ind, l in enumerate(arch["config"]['layers']):
    if ind > 0:
        source_str += '&theta_' + str(ind) + '[0][0],\n'
source_str += '};\n'

header_str += 'extern const float_t* biasMap[LAYERS-1];\n'
source_str += 'const float_t* biasMap[LAYERS-1] = {\n'
for ind, l in enumerate(arch["config"]['layers']):
    if ind > 0:
        source_str += '&beta_' + str(ind) + '[0],\n'
source_str += '};\n'

header_str += 'extern float_t* activationMap[LAYERS];\n'
source_str += 'float_t* activationMap[LAYERS] = {'
for ind, l in enumerate(arch["config"]['layers']):
    source_str += '&alpha_' + str(ind) + '[0],'
source_str += '};\n'

source_str += 'const uint16_t numnodes[LAYERS] = {'+ node_str +'};\n'
source_str += 'const ACTIVATION_FUNC activation_functions[LAYERS] = {'\
                + activation_str +'};\n'

#header_str += '#define ALPHA ' + alpha_str + '\n'
header_str += '#endif // __MODEL_H'

with open(args.output+'.h', 'w') as fout:
    fout.write(header_str)

with open(args.output+'.c', 'w') as fout:
    fout.write(source_str)
