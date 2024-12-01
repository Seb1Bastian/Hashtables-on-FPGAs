#ifndef DEFINES_H
#define DEFINES_H
#include <stdbool.h>
#define NUMBER_OF_HASH_TABLES 3
#define BUCKET_SIZE 1
#define UNIQUE_KEYS                     //should allways be defined except for debugging porpuses


struct full_bucket{
    bool full[BUCKET_SIZE];
};

struct data_bucket{
    int data[BUCKET_SIZE];
};

struct key_bucket{
    int key[BUCKET_SIZE];
};

struct hash_table{
    struct key_bucket *key_buckets;
    struct data_bucket *data_buckets;
    struct full_bucket *full_buckets;
};

struct hash_tables{
    struct hash_table *tables[NUMBER_OF_HASH_TABLES];
};

#endif