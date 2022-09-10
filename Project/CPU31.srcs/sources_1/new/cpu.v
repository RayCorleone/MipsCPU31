`timescale 1ns / 1ps

module cpu(
    input clk,
    input reset,
    input [31:0] inst,
    input [31:0] mem,
    output w_mem,
    output [31:0] pc,
    output [31:0] alu,
    output [31:0] data
    );

    // 指令组成 ****************************
    wire [4:0] rd;      //指令的rd(15-11)
    wire [4:0] rt;      //指令的rt(20-16)
    wire [4:0] rs;      //指令的rs(25-21)
    wire [5:0] opc;     //指令的op code
    wire [5:0] func;    //指令的func code
    wire [15:0] imme16; //指令的immediate
    wire [25:0] index;  //指令的index(address)
    assign rd = inst[15:11];
    assign rt = inst[20:16];
    assign rs = inst[25:21];
    assign func = inst[5:0];
    assign opc = inst[31:26];
    assign imme16 = inst[15:0];
    assign index = inst[25:0];

    // 控制信号 ****************************
    wire w_reg;             //reg写信号
    wire rt_rd;             //mux_reg控制信号
    wire sft;               //mux_alua控制信号
    wire is_imm;            //mux_alub控制信号
    wire mem_alu;           //mux_aorm控制信号
    wire is_jal;            //mux_idata控制信号
    wire [3:0] aluc;        //alu控制信号
    wire [1:0] pc_select;   //mux_pc控制信号
    
    // 数据接口 ****************************
    wire [31:0] addr;       //跳转地址
    wire [31:0] aorm;       //经过选择后的数据
    wire [31:0] idata;      //写入reg的data
    wire [31:0] sa;         //IMEM(10-6)拓展后数据
    wire [31:0] offset;     //IMEM(15-0)拓展后数据
    wire [31:0] imme32;     //拓展后32位的立即数
    wire [31:0] ra;         //寄存器堆里的数据
    wire [31:0] npc;        //npc的值(pc+4)
    wire [31:0] next_pc;    //下一条pc指令
    wire [31:0] jump_pc;    //跳转到的指令
    wire [31:0] alua,alub;  //alu的两个数据入口
    wire [4:0] reg_select;  //regfile寄存器选择信号

    // 其他信号 ****************************
    wire sext;      //符号拓展or零拓展
    wire zero;      //alu运算结果0反馈
    wire overflow;  //alu运算结果溢出反馈

    // 主要模块 ****************************
    PC pc_1(clk,reset,next_pc,pc);
    NPC npc_1(1'b0,pc,npc);
    control control_1(zero,opc,func,rt_rd,is_jal,sext,is_imm,w_reg,w_mem,sft,mem_alu,aluc,pc_select);
    ALU alu_1(alua,alub,aluc,alu,zero,overflow);

    add add_1(npc,offset,addr);
    II II_1(npc[31:28],index,jump_pc);
    ext5 ext5_1(inst[10:6],sa);
    ext16 ext16_1(imme16,sext,imme32);
    ext18 ext18_1(imme16,sext,offset);

    mux5 mux_reg(rd,rt,rt_rd,reg_select);
    muxpc mux_pc(clk,npc,addr,ra,jump_pc,pc_select,next_pc);
    mux32 mux_alub(data,imme32,is_imm,alub);
    mux32 mux_alua(ra,sa,sft,alua);
    mux32 mux_aorm(alu,mem,mem_alu,aorm);
    mux32 mux_idata(aorm,npc,is_jal,idata);

    regfile cpu_ref(clk,reset,w_reg,is_jal,rs,rt,reg_select,idata,pc,ra,data);
endmodule