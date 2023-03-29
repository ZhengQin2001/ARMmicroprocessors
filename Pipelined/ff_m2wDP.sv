module ff_m2wDP(input logic clk, reset,
                input logic [31:0] ReadDataM, ALUOutM,
                input logic [3:0] WA3M,
                output logic [31:0] ReadDataW, ALUOutW,
                output logic [3:0] WA3W);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ReadDataW <= 32'b0;
            ALUOutW <= 32'b0;
            WA3W <= 4'b0;
        end else begin
            ReadDataW <= ReadDataM;
            ALUOutW <= ALUOutM;
            WA3W <= WA3M;
        end
    end
    
endmodule