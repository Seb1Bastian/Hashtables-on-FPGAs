module hash_table #(parameter DATA_WIDTH = 32)(
    input   logic clk,
    input   logic reset,
    input   logic [DATA_WIDTH-1:0] data_in,
    input   logic ready_i,
    input   logic valid_i,
    output  wire ready_o,
    output  wire valid_o
    output  wire [DATA_WIDTH-1:0] read_data_o
);
/*localparam integer HASH_TABLE_SIZE[NUMBER_OF_TABLES-1:0] = '{32'd1,32'd1,32'd1,32'd1};
localparam [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0] = '{'{6'b000000},
                                                                                      '{6'b000100},
                                                                                      '{6'b000010},
                                                                                      '{6'b000001}};
localparam HASH_TABLE_MAX_SIZE = HASH_TABLE_SIZE[0];*/
genvar i,j,l;

/*generate
    for (i = 0; i < NUMBER_OF_TABLES; i++) begin
        HASH_TABLE_SIZE[i] = HASH_TABLE_SIZES[(i+1)*32-1:-32];
    end
endgenerate*/



wire [KEY_WIDTH-1:0] correct_dim_matrix [NUMBER_OF_TABLES-1:0][HASH_TABLE_MAX_SIZE-1:0];

wire [DATA_WIDTH-1:0]   data_in_delayed;
wire [1:0]              delete_write_read_i_valid;
wire [1:0]              delete_write_read_i_delayed;





controller big_ass_controller (
    .delete_write_read_i(delete_write_read_i_delayed),
    .valid_o(valid_o)
);



//delaying signals to the right time




siso_register #(
    .DATA_WIDTH(DATA_WIDTH-2),
    .DELAY(2))
data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(data_in[DATA_WIDTH-3:0]),
    .data_o(data_in_delayed));

assign read_data_o[DATA_WIDTH-3:0] = data_in_delayed;
assign read_data_o[DATA_WIDTH-1-:1] = 2'b00;

siso_register #(
    .DATA_WIDTH(2),
    .DELAY(2))
op_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(delete_write_read_i_valid),
    .data_o(delete_write_read_i_delayed));


assign ready_o = ready_i;
assign delete_write_read_i_valid = valid_i == 1'b1 ? data_in[DATA_WIDTH-1-:1] : 2'b00; //nothing operation


endmodule