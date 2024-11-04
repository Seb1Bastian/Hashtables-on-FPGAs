#include "hash_function.h"

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