/**
 * This file includes all fo the relevant
 * functionality for the inference.
 */

#include "model.h"
#include "utils.h"
#include <stdint.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	// Reading data from input file.
	uint8_t input_buffer[FEATURES];
	float output_buffer[OUTPUTS];
	FILE *input_file_ptr;
	input_file_ptr = fopen(argv[1],"rb");
	size_t ret = fread(input_buffer, FEATURES, sizeof(uint8_t), input_file_ptr);
	fclose(input_file_ptr);
	// Normalizing byte type input to float {0..1}
	for(int input_index = 0; input_index < FEATURES; input_index++)
	{
		alpha_0[input_index]
			= (float) input_buffer[input_index] / 255.0;
		// Thresholded visualization
		if(input_buffer[input_index]>0xf0)
		{
			printf("+");
		}
		else
		{
			printf(" ");
		}
		if((input_index+1)%28 == 0)
		{
			printf("\n");
		}
	}
	// Feedforward prediction
	printf("%s", "Calculating activations\n");
	for(int layer_index = 0; layer_index < LAYERS-1; layer_index++)
	{
		printf("Layer: %d\n", layer_index+1);
		// For all of the next layer's nodes...
		for(int j = 0; j < numnodes[layer_index+1]; j++)
		{	
			float zeta = 0.0f;
			// ...iterate over the current layer's nodes.
			for(int i = 0; i < numnodes[layer_index]; i++)
			{
				zeta += 
				(weightMap[layer_index])[i*numnodes[layer_index+1]+j]
				* activationMap[layer_index][i];
			}

			activationMap[layer_index+1][j] = zeta+biasMap[layer_index][j];
			// Appling activation functions
			if(activation_functions[layer_index+1] == RELU)
			{
				activationMap[layer_index+1][j]
				= relu(activationMap[layer_index+1][j]);
			}
			if(activation_functions[layer_index+1] == SIGMOID)
			{
				activationMap[layer_index+1][j]
				= sigmoid(activationMap[layer_index+1][j]);
			}
		}
	}
	// Applying output activation function
	// Filling up the output buffer.
	for(int j = 0; j < OUTPUTS; j++)
	{
		if(activation_functions[LAYERS-1] == SOFTMAX)
		{
			output_buffer[j]
			= softmax(
				activationMap[LAYERS-1]
				, j
				, numnodes[LAYERS-1]
			);
		}
	}

	printf("Output activations:\n");
	float max=0.0f;
	int max_index = 0;
	for(int output_node_index = 0; output_node_index < OUTPUTS; output_node_index++)
	{
		printf("%3d : %0.9f\n"
		, output_node_index
		, output_buffer[output_node_index]);
		if(output_buffer[output_node_index] > max)
		{
			max = output_buffer[output_node_index];
			max_index = output_node_index;
		}
	}
	printf("Prediction: %d\n", max_index);
	return 0;
}
