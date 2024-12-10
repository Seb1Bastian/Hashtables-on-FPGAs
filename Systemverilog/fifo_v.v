module fifo #(parameter DATA_WIDTH = 8, parameter DEPTH = 16) (
    input wire clk,
    input wire reset,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output wire empty,
    output wire full
);

// Interne Signale
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
reg [3:0] wr_ptr = 0; // Schreibzeiger
reg [3:0] rd_ptr = 0; // Lesezeiger
reg [4:0] count = 0;  // Zähler für die Anzahl der gespeicherten Daten

// Daten schreiben
always @(posedge clk) begin
    if (reset) begin
        wr_ptr = 0;
        rd_ptr = 0;
        count = 0;
    end else begin
        if (wr_en && !rd_en && !full) begin
            mem[wr_ptr] = data_in;
            wr_ptr = wr_ptr + 1;
            count = count + 1;
         end else if (!wr_en && rd_en && !empty) begin
            rd_ptr = rd_ptr + 1;
            count = count - 1;
         end else if (wr_en && rd_en && !empty) begin
            mem[wr_ptr] = data_in;
            wr_ptr = wr_ptr + 1;
            rd_ptr = rd_ptr + 1;
         end else if (wr_en && rd_en && empty) begin
            mem[wr_ptr] = data_in;
            wr_ptr = wr_ptr + 1;
            count = count + 1;
         end
    end
end

always @ (rd_ptr or mem) begin
   data_out = mem[rd_ptr];
end
assign empty = (count == 0);
assign full = (count == DEPTH);

endmodule

