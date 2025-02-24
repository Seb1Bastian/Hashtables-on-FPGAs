module matrix_generator #(parameter NUMBER_OF_TABLES = 4,
                          parameter HASH_ADR_WIDTH   = 5,
                          parameter KEY_WIDTH = 6)(
    output  wire  [NUMBER_OF_TABLES*HASH_ADR_WIDTH*KEY_WIDTH-1:0]  matrixes_o
); 

wire[KEY_WIDTH-1:0] logic_matrix[NUMBER_OF_TABLES-1:0][HASH_ADR_WIDTH-1:0];

localparam [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_ADR_WIDTH-1:0] = '{'{6'b000000},
                                                                                      '{6'b000100},
                                                                                      '{6'b000010},
                                                                                      '{6'b000001}};

assign logic_matrix = Q_MATRIX;

genvar i,j;
generate
    for (i = 0; i < NUMBER_OF_TABLES; i++) begin
        for (j = 0; j < HASH_TABLE_MAX_SIZE; j++) begin
            assign matrixes_o[(i * HASH_TABLE_MAX_SIZE * KEY_WIDTH) + (j * KEY_WIDTH) :+ KEY_WIDTH] = logic_matrix[i][j];
        end
    end
endgenerate

endmodule