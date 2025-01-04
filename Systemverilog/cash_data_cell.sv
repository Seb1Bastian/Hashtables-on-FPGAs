module cash_data_cell #(parameter DATA_WIDTH = 32)(
    input   wire                    clk, // Clock Input
    input   wire                    reset,
    input   logic [DATA_WIDTH-1:0]  data_in,
    input   logic                   cs,
    input   logic                   we, // Write Enable/Read Enable
    input   logic                   del, // Delete Enable

    output  wire [DATA_WIDTH-1:0] data_out
); 
//--------------Internal variables---------------- 
reg [DATA_WIDTH-1:0]    data_reg;


//-------------init from variables-----------
initial begin
    data_reg = {DATA_WIDTH{1'b0}};
end




//--------------Code Starts Here------------------ 
assign data_out = data_reg;

always @ (posedge clk)
begin : prcasesa
    if ( reset )
        data_reg = {DATA_WIDTH{1'b0}};
    else if (cs && we)
        data_reg = data_in;
    else if (cs && del)
        data_reg = {DATA_WIDTH{1'b0}};
end

endmodule // End of Module ram_sp_sr_sw