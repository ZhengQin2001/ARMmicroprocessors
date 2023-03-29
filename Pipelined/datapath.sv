`include "reg_file.sv"
`include "mux2.sv"
`include "mux3.sv"
`include "flopr.sv"
`include "extend.sv"
`include "adder.sv"
`include "ALU.sv"
`include "ff_f2d.sv"
`include "ff_d2eDP.sv"
`include "ff_e2mDP.sv"
`include "ff_m2wDP.sv"

module datapath(input logic clk, reset,
                input logic [1:0] RegSrcD,
                input logic RegWriteW,
                input logic [1:0] ImmSrcD,
                input logic ALUSrcE, 
                input logic [3:0] ALUControlE,
                input logic [1:0] RegControlE,
                input logic MemtoRegW,
                input logic PCSrcW,
                input logic StallF, StallD,
                input logic FlushD, FlushE,
                input logic BranchTakenE,
                input logic [1:0] ForwardAE, ForwardBE,
                output logic [3:0] ALUFlags,
                output logic [31:0] PCF,
                input logic [31:0] InstrF,
                output logic [31:0] InstrD,
                output logic [31:0] ALUOutM, WriteDataM,
                input logic [31:0] ReadDataM,
                output logic [4:0] Match);

    logic [31:0] PCNextF, PCPlus4F, PCPlus8D, PCBF;
    logic [3:0] RA1D, RA2D, RA1E, RA2E;
    logic [31:0] RD1D, RD2D, ExtImmD;
    logic [31:0] RD1E, RD2E, ExtImmE;
    logic [3:0] WA3E;

    logic [31:0] SrcAE, SrcBE, ResultW;
    logic [31:0] ALUResultE, WriteDataE;
    logic [3:0] WA3M;
    
    logic [31:0] ReadDataW, ALUOutW;
    logic [3:0] WA3W;

    // next PC logic
    assign PCPlus8D = PCPlus4F;

    mux2 #(32) pcmux(PCPlus4F, ResultW, PCSrcW, PCBF);
    mux2 #(32) pcmuxB(PCBF, ALUResultE, BranchTakenE, PCNextF);
    flopenr #(32) pcreg(clk, reset, ~StallF, PCNextF, PCF);
    adder #(32) pcadd1(PCF, 32'b100, PCPlus4F);
    ff_f2d ff_f2d_inst(clk, reset, ~StallD, FlushD, InstrF, InstrD); // Fetch-to-Decode

    // register file logic
    mux2 #(4) ra1mux(InstrD[19:16], 4'b1111, RegSrcD[0], RA1D);
    mux2 #(4) ra2mux(InstrD[3:0], InstrD[15:12], RegSrcD[1], RA2D);
    regfile rf(clk, RegWriteW, RA1D, RA2D, WA3W, ResultW, PCPlus8D, RD1D, RD2D); 
    extend ext(InstrD[23:0], ImmSrcD, ExtImmD);
    ff_d2eDP ff_d2eDP_inst(clk, reset, FlushE, RD1D, RD2D, RA1D, RA2D, InstrD[15:12], ExtImmD, RD1E, RD2E, RA1E, RA2E, WA3E, ExtImmE); // Decode-to-Execute
    
    // ALU logic
    mux3 #(32) mux3A(RD1E, ResultW, ALUOutM, ForwardAE, SrcAE);
    mux3 #(32) mux3B(RD2E, ResultW, ALUOutM, ForwardBE, WriteDataE);
    mux2 #(32) srcbmux(WriteDataE, ExtImmE, ALUSrcE, SrcBE);
    alu alu(SrcAE, SrcBE, ALUControlE, RegControlE, ALUResultE, ALUFlags);
    ff_e2mDP ff_e2mDP_inst(clk, reset, ALUResultE, WriteDataE, WA3E, ALUOutM, WriteDataM, WA3M); // Execute-to-Memory

    // write data logic
    ff_m2wDP ff_m2wDP_inst(clk, reset, ReadDataM, ALUOutM, WA3M, ReadDataW, ALUOutW, WA3W);  // Memory-to-Writeback
    mux2 #(32) resmux(ALUOutW, ReadDataW, MemtoRegW, ResultW);

    // hazards
    assign Match_1E_M = (RA1E == WA3M);
    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_M = (RA2E == WA3M);
    assign Match_2E_W = (RA2E == WA3W);
    assign Match_12D_E = (RA1D == WA3E) + (RA2D == WA3E);

    assign Match = {Match_12D_E, Match_1E_M, Match_2E_M, Match_1E_W, Match_2E_W};

endmodule