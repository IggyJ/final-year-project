`timescale 10ps/1ps
`include "reg_file.sv"

module reg_file_tb;

logic [4:0] read_index1, read_index2, write_index;
logic [31:0] write_data;
logic [31:0] read_data1, read_data2;
logic clk, reset, write_enable;

reg_file reg_file_mod(read_index1, read_index2, write_index,
                      write_data,
                      read_data1, read_data2,
                      clk, reset, write_enable);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    read_index1 = 0; read_index2 = 0; write_index = 0;
    reset = 1; write_enable = 0; write_data = 0;
    #10 reset = 0; write_enable = 1;
        write_index = 1; write_data = 32'h8;
        read_index2 = 1;
    #10 write_index = 0;
    #10 write_index = 10; write_data = 32'h1f;
        read_index2 = 10;
    #10;
    $finish;
end

initial begin
    $dumpfile("wave_reg_file.vcd");
    $dumpvars(0, clk, reset, write_enable,
              read_index1, read_index2, write_index,
              write_data, read_data1, read_data2);
end

endmodule