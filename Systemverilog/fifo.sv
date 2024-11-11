module fifo #(
    parameter DATA_WIDTH = 4,
    parameter DEPTH = 2
)(
    input logic clk,
    input logic reset,
    input logic data_valid_i,
    input logic [DATA_WIDTH-1:0] data_i,
    input logic ready_i,

    output wire ready_o,
    output wire [DATA_WIDTH-1:0] data_o,
    output wire data_valid_o
);

logic [DATA_WIDTH-1:0] data_regs [DEPTH-1:0];
logic valid_flags [DEPTH-1:0];
logic counter_write [DEPTH-1:0];
logic counter_read [DEPTH-1:0];
wire can_write;
wire can_read;

always @(posedge clk) begin
    if (reset === 1) begin
        valid_flags <= '{default: '0};
        counter_read <= '{default: '0};
        counter_read[0] <= 1'b1;
        counter_write <= '{default: '0};
        counter_write[0] <= 1'b1;
    end else begin
        if (data_valid_i === 1 && can_write) begin
            for (i = 0; i < DEPTH ; i++ ) begin
                if (counter_write[i] === 1) begin
                    data_regs[i] <= data_i;
                    valid_flags[i] <= 1'b1;
                end
            end
            counter_write <= counter_write[DEPTH-2:1] & counter_write[0];
        end
        if (ready_i === 1 && can_read) begin
            for (i = 0; i < DEPTH ; i++ ) begin
                if (counter_read[i] === 1) begin
                    data_o <= data_regs[i];
                    valid_flags[i] <= 1'b0;
                end
            end
            counter_read <= counter_read[DEPTH-2:1] & counter_read[0];
        end
        
    end
end

assign can_write = |((~valid_flags) && counter_write);
assign can_read = |(valid_flags && counter_read);

    
endmodule