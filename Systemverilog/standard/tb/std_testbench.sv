module testbench_just_read();

localparam KEY_WIDTH = 32;
localparam DATA_WIDTH = 30;
localparam NUMBER_OF_TABLES = 8;
localparam HASH_TABLE_MAX_SIZE = 11;

reg clk;
reg reset;
reg [2+KEY_WIDTH+DATA_WIDTH-1:0] data_i;
reg ready_i;
reg valid_i;
wire ready_o;
wire valid_o;
wire keep_o;
wire last_o;
wire [2+KEY_WIDTH+DATA_WIDTH-1:0] data_o;

wire [KEY_WIDTH-1:0]                                    logic_matrix [NUMBER_OF_TABLES-1:0][HASH_TABLE_MAX_SIZE-1:0];
wire [NUMBER_OF_TABLES*HASH_TABLE_MAX_SIZE*KEY_WIDTH-1:0]    matrixes_o;

axi_wrapper #(
    .KEY_WIDTH(32),
    .DATA_WIDTH(30),
    .NUMBER_OF_TABLES(8),
    .KEEP_WIDTH(1),
    .HASH_TABLE_MAX_SIZE(11),
    .BUCKET_SIZE(2))
the_table ( 
    .clk(clk),
    .reset(reset),
    .data_i(data_i),
    .ready_i(ready_i),
    .valid_i(valid_i),
    .keep_i(0),
    .last_i(0),
    .matrixes_i(matrixes_o),
    .ready_o(ready_o),
    .valid_o(valid_o),
    .keep_o(keep_o),
    .last_o(last_o),
    .data_o(data_o));
    
    
matrix_wrapper #(
    .KEY_WIDTH(32),
    .NUMBER_OF_TABLES(8),
    .HASH_ADR_WIDTH(11))
matrix_wrap (
    .matrixes_o(matrixes_o));
    
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
    valid_i = 1;
    ready_i = 1;
    data_i = {2'b10, 32'b000001, 30'd1}; //this write is during a reset
    #10;
    data_i = {2'b01, 32'b000001, 30'd0};
    #10;
    data_i = {2'b10, 32'b000001, 30'd1};
    #10;
    data_i = {2'b01, 32'b000001, 30'd0};
    #10;
    data_i = {2'b10, 32'd2, 30'd2};
    #10;
    data_i = {2'b10, 32'd3, 30'd3};
    #10;
    data_i = {2'b10, 32'd4, 30'd4};
    #10;
    data_i = {2'b10, 32'd5, 30'd5};
    #10;
    data_i = {2'b10, 32'd6, 30'd6};
    #10;
    data_i = {2'b10, 32'd7, 30'd7};
    #10;
    
    data_i = {2'b01, 32'd2, 30'd0};
    #10;
    data_i = {2'b01, 32'd3, 30'd0};
    #10;
    data_i = {2'b01, 32'd4, 30'd0};
    #10;
    data_i = {2'b01, 32'd5, 30'd0};
    #10;
    data_i = {2'b01, 32'd6, 30'd0};
    #10;
    data_i = {2'b01, 32'd7, 30'd0};
    #30;
    
    data_i = {2'b10, 32'd8, 30'd8};
    #10;
    data_i = {2'b11, 32'd8, 30'd0};
    #10;
    data_i = {2'b01, 32'd8, 30'd0};
    #30;
    
    data_i = {2'b11, 32'd2, 30'd0};
    #10;
    data_i = {2'b11, 32'd3, 30'd0};
    #10;
    data_i = {2'b11, 32'd4, 30'd0};
    #10;
    data_i = {2'b11, 32'd5, 30'd0};
    #10;
    data_i = {2'b11, 32'd6, 30'd0};
    #10;
    data_i = {2'b11, 32'd7, 30'd0};
    #10;
    data_i = {2'b01, 32'd2, 30'd0};
    #10;
    data_i = {2'b01, 32'd3, 30'd0};
    #10;
    data_i = {2'b01, 32'd4, 30'd0};
    #10;
    data_i = {2'b01, 32'd5, 30'd0};
    #10;
    data_i = {2'b01, 32'd6, 30'd0};
    #10;
    data_i = {2'b01, 32'd7, 30'd0};
    #10;
    /*
    valid_i = 1;
    data_i = {2'b10, 32'b000000, 30'd1};
    #10;
    data_i = {2'b10, 32'b001000, 30'ha};
    #10;
    data_i = {2'b10, 32'b010000, 30'd3};
    #10;
    data_i = {2'b10, 32'b011000, 30'd4};
    #10;
    data_i = {2'b10, 32'b100000, 30'd5};
    #10;
    data_i = {2'b10, 32'b101000, 30'd6};
    #10;
    data_i = {2'b10, 32'b001010, 30'hb};
    #10;
    data_i = {2'b10, 32'b000100, 30'd7};

    #10;
    data_i = {2'b11, 32'b001000, 30'd0};
    #10;
    data_i = {2'b10, 32'b001110, 30'd2};

    #10;
    data_i = {2'b10, 32'b110000, 30'd8};
    #10;
    data_i = {2'b10, 32'b000010, 30'd9};

    #10;

    data_i = {2'b01, 32'b000010, 30'hff};
    #10;
    data_i = {2'b01, 32'b110000, 30'hff};
    #10;
    data_i = {2'b01, 32'b000100, 30'hff};
    #10;
    data_i = {2'b01, 32'b101000, 30'hff};
    #10;
    data_i = {2'b01, 32'b100000, 30'hff};
    #10;
    data_i = {2'b01, 32'b011000, 30'hff};
    #10;
    data_i = {2'b01, 32'b010000, 30'hff};
    #10;
    data_i = {2'b01, 32'b001110, 30'hff};
    #10;
    data_i = {2'b01, 32'b000000, 30'hff};
    
    #10;*/


    #50;
    $finish;    
end
endmodule
