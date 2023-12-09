# Systolic_Array_Design
The following repository houses a detailed implementation of the systolic array using Verilog and System Verilog.
The systolic array design for matrix multiplication incorporates a robust feature combination for efficient computation. Employing counters with a control module enhances the precision and control over the matrix multiplication process. The integration of AXI Handshaking and Memory Banking for CPU-SRAM communication ensures a streamlined data flow. Furthermore, it is synthesized for an ASIC implementation and tested on a Xilinx PYNQ Board.
Notably, six modules define the operation of this systolic array
1) pe. v : 
- Basic Unit of the systolic array. Multiply and Accumulate Module.
- We have two input streams coming in and we calculate their sum of products.
- pe_simulation_MN.png highlights a single instance of pe module.

2) counter.v:
- It is a cascaded counter used to pick up addresses for both A and B separately.
- pixel_counter_A [row] and slice_counter_A [column]
- pixel_counter_B [column] and slice_counter_B [row]
- counter_simulation_MN.png highlights how the counter works for a small case...

3) control.v:
- This is a module that uses counter modules and calculates the required element address for A and B arrays.

4) systolic.sv:
- The systolic module is the main module that streams in inputs from the s2mm module, Multiplies, and Accumulate, and then serially extracts the calculated output.
- Systolic_simulation84.png highlights how values are calculated for M=8 and N=4.
- Systolic_simulation88.png highlights how values are calculated for M=8 and N=8.
  
5) s2mm.sv: 
- This module collects the values for A and B that are streamed using AXI Protocol from the CPU. 

6) mm2s.sv:
- This module returns the value from the systolic to the CPU via the AXI Protocol.

![systolic](https://github.com/Ashwin4514/Systolic_Array_Design/assets/64789016/a6cf2d6e-1662-491a-8cc9-555e405d5611)
