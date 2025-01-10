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

logic [KEY_WIDTH-1:0]  key_older;
logic [DATA_WIDTH-1:0] data_older;
logic write_older;
logic del_older;
wire  key_equal_older;

logic [KEY_WIDTH-1:0]  key_newer;
logic [DATA_WIDTH-1:0] data_newer;
logic write_newer;
logic del_newer;
wire  key_equal_newer;


logic [DATA_WIDTH-1:0] inbetween_data_corrected;
logic inbetween_valid_corrected;

always @(posedge clk) begin
    if (reset == 1) begin
        key_older <= 0;
        data_older <= 0;
        write_older <= 0;
        del_older <= 0;
        key_newer <= 0;
        data_newer <= 0;
        write_newer <= 0;
        del_newer <= 0;
    end else if (clk_en == 1) begin
        key_older <= key_newer;
        data_older <= data_newer;
        write_older <= write_newer;
        del_older <= del_newer;
        key_newer <=   forward_key_i;
        data_newer <=  forward_data_i;
        write_newer <= forward_write_i;
        del_newer <=   forward_del_i;
    end
end

assign key_equal_older = (key_older == new_key_i)? 1'b1 : 1'b0;
always @(key_equal_older, data_older, write_older, del_older, new_data_i) begin
    case ({key_equal_older,write_older,del_older})
        3'b110 : inbetween_data_corrected = data_older;
        3'b101 : inbetween_data_corrected = new_data_i;
        default: inbetween_data_corrected = new_data_i;
    endcase
end

always @(key_equal_older, new_valid_i, write_older, del_older) begin
    case ({key_equal_older,write_older,del_older})
        3'b110 : inbetween_valid_corrected = 1'b1;
        3'b101 : inbetween_valid_corrected = 1'b0;
        default: inbetween_valid_corrected = new_valid_i;
    endcase
end

assign key_equal_newer = (key_newer == new_key_i)? 1'b1 : 1'b0;
always @(key_equal_newer, data_newer, write_newer, del_newer) begin
    case ({key_equal_newer,write_newer,del_newer})
        3'b110 : corrected_data_o = data_newer;
        3'b101 : corrected_data_o = inbetween_data_corrected;
        default: corrected_data_o = inbetween_data_corrected;
    endcase
end

always @(key_equal_newer, write_newer, del_newer, inbetween_valid_corrected) begin
    case ({key_equal_newer,write_newer,del_newer})
        3'b110 : correct_valid_o = 1'b1;
        3'b101 : correct_valid_o = 1'b0;
        default: correct_valid_o = inbetween_valid_corrected;
    endcase
end

endmodule