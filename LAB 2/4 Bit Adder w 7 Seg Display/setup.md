# 4-Bit Adder with 7-Segment Display for Basys 3 FPGA

## Project Overview

This project extends a modular 4-bit ripple-carry adder to display its result on the Basys 3 FPGA's 7-segment display.

## Module Hierarchy

```
adder_4bit_7seg_top (Top Module)
├── adder_4bit
│   └── full_adder (x4)
│       └── half_adder (x2)
└── seg_display_controller
    └── hex_to_7seg
```

## Files

| File | Description |
|------|-------------|
| `half_adder.v` | Basic half adder (XOR for sum, AND for carry) |
| `full_adder.v` | Full adder using 2 half adders |
| `adder_4bit.v` | 4-bit ripple-carry adder using 4 full adders |
| `hex_to_7seg.v` | Converts 4-bit value to 7-segment cathode pattern |
| `seg_display_controller.v` | Multiplexes 2 digits, extracts decimal digits |
| `adder_4bit_7seg_top.v` | Top module integrating adder with display |
| `adder_7seg.xdc` | Pin constraints for Basys 3 |
| `adder_4bit_7seg_tb.v` | Testbench |

---

## 7-Segment Display: In-Depth Explanation

### Physical Structure of a 7-Segment Display

A 7-segment display consists of 7 LEDs arranged to form a digit shape:

```
     ━━━ A ━━━
    ┃         ┃
    F         B
    ┃         ┃
     ━━━ G ━━━
    ┃         ┃
    E         C
    ┃         ┃
     ━━━ D ━━━   (DP)
```

Each segment (A-G) is an individual LED. By turning specific segments ON/OFF, we can display digits 0-9 and hex characters A-F.

### Common Anode vs Common Cathode

LEDs have two terminals: **Anode (+)** and **Cathode (-)**. Current flows from anode to cathode to light up the LED.

**Common Cathode Display:**
- All cathodes are tied together to GND
- To light a segment, drive its anode HIGH
- Logic: HIGH = ON, LOW = OFF

**Common Anode Display (Basys 3 uses this):**
- All anodes are tied together to VCC
- To light a segment, drive its cathode LOW
- Logic: LOW = ON, HIGH = OFF (inverted!)

```
Common Anode Structure:
                    VCC (3.3V)
                      │
            ┌────┬────┼────┬────┐
            │    │    │    │    │
           LED  LED  LED  LED  LED  (LED anodes connected)
            │    │    │    │    │
            A    B    C    D    E  ... (cathodes directly active-low accent )
```

### Basys 3: 4-Digit Display with Shared Cathodes

The Basys 3 has a **4-digit** 7-segment display. To save FPGA pins, the cathodes of all 4 digits are connected together:

```
        Digit 3    Digit 2    Digit 1    Digit 0
        (AN3)      (AN2)      (AN1)      (AN0)
        ┌───┐      ┌───┐      ┌───┐      ┌───┐
        │   │      │   │      │   │      │   │
        └───┘      └───┘      └───┘      └───┘
          │          │          │          │
          └──────────┴──────────┴──────────┘
                          │
            Shared Cathodes (CA, CB, CC, CD, CE, CF, CG)
```

**Problem:** With shared cathodes, if we send the pattern for "5" to the cathodes, ALL 4 digits would show "5".

**Solution:** Time-division multiplexing.

### Time-Division Multiplexing

We rapidly switch between digits, showing only ONE digit at a time:

```
Time ──────────────────────────────────────────────────►

        ┌─────┐           ┌─────┐           ┌─────┐
AN0:    │ ON  │           │ ON  │           │ ON  │
        └─────┘           └─────┘           └─────┘
              ┌─────┐           ┌─────┐
AN1:          │ ON  │           │ ON  │
              └─────┘           └─────┘

Cathodes: [dig0] [dig1] [dig0] [dig1] [dig0] [dig1] ...

        ◄─────────────────────────────────────────────►
                    One refresh cycle
```

**Key insight:** If we switch fast enough (>60Hz), human eyes perceive all digits as lit simultaneously due to persistence of vision.

### Anode Control (Active-Low)

The anodes are controlled through PNP transistors on the Basys 3. The FPGA outputs active-low signals:

| FPGA Output | Transistor | Anode | Digit State |
|-------------|------------|-------|-------------|
| 0 (LOW)     | ON         | HIGH  | **ENABLED** |
| 1 (HIGH)    | OFF        | LOW   | DISABLED    |

To enable only digit 0 (rightmost):
```verilog
an = 4'b1110;  // AN3=1(off), AN2=1(off), AN1=1(off), AN0=0(on)
```

To enable only digit 1:
```verilog
an = 4'b1101;  // AN3=1(off), AN2=1(off), AN1=0(on), AN0=1(off)
```

