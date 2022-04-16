module io_select(
	input logic [31:0] addr,
	output logic dmem_enable, gpio0_enable, uart_enable, i2c_enable
);

	assign dmem_enable  = (addr[31:25] == 7'b0000001);
	assign gpio0_enable = (addr == 32'h04000000);
	assign uart_enable  = (addr == 30'h04000004) ||
						  (addr == 30'h04000005) ||
						  (addr == 30'h04000006) ||
						  (addr == 30'h04000007) ||
						  (addr == 30'h04000008) ||
						  (addr == 30'h04000009);
	assign i2c_enable   = (addr == 30'h0400000a) ||
						  (addr == 30'h0400000b) ||
						  (addr == 30'h0400000c) ||
						  (addr == 30'h0400000d) ||
						  (addr == 30'h0400000e) ||
						  (addr == 30'h0400000f);

endmodule