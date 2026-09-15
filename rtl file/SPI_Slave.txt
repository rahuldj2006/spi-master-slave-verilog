module spi_slave(
    input sclk,          // Clock from Master
    input rst,           
    input cs,            // Chip Select from Master
    input mosi,          // Master Out Slave In
    output reg miso,     // Master In Slave Out
    input [7:0] din,     // Data to send to master
    output reg [7:0] dout // Data received from master
);
    reg [7:0] tx_reg;
    reg [7:0] rx_reg;

    // Load data when idle, or shift on falling edge of SCLK
    always @(negedge sclk or posedge cs or posedge rst) begin
        if (rst) begin
            tx_reg <= din;                 // Load immediately on reset
        end else if (cs) begin
            tx_reg <= din;                 // Reload when CS goes high (idle)
        end else begin
            tx_reg <= {tx_reg[6:0], 1'b0}; // Shift out data on falling edge
        end
    end
    
    // MISO continuous output logic: first bit setup exactly when CS drops low
    always @(*) begin
        if (!cs) miso = tx_reg[7];
        else miso = 0;
    end

    // Sample MOSI on the rising edge of SCLK
    always @(posedge sclk or posedge rst) begin
        if (rst) rx_reg <= 0;
        else if (!cs) rx_reg <= {rx_reg[6:0], mosi};
    end

    // Lock the received data to dout when transaction finishes
    always @(posedge cs or posedge rst) begin
        if (rst) dout <= 0;
        else dout <= rx_reg;
    end
endmodule