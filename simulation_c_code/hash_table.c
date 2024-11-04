#include <stdbool.h>
#include <stdio.h>
#include "hash_table.h"

extern int HASH_TABLE_SIZE[];

struct full_bucket* check_hash_table(struct hash_tables *t, int adr, int table_id){
    return &(t->tables[table_id]->full_buckets[adr]);
}

struct data_bucket* read_data_hash_table(struct hash_tables *t, int adr, int table_id){
    return &(t->tables[table_id]->data_buckets[adr]);
}

struct key_bucket* read_key_hash_table(struct hash_tables *t, int adr, int table_id){
    return &(t->tables[table_id]->key_buckets[adr]);
}

int read_data_hash_table_bucket(struct hash_tables *t, int adr, int table_id, int bucket_position){
    return t->tables[table_id]->data_buckets[adr].data[bucket_position];
}

int read_key_hash_table_bucket(struct hash_tables *t, int adr, int table_id, int bucket_position){
    return t->tables[table_id]->key_buckets[adr].key[bucket_position];
}

bool read_full_hash_table_bucket(struct hash_tables *t, int adr, int table_id, int bucket_position){
    return t->tables[table_id]->full_buckets[adr].full[bucket_position];
}

bool insert_hash_table(struct hash_tables *t, int adr, int table_id, int key ,int data){
    struct hash_table *table = t->tables[table_id];
    struct full_bucket *full = check_hash_table(t, adr, table_id);
    for(int i = 0; i < BUCKET_SIZE; i++){
        if (!full->full[i]) {
            full->full[i] = true;
            table->data_buckets[adr].data[i] = data;
            table->key_buckets[adr].key[i] = key;
            return true;
        }
    }
    return false;
}

bool contains_key(struct hash_tables *t, int key){
    int hash_adr;
    int bucket_key;
    bool full; 
    for (int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        for (int j = 0; j < BUCKET_SIZE; j++) {
            hash_adr = compute_hash(key, i);
            bucket_key = read_key_hash_table_bucket(t, hash_adr, i, j);
            full = read_full_hash_table_bucket(t, hash_adr, i, j);
            if (full && (bucket_key == key)) {
                return true;            
            }
        }
    }
    return false;
}

