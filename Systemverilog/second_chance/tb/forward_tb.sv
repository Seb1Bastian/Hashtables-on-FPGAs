module controller_tb;

localparam KEY_WIDTH = 4;
localparam DATA_WIDTH = 8;
localparam NUMBER_OF_TABLES = 3;
localparam BUCKET_SIZE = 2;
localparam FORWARDED_CLOCK_CYCLES = 2;
localparam integer MAX_HASH_ADR_WIDTH = 3;
localparam integer HASH_TABLE_ADR_WIDTH[NUMBER_OF_TABLES-1:0] = {3,3,3};



logic clk;
logic reset;
logic clk_en;
logic [MAX_HASH_ADR_WIDTH-1:0]                    new_hash_adr_i              [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]           new_data_i                  [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]            new_key_i                   [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0]                           new_valid_i                 [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]   new_shift_adr_i             [NUMBER_OF_TABLES-2:0];
logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          new_shift_valid_i           [NUMBER_OF_TABLES-2:0];
logic [MAX_HASH_ADR_WIDTH-1:0]                    forward_hash_adr_i          [NUMBER_OF_TABLES-1:0];
logic [DATA_WIDTH-1:0]                            forward_data_i              [NUMBER_OF_TABLES-1:0];
logic [KEY_WIDTH-1:0]                             forward_key_i               [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0]                           forward_updated_mem_i       [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0]                           forward_valid_i             [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]   forward_shift_hash_adr_i    [NUMBER_OF_TABLES-2:0];
logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          forward_shift_valid_i       [NUMBER_OF_TABLES-2:0];
logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          forward_shift_shift_valid_i [NUMBER_OF_TABLES-1:2];
logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          forward_write_shift_i       [NUMBER_OF_TABLES-2:0];

wire [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]             correct_key_o           [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]            correct_data_o          [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                            correct_is_valid_o      [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]    shift_adr_corrected_o   [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]           shift_valid_corrected_o [NUMBER_OF_TABLES-2:0];



whole_forward_updater #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEY_WIDTH(KEY_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .FORWARDED_CLOCK_CYCLES(FORWARDED_CLOCK_CYCLES),
    .MAX_HASH_ADR_WIDTH(MAX_HASH_ADR_WIDTH),
    .BUCKET_SIZE(BUCKET_SIZE),
    .HASH_TABLE_ADR_WIDTH(HASH_TABLE_ADR_WIDTH)
) uut (
    .clk(clk),
    .clk_en(clk_en),
    .reset(reset),
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
    .forward_shift_shift_valid_i(forward_shift_shift_valid_i), 
    .forward_write_shift_i(forward_write_shift_i),
    
    .correct_key_o(correct_key_o),          
    .correct_data_o(correct_data_o),         
    .correct_is_valid_o(correct_is_valid_o),     
    .shift_adr_corrected_o(shift_adr_corrected_o),  
    .shift_valid_corrected_o(shift_valid_corrected_o)
);

initial begin
    
    clk = 1'b0;
    forever begin
        #5;
        clk = ~clk;
    end
end


initial begin
    clk_en = 1'b1;
    reset = 1'b1;
    #10ns;
    reset = 1'b0;
    new_hash_adr_i              = '{3'b000,3'b000,3'b000};
    new_data_i                  = '{{8'h00,8'h00},{8'h00,8'h00},{8'h00,8'h00}};
    new_key_i                   = '{{4'h0,4'h0},{4'h0,4'h0},{4'h0,4'h0}};
    new_valid_i                 = '{2'b00,2'b00,2'b00};
    new_shift_adr_i             = '{{3'h0,3'h0},{3'h0,3'h0}};
    new_shift_valid_i           = '{{2'b00,2'b00},{2'b00,2'b00}};

    forward_hash_adr_i          = '{3'b000,3'b000,3'b001};
    forward_data_i              = '{8'h00,8'h00,8'h01};
    forward_key_i               = '{4'h00,4'h00,4'h01};
    forward_updated_mem_i       = '{2'b00,2'b00,2'b01};
    forward_valid_i             = '{2'b00,2'b00,2'b01};
    forward_shift_hash_adr_i    = '{{3'h0,3'h0},{3'h0,3'h0}};
    forward_shift_valid_i       = '{{2'b00,2'b00},{2'b00,2'b00}};
    forward_shift_shift_valid_i = '{{2'b00,2'b00}};
    forward_write_shift_i       = '{{2'b00,2'b00},{2'b00,2'b00}};
    #10ns;
    new_hash_adr_i              = '{3'b000,3'b000,3'b001};
    forward_updated_mem_i       = '{2'b00,2'b00,2'b00};
    #10ns;

    #10ns;
    #10ns;
    $finish;
end


endmodule