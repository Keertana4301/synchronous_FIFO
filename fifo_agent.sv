class fifo_agent extends uvm_agent;
  fifo_driver drv;
  fifo_sequencer seqr;

  `uvm_component_utils(fifo_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = fifo_sequencer::type_id::create("seqr", this);
    drv = fifo_driver::type_id::create("drv", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
