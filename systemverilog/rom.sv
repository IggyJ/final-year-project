module rom(
    input logic [9:0] addr,
    input logic clk,
    output logic [31:0] data_out
);
    logic [9:0] addr_latch;

    logic [31:0] memory [0:1023];
    assign data_out = memory[addr_latch];

    initial $readmemh("./imem.txt", memory);

    always_ff @(posedge clk) addr_latch <= addr;

endmodule