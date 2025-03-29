module axi_wrapper #(parameter DATA_WIDTH = 64)
( 
    input clk,
    input reset,
    input [DATA_WIDTH-1:0] data_i,
    input ready_i,
    input valid_i,
    input last_i,
    input [7:0] keep_i,
    output ready_o,
    output valid_o,
    output last_o,
    output [7:0] keep_o,
    output [DATA_WIDTH-1:0] data_o );
    
wire [DATA_WIDTH-1:0] inbetween_data;


hash_table #(.DATA_WIDTH(DATA_WIDTH)) 
the_table ( 
    .clk(clk),
    .reset(reset),
    .data_in(data_i[DATA_WIDTH-1:0]),
    .ready_i(ready_i),
    .valid_i(valid_i),
    .last_i(last_i),
    .keep_i(keep_i),
    .ready_o(ready_o),
    .valid_o(valid_o),
    .last_o(last_o),
    .keep_o(keep_o),
    .read_data_o(inbetween_data[DATA_WIDTH-1:0]));
    
assign data_o = inbetween_data;
endmodule