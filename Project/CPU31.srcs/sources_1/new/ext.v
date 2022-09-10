`timescale 1ns / 1ps

module ext5(
    input [4:0] i,
    output [31:0] o
    );
    assign o ={{27{1'b0}},i};
endmodule

module ext16(
    input [15:0] i,
    input sign,
    output [31:0] o
    );
    assign o =sign? {{27{i[15]}},i}:{{27{1'b0}},i};
endmodule

module ext18(
    input [15:0] i,
    input sign,
    output [31:0] o
    );
    assign o =sign?{{14{i[15]}},i,2'b00}:{{14{1'b0}},i,2'b00};
endmodule