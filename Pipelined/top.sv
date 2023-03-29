`include "arm.sv"
`include "imem.sv"
`include "dmem.sv"

module top(input logic clk, reset,
           output logic [31:0] WriteDataM, DataAdr,
           output logic MemWriteM);
    logic [31:0] PCF, InstrF, ReadDataM;
    // instantiate processor and memories
    arm arm(clk, reset, PCF, InstrF, MemWriteM, DataAdr, WriteDataM, ReadDataM);
    imem imem(PCF, InstrF);
    dmem dmem(clk, MemWriteM, DataAdr, WriteDataM, ReadDataM);
endmodule