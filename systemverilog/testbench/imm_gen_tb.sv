`timescale 10ps/1ps
`include "imm_gen.sv"

module imm_gen_tb;

logic [31:0] instr, imm;
logic clk;
logic i_instr, s_instr;

imm_gen imm_gen_mod(instr, imm, i_instr, s_instr);

initial begin
    clk = 0;
    repeat(50) #5 clk = ~clk;
end

initial begin
    #10 instr = 32'b1111111_00000_00000_111_00001_0110011; // R-Type
    #10 instr = 32'b1010101_01010_00000_111_00001_0000011; // I-Type
    #10 instr = 32'b0101010_00000_00000_111_10101_0100011; // S-Type
    #10 instr = 32'b1010101_00000_00000_111_01010_1100011; // B-Type
    #10 instr = 32'b1111111_11111_11111_111_00001_0110111; // U-Type
    #10 instr = 32'b0000000_00000_00000_001_00001_1101111; // J-Type
end

initial begin
    $dumpfile("wave_imm_gen.vcd");
    $dumpvars(0, clk, instr, imm);
end

endmodule