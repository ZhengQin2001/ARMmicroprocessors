module ff_f2d (input logic clk, reset, StallD, FlushD,
               input logic [31:0] InstrF,
               output logic [31:0] InstrD);
    always_ff @(posedge clk, posedge reset)
        if (reset) InstrD <= 0;
        else if (StallD) begin
            InstrD <= FlushD ? 32'b0:InstrF;
        end
        
endmodule