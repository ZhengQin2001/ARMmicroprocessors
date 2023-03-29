`timescale 1ps/1ps
`include "top.sv"

module testbench();
    logic clk;
    logic reset;
    logic [31:0] WriteData, DataAdr;
    logic MemWrite;

    // instantiate device to be tested
    top dut(clk, reset, WriteData, DataAdr, MemWrite);


    // initialize test
    initial begin
        $display("Simulation started");
        reset <= 1; # 22; reset <= 0;
        $dumpfile("testbench.vcd"); // Dump variable changes in the vcd file
        $dumpvars(0, testbench); // Specifies which variables to dump in the vcd file     
        $dumpvars(1, testbench);   
        # 400;
        $display("Simulation is terminated");
        $finish;
    end

    // generate clock to sequence tests
    always begin
        clk <= 1; # 5; clk <= 0; # 5;
    end

    // check that 7 gets written to address 0x64
    // at end of program
        /*
    always @(negedge clk) begin
        if(MemWrite) begin
            if(DataAdr === 100 & WriteData === 7) begin
                $display("Simulation succeeded");
                $finish;
            end else if (DataAdr !== 7) begin
                $display("Simulation failed. %d, %d", DataAdr, WriteData);
                $finish;
            end
        end
    end
    */
endmodule