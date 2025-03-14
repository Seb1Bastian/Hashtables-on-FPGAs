module controller (
    input   logic [1:0]                     delete_write_read_i,      // 00 = do nothing | 01 = read | 10 = write | 11 = delete
    output  wire                            valid_o
);
localparam logic [1:0] NOTHING_OPERATION = 2'b00;
localparam logic [1:0] READ_OPERATION    = 2'b01;
localparam logic [1:0] WRITE_OPERATION   = 2'b10;
localparam logic [1:0] DELTE_OPERATION   = 2'b11;

assign valid_o = (delete_write_read_i == NOTHING_OPERATION) ? 1'b0 : 1'b1;

endmodule