module little_to_big_endian(
    input  logic [31:0] little_endian,
    output logic [31:0] big_endian
);
    // Big-endian conversion
    assign big_endian = {little_endian[7:0], little_endian[15:8], little_endian[23:16], little_endian[31:24]};
endmodule