/* verilator lint_off UNUSEDSIGNAL */

`timescale 1ns / 1ps

module LSU (
    input clock,
    input reset,

    input mem_ren,
    input mem_wen,
    input R_wen,
    input [3:0] csr_wen,
    input [31:0] Ex_result,
    input [4:0] rd,
    input [2:0] funct3,
    input [31:0] rs2_value,
    input jump_flag,
    input [31:0] rd_value,
    input [31:0] pc,


    output [31:0] rd_value_next,
    output R_wen_next,
    output [31:0] LSU_Rdata,
    output [31:0] LSU_Rdata_raw,
    output [2:0] funct3_next,
    output [3:0] csr_wen_next,
    output [31:0] Ex_result_next,
    output [4:0] rd_next,
    output mem_ren_next,
    output jump_flag_next,

    output logic [31:0] pc_out,
    output logic [31:0] pc_wb,
    output [31:0] addr,
    output wen,
    output [31:0] wdata,
    output [1:0] mask,
    input [31:0] rdata,

    output [31:0] rdata_wb_raw,
    output [2:0] funct3_wb,
    output [3:0] csr_wen_wb,
    output [31:0] Ex_result_wb,
    output [31:0] rd_value_wb,
    output [4:0] rd_wb,
    output mem_ren_wb,
    output R_wen_wb,
    output jump_flag_wb,
    output [31:0] forward_val_wb,
    output logic valid_wb,

    output [31:0] Ex_result_pipe,
    output [4:0] rd_pipe,
    output mem_ren_pipe,
    output R_wen_pipe,
    output valid_pipe,
    output [31:0] forward_val_pipe,

    input valid_last,
    output logic ready_last,

    input ready_next,
    output logic valid_next


);

  logic        mem_ren_reg;
  logic        mem_wen_reg;
  logic        R_wen_reg;
  logic [3:0]  csr_wen_reg;
  (* max_fanout = 32 *) logic [31:0] Ex_result_addr_reg;
  (* max_fanout = 16 *) logic [31:0] Ex_result_fwd_reg;
  logic [4:0]  rd_reg;
  logic [2:0]  funct3_reg;
  logic [31:0] rs2_value_reg;
  logic        jump_flag_reg;
  logic [31:0] rd_value_reg;
  logic [31:0] pc_reg;
  logic        valid_reg;

  logic [31:0] rdata_8i;
  logic [31:0] rdata_16i;
  logic [31:0] rdata_8u;
  logic [31:0] rdata_16u;

  logic [31:0] rdata_ex;

  logic        mem_ren_reg_pipe;
  logic        mem_wen_reg_pipe;
  logic        R_wen_reg_pipe;
  logic [3:0]  csr_wen_reg_pipe;
  (* max_fanout = 8 *) logic [31:0] Ex_result_addr_reg_pipe;
  logic [31:0] Ex_result_fwd_reg_pipe;
  logic [4:0]  rd_reg_pipe;
  logic [2:0]  funct3_reg_pipe;
  logic [31:0] rs2_value_reg_pipe;
  logic        jump_flag_reg_pipe;
  logic [31:0] rd_value_reg_pipe;
  logic [31:0] pc_reg_pipe;
  logic        valid_reg_pipe;

  logic        mem_ren_reg2;
  logic        R_wen_reg2;
  logic [3:0]  csr_wen_reg2;
  logic [31:0] Ex_result_fwd_reg2;
  logic [4:0]  rd_reg2;
  logic [2:0]  funct3_reg2;
  logic        jump_flag_reg2;
  logic [31:0] rd_value_reg2;
  logic [31:0] pc_reg2;
  logic        valid_reg2;
  logic [31:0] rdata_reg2;

  logic [31:0] rdata_8i2;
  logic [31:0] rdata_16i2;
  logic [31:0] rdata_8u2;
  logic [31:0] rdata_16u2;
  logic [31:0] rdata_wb2;

  assign ready_last = ready_next;
  assign valid_next = valid_reg;

  assign addr  = {Ex_result_addr_reg_pipe[31:18], 2'b00, Ex_result_addr_reg_pipe[15:0]};
  assign wdata = rs2_value_reg_pipe;
  assign mask  = funct3_reg_pipe[1:0];
  assign wen   = mem_wen_reg_pipe;

  assign LSU_Rdata      = rdata_ex;
  assign LSU_Rdata_raw  = rdata;
  assign funct3_next    = funct3_reg;
  assign Ex_result_next = Ex_result_fwd_reg;
  assign rd_value_next  = rd_value_reg;
  assign rd_next        = rd_reg;
  assign mem_ren_next   = mem_ren_reg;
  assign R_wen_next     = R_wen_reg;
  assign jump_flag_next = jump_flag_reg;
  assign csr_wen_next   = csr_wen_reg;
  assign pc_out         = pc_reg;

  assign Ex_result_pipe = Ex_result_fwd_reg_pipe;
  assign rd_pipe        = rd_reg_pipe;
  assign mem_ren_pipe   = mem_ren_reg_pipe;
  assign R_wen_pipe     = R_wen_reg_pipe;
  assign valid_pipe     = valid_reg_pipe;

  logic wb_sel_jmp_csr_pipe;
  assign wb_sel_jmp_csr_pipe = jump_flag_reg_pipe | (|csr_wen_reg_pipe);
  assign forward_val_pipe = wb_sel_jmp_csr_pipe ? rd_value_reg_pipe : Ex_result_fwd_reg_pipe;

  assign pc_wb          = pc_reg2;
  assign rdata_wb_raw   = rdata_reg2;
  assign funct3_wb      = funct3_reg2;
  assign csr_wen_wb     = csr_wen_reg2;
  assign Ex_result_wb   = Ex_result_fwd_reg2;
  assign rd_value_wb    = rd_value_reg2;
  assign rd_wb          = rd_reg2;
  assign mem_ren_wb     = mem_ren_reg2;
  assign R_wen_wb       = R_wen_reg2;
  assign jump_flag_wb   = jump_flag_reg2;
  assign valid_wb       = valid_reg2;

  logic wb_sel_jmp_csr2;
  assign wb_sel_jmp_csr2 = jump_flag_reg2 | (|csr_wen_reg2);
  assign forward_val_wb = wb_sel_jmp_csr2 ? rd_value_reg2 : (mem_ren_reg2 ? rdata_wb2 : Ex_result_fwd_reg2);

  always_ff @(posedge clock) begin
    if (reset) begin
      mem_ren_reg   <= 1'b0;
      mem_wen_reg   <= 1'b0;
      R_wen_reg     <= 1'b0;
      csr_wen_reg   <= 4'b0;
      Ex_result_addr_reg <= 32'b0;
      Ex_result_fwd_reg  <= 32'b0;
      rd_reg        <= 5'b0;
      funct3_reg    <= 3'b0;
      rs2_value_reg <= 32'b0;
      jump_flag_reg <= 1'b0;
      rd_value_reg  <= 32'b0;
      pc_reg        <= 32'b0;
      valid_reg     <= 1'b0;

      mem_ren_reg_pipe   <= 1'b0;
      mem_wen_reg_pipe   <= 1'b0;
      R_wen_reg_pipe     <= 1'b0;
      csr_wen_reg_pipe   <= 4'b0;
      Ex_result_addr_reg_pipe <= 32'b0;
      Ex_result_fwd_reg_pipe  <= 32'b0;
      rd_reg_pipe        <= 5'b0;
      funct3_reg_pipe    <= 3'b0;
      rs2_value_reg_pipe <= 32'b0;
      jump_flag_reg_pipe <= 1'b0;
      rd_value_reg_pipe  <= 32'b0;
      pc_reg_pipe        <= 32'b0;
      valid_reg_pipe     <= 1'b0;

      mem_ren_reg2  <= 1'b0;
      R_wen_reg2    <= 1'b0;
      csr_wen_reg2  <= 4'b0;
      Ex_result_fwd_reg2 <= 32'b0;
      rd_reg2       <= 5'b0;
      funct3_reg2   <= 3'b0;
      jump_flag_reg2 <= 1'b0;
      rd_value_reg2 <= 32'b0;
      pc_reg2       <= 32'b0;
      valid_reg2    <= 1'b0;
      rdata_reg2    <= 32'b0;
    end else if (ready_next) begin
      mem_ren_reg2  <= mem_ren_reg_pipe;
      R_wen_reg2    <= R_wen_reg_pipe;
      csr_wen_reg2  <= csr_wen_reg_pipe;
      Ex_result_fwd_reg2 <= Ex_result_fwd_reg_pipe;
      rd_reg2       <= rd_reg_pipe;
      funct3_reg2   <= funct3_reg_pipe;
      jump_flag_reg2 <= jump_flag_reg_pipe;
      rd_value_reg2 <= rd_value_reg_pipe;
      pc_reg2       <= pc_reg_pipe;
      valid_reg2    <= valid_reg_pipe;
      rdata_reg2    <= rdata;

      mem_ren_reg_pipe   <= mem_ren_reg;
      mem_wen_reg_pipe   <= mem_wen_reg;
      R_wen_reg_pipe     <= R_wen_reg;
      csr_wen_reg_pipe   <= csr_wen_reg;
      Ex_result_addr_reg_pipe <= Ex_result_addr_reg;
      Ex_result_fwd_reg_pipe  <= Ex_result_fwd_reg;
      rd_reg_pipe        <= rd_reg;
      funct3_reg_pipe    <= funct3_reg;
      rs2_value_reg_pipe <= rs2_value_reg;
      jump_flag_reg_pipe <= jump_flag_reg;
      rd_value_reg_pipe  <= rd_value_reg;
      pc_reg_pipe        <= pc_reg;
      valid_reg_pipe     <= valid_reg;

      mem_ren_reg   <= mem_ren;
      mem_wen_reg   <= mem_wen;
      R_wen_reg     <= R_wen;
      csr_wen_reg   <= csr_wen;
      Ex_result_addr_reg <= Ex_result;
      Ex_result_fwd_reg  <= Ex_result;
      rd_reg        <= rd;
      funct3_reg    <= funct3;
      rs2_value_reg <= rs2_value;
      jump_flag_reg <= jump_flag;
      rd_value_reg  <= rd_value;
      pc_reg        <= pc;
      valid_reg     <= valid_last;
    end
  end

  always @(*) begin
    case (funct3_reg)
      3'b000:  rdata_ex = rdata_8i;
      3'b001:  rdata_ex = rdata_16i;
      3'b010:  rdata_ex = rdata;
      3'b100:  rdata_ex = rdata_8u;
      3'b101:  rdata_ex = rdata_16u;
      default: rdata_ex = 0;
    endcase
  end

  assign rdata_8u  = {24'd0, rdata[7:0]};
  assign rdata_16u = {16'd0, rdata[15:0]};

  /* verilator lint_off PINMISSING */
  sext #(
      .DATA_WIDTH(8),
      .OUT_WIDTH (32)
  ) sext_i8 (
      .data     (rdata[0+:8]),
      .sext_data(rdata_8i)
  );

  sext #(
      .DATA_WIDTH(16),
      .OUT_WIDTH (32)
  ) sext_i16 (
      .data     (rdata[0+:16]),
      .sext_data(rdata_16i)
  );

  assign rdata_8u2  = {24'd0, rdata_reg2[7:0]};
  assign rdata_16u2 = {16'd0, rdata_reg2[15:0]};

  /* verilator lint_off PINMISSING */
  sext #(
      .DATA_WIDTH(8),
      .OUT_WIDTH (32)
  ) sext_i8_2 (
      .data     (rdata_reg2[0+:8]),
      .sext_data(rdata_8i2)
  );

  sext #(
      .DATA_WIDTH(16),
      .OUT_WIDTH (32)
  ) sext_i16_2 (
      .data     (rdata_reg2[0+:16]),
      .sext_data(rdata_16i2)
  );

  always @(*) begin
    case (funct3_reg2)
      3'b000:  rdata_wb2 = rdata_8i2;
      3'b001:  rdata_wb2 = rdata_16i2;
      3'b010:  rdata_wb2 = rdata_reg2;
      3'b100:  rdata_wb2 = rdata_8u2;
      3'b101:  rdata_wb2 = rdata_16u2;
      default: rdata_wb2 = 0;
    endcase
  end


endmodule  //MEM
