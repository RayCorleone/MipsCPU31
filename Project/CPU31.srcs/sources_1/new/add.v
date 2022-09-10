`timescale 1ns / 1ps

module NPC(
    input rst,
    input [31:0] i,
    output [31:0] o
    );
    assign o = rst ? i:i+4;
endmodule

module add(
    input [31:0] i1,
    input [31:0] i2,
    output [31:0] o
    );
    assign o = i1 + i2;
endmodule