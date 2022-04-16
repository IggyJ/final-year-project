module i2c(
    input logic clk, reset, write_enable,
    input logic [3:0] addr,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    inout logic scl, sda
);

    logic [15:0] i2c_speed;
    logic [7:0] i2c_conf, i2c_flag, i2c_data, i2c_address;
    logic [15:0] clk_ticks;
    logic next_read, is_read, scl_state, sda_state;
    logic [2:0] i2c_state;
    logic [3:0] i2c_data_count;

    logic i2c_ready, i2c_start, i2c_ack, i2c_cont, i2c_stop, i2c_rdata;

    assign i2c_ready = i2c_flag[7];
    assign i2c_start = i2c_flag[6];
    assign i2c_ack   = i2c_flag[5];
    assign i2c_cont  = i2c_flag[4];
    assign i2c_stop  = i2c_flag[3];
    assign i2c_rdata = i2c_flag[2];

    assign scl = scl_state ? 1'bz : 1'b0;
    assign sda = sda_state ? 1'bz : 1'b0;

    localparam STATE_IDLE    = 3'b000;
    localparam STATE_START   = 3'b001;
    localparam STATE_ADDRESS = 3'b010;
    localparam STATE_ACK     = 3'b011;
    localparam STATE_DATA    = 3'b100;
    localparam STATE_STOP    = 3'b101;
    localparam STATE_WAIT    = 3'b110;

    always_ff @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            i2c_state <= 0;
            i2c_speed <= 0;
            i2c_conf <= 0;
            i2c_flag <= 8'h80;
            i2c_data <= 0;
            i2c_address <= 0;
            scl_state <= 1;
            is_read <= 0;
            next_read <= 0;
        end
          
        else begin
            // DATA FROM CPU
            if (write_enable)
            begin
                case (addr)
                    10: i2c_speed <= data_in[31:16];
                    12: i2c_conf <= data_in[7:0];
                    13:
                    begin
                        i2c_flag[6] <= data_in[14];
                        i2c_flag[4:3] <= data_in[12:11];
                    end
                    14: i2c_data <= data_in[23:16];
                endcase
            end
                
            // I2C FSM
            case(i2c_state)
                STATE_IDLE:
                begin
                    scl_state <= 1;
                    sda_state <= 1;
                    i2c_data_count <= 0;
                    if (i2c_start)
                    begin
                        sda_state <= 0;
                        clk_ticks <= 0;
                        i2c_flag[7] <= 0;
                        i2c_state <= STATE_START;
                        i2c_flag[3] <= 0;
                        i2c_flag[6] <= 0;
                        i2c_flag[2] <= 0;
                        next_read <= i2c_data[0];
                    end
                end

                STATE_START:
                begin
                    if (clk_ticks == i2c_speed / 2)
                    begin
                        scl_state <= 0;
                        i2c_state <= STATE_DATA;
                    end
                    clk_ticks <= clk_ticks + 1;
                end

                STATE_DATA:
                begin
                    i2c_flag[4] <= 0;
                    i2c_flag[5] <= 0;
                    i2c_flag[7] <= 0;

                    if (!is_read) sda_state <= i2c_data[7]; // Write data

                    if (clk_ticks == i2c_speed)
                    begin
                        scl_state <= 1;
                        clk_ticks <= 0;
                        if (is_read) i2c_data[7] <= sda; // Read data
                    end
                    else
                    begin
                        if (clk_ticks == i2c_speed / 2)
                        begin
                            if (is_read)
                            begin
                                if (i2c_data_count != 7) i2c_data <= i2c_data >> 1;
                            end
                            else i2c_data <= i2c_data << 1;
                            
                            i2c_data_count <= i2c_data_count + 1;
                            scl_state <= 0;
                        end

                        if (i2c_data_count == 8)
                        begin
                            i2c_data_count <= 0;
                            i2c_state <= STATE_ACK;
                            i2c_flag[5] <= 0;
                            if (is_read) i2c_flag[2] <= 1;
                        end
                        clk_ticks <= clk_ticks + 1;
                    end
                end

                STATE_ACK:
                begin
                    if (is_read) sda_state <= 0;
                    else sda_state <= 1;

                    if (clk_ticks == i2c_speed)
                    begin
                        clk_ticks <= 0;
                        i2c_flag[5] <= ~sda;
                        scl_state <= 1;
                    end
                    else
                    begin
                        if (clk_ticks == i2c_speed / 2)
                        begin
                            scl_state <= 0;
                            if (i2c_ack)
                            begin
                                i2c_state <= STATE_WAIT;
                                is_read <= next_read;
                            end
                            else
                            begin
                                i2c_state <= STATE_STOP;
                                i2c_flag[3] <= 1;
                                i2c_data_count <= 0;
                            end
                        end
                        clk_ticks <= clk_ticks + 1;
                    end
                end

                STATE_WAIT:
                begin
                    i2c_data_count <= 0;
                    i2c_flag[7] <= 1;
                    i2c_flag[2] <= 0;
                    if (i2c_stop)
                    begin
                        i2c_state <= STATE_STOP;
                        i2c_flag[7] <= 0;
                    end
                    else if (i2c_start)
                    begin
                        scl_state <= 1;
                        if (scl)
                        begin
                            i2c_state = STATE_START;
                            sda_state <= 0;
                            clk_ticks <= 0;
                            next_read <= i2c_data[0];
                            i2c_flag[6] <= 0;
                        end
                    end
                    else if (i2c_cont)
                    begin
                        i2c_state <= STATE_DATA;
                        clk_ticks <= i2c_speed / 2 + 1;
                    end
                    else
                    begin
                        sda_state <= 1;
                        scl_state <= 0;
                        clk_ticks <= 0;
                    end
                end

                STATE_STOP:
                begin
                    i2c_flag[2] <= 0;
                    is_read <= 0;
                    next_read <= 0;
                    if (clk_ticks == i2c_speed)
                        if (i2c_data_count == 1)
                        begin
                            i2c_state <= STATE_IDLE;
                            i2c_flag[7] <= 1;
                            i2c_flag[3] <= 0;
                            clk_ticks <= 0;
                        end
                        else
                        begin
                            i2c_data_count <= i2c_data_count + 1;
                            clk_ticks <= 0;
                            sda_state <= 0;     
                        end
                    else 
                    begin
                        clk_ticks <= clk_ticks + 1;
                        if (clk_ticks == i2c_speed / 2 && i2c_data_count == 1)
                        begin
                            scl_state <= 1;
                        end
                    end
                end

            endcase
        end
    end

    // DATA TO CPU
    always_comb begin
        case (addr)
            10: data_out = {i2c_speed, 16'b0};
            12: data_out = {16'b0, i2c_conf, 8'b0};
            13: data_out = {16'b0, i2c_flag, 8'b0};
            14: data_out = {8'b0, i2c_data, 16'b0};
            default: data_out = 16'b0;
        endcase
    end


endmodule