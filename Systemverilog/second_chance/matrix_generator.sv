module matrix_generator #(parameter NUMBER_OF_TABLES = 4,
                          parameter HASH_ADR_WIDTH   = 5,
                          parameter KEY_WIDTH = 6)(
    output  wire  [NUMBER_OF_TABLES*HASH_ADR_WIDTH*KEY_WIDTH-1:0]  matrixes_o
); 

wire[KEY_WIDTH-1:0] logic_matrix[NUMBER_OF_TABLES-1:0][HASH_ADR_WIDTH-1:0];

localparam integer HASH_TABLE_SIZE[NUMBER_OF_TABLES-1:0] = '{32'd13,32'd13,32'd13,32'd13,
                                                             32'd13,32'd13,32'd13,32'd13};
localparam [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0] = 
                                                                                    '{'{16'b1100001000100101,
                                                                                        16'b0001010001000101,
                                                                                        16'b1111101010111111,
                                                                                        16'b0011101010011001,
                                                                                        16'b1011001010100100,
                                                                                        16'b0010000100001101,
                                                                                        16'b0111011101010100,
                                                                                        16'b0100000111101111,
                                                                                        16'b0010010101000011,
                                                                                        16'b1001101011000000,
                                                                                        16'b0001101110111001,
                                                                                        16'b1001011101011010,
                                                                                        16'b0000000001101001},
                           
                                                                                      '{16'b0111011100010010,
                                                                                        16'b0010001100100010,
                                                                                        16'b1011110011010100,
                                                                                        16'b1101111000001000,
                                                                                        16'b0110101001001000,
                                                                                        16'b1101001101011100,
                                                                                        16'b1010101001111110,
                                                                                        16'b0110111010111100,
                                                                                        16'b1011111001111001,
                                                                                        16'b0111000111111010,
                                                                                        16'b1111001001111100,
                                                                                        16'b0011001101100111,
                                                                                        16'b0111000001011001},
                           
                                                                                      '{16'b1111100011000111,
                                                                                        16'b0110101011110010,
                                                                                        16'b1111100111000100,
                                                                                        16'b0001111001101100,
                                                                                        16'b0011000001101001,
                                                                                        16'b1010001110111010,
                                                                                        16'b1011100011011010,
                                                                                        16'b1111000010100000,
                                                                                        16'b1100100000111010,
                                                                                        16'b0100001000111000,
                                                                                        16'b1001001101101000,
                                                                                        16'b1100111011100000,
                                                                                        16'b1001101000000101}, 
                           
                                                                                      '{16'b0001110100101110,
                                                                                        16'b1000000010100111,
                                                                                        16'b0010000100100011,
                                                                                        16'b0000110011011010,
                                                                                        16'b0100011111000111,
                                                                                        16'b0011110010010100,
                                                                                        16'b1001000001100011,
                                                                                        16'b1111011011101111,
                                                                                        16'b1001100111100110,
                                                                                        16'b1101010001000111,
                                                                                        16'b1111110011001101,
                                                                                        16'b1010000011111010,
                                                                                        16'b0101011100010100},
                           
                                                                                      '{16'b1010001011010100,
                                                                                        16'b1101000100001100,
                                                                                        16'b0100000110110011,
                                                                                        16'b1010101001001010,
                                                                                        16'b0101101101001011,
                                                                                        16'b0011101000101001,
                                                                                        16'b1101011111010001,
                                                                                        16'b0101000100100011,
                                                                                        16'b0111010011111010,
                                                                                        16'b0100011001011100,
                                                                                        16'b1001001100100011,
                                                                                        16'b1111000101011110,
                                                                                        16'b1001000110010101},
                           
                                                                                      '{16'b0000110011111001,
                                                                                        16'b0000000110100010,
                                                                                        16'b0100100000101010,
                                                                                        16'b0101111111110111,
                                                                                        16'b0101101110111010,
                                                                                        16'b1110000010000100,
                                                                                        16'b1100110111011110,
                                                                                        16'b0000010111010000,
                                                                                        16'b1001100011001011,
                                                                                        16'b0111000000101001,
                                                                                        16'b0001000001010110,
                                                                                        16'b1001001101101101,
                                                                                        16'b0011101111101111},
                           
                                                                                      '{16'b0010101101100110,
                                                                                        16'b1110111010001110,
                                                                                        16'b0101111010101001,
                                                                                        16'b0010110110001101,
                                                                                        16'b0110100101011000,
                                                                                        16'b1001101100101100,
                                                                                        16'b0101111001001101,
                                                                                        16'b0011110111101111,
                                                                                        16'b0110111001111001,
                                                                                        16'b0010110011100100,
                                                                                        16'b0111110101110011,
                                                                                        16'b0111011011011001,
                                                                                        16'b0111001001010101},
                           
                                                                                      '{16'b1000000010100001,
                                                                                        16'b0001100001101111,
                                                                                        16'b0011000000000100,
                                                                                        16'b0011110011111011,
                                                                                        16'b1001111100111000,
                                                                                        16'b0101001100100010,
                                                                                        16'b0000010100111001,
                                                                                        16'b0110001001101101,
                                                                                        16'b0011010011001011,
                                                                                        16'b1000110110100001,
                                                                                        16'b0100101001000100,
                                                                                        16'b0001010001010011,
                                                                                        16'b1110001011000110}};

assign logic_matrix = Q_MATRIX;

genvar i,j;
generate
    for (i = 0; i < NUMBER_OF_TABLES; i++) begin
        for (j = 0; j < HASH_ADR_WIDTH; j++) begin
            assign matrixes_o[(i * HASH_ADR_WIDTH * KEY_WIDTH) + (j * KEY_WIDTH) +: KEY_WIDTH] = logic_matrix[i][j];
        end
    end
endgenerate

endmodule