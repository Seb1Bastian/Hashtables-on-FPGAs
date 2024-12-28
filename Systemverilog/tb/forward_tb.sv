`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.12.2024 00:26:40
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


module testbench(

    );
localparam DATA_WIDTH = 4;
localparam KEY_WIDTH = 2;
localparam NUMBER_OF_TABLES = 3;
localparam FORWARDED_CLOCK_CYCLES = 2;
localparam MAX_HASH_ADR_WIDTH = 2;
localparam integer HASH_TABLE_ADR_WIDTH[NUMBER_OF_TABLES-1:0] = {2,2,2};


logic clk;
logic reset;
logic clk_en;
logic [MAX_HASH_ADR_WIDTH-1:0]  new_hash_adr_i              [NUMBER_OF_TABLES-1:0];
logic [DATA_WIDTH-1:0]          new_data_i                  [NUMBER_OF_TABLES-1:0];
logic [KEY_WIDTH-1:0]           new_key_i                   [NUMBER_OF_TABLES-1:0];
logic                           new_valid_i                 [NUMBER_OF_TABLES-1:0];
logic [MAX_HASH_ADR_WIDTH-1:0]  new_shift_adr_i             [NUMBER_OF_TABLES-2:0];
logic                           new_shift_valid_i           [NUMBER_OF_TABLES-2:0];  // von i nach i+;
logic [MAX_HASH_ADR_WIDTH-1:0]  forward_hash_adr_i          [NUMBER_OF_TABLES-1:0];
logic [DATA_WIDTH-1:0]          forward_data_i              [NUMBER_OF_TABLES-1:0];
logic [KEY_WIDTH-1:0]           forward_key_i               [NUMBER_OF_TABLES-1:0];
logic                           forward_updated_mem_i       [NUMBER_OF_TABLES-1:0];
logic                           forward_valid_i             [NUMBER_OF_TABLES-1:0];
logic [MAX_HASH_ADR_WIDTH-1:0]  forward_shift_hash_adr_i    [NUMBER_OF_TABLES-2:0];
logic                           forward_shift_valid_i       [NUMBER_OF_TABLES-2:0];


wire [KEY_WIDTH-1:0]            correct_key_o               [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]           correct_data_o              [NUMBER_OF_TABLES-1:0];
wire                            correct_is_valid_o          [NUMBER_OF_TABLES-1:0];
wire [MAX_HASH_ADR_WIDTH-1:0]   shift_adr_corrected_o       [NUMBER_OF_TABLES-2:0];
wire                            shift_valid_corrected_o     [NUMBER_OF_TABLES-2:0];




whole_forward_updater #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEY_WIDTH(KEY_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .FORWARDED_CLOCK_CYCLES(FORWARDED_CLOCK_CYCLES),
    .MAX_HASH_ADR_WIDTH(MAX_HASH_ADR_WIDTH),
    .HASH_TABLE_ADR_WIDTH(HASH_TABLE_ADR_WIDTH)
) uut (
    .clk(clk),
    .reset(reset),
    .clk_en(clk_en),
    .new_hash_adr_i(new_hash_adr_i),
    .new_data_i(new_data_i),
    .new_key_i(new_key_i),
    .new_valid_i(new_valid_i),
    .new_shift_adr_i(new_shift_adr_i),
    .new_shift_valid_i(new_shift_valid_i),
    .forward_hash_adr_i(forward_hash_adr_i),
    .forward_data_i(forward_data_i),
    .forward_key_i(forward_key_i),
    .forward_updated_mem_i(forward_updated_mem_i),
    .forward_valid_i(forward_valid_i),
    .forward_shift_hash_adr_i(forward_shift_hash_adr_i),
    .forward_shift_valid_i(forward_shift_valid_i),
//  .c [MAX_HASH_ADR_WIDTH-1:0] forward_next_mem_hash_adr_i(forward_next_mem_hash_adr_i),
//  .c forward_next_mem_updated_i(forward_next_mem_updated_i),
//  .c forward_next_mem_valid_i(forward_next_mem_valid_i),
    .correct_key_o(correct_key_o),
    .correct_data_o(correct_data_o),
    .correct_is_valid_o(correct_is_valid_o),
    .shift_adr_corrected_o(shift_adr_corrected_o),
    .shift_valid_corrected_o(shift_valid_corrected_o)
);


initial begin
    clk = 0;
    reset = 1;
    #5;
    clk = 1;
    #5;
    clk = 0;
    reset = 0;
    #5;
    for(int i = 0; i<100; i = i+1) begin
        clk = ~clk;
        #5;
    end
end

initial begin
    clk_en = 1;
    new_hash_adr_i = {0,0,0};
    new_data_i = {0,0,0} ;
    new_key_i = {0,0,0};
    new_valid_i = {0,0,0};
    new_shift_adr_i = {0,0};
    new_shift_valid_i = {0,0};
    forward_hash_adr_i = {0,0,0};
    forward_data_i = {0,0,0};
    forward_key_i = {0,0,0};
    forward_updated_mem_i = {0,0,0} ;
    forward_valid_i = {0,0,0};
    forward_shift_hash_adr_i = {0,0};
    forward_shift_valid_i = {0,0};
    #10;
    new_hash_adr_i = {0,0,0};
    new_data_i = {3,2,1} ;
    new_key_i = {3,2,1};
    new_valid_i = {1,0,1};
    new_shift_adr_i = {1,0};
    new_shift_valid_i = {0,0};
    forward_hash_adr_i = {0,0,0};
    forward_data_i = {0,0,0};
    forward_key_i = {0,0,0};
    forward_updated_mem_i = {0,0,0} ;
    forward_valid_i = {0,0,0};
    forward_shift_hash_adr_i = {0,0};
    forward_shift_valid_i = {0,0};
    #10;
    new_hash_adr_i = {0,0,0};
    new_data_i = {3,2,1} ;
    new_key_i = {3,2,1};
    new_valid_i = {0,0,0};
    new_shift_adr_i = {0,1};
    new_shift_valid_i = {0,0};
    forward_hash_adr_i = {0,0,1};
    forward_data_i = {0,0,3};
    forward_key_i = {0,0,3};
    forward_updated_mem_i = {0,0,1} ;
    forward_valid_i = {0,0,1};
    forward_shift_hash_adr_i = {0,0};
    forward_shift_valid_i = {0,0};
    #10;
    new_hash_adr_i = {0,0,1};
    new_data_i = {3,2,1} ;
    new_key_i = {3,2,1};
    new_valid_i = {0,0,0};
    new_shift_adr_i = {0,1};
    new_shift_valid_i = {0,0};
    forward_hash_adr_i = {0,0,1};
    forward_data_i = {0,0,3};
    forward_key_i = {0,0,3};
    forward_updated_mem_i = {0,0,1} ;
    forward_valid_i = {0,0,1};
    forward_shift_hash_adr_i = {0,0};
    forward_shift_valid_i = {0,0};
    #10;
    new_hash_adr_i = {0,0,1};
    new_data_i = {3,2,1} ;
    new_key_i = {3,2,1};
    new_valid_i = {0,0,0};
    new_shift_adr_i = {0,1};
    new_shift_valid_i = {0,0};
    forward_hash_adr_i = {0,0,1};
    forward_data_i = {0,0,3};
    forward_key_i = {0,0,3};
    forward_updated_mem_i = {0,0,1} ;
    forward_valid_i = {0,0,0};
    forward_shift_hash_adr_i = {0,0};
    forward_shift_valid_i = {0,0};
end

endmodule