module ff_d2eDP (input logic clk, reset, FlushE,
                 input logic [31:0] RD1D, RD2D, 
                 input logic [3:0] RA1D, RA2D, WA3D,
                 input logic [31:0] ExtImmD,
                 output logic [31:0] RD1E, RD2E, 
                 output logic [3:0] RA1E, RA2E, WA3E,
                 output logic [31:0] ExtImmE);
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            RD1E <= 32'b0;
            RD2E <= 32'b0;
            RA1E <= 4'b0;
            RA2E <= 4'b0;
            WA3E <= 4'b0;
            ExtImmE <= 32'b0;
        end else begin
            RD1E <= FlushE ? 32'b0:RD1D;
            RD2E <= FlushE ? 32'b0:RD2D;
            RA1E <= FlushE ? 4'b0:RA1D;
            RA2E <= FlushE ? 4'b0:RA2D;
            WA3E <= FlushE ? 4'b0:WA3D;
            ExtImmE <= FlushE ? 32'b0:ExtImmD;
        end
    end

endmodule