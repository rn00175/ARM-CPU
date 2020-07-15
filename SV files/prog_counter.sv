module prog_counter (clk, reset, cond_addr19, uncond_addr26, ext_pc, uncond_br, br_taken, pc_rd, pc_out, pc_4out);

    /*
    uncond_br:  select signal to determine whether next PC is an unconditional branch
                or conditional branch

    br_taken:   select signal to determine whether a branch should be taken or not

    pc_rd:      select signal to load PC from register

    pc_out:     output of program counter

    pc_4out:    output of program counter + 4 (next instruction) for BL instruction purposeses.
    */


    input   logic           clk, reset, br_taken, uncond_br, pc_rd;
    input   logic [18:0]    cond_addr19;
    input   logic [25:0]    uncond_addr26;
    input   logic [63:0]    ext_pc; //Address from register
    output  logic [63:0]    pc_out, pc_4out;

    //internal wirings
    //64-bit wires
    logic [63:0]        br_taken_mux_out, uncond_mux_out, pcrd_mux_out;

    //MUX wires
    logic [63:0]        br_taken_mux_in [1:0], uncond_mux_in [1:0], pcrd_mux_in [1:0];

    //counter register;
    logic [63:0]        counter;

    always_comb begin
        
        //Branch taken mux Inputs
        br_taken_mux_in[0] = counter + 4;
        br_taken_mux_in[1] = counter + uncond_mux_out * 4;
 
        //Unconditional Branch mux Inputs
        uncond_mux_in[0] = {45'b0, cond_addr19};
        uncond_mux_in[1] = {38'b0, uncond_addr26};

        //PC_RD mux Inputs
        pcrd_mux_in[0] = br_taken_mux_out;
        pcrd_mux_in[1] = ext_pc;
        
        pc_out = counter;
        pc_4out = counter + 4;
    end

    //MUXes
    mux #(.DATA_WIDTH(64), .SEL_WIDTH(1)) br_mux 
    (.in(br_taken_mux_in), 
     .out(br_taken_mux_out), 
     .sel(br_taken));

    mux #(.DATA_WIDTH(64), .SEL_WIDTH(1)) uncond_mux
    (.in(uncond_mux_in),
     .out(uncond_mux_out),
     .sel(uncond_br));

    mux #(.DATA_WIDTH(64), .SEL_WIDTH(1)) pcrd_mux
    (.in(pcrd_mux_in),
     .out(pcrd_mux_out),
     .sel(pc_rd));

    always_ff @(posedge clk) begin
        if (reset) counter <= 'b0;
        else counter <= pcrd_mux_out;
    end
endmodule

module prog_counter_tb();

    logic clk, reset, br_taken, uncond_br, pc_rd;
    logic [18:0] cond_addr19;
    logic [25:0] uncond_addr26;
    logic [63:0] ext_pc, pc_out, pc_4out;

    prog_counter dut (.*);

    parameter CLOCK_PERIOD = 100;

    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    task advance(input int a);
        begin
            for (int i = 0; i < a; i++) @(posedge clk);
        end        
    endtask

    int i;

    initial begin
        reset <= 1;
        br_taken <= 0; uncond_br <= 0;
        pc_rd <= 0; cond_addr19 <= 0;
        uncond_addr26 <= 0; ext_pc <= 'd45826;
        advance(1);

        reset <= 0;
        advance(33); //1 to finish reset, 32 cycle time lapse

        uncond_addr26 <= 'd328; advance(1);
        uncond_br <= 1; advance(1);
        br_taken <= 1;  advance(1); //35th cycle
        br_taken <= 0;  advance(1);

        assert (pc_out == ((4 * 35) + 4 * 'd328));

        uncond_br <= 0; advance(1);
        cond_addr19 <= 'd164; advance(1);
        br_taken <= 1; advance(1);
        br_taken <= 0; advance(1);

        assert (pc_out == ((4 * 38) + 4 * 'd328 + 4 * 'd164));

        pc_rd <= 1; advance(1);
        pc_rd <= 0; advance(1);
        
        assert (pc_out == 'd45826);
        advance(10);
        
        $stop;
    end

endmodule
