module hash_table #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter KEEP_WIDTH = $ceil(KEY_WIDTH+DATA_WIDTH),
                    parameter NUMBER_OF_TABLES = 5,
                    parameter HASH_TABLE_MAX_SIZE = 5,
                    parameter [32*NUMBER_OF_TABLES-1:0] HASH_TABLE_SIZES = {32'd5,32'd5,32'd5,32'd5},
                    parameter BUCKET_SIZE = 1,
                    parameter CAM_SIZE = 8)(
    input   logic clk,
    input   logic reset,
    input   logic [NUMBER_OF_TABLES*HASH_TABLE_MAX_SIZE*KEY_WIDTH-1:0] matrixes_i,
    input   logic [KEY_WIDTH-1:0] key_in,
    input   logic [DATA_WIDTH-1:0] data_in,
    input   logic [1:0] delete_write_read_i,
    input   logic ready_i,
    input   logic valid_i,
    input   logic last_i,
    output  wire ready_o,
    output  wire valid_o,
    output  wire last_o,
    output  wire [DATA_WIDTH-1:0] read_data_o,
    output  wire no_deletion_target_o,
    output  wire no_write_space_o,
    output  wire no_element_found_o,
    output  wire key_already_present_o
);
/*localparam integer HASH_TABLE_SIZE[NUMBER_OF_TABLES-1:0] = '{32'd1,32'd1,32'd1,32'd1};
localparam [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0] = '{'{6'b000000},
                                                                                      '{6'b000100},
                                                                                      '{6'b000010},
                                                                                      '{6'b000001}};
localparam HASH_TABLE_MAX_SIZE = HASH_TABLE_SIZE[0];*/
localparam integer HASH_TABLE_SIZE [NUMBER_OF_TABLES-1:0] = ADDR_CALC();

typedef integer packed_array_t [NUMBER_OF_TABLES-1:0];
function packed_array_t ADDR_CALC();
    packed_array_t a;
    for (int ii = 0; ii < NUMBER_OF_TABLES; ii++) begin
        a[ii] = HASH_TABLE_SIZES[32*(ii+1)-1 -:32];
    end
    return a;
endfunction

genvar i,j,l;

/*generate
    for (i = 0; i < NUMBER_OF_TABLES; i++) begin
        HASH_TABLE_SIZE[i] = HASH_TABLE_SIZES[(i+1)*32-1:-32];
    end
endgenerate*/



wire [KEY_WIDTH-1:0] correct_dim_matrix [NUMBER_OF_TABLES-1:0][HASH_TABLE_MAX_SIZE-1:0];

wire [KEY_WIDTH-1:0]    key_in_delayed;
wire [DATA_WIDTH-1:0]   data_in_delayed;
wire [1:0]              delete_write_read_i_valid;
wire [1:0]              delete_write_read_i_delayed;

wire [HASH_TABLE_MAX_SIZE-1:0]                                          hash_adrs_out                           [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                                          hash_adrs_out_delayed                   [NUMBER_OF_TABLES-1:0];
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]                       hash_adrs_out_packed;
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]                       hash_adrs_out_packed_delayed;
wire [BUCKET_SIZE-1:0][KEY_WIDTH+DATA_WIDTH-1:0]                        data_out_of_block_ram                   [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][KEY_WIDTH+DATA_WIDTH-1:0]                        data_out_of_block_ram_delayed           [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES)-1:0]   data_out_of_block_ram_packed;
wire [BUCKET_SIZE-1:0][((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES)-1:0]   data_out_of_block_ram_packed_delayed;
wire [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]                                   key_delayed                             [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]                                  data_delayed                            [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0]                         hash_adr_1                              [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0]                         hash_adr_1_delayed                      [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-1))-1:0]  hash_adr_1_packed;
wire [BUCKET_SIZE-1:0][(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-1))-1:0]  hash_adr_1_packed_delayed;
wire [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0]                         hash_adr_2                              [NUMBER_OF_TABLES-2:1];
wire [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0]                         hash_adr_2_delayed                      [NUMBER_OF_TABLES-2:1];
wire [BUCKET_SIZE-1:0][(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-2))-1:0]  hash_adr_2_packed;
wire [BUCKET_SIZE-1:0][(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-2))-1:0]  hash_adr_2_packed_delayed;  //TODO: geht das so überhaupt ins siso
wire [BUCKET_SIZE-1:0]                                                  flags_0                                 [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                                  flags_0_delayed                         [NUMBER_OF_TABLES-1:0];
wire [(NUMBER_OF_TABLES*BUCKET_SIZE)-1:0]                               flags_0_packed;
wire [(NUMBER_OF_TABLES*BUCKET_SIZE)-1:0]                               flags_0_packed_delayed;
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]                                 flags_1                                 [NUMBER_OF_TABLES-1:1];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]                                 flags_2                                 [NUMBER_OF_TABLES-1:2];

