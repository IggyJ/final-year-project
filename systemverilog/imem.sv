module imem(
    input logic [31:0] index,
    output logic [31:0] read_instr
);

    logic [7:0] mem [0:255];

    int i;

    initial begin
        for (int i = 0; i < 256; i++) begin
            mem[i] = 8'b0;
        end

        $readmemh("./imem.txt", mem);
    end

    assign read_instr = {mem[index+3], mem[index+2], mem[index+1], mem[index]};    

endmodule