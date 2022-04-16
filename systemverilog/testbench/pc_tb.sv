`timescale 10ps/1ps
`include "pc.sv"

module pc_tb;

logic clk, reset, pc_src;
logic [31:0] imm, count;

pc pc_mod(clk, reset, pc_src, imm, count);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
        reset = 1; pc_src = 0; imm = 32'h10;
    #10 reset = 0;
    #50 pc_src = 1;
    #10 pc_src = 0;
    #10;
    $finish;
end


initial begin
    $dumpfile("wave_pc.vcd");
    $dumpvars(0, clk, count, reset, pc_src, imm);
    $monitor("Count = %d", count);
end


endmodule