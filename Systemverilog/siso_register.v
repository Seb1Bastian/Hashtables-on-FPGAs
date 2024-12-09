module siso_register_v #(
    parameter DATA_WIDTH = 10,
    parameter DELAY = 1
)
(
    input clk,
    input reset,
    input write_en,
    input [DATA_WIDTH-1:0] data_i,

    output [DATA_WIDTH-1:0] data_o
);

reg [DATA_WIDTH-1:0] shift_registers [DELAY-1:0];

integer i;
initial begin
    for (i = 0; i < DELAY; i = i + 1) begin 
        shift_registers[i] = {DATA_WIDTH{1'b0}};
     end
end

always @(posedge clk ) begin
    if (reset == 1) begin
        for (i = 0; i < DELAY; i = i + 1) begin
            shift_registers[i] = {DATA_WIDTH{1'b0}};
        end
    end else if (write_en == 1) begin
        for (i = DELAY-1; i > 0 ; i = i-1) begin
            shift_registers[i] = shift_registers[i-1];
        end
        shift_registers[0] = data_i;
    end
end

assign data_o = shift_registers[DELAY-1];



endmodule