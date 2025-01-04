module hash_cash #(parameter DATA_WIDTH = 32,
                  parameter KEY_WIDTH = 32,
                  parameter MEM_SIZE  = 128)(
    input   wire                    clk     , // Clock Input
    input   logic                   reset   ,
    input   logic [DATA_WIDTH-1:0]  data_in ,
    input   logic [KEY_WIDTH-1:0]   key_write_i,
    input   logic [KEY_WIDTH-1:0]   key_read_i,
    input   logic                   cs      , // Chip Select
    input   logic                   we      , // Write Enable/Read Enable
    input   logic                   read_en ,
    input   logic                   del     ,

    output  wire [DATA_WIDTH-1:0]  data_out,
    output  wire                   valid_o,
    output  wire [1:0]             error
); 
//--------------Internal variables---------------- 
wire [MEM_SIZE-1:0] key_cells_fits_read_out;
wire [MEM_SIZE-1:0] key_cells_fits_write_out;
wire [MEM_SIZE-1:0] key_cells_empty_out;
wire [MEM_SIZE-1:0] smallest_empty;
wire [MEM_SIZE-1:0][DATA_WIDTH-1:0] data_cells_out;
wire [MEM_SIZE-1:0] delete_input;
wire [MEM_SIZE-1:0] demulitplexer_we_out;
wire [MEM_SIZE-1:0] write_enable_input;
wire [DATA_WIDTH-1:0] multiplexer_out;

//--------------Code Starts Here-------------------
cash_data_cells #(
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_SIZE(MEM_SIZE)
) data_cell (
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .cs(cs),
    .we(write_enable_input),
    .del(delete_input),
    .data_out(data_cells_out)
);

cash_key_cells #(
    .KEY_WIDTH(KEY_WIDTH),
    .MEM_SIZE(MEM_SIZE)
) key_cell (
    .clk(clk),
    .reset(reset),
    .key_write_i(key_write_i),
    .key_read_i(key_read_i),
    .cs(cs),
    .we(write_enable_input),
    .del(delete_input),
    .empty(key_cells_empty_out),
    .fits_read(key_cells_fits_read_out),
    .fits_write(key_cells_fits_write_out)
);

priority_sanitizer #(
    .DATA_WIDTH(MEM_SIZE)
) prio_san (
    .data_in(key_cells_empty_out),
    .data_out(smallest_empty)
);

raw_demulitplexer #(
    .DATA_WIDTH(1),
    .DATA_LINES(MEM_SIZE)
) demulitplexer (
    .data_in(we),
    .sel(smallest_empty),
    .data_out(demulitplexer_we_out)
);

raw_mulitplexer_cam #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_LINES(MEM_SIZE)
) multiplexer (
    .data_in(data_cells_out),
    .sel(key_cells_fits_read_out),
    .data_out(multiplexer_out)
);


assign delete_input = {MEM_SIZE{del}} & key_cells_fits_write_out;
assign write_enable_input = demulitplexer_we_out;// & {MEM_SIZE{(!(|key_cells_fits_write_out))}};
assign write_error = (|key_cells_fits_write_out) & we; //assumption each key exist only one time. write_error = 1 => wants to write with a key that is already inside the cash
assign error[0] = write_error;
assign data_out = multiplexer_out;
assign valid_o = (|key_cells_fits_read_out) & read_en;

endmodule // End of Module ram_sp_sr_sw