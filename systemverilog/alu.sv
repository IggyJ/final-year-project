module alu(
    input  logic [4:0]  alu_ctl,
    input  logic [31:0] a, b,
    output logic [31:0] alu_result,
    output logic zero
);
    logic [4:0] shmt;
    assign shmt = b[4:0];

    always_comb begin
        case (alu_ctl)
            0: alu_result = a & b;          // and
            1: alu_result = a | b;          // or
            2: alu_result = a + b;          // add
            3: alu_result = a - b;          // sub
            4: alu_result = a < b ? 1 : 0;  // sltu
            5: alu_result = a ^ b;          // xor
            6: alu_result = a << shmt;      // sll
            7: alu_result = a >> shmt;      // srl
            8: alu_result = $signed(a) >>> shmt; // sra
            9: alu_result = b;              // lui
            10: alu_result = $signed(a) < $signed(b) ? 1 : 0; // slt
            //11: alu_result = b != 0 ? a / b : 0;         // divu
            //12: alu_result = b != 0 ? $signed(a) / $signed(b) : 0; // div
            //13: alu_result =  b != 0 ? a % b : 0;        // remu
            //14: alu_result = b != 0 ? $signed(a) % $signed(b) : 0; // rem
            //15: alu_result = a * b;         // mul
            //16: alu_result = (a * b) >> 32; // mulhu
            //17: alu_result = ($signed(a) * b) >> 32; // mulhsu
            //18: alu_result = ($signed(a) * $signed(b)) >> 32; // mulh
            19: alu_result = a >= b ? 1 : 0;
            20: alu_result = $signed(a) >= $signed(b) ? 1 : 0;
            default: alu_result = 32'b0;
        endcase
    end 

    assign zero = (alu_result == 0); 

endmodule