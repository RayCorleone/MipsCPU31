`timescale 1ns / 1ps

module regfile(
    input clk,
    input rst,
    input write,
    input jal,
    input [4:0] rna,
    input [4:0] rnb,
    input [4:0] wn,
    input [31:0] data,
    input [31:0] pc,
    output [31:0] Data1,
    output [31:0] Data2
    );
    
    integer i;
    reg [31:0] array_reg[31:0];
     
    //从寄存器读取数据
    assign Data1 = (rna)?(array_reg[rna]):0;
    assign Data2 = (rnb)?(array_reg[rnb]):0;
    
    //将数据写入寄存器
    always@(posedge clk or posedge rst) begin
        if(rst==1) begin
            for(i=0;i<32;i=i+1) begin
                array_reg[i]<=0; end end
        else if(wn != 0 && write && wn != 31) begin
            array_reg[wn]<=data; end
        else if(wn == 31 && write && jal==1) begin
            array_reg[31]<=pc+4; end
        else if(wn == 31 && write && jal!=1) begin
            array_reg[31]<=data; end
    end
endmodule