### Cathode Encoding (Active-Low)

Since Basys 3 is common-anode, cathodes are active-low:
- Cathode = 0 → Segment ON
- Cathode = 1 → Segment OFF

Segment mapping: `seg[6:0] = {CA, CB, CC, CD, CE, CF, CG}`

**Encoding table for digits 0-9:**

```
Digit   Segments ON      seg[6:0]     Visual
─────────────────────────────────────────────
  0     A,B,C,D,E,F      0000001       ┌───┐
                                       │   │
                                       └───┘

  1     B,C              1001111         │
                                         │

  2     A,B,G,E,D        0010010       ┌───┐
                                        ───┤
                                       └───

  3     A,B,C,D,G        0000110       ────┐
                                        ───┤
                                       ────┘

  4     F,G,B,C          1001100       │   │
                                        ───┤
                                           │

  5     A,F,G,C,D        0100100       ├───
                                        ───┤
                                       ────┘

  6     A,F,E,D,C,G      0100000       ├───
                                       │───┤
                                       └───┘

  7     A,B,C            0001111       ────┐
                                           │
                                           │

  8     A,B,C,D,E,F,G    0000000       ┌───┐
                                       │───│
                                       └───┘

  9     A,B,C,D,F,G      0000100       ┌───┐
                                        ───┤
                                       ────┘
```

**Example: Displaying "1"**
- Segments B and C should be ON (cathode = 0)
- Segments A, D, E, F, G should be OFF (cathode = 1)
- Pattern: `{A,B,C,D,E,F,G}` = `{1,0,0,1,1,1,1}` = `7'b1001111`

### Timing Calculations

**Goal:** Refresh rate between 60Hz and 1000Hz to avoid flicker.

**Basys 3 clock:** 100 MHz (period = 10ns)

**Our approach:** Use an 18-bit counter. The MSB toggles at:

```
Counter max value = 2^18 - 1 = 262,143
Time to overflow  = 262,144 × 10ns = 2.62ms

MSB toggle frequency = 100,000,000 / 2^18 
                     = 100,000,000 / 262,144 
                     ≈ 381 Hz (per digit)
```

With 2 digits, full refresh cycle:
```
Full cycle = 2 × 2.62ms = 5.24ms
Refresh rate = 1 / 5.24ms ≈ 190 Hz
```

This is well above 60Hz, so no visible flicker.

**Counter logic:**
```verilog
reg [17:0] refresh_counter;

always @(posedge clk)
    refresh_counter <= refresh_counter + 1;

// MSB selects which digit to display
wire digit_select = refresh_counter[17];
// digit_select = 0 → show ones digit (for ~2.6ms)
// digit_select = 1 → show tens digit (for ~2.6ms)
```

### Number Conversion: Binary to Decimal Digits

Our adder produces a 5-bit binary result (0-31). To display in decimal, we need to extract individual digits.

**Mathematical basis:**
- Tens digit = floor(value / 10)
- Ones digit = value mod 10

**Example:** Result = 23 (binary: 10111)
```
Tens = 23 / 10 = 2  (integer division)
Ones = 23 % 10 = 3  (modulo/remainder)
Display: "23"
```

**Another example:** Result = 7 (binary: 00111)
```
Tens = 7 / 10 = 0
Ones = 7 % 10 = 7
Display: "07"
```

**Verilog implementation:**
```verilog
wire [4:0] value = 5'd23;      // 5-bit input from adder
wire [3:0] tens  = value / 10; // Synthesizes to combinational logic
wire [3:0] ones  = value % 10; // Synthesizes to combinational logic
```

**Note on synthesis:** Division and modulo by constants (like 10) synthesize into efficient combinational logic circuits. The synthesizer recognizes the constant divisor and creates optimized hardware. For variable divisors, you'd need a sequential divider circuit.

### Complete Data Flow

```
Step 1: INPUT
─────────────────────────────────
Switches A[3:0] = 1111 (15)
Switches B[3:0] = 1111 (15)  
Switch Cin      = 1

Step 2: ADDITION (adder_4bit)
─────────────────────────────────
  1111 (15)
+ 1111 (15)
+    1 (cin)
──────────
 11111 (31)

sum[3:0] = 1111 (15)
cout     = 1

Step 3: COMBINE RESULT
─────────────────────────────────
full_result = {cout, sum} = 5'b11111 = 31

Step 4: EXTRACT DECIMAL DIGITS
─────────────────────────────────
tens = 31 / 10 = 3
ones = 31 % 10 = 1

Step 5: MULTIPLEXING (repeats continuously)
─────────────────────────────────
Time 0-2.6ms:   digit_select=0
                an = 4'b1110 (AN0 enabled)
                current_digit = ones = 1
                seg = 7'b1001111 (shows "1")

Time 2.6-5.2ms: digit_select=1
                an = 4'b1101 (AN1 enabled)
                current_digit = tens = 3
                seg = 7'b0000110 (shows "3")

(cycle repeats at 190Hz)

Step 6: PERCEIVED OUTPUT
─────────────────────────────────
Human sees: "31" on rightmost two digits
```

