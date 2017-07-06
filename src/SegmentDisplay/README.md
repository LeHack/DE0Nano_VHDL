# 4 digit 8 segment display (FJ-5461BH) example usage in VHDL

Simple proof of concept on how to manipulate a 4 digit display (7 segment + DP) using an FPGA, a 8-bit SIPO register and two 3-channel multiplexers.

### Notes:

Example pin assignments for DE0 Nano:
* CLOCK 50: R8

Register (74HC595):
* CLK: R13 (SHCP)
* LATCH: T11 (STCP)
* DATA: R12 (DS)

Multiplexers (74HC4053):
* MLTPLX_CH 0: T10 (#1 S1)
* MLTPLX_CH 1: R11 (#1 S2)
* MLTPLX_CH 2: P11 (#2 S1)
* MLTPLX_CH 3: R10 (#2 S2)

Below is a circuit and pcb design that can be used with this example:  
![Circuit](pcb/circuit.png)
![pcb](pcb/pcb.png)


In order to run a simulation, set the Library (in project files properties) to "utils" for all files added from within the "utils" subdirectory.
