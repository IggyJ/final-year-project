module pc(
    input logic clk, reset,
    input logic [31:0] set,
    output logic [31:0] count
);

    always_ff @ (posedge clk) begin
        if (reset)
            count <= 32'b0;
        else
            count <= set;
    end
    
endmodule