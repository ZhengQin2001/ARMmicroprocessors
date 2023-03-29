module hazard(input logic [4:0] Match,
              input logic PCSrcW, PCWrPendingF,
              input logic RegWriteM, RegWriteW, MemtoRegE, BranchTakenE,
              output logic [1:0] ForwardAE, ForwardBE,
              output logic StallD, StallF, FlushD, FlushE);

    logic LDRstall;

    // Data hazards with forwarding
    ////{Match_12D_E, Match_1E_M, Match_2E_M, Match_1E_W, Match_2E_W} = Match;

    assign ForwardAE = (Match[3] & RegWriteM) ? 2'b10: // SrcAE = ALUOutM
                       (Match[1] & RegWriteW) ? 2'b01: // SrcAE = ResultW
                       2'b00;                          // SrcAE from RegFile
    assign ForwardBE = (Match[2] & RegWriteM) ? 2'b10: // SrcBE = ALUOutM
                       (Match[0] & RegWriteW) ? 2'b01: // SrcBE = ResultW
                       2'b00;                          // SrcBE from RegFile
    
    // Data hazards with stalls
    assign LDRstall = (Match[4] & MemtoRegE);
    

    assign StallD = LDRstall;
    assign StallF = LDRstall + PCWrPendingF;
    assign FlushD = (PCWrPendingF | BranchTakenE) ^ PCSrcW;
    assign FlushE = LDRstall + BranchTakenE;
                    

    //always_comb begin
        //if (Match[3] & RegWriteM) ForwardAE = 2'b10;
        //else if (Match[1] & RegWriteW) ForwardAE = 2'b01;
        //else ForwardAE = 2'b00;

        //if (Match[2] & RegWriteM) ForwardBE = 2'b10;
        //else if (Match[0] & RegWriteW) ForwardBE = 2'b01;
        //else ForwardBE = 2'b00;


        
endmodule