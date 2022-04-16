module control(
    input logic [31:0] instr,
    output logic [4:0] alu_ctl,
    output logic reg_write_enable, alu_src, mem_to_reg,
    output logic dmem_write_enable, dmem_read_enable,
    output logic branch, branch_inv, jump, jump_reg, pc_to_rf,
    input logic r_instr, i_instr, s_instr, b_instr, u_instr, j_instr
);

    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [6:0] opcode;
    
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    assign opcode = instr[6:0];

    assign dmem_read_enable = (opcode == 7'b0000011) ? 1 : 0;
    // assign dmem_read_enable = 1;
    assign dmem_write_enable = s_instr ? 1 : 0;
    assign branch = b_instr;
    assign jump = j_instr || (opcode == 7'b0010111);
    assign jump_reg = (opcode == 7'b1100111) ? 1 : 0;
    assign alu_src = (i_instr || s_instr || u_instr) ? 1 : 0;
    assign reg_write_enable = r_instr || i_instr || u_instr || j_instr ? 1 : 0;
    assign mem_to_reg = (opcode == 7'b0000011) ? 1 : 0;
    assign pc_to_rf = (opcode == 7'b0010111) ? 1 : 0;
    assign branch_inv = (b_instr && (funct3 == 3'b001 || funct3 == 3'b100 || funct3 == 3'b110 || funct3 == 3'b101 || funct3 == 3'b111)) ? 1 : 0;

    always @(*) begin
        if (r_instr) begin
            if (funct7 == 7'b0000000 || funct7 == 7'b0100000) begin
                case (funct3)
                    3'b000: alu_ctl = funct7[5] ? 3 : 2; // sub/add
                    3'b001: alu_ctl = 6; // sll
                    3'b010: alu_ctl = 10;// slt
                    3'b011: alu_ctl = 4; // sltu
                    3'b100: alu_ctl = 5; // xor
                    3'b101: alu_ctl = funct7[5] ? 8 : 7; // sra/srl
                    3'b110: alu_ctl = 1; // or
                    3'b111: alu_ctl = 0; // and
                endcase
            end
            /*else if (funct7 == 7'b0000001) begin // RV32M
                case (funct3)
                    3'b000: alu_ctl = 15; // mul
                    3'b001: alu_ctl = 18; // mulh
                    3'b010: alu_ctl = 17; // mulhsu
                    3'b011: alu_ctl = 16; // mulhu
                    3'b100: alu_ctl = 12; // div
                    3'b101: alu_ctl = 11; // divu
                    3'b110: alu_ctl = 14; // rem
                    3'b111: alu_ctl = 13; // remu
                endcase
            end*/
        end
        else if (opcode == 7'b0010011) begin
            case (funct3)
                3'b000: alu_ctl = 2; // addi
                3'b001: alu_ctl = 6; // slli
                3'b010: alu_ctl = 4; // slti
                3'b011: alu_ctl = 4; // sltiu
                3'b100: alu_ctl = 5; // xori
                3'b101: alu_ctl = funct7[5] ? 8 : 7; // srai/srli
                3'b110: alu_ctl = 1; // ori
                3'b111: alu_ctl = 0; // andi
            endcase
        end
        else if (opcode == 7'b0000011) begin // loads
            alu_ctl = 2;
        end
        else if (opcode == 7'b1100111) begin // jalr
            alu_ctl = 2;
        end
        else if (j_instr) begin
            alu_ctl = 2;
        end
        else if (s_instr) begin
            alu_ctl = 2;
        end
        else if (u_instr) begin
            alu_ctl = 9;
        end
        else if (b_instr) begin
            case (funct3)
                3'b000: alu_ctl = 3;  // beq
                3'b001: alu_ctl = 3;  // bne
                3'b100: alu_ctl = 10; // blt
                3'b101: alu_ctl = 20; // bge
                3'b110: alu_ctl = 4;  // bltu
                3'b111: alu_ctl = 19; // bgeu
            endcase
        end
    end

endmodule