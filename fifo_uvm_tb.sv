`include "uvm_macros.svh"
import uvm_pkg::*;
//Interface 
interface fifo_if(input bit clk, input bit rst_n);
   logic write_en,read_en;
   logic [15:0] data_in;
   logic [15:0] data_out;
   logic full, empty;
endinterface

//Sequence item
class fifo_seq_item extends uvm_sequence_item;
	rand bit [15:0] data_in;
    rand bit write_en, read_en;
    	bit [15:0] data_out;
    `uvm_object_utils_begin(fifo_seq_item)
    	`uvm_field_int(data_in,UVM_ALL_ON)
    	`uvm_field_int(write_en,UVM_ALL_ON)
    	`uvm_field_int(read_en,UVM_ALL_ON)
     `uvm_object_utils_end
     //constructor
    function new(string name = "fifo_seq_item");
    	super.new(name);
    endfunction
    //constraint
    constraint c_write_read {write_en!=read_en;};
endclass

//Sequence
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

//Sequencer
class fifo_sequencer extends uvm_sequencer #(fifo_seq_item);
  `uvm_component_utils(fifo_sequencer)
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
endclass

//Driver 
class fifo_driver extends uvm_driver #(fifo_seq_item);
	virtual fifo_if vif;
    `uvm_component_utils(fifo_driver)
    function new(string name, uvm_component parent);
    	super.new(name, parent);
    endfunction 
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      if (!uvm_config_db#(virtual fifo_if)::get(this,"","vif",vif))
        	`uvm_fatal("NO_VIF","INTERFACE NOT FOUND")
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
        
//Agent

class fifo_agent extends uvm_agent;
  fifo_driver drv;
  fifo_sequencer seqr;

  `uvm_component_utils(fifo_agent)

  function new(string name, uvm_component parent);
    super.new(name,parent);
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
//Environment
class fifo_env extends uvm_env;
  fifo_agent agent;

  `uvm_component_utils(fifo_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = fifo_agent::type_id::create("agent", this);
  endfunction
endclass
      
//Test
class fifo_test extends uvm_test;
	`uvm_component_utils(fifo_test)
    fifo_env env;
    fifo_sequence seq;
    function new(string name, uvm_component parent);
    	super.new(name, parent);
    endfunction   
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
        env = fifo_env::type_id::create("env",this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      seq = fifo_sequence::type_id::create("seq");
      seq.start(env.agent.seqr);  // Pass the sequencer, not the driver's port
      phase.drop_objection(this);
    endtask
endclass
      
//Top-level testbench
module top;
	bit clk = 0;
    bit rst_n;
    always #5 clk = ~clk;
    initial begin
    	rst_n =0;
        #20 rst_n =1;
    end
    fifo_if fifo_if_inst(clk,rst_n);
    sync_fifo dut(
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
    	uvm_config_db#(virtual fifo_if)::set(null,"*","vif",fifo_if_inst);
        run_test("fifo_test");
    end
    initial begin
        $dumpfile("fifo_test.vcd");
        $dumpvars(0, top);
    end
endmodule
