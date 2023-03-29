`include "controller.sv"
`include "datapath.sv"
`include "hazard.sv"

module arm (input logic clk, reset,
            output logic [31:0] PCF,
            input logic [31:0] InstrF,
            output logic MemWriteM,
            output logic [31:0] ALUOutM, WriteDataM,
            input logic [31:0] ReadDataM);

    logic [3:0] ALUFlags;
    logic RegWriteW, ALUSrcE, MemtoRegW, PCSrc;
    logic [1:0] RegSrcD, ImmSrcD;
    logic [3:0] ALUControlE;
    logic [1:0] RegControlE;
    logic StallD, StallF, FlushD, FlushE;
    logic BranchTakenE;
    logic [1:0] ForwardAE, ForwardBE;
    logic [4:0] Match;
    logic [31:0] InstrD;

    controller c(clk, reset, InstrD[31:0], ALUFlags, RegSrcD, RegWriteW, ImmSrcD, ALUSrcE, 
        ALUControlE, RegControlE, MemWriteM, MemtoRegW, MemtoRegE, PCSrcW, BranchTakenE, FlushE, PCWrPendingF, RegWriteM);
    datapath dp(clk, reset, RegSrcD, RegWriteW, ImmSrcD, ALUSrcE, ALUControlE, RegControlE, 
        MemtoRegW, PCSrcW, StallF, StallD, FlushD, FlushE, BranchTakenE, ForwardAE, ForwardBE,
        ALUFlags, PCF, InstrF, InstrD, ALUOutM, WriteDataM, ReadDataM, Match);
    hazard hu(Match, PCSrcW, PCWrPendingF, RegWriteM, RegWriteW, MemtoRegE, BranchTakenE, ForwardAE,
        ForwardBE, StallD, StallF, FlushD, FlushE);

endmodule