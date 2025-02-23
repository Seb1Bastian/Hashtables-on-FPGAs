module controller #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter integer HASH_TABLE_MAX_SIZE = 2,
                    parameter BUCKET_SIZE = 1,
                    parameter CAM_SIZE = 64
                    )(
    input   logic                           clk,
    input   logic                           clk_en,
    input   logic                           reset,
    input   logic [KEY_WIDTH-1:0]           key_i,
    input   logic [DATA_WIDTH-1:0]          data_i,
    input   logic [HASH_TABLE_MAX_SIZE-1:0] hash_adr_i          [NUMBER_OF_TABLES-1:0],
    input   logic [1:0]                     delete_write_read_i,      // 00 = do nothing | 01 = read | 10 = write | 11 = delete
    input   logic [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]           read_out_keys_i     [NUMBER_OF_TABLES-1:0],
    input   logic [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]          read_out_data_i     [NUMBER_OF_TABLES-1:0],
    input   logic [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0] read_out_hash_adr_i [NUMBER_OF_TABLES-2:0], // von i nach i+1
    input   logic [BUCKET_SIZE-1:0]                          valid_flags_0_i     [NUMBER_OF_TABLES-1:0],
    input   logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]         valid_flags_1_i     [NUMBER_OF_TABLES-1:1],

    input   logic [DATA_WIDTH-1:0]          CAM_data_i,
    input   logic                           CAM_valid_i,

    output  wire [BUCKET_SIZE-1:0]                  write_en_o          [NUMBER_OF_TABLES-1:0],
    output  wire                                    write_shift_o       [NUMBER_OF_TABLES-2:0],
    output  wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0] write_shift_b_o     [NUMBER_OF_TABLES-2:0],
    output  wire [BUCKET_SIZE-1:0]                  write_og_b_o        [NUMBER_OF_TABLES-1:0],
    output  wire [BUCKET_SIZE-1:0]                  write_valid_flag_o  [NUMBER_OF_TABLES-1:0],
    output  wire [KEY_WIDTH-1:0]                    keys_o              [NUMBER_OF_TABLES-1:0],
    output  wire [DATA_WIDTH-1:0]                   data_o              [NUMBER_OF_TABLES-1:0],
    output  wire [HASH_TABLE_MAX_SIZE-1:0]          hash_adr_o          [NUMBER_OF_TABLES-1:0],
    output  wire [DATA_WIDTH-1:0]           read_data_o,
    output  wire                            valid_o,

    output  wire [KEY_WIDTH-1:0]            CAM_key_o,
    output  wire [DATA_WIDTH-1:0]           CAM_data_o,
    output  wire                            CAM_write_en_o,
    output  wire                            CAM_delete_o,

    output  wire                            no_deletion_target_o,
    output  wire                            no_write_space_o,
    output  wire                            no_element_found_o,
    output  wire                            key_already_present_o
);
localparam logic [1:0] NOTHING_OPERATION = 2'b00;
localparam logic [1:0] READ_OPERATION    = 2'b01;
localparam logic [1:0] WRITE_OPERATION   = 2'b10;
localparam logic [1:0] DELTE_OPERATION   = 2'b11;

wire [BUCKET_SIZE*BUCKET_SIZE-1:0]                              valid_flags_1 [NUMBER_OF_TABLES-1:0];

logic                                                           used_space_in_CAM;
wire                                                            write_CAM;
wire                                                            delete_CAM;

wire [KEY_WIDTH-1:0]                                            read_key;
wire [DATA_WIDTH-1:0]                                           read_data;
wire [DATA_WIDTH-1:0]                                           read_table_data;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]                    same_key;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]                    delete;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]                    write;
wire [NUMBER_OF_TABLES-1:0]                                     write_og;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]                    write_og_b;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]   write_shift_b;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]   write_shift_b_;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]                    write_shift_reduced;
wire                                                            write_shift [NUMBER_OF_TABLES-1:0]; //shift into table i
wire                                                            unary_or_same_key;
wire                                                            no_write;
wire                                                            con_is_read;
wire                                                            con_is_write;
wire                                                            con_is_del;
wire [NUMBER_OF_TABLES-1:0]                                     unary_valid;
wire [NUMBER_OF_TABLES-1:0]                                     unary_shift_valid;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]                    possible_write_og_b_for_non_shift;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]                    possible_write_og_b_for_shift;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]   possible_write_shift_b;

