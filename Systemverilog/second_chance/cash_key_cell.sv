module cash_key_cell #(parameter KEY_WIDTH = 32)(
    input   wire                  clk      , // Clock Input
    input   wire                  reset,
    input   logic [KEY_WIDTH-1:0] key_write_i,
    input   logic [KEY_WIDTH-1:0] key_read_i,
    input   logic                  cs       , // Chip Select
    input   logic                  we       , // Write Enable/Read Enable
    input   logic                  del      , // Delete Enable

    output  wire                   empty,
    output  wire                   fits_write,
    output  wire                   fits_read
); 
//--------------Internal variables---------------- 
logic [KEY_WIDTH-1:0]    key_reg;
logic empty_internal;


//-------------init from variables-----------
initial begin
    key_reg = {KEY_WIDTH{1'b0}};
    empty_internal = 1'b1;
end




//--------------Code Starts Here------------------ 
assign fits_write = (key_write_i == key_reg && empty_internal) ? 1'b1 : 1'b0;
assign fits_read = (key_read_i == key_reg && !empty_internal) ? 1'b1 : 1'b0;
assign empty = empty_internal;


always @ (posedge clk) begin
    if (reset) begin
        key_reg <= {KEY_WIDTH{1'b0}};
        empty_internal <= 1'b1;
    end else if (cs && we) begin
        key_reg <= key_write_i;
        empty_internal <= 1'b0;
    end else if (cs && del) begin
        empty_internal <= 1'b1;
    end
end

endmodule // End of Module ram_sp_sr_sw