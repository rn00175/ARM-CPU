//32 64-bit register file.
//3 5-bit ports that denotes Register 1 to Read, Register 2 to Read, and Register to Write.
//3 64-bit ports that takes in data to write, data to read from register 1, and data to read from register 2
//1 single bit port that enables or disables register writing

`timescale 1ns/10ps

module regfile(ReadData1, ReadData2, WriteData, RegAddr1, RegAddr2, WriteAddr, RegWriteEN, clk);

    input logic     [4:0]   RegAddr1, RegAddr2, WriteAddr;
    input logic             RegWriteEN, clk;
    input logic     [63:0]  WriteData;
    output logic    [63:0]  ReadData1, ReadData2;

    logic   [63:0]    registerFile [0:30];

    //assign registerFile[5'b11111] = 16'h0;

    always_ff @(posedge clk) begin
        if (RegAddr1 == 5'b11111)   ReadData1 <= 16'h0;
        else                        ReadData1 <= registerFile[RegAddr1];
        
        if (RegAddr2 == 5'b11111)   ReadData2 <= 16'h0;
        else                        ReadData2 <= registerFile[RegAddr2];
        
        if (RegWriteEN && (WriteAddr != 5'b11111)) registerFile[WriteAddr] <= WriteData;
    end
endmodule

//Testbench for register file

module regstim(); 		

	parameter ClockDelay = 5000;

	logic   [4:0] 	RegAddr1, RegAddr2, WriteAddr;
	logic   [63:0]	WriteData;
	logic 			RegWriteEN, clk;
	logic   [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .RegAddr1, .RegAddr2, .WriteAddr,
					 .RegWriteEN, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWriteEN <= 5'd0;
		RegAddr1 <= 5'd0;
		RegAddr2 <= 5'd0;
		WriteAddr <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWriteEN <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWriteEN <= 0;
			RegAddr1 <= i-1;
			RegAddr2 <= i;
			WriteAddr <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWriteEN <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWriteEN <= 0;
			RegAddr1 <= i-1;
			RegAddr2 <= i;
			WriteAddr <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$stop;
	end
endmodule