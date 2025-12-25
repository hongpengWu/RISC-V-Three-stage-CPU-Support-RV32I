`include "para.sv"

module EX_LSWB_Reg (
    input clock,
    input reset,

    // Control signals
    input valid_last,
    input ready_last,
    input ready_next,
    output logic valid_next,

    // Data inputs from EXU
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

    // Data outputs to LSU
    output logic mem_ren_reg,
    output logic mem_wen_reg,
    output logic R_wen_reg,
    output logic [3:0] csr_wen_reg,
    output logic [31:0] Ex_result_reg,
    output logic [4:0] rd_reg,
    output logic [2:0] funct3_reg,
    output logic [31:0] rs2_value_reg,
    output logic jump_flag_reg,
    output logic [31:0] rd_value_reg,
    output logic [31:0] pc_reg
);

    // 统一握手协议
    always @(posedge clock) begin
        if (reset)
            valid_next <= 1'b0;
        else if (valid_last & ready_last)
            valid_next <= 1'b1;
        else
            valid_next <= 1'b0;
    end

    always @(posedge clock) begin
        if (reset) begin
            mem_ren_reg   <= 0;
            mem_wen_reg   <= 0;
            R_wen_reg     <= 0;
            csr_wen_reg   <= 0;
            Ex_result_reg <= 0;
            rd_value_reg  <= 0;
            rd_reg        <= 0;
            funct3_reg    <= 0;
            rs2_value_reg <= 0;
            jump_flag_reg <= 0;
            pc_reg        <= 0;
        end else if (valid_last & ready_last) begin
            mem_ren_reg   <= mem_ren;
            mem_wen_reg   <= mem_wen;
            R_wen_reg     <= R_wen;
            csr_wen_reg   <= csr_wen;
            Ex_result_reg <= Ex_result;
            rd_value_reg  <= rd_value;
            rd_reg        <= rd;
            funct3_reg    <= funct3;
            rs2_value_reg <= rs2_value;
            jump_flag_reg <= jump_flag;
            pc_reg        <= pc;
        end
    end

endmodule