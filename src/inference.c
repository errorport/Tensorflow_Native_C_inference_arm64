/**
 * This file includes all fo the relevant
 * functionality for the inference.
 */

#include "model.h"
#include "utils.h"
#include <stdint.h>
#include <stdio.h>

int main()
{
	/*
	printf("%s", "Model parameters:\n");
	printf("%s %d %s", "\tLayers:", LAYERS, "\n");
	*/
	printf("%s", "Calculating activations\n");
	for(int layer_index = 0; layer_index < LAYERS-1; layer_index++)
	{
		for(int j = 0; j < numnodes[layer_index+1]; j++)
		{
			float zeta = 0.0f;
			for(int i = 0; i < numnodes[layer_index]; i++)
			{
				zeta += weightMap[layer_index][i, j]
					* activationMap[layer_index][i];
				//activationMap[layer_index][j]	
			}
		}
	}

	// printf("%0.4f", relu(0.25f));
	// printf("%0.4f", (weightMap[0])[0, 1]);

	return 0;
}
