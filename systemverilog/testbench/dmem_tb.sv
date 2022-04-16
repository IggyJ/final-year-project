`timescale 10ps/1ps
`include "dmem.sv"

module dmem_tb;

logic [31:0] address;
logic [31:0] read_data; 
logic [31:0] write_data;
logic [2:0] width;
logic clk, read_enable, write_enable;

dmem dmem_mod(address, read_data, write_data, width, clk, read_enable, write_enable);

initial begin
    clk = 0;
    repeat(50) #5 clk = ~clk;
end

int i;

initial begin
        read_enable = 0; write_enable = 1; write_data = 8'hF0; address = 4; width = 3'b010;
    #10 read_enable = 1; write_enable = 0; address = 0; width = 3'b100;
    for (i = 1; i < 10; i++) begin
        #10 address = i;
    end

end

initial begin
    $dumpfile("wave_dmem.vcd");
    $dumpvars(0, address, read_data, write_data, clk, read_enable, write_enable);
end

endmodule