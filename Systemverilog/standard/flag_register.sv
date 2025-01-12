module flag_register #(
    parameter SIZE = 10,
    parameter BUCKET_SIZE = 1
)
(
    input logic                     clk,
    input logic                     reset,
    input logic [SIZE-1:0]          read_adr_0,
    input logic [SIZE-1:0]          read_adr_1,
    input logic [SIZE-1:0]          read_adr_2,
    input logic [SIZE-1:0]          write_adr,
    input logic                     write_en,
    input logic [BUCKET_SIZE-1:0]   write_is_valid,
    
    output logic [BUCKET_SIZE-1:0] flag_out_0,
    output logic [BUCKET_SIZE-1:0] flag_out_1,
    output logic [BUCKET_SIZE-1:0] flag_out_2
);

logic [BUCKET_SIZE-1:0] valid_flags [(2**SIZE)-1:0];

always @(posedge clk) begin
    if (reset == 1) begin
        valid_flags <= '{default: '0};
    end else if (write_en) begin
        valid_flags[write_adr] <= write_is_valid;
    end
end
always @(posedge clk) begin
    if (reset == 1) begin
        flag_out_0 <= '{default: '0};
        flag_out_1 <= '{default: '0};
        flag_out_2 <= '{default: '0};
    end else begin
        flag_out_0 <= valid_flags[read_adr_0];
        flag_out_1 <= valid_flags[read_adr_1];
        flag_out_2 <= valid_flags[read_adr_2];
    end
end
   
endmodule