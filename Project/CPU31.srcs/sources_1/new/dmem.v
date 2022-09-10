`timescale 1ns / 1ps

module dmem(
    input clk,
    input rst,
    input write,
    input [31:0] addrData,  //oALU
    input [31:0] iData,     //data
    output [31:0] oData
    );

    integer i;
    reg [31:0] memory[0:31];
    wire [31:0] Daddr;
    
    assign Daddr = addrData - 32'h10010000;
    assign oData = memory[Daddr[31:2]];
    
    always @(negedge clk or posedge rst) begin //Ğ´ÈëÊı¾İ
        if(rst==1) begin
            for(i=0;i<32;i=i+1) memory[i]<=0; end
        else if(write==1)
            memory[Daddr[31:2]]<=iData;
    end
endmodule