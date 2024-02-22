<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Stores memory in an internal memory block.
A pointer points to the current cell in the memory block.
Read and write instructions ( push and pop ) can be activated with the input pins 7 and 6.
After the operation is done, the output pin 7 is set to high to signal, that the stack is in idle mode now.

## How to test

Connect the bidirectional pins to input and output devices.
Push different numbers using the instruction pin, then pop those numbers again.
They should be in reversed order.

## External hardware

Clock with needed frequency, buttons for instructions, switches for bidirectional bus, LEDs for idle notifier and bidirectional bus
