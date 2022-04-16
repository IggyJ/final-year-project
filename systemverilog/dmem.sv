module dmem(
    input logic [31:0] address,
    output logic [31:0] read_data, 
    input logic [31:0] write_data,
    input logic [2:0] width,
    input clk, read_enable, write_enable
);

    logic [7:0] mem [0:127];
    logic [31:0] store_buffer;
    logic [31:0] load_buffer;

    int i;

    initial begin
        for (int i = 0; i < 128; i++) begin
            mem[i] = 8'b0;
        end
    end

    assign load_buffer = {mem[address+3], mem[address+2], mem[address+1], mem[address]};

    always_ff @ (posedge clk) begin
        if (write_enable) begin
            case (width)
                3'b000: mem[address] <= write_data[7:0];         // sb
                3'b001: begin                                   // sh
                            mem[address]   <= write_data[7:0];
                            mem[address+1] <= write_data[15:8];
                        end
                3'b010: begin                                   // sw
                            //$monitor("Storing %h at %d, enabled = %d", write_data, address, write_enable);
                            mem[address]   <= write_data[7:0];
                            mem[address+1] <= write_data[15:8];
                            mem[address+2] <= write_data[23:16];
                            mem[address+3] <= write_data[31:24];
                        end
            endcase
        end 
    end

    always @ (*) begin
        if (read_enable) begin
            case (width)
                3'b000:  read_data = {{24{load_buffer[7]}}, load_buffer[7:0]};  // lb
                3'b001:  read_data = {{16{load_buffer[7]}}, load_buffer[15:0]}; // lh
                3'b010:  read_data = load_buffer;                               // lw
                3'b100:  read_data = {24'b0, load_buffer[7:0]};                 // lbu
                3'b101:  read_data = {16'b0, load_buffer[15:0]};                // lhu
                default: read_data = 32'b0;
            endcase
        end
        else
            read_data = 32'bz;
    end

    final $writememh("dmem.txt", mem);

endmodule