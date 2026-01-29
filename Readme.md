# CSE 4224 - Digital System Design
## Exam Preparation Guide

**Course:** Digital System Design Laboratory  
**Environment:** Vivado 2023.1  
**FPGA Board:** Basys3 Xilinx Artix-7 (XC7A35TICPG236-1L)

---

## 📚 Table of Contents

1. [Fundamental Concepts](#fundamental-concepts)
2. [Verilog HDL Essentials](#verilog-hdl-essentials)
3. [Combinational Logic Design](#combinational-logic-design)
4. [Sequential Logic Design](#sequential-logic-design)
5. [FPGA Display Systems](#fpga-display-systems)
6. [ALU Design](#alu-design)
7. [Testbenches and Simulation](#testbenches-and-simulation-)
8. [XDC Constraints and Pin Mapping](#xdc-constraints-and-pin-mapping-)
9. [Control Unit Design Patterns](#control-unit-design-patterns)
10. [Lab Implementations](#lab-implementations)
11. [Common Exam Topics](#common-exam-topics)
12. [Quick Reference](#quick-reference)

---

## 🎯 Fundamental Concepts

### Digital System Design Hierarchy

#### 1. **Switch Level**
- Layout of transistors, wires, and resistors on IC chip
- Lowest level of abstraction
- Rarely used in modern design

#### 2. **Gate Level (Structural)**
- Uses logical gates (AND, OR, NOT, NAND, NOR, XOR, XNOR)
- Flip-flops and their interconnections
- Easy to synthesize
- Text-based schematic entry

#### 3. **RTL (Register Transfer Level)** ⭐ Most Important
- **Synthesizable** - converts to actual hardware
- Uses registers (flip-flops) with combinational logic between them
- Standard level for FPGA design
- Balance between abstraction and hardware control

#### 4. **Behavioral Level**
- Highest level of abstraction
- Describes algorithm without hardware details
- **Not synthesizable** (for complex algorithms)
- Used for testbenches and simulation

---

### Hardware Description Language (HDL)

**Why HDL?**
- Gate-level design unmanageable for millions of transistors
- Provides text-based description, testing, and synthesis
- Industry standard for digital design

**Verilog vs VHDL:**
- **Verilog**: C-like syntax, case-sensitive, more concise
- **VHDL**: Pascal/Ada-like, verbose, strongly typed

---

## 💻 Verilog HDL Essentials

### Basic Syntax Rules

```verilog
// Single-line comment
/* Multi-line
   comment */
```

- **Case Sensitive**: All keywords lowercase
- **Identifiers**: Up to 1024 characters
- **Keywords**: `module`, `endmodule`, `input`, `output`, `wire`, `reg`, `assign`, `always`

---

### Data Types ⭐ Exam Critical

#### Wire vs Reg Comparison

| Feature | Wire | Reg |
|---------|------|-----|
| **Purpose** | Physical connections | Storage elements |
| **Assignment** | Continuous (`assign`) | Procedural (`always`, `initial`) |
| **Behavior** | Combinational logic | Can be combinational or sequential |
| **Synthesis** | Always wires | May or may not be flip-flops |
| **Default Value** | `x` (unknown) | `0` |
| **Usage** | Module interconnections | Storage, intermediate values |

⚠️ **Common Misconception**: `reg` does NOT always mean a physical register/flip-flop! It's just a variable that can hold values in procedural blocks.

#### Logic Values

| Value | Meaning |
|-------|---------|
| `0` | Logic zero / false |
| `1` | Logic one / true |
| `x` | Unknown (uninitialized or conflict) |
| `z` | High impedance (tri-state) |

#### Number Representation

```verilog
// Format: <size>'<base><number>
549          // Decimal (default)
'h8FF        // Hexadecimal
'o765        // Octal
4'b1011      // 4-bit binary: 1011
3'b10x       // 3-bit with unknown LSB
5'd3         // 5-bit decimal: 00011
-4'b11       // Two's complement: 1101
```

#### Vector Declaration

```verilog
// MSB on left (recommended)
reg [7:0] data;     // data[7] is MSB
wire [3:0] addr;    // addr[3] is MSB

// MSB on right (less common)
reg [0:7] oldstyle; // oldstyle[0] is MSB
```

---

### Operators ⭐ Must Know for Exams

#### Bitwise Operators
Operate on each bit independently:
```verilog
~a        // NOT
a & b     // AND
a | b     // OR
a ^ b     // XOR
a ~^ b    // XNOR (also a ^~b)

// Example:
4'b0101 & 4'b0011 = 4'b0001
4'b0101 | 4'b0011 = 4'b0111
```

#### Reduction Operators
Reduce vector to single bit:
```verilog
&a        // AND all bits
~&a       // NAND all bits
|a        // OR all bits
~|a       // NOR all bits
^a        // XOR all bits (parity)
~^a       // XNOR all bits

// Example:
&(4'b0101) = 0&1&0&1 = 0
|(4'b0101) = 0|1|0|1 = 1
^(4'b0101) = 0^1^0^1 = 0 (even parity)
```

#### Logical Operators
Return 1-bit true/false:
```verilog
!a        // NOT
a && b    // AND
a || b    // OR
a == b    // Equality (x if unknown bits)
a != b    // Inequality
a === b   // Case equality (exact match, including x/z)
a !== b   // Case inequality
```

#### Arithmetic Operators
```verilog
-a        // Negate
a + b     // Add
a - b     // Subtract
a * b     // Multiply
a / b     // Divide (by constant for synthesis)
a % b     // Modulo (by constant for synthesis)
```

#### Shift Operators
```verilog
a << n    // Logical left shift (fill with 0)
a >> n    // Logical right shift (fill with 0)
a <<< n   // Arithmetic left shift
a >>> n   // Arithmetic right shift (sign extend)
```

#### Relational Operators
```verilog
a > b     // Greater than
a >= b    // Greater or equal
a < b     // Less than
a <= b    // Less or equal (⚠️ Not assignment!)
```

#### Conditional (Ternary) Operator
```verilog
condition ? true_value : false_value

// Example:
assign max = (a > b) ? a : b;
```

#### Concatenation
```verilog
{a, b, c}           // Concatenate
{3{a}}              // Replicate: {a, a, a}
{cout, sum}         // Common: combine carry and sum

// Example:
A = 8'b01011010;
B = {A[7:4], A[3:0]};  // Swap nibbles
```

---

### Module Structure

```verilog
module module_name (
    input wire [width-1:0] input_port,
    output wire [width-1:0] output_port,
    inout wire [width-1:0] bidir_port
);
    // Declarations
    wire internal_wire;
    reg [7:0] internal_reg;
    
    // Continuous assignments
    assign output_port = input_port & internal_wire;
    
    // Procedural blocks
    always @(*) begin
        // Combinational logic
    end
    
    // Module instantiation
    submodule_name instance_name (
        .port_name(signal_name)
    );
    
endmodule
```

---

### Assignment Types ⭐ Critical Distinction

#### 1. Continuous Assignment
- Models **combinational logic**
- Drives `wire` variables
- Evaluated whenever input changes
- Uses `assign` keyword

```verilog
assign sum = a ^ b ^ cin;           // XOR gate
assign carry = (a & b) | (a & cin) | (b & cin);  // Majority
assign out = sel ? a : b;           // Mux
```

#### 2. Procedural Assignment
- Inside `always` or `initial` blocks
- Assigns to `reg` variables
- Can model combinational or sequential logic

**Blocking Assignment (`=`):**
- Executes sequentially (like C programming)
- Next statement waits for current to complete
- **Use for combinational logic**

```verilog
always @(*) begin
    temp = a & b;
    out = temp | c;  // Uses updated temp immediately
end
```

**Non-Blocking Assignment (`<=`):**
- All RHS evaluated simultaneously
- All LHS updated at end of time step
- **Use for sequential logic (flip-flops)**

```verilog
always @(posedge clk) begin
    q1 <= d;    // Both assignments happen
    q2 <= q1;   // simultaneously (shift register)
end
```

⚠️ **Exam Trap**: Wrong assignment type causes simulation/synthesis mismatch!

---

### Sensitivity Lists

#### Combinational Logic
```verilog
// Method 1: List all inputs
always @(a or b or c) begin
    out = a & b | c;
end

// Method 2: Use @(*) - Automatic (Recommended)
always @(*) begin
    out = a & b | c;
end
```

#### Sequential Logic
```verilog
// Positive edge
always @(posedge clk) begin
    q <= d;
end

// Negative edge
always @(negedge clk) begin
    q <= d;
end

// With reset
always @(posedge clk or posedge rst) begin
    if (rst)
        q <= 0;
    else
        q <= d;
end
```

---

### Control Structures

#### If-Else Statement
```verilog
always @(*) begin
    if (condition1)
        statement1;
    else if (condition2)
        statement2;
    else
        statement3;
end
```

**Synthesis Result:**
- Priority encoder (checks conditions sequentially)
- First true condition executes

#### Case Statement ⭐ Preferred for Decoders
```verilog
always @(*) begin
    case (select)
        2'b00:   out = a;
        2'b01:   out = b;
        2'b10:   out = c;
        2'b11:   out = d;
        default: out = 0;  // Important!
    endcase
end
```

**Synthesis Result:**
- Parallel decoder (all conditions checked simultaneously)
- More efficient than if-else for equal-priority selections

⚠️ **Always include `default`** to avoid latches!

---

## 🔧 Combinational Logic Design

### Half Adder

**Truth Table:**
| A | B | Sum | Carry |
|---|---|-----|-------|
| 0 | 0 | 0   | 0     |
| 0 | 1 | 1   | 0     |
| 1 | 0 | 1   | 0     |
| 1 | 1 | 0   | 1     |

**Logic Equations:**
- Sum = A ⊕ B (XOR)
- Carry = A · B (AND)

**Verilog Implementation:**
```verilog
module half_adder(
    input a, b,
    output sum, carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule
```

---

### Full Adder

**Truth Table:**
| A | B | Cin | Sum | Cout |
|---|---|-----|-----|------|
| 0 | 0 | 0   | 0   | 0    |
| 0 | 0 | 1   | 1   | 0    |
| 0 | 1 | 0   | 1   | 0    |
| 0 | 1 | 1   | 0   | 1    |
| 1 | 0 | 0   | 1   | 0    |
| 1 | 0 | 1   | 0   | 1    |
| 1 | 1 | 0   | 0   | 1    |
| 1 | 1 | 1   | 1   | 1    |

**Logic Equations:**
- Sum = A ⊕ B ⊕ Cin
- Cout = (A·B) + (A·Cin) + (B·Cin) = AB + Cin(A⊕B)

**Structural Implementation using 2 Half Adders:**
```verilog
module full_adder(
    input a, b, cin,
    output s, cout
);
    wire sum_partial, carry1, carry2;
    
    // First half adder: A + B
    half_adder HA1 (
        .a(a),
        .b(b),
        .sum(sum_partial),
        .carry(carry1)
    );
    
    // Second half adder: partial_sum + Cin
    half_adder HA2 (
        .a(sum_partial),
        .b(cin),
        .sum(s),
        .carry(carry2)
    );
    
    // Final carry is OR of both carries
    assign cout = carry1 | carry2;
endmodule
```

---

### 4-Bit Ripple Carry Adder

**Concept:**
- Chain 4 full adders
- Carry "ripples" from LSB to MSB
- Simple but slow (carry propagation delay)

**Delay Analysis:**
- Each FA has delay of 2 gate delays (for carry)
- 4-bit adder: 4 × 2 = 8 gate delays
- N-bit adder: 2N gate delays

**Block Diagram:**
```
a[3] b[3]    a[2] b[2]    a[1] b[1]    a[0] b[0]
  │    │      │    │      │    │      │    │
  └──┬─┘      └──┬─┘      └──┬─┘      └──┬─┘
    ┌▼┐        ┌▼┐        ┌▼┐        ┌▼┐
cin→│FA│───────→│FA│───────→│FA│───────→│FA│
    └┬┘        └┬┘        └┬┘        └┬┘
     │          │          │          │
   s[3]       s[2]       s[1]       s[0]
                                      │
                                    cout
```

**Implementation:**
```verilog
module adder_4bit(
    input [3:0] a, b,
    input cin,
    output [3:0] sum,
    output cout
);
    wire c0, c1, c2;
    
    full_adder FA0 (.a(a[0]), .b(b[0]), .cin(cin), .s(sum[0]), .cout(c0));
    full_adder FA1 (.a(a[1]), .b(b[1]), .cin(c0),  .s(sum[1]), .cout(c1));
    full_adder FA2 (.a(a[2]), .b(b[2]), .cin(c1),  .s(sum[2]), .cout(c2));
    full_adder FA3 (.a(a[3]), .b(b[3]), .cin(c2),  .s(sum[3]), .cout(cout));
endmodule
```

**Example Calculation:**
```
  A = 1111 (15)
  B = 1111 (15)
Cin =    1
-----------
    11111 (31) = {cout, sum} = {1, 1111}
```

---

### Multiplexer (MUX)

**2-to-1 Multiplexer:**
```verilog
// Method 1: Continuous assignment
module mux2to1(
    input a, b, sel,
    output out
);
    assign out = sel ? b : a;
    // Also: assign out = (~sel & a) | (sel & b);
endmodule

// Method 2: Procedural
module mux2to1(
    input a, b, sel,
    output reg out
);
    always @(*) begin
        case (sel)
            1'b0: out = a;
            1'b1: out = b;
        endcase
    end
endmodule
```

**4-to-1 Multiplexer:**
```verilog
module mux4to1(
    input [3:0] data,
    input [1:0] sel,
    output reg out
);
    always @(*) begin
        case (sel)
            2'b00: out = data[0];
            2'b01: out = data[1];
            2'b10: out = data[2];
            2'b11: out = data[3];
        endcase
    end
endmodule
```

---

## 🔄 Sequential Logic Design

### D Flip-Flop

**Basic D Flip-Flop:**
```verilog
module dff(
    input clk, d,
    output reg q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule
```

**With Asynchronous Reset:**
```verilog
module dff_async_reset(
    input clk, rst, d,
    output reg q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 0;
        else
            q <= d;
    end
endmodule
```

**With Synchronous Reset:**
```verilog
module dff_sync_reset(
    input clk, rst, d,
    output reg q
);
    always @(posedge clk) begin
        if (rst)
            q <= 0;
        else
            q <= d;
    end
endmodule
```

---

### Counter

**4-bit Up Counter:**
```verilog
module counter_4bit(
    input clk, rst,
    output reg [3:0] count
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            count <= 4'b0000;
        else
            count <= count + 1;
    end
endmodule
```

---

## 🖥️ FPGA Display Systems

### 7-Segment Display Architecture

#### Physical Structure
```
     ━━━ A ━━━
    ┃         ┃
    F         B
    ┃         ┃
     ━━━ G ━━━
    ┃         ┃
    E         C
    ┃         ┃
     ━━━ D ━━━  (DP)
```

Segment order: {A, B, C, D, E, F, G}

---

### Common Anode vs Common Cathode ⭐ Critical

#### Common Cathode (Less Common)
- All cathodes connected to GND
- Drive anode HIGH to light segment
- Logic: `1` = ON, `0` = OFF

#### Common Anode (Basys3 Uses This)
- All anodes connected to VCC
- Drive cathode LOW to light segment
- Logic: `0` = ON, `1` = OFF (inverted!)

⚠️ **Exam Important**: Basys3 uses **common anode**, so patterns are inverted!

---

### Segment Encoding Table ⭐ Memorize for Exams

Format: `seg[6:0] = {CA, CB, CC, CD, CE, CF, CG}` (Common Anode - Active Low)

| Digit | Segments ON | Binary Pattern | Hex  |
|-------|-------------|----------------|------|
| 0     | ABCDEF      | 0000001        | 0x01 |
| 1     | BC          | 1001111        | 0x4F |
| 2     | ABGED       | 0010010        | 0x12 |
| 3     | ABGCD       | 0000110        | 0x06 |
| 4     | FGBC        | 1001100        | 0x4C |
| 5     | AFGCD       | 0100100        | 0x24 |
| 6     | AFEDCG      | 0100000        | 0x20 |
| 7     | ABC         | 0001111        | 0x0F |
| 8     | ABCDEFG     | 0000000        | 0x00 |
| 9     | ABGCDF      | 0000100        | 0x04 |

**Decoder Implementation:**
```verilog
module hex_to_7seg(
    input [3:0] hex,
    output reg [6:0] seg
);
    always @(*) begin
        case(hex)
            4'h0: seg = 7'b0000001;
            4'h1: seg = 7'b1001111;
            4'h2: seg = 7'b0010010;
            4'h3: seg = 7'b0000110;
            4'h4: seg = 7'b1001100;
            4'h5: seg = 7'b0100100;
            4'h6: seg = 7'b0100000;
            4'h7: seg = 7'b0001111;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0000100;
            default: seg = 7'b1111111;  // Blank
        endcase
    end
endmodule
```

---

### Time-Division Multiplexing ⭐ Key Concept

**Problem:**
- Basys3 has 4 digits but only 7 cathode pins (shared)
- If we enable all digits, they all show the same pattern

**Solution: Rapid Switching**
- Display only ONE digit at a time
- Switch between digits rapidly (>60Hz)
- Human eye perceives all digits lit due to **persistence of vision**

**Timing:**
```
Basys3 Clock: 100 MHz
Counter: 18 bits (2^18 = 262,144)
Toggle Time: 262,144 × 10ns = 2.62ms
Frequency: 100MHz / 2^18 ≈ 381 Hz per digit
Full Cycle: 2 digits × 2.62ms = 5.24ms
Refresh Rate: 1 / 5.24ms ≈ 190 Hz ✓ (>60Hz, no flicker)
```

**Anode Control (Active-Low):**
```verilog
// Enable only rightmost digit (AN0)
an = 4'b1110;  // AN3=off, AN2=off, AN1=off, AN0=ON

// Enable second digit (AN1)
an = 4'b1101;  // AN3=off, AN2=off, AN1=ON, AN0=off
```

---

### Binary to Decimal Conversion ⭐ Important

**Problem:** Display 5-bit binary (0-31) as decimal digits

**Solution:**
```verilog
wire [4:0] value = 5'b11111;  // 31
wire [3:0] tens = value / 10;  // 3
wire [3:0] ones = value % 10;  // 1
// Display: "31"
```

**Synthesis Note:** Division/modulo by **constants** synthesizes to combinational logic efficiently.

---

### Complete Display Controller

```verilog
module seg_display_controller(
    input clk,
    input [4:0] value,        // 5-bit (0-31)
    output [6:0] seg,         // Cathodes
    output reg [3:0] an       // Anodes (active-low)
);
    // Refresh counter
    reg [17:0] refresh_counter = 0;
    always @(posedge clk)
        refresh_counter <= refresh_counter + 1;
    
    wire digit_select = refresh_counter[17];
    
    // Extract decimal digits
    wire [3:0] tens = value / 10;
    wire [3:0] ones = value % 10;
    
    // Multiplexer
    reg [3:0] current_digit;
    always @(*) begin
        case(digit_select)
            1'b0: begin
                an = 4'b1110;           // Enable AN0
                current_digit = ones;
            end
            1'b1: begin
                an = 4'b1101;           // Enable AN1
                current_digit = tens;
            end
        endcase
    end
    
    // Decoder
    hex_to_7seg decoder(.hex(current_digit), .seg(seg));
endmodule
```

---

## 🧮 ALU Design

### Basic ALU Operations

**Control Signals:**
- `s0`: Addition/Subtraction select
- `s1`: Complement B input

**Truth Table:**
| s1 | s0 | Operation | B_modified | Cin |
|----|----|-----------|------------|-----|
| 0  | 0  | A + B     | B          | 0   |
| 0  | 1  | A + B + 1 | B          | 1   |
| 1  | 0  | A - B     | ~B         | 1   |
| 1  | 1  | Reserved  | ~B         | 1   |

**Subtraction using Addition:**
- A - B = A + (~B) + 1 (Two's complement)
- `s1=1` complements B
- `cin=1` adds the +1

---

### Control Unit Implementation

```verilog
module control(
    input [3:0] b,
    input s0, s1,
    output [3:0] y
);
    wire [3:0] b_and, b_not;
    
    // Replicate control signals
    assign b_and = b & {4{s0}};
    assign b_not = ~b & {4{s1}};
    
    // Select based on s0 and s1
    assign y = b_and | b_not;
endmodule
```

**Logic:**
- If `s1=1, s0=0`: y = ~B (for subtraction)
- If `s1=0, s0=1`: y = B (for addition with carry)
- If `s1=0, s0=0`: y = B (normal addition)

---

### ALU Top Module

```verilog
module alu_top(
    input clk,
    input [3:0] a, b,
    input s0, s1,
    input cin,
    output [3:0] sum_led,
    output cout_led,
    output [6:0] seg,
    output [3:0] an
);
    wire [3:0] b_modified, sum;
    wire cout;
    wire [4:0] result;
    wire adder_cin;
    
    // Cin is 1 for subtraction, or user cin
    assign adder_cin = cin | s1;
    
    // Control unit
    control ctrl(.b(b), .s0(s0), .s1(s1), .y(b_modified));
    
    // Adder
    adder_4bit adder(
        .a(a),
        .b(b_modified),
        .cin(adder_cin),
        .sum(sum),
        .cout(cout)
    );
    
    // For subtraction, ignore carry
    assign result = s1 ? {1'b0, sum} : {cout, sum};
    
    // Display
    seg_display_controller display(
        .clk(clk),
        .value(result),
        .seg(seg),
        .an(an)
    );
    
    assign sum_led = sum;
    assign cout_led = cout;
endmodule
```

---

## 🧪 Testbenches and Simulation ⭐ Critical for Exams

### What is a Testbench?

A **testbench** is a Verilog module that:
- Has **no inputs or outputs** (top-level test module)
- Instantiates the Design Under Test (DUT)
- Generates test stimuli
- Verifies expected behavior
- **Not synthesizable** (simulation only)

---

### Timescale Directive ⭐ Important

**Purpose:** Defines time unit and precision for simulation

**Syntax:**
```verilog
`timescale <time_unit> / <time_precision>
```

**Common Examples:**
```verilog
`timescale 1ns / 1ps   // Time unit=1ns, precision=1ps
`timescale 1us / 1ns   // Time unit=1μs, precision=1ns
`timescale 1ms / 1us   // Time unit=1ms, precision=1μs
```

**Time Units:** s (second), ms, us, ns, ps, fs

**How it works:**
- **Time unit**: What #1 means in your code
- **Time precision**: Smallest time step simulator can resolve

```verilog
`timescale 1ns / 1ps

module test;
    reg clk;
    initial begin
        clk = 0;
        #10;        // Wait 10 × 1ns = 10ns
        clk = 1;
        #5.5;       // Wait 5.5ns (precision allows 0.5)
        clk = 0;
    end
endmodule
```

**Best Practices:**
- Place at top of file (before module declaration)
- Use consistent timescale across all files in project
- `1ns/1ps` is standard for FPGA designs (100MHz = 10ns)

---

### Testbench Structure

```verilog
`timescale 1ns / 1ps  // Time unit / Time precision

module module_name_tb;  // Convention: add _tb suffix

    // 1. Declare signals
    reg [3:0] a, b;     // Inputs to DUT (use reg)
    reg cin;
    wire [3:0] sum;     // Outputs from DUT (use wire)
    wire cout;
    
    // 2. Instantiate DUT (Device Under Test)
    adder_4bit UUT (    // UUT = Unit Under Test
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    // 3. Generate stimulus
    initial begin
        // Test case 1
        a = 4'b0000; b = 4'b0000; cin = 0;
        #10;  // Wait 10 time units
        
        // Test case 2
        a = 4'd5; b = 4'd3; cin = 0;
        #10;
        
        // More test cases...
        
        $finish;  // End simulation
    end
    
endmodule
```

---

### Clock Generation ⭐ Important Pattern

For sequential designs, generate a clock signal:

```verilog
reg clk;

// Method 1: Forever loop
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Toggle every 5ns (100MHz)
end

// Method 2: Always block (less common in testbench)
initial clk = 0;
always #5 clk = ~clk;
```

**Period Calculation:**
- 100 MHz → Period = 10ns → Half-period = 5ns
- 50 MHz → Period = 20ns → Half-period = 10ns

---

### System Tasks ⭐ Must Know

#### $display
Prints once when executed (like printf in C):
```verilog
$display("Time=%0t | a=%d b=%d | sum=%d", $time, a, b, sum);
// Output: Time=10 | a=5 b=3 | sum=8
```

#### $monitor
Prints automatically whenever any argument changes:
```verilog
initial begin
    $monitor("Time=%0t | a=%b b=%b | sum=%b cout=%b", 
             $time, a, b, sum, cout);
end
// Prints every time a, b, sum, or cout changes
```

⚠️ **Note**: Only one `$monitor` can be active at a time!

#### $finish
Ends simulation and exits:
```verilog
$finish;  // Normal termination
```

#### $stop
Pauses simulation (can resume):
```verilog
$stop;  // Pause for debugging
```

#### $time
Returns current simulation time:
```verilog
$display("Current time: %0t", $time);
```

---

### Format Specifiers

| Specifier | Format | Example Output |
|-----------|--------|----------------|
| `%b` | Binary | 1010 |
| `%d` | Decimal (signed) | -5 |
| `%h` | Hexadecimal | A5 |
| `%o` | Octal | 125 |
| `%t` | Time | 100 |
| `%0d` | Decimal (no leading spaces) | 5 |
| `%0t` | Time (no leading spaces) | 100 |

---

### Complete Testbench Example

```verilog
`timescale 1ns / 1ps

module adder_4bit_tb;
    // Signals
    reg [3:0] a, b;
    reg cin;
    wire [3:0] sum;
    wire cout;
    
    // Instantiate DUT
    adder_4bit UUT (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    // Test stimulus
    initial begin
        $display("========== 4-Bit Adder Test ==========");
        $monitor("Time=%0t | a=%b(%d) b=%b(%d) cin=%b | sum=%b(%d) cout=%b", 
                 $time, a, a, b, b, cin, sum, sum, cout);
        
        // Test 1: 0 + 0 + 0 = 0
        a = 4'b0000; b = 4'b0000; cin = 0;
        #10;
        
        // Test 2: 3 + 5 + 0 = 8
        a = 4'd3; b = 4'd5; cin = 0;
        #10;
        
        // Test 3: 15 + 1 + 0 = 16 (overflow)
        a = 4'd15; b = 4'd1; cin = 0;
        #10;
        
        // Test 4: 10 + 5 + 1 = 16
        a = 4'd10; b = 4'd5; cin = 1;
        #10;
        
        // Test 5: 15 + 15 + 1 = 31 (maximum)
        a = 4'd15; b = 4'd15; cin = 1;
        #10;
        
        $display("========== All Tests Complete ==========");
        $finish;
    end
endmodule
```

**Expected Output:**
```
========== 4-Bit Adder Test ==========
Time=0 | a=0000(0) b=0000(0) cin=0 | sum=0000(0) cout=0
Time=10 | a=0011(3) b=0101(5) cin=0 | sum=1000(8) cout=0
Time=20 | a=1111(15) b=0001(1) cin=0 | sum=0000(0) cout=1
Time=30 | a=1010(10) b=0101(5) cin=1 | sum=0000(0) cout=1
Time=40 | a=1111(15) b=1111(15) cin=1 | sum=1111(15) cout=1
========== All Tests Complete ==========
```

---

### Testbench with Clock (7-Segment Display)

```verilog
module adder_4bit_7seg_tb;
    reg clk;
    reg [3:0] a, b;
    reg cin;
    wire [3:0] sum_led;
    wire cout_led;
    wire [6:0] seg;
    wire [3:0] an;
    
    // Instantiate DUT
    adder_4bit_7seg_top UUT (
        .clk(clk),
        .a(a),
        .b(b),
        .cin(cin),
        .sum_led(sum_led),
        .cout_led(cout_led),
        .seg(seg),
        .an(an)
    );
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end
    
    // Test stimulus
    initial begin
        // Initialize
        a = 4'b0000;
        b = 4'b0000;
        cin = 0;
        #100;  // Wait for display to stabilize
        
        // Test cases
        a = 4'd5; b = 4'd3; cin = 0;
        #10;
        $display("Test: %d + %d + %d = %d", a, b, cin, {cout_led, sum_led});
        
        a = 4'd15; b = 4'd15; cin = 1;
        #10;
        $display("Test: %d + %d + %d = %d", a, b, cin, {cout_led, sum_led});
        
        #1000;  // Wait to observe multiplexing
        $finish;
    end
endmodule
```

---

### Testbench Best Practices ⭐

1. **Always use `$display` or `$monitor`** to see results
2. **Wait between test cases** (#10, #20, etc.) for signals to propagate
3. **Test edge cases**: 0, maximum values, overflow
4. **Use meaningful variable names** in messages
5. **Include both binary and decimal** in output for clarity
6. **Test all combinations** for small designs (exhaustive testing)
7. **Use `initial begin...end`** blocks for stimulus
8. **End with `$finish`** to terminate simulation cleanly

---

## 🔌 XDC Constraints and Pin Mapping ⭐ FPGA Specific

### What is an XDC File?

**XDC** (Xilinx Design Constraints) file:
- Maps design signals to physical FPGA pins
- Sets electrical standards (voltage levels)
- Defines timing constraints
- Required for FPGA implementation
- **Not needed for simulation**

---

### XDC File Syntax

```tcl
set_property -dict { PACKAGE_PIN <pin> IOSTANDARD <standard> } [get_ports {<signal>}]
```

**Parameters:**
- `PACKAGE_PIN`: Physical pin on FPGA (e.g., W5, V17)
- `IOSTANDARD`: Voltage standard (usually LVCMOS33 = 3.3V)
- `get_ports`: Signal name from top module

---

### Basys3 Pin Assignments ⭐ Memorize Common Ones

#### Clock
```tcl
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
```
- **W5**: 100 MHz oscillator
- Period = 10ns (100MHz)

#### Switches (SW0-SW15)
```tcl
# SW0-SW3 (Input A)
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {a[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {a[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {a[2]}]
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {a[3]}]

# SW4-SW7 (Input B)
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {b[0]}]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {b[1]}]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {b[2]}]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {b[3]}]

# SW8 (Carry In)
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports cin]

# SW9-SW10 (ALU Control)
set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports s0]
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports s1]
```

#### LEDs (LD0-LD15)
```tcl
# LD0-LD3 (Sum output)
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {sum[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {sum[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {sum[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {sum[3]}]

# LD4 (Carry output)
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports cout]
```

#### 7-Segment Display
```tcl
# Cathodes (segments A-G)
# seg[6]=CA, seg[5]=CB, seg[4]=CC, seg[3]=CD, seg[2]=CE, seg[1]=CF, seg[0]=CG
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]  # CA
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]  # CB
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]  # CC
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]  # CD
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]  # CE
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]  # CF
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]  # CG

# Anodes (digit select, active-low)
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]  # Digit 0 (rightmost)
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]  # Digit 1
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]  # Digit 2
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]  # Digit 3 (leftmost)
```

#### Buttons
```tcl
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports btnC]  # Center
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports btnU]  # Up
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports btnL]  # Left
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports btnR]  # Right
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports btnD]  # Down
```

---

### Vector Signal Syntax ⭐ Important

**For vector signals (multi-bit):**
```tcl
# Method 1: Individual bits
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {a[0]}]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {a[1]}]

