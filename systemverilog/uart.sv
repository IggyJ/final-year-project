module uart(
    input logic clk, reset, write_enable,
    input logic [3:0] addr,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    input logic rx,
    output logic tx
);

    logic [15:0] uart_baud, tx_clk_count, rx_clk_count;
    logic [7:0] uart_conf, uart_flag, uart_rxd, uart_txd;
    logic [3:0] rx_count, tx_count;
    logic [2:0] rx_state, tx_state;

    logic flag_tx_ready, flag_tx_data, flag_rx_data;
    logic [3:0] conf_data_length;
    logic conf_parity_enabled, conf_parity_odd, conf_stop_bits;
    assign flag_tx_ready = uart_flag[7];
    assign flag_tx_data  = uart_flag[6];
    assign flag_rx_data  = uart_flag[5];
    assign conf_data_length = {2'b0, uart_conf[4:3]} + 4'd4;
    assign conf_parity_enabled = uart_conf[2];
    assign conf_parity_odd = uart_conf[1];
    assign conf_stop_bits = uart_conf[0];

    logic txd_parity_even;
                                                        
    localparam STATE_IDLE   = 3'b000;
    localparam STATE_START  = 3'b001;
    localparam STATE_DATA   = 3'b010;
    localparam STATE_PARITY = 3'b011;
    localparam STATE_STOP   = 3'b100;
    localparam STATE_DONE   = 3'b101;

    always_ff @(posedge clk) begin
         // RESET
        if (reset) begin
            uart_baud <= 16'b0;
            uart_conf <= 8'b00011000;
            uart_flag <= 8'b10000000;

            uart_txd  <= 8'b0;
            tx_count  <= 4'b0;
            tx_clk_count <= 16'b0;
            tx_state  <= 3'b0;
            tx <= 1'b1;
            
            uart_rxd  <= 8'b0;
            rx_count  <= 4'b0;
            rx_clk_count <= 16'b0;
            rx_state  <= 3'b0;
        end
          
        else begin
            // DATA FROM CPU
            if (write_enable) begin
                case (addr)
                    4: uart_baud <= data_in[15:0];
                    6: uart_conf <= data_in[23:16];
                    7: uart_flag[6:5] <= data_in[30:29];
                    9: uart_txd <= data_in[15:8];
                endcase
            end
                

            // TRANSMITTER FSM
            case (tx_state)
                STATE_IDLE:
                begin
                    tx <= 1;
                    if (flag_tx_data) begin
                        uart_flag[7:6] <= 2'b0;
                        tx_count <= 0;
                        tx_clk_count <= 0;
                        tx_state <= STATE_START;
                        txd_parity_even <= (^uart_txd[7:6] ^ ^uart_txd[5:4]) ^
                                            (^uart_txd[3:2] ^ ^uart_txd[1:0]);
                    end
                end

                STATE_START:
                begin
                    tx <= 0;
                    if (tx_clk_count == uart_baud) begin
                        tx_clk_count <= 0;
                        tx_state <= STATE_DATA;
                    end
                    else
                        tx_clk_count <= tx_clk_count + 16'd1;
                end

                STATE_DATA:
                begin
                    tx <= uart_txd[0];
                    if (tx_clk_count == uart_baud) begin
                        uart_txd <= uart_txd >> 1;

                        if (tx_count == conf_data_length) begin
                            tx_state <= conf_parity_enabled ? STATE_PARITY : STATE_STOP;
                            tx_count <= 0;
                        end
                        else
                            tx_count <= tx_count + 4'd1;

                        tx_clk_count <= 0;
                    end else
                        tx_clk_count <= tx_clk_count + 16'd1;
                end

                STATE_PARITY:
                begin
                    tx <= conf_parity_odd ? ~txd_parity_even : txd_parity_even;
                    if (tx_clk_count == uart_baud) begin
                        tx_clk_count <= 0;
                        tx_state <= STATE_STOP;
                    end
                    else
                        tx_clk_count <= tx_clk_count + 16'd1;
                end

                STATE_STOP:
                begin
                    tx <= 1;
                    if (tx_clk_count == uart_baud) begin
                        tx_count <= tx_count + 1;

                        if (tx_count[0] == conf_stop_bits) begin
                            uart_flag[7] <= 1;
                            tx_state <= STATE_IDLE;
                        end

                        tx_clk_count <= 0;
                    end else
                        tx_clk_count <= tx_clk_count + 16'd1;
                end
            endcase

            // RECEIVER FSM
            case (rx_state)
                STATE_IDLE:
                begin
                    if (!rx) begin
                        rx_clk_count <= 0;
                        rx_state <= STATE_START;
                    end
                end

                STATE_START:
                begin
                    if (rx_clk_count == uart_baud) begin
                        rx_clk_count <= 0;
                        rx_count <= 0;
                        rx_state <= STATE_DATA;
                    end
                    else
                        rx_clk_count <= rx_clk_count + 1;
                end

                STATE_DATA:
                begin
                    if (rx_clk_count == uart_baud/2) begin
                        rx_clk_count <= rx_clk_count + 1;
                        uart_rxd[7] <= rx;
                    end
                    else if (rx_clk_count == uart_baud) begin
                        rx_count <= rx_count + 1;
                        rx_clk_count <= 0;
                        if (rx_count == conf_data_length)
                            rx_state = conf_parity_enabled ? STATE_PARITY : STATE_STOP;
                        else
                            uart_rxd <= uart_rxd >> 1;
                    end
                    else
                        rx_clk_count <= rx_clk_count + 1;
                end

                STATE_PARITY:
                begin
                    if (rx_clk_count == uart_baud/2) begin
                        uart_flag[4] <= rx;
                        rx_clk_count <= rx_clk_count + 1;
                    end
                    else if (rx_clk_count == uart_baud) begin
                        rx_state = STATE_STOP;
                    end
                    else
                        rx_clk_count <= rx_clk_count + 1;
                end

                STATE_STOP:
                begin
                    uart_flag[5] <= 1'b1;
                    rx_state <= STATE_IDLE;
                end
                
            endcase
        end
    end

    // DATA TO CPU
    always_comb begin
        case (addr)
            4: data_out = {16'b0, uart_baud};
            6: data_out = {8'b0, uart_conf, 16'b0};
            7: data_out = {uart_flag, 24'b0};
            8: data_out = {24'b0, uart_rxd};
            9: data_out = {16'b0, uart_txd, 8'b0};
            default: data_out = 16'b0;
        endcase
    end

endmodule