`include "flopenr.sv"

module condlogic(input logic clk, reset,
                 input logic [3:0] CondE,
                 input logic [3:0] ALUFlags,
                 input logic [1:0] FlagWriteE,
                 input logic PCSrcE, RegWriteE, MemWriteE, NoWriteE, BranchE,
                 //input logic [3:0] FlagsE,
                 output logic PCSrcEout, RegWriteEout, MemWriteEout, BranchTakenE
                 //output logic [3:0] Flags
                 );
    logic [1:0] FlagWriteEout;
    logic [3:0] FlagsE;
    logic CondExE;
    flopenr #(2)flagreg1(clk, reset, FlagWriteEout[1], ALUFlags[3:2], FlagsE[3:2]);
    flopenr #(2)flagreg0(clk, reset, FlagWriteEout[0], ALUFlags[1:0], FlagsE[1:0]);
    // write controls are conditional
    condcheck cc(CondE, FlagsE, CondExE);
    assign FlagWriteEout = FlagWriteE & {2{CondExE}};
    assign RegWriteEout = RegWriteE & CondExE & {~NoWriteE};
    assign MemWriteEout = MemWriteE & CondExE;
    assign PCSrcEout = PCSrcE & CondExE;
    assign BranchTakenE = BranchE & CondExE;

endmodule


module condcheck(input logic [3:0] CondE,
                 input logic [3:0] FlagsE,
                 output logic CondExE);
    logic neg, zero, carry, overflow, ge;
    assign {neg, zero, carry, overflow} = FlagsE;
    assign ge = (neg == overflow);
    always_comb
        case(CondE)
            4'b0000: CondExE = zero; // EQ
            4'b0001: CondExE = ~zero; // NE
            4'b0010: CondExE = carry; // CS
            4'b0011: CondExE = ~carry; // CC
            4'b0100: CondExE = neg; // MI
            4'b0101: CondExE = ~neg; // PL
            4'b0110: CondExE = overflow; // VS
            4'b0111: CondExE = ~overflow; // VC
            4'b1000: CondExE = carry & ~zero; // HI
            4'b1001: CondExE = ~(carry & ~zero); // LS
            4'b1010: CondExE = ge; // GE
            4'b1011: CondExE = ~ge; // LT
            4'b1100: CondExE = ~zero & ge; // GT
            4'b1101: CondExE = ~(~zero & ge); // LE
            4'b1110: CondExE = 1'b1; // Always
            default: CondExE = 1'bx; // undefined
        endcase

endmodule