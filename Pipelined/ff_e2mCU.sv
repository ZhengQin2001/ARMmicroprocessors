module ff_e2mCU (input logic clk, reset, 
                 input logic PCSrcEout, RegWriteEout, MemtoRegE, MemWriteEout,
                 output logic PCSrcM, RegWriteM, MemtoRegM, MemWriteM);
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            PCSrcM <= 0;
            RegWriteM <= 0;
            MemtoRegM <= 0;
            MemWriteM <= 0;
        end
        else begin
            PCSrcM <= PCSrcEout;
            RegWriteM <= RegWriteEout;
            MemtoRegM <= MemtoRegE;
            MemWriteM <= MemWriteEout;
        end
    end

endmodule