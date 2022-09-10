`timescale 1ns / 1ps

module onBoard(
    input clk,
    input reset,
    output [7:0] o_seg,
    output [7:0] o_sel
    );
    wire [31:0]inst;
    wire [31:0]pc;
    sccomp_dataflow scc(.clk_in(clk),.reset(reset),.inst(inst),.pc(pc));
    seg7x16 seg(clk, reset, pc, o_seg, o_sel);
endmodule