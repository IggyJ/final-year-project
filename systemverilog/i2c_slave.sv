module i2c_slave(
    input logic reset,
    input logic scl,
    inout logic sda
);

reg ack;
reg [7:0] buffer;
reg [3:0] count;


initial
begin
    count <= 0;
    ack <= 0;
end

always_ff @(posedge scl)
if (reset)
begin
    count <= 0;
    ack <= 0;
end
else
begin
    count <= count + 1;
    if (count <= 9)
    begin
        buffer[7] <= sda;
        buffer <= buffer >> 1;
    end
end

always_ff @(posedge sda) if (scl) count <= 0;

always_ff @(negedge scl)
begin
    if (count == 8)
        ack <= 1;
    if (count == 9)
    begin
        count <= 0;
        ack <= 0;
    end
end

assign sda = ack ? 1'b0 : 1'bz;

endmodule