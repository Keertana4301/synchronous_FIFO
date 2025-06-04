interface fifo_if(input bit clk, input bit rst_n);
   logic write_en, read_en;
   logic [15:0] data_in;
   logic [15:0] data_out;
   logic full, empty;
endinterface