// 64-bit Arithmetic Logic Unit
// cntrl		Operation					Notes:
// 000:			result = B					value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alu(A, B, cntrl, out, zero, overflow, carry, negative);

    input logic     [63:0]  A, B;
    input logic     [2:0]   cntrl;
    output logic    [63:0]  out;
    output logic            zero, overflow, carry, negative;

    logic pre_carry, pre_result;

    assign  zero = (out == '0);

    always_comb begin
        pre_carry = '0;
        pre_result = '0;
        
        case(cntrl) 
        3'b000: {pre_carry, pre_result} = {1'b0, B};
        3'b010: {pre_carry, pre_result} = A + B;
        3'b011: {pre_carry, pre_result} = A - B;
        3'b100: {pre_carry, pre_result} = {1'b0, }

