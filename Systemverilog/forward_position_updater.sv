module forward_position_updater #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2,
    parameter FORWARDED_CLOCK_CYCLES = 2,
    parameter HASH_ADR_WIDTH = 2
)(
    input logic clk,
    input logic reset,
    input logic clk_en,
    input logic [HASH_ADR_WIDTH-1:0] new_hash_adr_i,
    input logic [DATA_WIDTH-1:0] new_data_i,
    input logic [KEY_WIDTH-1:0] new_key_i,
    input logic new_valid_i,

    input logic [HASH_ADR_WIDTH-1:0] forward_hash_adr_i,
    input logic [DATA_WIDTH-1:0] forward_data_i,
    input logic [KEY_WIDTH-1:0] forward_key_i,
    input logic forward_updated_mem_i,
    input logic forward_valid_i,

    output wire [KEY_WIDTH-1:0] correct_key,
    output wire [DATA_WIDTH-1:0] correct_data,
    output wire correct_is_valid,
);

logic [HASH_ADR_WIDTH-1:0] hash_regs [FORWARDED_CLOCK_CYCLES-1:0];
logic [KEY_WIDTH-1:0] key_regs [FORWARDED_CLOCK_CYCLES-1:0];
logic [DATA_WIDTH-1:0] data_regs [FORWARDED_CLOCK_CYCLES-1:0];
logic updated_mem_regs [FORWARDED_CLOCK_CYCLES-1:0];
logic valid_regs [FORWARDED_CLOCK_CYCLES-1:0];

wire [FORWARDED_CLOCK_CYCLES-1:0] same_hash_adr;

wire [KEY_WIDTH-1:0] selected_key [FORWARDED_CLOCK_CYCLES-1:0];
wire [DATA_WIDTH-1:0] selected_data [FORWARDED_CLOCK_CYCLES-1:0];
wire selected_valid [FORWARDED_CLOCK_CYCLES-1:0];

genvar i;
always @(posedge clk) begin
    if (reset == 1) begin
        hash_regs <= '{default: '0};
        key_regs <= '{default: '0};
        data_regs <= '{default: '0};
        updated_mem_regs <= '{default: '0};
        valid_regs <= '{default: '0};
    end else begin
        hash_regs[FORWARDED_CLOCK_CYCLES-1] = forward_hash_adr_i;
        key_regs[FORWARDED_CLOCK_CYCLES-1] = forward_key_i;
        data_regs[FORWARDED_CLOCK_CYCLES-1] = forward_data_i;
        updated_mem_regs[FORWARDED_CLOCK_CYCLES-1] = forward_updated_mem_i;
        valid_regs[FORWARDED_CLOCK_CYCLES-1] = forward_valid_i;
        for (i = FORWARDED_CLOCK_CYCLES-2; i > 0 ; i = i + 1 ) begin
            hash_regs[i] = hash_regs[i+1];
            key_regs[i] = key_regs[i+1];
            data_regs[i] = data_regs[i+1];
            updated_mem_regs[i] = updated_mem_regs[i+1];
            valid_regs[i] = valid_regs[i+1];
        end
        
    end
end

generate
    for(i = 0; i<FORWARDED_CLOCK_CYCLES; i = i+1) begin
        same_hash_adr[i] = (hash_regs[i] == new_hash_adr_i) ? 1'b1 : 1'b0;
    end
endgenerate

generate
    assign selected_key[0]   = (same_hash_adr[0] == 1'b1 && updated_mem_reg[0] == 1'b1 ) ? key_regs[i]   : new_key_i;
    assign selected_data[0]  = (same_hash_adr[0] == 1'b1 && updated_mem_reg[0] == 1'b1 ) ? data_regs[i]  : new_key_i;
    assign selected_valid[0] = (same_hash_adr[0] == 1'b1 && updated_mem_reg[0] == 1'b1 ) ? valid_regs[i] : new_valid_i;
    for(i = 1; i<FORWARDED_CLOCK_CYCLES; i = i+1) begin
        assign selected_key[i]   = (same_hash_adr[i] == 1'b1 && updated_mem_reg[i] == 1'b1 ) ? key_regs[i]   : selected_key[i-1];
        assign selected_data[i]  = (same_hash_adr[i] == 1'b1 && updated_mem_reg[i] == 1'b1 ) ? data_regs[i]  : selected_data[i-1];
        assign selected_valid[i] = (same_hash_adr[i] == 1'b1 && updated_mem_reg[i] == 1'b1 ) ? valid_regs[i] : selected_valid[i-1];
    end
endgenerate

assign correct_key      = selected_key[FORWARDED_CLOCK_CYCLES-1];
assign correct_data     = selected_data[FORWARDED_CLOCK_CYCLES-1];
assign correct_is_valid = selected_valid[FORWARDED_CLOCK_CYCLES-1];
    
endmodule