bool insert_hash_tables(struct hash_tables *t, int key, int data){
    #ifdef UNIQUE_KEYS
        if(contains_key(t,key)){
            return false;
        }
    #endif
    int hash_adresses[NUMBER_OF_HASH_TABLES];
    for (int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        hash_adresses[i] = compute_hash(key,i);
    }
    struct full_bucket *full_buckets[NUMBER_OF_HASH_TABLES];
    for (int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        full_buckets[i] = check_hash_table(t, hash_adresses[i], i);
    }
    struct data_bucket *data_buckets[NUMBER_OF_HASH_TABLES];
    for (int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        data_buckets[i] = read_data_hash_table(t, hash_adresses[i], i);
    }
    bool fulls[NUMBER_OF_HASH_TABLES+1];
    fulls[NUMBER_OF_HASH_TABLES] = true; // diese hash tabelle existiert gar nicht weswegen sie immer voll seien muss
    for(int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        fulls[i] = true;
        for(int j = 0; j < BUCKET_SIZE; j++){
            fulls[i] = fulls[i] && full_buckets[i]->full[j];
        }
    }

    bool fulls_b_2[NUMBER_OF_HASH_TABLES][BUCKET_SIZE]; // which element from the bucket can be pushed to the next stage
    for(int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        for (int j = 0; j < BUCKET_SIZE; j++) {
            fulls_b_2[i][j] = true;
        }
    }
    bool fulls_2[NUMBER_OF_HASH_TABLES]; // We can push the value in at this position to the next hash table
    fulls_2[NUMBER_OF_HASH_TABLES-1] = true; //der letzte wert ist immer true, da es keine folge tabelle gibt in die man tauschen könnte
    int in_between_keys[NUMBER_OF_HASH_TABLES-1][BUCKET_SIZE];
    int in_between_hash_adr[NUMBER_OF_HASH_TABLES-1][BUCKET_SIZE];
    bool in_between_full_single_value = true;
    struct full_bucket *in_between_full;
    for(int i = 0; i < NUMBER_OF_HASH_TABLES-1; i++) {
        fulls_2[i] = true;
        for (int j = 0; j < BUCKET_SIZE; j++) {
            in_between_keys[i][j] = read_key_hash_table_bucket(t, hash_adresses[i], i, j);
            in_between_hash_adr[i][j] = compute_hash(in_between_keys[i][j], (i+1));
            in_between_full = check_hash_table(t, in_between_hash_adr[i][j], (i+1));

            /*for (int l=0; l<BUCKET_SIZE; l++) {
                in_between_full_single_value = in_between_full_single_value && in_between_full->full[l];
            }
            printf("i:%d, j:%d: bool:%d\n",i,j, in_between_full_single_value);*/

            for(int l = 0; l < BUCKET_SIZE; l++){
                fulls_b_2[i][j] = fulls_b_2[i][j] && in_between_full->full[l];
                fulls_2[i] = fulls_2[i] && in_between_full->full[l];
            }
        }
    }
    int in_between_data;
    int in_between_key;
    //printf("full1: %d, %d, %d\n", fulls[0], fulls[1], fulls[2]);
    //printf("full2: %d, %d, %d\n", fulls_2[0], fulls_2[1], fulls_2[2]);
    //print_array(fulls_b_2,NUMBER_OF_HASH_TABLES, BUCKET_SIZE);
    //printf("\n");
    for(int i = 0; i < NUMBER_OF_HASH_TABLES; i++){
        if ( (!fulls[i] || (!fulls_2[i] && fulls[i+1]))) {
            if (!fulls[i]) {
                //die erste position ist frei es muss nicht getauscht werden
                insert_hash_table(t, hash_adresses[i], i, key, data);
                return true;
            }else {
                for (int j = 0; j<BUCKET_SIZE; j++) {
                    //printf("i: %d, j:%d, bool:%d\n",i, j, fulls_b_2[i][j]);
                    if(!fulls_b_2[i][j]){
                        //printf("i: %d, j:%d\n",i, j);
                        //print_hash_tables(t);
                        in_between_data = read_data_hash_table_bucket(t, hash_adresses[i], i, j);
                        t->tables[i]->full_buckets[hash_adresses[i]].full[j] = false;
                        insert_hash_table(t, in_between_hash_adr[i][j], i+1, in_between_keys[i][j], in_between_data);
                        insert_hash_table(t, hash_adresses[i], i, key, data);
                        return true;
                    }
                }
            }        
        }
    }
    return false;
}

bool delete_hash_table(struct hash_tables *t, int key){
    int hash_adr;
    int bucket_key;
    bool full; 
    for (int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        for (int j = 0; j < BUCKET_SIZE; j++) {
            hash_adr = compute_hash(key, i);
            bucket_key = read_key_hash_table_bucket(t, hash_adr, i, j);
            full = read_full_hash_table_bucket(t, hash_adr, i, j);
            if (full && (bucket_key == key)) {
                t->tables[i]->full_buckets[hash_adr].full[j] = false;
                //t->tables[i]->data_buckets[hash_adr].data[j] = 0;     //can be commented in for easier debugging
                //t->tables[i]->key_buckets[hash_adr].key[j] = 0;
                return true;            
            }
        }
    }
    return false;
}


void print_hash_tables(struct hash_tables *t){
    printf("==============SHOW HASH TABLES==============\n");
    for (int i = 0; i < NUMBER_OF_HASH_TABLES; i++) {
        printf("Hash Table %d:\n",i);
        for(int j = 0; j < HASH_TABLE_SIZE[i]; j++){
            printf("B_%d:{ ",j);
            for(int l = 0; l < BUCKET_SIZE; l++){
                printf("(%d, %d, %s)", t->tables[i]->key_buckets[j].key[l], t->tables[i]->data_buckets[j].data[l], t->tables[i]->full_buckets[j].full[l] ?  "True" : "False");
                if (l == BUCKET_SIZE-1) {
                    printf("}\n");
                }else {
                    printf(", ");
                }
            }
        }
        printf("\n");
    }
}

void print_array(int *arr, int d1, int d2){
    printf("\n");
    for(int i=0; i<d1;i++){
        for (int j=0; j<d2; j++) {
            printf("%d, ",arr[i*d1+j]);
        }
        printf("\n");        
    }
    printf("\n");
}