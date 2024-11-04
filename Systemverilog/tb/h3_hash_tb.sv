module h3_hash_tb;
    // Testbench signals
wire[1:0] hash_adr_out;
logic[1:0] key_in;

    // Instantiate the DUT (Device Under Test)
    h3_hash_function #(.KEY_WIDTH(2),
                .HASH_ADR_WIDTH(2),
                .Q_MATRIX(2)
    ) uut (
        .key_in(key_in) , // Data bi-directional
        .hash_adr_out(hash_adr_out)
    ); 

    // Test stimulus
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,h3_hash_tb);
        // Initialize signals
        key_in = 2'b00;
        #10;
        key_in = 2'b01;
        #10;
        key_in = 2'b10;
        #10;
        key_in = 2'b11;
        // Finish simulation
        #50;
        $finish;
    end

    // Monitor outputs
    initial begin
        $display("At time %t: d = %b", $time, hash_adr_out);
    end

endmodule
