# DE0Nano + MAX7219 example usage in VHDL

This example shows how to read data from the DE0 Nano integrated analog-to-digital converter using the SPI interface and then how to display this data using a MAX7219 LED Matrix.

### Notes:

Example pin assignments for DE0 Nano:
* CLOCK 50: R8
* LED_CLK: A2 (GPIO_02)
* LED_CS: B3 (GPIO_04)
* LED_DIN: A4 (GPIO_06)
* ADC_CS_N: A10
* ADC_SADDR: B10
* ADC_SCLK: B14
* ADC_SDAT: A9


In order to run a simulation, set the Library (in project files properties) to "utils" for all files added from within the "utils" subdirectory.
