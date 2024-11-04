module hash_table_tb;

    localparam KEY_WIDTH = 2;
    localparam DATA_WIDTH = 8;
    localparam NUMBER_OF_TABLES = 3;
    localparam integer HASH_TABLE_SIZE [NUMBER_OF_TABLES-1:0] = {2,2,2};
    localparam logic [KEY_WIDTH-1:0] Q_MATRIX [NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0] = '{'{2'b01, 2'b01},'{2'b10, 2'b10},'{2'b11, 2'b11}};


    logic clk;
    logic reset;
    logic [KEY_WIDTH-1:0] key_in;
    logic [DATA_WIDTH-1:0] data_in;
    logic [1:0] delete_write_read_i;
    wire [DATA_WIDTH-1:0] read_data_o;
    wire no_deletion_target_o;
    wire no_write_space_o;
    wire no_element_found_o;

    hash_table #(.KEY_WIDTH(KEY_WIDTH),
                       .DATA_WIDTH(DATA_WIDTH),
                       .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
                       .HASH_TABLE_SIZE(HASH_TABLE_SIZE),
                       .Q_MATRIX(Q_MATRIX)
    ) uut (
        .clk(clk),
        .reset(reset),
        .key_in(key_in),
        .data_in(data_in),
        .delete_write_read_i(delete_write_read_i),
        .read_data_o(read_data_o),
        .no_deletion_target_o(no_deletion_target_o),
        .no_write_space_o(no_write_space_o),
        .no_element_found_o(no_element_found_o)
    );


// Test stimulus
    initial begin
        $dumpvars(0,hash_table_tb);
        // Initialize signals
        clk = 0;
        reset = 0;
        key_in = 2'b00;
        data_in = 8'hFF;
        delete_write_read_i = 2'b10;
        #5;
        clk = 1;
        #5;
        clk = 0;
        key_in = 2'b00;
        data_in = 8'hFF;
        delete_write_read_i = 2'b01;
        #5;
        clk = 1;
        #5;
        clk = 0;
        #5;
        clk = 1;
        #5;
        clk = 0;
        #5;
        clk = 1;
        #5;
        clk = 0;
        #5;
        clk = 1;
        #5;
        clk = 0;
        /*#5;
        clk = 1;
        #5;
        key_in = 2'b01;
        clk = 0;
        #5;
        clk = 1;
        #5;
        key_in = 2'b10;
        clk = 0;
        #5;
        clk = 1;
        #5;
        key_in = 2'b11;
        clk = 0;
        #5;
        clk = 1;
        #5;*/
        // Finish simulation
        $finish;
    end


endmodule