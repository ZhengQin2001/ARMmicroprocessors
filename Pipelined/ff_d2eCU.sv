module ff_d2eCU (input logic clk, reset, FlushE,
                 input logic PCSrcD, RegWriteD, MemtoRegD, MemWriteD,
                 input logic [3:0] ALUControlD, 
                 input logic [1:0] RegControlD,
                 input logic BranchD, ALUSrcD,
                 input logic [1:0] FlagWriteD,
                 input logic [1:0] ImmSrcD,
                 input logic [3:0] CondD,
                 input logic NoWriteD,
                 output logic PCSrcE, RegWriteE, MemtoRegE, MemWriteE,
                 output logic [3:0] ALUControlE,
                 output logic [1:0] RegControlE,
                 output logic BranchE, ALUSrcE, 
                 output logic [1:0] FlagWriteE,
                 output logic [3:0] CondE,
                 output logic NoWriteE
                 //input logic [3:0] Flags,
                 //output logic [3:0] FlagsE
                 );
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            PCSrcE <= 0;
            RegWriteE <= 0;
            MemtoRegE <= 0;
            MemWriteE <= 0;
            ALUControlE <= 4'b0;
            RegControlE <= 2'b0;
            BranchE <= 0;
            ALUSrcE <= 0;
            FlagWriteE <= 2'b0;
            CondE <= 4'b0;
            //FlagsE <= 4'b0;
            NoWriteE <= 1'b0;
        end
        else begin
            PCSrcE <= FlushE ? 0:PCSrcD;
            RegWriteE <= FlushE ? 0:RegWriteD;
            MemtoRegE <= FlushE ? 0:MemtoRegD;
            MemWriteE <= FlushE ? 0:MemWriteD;
            ALUControlE <= FlushE ? 4'b0:ALUControlD;
            RegControlE <= FlushE ? 2'b0:RegControlD;
            BranchE <= FlushE ? 0:BranchD;
            ALUSrcE <= FlushE ? 0:ALUSrcD;
            FlagWriteE <= FlushE ? 0:FlagWriteD;
            CondE <= FlushE ? 4'b0:CondD;
            //FlagsE <= FlushE ? 4'b0:Flags;
            NoWriteE <= FlushE ? 1'b0:NoWriteD;
        end
    end

endmodule