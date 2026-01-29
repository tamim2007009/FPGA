# Verilog Programming Tutorial

## Table of Contents

* [Introduction](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#introduction)
* [Levels of Description](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#levels-of-description)
* [Verilog Language Basics](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#verilog-language-basics)
* [Data Types](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#data-types)
* [Operators](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#operators)
* [Module Structure](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#module-structure)
* [Assignments](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#assignments)
* [Control Constructs](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#control-constructs)
* [Examples](https://claude.ai/chat/8fbd19ae-ea0c-45f2-aa67-30d6963116e2#examples)

## Introduction

**Verilog HDL** is a Hardware Description Language used to describe digital systems, such as computers or components of a computer.

### Key Features:

* **IEEE Standard** : Verilog is an industry-standard HDL
* **Syntax** : Similar to C programming language
* **Alternative** : VHDL (similar to PASCAL/Ada)
* **Case Sensitive** : All keywords are lowercase

### Why Use HDL?

* Gate-level design is unmanageable for large systems (millions of transistors)
* HDL provides mechanisms to describe, test, and synthesize large designs
* Essential for modern digital design

## Levels of Description

### 1. Switch Level

* Layout of wires, resistors, and transistors on an IC chip

### 2. Gate (Structural) Level

* Logical gates, flip-flops, and their interconnections
* Very easy to synthesize
* Text-based schematic entry

### 3. RTL (Register Transfer Level)

* **Synthesizable**
* Uses registers (flip-flops) with combinational logic between them
* Most common level for design

### 4. Behavioral (Algorithmic) Level

* Highest level of abstraction
* Easiest to write and debug
* **Not synthesizable**
* Description of algorithm without hardware implementation details

## Verilog Language Basics

### Comments

```verilog
// Single line comment

/* Multi-line
   comment */
```

### Identifiers

* Equivalent to variable names in C
* Can be up to 1024 characters
* Case sensitive

### Keywords

* Reserved words like `module`, `endmodule`, `input`, `output`
* Always in lowercase

## Data Types

### Wire

* Represents physical connections between structural entities (gates)
* Does not store values, only labels on wires
* Default value when unconnected: `x` (unknown)

### Reg (Register)

* Stores the last value that was procedurally assigned
* **Note** : A `reg` variable does NOT necessarily represent a physical register!
* Initialized to 0 at simulation start

### Possible Values

| Value | Meaning                    |
| ----- | -------------------------- |
| `0` | Logical zero or false      |
| `1` | Logical one or true        |
| `x` | Unknown logical value      |
| `z` | High impedance (tri-state) |

### Number Representation

 **Format** : `<size><base format><number>`

```verilog
549          // decimal number
'h8FF        // hex number
'o765        // octal number
4'b1011      // 4-bit binary number: 1011
3'b10x       // 3-bit binary with LSB unknown
5'd3         // 5-bit decimal number
-4'b11       // Two's complement of 0011 = 1101
```

### Register/Wire Declaration

```verilog
// 8-bit registers, MSB at bit 0
reg [0:7] A, B;

// 4-bit wire
wire [0:3] Dataout;

// 8-bit register, MSB at bit 7 (recommended convention)
reg [7:0] C;
```

## Operators

### Bitwise Operators

Perform bit-oriented operations on vectors:

```verilog
~a        // NOT
a & b     // AND
a | b     // OR
a ^ b     // XOR
a ~^ b    // XNOR (also a ^~ b)
```

 **Example** :

```verilog
~(4'b0101) = 4'b1010
4'b0101 & 4'b0011 = 4'b0001
```

### Reduction Operators

Act on each bit of a single input vector:

```verilog
&a        // AND
~&a       // NAND
|a        // OR
~|a       // NOR
^a        // XOR
~^a       // XNOR
```

 **Example** :

```verilog
&(4'b0101) = 0 & 1 & 0 & 1 = 1'b0
```

### Logical Operators

Return one-bit (true/false) results:

```verilog
!a        // NOT
a && b    // AND
a || b    // OR
a == b    // Equality (returns x if x or z in bits)
a != b    // Inequality
a === b   // Case equality (bit-by-bit comparison)
a !== b   // Case inequality
```

### Arithmetic Operators

```verilog
-a        // Negate
a + b     // Add
a - b     // Subtract
a * b     // Multiply
a / b     // Divide
a % b     // Modulus
a ** b    // Exponentiate
```

### Shift Operators

```verilog
a << b    // Logical left shift
a >> b    // Logical right shift
a <<< b   // Arithmetic left shift
a >>> b   // Arithmetic right shift
```

### Relational Operators

```verilog
a > b     // Greater than
a >= b    // Greater than or equal
a < b     // Less than
a <= b    // Less than or equal
```

### Conditional Operator

```verilog
a ? b : c  // If a then b else c
```

### Concatenation

```verilog
A = 8'b01011010;
B = {A[0:3] | A[4:7], 4'b0000};  // B = 11110000
```

## Module Structure

```verilog
module <module_name> (<port_list>);
    <declarations>
    <module_items>
endmodule
```

### Components:

* **module_name** : Unique identifier for the module
* **port_list** : Input, output, and inout ports
* **declarations** : Registers, wires, memories, functions, tasks
* **module_items** : Initial constructs, always blocks, continuous assignments, module instances

### Example: NAND Gate

```verilog
// RTL model of a NAND gate
module NAND(in1, in2, out);
    input in1, in2;
    output out;
  
    // Continuous assignment
    assign out = ~(in1 & in2);
endmodule
```

### Module Instantiation

 **Format** : `<module_name> <instance_name> (<port_list>);`

```verilog
// AND gate using two NAND gates
module AND(in1, in2, out);
    input in1, in2;
    output out;
    wire w1;
  
    // Two instances of NAND module
    NAND NAND1(in1, in2, w1);
    NAND NAND2(w1, w1, out);
endmodule
```

## Assignments

### Continuous Assignment

* Used to model **combinational logic**
* Drives **wire** variables
* Evaluated whenever an input changes

```verilog
assign out = ~(in1 & in2);
```

### Procedural Assignment

* Used for both **combinational and sequential logic**
* Changes the state of a **register**
* Must be within an `always` or `initial` block

```verilog
reg A;
always @ (B or C) begin
    A = B & C;  // Combinational logic
end
```

### Blocking vs Non-Blocking

#### Blocking Assignment (`=`)

* Acts like traditional programming languages
* Statement completes before moving to next statement

```verilog
always @(posedge Clk) begin
    C = C + 1;
    A = C + 1;  // A is ahead of C by 1
end
```

#### Non-Blocking Assignment (`<=`)

* Evaluates all right-hand sides in current time unit
* Assigns left-hand sides at end of time unit
* **Recommended for sequential logic**

```verilog
always @(posedge Clk) begin
    D <= D + 1;
    B <= D + 1;  // B equals old D + 1 (same as D)
end
```

## Events

Procedural statements are triggered by:

* Value change on a wire
* Named events

```verilog
// Triggered by any change in B or C
always @ (B or C) begin
    X = B & C;
end

// Triggered by positive edge of clock
always @(posedge Clk) begin
    Y <= B & C;
end

// Triggered by negative edge of clock
always @(negedge Clk) begin
    Z <= B & C;
end
```

## Control Constructs

### If-Else Statement

```verilog
if (A == 4) begin
    B = 2;
end
else if (A == 2) begin
    B = 1;
end
else begin
    B = 4;
end
```

### Case Statement

```verilog
case (expression)
    value1: begin
        statement;
    end
    value2: begin
        statement;
    end
    default: begin
        statement;
    end
endcase
```

## Examples

### 1-bit 2-to-1 Multiplexer (Continuous Assignment)

```verilog
module mux1bit2to1(a, b, s, out);
    input a, b, s;
    output out;
  
    assign out = (~s & a) | (s & b);
endmodule
```

### 1-bit 2-to-1 Multiplexer (Procedural)

```verilog
module mux1bit2to1(a, b, s, out);
    input a, b, s;
    output out;
    reg out;
  
    always @ (s or a or b) begin
        if (s == 0)
            out = a;
        else
            out = b;
    end
endmodule
```

### D Flip-Flop

```verilog
module Dflipflop(D, Clk, Q, Qbar);
    input D, Clk;
    output Q, Qbar;
    reg Qint;
  
    // Transfer D to Q on positive clock edge
    always @(posedge Clk) begin
        Qint <= D;
    end
  
    assign Q = Qint;
    assign Qbar = ~Qint;
endmodule
```

## Best Practices

1. **Declare all variables** - Undeclared variables default to wire
2. **One variable per line** - Especially for inputs/outputs, with comments
3. **Use meaningful names** - Make code self-documenting
4. **One module per file** - Easier to maintain (not a requirement, but good practice)
5. **Use non-blocking assignments (`<=`)** for sequential logic
6. **Use blocking assignments (`=`)** for combinational logic
7. **Always specify bit widths** - Avoid ambiguity

## Common Pitfalls

* Forgetting to declare a variable as `reg` when using in procedural blocks
* Mixing blocking and non-blocking assignments inappropriately
* Not including all signals in sensitivity list for combinational logic
* Using `reg` thinking it always creates a physical register

## Additional Resources

* IEEE Standard 1364 (Verilog HDL)
* IEEE Standard 1800 (SystemVerilog)
* Vivado Design Suite (Xilinx FPGA tools)
* ModelSim, Icarus Verilog (simulators)

---

 **Note** : This tutorial is based on CSE 4224 - Digital System Design course materials.
