#ifndef HASH_TABLE
#define HASH_TABLE

#include "hash_function.h"

struct full_bucket* check_hash_table(struct hash_tables *t, int adr, int table_id);
struct data_bucket* read_data_hash_table(struct hash_tables *t, int adr, int table_id);

bool insert_hash_table(struct hash_tables *t, int adr, int table_id, int key, int data);
bool insert_hash_tables(struct hash_tables *t, int key, int data);

bool delete_hash_table(struct hash_tables *t, int key);

void print_hash_tables(struct hash_tables *t);

void print_array(int *arr, int d1, int d2);

#endif