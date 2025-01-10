module cash_key_cells #(parameter KEY_WIDTH = 32,
                        parameter MEM_SIZE  = 128)(
    input   wire                                clk, // Clock Input
    input   wire                                reset,
    input   logic [KEY_WIDTH-1:0]               key_write_i,
    input   logic [KEY_WIDTH-1:0]               key_read_i,
    input   logic                               cs, // Chip Select
    input   logic [MEM_SIZE-1:0]                we, // Write Enable/Read Enable
    input   logic [MEM_SIZE-1:0]                del, // Delete Enable

    output  wire [MEM_SIZE-1:0]                 empty,
    output  wire [MEM_SIZE-1:0]                 fits_read,
    output  wire [MEM_SIZE-1:0]                 fits_write
); 

genvar i;
generate
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
        cash_key_cell #(
            .KEY_WIDTH(KEY_WIDTH)
        ) key_cell (
            .clk(clk),
            .reset(reset),
            .key_write_i(key_write_i),
            .key_read_i(key_read_i),
            .cs(cs),
            .we(we[i]),
            .del(del[i]),
            .empty(empty[i]),
            .fits_read(fits_read[i]),
            .fits_write(fits_write[i])
        );
    end
endgenerate

endmodule