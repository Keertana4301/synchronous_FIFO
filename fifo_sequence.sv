class fifo_sequence extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_sequence)

  function new(string name = "fifo_sequence");
    super.new(name);
  endfunction

  virtual task body();
    fifo_seq_item req;
    repeat (10) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end
  endtask
endclass
