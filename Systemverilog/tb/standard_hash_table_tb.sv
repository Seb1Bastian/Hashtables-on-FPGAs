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
    .KEY_WIDTH(4),
    .DATA_WIDTH(26),
    .NUMBER_OF_TABLES(3),
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
    data_i = 32'h80000001;  //key = 0
    #10;
    data_i = 32'h98000002;  //key = 6
    #10;
    data_i = 32'h88000003;  //key = 2
    #10;
    data_i = 32'hB4000004;  //key = D
    #10;
    data_i = 32'h8C000005;  //key = 3
    #10;
    //data_i = 32'h00000000;
    //#40;
    data_i = 32'hA0000006;  //key = 8
    #10
    data_i = 32'h84000007;  //key = 1
    #10;
    data_i = 32'h9C000008;  //key = 7
    #50;
    
    
    
    data_i = 32'h40000001;
    #10;
    data_i = 32'h58000002;
    #10;
    data_i = 32'h48000003;
    #10;
    data_i = 32'h74000004;
    #10;
    data_i = 32'h4C000005;
    #10;
    //data_i = 32'h00000000;
    //#40;
    data_i = 32'h60000006;
    #10
    data_i = 32'h44000007;
    #10;
    data_i = 32'h5C000008;
    #50;

    /*data_i = 32'h80000001; //write key = 0, data = 1
    #10;
    data_i = 32'hB0000002; 
    #10;
    data_i = 32'hA0000003;
    #10;
    data_i = 32'h00000000;
    #40;*/
    /*valid_i = 1;
    data_i = 32'h80000001; //write key = 0, data = 1
    #10;
    data_i = 32'h50000000; // read key = 0
    #40;
    data_i = 32'hB0000002; // write key = 3, data = 2
    #10;
    data_i = 32'h70000000; // read key = 3
    #40;
    data_i = 32'hA0000003; // write key = 2, data = 3
    #10;
    data_i = 32'h60000000; // read key = 2
    #40;*/
end
endmodule