wire [BUCKET_SIZE-1:0]                                                  write_en                                [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                                  write_valid_flag                        [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH-1:0]                                                    write_keys                              [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                                                   write_data                              [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                                          hash_adr_write                          [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                                                   read_data;

wire [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0]                         forward_shift_hash_adr                  [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]                                 forward_shift_valid                     [NUMBER_OF_TABLES-2:0];
wire                                                                    write_shift                             [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]                                 write_shift_b                           [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0]                                                  write_og_b                              [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]                                   correct_key                             [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]                                  correct_data                            [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                                  correct_is_valid                        [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0]                         correct_shift_adr                       [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]                                 correct_shift_valid                     [NUMBER_OF_TABLES-2:0];


wire [DATA_WIDTH-1:0] correct_cam_data;
wire correct_cam_valid;
wire cam_del;
wire cam_write;
wire [KEY_WIDTH-1:0] cam_write_key;
wire [DATA_WIDTH-1:0] cam_write_data;
wire [KEY_WIDTH-1:0] key_in_cam_delayed;

wire [DATA_WIDTH-1:0] cam_read_data;
wire [DATA_WIDTH-1:0] cam_read_data_delayed;
wire cam_read_valid;
wire cam_read_valid_delayed;


generate
    for (i = 0; i < NUMBER_OF_TABLES; i++) begin
        for (j = 0; j < HASH_TABLE_MAX_SIZE; j++) begin
            assign correct_dim_matrix[i][j] = matrixes_i[(i * HASH_TABLE_MAX_SIZE * KEY_WIDTH) + (j * KEY_WIDTH) +: KEY_WIDTH];
        end
    end
endgenerate
generate
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1) begin
        h3_hash_function 
            #(.KEY_WIDTH(KEY_WIDTH),
              .HASH_ADR_WIDTH(HASH_TABLE_SIZE[i])
        )
        hash_0(
            .key_in(key_in),
            .matrix_i(correct_dim_matrix[i]),
            .hash_adr_out(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0])
        );
    end
endgenerate


generate
    for (i = 0; i < NUMBER_OF_TABLES ; i = i + 1 ) begin
        for (j = 0; j < BUCKET_SIZE; j = j + 1) begin
            simple_dual_one_clock 
                #(.MEM_SIZE(HASH_TABLE_SIZE[j]),
                .DATA_WIDTH(KEY_WIDTH+DATA_WIDTH)
            )
            block_ram(
                .clk(clk),
                .ena(1'b1),     //probably needs not to be changed
                .enb(1'b1),     //probably needs not to be changed
                .wea((write_en[i][j] && ready_i)),
                .addra(hash_adr_write[i][HASH_TABLE_SIZE[j]-1:0]),
                .addrb(hash_adrs_out[i][HASH_TABLE_SIZE[j]-1:0]),
                .dia({write_keys[i], write_data[i]}),
                .dob(data_out_of_block_ram[i][j])
            );
        end
    end
endgenerate


hash_cash#( 
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_SIZE(CAM_SIZE)
) hash_cam (
    .clk(clk),
    .reset(reset),
    .data_in(cam_write_data),
    .key_write_i(cam_write_key),
    .key_read_i(key_in),
    .cs(ready_i),
    .we(cam_write),
    .read_en(1'b1),
    .del(cam_del),
    .data_out(cam_read_data),
    .valid_o(cam_read_valid),
    .error()
);


localparam logic [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0] zero_vector = '{default: '0};
generate
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1) begin
        if (i == 0) begin
            flag_register 
                #(.ADR_WIDTH(HASH_TABLE_SIZE[i]),
                  .MAX_ADR_WIDTH(HASH_TABLE_MAX_SIZE),
                  .BUCKET_SIZE(BUCKET_SIZE)
            )flags_reg_0(
                .clk(clk),
                .reset(reset),
                .ready_i(ready_i),
                .read_adr_0(hash_adrs_out[i]),
                .read_adr_1(zero_vector),
                .read_adr_2(zero_vector),
                .write_adr(hash_adr_write[i]),
                .write_en((|write_en[i])),
                .write_is_valid(write_valid_flag[i]),
                .flag_out_0(flags_0[i]),
                .flag_out_1(),
                .flag_out_2()
            );
        end else if (i == 1) begin
            flag_register 
                #(.ADR_WIDTH(HASH_TABLE_SIZE[i]),
                  .MAX_ADR_WIDTH(HASH_TABLE_MAX_SIZE),
                  .BUCKET_SIZE(BUCKET_SIZE)
            )flags_reg_1(
                .clk(clk),
                .reset(reset),
                .ready_i(ready_i),
                .read_adr_0(hash_adrs_out[i]),   //from i-1 to i
                .read_adr_1(hash_adr_1[i-1]),   // from i to i+1
                .read_adr_2(zero_vector),
                .write_adr(hash_adr_write[i]),
                .write_en((|write_en[i])),
                .write_is_valid(write_valid_flag[i]),
                .flag_out_0(flags_0[i]),
                .flag_out_1(flags_1[i]),
                .flag_out_2()
            );
        end else if ( i > 1) begin
            flag_register 
                #(.ADR_WIDTH(HASH_TABLE_SIZE[i]),
                  .MAX_ADR_WIDTH(HASH_TABLE_MAX_SIZE),
                  .BUCKET_SIZE(BUCKET_SIZE)
            )flags_reg__(
                .clk(clk),
                .reset(reset),
                .ready_i(ready_i),
                .read_adr_0(hash_adrs_out[i]),    //into i-te mem
                .read_adr_1(hash_adr_1[i-1]),     //from i to i+1 mem
                .read_adr_2(hash_adr_2[i-1]),     //from i to i+1 mem
                .write_adr(hash_adr_write[i]),
                .write_en((|write_en[i])),
                .write_is_valid(write_valid_flag[i]),
                .flag_out_0(flags_0[i]),
                .flag_out_1(flags_1[i]),
                .flag_out_2(flags_2[i])
            );
        end
    end
