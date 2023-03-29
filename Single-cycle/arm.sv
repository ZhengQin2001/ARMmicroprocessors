`include "controller.sv"
`include "datapath.sv"

module arm (input logic clk, reset,
            output logic [31:0] PC,
            input logic [31:0] Instr,
            output logic MemWrite,
            output logic [31:0] ALUResult, WriteData,
            input logic [31:0] ReadData);

    logic [3:0] ALUFlags;
    logic RegWrite, ALUSrc, NoWrite, MemtoReg, PCSrc;
    logic [1:0] RegSrc, ImmSrc;
    logic [3:0] ALUControl;
    logic [1:0] RegControl;

    controller c(clk, reset, Instr[31:0], ALUFlags, RegSrc, RegWrite, ImmSrc,
        ALUSrc, NoWrite, ALUControl, RegControl, MemWrite, MemtoReg, PCSrc);
    datapath dp(clk, reset, RegSrc, RegWrite, ImmSrc, ALUSrc, ALUControl, RegControl, 
        MemtoReg, PCSrc, ALUFlags, PC, Instr, ALUResult, WriteData, ReadData);
    
endmodule