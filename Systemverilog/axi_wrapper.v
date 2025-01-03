module axi_wrapper #(parameter KEY_WIDTH = 4,
                     parameter DATA_WIDTH = 26,
                     parameter NUMBER_OF_TABLES = 3)
( 
    input clk,
    input reset,
    input [2+DATA_WIDTH+KEY_WIDTH-1:0] data_i,
    input ready_i,
    input valid_i,
    output ready_o,
    output valid_o,
    output [2+DATA_WIDTH+KEY_WIDTH-1:0] data_o );


hash_table #( .KEY_WIDTH(KEY_WIDTH),
              .DATA_WIDTH(DATA_WIDTH),
              .NUMBER_OF_TABLES(NUMBER_OF_TABLES)) 
the_table ( 
    .clk(clk),
    .reset(reset),
    .key_in(data_i[DATA_WIDTH+KEY_WIDTH-1:DATA_WIDTH]),
    .data_in(data_i[DATA_WIDTH-1:0]),
    .delete_write_read_i(data_i[DATA_WIDTH+KEY_WIDTH+2-1:DATA_WIDTH+KEY_WIDTH]),
    .ready_i(ready_i),
    .valid_i(valid_i),
    .ready_o(ready_o),
    .valid_o(valid_o),
    .read_data_o(data_o[DATA_WIDTH-1:0]),
    .no_deletion_target_o(data_o[28]),
    .no_write_space_o(data_o[29]),
    .no_element_found_o(data_o[30]),
    .key_already_present_o(data_o[31]));
endmodule