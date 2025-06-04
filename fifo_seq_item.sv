class fifo_seq_item extends uvm_sequence_item;
  rand bit [15:0] data_in;
  rand bit write_en, read_en;
  bit [15:0] data_out;

  `uvm_object_utils_begin(fifo_seq_item)
    `uvm_field_int(data_in, UVM_ALL_ON)
    `uvm_field_int(write_en, UVM_ALL_ON)
    `uvm_field_int(read_en, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "fifo_seq_item");
    super.new(name);
  endfunction

  constraint c_write_read { write_en != read_en; }
endclass
