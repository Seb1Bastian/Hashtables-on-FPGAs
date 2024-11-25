module axi_wrapper #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter integer HASH_TABLE_SIZE [NUMBER_OF_TABLES-1:0]   = '{2,2,2},
                    parameter logic [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0]  = '{'{2'b01, 2'b01},'{2'b01, 2'b01},'{2'b01, 2'b01}})(
    input   logic clk,
    input   logic reset,
    input   logic [2+DATA_WIDTH + KEY_WIDTH-1:0] data_in,
    input   logic ready_i,
    input   logic valid_i,
    output  wire ready_o,
    output  wire valid_o,
    output  wire [2+DATA_WIDTH + KEY_WIDTH-1:0] data_o,

);

the_table(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .HASH_TABLE_SIZE(HASH_TABLE_SIZE),
    .Q_MATRIX(Q_MATRIX)
)hash_table(
    .clk(clk),
    .reset(reset),
    .key_i(data_i[DATA_WIDTH+KEY_WIDTH-1:DATA_WIDTH])
    .data_i(data_i[DATA_WIDTH-1:0])
    .delete_write_read_i(data_i[DATA_WIDTH+KEY_WIDTH+2:DATA_WIDTH+KEY_WIDTH])
    .ready_i(ready_i),
    .valid_i(valid_i),
    .ready_o(ready_o),
    .valid_o(valid_o),
    .read_data_o(data_o[DATA_WIDTH-1:0])
    .no_deletion_target_o(data_o[DATA_WIDTH]),
    .no_write_space_o(data_o[DATA_WIDTH+1]),
    .no_element_found_o(data_o[DATA_WIDTH+2]),
    .key_already_present_o(data_o[DATA_WIDTH+3])
);
endmodule