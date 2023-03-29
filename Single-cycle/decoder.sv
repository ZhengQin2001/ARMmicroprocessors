module decoder(input logic [1:0] Op,
               input logic [5:0] Funct,
               input logic [3:0] Rd,
               input logic [11:0] Src2,
               output logic [1:0] FlagW,
               output logic PCS, RegW, MemW,
               output logic MemtoReg, ALUSrc, NoWrite,
               output logic [1:0] ImmSrc, RegSrc,
               output logic [3:0] ALUControl,
               output logic [1:0] RegControl);

    logic [9:0] controls;
    logic Branch, ALUOp;
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

    assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

    // ALU Decoder
    always_comb
        if (ALUOp) begin
            case(Funct[4:1])
                4'b0100: begin
                        ALUControl = 4'b0000; // ADD
                        NoWrite = 1'b0;
                        FlagW = {Funct[0], Funct[0]}; 
                        RegControl = 2'bx;
                end

                4'b0010: begin
                        ALUControl = 4'b0001; // SUB
                        NoWrite = 1'b0;
                        FlagW = {Funct[0], Funct[0]}; 
                        RegControl = 2'bx;
                end

                4'b0011: begin
                        ALUControl = 4'b0101; // RSB
                        NoWrite = 1'b0;
                        FlagW = {Funct[0], Funct[0]}; 
                        RegControl = 2'bx;
                end

                4'b0000: begin
                        ALUControl = 4'b0010; // AND
                        NoWrite = 1'b0;
                        FlagW = {Funct[0], 1'b0}; 
                        RegControl = 2'bx;
                end

                4'b1100: begin
                        ALUControl = 4'b0011; // ORR
                        NoWrite = 1'b0;
                        FlagW = {Funct[0], 1'b0}; 
                        RegControl = 2'bx;

                end

                4'b0001: begin
                        ALUControl = 4'b0111; // EOR
                        NoWrite = 1'b0;
                        FlagW = {Funct[0], 1'b0}; 
                        RegControl = 2'bx;
                end

                4'b1010: begin
                    if (Funct[0]) begin
                        ALUControl = 4'b0001; // CMP
                        NoWrite = 1'b1;
                        FlagW = 2'b11;
                        RegControl = 2'bx;
                    end else begin
                        ALUControl = 4'bx; 
                        NoWrite = 1'bx;
                        FlagW = 2'bx;
                        RegControl = 2'bx;
                    end
                end

                4'b1011: begin
                    if (Funct[0]) begin           
                        ALUControl = 4'b0000; // CMN
                        NoWrite = 1'b1;
                        FlagW = 2'b11;
                        RegControl = 2'bx;
                    end else begin
                        ALUControl = 4'bx; 
                        NoWrite = 1'bx;
                        FlagW = 2'bx;
                        RegControl = 2'bx;
                    end
                end

                4'b1000: begin    
                    if (Funct[0]) begin            
                        ALUControl = 4'b0010; // TST
                        NoWrite = 1'b1;
                        FlagW = 2'b11;
                        RegControl = 2'bx;
                    end else begin
                        ALUControl = 4'bx; 
                        NoWrite = 1'bx;
                        FlagW = 2'bx;
                        RegControl = 2'bx;
                    end
                end

                4'b1001: begin      
                    if (Funct[0]) begin         
                        ALUControl = 4'b0111; // TEQ
                        NoWrite = 1'b1;
                        FlagW = 2'b11;
                        RegControl = 2'bx;
                    end else begin
                        ALUControl = 4'bx; 
                        NoWrite = 1'bx;
                        FlagW = 2'bx;
                        RegControl = 2'bx;
                    end
                end

                4'b1101: begin
                    NoWrite = 1'b0;
                    ALUControl = 4'b0110;
                    FlagW = 2'b10;

                    if (Funct[5] | (Src2[11:4] == 8'b0)) RegControl = 2'b00;  // MOV

                    else if (~Funct[5] & (Src2[6:5] == 2'b00) & (Src2[11:4] != 1'b0)) RegControl = 2'b01; // LSL

                    else if (~Funct[5] & (Src2[6:5] == 2'b01)) RegControl = 2'b10; // LSR

                    else if (~Funct[5] & (Src2[6:5] == 2'b10)) RegControl = 2'b11; // ASR

                    else RegControl = 2'bx;

                end

                4'b1111: begin               
                        ALUControl = 4'b1110; // MVN
                        NoWrite = 1'b0;
                        FlagW = 2'b10;
                        RegControl = 2'bx;

                end

                4'b1110: begin
                        ALUControl = 4'b1010; //BIC
                        NoWrite = 1'b0;
                        FlagW = 2'b10;
                        RegControl = 2'bx;
                end
                
                default: begin
                    ALUControl = 4'bx; // unimplemented
                    RegControl = 2'bx;
                    NoWrite = 1'bx;
                    FlagW = 2'bx;
                end
            endcase
        // update flags if S bit is set (C & V only for arith)
            //FlagW[1] = Funct[0];
            //FlagW[0] = Funct[0] & (ALUControl[1:0] == 2'b00 | ALUControl[1:0] == 2'b01);
        end else begin
            ALUControl = 4'b0000; // add for non-DP instructions
            RegControl = 2'b00;
            NoWrite = 1'b0; 
            FlagW = 2'b00; // don't update Flags
        end

    // PC Logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
    
endmodule