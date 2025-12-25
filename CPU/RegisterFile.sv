`include "para.sv"
module RegisterFile #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
    input clock,
    input [DATA_WIDTH-1:0] wdata,
    input [ADDR_WIDTH-1:0] waddr,
    input wen,
    input reset,
    input [ADDR_WIDTH-1:0] rs1_addr,
    input [ADDR_WIDTH-1:0] rs2_addr,
    output [DATA_WIDTH-1:0] rs1_value,
    output [DATA_WIDTH-1:0] rs2_value,
    output [DATA_WIDTH-1:0] a0_value
);
    logic [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];

    // 添加复位逻辑
    always @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
                rf[i] <= 0;
            end
        end else if (wen && waddr != 0) begin  // x0寄存器始终为0
            rf[waddr] <= wdata;
        end
    end

    // 确保x0寄存器始终为0
    assign rs1_value = (rs1_addr == 0) ? 0 : rf[rs1_addr];
    assign rs2_value = (rs2_addr == 0) ? 0 : rf[rs2_addr];
    assign a0_value = rf[10]; 
endmodule

