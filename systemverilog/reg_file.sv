module reg_file(
    input  logic [4:0] read_index1, read_index2, write_index,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1, read_data2,
    input  logic clk, reset, write_enable
);

    logic [31:0] rf [0:31];

    integer i;
    always_ff @ (negedge clk)
    begin
        if (reset) begin
            for (i = 0; i < 32; i++) begin
                rf[i] <= 32'b0;
            end
        end
        else if (write_enable && write_index != 32'b0) begin
            rf[write_index] <= write_data;
        end
    end
        
    assign read_data1 = rf[read_index1];
    assign read_data2 = rf[read_index2];

    final
        $writememh("rf.txt", rf);

endmodule