# Design and Verification of CAM(TCAM) with SystemVerilog

## Introduction of CAM
Current digital memory system designs require very fast lookups among large amounts of data. CAM(Content Addressable Memory) is introduced to solve this problem. 

Unlike SRAM accepting address to return data, CAMs search data and return matching address. A search operation of CAM is much faster than traditionl operation due to its parallel structure.

## Binary CAM and Ternary CAM
BCAM provides search pattern which only contains 1 and 0. 

On the other side, the search pattern of TCAM is able to contain 1, 0 and X(ingore).

## About this project
Project Status: Initial stage.

Goals
1. Parameterized SystemVerilog TCAM design
2. At first stage, the search logic will not be pipelined
3. Test with SV or UVM Verification envirorment
