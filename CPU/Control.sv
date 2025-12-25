module Control(

    input clock,
    input reset,

    input [31:0] mtvec_out,
    input [31:0] mepc_out,

    input [31:0] branch_pc,
    input [31:0] Ex_result,

    input [31:0] MEM_Ex_result,
    input [31:0] MEM_Rdata,

    input [31:0] IDU_rs1_value,
    input [31:0] IDU_rs2_value,
    input branch_flag,
    input jump_flag,
    input mret_flag,
    input ecall_flag,

    input MEM_mem_ren,
    input fence_i_flag,

    input [4:0] IDU_rs1,
    input [4:0] IDU_rs2,

    input IDU_valid,
    input EXU_valid,
    input MEM_valid,

    input [4:0] EXU_rd,
    input [4:0] MEM_rd,

    input EXU_mem_ren,
    input EXU_R_Wen,
    input MEM_R_Wen,
    output IFU_stall,

    output [31:0] EXU_rs1_in,
    output [31:0] EXU_rs2_in,
    
    output icache_clr,
    output EXU_inst_clear,
    output [31:0] dnpc,
    output dnpc_flag
);
    logic [1:0] IDU_rs1_choice;
    logic [1:0] IDU_rs2_choice;
    // 预计算控制信号以减少关键路径
    logic branch_taken, exception_or_jump, stall_condition;
    logic rs1_hazard, rs2_hazard;
    // 第一级：基本条件计算
    assign branch_taken = branch_flag & Ex_result[0];
    assign exception_or_jump = jump_flag | fence_i_flag | mret_flag | ecall_flag;
    assign rs1_hazard = (EXU_rd == IDU_rs1) && (EXU_rd != 5'b0);
    assign rs2_hazard = (EXU_rd == IDU_rs2) && (EXU_rd != 5'b0);
    assign stall_condition = EXU_mem_ren && (rs1_hazard || rs2_hazard);
    // 第二级：输出信号
    assign dnpc_flag = branch_taken | exception_or_jump;
    assign EXU_inst_clear = branch_taken | exception_or_jump | stall_condition;
    assign IFU_stall = stall_condition;
    assign icache_clr = fence_i_flag & EXU_valid;
    // 优化dnpc选择逻辑
    logic [31:0] dnpc_reg;
    always @(*) begin
        if (jump_flag)
            dnpc_reg = Ex_result;
        else if (branch_flag)
            dnpc_reg = branch_pc;
        else if (mret_flag)
            dnpc_reg = mepc_out;
        else
            dnpc_reg = mtvec_out;
    end
    assign dnpc = dnpc_reg;
    // 优化数据转发多路选择器
    logic [31:0] rs1_mux_reg, rs2_mux_reg;
    always @(*) begin
        case (IDU_rs1_choice)
            2'b01: rs1_mux_reg = Ex_result;
            2'b10: rs1_mux_reg = MEM_Ex_result;
            2'b11: rs1_mux_reg = MEM_Rdata;
            default: rs1_mux_reg = IDU_rs1_value;
        endcase
    end
    always @(*) begin
        case (IDU_rs2_choice)
            2'b01: rs2_mux_reg = Ex_result;
            2'b10: rs2_mux_reg = MEM_Ex_result;
            2'b11: rs2_mux_reg = MEM_Rdata;
            default: rs2_mux_reg = IDU_rs2_value;
        endcase
    end
    assign EXU_rs1_in = rs1_mux_reg;
    assign EXU_rs2_in = rs2_mux_reg;
    Data_hazard Data_hazard_inst(
        .IDU_rs1(IDU_rs1),
        .IDU_rs2(IDU_rs2),
        .EXU_rd(EXU_rd),
        .MEM_rd(MEM_rd),
        .MEM_valid(MEM_valid),
        .EXU_valid(EXU_valid),
        .IDU_valid(IDU_valid),
        .MEM_mem_ren(MEM_mem_ren),
        .EXU_R_Wen(EXU_R_Wen),
        .MEM_R_Wen(MEM_R_Wen),
        .IDU_rs1_choice(IDU_rs1_choice),
        .IDU_rs2_choice(IDU_rs2_choice)
    );
endmodule                                                           //PC_Control



