module ff_e2mDP (input logic clk, reset, 
                 input logic [31:0] ALUResultE, WriteDataE,
                 input logic [3:0] WA3E,
                 output logic [31:0] ALUOutM, WriteDataM,
                 output logic [3:0] WA3M);
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ALUOutM <= 32'b0;
            WriteDataM <= 32'b0;
            WA3M <= 4'b0;
        end
        else begin
            ALUOutM <= ALUResultE;
            WriteDataM <= WriteDataE;
            WA3M <= WA3E;
        end
    end

endmodule