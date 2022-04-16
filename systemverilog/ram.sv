module ram(
    input logic clk, write_enable, read_enable,
    input logic [31:0] data_in,
    input logic [9:0] addr,
    input logic [3:0] mask,
    output logic [31:0] data_out
);

    logic [31:0] memory [0:1023];

    always_ff @(posedge clk) begin
        if (write_enable) begin
            if (mask[0]) memory[addr][7:0]   <= data_in[7:0];
            if (mask[1]) memory[addr][15:8]  <= data_in[15:8];
            if (mask[2]) memory[addr][23:16] <= data_in[23:16];
            if (mask[3]) memory[addr][31:24] <= data_in[31:24];
        end

        data_out <= memory[addr];
    end

    final $writememh("dmem.txt", memory);

endmodule