module big_to_little_endian(
    input logic [31:0] big_endian,
    output logic [31:0] little_endian); // Little-endian conversion

assign little_endian = {big_endian[7:0], big_endian[15:8], big_endian[23:16], big_endian[31:24]};
endmodule