#include "defines.h"
#include "hash_table.h"
#include <stdio.h>
#include <stdlib.h>

const int HASH_TABLE_SIZE[NUMBER_OF_HASH_TABLES] = {2/BUCKET_SIZE,
                                                    2/BUCKET_SIZE,
                                                    2/BUCKET_SIZE};

int OVERFLOW_ARRAY[NUMBER_OF_WRITE_OPERATIONS];

int main(int argc, char* argv[]){
    struct hash_tables *hash_tables_p = calloc(1, sizeof(struct hash_tables));
    printf("1\n");

    for (int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        printf("2\n");
        struct hash_table *hash_table_p = calloc(1, sizeof(struct hash_table));
        printf("3\n");
        hash_tables_p->tables[i] = hash_table_p;
        printf("4\n");
        struct key_bucket *key_bucket = calloc(HASH_TABLE_SIZE[i], sizeof(struct key_bucket));
        struct data_bucket *data_bucket = calloc(HASH_TABLE_SIZE[i], sizeof(struct data_bucket));
        struct full_bucket *full_bucket = calloc(HASH_TABLE_SIZE[i], sizeof(struct full_bucket));
        printf("5\n");
        hash_table_p->key_buckets = key_bucket;
        hash_table_p->data_buckets = data_bucket;
        hash_table_p->full_buckets = full_bucket;
        printf("6\n");
    }
    printf("7\n");
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 0, 1);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 1, 2);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 3, 3);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    delete_hash_table(hash_tables_p, 0);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 2, 4);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    /*insert_hash_tables(hash_tables_p, 1, 4);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 1, 5);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 1, 6);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 1, 7);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 1, 8);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 1, 9);
    print_hash_tables(hash_tables_p);
    printf("\n\n");
    insert_hash_tables(hash_tables_p, 1, 10);
    print_hash_tables(hash_tables_p);
    //*/
}