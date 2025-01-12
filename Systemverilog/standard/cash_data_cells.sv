module cash_data_cells #(parameter DATA_WIDTH = 32,
                         parameter MEM_SIZE   = 128)(
    input   wire                                    clk, // Clock Input
    input   wire                                    reset,
    input   logic [DATA_WIDTH-1:0]                  data_in,
    input   logic                                   cs,
    input   logic [MEM_SIZE-1:0]                    we, // Write Enable/Read Enable
    input   logic [MEM_SIZE-1:0]                    del, // Delete Enable

    output  wire [MEM_SIZE-1:0][DATA_WIDTH-1:0]    data_out
); 

genvar i;
generate
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
        cash_data_cell #(
            .DATA_WIDTH(DATA_WIDTH)
        ) data_cell (
            .clk(clk),
            .reset(reset),
            .data_in(data_in),
            .cs(cs),
            .we(we[i]),
            .del(del[i]),
            .data_out(data_out[i])
        );
    end
endgenerate

endmodule