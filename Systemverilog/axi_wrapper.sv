module axi_wrapper #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter integer HASH_TABLE_SIZE [NUMBER_OF_TABLES-1:0]   = '{2,2,2},
                    parameter logic [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0]  = '{'{2'b01, 2'b01},'{2'b01, 2'b01},'{2'b01, 2'b01}})(
    input   logic clk,
    input   logic reset,
    
    //write adr channel
    input   logic AWVALID,
    input   logic [1:0] AWADDR,
    input   logic [1:0] AWPROT,
    output  wire AWREADY,

    //write data channel
    input   logic WVALID,
    input   logic [1:0] WDATA,
    input   logic [1:0] WSTRB,
    output  wire WREADY,

    //write response channel
    input   logic BVALID,
    input   logic [1:0] BRESP,
    output  wire BREADY,

    //read adr channel
    input   logic ARVALID,
    input   logic [1:0] ARADDR,
    input   logic [1:0] ARPROT,
    output  wire ARREADY,

    //read data channel
    input   logic RREADY,
    output  wire RVALID,
    output  wire RDATA,
    output  wire RRESP


);



//write data channel fifo
fifo 
#(.DATA_WIDTH(KEY_WIDTH),
  .DEPTH(2)
)
wdf(
    .clk(clk),
    .reset(reset),
    
    
);


endmodule