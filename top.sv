`include "uvm_macros.svh"
import uvm_pkg::*;

module top;
  bit clk = 0;
  bit rst_n;

  always #5 clk = ~clk;

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  fifo_if fifo_if_inst(clk, rst_n);

  sync_fifo dut (
    .clk(fifo_if_inst.clk),
    .rst_n(fifo_if_inst.rst_n),
    .write_en(fifo_if_inst.write_en),
    .read_en(fifo_if_inst.read_en),
    .data_in(fifo_if_inst.data_in),
    .data_out(fifo_if_inst.data_out),
    .full(fifo_if_inst.full),
    .empty(fifo_if_inst.empty)
  );

  initial begin
    uvm_config_db#(virtual fifo_if)::set(null, "*", "vif", fifo_if_inst);
    run_test("fifo_test");
  end

  initial begin
    $dumpfile("fifo_test.vcd");
    $dumpvars(0, top);
  end
endmodule
