/* Deal with the Data hazard - Optimized for timing */
module Data_hazard(
    input [4:0] IDU_rs1,
    input [4:0] IDU_rs2,
    input [4:0] EXU_rd,
    input [4:0] MEM_rd,
    input IDU_valid,
    input EXU_valid,
    input MEM_valid,
    input MEM_mem_ren,
    input EXU_R_Wen,
    input MEM_R_Wen,
    output [1:0] IDU_rs1_choice,
    output [1:0] IDU_rs2_choice
);
    // ???????????????????????
    logic exu_rs1_match, exu_rs2_match;
    logic mem_rs1_match, mem_rs2_match;
    logic exu_rs1_valid, exu_rs2_valid;
    logic mem_rs1_valid, mem_rs2_valid;
    // ??????????????????
    assign exu_rs1_match = (EXU_rd == IDU_rs1) && (EXU_rd != 5'b0);
    assign exu_rs2_match = (EXU_rd == IDU_rs2) && (EXU_rd != 5'b0);
    assign mem_rs1_match = (MEM_rd == IDU_rs1) && (MEM_rd != 5'b0);
    assign mem_rs2_match = (MEM_rd == IDU_rs2) && (MEM_rd != 5'b0);
    // ???????????????????
    assign exu_rs1_valid = EXU_R_Wen && exu_rs1_match;
    assign exu_rs2_valid = EXU_R_Wen && exu_rs2_match;
    assign mem_rs1_valid = MEM_R_Wen && mem_rs1_match;
    assign mem_rs2_valid = MEM_R_Wen && mem_rs2_match;
    // ??????????????????
    assign IDU_rs1_choice = exu_rs1_valid ? 2'b01 : (mem_rs1_valid ? (MEM_mem_ren ? 2'b11 : 2'b10) : 2'b00);
    assign IDU_rs2_choice = exu_rs2_valid ? 2'b01 : (mem_rs2_valid ? (MEM_mem_ren ? 2'b11 : 2'b10) : 2'b00);
endmodule                                                           //Aribter



