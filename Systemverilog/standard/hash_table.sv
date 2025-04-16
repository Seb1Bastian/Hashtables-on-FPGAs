module hash_table #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter HASH_TABLE_MAX_SIZE = 5,
                    parameter [32*NUMBER_OF_TABLES-1:0] HASH_TABLE_SIZES = {32'd5,32'd5,32'd5,32'd5},
                    parameter KEEP_WIDTH = 8,
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
    input   logic [KEEP_WIDTH-1:0] keep_i,
    output  wire ready_o,
    output  wire valid_o,
    output  wire last_o,
    output  wire [KEEP_WIDTH-1:0] keep_o,
    output  wire [DATA_WIDTH-1:0] read_data_o,
    output  wire no_deletion_target_o,
    output  wire no_write_space_o,
    output  wire no_element_found_o,
    output  wire key_already_present_o
);

wire [KEY_WIDTH-1:0]    key_in_delayed;
wire [DATA_WIDTH-1:0]   data_in_delayed;
wire [1:0]              delete_write_read_i_valid;
wire [1:0]              delete_write_read_i_delayed;
wire [KEY_WIDTH-1:0]    correct_dim_matrix [NUMBER_OF_TABLES-1:0][HASH_TABLE_MAX_SIZE-1:0];

wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adrs_out                           [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adrs_out_delayed                   [NUMBER_OF_TABLES-1:0];
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]       hash_adrs_out_packed;
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]       hash_adrs_out_packed_delayed;
wire [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0]         content_out_of_block_ram                [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH-1:0]                                    key_delayed                             [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                                   data_delayed                            [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                                  flags_0                                 [NUMBER_OF_TABLES-1:0];

wire                                            write_en            [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                          write_valid_flag    [NUMBER_OF_TABLES-1:0];
wire [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0] write_content       [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                  hash_adr_write      [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                           read_data;


wire [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0] correct_content         [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                          correct_is_valid    [NUMBER_OF_TABLES-1:0];


wire [DATA_WIDTH-1:0]   correct_cam_data;
wire                    correct_cam_valid;
wire                    cam_del;
wire                    cam_write;
wire [KEY_WIDTH-1:0]    cam_write_key;
wire [DATA_WIDTH-1:0]   cam_write_data;
wire [KEY_WIDTH-1:0]    key_in_cam_delayed;

wire [DATA_WIDTH-1:0]   cam_read_data;
wire                    cam_read_valid;

localparam integer HASH_TABLE_SIZE [NUMBER_OF_TABLES-1:0] = ADDR_CALC();

typedef integer packed_array_t [NUMBER_OF_TABLES-1:0];
function packed_array_t ADDR_CALC();
    packed_array_t a;
    for (int ii = 0; ii < NUMBER_OF_TABLES; ii++) begin
        a[ii] = HASH_TABLE_SIZES[32*(ii+1)-1 -:32];
    end
    return a;
endfunction


genvar i,j;
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
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1) begin
        simple_dual_one_clock 
            #(.MEM_SIZE(HASH_TABLE_SIZE[i]),
              .DATA_WIDTH((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)
        )
        block_ram(
            .clk(clk),
            .ena(1'b1),     //probably needs not to be changed
            .enb(1'b1),     //probably needs not to be changed
            .wea((write_en[i] && ready_i)),
            .addra(hash_adr_write[i][HASH_TABLE_SIZE[i]-1:0]),
            .addrb(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0]),
            .dia({write_content[i]}),
            .dob(content_out_of_block_ram[i])
        );
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


generate
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1) begin
        flag_register 
            #(.SIZE(HASH_TABLE_SIZE[i]),
              .BUCKET_SIZE(BUCKET_SIZE)
        ) flags_reg (
            .clk(clk),
            .reset(reset),
            .ready_i(ready_i),
            .read_adr_0(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0]),
            .read_adr_1({HASH_TABLE_SIZE[i]{1'b0}}),
            .read_adr_2({HASH_TABLE_SIZE[i]{1'b0}}),
            .write_adr(hash_adr_write[i]),
            .write_en((write_en[i] && ready_i)),
            .write_is_valid(write_valid_flag[i]),
            .flag_out_0(flags_0[i]),
            .flag_out_1(),
            .flag_out_2()
        );
    end
endgenerate

forwarder_unit #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEY_WIDTH(KEY_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .BUCKET_SIZE(BUCKET_SIZE),
    .MAX_HASH_ADR_WIDTH(HASH_TABLE_MAX_SIZE),
    .HASH_TABLE_ADR_WIDTH(HASH_TABLE_SIZE)
) forward_updater (
    .clk(clk),
    .reset(reset),
    .clk_en(1'b1),                                              //no clk_en ?????
    .new_hash_adr_i(hash_adrs_out_delayed),
    .new_content_i(content_out_of_block_ram),
    .new_valid_i(flags_0),

    .forward_hash_adr_i(hash_adr_write),
    .forward_content_i(write_content),
    .forward_updated_mem_i(write_en),
    .forward_valid_i(write_valid_flag),

    .correct_content_o(correct_content),
    .correct_is_valid_o(correct_is_valid)
);

cam_forwarder #(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) cam_forwarder (
    .clk(clk),
    .reset(reset),
    .clk_en(ready_i),

    .new_key_i(key_in_delayed),
    .new_data_i(cam_read_data),
    .new_valid_i(cam_read_valid),

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
    .data_i(data_in_delayed),
    .key_i(key_in_delayed),
    .hash_adr_i(hash_adrs_out_delayed), //
    .delete_write_read_i(delete_write_read_i_delayed),
    .read_out_content_i(correct_content),
    .valid_flags_0_i(correct_is_valid),
    .CAM_data_i(correct_cam_data),
    .CAM_valid_i(correct_cam_valid),
    .write_en_o(write_en),
    .write_valid_flag_o(write_valid_flag),
    .write_content_o(write_content),
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
    .DELAY(1))
data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(data_in),
    .data_o(data_in_delayed));

siso_register #(
    .DATA_WIDTH(KEY_WIDTH),
    .DELAY(1))
key_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(key_in),
    .data_o(key_in_delayed));

siso_register #(
    .DATA_WIDTH(2),
    .DELAY(1))
op_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(delete_write_read_i_valid),
    .data_o(delete_write_read_i_delayed));

siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES),
    .DELAY(1))
hash_adr_delay_0(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(hash_adrs_out_packed),
    .data_o(hash_adrs_out_packed_delayed));
assign hash_adrs_out_packed = { << { hash_adrs_out}};
assign hash_adrs_out_delayed = { << { hash_adrs_out_packed_delayed}};

siso_register #(
    .DATA_WIDTH(1),
    .DELAY(1))
last_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(last_i),
    .data_o(last_o));


siso_register #(
    .DATA_WIDTH(KEEP_WIDTH),
    .DELAY(1))
keep_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(keep_i),
    .data_o(keep_o));



assign ready_o = ready_i;
assign delete_write_read_i_valid = valid_i == 1'b1 ? delete_write_read_i : 2'b00; //nothing operation


endmodule