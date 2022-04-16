module csr(
    input  logic clk, reset,
    input  logic [11:0] address,
    output logic [31:0] data_out
);

    // Also used for time and instret;
    reg [63:0] csr_cycle;

    always @(posedge clk)
    begin
        if (reset)
            csr_cycle <= 64'h0;
        else
            csr_cycle <= csr_cycle + 1;
    end

    always @(posedge clk)
    begin
        case (address)
            12'hc00: data_out <= csr_cycle[31:0];
            12'hc01: data_out <= csr_cycle[31:0];
            12'hc02: data_out <= csr_cycle[31:0];
            12'hc80: data_out <= csr_cycle[63:32];
            12'hc81: data_out <= csr_cycle[63:32];
            12'hc82: data_out <= csr_cycle[63:32];
            default: data_out <= 32'h0;
        endcase
    end

endmodule