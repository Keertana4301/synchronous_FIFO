# Synchronous FIFO:

This project implements a parameterizable synchronous FIFO buffer in SystemVerilog with a comprehensive UVM (Universal Verification Methodology) testbench. The design features a 16-deep, 16-bit wide FIFO with full UVM verification environment including proper sequencing, driving, and monitoring capabilities.

## Project Overview

**Synchronous FIFO Buffer Implementation**
- 16-deep, 16-bit wide parameterizable FIFO
- Single clock domain design with full/empty detection
- Complete physical implementation flow
- UVM testbench verified design

### RTL Architecture
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

## Prerequisites

### Software Requirements
- **Ubuntu/Linux**: OpenLane installation
- **Windows**: KLayout installation
- **File Transfer**: Shared folder, WSL, or USB drive

### Installation
- [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane)
- [KLayout](https://www.klayout.de/build.html)

## Step-by-Step Implementation

### 1. Create Design Directory

```bash
mkdir -p ~/OpenLane/designs/sync_fifo
cd ~/OpenLane/designs/sync_fifo
```

### 2. RTL Implementation

Create `sync_fifo.v`:

```verilog
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
```

### 3. OpenLane Configuration

Create `config.tcl`:

```tcl
# Design Configuration
set ::env(DESIGN_NAME) sync_fifo

# Source Files
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/sync_fifo.v]

# Clock Configuration
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"

# Reset Configuration  
set ::env(RST_PORT) "rst_n"

# Design Constraints
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 150 150"
set ::env(FP_CORE_UTIL) 40
```

### 4. Run OpenLane Flow

```bash
cd ~/OpenLane
make mount
./flow.tcl -design sync_fifo
```

### 5. Locate Output Files

```bash
cd ~/OpenLane/designs/sync_fifo/runs/
find . -name "*.gds" -type f
```

Key output files in `*/results/final/`:
- **`sync_fifo.gds`** - GDSII layout file
- **`sync_fifo.lef`** - Library Exchange Format
- **`sync_fifo.def`** - Design Exchange Format  
- **`sync_fifo.v`** - Gate-level netlist

### 6. Transfer to Windows

**WSL Method:**
```bash
cp sync_fifo.gds /mnt/c/Users/YourUsername/Desktop/
```

**VM Shared Folder:**
```bash
cp sync_fifo.gds /path/to/shared/folder/
```

### 7. View in KLayout (Windows)

1. Launch **KLayout**
2. `File > Open` → Select `sync_fifo.gds`
3. Navigate layers using the layer panel
4. Use `F2` to fit layout in window

## Design Specifications

### Module Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `DEPTH` | 16 | FIFO depth (storage locations) |
| `WIDTH` | 16 | Data width in bits |

### Interface Ports
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

## Key Features

### Control Logic
- **Full Detection**: `(write_ptr + 1) == read_ptr`
- **Empty Detection**: `write_ptr == read_ptr`  
- **Pointer Management**: 4-bit pointers with wrap-around
- **Synchronous Reset**: All registers cleared on reset

### Physical Implementation
- **Technology**: SkyWater Sky130 PDK
- **Clock Frequency**: 100MHz (10ns period)
- **Core Utilization**: 40%
- **Die Area**: 150μm × 150μm

## Results

### Timing Analysis
- **Clock Period**: 10ns (100MHz)
- **Reset Duration**: 20ns

![Simulations](https://github.com/user-attachments/assets/bcaeb8a6-6eda-434e-aca0-f1d01af5dfa7)
### KLayout Display
![KLayout_view](https://github.com/user-attachments/assets/446027ab-5a73-4461-aa02-026a9b9fa61a)

## Applications

- **Data Buffering**: Temporary storage in digital systems
- **Rate Matching**: Between different speed domains
- **Pipeline Buffers**: In processor and DSP designs
- **Communication Systems**: Packet buffering applications


