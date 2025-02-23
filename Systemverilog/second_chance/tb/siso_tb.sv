module siso_tb;

localparam DATA_WIDTH = 2;
localparam DELAY = 1;



logic clk;
logic reset;
logic write_en;
logic [DATA_WIDTH-1:0][DATA_WIDTH-1:0] data_i;
wire [DATA_WIDTH*DATA_WIDTH-1:0] data_inbetween;
wire [DATA_WIDTH-1:0][DATA_WIDTH-1:0] data_o;



siso_register #(
    .DATA_WIDTH(DATA_WIDTH*DATA_WIDTH),
    .DELAY(DELAY)
) uut (
    .clk(clk),
    .reset(reset),
    .write_en(write_en),
    .data_i(data_i),
    .data_o(data_inbetween)
);
assign data_o = data_inbetween;

initial begin
    
    clk = 1'b0;
    forever begin
        #5ns;
        clk = ~clk;
    end
end


initial begin
    reset = 1'b1;
    #10ns;
    reset = 1'b0;
    write_en  = 1'b1;
    data_i = '{2'b11, 2'b00};
    #10ns;

    #10ns;
    $finish;
end


endmodule