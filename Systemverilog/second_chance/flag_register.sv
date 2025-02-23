module flag_register #(
    parameter MAX_ADR_WIDTH = 10,
    parameter ADR_WIDTH = 10,
    parameter BUCKET_SIZE = 1,
    parameter USE_MORE_BCLK = 1
)
(
    input logic                                     clk,
    input logic                                     reset,
    input logic                                     ready_i,
    input logic [MAX_ADR_WIDTH-1:0]                 read_adr_0,
    input logic [BUCKET_SIZE-1:0][MAX_ADR_WIDTH-1:0]read_adr_1,
    input logic [BUCKET_SIZE-1:0][MAX_ADR_WIDTH-1:0]read_adr_2,
    input logic [MAX_ADR_WIDTH-1:0]                 write_adr,
    input logic                                     write_en,
    input logic [BUCKET_SIZE-1:0]                   write_is_valid,
    
    output logic [BUCKET_SIZE-1:0]                  flag_out_0,
    output logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0] flag_out_1,
    output logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0] flag_out_2
);

simple_dual_one_clock 
    #(.MEM_SIZE(ADR_WIDTH),
        .DATA_WIDTH(BUCKET_SIZE)
)
block_ram_0(
    .clk(clk),
    .ena(ready_i),     //probably needs not to be changed
    .enb(ready_i),     //probably needs not to be changed
    .wea((write_en)),
    .addra(write_adr[ADR_WIDTH-1:0]),
    .addrb(read_adr_0[ADR_WIDTH-1:0]),
    .dia(write_is_valid),
    .dob(flag_out_0)
);

genvar i;
generate
    for (i = 0; i < BUCKET_SIZE ; i = i + 1 ) begin
        simple_dual_one_clock 
            #(.MEM_SIZE(ADR_WIDTH),
              .DATA_WIDTH(BUCKET_SIZE)
        )block_ram_1(
            .clk(clk),
            .ena(ready_i),
            .enb(ready_i),
            .wea(write_en),
            .addra(write_adr[ADR_WIDTH-1:0]),
            .addrb(read_adr_1[i][ADR_WIDTH-1:0]),
            .dia(write_is_valid),
            .dob(flag_out_1[i])
        );
    end 
endgenerate

generate
    for (i = 0; i < BUCKET_SIZE ; i = i + 1 ) begin
        simple_dual_one_clock 
            #(.MEM_SIZE(ADR_WIDTH),
              .DATA_WIDTH(BUCKET_SIZE)
        )block_ram_2(
            .clk(clk),
            .ena(ready_i),
            .enb(ready_i),
            .wea(write_en),
            .addra(write_adr[ADR_WIDTH-1:0]),
            .addrb(read_adr_2[i][ADR_WIDTH-1:0]),
            .dia(write_is_valid),
            .dob(flag_out_2[i])
        );
    end
endgenerate
endmodule