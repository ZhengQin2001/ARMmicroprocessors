`include "decoder.sv"
`include "condLogic.sv"
`include "ff_d2eCU.sv"
`include "ff_e2mCU.sv"
`include "ff_m2wCU.sv"

module controller(input logic clk, reset,
                  input logic [31:0] InstrD,
                  input logic [3:0] ALUFlags,
                  output logic [1:0] RegSrcD,
                  output logic RegWriteW,
                  output logic [1:0] ImmSrcD,
                  output logic ALUSrcE,
                  output logic [3:0] ALUControlE,
                  output logic [1:0] RegControlE,
                  output logic MemWriteM, MemtoRegW, MemtoRegE,
                  output logic PCSrcW, BranchTakenE,
                  //Hazard unit
                  input logic FlushE,
                  output logic PCWrPendingF,
                  output logic RegWriteM);
    logic [1:0] FlagWriteD;
    logic PCSrcD, RegWriteD, MemWriteD;
    logic BranchD, BranchE;
    logic MemtoRegD, ALUSrcD, NoWriteD, NoWriteE;
    logic [3:0] ALUControlD;
    logic [1:0] RegControlD;
    logic PCSrcE, RegWriteE, MemWriteE;
    logic PCSrcEout, RegWriteEout, MemWriteEout;
    logic PCSrcM, MemtoRegM;
    logic [1:0] FlagWriteE;
    logic [3:0] CondE;

    decoder dec(InstrD[27:26], InstrD[25:20], InstrD[15:12], InstrD[11:0], FlagWriteD, PCSrcD,
     RegWriteD, MemWriteD, BranchD, MemtoRegD, ALUSrcD, NoWriteD, ImmSrcD, RegSrcD, ALUControlD, RegControlD);
    ff_d2eCU d2eCU(clk, reset, FlushE, PCSrcD, RegWriteD, MemtoRegD, MemWriteD, ALUControlD, RegControlD, BranchD, ALUSrcD, FlagWriteD,
     ImmSrcD, InstrD[31:28], NoWriteD, PCSrcE, RegWriteE, MemtoRegE, MemWriteE, ALUControlE, RegControlE, BranchE, 
     ALUSrcE, FlagWriteE, CondE, NoWriteE);
    condlogic cl(clk, reset, CondE, ALUFlags, FlagWriteE, PCSrcE, RegWriteE, MemWriteE, NoWriteE, BranchE, PCSrcEout,
     RegWriteEout, MemWriteEout, BranchTakenE);
    ff_e2mCU e2mCU(clk, reset, PCSrcEout, RegWriteEout, MemtoRegE, MemWriteEout, PCSrcM, RegWriteM, MemtoRegM, MemWriteM); 
    ff_m2wCU m2wCU(clk, reset, PCSrcM, RegWriteM, MemtoRegM, PCSrcW, RegWriteW, MemtoRegW);

    // Control Hazards
    assign PCWrPendingF = PCSrcD + PCSrcE + PCSrcM;
endmodule