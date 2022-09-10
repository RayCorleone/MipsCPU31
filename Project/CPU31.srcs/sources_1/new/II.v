`timescale 1ns / 1ps

module II(
    input [3:0] a,  // pc31-28
    input [25:0] b, // imem25-0
    output [31:0] oData
    );
    assign oData = {a,b,2'b00};
endmodule