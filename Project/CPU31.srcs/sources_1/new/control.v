`timescale 1ns / 1ps

module control(
    input zero,
    input [5:0] opc,
    input [5:0] func,
    output rt_rd,   //1:选择rt      0:选择rd
    output isjal,   //1:选择PC + 4  0:选择ALU或者储存器数据 
    output sext,    //1:符号扩展    0:零扩展
    output imm,     //1:选择扩展后的立即数 0：选择寄存器堆的数据
    output w_reg,   //1:写寄存器堆  0：不写
    output w_mem,   //1:写存储器    0：不写
    output sft,     //1:选择移位位数            0：选择寄存器堆的数据
    output mem_alu, //1:选择从存储器中读出的数据 0：选择ALU计算出的数据
    output [3:0] aluc,       //ALU控制信号
    output [1:0] pc_select   //muxpc控制信号
    );

    wire r_type =~(opc[5]|opc[4]|opc[3]|opc[2]|opc[1]|opc[0]);
    wire i_add  =r_type&func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];   //100000
    wire i_addu =r_type&func[5]&~func[4]&~func[3]&~func[2]&~func[1]&func[0];    //100001
    wire i_sub  =r_type&func[5]&~func[4]&~func[3]&~func[2]&func[1]&~func[0];    //100010
    wire i_subu =r_type&func[5]&~func[4]&~func[3]&~func[2]&func[1]&func[0];     //100011
    wire i_and  =r_type&func[5]&~func[4]&~func[3]&func[2]&~func[1]&~func[0];    //100100
    wire i_or   =r_type&func[5]&~func[4]&~func[3]&func[2]&~func[1]&func[0];     //100101
    wire i_xor  =r_type&func[5]&~func[4]&~func[3]&func[2]&func[1]&~func[0];     //100110
    wire i_nor  =r_type&func[5]&~func[4]&~func[3]&func[2]&func[1]&func[0];      //100111
    wire i_slt  =r_type&func[5]&~func[4]&func[3]&~func[2]&func[1]&~func[0];     //101010
    wire i_sltu =r_type&func[5]&~func[4]&func[3]&~func[2]&func[1]&func[0];      //101011
    wire i_sll  =r_type&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];  //000000
    wire i_srl  =r_type&~func[5]&~func[4]&~func[3]&~func[2]&func[1]&~func[0];   //000010
    wire i_sra  =r_type&~func[5]&~func[4]&~func[3]&~func[2]&func[1]&func[0];    //000011
    wire i_sllv =r_type&~func[5]&~func[4]&~func[3]&func[2]&~func[1]&~func[0];   //000100
    wire i_srlv =r_type&~func[5]&~func[4]&~func[3]&func[2]&func[1]&~func[0];    //000110
    wire i_srav =r_type&~func[5]&~func[4]&~func[3]&func[2]&func[1]&func[0];     //000111
    wire i_jr   =r_type&~func[5]&~func[4]&func[3]&~func[2]&~func[1]&~func[0];   //001000
    wire i_addi =~opc[5]&~opc[4]&opc[3]&~opc[2]&~opc[1]&~opc[0];    //001000
    wire i_addiu=~opc[5]&~opc[4]&opc[3]&~opc[2]&~opc[1]&opc[0];     //001001
    wire i_andi =~opc[5]&~opc[4]&opc[3]&opc[2]&~opc[1]&~opc[0];     //001100
    wire i_ori  =~opc[5]&~opc[4]&opc[3]&opc[2]&~opc[1]&opc[0];      //001101  
    wire i_xori =~opc[5]&~opc[4]&opc[3]&opc[2]&opc[1]&~opc[0];      //001110
    wire i_lw   =opc[5]&~opc[4]&~opc[3]&~opc[2]&opc[1]&opc[0];      //100011
    wire i_sw   =opc[5]&~opc[4]&opc[3]&~opc[2]&opc[1]&opc[0];       //101011
    wire i_beq  =~opc[5]&~opc[4]&~opc[3]&opc[2]&~opc[1]&~opc[0];    //000100
    wire i_bne  =~opc[5]&~opc[4]&~opc[3]&opc[2]&~opc[1]&opc[0];     //000101
    wire i_slti =~opc[5]&~opc[4]&opc[3]&~opc[2]&opc[1]&~opc[0];     //001010
    wire i_sltiu=~opc[5]&~opc[4]&opc[3]&~opc[2]&opc[1]&opc[0];      //001011
    wire i_lui  =~opc[5]&~opc[4]&opc[3]&opc[2]&opc[1]&opc[0];       //001111
    wire i_j    =~opc[5]&~opc[4]&~opc[3]&~opc[2]&opc[1]&~opc[0];    //000010
    wire i_jal  =~opc[5]&~opc[4]&~opc[3]&~opc[2]&opc[1]&opc[0];     //000011

    assign w_mem = i_sw;
    assign isjal = i_jal;
    assign mem_alu = i_lw;
    assign sft = i_sll|i_srl|i_sra;
    assign sext=i_addi|i_addiu|i_lw|i_sw|i_beq|i_bne|i_slti|i_sltiu;
    assign rt_rd = i_addi|i_addiu|i_andi|i_ori|i_xori|i_lw|i_slti|i_sltiu|i_lui;
    assign imm = i_addi|i_addiu|i_andi|i_ori|i_xori|i_lw|i_sw|i_slti|i_sltiu|i_lui;

    assign pc_select[1] = i_jr|i_j|i_jal;
    assign pc_select[0] = (zero&i_beq)|(~zero&i_bne)|i_j|i_jal;

    assign w_reg = i_add|i_addu|i_sub|i_subu|i_and|i_or|i_xor|
                i_nor|i_slt|i_sltu|i_sll|i_srl|i_sra|i_sllv|
                i_srlv|i_srav|i_addi|i_addiu|i_andi|i_ori|i_xori|
                i_lw|i_slti|i_sltiu|i_lui|isjal;
    assign aluc[3] = i_slt|i_sltu|i_sll|i_srl|i_sra|i_sllv|i_srlv|
                    i_srav|i_slti|i_sltiu|i_lui;
    assign aluc[2] = i_and|i_or|i_xor|i_nor|i_sll|i_srl|i_sra|i_sllv|
                    i_srlv|i_srav|i_andi|i_ori|i_xori;
    assign aluc[1] = i_add|i_sub|i_xor|i_nor|i_slt|i_sltu|i_sll|i_sllv|
                    i_addi|i_xori|i_lw|i_sw|i_beq|i_bne|i_slti|i_sltiu;
    assign aluc[0] = i_sub|i_subu|i_or|i_nor|i_slt|i_srl|i_srlv|i_ori|
                    i_slti|i_sll|i_sllv|i_lui;         
endmodule