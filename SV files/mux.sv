/*
Configurable / Scalable MUX
Parameters determine the width of data, and the number of inputs
DATA_WIDTH: width of data coming in and out
SEL_WIDTH:  width of select bits. Number of inputs is 2^SEL_WIDTH
*/

module mux #(parameter DATA_WIDTH = 1, parameter SEL_WIDTH = 1)(in, out, sel);

    input   logic [DATA_WIDTH-1:0]  in [2**SEL_WIDTH-1:0];
    input   logic [SEL_WIDTH-1:0]   sel;
    output  logic [DATA_WIDTH-1:0]  out;

    assign out = in[sel];
endmodule

module mux_testbench;
    parameter DATA_WIDTH = 8;
    parameter SEL_WIDTH = 1;

    logic   [DATA_WIDTH-1:0]    in [2**SEL_WIDTH-1:0];
    logic   [DATA_WIDTH-1:0]    out;
    logic   [SEL_WIDTH-1:0]     sel;

    mux #(DATA_WIDTH, SEL_WIDTH) two_bit_mux(.in, .out, .sel);

    initial begin
        //Set initial state
        sel = 'b0; #10;
        
        for (int i = 0; i < 2**SEL_WIDTH; i++) begin
            in[i] = $urandom_range(2**DATA_WIDTH, 0); #10;
        end

        for (int i = 0; i < 2**SEL_WIDTH; i++) begin
            sel = i; #10;
        end
        #100; $stop;
    end
endmodule