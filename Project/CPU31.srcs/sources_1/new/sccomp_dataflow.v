`timescale 1ns / 1ps

module sccomp_dataflow(
    input clk_in,
    input reset,
    output [31:0]inst,
    output [31:0]pc
    );

    wire wn;            // 写信号
    wire [31:0] data;   // 存入DMEM的数据
    wire [31:0] oALU;   // ALU指定读写地址
    wire [31:0] oMEM;   // DMEM输出的数据
    wire [31:0] a;      // IMEM读取地址

    assign a = pc - 32'h00400000;

    imem imem_1(a[12:2],inst);
    //iram iram_1(clk_in,inst);
    cpu sccpu(clk_in,reset,inst,oMEM,wn,pc,oALU,data);
    dmem dmem_1(clk_in,reset,wn,oALU,data,oMEM);
endmodule