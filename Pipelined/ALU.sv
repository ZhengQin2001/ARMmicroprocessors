module alu_adder #(parameter n = 8)
                  (input logic [n-1:0] a, b,
                   input logic cin,
                   output logic [n-1:0] s,
                   output logic cout);
    assign {cout, s} = a + b + cin;
endmodule


module alu #(parameter n = 32)
            (input logic [n-1:0] a, b,
             input logic [3:0] ALUControlE,
             input logic [1:0] RegControlE,
             output logic [n-1:0] result,
             output logic [3:0] ALUFlags);

    logic [n-1:0] ADDresult, SUBresult, ANDresult, ORresult, EORresult, RSBresult;
    logic cout, ADDcout, SUBcout, RSBcout;

    alu_adder#(32) add_instr(a, b, 1'b0, ADDresult, ADDcout);
    alu_adder#(32) sub_instr(a, ~b, 1'b1, SUBresult, SUBcout);
    alu_adder#(32) rsb_instr(b, ~a, 1'b1, RSBresult, RSBcout);
    assign ANDresult = a & b;
    assign ORresult = a | b;
    assign EORresult = a ^ b;

    always_latch begin
        case(ALUControlE)
            4'b0000: begin
                result = ADDresult;
                cout = ADDcout;
            end

            4'b0001: begin
                result = SUBresult;
                cout = SUBcout;
            end

            4'b0010: begin
                result = ANDresult;
                cout = 1'bx;
            end

            4'b0011: begin
                result = ORresult;
                cout = 1'bx;
            end 

            4'b0111: begin
                result = EORresult;
                cout = 1'bx;
            end

            4'b0101: begin
                result = RSBresult;
                cout = RSBcout;
            end

            4'b0110: begin
                cout = 1'bx;
                case(RegControlE)
                    00: result = b;

                    01: result = a << b;

                    10: result = a >> b;

                    11: result = a >>> b;

                endcase
            end

            4'b1110: begin
                result = ~b;
                cout = 1'bx;
            end
            
            4'b1010: begin
                result = a & ~b;
                cout = 1'bx;
            end

            default: begin
                result = 32'bx;
                cout = 1'bx;
            end

        endcase 
    end
// ALUflags
    assign ALUFlags[3] = result[n-1]; // negative
    assign ALUFlags[2] = (result == 0); // zero
    assign ALUFlags[1] = ~ALUControlE[1] & cout; // carry out
    assign ALUFlags[0] = ~(a[n-1]^b[n-1]^ALUControlE[0]) & (a[n-1]^result[n-1]) &~ ALUControlE[1]; // overflow
endmodule