wire [BUCKET_SIZE-1:0]                                          correct_valid_flags_del         [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                          correct_valid_flags_write       [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                          correct_valid_flags_write_shift [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                          possible_write_shift_b_reduced  [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                          valid_flags_1_reduced           [NUMBER_OF_TABLES-1:0];


wire [KEY_WIDTH-1:0]            to_be_shifted_keys      [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]           to_be_shifted_data      [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]  to_be_shifted_hash_adr  [NUMBER_OF_TABLES-1:0];


genvar i,j,k,l;
generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        for (j = 0; j < BUCKET_SIZE ; j++ ) begin
            assign same_key[i][j] = (key_i == read_out_keys_i[i][j] & valid_flags_0_i[i][j]) ? 1'b1 : 1'b0;
        end
    end
endgenerate
assign unary_or_same_key = (|same_key) | CAM_valid_i;

generate
    assign unary_valid[0] = &valid_flags_0_i[0];
    for (i = 1; i < NUMBER_OF_TABLES ; i++) begin
        assign unary_valid[i] = &valid_flags_0_i[i];
        assign unary_shift_valid[i] = &valid_flags_1_i[i];
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        for (k = 0; k < BUCKET_SIZE; k++) begin
            if (k == 0) begin
                assign possible_write_og_b_for_non_shift[i][k] = ~valid_flags_0_i[i][k];
                assign possible_write_og_b_for_shift[i][k] = (i == NUMBER_OF_TABLES-1) ? 1'b0 : ~&valid_flags_1_i[i+1][k][BUCKET_SIZE-1:0]; //calculates which buckets can be shifted on a per table basis
            end else begin
                assign possible_write_og_b_for_non_shift[i][k] = ~valid_flags_0_i[i][k] & (&valid_flags_0_i[i][k-1:0]); //write into first empty bucket
                assign possible_write_og_b_for_shift[i][k] = (i == NUMBER_OF_TABLES-1) ? 1'b0 : (~&valid_flags_1_i[i+1][k][BUCKET_SIZE-1:0]) & (~|possible_write_og_b_for_shift[i][k-1:0]);
            end
            assign valid_flags_1[i][(k+1)*BUCKET_SIZE-1:k*BUCKET_SIZE] = (i == 0) ? {BUCKET_SIZE{1'b0}} : valid_flags_1_i[i][k];
            for (l = 0; l < BUCKET_SIZE ; l++ ) begin //i+1 muss noch respektiert werden mit einem if
                if (l == 0) begin
                    assign possible_write_shift_b[i][k][l] = (i == 0) ? 1'b0 : ~valid_flags_1_i[i][k][l];
                end else begin
                    assign possible_write_shift_b[i][k][l] = (i == 0) ? 1'b0 : ~valid_flags_1_i[i][k][l] & (&valid_flags_1[i][(k)*BUCKET_SIZE+l-1:0]); //shift into the first empty bucket
                end
            end
            assign possible_write_shift_b_reduced[i][k] = |possible_write_shift_b[i][k];
        end
    end
endgenerate



generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        if (i == 0) begin
            assign write_og[0] = (!unary_valid[i] || ((!unary_shift_valid[i+1]) && unary_valid[i+1])) ? 1'b1 : 1'b0;
        end else if (i < NUMBER_OF_TABLES-1) begin
            assign write_og[i] = ((!unary_valid[i] || ((!unary_shift_valid[i+1]) && unary_valid[i+1])) && (~|write_og[i-1:0])) ? 1'b1 : 1'b0;
        end else begin
            assign write_og[i] = ((!unary_valid[i]) && (~|write_og[i-1:0])) ? 1'b1 : 1'b0;
        end
        if (i == 0) begin
            assign write_shift[0] = 1'b0;
        end else begin
            assign write_shift[i] = ((unary_valid[i-1] & write_og[i-1]));
        end


        for (k = 0; k < BUCKET_SIZE; k++) begin
            if (i == NUMBER_OF_TABLES-1) begin
                assign write_og_b[i][k] = write_og[i] & possible_write_og_b_for_non_shift[i][k];
            end else begin
                assign write_og_b[i][k] = write_og[i] & ((write_shift[i+1]) ? possible_write_og_b_for_shift[i][k]: possible_write_og_b_for_non_shift[i][k]);
            end
            for (l = 0; l < BUCKET_SIZE ; l++ ) begin
                //assign write_shift_b[i][k][l] = (write_shift[i]) ? possible_write_shift_b : 1'b0;
                assign write_shift_b[i][l][k] = (write_shift[i] == 1'b1) ? possible_write_shift_b[i][k][l] : 1'b0;
                assign write_shift_b_[i][k][l] = (write_shift[i] == 1'b1) ? possible_write_shift_b[i][k][l] : 1'b0;
            end
            //assign write_shift_reduced[i][k] = |write_shift_b[i][BUCKET_SIZE:0][l]; // to show in which bucket we shift the data
            assign write_shift_reduced[i][k] = |write_shift_b[i][k][BUCKET_SIZE-1:0]; // to show in which bucket we shift the data
            assign write[i][k] = (write_og_b[i][k] | write_shift_reduced[i][k]) & delete_write_read_i == WRITE_OPERATION && (~unary_or_same_key);
            assign delete[i][k] = same_key[i][k] & delete_write_read_i == DELTE_OPERATION ? 1'b1 : 1'b0;
            assign write_en_o[i][k] = (write[i][k] || delete[i][k]) ? 1'b1 : 1'b0;
        end
        if (i > 0) begin
            assign write_shift_o[i-1] = write_shift[i];
        end
        assign write_og_b_o[i] = write_og_b[i];
    end
endgenerate

generate
    for (i = 1; i < NUMBER_OF_TABLES; i++) begin
        assign write_shift_b_o[i-1] = write_shift_b_[i];
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES; i++) begin
        if (i > 0) begin
            raw_mulitplexer_unpacked #(
                .DATA_WIDTH(BUCKET_SIZE),
                .BUCKET_SIZE(BUCKET_SIZE)
            ) write_multiplexer_key(
                .data_in(valid_flags_1_i[i]),
                .sel(possible_write_shift_b_reduced[i]),
                .data_out(valid_flags_1_reduced[i])
            );
        end
        for (k = 0; k < BUCKET_SIZE; k++) begin
            assign correct_valid_flags_del[i][k] =  valid_flags_0_i[i][k] & (~delete[i][k]) & delete_write_read_i == DELTE_OPERATION;
            assign correct_valid_flags_write[i][k] =  (valid_flags_0_i[i][k] | (write_og_b[i][k])) & write_og[i] & delete_write_read_i == WRITE_OPERATION;
            assign correct_valid_flags_write_shift[i][k] =  (i == 0) ? 1'b0 : (write_shift_reduced[i][k] | valid_flags_1_reduced[i][k]) & delete_write_read_i == WRITE_OPERATION;
            assign write_valid_flag_o[i][k] =  (correct_valid_flags_del[i][k] | correct_valid_flags_write[i][k] | correct_valid_flags_write_shift[i][k]);
        end
    end
endgenerate
    


generate    //select the data from the correct bucket to be shifted 
    for (i = 0; i < NUMBER_OF_TABLES-1; i++ ) begin
        raw_mulitplexer_packed #(
            .DATA_WIDTH(KEY_WIDTH),
            .DATA_LINES(BUCKET_SIZE)
        ) write_multiplexer_key(
            .data_in(read_out_keys_i[i]),
            .sel(possible_write_og_b_for_shift[i]),
            .data_out(to_be_shifted_keys[i])
        );
        raw_mulitplexer_packed #(
            .DATA_WIDTH(DATA_WIDTH),
            .DATA_LINES(BUCKET_SIZE)
        ) write_multiplexer_data(
            .data_in(read_out_data_i[i]),
            .sel(possible_write_og_b_for_shift[i]),
            .data_out(to_be_shifted_data[i])
        );
        raw_mulitplexer_packed #(
            .DATA_WIDTH(HASH_TABLE_MAX_SIZE),
            .DATA_LINES(BUCKET_SIZE)
        ) write_multiplexer_adr(
            .data_in(read_out_hash_adr_i[i]),
            .sel(possible_write_og_b_for_shift[i]),
            .data_out(to_be_shifted_hash_adr[i])
        );
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES; i++ ) begin
        for (l = 0; l < BUCKET_SIZE; l++) begin
            if (i == 0) begin
                assign keys_o[i] = key_i;
                assign data_o[i] = data_i;
                assign hash_adr_o[i]  = hash_adr_i[i];
            end else begin
                assign keys_o[i] = (write_shift[i] == 1'b1) ? to_be_shifted_keys[i-1] : key_i; //write_shift_reduced[i]
                assign data_o[i] = (write_shift[i] == 1'b1) ? to_be_shifted_data[i-1] : data_i;
                assign hash_adr_o[i]  = (write_shift[i] == 1'b1) ? to_be_shifted_hash_adr[i-1] : hash_adr_i[i];
            end
        end
        
    end
endgenerate

raw_mulitplexer #(
    .DATA_WIDTH(DATA_WIDTH),
    .BUCKET_SIZE(BUCKET_SIZE),
    .DATA_LINES(NUMBER_OF_TABLES)
) read_multiplexer_data(
    .data_in(read_out_data_i),
    .sel(same_key),    //this code assumes that only one same_key signal can be 1 at each point in time
    .data_out(read_table_data)
);

assign read_data = (CAM_valid_i) ? CAM_data_i : read_table_data;

//assign read_data_o = {unary_or_same_key, con_is_write, con_is_read, con_is_del, read_data[DATA_WIDTH-5:0]};
assign read_data_o = read_data[DATA_WIDTH-1:0];
/*assign no_deletion_target_o = ((!unary_or_same_key) && (delete_write_read_i == DELTE_OPERATION)) ? 1'b1 : 1'b0;
assign no_write_space_o = ((~|write) && (delete_write_read_i == WRITE_OPERATION)) ? 1'b1 : 1'b0;
assign no_element_found_o = ((!unary_or_same_key) && (delete_write_read_i == READ_OPERATION)) ? 1'b1 : 1'b0;
assign key_already_present_o = ((unary_or_same_key) && (delete_write_read_i == WRITE_OPERATION)) ? 1'b1 : 1'b0;
*/

always @(posedge clk) begin
    if (reset == 1) begin
        used_space_in_CAM <= 0;
    end else if (clk_en == 1) begin
        if (write_CAM == 1) begin
            used_space_in_CAM <= used_space_in_CAM + 1;
        end else if (delete_CAM == 1) begin
            used_space_in_CAM <= used_space_in_CAM - 1;
        end
    end
end

assign CAM_key_o = key_i;
assign CAM_data_o = data_i;
assign write_CAM = (~(|write_og)) & delete_write_read_i == WRITE_OPERATION & used_space_in_CAM != CAM_SIZE;
assign delete_CAM = (|unary_or_same_key) & (~(|delete)) & delete_write_read_i == DELTE_OPERATION;
assign CAM_write_en_o = write_CAM;
assign CAM_delete_o = delete_CAM;





assign no_deletion_target_o = (~unary_or_same_key) & con_is_del;
assign no_write_space_o = no_write & con_is_write;
assign no_element_found_o = (~unary_or_same_key) & con_is_read;
assign key_already_present_o = unary_or_same_key & con_is_write;

assign valid_o = (delete_write_read_i == NOTHING_OPERATION) ? 1'b0 : 1'b1;
assign con_is_write = (delete_write_read_i == WRITE_OPERATION) ? 1'b1 : 1'b0;
assign con_is_read = (delete_write_read_i == READ_OPERATION) ? 1'b1 : 1'b0;
assign con_is_del = (delete_write_read_i == DELTE_OPERATION) ? 1'b1 : 1'b0;
assign no_write = (~((|write) | write_CAM));

endmodule