`include "decoder.sv"
`include "condLogic.sv"

module controller(input logic clk, reset,
                  input logic [31:0] Instr,
                  input logic [3:0] ALUFlags,
                  output logic [1:0] RegSrc,
                  output logic RegWrite,
                  output logic [1:0] ImmSrc,
                  output logic ALUSrc, NoWrite,
                  output logic [3:0] ALUControl,
                  output logic [1:0] RegControl,
                  output logic MemWrite, MemtoReg,
                  output logic PCSrc);
    logic [1:0] FlagW;
    logic PCS, RegW, MemW;
    decoder dec(Instr[27:26], Instr[25:20], Instr[15:12], Instr[11:0], FlagW, PCS,
     RegW, MemW, MemtoReg, ALUSrc, NoWrite, ImmSrc, RegSrc, ALUControl, RegControl);
    condlogic cl(clk, reset, Instr[31:28], ALUFlags, FlagW, PCS, RegW, MemW, NoWrite, PCSrc, RegWrite, MemWrite); 
endmodule