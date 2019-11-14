/**
 *	Basic utility set.
 */

#include "utils.h"

float
relu(float input)
{
	if(input > 0.0f)
		return input;
	return 0;
}

float
softmax(float* input_array, int index, int input_length)
{
	float denominator = 0;
	for(int input_index=0; input_index<input_length; input_index++)
	{
		denominator += exp(
			(float) input_array[input_index]
			);
	}
	return exp((float) input_array[index])
		/ denominator;
}

