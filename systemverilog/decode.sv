module decode(
    input logic [31:0] instr,
    output logic r_instr, i_instr, s_instr, b_instr, u_instr, j_instr
);

    assign r_instr = instr[6:2] ==? 5'b011x0 ||
                     instr[6:2] ==  5'b01011 ||
                     instr[6:2] ==  5'b10100;
    assign i_instr = instr[6:2] ==? 5'b0000x ||
                     instr[6:2] ==? 5'b001x0 ||
                     instr[6:2] ==  5'b11001 ||
                     instr[6:2] ==  5'b11100;
    assign s_instr = instr[6:2] ==? 5'b0100x;
    assign b_instr = instr[6:2] ==  5'b11000;
    assign u_instr = instr[6:2] ==? 5'b0x101;
    assign j_instr = instr[6:2] ==  5'b11011;

endmodule