#include <stdio.h>
#include "utils.h"

int
main()
{
	printf("Testing softmax\n");
	float test_in[4] = {0.1, 0.5, 0.9, -0.4};
	printf("%0.5f", softmax(test_in, 0, 4));
	return 0;
}
