class fifo_driver extends uvm_driver #(fifo_seq_item);
  virtual fifo_if vif;

  `uvm_component_utils(fifo_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      fifo_seq_item req;
      seq_item_port.get_next_item(req);

      vif.write_en <= 0;
      vif.read_en <= 0;
      @(posedge vif.clk);

      if (req.write_en) begin
        vif.data_in <= req.data_in;
        vif.write_en <= 1;
      end else if (req.read_en) begin
        vif.read_en <= 1;
      end

      @(posedge vif.clk);
      vif.write_en <= 0;
      vif.read_en <= 0;
      seq_item_port.item_done();
    end
  endtask
endclass
