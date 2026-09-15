module spi_master(
    input clk,           // System clock
    input rst,           // Active-high reset
    input start,         // Trigger to start transmission
    input [7:0] din,     // Data to send to slave
    output reg [7:0] dout, // Data received from slave
    output reg done,     // Transmission complete flag
    output reg sclk,     // SPI Clock
    output reg mosi,     // Master Out Slave In
    input miso,          // Master In Slave Out
    output reg cs        // Chip Select (Active Low)
);
    reg [7:0] tx_reg;
    reg [4:0] count;
    reg state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk <= 0; mosi <= 0; cs <= 1; done <= 0; state <= 0; count <= 0;
        end else begin
            case(state)
                0: begin // IDLE STATE
                    cs <= 1; sclk <= 0; done <= 0;
                    if (start) begin
                        tx_reg <= din;
                        cs <= 0;       // Pull CS low to select slave
                        count <= 16;   // 8 bits = 16 clock edges
                        state <= 1;    // Move to TRANSFER state
                    end
                end
                1: begin // TRANSFER STATE
                    if (count > 0) begin
                        if (count % 2 == 0) begin 
                            // Setup data on MOSI before rising edge
                            mosi <= tx_reg[7];
                            sclk <= 0;
                        end else begin 
                            // Sample data from MISO on rising edge
                            tx_reg <= {tx_reg[6:0], miso};
                            sclk <= 1;
                        end
                        count <= count - 1;
                    end else begin // DONE
                        cs <= 1; sclk <= 0; done <= 1;
                        dout <= tx_reg;
                        state <= 0;
                    end
                end
            endcase
        end
    end
endmodule