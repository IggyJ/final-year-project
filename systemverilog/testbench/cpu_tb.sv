`timescale 10ps/1ps
`include "cpu.sv"

module cpu_tb;

logic clk, reset;
logic [7:0] gpio0;

cpu cpu_mod(clk, reset, gpio0);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
        reset = 1;
    #10 reset = 0;
    #5000 reset = 1;
    #10 reset = 0;
    #5000;
    $finish;
end

initial begin
    $dumpfile("wave_cpu.vcd");
    $dumpvars(0, cpu_tb);
end

endmodule