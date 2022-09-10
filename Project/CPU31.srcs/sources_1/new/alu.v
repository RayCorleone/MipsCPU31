`timescale 1ns / 1ps

module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] aluc,
    output reg [31:0] result,
    output zero, overflow
    );

    wire turn_1;
    wire zero_1;
    wire [31:0]srav;
    wire [32:0] data1;
    wire [32:0] data2;
    wire [32:0] temp1,temp2;

    assign data1 = a;
    assign data2 = b;

    assign srav={32{b[31]}};
    assign temp1=data1+data2;
    assign temp2=data1-data2;
    assign turn_1=(aluc==4'b0010)&&temp1[32];
    assign overflow=(turn_1)?1:0;
    assign zero_1=(aluc==4'b0010)&&(a==b);
    assign zero=zero_1?1:0;

    always@(aluc or a or b) begin
        case(aluc)
        4'b0010: begin  //add,addi,lw,sw,beq,bne
            result<=a+b; end
        4'b0000: begin  //addu,addiu
            result<=a+b; end
        4'b0011: begin  //sub
            result<=a-b; end
        4'b0001: begin  //subu
            result<=a-b; end
        4'b0100: begin  //and,andi
            result<=a&b; end
        4'b0101: begin  //or,ori
            result<=a|b; end
        4'b0110: begin  //xor,xori
            result<=a^b; end
        4'b0111: begin  //nor
            result<=~(a|b); end
        4'b1011: begin  //slt(有符号数),slti
            if(a[31]==0&&b[31]==0&&a<b)         result<=1;
            else if(a[31]==0&&b[31]==0&&a>=b)   result<=0;
            else if(a[31]==1&&b[31]==1&&a>=b)   result<=0;
            else if(a[31]==1&&b[31]==1&&a<b)    result<=1;
            else if(a[31]==1&&b[31]==0)         result<=1;
            else if(a[31]==0&&b[31]==1)         result<=0; end
        4'b1010: begin  //sltu(无符号数比较),sltiu
            if(a<b) result<=1;
            else    result<=0; end
        4'b1111: begin  //sll,sllv
            result<=b<<a; end
        4'b1101: begin  //srl逻辑右移,srlv
            result<=b>>a; end
        4'b1100: begin  //sra算数右移,srav
            result<=({{31{b[31]}},1'b0}<<(~a[4:0]))|(b>>a[4:0]); end
        4'b1001: begin  //lui
            result<=b*65536; end
        endcase
    end
endmodule