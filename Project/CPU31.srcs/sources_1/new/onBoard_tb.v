`timescale 1ns / 1ps

module onBoard_tb;
    reg clk;
    reg reset;
    wire [7:0] o_seg;
    wire [7:0] o_sel;
    
    initial  begin
        clk = 0;
        reset = 1; #0.5 reset = 0; 
    end
    
    always begin
        #0.5 clk = ~clk;
    end

    onBoard onB(clk, reset, o_seg, o_sel);
endmodule