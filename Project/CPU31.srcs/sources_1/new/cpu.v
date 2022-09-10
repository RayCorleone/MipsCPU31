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

    // ָ����� ****************************
    wire [4:0] rd;      //ָ���rd(15-11)
    wire [4:0] rt;      //ָ���rt(20-16)
    wire [4:0] rs;      //ָ���rs(25-21)
    wire [5:0] opc;     //ָ���op code
    wire [5:0] func;    //ָ���func code
    wire [15:0] imme16; //ָ���immediate
    wire [25:0] index;  //ָ���index(address)
    assign rd = inst[15:11];
    assign rt = inst[20:16];
    assign rs = inst[25:21];
    assign func = inst[5:0];
    assign opc = inst[31:26];
    assign imme16 = inst[15:0];
    assign index = inst[25:0];

    // �����ź� ****************************
    wire w_reg;             //regд�ź�
    wire rt_rd;             //mux_reg�����ź�
    wire sft;               //mux_alua�����ź�
    wire is_imm;            //mux_alub�����ź�
    wire mem_alu;           //mux_aorm�����ź�
    wire is_jal;            //mux_idata�����ź�
    wire [3:0] aluc;        //alu�����ź�
    wire [1:0] pc_select;   //mux_pc�����ź�
    
    // ���ݽӿ� ****************************
    wire [31:0] addr;       //��ת��ַ
    wire [31:0] aorm;       //����ѡ��������
    wire [31:0] idata;      //д��reg��data
    wire [31:0] sa;         //IMEM(10-6)��չ������
    wire [31:0] offset;     //IMEM(15-0)��չ������
    wire [31:0] imme32;     //��չ��32λ��������
    wire [31:0] ra;         //�Ĵ������������
    wire [31:0] npc;        //npc��ֵ(pc+4)
    wire [31:0] next_pc;    //��һ��pcָ��
    wire [31:0] jump_pc;    //��ת����ָ��
    wire [31:0] alua,alub;  //alu�������������
    wire [4:0] reg_select;  //regfile�Ĵ���ѡ���ź�

    // �����ź� ****************************
    wire sext;      //������չor����չ
    wire zero;      //alu������0����
    wire overflow;  //alu�������������

    // ��Ҫģ�� ****************************
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