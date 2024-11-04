// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v

module simple_dual_one_clock #(
    parameter MEM_SIZE = 5,
    parameter DATA_WIDTH = 32
)
(clk,ena,enb,wea,addra,addrb,dia,dob);

input clk,ena,enb,wea;
input [MEM_SIZE-1:0] addra,addrb;
input [DATA_WIDTH-1:0] dia;
output [DATA_WIDTH-1:0] dob;
reg [DATA_WIDTH-1:0] ram [(2**MEM_SIZE)-1:0];
reg [DATA_WIDTH-1:0] doa,dob;

initial begin
    ram <= '{default: '0};
    dob <= '{default: '0};
end

always @(posedge clk) begin
if (ena) begin
if (wea)
ram[addra] <= dia;
end
end

always @(posedge clk) begin
if (enb)
dob <= ram[addrb];
end

endmodule