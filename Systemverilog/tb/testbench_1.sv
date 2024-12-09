//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.12.2024 16:34:48
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench();

reg clk;
reg reset;
reg [31:0] data_i;
reg ready_i;
reg valid_i;
wire ready_o;
wire valid_o;
wire [31:0] data_o;

axi_wrapper #(
    .KEY_WIDTH(2),
    .DATA_WIDTH(28),
    .NUMBER_OF_TABLES(3),
    .HASH_TABLE_SIZE(96'h000000020000000200000002),
    .Q_MATRIX(12'h0))
the_table ( 
    .clk(clk),
    .reset(reset),
    .data_i(data_i),
    .ready_i(ready_i),
    .valid_i(valid_i),
    .ready_o(ready_o),
    .valid_o(valid_o),
    .data_o(data_o));
    
integer i;    
initial begin
    clk = 0;
    reset = 1;
    #5;
    clk = 1;
    #5;
    clk = 0;
    reset = 0;
    #5;
    for(i = 0; i<100; i = i+1) begin
        clk = ~clk;
        #5;
    end
end

initial begin
    data_i = 0;
    valid_i = 0;
    ready_i = 1;
    #10;
    valid_i = 1;
    data_i = 32'h80000001;
    #50;
end
endmodule
