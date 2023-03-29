module ff_m2wCU (input logic clk, reset, 
                 input logic PCSrcM, RegWriteM, MemtoRegM,
                 output logic PCSrcW, RegWriteW, MemtoRegW);
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            PCSrcW <= 0;
            RegWriteW <= 0;
            MemtoRegW <= 0;
        end
        else begin
            PCSrcW <= PCSrcM;
            RegWriteW <= RegWriteM;
            MemtoRegW <= MemtoRegM;
        end
    end

endmodule