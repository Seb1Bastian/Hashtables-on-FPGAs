module flag_register #(
    parameter SIZE = 10,
    parameter BUCKET_SIZE = 1,
    parameter USE_MORE_BCLK = 1
)
(
    input logic                     clk,
    input logic                     reset,
    input logic                     ready_i,
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

generate
    if (USE_MORE_BCLK == 1) begin
        simple_dual_one_clock 
            #(.MEM_SIZE(SIZE),
              .DATA_WIDTH(BUCKET_SIZE)
        )
        block_ram_0(
            .clk(clk),
            .ena(ready_i),     //probably needs not to be changed
            .enb(ready_i),     //probably needs not to be changed
            .wea((write_en)),
            .addra(write_adr),
            .addrb(read_adr_0),
            .dia(write_is_valid),
            .dob(flag_out_0)
        );

        simple_dual_one_clock 
            #(.MEM_SIZE(SIZE),
              .DATA_WIDTH(BUCKET_SIZE)
        )
        block_ram_1(
            .clk(clk),
            .ena(ready_i),     //probably needs not to be changed
            .enb(ready_i),     //probably needs not to be changed
            .wea((write_en)),
            .addra(write_adr),
            .addrb(read_adr_1),
            .dia(write_is_valid),
            .dob(flag_out_1)
        );

        simple_dual_one_clock 
            #(.MEM_SIZE(SIZE),
              .DATA_WIDTH(BUCKET_SIZE)
        )
        block_ram_2(
            .clk(clk),
            .ena(ready_i),     //probably needs not to be changed
            .enb(ready_i),     //probably needs not to be changed
            .wea((write_en)),
            .addra(write_adr),
            .addrb(read_adr_2),
            .dia(write_is_valid),
            .dob(flag_out_2)
        );
    end else begin
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
    end
endgenerate;
   
endmodule