endgenerate


generate
    for (i = 0; i < NUMBER_OF_TABLES-1; i = i + 1) begin
        for (j = 0; j < BUCKET_SIZE ; j = j + 1) begin
            h3_hash_function 
                #(.KEY_WIDTH(KEY_WIDTH),
                .HASH_ADR_WIDTH(HASH_TABLE_SIZE[i])
            )hash_1(
                .key_in(data_out_of_block_ram[i][j][KEY_WIDTH+DATA_WIDTH-1:DATA_WIDTH]),
                .matrix_i(correct_dim_matrix[i]),
                .hash_adr_out(hash_adr_1[i][j])
            );
        end
        
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES-2; i = i + 1) begin
        for(j = 0; j < BUCKET_SIZE; j++) begin
            h3_hash_function 
                #(.KEY_WIDTH(KEY_WIDTH),
                .HASH_ADR_WIDTH(HASH_TABLE_SIZE[i])
            )
            hash_2(
                .key_in(correct_key[i][j]),
                .matrix_i(correct_dim_matrix[i]),
                .hash_adr_out(hash_adr_2[i+1][j])
            );
        end
    end
endgenerate

generate
    for (j = 0; j < BUCKET_SIZE; j++) begin
        assign forward_shift_hash_adr[0][j] = hash_adrs_out_delayed[1];
        for (l = 0; l < BUCKET_SIZE; l++) begin
            assign forward_shift_valid[0][j][l] = correct_is_valid[1][l]; //TODO: brauch die buckets, wo nicht reingeschrieben wurde
        end
    end
    for (i = 1; i < NUMBER_OF_TABLES-1 ; i++ ) begin
        for(j = 0; j < BUCKET_SIZE; j++) begin
            assign forward_shift_hash_adr[i][j] = (write_shift[i-1] & write_en[i][j]) ? hash_adr_2[i][j] : hash_adrs_out_delayed[i] ; // if shifted from i to i+1 the shift values for i+2 must be updated
            for (l = 0; l < BUCKET_SIZE; l++) begin
                assign forward_shift_valid[i][j][l] = correct_is_valid[i+1][l]; //gets later correct if a shift operation happend (in the forward unit) (write_shift[i] == 1'b1) ? flags_2[i+1] : correct_is_valid[i+1]; 
            end
        end
    end
