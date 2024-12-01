#include "hash_function.h"
#include <stdio.h>
extern int HASH_TABLE_SIZE[];

int compute_hash(int key, int function_id){
    int hash;
    if (function_id == 0) {
        hash = key;
        return 1;
        return hash % HASH_TABLE_SIZE[0];
    }else if (function_id == 1) {
        hash = key;
        return hash % HASH_TABLE_SIZE[1];
    }else if (function_id == 2) {
        hash = key;
        return 1;
        return hash % HASH_TABLE_SIZE[2];
    }else if (function_id == 3) {
        hash = key;
        return hash % HASH_TABLE_SIZE[3];
    }else if (function_id == 4) {
        hash = key;
        return hash % HASH_TABLE_SIZE[4];
    }else if (function_id == 5) {
        hash = key;
        return hash % HASH_TABLE_SIZE[5];
    }else {
        return -1;
    }
}


int h3_hash_function(int key, int *matrix_row, int key_length, int hash_length){
    int helper[hash_length];
    int result = 0;
    for (int i =0; i<hash_length; i++) {
        helper[i] = key & matrix_row[i];
        //printf("helper:%d, %d\n",i,helper[i]);
    }
    for (int i=hash_length-1; i>0; i-- ) {
        result += __builtin_parity(helper[i]);
        result = result << 1;
        //printf("result:%d, %d\n",i,result);
    }
    result += __builtin_parity(helper[0]);
    //printf("result:%d, %d\n",0,result);
    return result;
}