# Method 2: All bits at once (less common)
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports a[0]]
```

⚠️ **Note**: Curly braces `{}` are optional for single bit, required for consistency.

---

### Common XDC Mistakes ⭐

1. **Misspelled signal names** - must match top module exactly
2. **Wrong pin numbers** - double-check Basys3 reference manual
3. **Missing bits** - all vector bits must be assigned
4. **Uncommenting unused pins** - causes conflicts
5. **Forgetting clock constraint** for timing analysis

---

### Complete XDC Example (4-Bit Adder)

```tcl
## Clock (not needed for pure combinational)
#set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]

## Input A (SW0-SW3)
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {a[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {a[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {a[2]}]
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {a[3]}]

## Input B (SW4-SW7)
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {b[0]}]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {b[1]}]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {b[2]}]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {b[3]}]

## Carry In (SW8)
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports cin]

## Sum Output (LD0-LD3)
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {sum[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {sum[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {sum[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {sum[3]}]

## Carry Out (LD4)
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports cout]
```

---

### Vivado Flow with XDC ⭐

1. **Add Design Sources** (.v files)
2. **Add Constraints** (.xdc file)
3. **Run Synthesis** - Checks design syntax
4. **Run Implementation** - Places and routes design
5. **Generate Bitstream** - Creates .bit file
6. **Program Device** - Upload to FPGA

---

## 🧮 Control Unit Design Patterns

### Control Unit - Version 1 (Explicit Logic)

```verilog
module control(
    input [3:0] b,
    input s0, s1,
    output [3:0] y
);
    wire [3:0] b_and, b_not;
    wire [3:0] s0_vec, s1_vec;
    
    // Replicate control signals to match width
    assign s0_vec = {4{s0}};  // {s0, s0, s0, s0}
    assign s1_vec = {4{s1}};
    
    // Select operations
    assign b_and = b & s0_vec;      // Pass B if s0=1
    assign b_not = (~b) & s1_vec;   // Pass ~B if s1=1
    
    // Combine results
    assign y = b_and | b_not;
    
endmodule
```

### Control Unit - Version 2 (Ternary Operator) ⭐ More Elegant

```verilog
module control(
    input [3:0] b,
    input s0, s1,
    output [3:0] y
);
    // Nested ternary: if s1 then ~b, else if s0 then b, else 0
    assign y = s1 ? (~b) : (s0 ? b : 4'b0000);
    
endmodule
```

**Truth Table:**
| s1 | s0 | Output y |
|----|----|----------|
| 0  | 0  | 0000     |
| 0  | 1  | b        |
| 1  | 0  | ~b       |
| 1  | 1  | ~b       |

**Priority:** s1 has higher priority than s0

---

### Replication Operator `{}` ⭐ Useful Trick

```verilog
// Replicate single bit to vector
wire [3:0] s0_vec = {4{s0}};

// Examples:
{4{1'b0}} = 4'b0000
{4{1'b1}} = 4'b1111
{3{2'b01}} = 6'b010101

// Common use: Extend control signals
wire enable = 1'b1;
wire [7:0] mask = {8{enable}};  // All 1s or all 0s
```

---

## 🧪 Lab Implementations

### LAB 1: 4-Bit Ripple Carry Adder

**Objective:** Implement modular 4-bit adder using half adders and full adders

**Module Hierarchy:**
```
adder_4bit
├── full_adder (×4)
│   └── half_adder (×2 each)
```

**Key Learning:**
- Structural modeling (module instantiation)
- Hierarchical design
- Carry propagation
- Testbench writing

---

### LAB 2: Adder with 7-Segment Display

**Objective:** Display adder result on FPGA 7-segment display

**Module Hierarchy:**
```
adder_4bit_7seg_top
├── adder_4bit
│   └── full_adder (×4)
│       └── half_adder (×2 each)
└── seg_display_controller
    └── hex_to_7seg
```

**Key Learning:**
- FPGA I/O interfacing
- 7-segment display encoding (common anode)
- Time-division multiplexing
- Clock management
- Binary to decimal conversion
- XDC constraints file

---

### LAB 2 Extension: ALU with 7-Segment

**Objective:** Implement simple ALU with addition/subtraction

**Additional Components:**
- Control unit for operation selection
- Two's complement subtraction
- Result display

**Key Learning:**
- ALU design principles
- Two's complement arithmetic
- Control signal management
- Conditional carry input

---

## 📝 Common Exam Topics

### Theory Questions

1. **Explain the difference between wire and reg in Verilog**
   - Wire: continuous assignment, combinational
   - Reg: procedural assignment, can be combinational or sequential
   - Reg doesn't always mean flip-flop!

2. **What is the difference between blocking and non-blocking assignments?**
   - Blocking (=): Sequential execution
   - Non-blocking (<=): Parallel execution
   - Use = for combinational, <= for sequential

3. **Explain how 7-segment multiplexing works**
   - Shared cathodes between digits
   - Rapid switching between digits (>60Hz)
   - Persistence of vision creates illusion

4. **How does two's complement subtraction work?**
   - A - B = A + (~B) + 1
   - Complement second operand, add 1 via carry

5. **What is ripple carry adder delay?**
   - 2N gate delays for N-bit adder
   - Carry must propagate from LSB to MSB

6. **What is the difference between $display and $monitor?**
   - $display: Prints once when executed
   - $monitor: Prints automatically when arguments change
   - Only one $monitor can be active at a time

7. **What is an XDC file used for?**
   - Maps design signals to physical FPGA pins
   - Sets electrical standards (LVCMOS33)
   - Defines timing constraints
   - Not needed for simulation

8. **Explain the replication operator in Verilog**
   - `{n{value}}` replicates value n times
   - Example: `{4{1'b1}}` = `4'b1111`
   - Useful for extending control signals

---

### Design Questions

1. **Design a 2-to-1 multiplexer**
   ```verilog
   assign out = sel ? b : a;
   ```

2. **Design a 4-bit counter**
   ```verilog
   always @(posedge clk or posedge rst) begin
       if (rst) count <= 0;
       else count <= count + 1;
   end
   ```

3. **Design a 7-segment decoder for common anode**
   - Use case statement
   - Active-low outputs
   - Include all 10 digits

4. **Design full adder using half adders**
   - Two half adders
   - OR the carry outputs

5. **Write a simple testbench structure**
   ```verilog
   module dut_tb;
       reg inputs;
       wire outputs;
       dut UUT(.in(inputs), .out(outputs));
       initial begin
           // Test cases
           inputs = 0; #10;
           inputs = 1; #10;
           $finish;
       end
   endmodule
   ```

6. **Write XDC constraint for a 4-bit vector**
   ```tcl
   set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {a[0]}]
   set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {a[1]}]
   # ... continue for all bits
   ```

---

### Debugging Questions

**Common Errors:**
1. Forgetting to declare variable as `reg` in always block
2. Using blocking assignment in sequential logic
3. Missing signals in sensitivity list
4. No `default` in case statement (causes latches)
5. Wrong active-low logic for common anode display
6. Signal name mismatch between design and XDC file
7. Forgetting to declare testbench inputs as `reg`
8. Not adding `#delay` between test cases
9. Missing `$finish` in testbench (simulation runs forever)
10. Using `wire` instead of `reg` for DUT inputs in testbench

---

### Timing Questions

1. **Calculate 7-segment refresh rate**
   - Clock frequency / 2^counter_bits / num_digits
   - Example: 100MHz / 2^18 / 2 ≈ 190 Hz

2. **Calculate ripple carry delay**
   - N-bit adder: 2N × gate_delay

---

## 🚀 Quick Reference

### Verilog Cheat Sheet

```verilog
// Module template
module name(input a, output b);
    assign b = a;
endmodule

// Combinational always block
always @(*) begin
    out = a & b;
end

// Sequential always block
always @(posedge clk) begin
    q <= d;
end

// Case statement
case (sel)
    0: out = a;
    1: out = b;
    default: out = 0;
endcase

// Conditional operator
assign out = sel ? a : b;

// Instantiation
module_name inst(.port(signal));

// Testbench template
module tb;
    reg clk, reset;
    reg [3:0] inputs;
    wire [3:0] outputs;
    
    // DUT instantiation
    design_module UUT(
        .clk(clk),
        .rst(reset),
        .in(inputs),
        .out(outputs)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Stimulus
    initial begin
        reset = 1; #10; reset = 0;
        inputs = 4'b0000; #10;
        inputs = 4'b0101; #10;
        $finish;
    end
endmodule
```

---

### System Tasks Quick Reference

```verilog
$display("format", args);     // Print once
$monitor("format", args);     // Print on change
$finish;                      // End simulation
$stop;                        // Pause simulation
$time;                        // Current time

// Format specifiers
%b  // Binary
%d  // Decimal
%h  // Hexadecimal
%t  // Time
%0d // Decimal (no leading spaces)
```

---

### XDC Template

```tcl
## Clock (100MHz on Basys3)
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports clk]

## Switches
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]

## LEDs
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]

## 7-Segment Cathodes
set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]

## 7-Segment Anodes
set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
```

---

### Common Patterns

**Combinational Logic:**
```verilog
always @(*) begin
    // Use blocking (=)
    result = a & b | c;
end
```

**Sequential Logic:**
```verilog
always @(posedge clk) begin
    // Use non-blocking (<=)
    q <= d;
end
```

**Decoder:**
```verilog
always @(*) begin
    case(input)
        0: out = 4'b0001;
        1: out = 4'b0010;
        default: out = 4'b0000;
    endcase
end
```

---

### Basys3 FPGA Specifics

**Clock:** W5 pin, 100 MHz  
**Switches:** V17, V16, W16, W17, W15, V15, W14, W13, V2, T3, T2, R3, W2, U1, T1, R2  
**LEDs:** U16, E19, U19, V19, W18, U15, U14, V14, V13, V3, W3, U3, P3, N3, P1, L1  
**7-Segment Cathodes:** W7, W6, U8, V8, U5, V5, U7  
**7-Segment Anodes:** U2, U4, V4, W4  

---

### Key Equations

**Full Adder:**
- Sum = A ⊕ B ⊕ Cin
- Cout = AB + ACin + BCin

**Refresh Rate:**
- freq = clk_freq / 2^counter_bits / num_digits

**Decimal Conversion:**
- tens = value / 10
- ones = value % 10

**Two's Complement:**
- -B = ~B + 1
- A - B = A + ~B + 1

---

## 📚 Study Tips

1. **Practice module instantiation** - understand hierarchical design
2. **Memorize 7-segment encoding** for digits 0-9
3. **Know when to use = vs <=** - critical for exams
4. **Understand multiplexing timing** - calculate refresh rates
5. **Draw block diagrams** - helps visualize data flow
6. **Trace signal propagation** - understand ripple carry delay
7. **Write testbenches** - verify your designs
8. **Know XDC syntax** - pin assignments and constraints

---

## ✅ Pre-Exam Checklist

- [ ] Difference between wire and reg
- [ ] Blocking vs non-blocking assignments
- [ ] Sensitivity lists (@(*) vs @(posedge clk))
- [ ] 7-segment encoding (common anode, active-low)
- [ ] Multiplexing concept and timing
- [ ] Full adder logic equations
- [ ] Ripple carry delay calculation
- [ ] Two's complement subtraction
- [ ] Case vs if-else synthesis
- [ ] Module instantiation syntax
- [ ] XDC constraint file format
- [ ] Binary to decimal conversion
- [ ] Verilog operators (bitwise, reduction, logical)
- [ ] Testbench structure (reg for inputs, wire for outputs)
- [ ] System tasks ($display, $monitor, $finish, $time)
- [ ] Clock generation in testbench
- [ ] Replication operator {n{value}}
- [ ] Basys3 pin locations (clock=W5, switches start at V17)
- [ ] Format specifiers (%b, %d, %h, %t)
- [ ] Control unit design with ternary operators

---

**Good Luck! 🎓**