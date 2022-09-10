`timescale 1ns / 1ps

module sccomp_dataflow(
    input clk_in,
    input reset,
    output [31:0]inst,
    output [31:0]pc
    );

    wire wn;            // д�ź�
    wire [31:0] data;   // ����DMEM������
    wire [31:0] oALU;   // ALUָ����д��ַ
    wire [31:0] oMEM;   // DMEM���������
    wire [31:0] a;      // IMEM��ȡ��ַ

    assign a = pc - 32'h00400000;

    imem imem_1(a[12:2],inst);
    //iram iram_1(clk_in,inst);
    cpu sccpu(clk_in,reset,inst,oMEM,wn,pc,oALU,data);
    dmem dmem_1(clk_in,reset,wn,oALU,data,oMEM);
endmodule