/**
 *	Basic utility set.
 */

#include "utils.h"
#include <stdio.h>

float
relu(float input)
{
	if(input >= 0.0f)
		return input;
	return 0.0f;
}

float
softmax(float input_array[], int index, int input_length)
{
	float denominator = 0.0f;
	for(int input_index=0; input_index<input_length; input_index++)
	{
		denominator += exp(input_array[input_index]);
	}
	return exp(input_array[index]) / denominator;
}

float
sigmoid(float in)
{
	return 1 / ( 1 + exp(-in));
}
