`timescale 1ns / 1ps

module mux5(
    input [4:0] i1,    // s=0
    input [4:0] i2,    // s=1
    input s,
    output [4:0] o
    );
    assign o=s ? i2:i1;
endmodule

module mux32(
    input [31:0] i1,    // s=0
    input [31:0] i2,    // s=1
    input s,
    output [31:0] o
    );
    assign o=s ? i2:i1;
endmodule

module muxpc(
    input clk,
    input [31:0] i0,    // s=00
    input [31:0] i1,    // s=01
    input [31:0] i2,    // s=10
    input [31:0] i3,    // s=11
    input [1:0] s,
    output [31:0] o
    );
    assign o=(s==0)?i0:(s==1?i1:(s==2?i2:i3));
endmodule