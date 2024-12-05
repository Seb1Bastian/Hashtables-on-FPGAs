module flag_register #(
    parameter SIZE = 10
)
(
    input logic clk,
    input logic reset,
    input logic [SIZE-1:0] read_adr_0,
    input logic [SIZE-1:0] read_adr_1,
    input logic [SIZE-1:0] write_adr,
    input logic write_en,
    input logic write_is_valid,
    
    output logic flag_out_0,
    output logic flag_out_1
);

logic valid_flags [(2**SIZE)-1:0];

initial begin
    valid_flags <= '{default: 1'b0};
end

always @(posedge clk) begin
    if (reset == 1) begin
        valid_flags <= '{default: '0};
    end else if (write_en) begin
        valid_flags[write_adr] <= write_is_valid;
    end
end
always @(posedge clk) begin
    if (reset == 1) begin
        flag_out_0 <= 1'b0;
        flag_out_1 <= 1'b0;
    end else begin
        flag_out_0 = valid_flags[read_adr_0];
        flag_out_1 = valid_flags[read_adr_1];
    end
end
   
endmodule