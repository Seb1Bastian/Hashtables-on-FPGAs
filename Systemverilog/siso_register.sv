module siso_register #(
    parameter DATA_WIDTH = 10,
    parameter DELAY = 1
)
(
    input logic clk,
    input logic reset,
    input logic write_en,
    input logic [DATA_WIDTH-1:0] data_i,

    output wire [DATA_WIDTH-1:0] data_o
);

logic [DATA_WIDTH-1:0] shift_registers [DELAY-1:0];

initial begin
    shift_registers <= '{default: '0};
end

always @(posedge clk ) begin
    if (reset == 1) begin
        shift_registers <= '{default: '0};
    end else if (write_en == 1) begin
        for (int i = DELAY-1; i > 0 ; i--) begin
            shift_registers[i] = shift_registers[i-1];
        end
        shift_registers[0] = data_i;
    end
end

assign data_o = shift_registers[DELAY-1];



endmodule