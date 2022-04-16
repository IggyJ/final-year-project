`include "cpu.sv"
`include "ram.sv"
`include "gpio.sv"
`include "io_select.sv"
`include "data_src.sv"
`include "uart.sv"
`include "i2c.sv"

module top(
    input logic clk_sys, clk_uart, reset,
    output logic [7:0] gpio0_data_out,
    input logic uart_rx,
    output logic uart_tx,
    inout logic i2c_scl, i2c_sda
);

    logic [31:0] cpu_data_in, cpu_data_out, ram_data_out;
    logic [3:0] mask;
    logic [31:0] addr;
    logic write_enable, read_enable, dmem_enable, gpio0_enable, uart_enable, i2c_enable;
    logic [31:0] uart_data_out, i2c_data_out;

    cpu cpu_mod(clk_sys, reset, cpu_data_in, cpu_data_out, mask, addr, write_enable, read_enable);

    // Work out which io to select depending on address
    io_select io_select_mod(addr, dmem_enable, gpio0_enable, uart_enable, i2c_enable);

    data_src data_src_mod(dmem_enable, gpio0_enable, uart_enable, i2c_enable, ram_data_out, gpio0_data_out, uart_data_out, i2c_data_out, cpu_data_in);

    // IO
    ram ram_mod(clk_sys, (dmem_enable & write_enable), (dmem_enable & read_enable), cpu_data_out, addr[11:2], mask, ram_data_out);
    gpio gpio0_mod(gpio0_data_out, cpu_data_out[7:0], clk_sys, (gpio0_enable & write_enable), reset);
    uart uart_mod(clk_sys, reset, (uart_enable & write_enable), addr[3:0], cpu_data_out, uart_data_out, uart_rx, uart_tx);
    i2c i2c_mod(clk_sys, reset, (i2c_enable & write_enable), addr[3:0], cpu_data_out, i2c_data_out, i2c_scl, i2c_sda);

endmodule