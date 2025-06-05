# Synchronous FIFO (First In First Out) Buffer

## Overview

This project implements a parameterizable synchronous FIFO buffer in SystemVerilog with a comprehensive UVM (Universal Verification Methodology) testbench. The design features a 16-deep, 16-bit wide FIFO with full UVM verification environment including proper sequencing, driving, and monitoring capabilities.

## Features

- **Synchronous Operation**: Single clock domain design
- **Parameterizable**: Configurable data width (16-bit default) and FIFO depth (16 default)
- **Full/Empty Detection**: Status flags for buffer management
- **UVM Testbench**: Complete verification environment with sequences, drivers, and agents
- **EDA Tools Integration**: Verified with Questa Sim in EDAPlayground
- **Physical Implementation**: Layout generated using OpenLane and KLayout

## Architecture

### RTL Design Block Diagram
```
    ┌─────────────────────────────────────┐
    │        Synchronous FIFO             │
    │                                     │
    │ clk ──────┐                         │
    │ rst_n ────┤                         │
    │           │    ┌──────────────┐     │
    │ write_en ─┼────┤              │     │
    │ data_in ──┼────┤ FIFO Memory  │     │
    │           │    │ Array[16]    │     │
    │ read_en ──┼────┤              │     │
    │           │    └──────────────┘     │
    │           │           │             │
    │           └───────────┼─────────────┤ data_out
    │                       │             │
    │ full ◄────────────────┼─────────────┤
    │ empty ◄───────────────┘             │
    └─────────────────────────────────────┘
```

## RTL Module Interface

### Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `DEPTH` | 16 | Number of storage locations |
| `WIDTH` | 16 | Width of data bus in bits |

### Ports
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1 | System clock |
| `rst_n` | Input | 1 | Active low reset |
| `write_en` | Input | 1 | Write enable |
| `read_en` | Input | 1 | Read enable |
| `data_in` | Input | WIDTH | Write data |
| `data_out` | Output | WIDTH | Read data |
| `full` | Output | 1 | FIFO full flag |
| `empty` | Output | 1 | FIFO empty flag |

## UVM Testbench Architecture

### Verification Components

1. **fifo_seq_item**: Transaction class with randomized data and control signals
2. **fifo_sequence**: Generates 10 random transactions with write/read constraint
3. **fifo_sequencer**: Standard UVM sequencer for transaction flow
4. **fifo_driver**: Drives interface signals based on sequence items
5. **fifo_agent**: Contains sequencer and driver components
6. **fifo_env**: Environment containing the agent
7. **fifo_test**: Top-level test class

### Key Constraint
```systemverilog
constraint c_write_read {write_en != read_en;}
```
This ensures that write and read operations don't occur simultaneously, preventing conflicts.

## RTL Implementation Details

### Memory Structure
- **Storage**: 16-word x 16-bit memory array
- **Pointers**: 4-bit write and read pointers (log2(16))
- **Reset Behavior**: Synchronous reset clears pointers and output

### Control Logic
```systemverilog
// Write Logic
always@(posedge clk) begin
    if(write_en & !full) begin
        fifo[write_ptr] <= data_in;
        write_ptr <= write_ptr + 1;
    end
end

// Read Logic  
always@(posedge clk) begin
    if(read_en & !empty) begin
        data_out <= fifo[read_ptr];
        read_ptr <= read_ptr + 1;
    end
end

// Status Flags
assign full = ((write_ptr + 1'b1) == read_ptr);
assign empty = (write_ptr == read_ptr);
```

## Simulation and Verification

### Prerequisites
- **Questa Sim** or compatible SystemVerilog simulator
- **UVM Library** (included in most modern simulators)
- **EDAPlayground** account (for online simulation)

### Running Simulation

#### Local Questa Simulation
```bash
# Compile and simulate
vlog -sv +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv
vlog -sv sync_fifo.sv fifo_tb.sv
vsim -c top -do "run -all; quit"

# With GUI
vsim top
run -all
```

#### EDAPlayground Setup
1. Upload `sync_fifo.sv` and `fifo_tb.sv`
2. Select "UVM/OVM" testbench
3. Choose Questa simulator
4. Run simulation

### Verification Features
- **Random Data Generation**: 16-bit random data patterns
- **Controlled Operations**: Mutually exclusive write/read operations
- **Coverage**: 10 transactions per test run
- **Waveform Dumping**: VCD file generation for analysis

## Physical Implementation

### OpenLane Flow
The design has been successfully synthesized and implemented using the OpenLane flow:

1. **Synthesis**: RTL to gate-level conversion
2. **Floorplanning**: Die and core area definition
3. **Placement**: Standard cell placement
4. **Clock Tree Synthesis**: Clock distribution
5. **Routing**: Metal layer interconnections
6. **Physical Verification**: DRC and LVS checks

### KLayout Integration
- **Layout Visualization**: Complete physical layout view
- **Layer Stack**: Standard digital CMOS layers
- **Design Rules**: Sky130 PDK compliance

## Key Design Features

### Pointer Management
- **Wrap-around Logic**: Automatic pointer increment with overflow
- **4-bit Pointers**: Efficient for 16-deep FIFO
- **Separate Read/Write**: Independent pointer control

### Flag Generation
- **Full Detection**: `(write_ptr + 1) == read_ptr`
- **Empty Detection**: `write_ptr == read_ptr`
- **Combinational Logic**: Immediate status updates

### UVM Best Practices
- **Factory Pattern**: Proper object creation using `type_id::create()`
- **Configuration Database**: Interface passing via `uvm_config_db`
- **Phase Management**: Proper objection raising/dropping
- **Randomization**: Constrained random testing

## Simulation Results

### Timing Analysis
- **Clock Period**: 10ns (100MHz)
- **Reset Duration**: 20ns

![Simulations](https://github.com/user-attachments/assets/bcaeb8a6-6eda-434e-aca0-f1d01af5dfa7)

## Applications

- **Data Buffering**: Temporary storage in digital systems
- **Rate Matching**: Between different speed domains
- **Pipeline Buffers**: In processor and DSP designs
- **Communication Systems**: Packet buffering applications