endgenerate
generate
    for (i = 0; i < NUMBER_OF_TABLES; i++) begin
        for(j = 0; j < BUCKET_SIZE; j++) begin
            assign key_delayed[i][j]  = data_out_of_block_ram_delayed[i][j][KEY_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
            assign data_delayed[i][j] = data_out_of_block_ram_delayed[i][j][DATA_WIDTH-1:0];
        end
    end
endgenerate


whole_forward_updater #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEY_WIDTH(KEY_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .FORWARDED_CLOCK_CYCLES(2),
    .MAX_HASH_ADR_WIDTH(HASH_TABLE_MAX_SIZE),
    .BUCKET_SIZE(BUCKET_SIZE),
    .HASH_TABLE_ADR_WIDTH(HASH_TABLE_SIZE)
) forward_updater (
    .clk(clk),
    .reset(reset),
    .clk_en(ready_i),
    .new_hash_adr_i(hash_adrs_out_delayed),
    .new_data_i(data_delayed),
    .new_key_i(key_delayed),
    .new_valid_i(flags_0_delayed),
    .new_shift_adr_i(hash_adr_1_delayed),
    .new_shift_valid_i(flags_1),

    .forward_hash_adr_i(hash_adr_write),
    .forward_data_i(write_data),
    .forward_key_i(write_keys),
    .forward_updated_mem_i(write_en),
    .forward_valid_i(write_valid_flag),
    .forward_shift_hash_adr_i(forward_shift_hash_adr),
    .forward_shift_valid_i(forward_shift_valid),
    .forward_shift_shift_valid_i(flags_2),
    .forward_write_shift_i(write_shift_b),

    .correct_key_o(correct_key),
    .correct_data_o(correct_data),
    .correct_is_valid_o(correct_is_valid),
    .shift_adr_corrected_o(correct_shift_adr),
    .shift_valid_corrected_o(correct_shift_valid)
);


cam_forwarder #(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) cam_forwarder (
    .clk(clk),
    .reset(reset),
    .clk_en(ready_i),

    .new_key_i(key_in_delayed),
    .new_data_i(cam_read_data_delayed),
    .new_valid_i(cam_read_valid_delayed),

    .forward_key_i(cam_write_key),
    .forward_data_i(cam_write_data),
    .forward_write_i(cam_write),
    .forward_del_i(cam_del),

    .corrected_data_o(correct_cam_data),
    .correct_valid_o(correct_cam_valid)
);


