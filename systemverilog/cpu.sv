`include "reg_file.sv"
`include "alu.sv"
`include "pc.sv"
`include "decode.sv"
`include "control.sv"
`include "imm_gen.sv"
`include "csr.sv"
`include "rom.sv"

module cpu(
    input logic clk, reset,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    output logic [3:0] mask,
    output logic [31:0] addr,
    output logic write_enable, read_enable
);
    // Control Flags
    logic rf_write_enable;
    logic mem_to_reg;
    logic alu_src;
    logic [4:0] alu_ctl;
    logic branch, jump, jump_reg;

    // Data Flow
    logic [31:0] imem_index, imem_next;
    logic [31:0] instr;
    logic [31:0] imm;
    logic [4:0] rf_read_index1, rf_read_index2, rf_write_index;
    assign rf_write_index = instr[11:7];
    assign rf_read_index1 = instr[19:15];
    assign rf_read_index2 = instr[24:20];
    logic [1:0] data_width;
    logic dmem_unsigned;
    assign data_width = instr[13:12];
    assign dmem_unsigned = instr[14];
	 
    logic [4:0] data_shmt;
    always @(*) begin
    case (data_width)
            3'b00: data_shmt = addr[1:0] * 8;
            3'b01: data_shmt = addr[1] * 16;
            default: data_shmt = 5'b0;
        endcase
    end
	 
    logic [31:0] data_in_shifted, data_in_extended; 
    assign data_in_shifted = data_in >> data_shmt;
    assign data_out = rf_read_data2 << data_shmt;

    always @(*) begin
        if (!dmem_unsigned)
        begin
            case (data_width)
                3'b00: data_in_extended = { {24{data_in_shifted[7]}}, data_in_shifted[7:0] };
                3'b01: data_in_extended = { {16{data_in_shifted[7]}}, data_in_shifted[15:0] };
                default: data_in_extended = data_in_shifted;
            endcase
        end
        else
        begin
            case (data_width)
                3'b00: data_in_extended = { 24'b0, data_in_shifted[7:0] };
                3'b01: data_in_extended = { 16'b0, data_in_shifted[15:0] };
                default: data_in_extended = data_in_shifted;
            endcase
        end
    end
    
    always @(*) begin
        case (data_width)
            3'b00: mask = 1 << addr[1:0];
            3'b01: mask = addr[1] ? 4'b1100 : 4'b0011;
            default: mask = 4'b1111;
        endcase
    end
	 	 
    logic [31:0] rf_read_data1, rf_read_data2, rf_write_data;
    logic [31:0] alu_a, alu_b, alu_result;
 
    assign addr = alu_result;

    logic pc_to_rf;

    // Program Counter and Branch Logic
    always_ff @(posedge clk) imem_next <= imem_index + 4;
    logic alu_zero, branch_inv;
    logic pc_src;
    logic [31:0] pc_set;
    assign pc_src = jump || (branch && (alu_zero ^ branch_inv));
    assign pc_set = jump_reg ? alu_result :
                    pc_src   ? imem_index + imm :
                    imem_index + 4;

    // Decode
    logic r_instr, i_instr, s_instr, b_instr, u_instr, j_instr;

    // Modules
    pc pc_mod(clk, reset, pc_set, imem_index);

    logic [31:0] imem_out;
    rom imem_mod(imem_index[11:2], ~clk, imem_out);
    assign instr = {imem_out[7:0], imem_out[15:8], imem_out[23:16], imem_out[31:24]};

    reg_file reg_file_mod(rf_read_index1, rf_read_index2, rf_write_index,
                          rf_write_data, rf_read_data1, rf_read_data2,
                          clk, reset, rf_write_enable);

    decode decode_mod(instr, r_instr, i_instr, s_instr, b_instr, u_instr, j_instr);

    control control_mod(instr, alu_ctl, rf_write_enable, alu_src, mem_to_reg, write_enable, read_enable,
                        branch, branch_inv, jump, jump_reg, pc_to_rf, r_instr, i_instr, s_instr, b_instr, u_instr, j_instr);

    imm_gen imm_gen_mod(instr, imm, r_instr, i_instr, s_instr, b_instr, u_instr, j_instr);

    alu alu_mod(alu_ctl, alu_a, alu_b, alu_result, alu_zero);

    logic [11:0] csr_address;
    logic [31:0] csr_out;
    logic system_instr;
    assign csr_address = instr[31:20];
    assign system_instr = (instr[6:2] ==  5'b11100) ? 1'b1 : 1'b0;
    csr csr_mod(clk, reset, csr_address, csr_out);

    // ALU Source
    assign alu_a = rf_read_data1;
    assign alu_b = alu_src ? imm : rf_read_data2;
    
    // Register File Write Source
    assign rf_write_data = pc_to_rf           ? pc_set :
                           (jump || jump_reg) ? imem_next :
                           mem_to_reg         ? data_in_extended :
                           system_instr       ? csr_out :
                                                alu_result;

endmodule