### Display Controller Code Walkthrough

```verilog
module seg_display_controller(
    input clk,
    input [4:0] value,        // 5-bit input (0-31)
    output [6:0] seg,         // cathode signals
    output reg [3:0] an       // anode signals (active-low)
);

    // ══════════════════════════════════════════════════
    // 1. REFRESH COUNTER
    // ══════════════════════════════════════════════════
    // Counts at 100MHz. When MSB toggles, we switch digits.
    // 18 bits → toggles at 381Hz per digit
    reg [17:0] refresh_counter = 0;
    always @(posedge clk)
        refresh_counter <= refresh_counter + 1;
    
    // ══════════════════════════════════════════════════
    // 2. DIGIT SELECT SIGNAL
    // ══════════════════════════════════════════════════
    // Use MSB to alternate between two digits
    wire digit_select = refresh_counter[17];
    // 0 = display ones digit
    // 1 = display tens digit
    
    // ══════════════════════════════════════════════════
    // 3. DECIMAL DIGIT EXTRACTION
    // ══════════════════════════════════════════════════
    // Convert binary (0-31) to two decimal digits
    wire [3:0] ones = value % 10;  // Remainder
    wire [3:0] tens = value / 10;  // Quotient
    
    // ══════════════════════════════════════════════════
    // 4. MULTIPLEXER: Select digit and anode
    // ══════════════════════════════════════════════════
    reg [3:0] current_digit;
    always @(*) begin
        case(digit_select)
            1'b0: begin
                an = 4'b1110;           // Enable AN0 only (rightmost)
                current_digit = ones;   // Show ones digit
            end
            1'b1: begin
                an = 4'b1101;           // Enable AN1 only
                current_digit = tens;   // Show tens digit
            end
        endcase
    end
    
    // ══════════════════════════════════════════════════
    // 5. DECODER: Convert digit to segment pattern
    // ══════════════════════════════════════════════════
    hex_to_7seg decoder(
        .hex(current_digit),
        .seg(seg)
    );
endmodule
```

---

## Pin Mapping

### Inputs
| Signal | Pin | Description |
|--------|-----|-------------|
| `a[0]` | V17 | Switch 0 |
| `a[1]` | V16 | Switch 1 |
| `a[2]` | W16 | Switch 2 |
| `a[3]` | W17 | Switch 3 |
| `b[0]` | W15 | Switch 4 |
| `b[1]` | V15 | Switch 5 |
| `b[2]` | W14 | Switch 6 |
| `b[3]` | W13 | Switch 7 |
| `cin`  | V2  | Switch 8 |
| `clk`  | W5  | 100MHz oscillator |

### Outputs
| Signal | Pin | Description |
|--------|-----|-------------|
| `seg[6]` (CA) | W7 | Segment A cathode |
| `seg[5]` (CB) | W6 | Segment B cathode |
| `seg[4]` (CC) | U8 | Segment C cathode |
| `seg[3]` (CD) | V8 | Segment D cathode |
| `seg[2]` (CE) | U5 | Segment E cathode |
| `seg[1]` (CF) | V5 | Segment F cathode |
| `seg[0]` (CG) | U7 | Segment G cathode |
| `an[0]` | U2 | Anode 0 (rightmost digit) |
| `an[1]` | U4 | Anode 1 |
| `an[2]` | V4 | Anode 2 (unused, kept HIGH) |
| `an[3]` | W4 | Anode 3 (unused, kept HIGH) |

---

## Vivado Setup

1. Create new project, select `xc7a35tcpg236-1`
2. Add all `.v` source files
3. Add `adder_7seg.xdc` as constraints
4. Set `adder_4bit_7seg_top` as top module
5. Run Synthesis → Implementation → Generate Bitstream
6. Program the board

## Testing Examples

| A (SW3-0) | B (SW7-4) | Cin (SW8) | Binary Result | Decimal Display |
|-----------|-----------|-----------|---------------|-----------------|
| 0000 (0)  | 0000 (0)  | 0         | 00000         | 00              |
| 0101 (5)  | 0011 (3)  | 0         | 01000         | 08              |
| 1111 (15) | 1111 (15) | 0         | 11110         | 30              |
| 1111 (15) | 1111 (15) | 1         | 11111         | 31              |
| 1001 (9)  | 0110 (6)  | 1         | 10000         | 16              |