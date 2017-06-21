# MAX7219 example usage in VHDL

Simple proof of concept on how to manipulate a MAX7219 based led matrix using an FPGA, VHDL and the SPI protocol.

### Notes:

Example pin assignments for DE0 Nano:
* CLOCK 50: R8
* LED_CLK: A2 (GPIO_02)
* LED_CS: B3 (GPIO_04)
* LED_DIN: A4 (GPIO_06)


In order to run a simulation, set the Library (in project files properties) to "utils" for all files added from within the "utils" subdirectory.
