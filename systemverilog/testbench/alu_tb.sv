`timescale 10ps/1ps
`include "alu.sv"

module alu_tb;

logic [3:0] alu_ctl;
logic [31:0] a, b;
logic [31:0] alu_result;
logic zero, clk;

alu alu_mod(alu_ctl, a, b, alu_result, zero);

initial begin
    clk = 0;
    repeat(50) #5 clk = ~clk;
end

integer i;

initial begin
    alu_ctl = 0; a = 0; b = 0;
    #10 a = 32'b1010; b = 32'b1111;
    for (i = 1; i < 9; i++) begin
        #10 alu_ctl = i;
    end
end

initial begin
    $dumpfile("wave_alu.vcd");
    $dumpvars(0, clk, alu_ctl, a, b, alu_result, zero);
end

endmodule