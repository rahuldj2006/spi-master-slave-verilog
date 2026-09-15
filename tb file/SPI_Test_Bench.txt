`timescale 1ns / 1ps

module spi_tb;
    reg clk, rst, start;
    reg [7:0] m_din, s_din;
    wire [7:0] m_dout, s_dout;
    wire m_done;
    wire sclk, mosi, miso, cs;

    // Instantiate Master
    spi_master master (
        .clk(clk), .rst(rst), .start(start), .din(m_din), .dout(m_dout),
        .done(m_done), .sclk(sclk), .mosi(mosi), .miso(miso), .cs(cs)
    );

    // Instantiate Slave
    spi_slave slave (
        .sclk(sclk), .rst(rst), .cs(cs), .mosi(mosi), .miso(miso),
        .din(s_din), .dout(s_dout)
    );

    // Generate System Clock (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Setup for Waveform Viewer
        $dumpfile("dump.vcd");
        $dumpvars(0, spi_tb);
        
        // Initialize
        clk = 0; rst = 1; start = 0;
        
        // Transaction 1: Master sends 10100101 (A5), Slave sends 00111100 (3C)
        m_din = 8'hA5; s_din = 8'h3C;
        #20 rst = 0;
        #10 start = 1; // Trigger transmission
        #10 start = 0;
        wait(m_done);  // Wait for 8 bits to finish
        #20;
        
        // Transaction 2: Master sends 01011010 (5A), Slave sends 11000011 (C3)
        m_din = 8'h5A; s_din = 8'hC3;
        start = 1;
        #10 start = 0;
        wait(m_done);
        
        #20 $display("Simulation Complete!");
        $finish;
    end
endmodule
