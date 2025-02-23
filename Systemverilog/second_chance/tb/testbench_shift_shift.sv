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


module testbench_sift_shift();

reg clk;
reg reset;
reg [31:0] data_i;
reg ready_i;
reg valid_i;
wire ready_o;
wire valid_o;
wire [31:0] data_o;

axi_wrapper #(
    .KEY_WIDTH(6),
    .DATA_WIDTH(24),
    .NUMBER_OF_TABLES(4),
    .BUCKET_SIZE(2))
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
    data_i = {2'b10, 6'b000000, 24'd1};
    #10;
    data_i = {2'b10, 6'b001000, 24'ha};
    #10;
    data_i = {2'b10, 6'b010000, 24'd3};
    #10;
    data_i = {2'b10, 6'b011000, 24'd4};
    #10;
    data_i = {2'b10, 6'b100000, 24'd5};
    #10;
    data_i = {2'b10, 6'b101000, 24'd6};
    #10;
    data_i = {2'b10, 6'b001010, 24'hb};
    #10;
    data_i = {2'b10, 6'b000100, 24'd7};

    #10;
    data_i = {2'b11, 6'b001000, 24'd0};
    #10;
    data_i = {2'b10, 6'b001110, 24'd2};

    #10;
    data_i = {2'b10, 6'b110000, 24'd8};
    #10;
    data_i = {2'b10, 6'b000010, 24'd9};

    #10;

    data_i = {2'b01, 6'b000010, 24'hff};
    #10;
    data_i = {2'b01, 6'b110000, 24'hff};
    #10;
    data_i = {2'b01, 6'b000100, 24'hff};
    #10;
    data_i = {2'b01, 6'b101000, 24'hff};
    #10;
    data_i = {2'b01, 6'b100000, 24'hff};
    #10;
    data_i = {2'b01, 6'b011000, 24'hff};
    #10;
    data_i = {2'b01, 6'b010000, 24'hff};
    #10;
    data_i = {2'b01, 6'b001110, 24'hff};
    #10;
    data_i = {2'b01, 6'b000000, 24'hff};
    
    #10;


    #50;
    $finish;    
end
endmodule
