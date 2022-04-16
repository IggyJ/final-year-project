`timescale 10ps/1ps
`include "imem.sv"

module imem_tb;

logic [31:0] index;
logic [31:0] read_instr; 
logic clk;

imem imem_mod(index, read_instr);

initial begin
    clk = 0;
    repeat(50) #5 clk = ~clk;
end

int i;

initial begin
    index = 0;
    for (i = 0; i < 40; i += 4) begin
        #10 index = i;
    end

end

initial begin
    $dumpfile("wave_imem.vcd");
    $dumpvars(0, clk, index, read_instr);
end

endmodule