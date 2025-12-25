`include "para.sv"


module myCPU (
    input cpu_clk,
    input cpu_rst,

    output [31:0] irom_addr,
    input  [31:0] irom_data,

    output [31:0] perip_addr,
    output perip_wen,
    output [ 1:0] perip_mask,
    output [31:0] perip_wdata,
    input  [31:0] perip_rdata
);

    // IFU signals
    logic [31:0] IFU_inst;
    logic IFU_valid;
    logic [31:0] IFU_pc;
    logic [31:0] IFU_snpc;

    // IDU signals
    logic [31:0] IDU_pc;
    logic [ 4:0] IDU_rd;
    logic [ 2:0] IDU_funct3;
    logic IDU_mret_flag;
    logic IDU_ecall_flag;
    logic [31:0] IDU_rs2_value;
    logic [31:0] IDU_rs1_value;
    logic [ 3:0] IDU_csr_wen;
    logic IDU_R_wen;
    logic [31:0] IDU_rd_value;
    logic IDU_mem_wen;
    logic IDU_mem_ren;
    logic IDU_inv_flag;
    logic IDU_branch_flag;
    logic IDU_jump_flag;
    logic [31:0] IDU_add1_value;
    logic [31:0] IDU_add2_value;
    logic [3:0] IDU_alu_opcode;
    logic [4:0] IDU_rs1;
    logic [4:0] IDU_rs2;
    logic [31:0] IDU_a0_value;
    logic [31:0] IDU_mepc_out;
    logic [31:0] IDU_mtvec_out;
    logic [31:0] IDU_branch_pc;
    logic IDU_valid;
    logic IDU_ready;
    logic IDU_fence_i_flag;

    // IFID_EX_Reg signals
    logic [ 2:0] IFID_EX_funct3_reg;
    logic [ 3:0] IFID_EX_csr_wen_reg;
    logic IFID_EX_R_wen_reg;
    logic IFID_EX_mem_wen_reg;
    logic IFID_EX_mem_ren_reg;
    logic [4:0] IFID_EX_rd_reg;
    logic [31:0] IFID_EX_pc_reg;
    logic [3:0] IFID_EX_alu_opcode_reg;
    logic IFID_EX_inv_flag_reg;
    logic IFID_EX_jump_flag_reg;
    logic IFID_EX_branch_flag_reg;
    logic IFID_EX_fetch_i_reg;
    logic [31:0] IFID_EX_branch_pc_reg;
    logic [31:0] IFID_EX_rs2_value_reg;
    logic [31:0] IFID_EX_add1_reg;
    logic [31:0] IFID_EX_add2_reg;
    logic [31:0] IFID_EX_rd_value_reg;
    logic IFID_EX_valid;

    // EXU signals
    logic [2:0] EXU_funct3;
    logic [3:0] EXU_csr_wen;
    logic EXU_R_wen;
    logic EXU_mem_wen;
    logic EXU_mem_ren;
    logic [ 4:0] EXU_rd;
    logic [31:0] EXU_pc;
    logic EXU_jump_flag;
    logic [31:0] EXU_rs2_value;
    logic [31:0] EXU_rd_value;
    logic [31:0] EXU_Ex_result;
    logic EXU_fence_i_flag;
    logic EXU_branch_flag;
    logic [31:0] EXU_branch_pc;

    // EX_LSWB_Reg signals
    logic EX_LSWB_mem_ren_reg;
    logic EX_LSWB_mem_wen_reg;
    logic EX_LSWB_R_wen_reg;
    logic [3:0] EX_LSWB_csr_wen_reg;
    logic [31:0] EX_LSWB_Ex_result_reg;
    logic [4:0] EX_LSWB_rd_reg;
    logic [2:0] EX_LSWB_funct3_reg;
    logic [31:0] EX_LSWB_rs2_value_reg;
    logic EX_LSWB_jump_flag_reg;
    logic [31:0] EX_LSWB_rd_value_reg;
    logic [31:0] EX_LSWB_pc_reg;
    logic EX_LSWB_valid;

    // LSU signals
    logic LSU_jump_flag;
    logic LSU_R_wen;
    logic [31:0] LSU_Rdata;
    logic [3:0] LSU_csr_wen;
    logic [31:0] LSU_Ex_result;
    logic [31:0] LSU_rd_value;
    logic [31:0] LSU_pc;
    logic [4:0] LSU_rd;
    logic LSU_mem_ren;
    logic LSU_ready;

    // WBU signals
    logic [31:0] WBU_pc;
    logic [31:0] WBU_rd_value;
    logic [31:0] WBU_csrd;
    logic [ 4:0] WBU_rd;
    logic WBU_R_wen;
    logic [ 3:0] WBU_csr_wen;
    logic WBU_ready;
    logic WBU_valid;
    logic LSU_valid;

    // Control signals
    logic dnpc_flag;
    logic EXU_inst_clear;
    logic [31:0] dnpc;
    logic IFU_stall;
    logic icache_clr;
    logic [31:0] EXU_rs1_in;
    logic [31:0] EXU_rs2_in;

    assign irom_addr = IFU_pc;

    // IFU?????
    IFU IFU_Inst0 (
        .clock (cpu_clk),
        .reset (cpu_rst),
        .dnpc (dnpc),
        .dnpc_flag(dnpc_flag),
        .stall (IFU_stall),
        .pc (IFU_pc),
        .snpc (IFU_snpc),
        .inst (IFU_inst),
        .irom_data(irom_data),
        .ready (IDU_ready),
        .valid (IFU_valid)
    );

    // Control?????
    Control Control_inst0 (
        .clock (cpu_clk),
        .reset (cpu_rst),
        .mtvec_out (IDU_mtvec_out),
        .mepc_out (IDU_mepc_out),
        .branch_pc (EXU_branch_pc),
        .Ex_result (EXU_Ex_result),
        .MEM_Ex_result(WBU_rd_value),
        .IDU_rs1_value(IDU_rs1_value),
        .IDU_rs2_value(IDU_rs2_value),
        .MEM_Rdata (LSU_Rdata),
        .branch_flag (EXU_branch_flag),
        .jump_flag (EXU_jump_flag),
        .mret_flag (IDU_mret_flag),
        .ecall_flag (IDU_ecall_flag),
        .fence_i_flag (EXU_fence_i_flag),
        .MEM_mem_ren (LSU_mem_ren),
        .IDU_rs1 (IDU_rs1),
        .IDU_rs2 (IDU_rs2),
        .IDU_valid (IDU_valid),
        .EXU_valid (IFID_EX_valid),
        .MEM_valid (LSU_valid),
        .EXU_rd (EXU_rd),
        .MEM_rd (LSU_rd),
        .EXU_mem_ren (EXU_mem_ren),
        .EXU_R_Wen (EXU_R_wen),
        .MEM_R_Wen (LSU_R_wen),
        .IFU_stall (IFU_stall),
        .EXU_rs1_in (EXU_rs1_in),
        .EXU_rs2_in (EXU_rs2_in),
        .dnpc (dnpc),
        .icache_clr (icache_clr),
        .EXU_inst_clear (EXU_inst_clear),
        .dnpc_flag (dnpc_flag)
    );

    // IDU?????
    IDU IDU_Inst0 (
        .clock (cpu_clk),
        .reset (cpu_rst),
        .snpc (IFU_snpc),
        .inst (IFU_inst),
        .pc (IFU_pc),
        .rd_value (WBU_rd_value),
        .csrd (WBU_csrd),
        .rd (WBU_rd),
        .R_wen (WBU_R_wen),
        .csr_wen (WBU_csr_wen),
        .EXU_rs1_in (EXU_rs1_in),
        .EXU_rs2_in (EXU_rs2_in),
        .branch_pc (IDU_branch_pc),
        .rd_next (IDU_rd),
        .funct3 (IDU_funct3),
        .mret_flag (IDU_mret_flag),
        .ecall_flag (IDU_ecall_flag),
        .fence_i_flag (IDU_fence_i_flag),
        .add2_value (IDU_add2_value),
        .add1_value (IDU_add1_value),
        .rs1_value (IDU_rs1_value),
        .rs2_value (IDU_rs2_value),
        .csr_wen_next (IDU_csr_wen),
        .R_wen_next (IDU_R_wen),
        .rd_value_next(IDU_rd_value),
        .mem_wen (IDU_mem_wen),
        .mem_ren (IDU_mem_ren),
        .inv_flag (IDU_inv_flag),
        .branch_flag (IDU_branch_flag),
        .jump_flag (IDU_jump_flag),
        .alu_opcode (IDU_alu_opcode),
        .pc_out (IDU_pc),
        .rs1 (IDU_rs1),
        .rs2 (IDU_rs2),
        .a0_value (IDU_a0_value),
        .mepc_out (IDU_mepc_out),
        .mtvec_out (IDU_mtvec_out),
        .valid_last (IFU_valid),
        .ready_last (IDU_ready),
        .ready_next (1'b1),  // IFID_EX_Reg always ready
        .valid_next (IDU_valid)
    );

    // IFID_EX_Reg?????
    IFID_EX_Reg IFID_EX_Reg_inst0 (
        .clock (cpu_clk),
        .reset (cpu_rst),
        .EXU_inst_clr (EXU_inst_clear),
        .valid_last (IDU_valid),
        .ready_last (1'b1),  // Always ready
        .ready_next (1'b1),  // EXU always ready
        .valid_next (IFID_EX_valid),
        .funct3 (IDU_funct3),
        .csr_wen (IDU_csr_wen),
        .R_wen (IDU_R_wen),
        .mem_wen (IDU_mem_wen),
        .mem_ren (IDU_mem_ren),
        .rd (IDU_rd),
        .pc (IDU_pc),
        .alu_opcode (IDU_alu_opcode),
        .inv_flag (IDU_inv_flag),
        .jump_flag (IDU_jump_flag),
        .branch_flag (IDU_branch_flag),
        .fetch_i_flag (IDU_fence_i_flag),
        .branch_pc (IDU_branch_pc),
        .rs2_value (EXU_rs2_in),
        .add1 (IDU_add1_value),
        .add2 (IDU_add2_value),
        .rd_value (IDU_rd_value),
        .funct3_reg (IFID_EX_funct3_reg),
        .csr_wen_reg (IFID_EX_csr_wen_reg),
        .R_wen_reg (IFID_EX_R_wen_reg),
        .mem_wen_reg (IFID_EX_mem_wen_reg),
        .mem_ren_reg (IFID_EX_mem_ren_reg),
        .rd_reg (IFID_EX_rd_reg),
        .pc_reg (IFID_EX_pc_reg),
        .alu_opcode_reg(IFID_EX_alu_opcode_reg),
        .inv_flag_reg (IFID_EX_inv_flag_reg),
        .jump_flag_reg(IFID_EX_jump_flag_reg),
        .branch_flag_reg(IFID_EX_branch_flag_reg),
        .fetch_i_reg (IFID_EX_fetch_i_reg),
        .branch_pc_reg(IFID_EX_branch_pc_reg),
        .rs2_value_reg(IFID_EX_rs2_value_reg),
        .add1_reg (IFID_EX_add1_reg),
        .add2_reg (IFID_EX_add2_reg),
        .rd_value_reg (IFID_EX_rd_value_reg)
    );

    // EXU?????
    EXU EXU_Inst0 (
        .funct3_reg (IFID_EX_funct3_reg),
        .csr_wen_reg (IFID_EX_csr_wen_reg),
        .R_wen_reg (IFID_EX_R_wen_reg),
        .mem_wen_reg (IFID_EX_mem_wen_reg),
        .mem_ren_reg (IFID_EX_mem_ren_reg),
        .rd_reg (IFID_EX_rd_reg),
        .pc_reg (IFID_EX_pc_reg),
        .alu_opcode_reg (IFID_EX_alu_opcode_reg),
        .inv_flag_reg (IFID_EX_inv_flag_reg),
        .jump_flag_reg (IFID_EX_jump_flag_reg),
        .branch_flag_reg (IFID_EX_branch_flag_reg),
        .fetch_i_reg (IFID_EX_fetch_i_reg),
        .branch_pc_reg (IFID_EX_branch_pc_reg),
        .rs2_value_reg (IFID_EX_rs2_value_reg),
        .add1_reg (IFID_EX_add1_reg),
        .add2_reg (IFID_EX_add2_reg),
        .rd_value_reg (IFID_EX_rd_value_reg),
        .funct3_next (EXU_funct3),
        .csr_wen_next (EXU_csr_wen),
        .R_wen_next (EXU_R_wen),
        .mem_wen_next (EXU_mem_wen),
        .mem_ren_next (EXU_mem_ren),
        .rd_next (EXU_rd),
        .pc_next (EXU_pc),
        .jump_flag_next (EXU_jump_flag),
        .rs2_value_next (EXU_rs2_value),
        .rd_value_next (EXU_rd_value),
        .Ex_result (EXU_Ex_result),
        .fetch_i_flag_next(EXU_fence_i_flag),
        .branch_flag_next (EXU_branch_flag),
        .branch_pc_next (EXU_branch_pc)
    );

    // EX_LSWB_Reg?????
    EX_LSWB_Reg EX_LSWB_Reg_inst0 (
        .clock (cpu_clk),
        .reset (cpu_rst),
        .valid_last (IFID_EX_valid),
        .ready_last (1'b1),  // Always ready
        .ready_next (WBU_ready),
        .valid_next (EX_LSWB_valid),
        .mem_ren (EXU_mem_ren),
        .mem_wen (EXU_mem_wen),
        .R_wen (EXU_R_wen),
        .csr_wen (EXU_csr_wen),
        .Ex_result (EXU_Ex_result),
        .rd (EXU_rd),
        .funct3 (EXU_funct3),
        .rs2_value (EXU_rs2_value),
        .jump_flag (EXU_jump_flag),
        .rd_value (EXU_rd_value),
        .pc (EXU_pc),
        .mem_ren_reg (EX_LSWB_mem_ren_reg),
        .mem_wen_reg (EX_LSWB_mem_wen_reg),
        .R_wen_reg (EX_LSWB_R_wen_reg),
        .csr_wen_reg (EX_LSWB_csr_wen_reg),
        .Ex_result_reg(EX_LSWB_Ex_result_reg),
        .rd_reg (EX_LSWB_rd_reg),
        .funct3_reg (EX_LSWB_funct3_reg),
        .rs2_value_reg(EX_LSWB_rs2_value_reg),
        .jump_flag_reg(EX_LSWB_jump_flag_reg),
        .rd_value_reg (EX_LSWB_rd_value_reg),
        .pc_reg (EX_LSWB_pc_reg)
    );

    // LSU?????
    LSU LSU_Inst0 (
        .mem_ren_reg (EX_LSWB_mem_ren_reg),
        .mem_wen_reg (EX_LSWB_mem_wen_reg),
        .R_wen_reg (EX_LSWB_R_wen_reg),
        .csr_wen_reg (EX_LSWB_csr_wen_reg),
        .Ex_result_reg (EX_LSWB_Ex_result_reg),
        .rd_reg (EX_LSWB_rd_reg),
        .funct3_reg (EX_LSWB_funct3_reg),
        .rs2_value_reg (EX_LSWB_rs2_value_reg),
        .jump_flag_reg (EX_LSWB_jump_flag_reg),
        .rd_value_reg (EX_LSWB_rd_value_reg),
        .pc_reg (EX_LSWB_pc_reg),
        .rd_value_next (LSU_rd_value),
        .R_wen_next (LSU_R_wen),
        .LSU_Rdata (LSU_Rdata),
        .csr_wen_next (LSU_csr_wen),
        .Ex_result_next (LSU_Ex_result),
        .rd_next (LSU_rd),
        .mem_ren_next (LSU_mem_ren),
        .jump_flag_next (LSU_jump_flag),
        .pc_next (LSU_pc),
        .addr (perip_addr),
        .wen (perip_wen),
        .wdata (perip_wdata),
        .mask (perip_mask),
        .rdata (perip_rdata)
    );

    // WBU?????
    WBU WBU_inst0 (
        .clock (cpu_clk),
        .reset (cpu_rst),
        .MEM_Rdata (LSU_Rdata),
        .Ex_result (LSU_Ex_result),
        .rd_value (LSU_rd_value),
        .rd (LSU_rd),
        .csr_wen (LSU_csr_wen),
        .R_wen (LSU_R_wen),
        .mem_ren (LSU_mem_ren),
        .jump_flag (LSU_jump_flag),
        .pc (LSU_pc),
        .R_wen_next (WBU_R_wen),
        .csr_wen_next (WBU_csr_wen),
        .csrd (WBU_csrd),
        .rd_value_next(WBU_rd_value),
        .pc_out (WBU_pc),
        .valid (EX_LSWB_valid),
        .ready (WBU_ready),
        .rd_next (WBU_rd),
        .valid_next (WBU_valid)
    );

endmodule

