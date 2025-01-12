module cam_forwarder #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2
)(
    input logic clk,
    input logic reset,
    input logic clk_en,

    input logic [KEY_WIDTH-1:0]     new_key_i,
    input logic [DATA_WIDTH-1:0]    new_data_i,
    input logic                     new_valid_i,

    input logic [KEY_WIDTH-1:0]     forward_key_i,
    input logic [DATA_WIDTH-1:0]    forward_data_i,
    input logic                     forward_write_i,
    input logic                     forward_del_i,

    output logic [DATA_WIDTH-1:0]    corrected_data_o,
    output logic                     correct_valid_o

);

logic [KEY_WIDTH-1:0]  key_newer;
logic [DATA_WIDTH-1:0] data_newer;
logic write_newer;
logic del_newer;
wire  key_equal_newer;


always @(posedge clk) begin
    if (reset == 1) begin
        key_newer <= 0;
        data_newer <= 0;
        write_newer <= 0;
        del_newer <= 0;
    end else if (clk_en == 1) begin
        key_newer <=   forward_key_i;
        data_newer <=  forward_data_i;
        write_newer <= forward_write_i;
        del_newer <=   forward_del_i;
    end
end

assign key_equal_newer = (key_newer == new_key_i)? 1'b1 : 1'b0;
always @(key_equal_newer, data_newer, write_newer, del_newer, new_data_i) begin
    case ({key_equal_newer,write_newer,del_newer})
        3'b110 : corrected_data_o = data_newer;
        3'b101 : corrected_data_o = new_data_i;
        default: corrected_data_o = new_data_i;
    endcase
end

always @(key_equal_newer, write_newer, del_newer, new_valid_i) begin
    case ({key_equal_newer,write_newer,del_newer})
        3'b110 : correct_valid_o = 1'b1;
        3'b101 : correct_valid_o = 1'b0;
        default: correct_valid_o = new_valid_i;
    endcase
end

endmodule