/**
 *	Basic utility set.
 */

#ifndef __UTILS__H
#define __UTILS__H

#include <math.h>

/**
 *	Calculates and returns RELU(input)
 */
float
relu(float input);

/**
 *	Calculates and returns softmax
 *	of the given input.
 *	exp(X[i])/sum[j=0..k]exp(X[j])
 *	\param	input_array
 *		Given input for softmax.
 *		(X)
 *	\param	index
 *		Index of the current value
 *		what the softmax will be
 *		calculated for.
 *		(i)
 *	\param	input_length
 *		Element number of input_array.
 *		(k)
 */
float
softmax(float* input_array, int index, int input_length);

#endif // __UTILS__H

