module h3_hash_function #(parameter KEY_WIDTH = 32,
                         parameter HASH_ADR_WIDTH   = 5,
                         parameter logic [KEY_WIDTH-1:0] Q_MATRIX [HASH_ADR_WIDTH-1:0]  = '{5'd1,5'd1,5'd1,5'd1,5'd1})(
    input   logic [KEY_WIDTH-1:0]                   key_in,
    output  wire [HASH_ADR_WIDTH-1:0]    hash_adr_out
); 

wire[KEY_WIDTH-1:0] and_matrix[HASH_ADR_WIDTH-1:0];
wire[KEY_WIDTH-1:0] org_matrix[HASH_ADR_WIDTH-1:0];

genvar i,j;
/*generate
    for (i = 0; i < KEY_WIDTH; i = i + 1) begin
        for (j = 0; j < HASH_ADR_WIDTH; j = j + 1) begin
            assign org_matrix[i][j] = Q_MATRIX[(HASH_ADR_WIDTH*i)+j];
        end        
    end
endgenerate*/

generate
    for (i = 0; i < KEY_WIDTH; i = i + 1) begin
        assign org_matrix[i] = Q_MATRIX[i];
    end
endgenerate

generate
    for (i = 0; i < KEY_WIDTH; i = i + 1) begin
        for (j = 0; j < HASH_ADR_WIDTH; j = j + 1) begin
            assign and_matrix[i][j] = key_in[j] & org_matrix[j][i];
        end        
    end
endgenerate

generate
    for (i = 0; i < HASH_ADR_WIDTH; i = i + 1) begin
        assign hash_adr_out[i] = ^and_matrix[i];
    end
endgenerate

endmodule