#include "defines.h"
#include "hash_table.h"
//#include "hash_function.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const int HASH_TABLE_SIZE[NUMBER_OF_HASH_TABLES] = {2/BUCKET_SIZE,
                                                    2/BUCKET_SIZE,
                                                    2/BUCKET_SIZE};

int fill_up_table(struct hash_tables *tables, int n_elements);

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
    //fill_up_table(hash_tables_p, 5);

    int matrix[2] = {1,3};
    printf("hash: %d\n",h3_hash_function(0,matrix,2,2));
    printf("hash: %d\n",h3_hash_function(1,matrix,2,2));
    printf("hash: %d\n",h3_hash_function(2,matrix,2,2));
    printf("hash: %d\n",h3_hash_function(3,matrix,2,2));
    /*printf("7\n");
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
    //print_hash_tables(hash_tables_p);
}

int fill_up_table(struct hash_tables *tables, int n_elements){
    int failed_inserts[n_elements];
    int failed_inserts_count = 0;
    memset(failed_inserts, 0, sizeof(failed_inserts));
    for (int i=0; i < n_elements; i++) {
        if(!insert_hash_tables(tables, i, 0)){
            failed_inserts[i] = 0;
            failed_inserts_count += 1;
        }

    }
    printf("fails: %d\n",failed_inserts_count);
    return 0;
}