`timescale 10ps/1ps
`include "top.sv"
`include "i2c_slave.sv"

module top_tb;

logic clk, clk_uart, reset;
logic [7:0] gpio0;
logic uart_rx, uart_tx;
wire i2c_scl, i2c_sda;
pullup p_scl(i2c_scl);
pullup p_sda(i2c_sda);

top top_mod(clk, clk_uart, reset, gpio0, uart_rx, uart_tx, i2c_scl, i2c_sda);

logic uart_write;
logic [3:0] uart_addr;
logic [31:0] uart_data_in, uart_data_out;
uart uart_test(clk, reset, uart_write, uart_addr, uart_data_in, uart_data_out, uart_tx, uart_rx);
i2c_slave i2c_test(reset, i2c_scl, i2c_sda);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    #50 uart_addr = 4;
        uart_data_in = 5;
        uart_write = 1;
    #10 uart_addr = 9;
        uart_data_in = 1024;
    #10 uart_addr = 7;
        uart_data_in = 32'h40000000;
    #10 uart_write = 0;
end


// initial begin
//     uart_rx = 1;
// end

initial begin
          reset = 1;
    #10   reset = 0;
    #100020;
    $finish;
end

initial begin
    $dumpfile("wave_cpu.vcd");
    $dumpvars(0, top_tb);
end

endmodule