controller #(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .BUCKET_SIZE(BUCKET_SIZE),
    .HASH_TABLE_MAX_SIZE(HASH_TABLE_MAX_SIZE)
) big_ass_controller (
    .clk(clk),
    .reset(reset),
    .clk_en(ready_i),
    .data_i(data_in_delayed),
    .key_i(key_in_delayed),
    .hash_adr_i(hash_adrs_out_delayed), //
    .delete_write_read_i(delete_write_read_i_delayed),
    .read_out_keys_i(correct_key),
    .read_out_data_i(correct_data),
    .read_out_hash_adr_i(correct_shift_adr),
    .valid_flags_0_i(correct_is_valid),
    .valid_flags_1_i(correct_shift_valid),
    .CAM_data_i(correct_cam_data),
    .CAM_valid_i(correct_cam_valid),
    .write_en_o(write_en),
    .write_shift_o(write_shift),
    .write_shift_b_o(write_shift_b),
    .write_og_b_o(write_og_b),
    .write_valid_flag_o(write_valid_flag),
    .keys_o(write_keys),
    .data_o(write_data),
    .hash_adr_o(hash_adr_write),
    .read_data_o(read_data_o),
    .valid_o(valid_o),
    .CAM_key_o(cam_write_key),
    .CAM_data_o(cam_write_data),
    .CAM_write_en_o(cam_write),
    .CAM_delete_o(cam_del),
    .no_deletion_target_o(no_deletion_target_o),
    .no_write_space_o(no_write_space_o),
    .no_element_found_o(no_element_found_o),
    .key_already_present_o(key_already_present_o)
);



//delaying signals to the right time

siso_register #(
    .DATA_WIDTH(DATA_WIDTH),
    .DELAY(1))
data_cam_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(cam_read_data),
    .data_o(cam_read_data_delayed));

siso_register #(
    .DATA_WIDTH(1),
    .DELAY(1))
valid_cam_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(cam_read_valid),
    .data_o(cam_read_valid_delayed));


siso_register #(
    .DATA_WIDTH(DATA_WIDTH),
    .DELAY(2))
data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(data_in),
    .data_o(data_in_delayed));

siso_register #(
    .DATA_WIDTH(KEY_WIDTH),
    .DELAY(2))
key_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(key_in),
    .data_o(key_in_delayed));

siso_register #(
    .DATA_WIDTH(2),
    .DELAY(2))
op_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(delete_write_read_i_valid),
    .data_o(delete_write_read_i_delayed));
assign delete_write_read_i_valid = valid_i == 1'b1 ? delete_write_read_i : 2'b00;

siso_register #(
    .DATA_WIDTH((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE*NUMBER_OF_TABLES),
    .DELAY(1))
stored_data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(data_out_of_block_ram_packed),
    .data_o(data_out_of_block_ram_packed_delayed));

assign data_out_of_block_ram_packed = { << { data_out_of_block_ram}};
assign data_out_of_block_ram_delayed = { << {data_out_of_block_ram_packed_delayed}};


siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES),
    .DELAY(2))                                                  // war vorher 1
hash_adr_delay_0(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(hash_adrs_out_packed),
    .data_o(hash_adrs_out_packed_delayed));
assign hash_adrs_out_packed = { << { hash_adrs_out}};
assign hash_adrs_out_delayed = { << { hash_adrs_out_packed_delayed}};

siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-1)*BUCKET_SIZE),
    .DELAY(1))
hash_adr_delay_1(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(hash_adr_1_packed),
    .data_o(hash_adr_1_packed_delayed));
assign hash_adr_1_packed = { << { hash_adr_1}};
assign hash_adr_1_delayed = { << { hash_adr_1_packed_delayed}};

siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-2)*BUCKET_SIZE),
    .DELAY(1))
hash_adr_delay_2(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(hash_adr_2_packed),
    .data_o(hash_adr_2_packed_delayed));
assign hash_adr_2_packed = { << { hash_adr_2}};
assign hash_adr_2_delayed = { << { hash_adr_2_packed_delayed}};


siso_register #(
    .DATA_WIDTH(NUMBER_OF_TABLES*BUCKET_SIZE),
    .DELAY(1))
flag_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(flags_0_packed),
    .data_o(flags_0_packed_delayed));

assign flags_0_packed = { << {flags_0}};
assign flags_0_delayed = { << { flags_0_packed_delayed}};
assign ready_o = ready_i;

siso_register #(
    .DATA_WIDTH(1),
    .DELAY(2))
last_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(last_i),
    .data_o(last_o));


siso_register #(
    .DATA_WIDTH(8),
    .DELAY(2))
keep_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(keep_i),
    .data_o(keep_o));


endmodule