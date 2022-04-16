module imm_gen(
    input logic [31:0] instr,
    output logic [31:0] imm,
    input logic r_instr, i_instr, s_instr, b_instr, u_instr, j_instr
);

    assign imm = i_instr ? { {21{instr[31]}}, instr[30:20] } :
                 s_instr ? { {21{instr[31]}}, instr[30:25], instr[11:7] } :
                 b_instr ? { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 } :
                 u_instr ? { instr[31:12], 12'b0 } :
                 j_instr ? { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 } :
                 32'b0;

endmodule