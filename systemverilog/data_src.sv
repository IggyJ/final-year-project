module data_src(
    input logic dmem_enable, gpio0_enable, uart_enable, i2c_enable,
    input logic [31:0] ram_data,
    input logic [7:0] gpio0_data,
    input logic [31:0] uart_data, i2c_data,
    output logic [31:0] data_to_cpu
);

    assign data_to_cpu = dmem_enable  ? ram_data :
                         gpio0_enable ? {24'b0, gpio0_data} :
                         uart_enable  ? uart_data :
                         i2c_enable   ? i2c_data :
                         32'b0;
                                
endmodule