module gpio(
    output logic [7:0] read_data, 
    input logic [7:0] write_data,
    input clk, write_enable, reset
);

    logic [7:0] mem;
    initial mem = 8'b0;

    assign read_data = mem;

    always_ff @(posedge clk) begin
        if (reset) mem <= 8'b0;
        else if (write_enable) mem <= write_data;
    end

endmodule