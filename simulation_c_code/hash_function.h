#ifndef HASH_FUNCTION
#define HASH_FUNCTION

#include "defines.h"
int compute_hash(int key, int function_id);
int h3_hash_function(int key, int *matrix_row, int key_length, int hash_length);

#endif