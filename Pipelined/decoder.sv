module decoder(input logic [1:0] Op,
               input logic [5:0] Funct,
               input logic [3:0] Rd,
               input logic [11:0] Src2,
               output logic [1:0] FlagWriteD,
               output logic PCSrcD, RegWriteD, MemWriteD,
               output logic BranchD,
               output logic MemtoRegD, ALUSrcD, NoWriteD,
               output logic [1:0] ImmSrcD, RegSrcD,
               output logic [3:0] ALUControlD,
               output logic [1:0] RegControlD);

    logic [9:0] controls;
    logic ALUOp;

    // Main Decoder
    always_comb
        casex(Op)
            2'b00: if (Funct[5]) controls = 10'b0000101001; // Data-processing immediate
                   else controls = 10'b0000001001; // Data-processing register
        
            2'b01: if (Funct[0]) controls = 10'b0001111000; // LDR
                   else controls = 10'b1001110100; // STR
                   
            2'b10: controls = 10'b0110100010; // B

            default: controls = 10'bx; // Unimplemented
        endcase

    assign {RegSrcD, ImmSrcD, ALUSrcD, MemtoRegD, RegWriteD, MemWriteD, BranchD, ALUOp} = controls;

    // ALU Decoder
    always_latch begin
        if (ALUOp) begin
            case(Funct[4:1])
                4'b0100: begin
                        ALUControlD = 4'b0000; // ADD
                        NoWriteD = 1'b0;
                        FlagWriteD = {Funct[0], Funct[0]};
                end

                4'b0010: begin
                        ALUControlD = 4'b0001; // SUB
                        NoWriteD = 1'b0;
                        FlagWriteD = {Funct[0], Funct[0]};
                end

                4'b0011: begin
                        ALUControlD = 4'b0101; // RSB
                        NoWriteD = 1'b0;
                        FlagWriteD = {Funct[0], Funct[0]};
                end

                4'b0000: begin
                        ALUControlD = 4'b0010; // AND
                        NoWriteD = 1'b0;
                        FlagWriteD = {Funct[0], 1'b0};
                end

                4'b1100: begin
                        ALUControlD = 4'b0011; // ORR
                        NoWriteD = 1'b0;
                        FlagWriteD = {Funct[0], 1'b0};
                end

                4'b0001: begin
                        ALUControlD = 4'b0111; // EOR
                        NoWriteD = 1'b0;
                        FlagWriteD = {Funct[0], 1'b0};
                end

                4'b1010: begin
                    RegControlD = 2'bx;
                    if (Funct[0]) begin
                        ALUControlD = 4'b0001; // CMP
                        NoWriteD = 1'b1;
                        FlagWriteD = 2'b11;
                    end 
                end

                4'b1011: begin
                    RegControlD = 2'bx;
                    if (Funct[0]) begin           
                        ALUControlD = 4'b0000; // CMN
                        NoWriteD = 1'b1;
                        FlagWriteD = 2'b11;
                    end 
                end

                4'b1000: begin    
                    RegControlD = 2'bx;
                    if (Funct[0]) begin            
                        ALUControlD = 4'b0010; // TST
                        NoWriteD = 1'b1;
                        FlagWriteD = 2'b11;
                    end 
                end

                4'b1001: begin    
                    if (Funct[0]) begin         
                        ALUControlD = 4'b0111; // TEQ
                        NoWriteD = 1'b1;
                        FlagWriteD = 2'b11;
                    end
                end

                4'b1101: begin
                    NoWriteD = 1'b0;
                    ALUControlD = 4'b0110;
                    FlagWriteD = 2'b10;

                    if (Funct[5] | (Src2[11:4] == 8'b0)) RegControlD = 2'b00;  // MOV

                    else if (~Funct[5] & (Src2[6:5] == 2'b00) & (Src2[11:4] != 1'b0)) RegControlD = 2'b01; // LSL

                    else if (~Funct[5] & (Src2[6:5] == 2'b01)) RegControlD = 2'b10; // LSR

                    else if (~Funct[5] & (Src2[6:5] == 2'b10)) RegControlD = 2'b11; // ASR

                    else RegControlD = 2'bx;

                end

                4'b1111: begin               
                        ALUControlD = 4'b1110; // MVN
                        NoWriteD = 1'b0;
                        FlagWriteD = 2'b10;
                end

                4'b1110: begin
                        ALUControlD = 4'b1010; //BIC
                        NoWriteD = 1'b0;
                        FlagWriteD = 2'b10;
                end
                
                default: begin
                    ALUControlD = 2'bx; // unimplemented
                    NoWriteD = 1'bx;
                    FlagWriteD = 2'bx;
                end
            endcase
        // update flags if S bit is set (C & V only for arith)
            
        end else begin
            ALUControlD = 4'b0000; // add for non-DP instructions
            NoWriteD = 1'b0; 
            FlagWriteD = 2'b00; // don't update Flags
        end
    end
    // PC Logic
    assign PCSrcD = ((Rd == 4'b1111) & RegWriteD) | BranchD;
    
endmodule