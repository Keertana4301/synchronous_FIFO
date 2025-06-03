module sync_fifo #(parameter DEPTH = 16, WIDTH = 16)(
    input clk,
    input rst_n,
    input write_en,
    input read_en,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out,
    output full,
    output empty
);

  reg [$clog2(DEPTH)-1:0] write_ptr, read_ptr;
  reg [WIDTH-1:0] fifo [0:DEPTH-1];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_ptr <= 0;
      read_ptr <= 0;
      data_out <= 0;
    end else begin
      // Write logic
      if (write_en && !full) begin
        fifo[write_ptr] <= data_in;
        write_ptr <= write_ptr + 1;
      end

      // Read logic
      if (read_en && !empty) begin
        data_out <= fifo[read_ptr];
        read_ptr <= read_ptr + 1;
      end
    end
  end

  assign full = ((write_ptr + 1'b1) == read_ptr);
  assign empty = (write_ptr == read_ptr);

endmodule
