// +FHDR----------------------------------------------------------------------------
// Project Name  : CAM
// Author        : flyskywalker
// Email         : flyskywalker92@gmail.com
// Website       : https://github.com/flyskywalker
// Created On    : 2022/11/26 20:32
// Last Modified : 2022/12/11 23:33
// File Name     : std.sv
// Description   :
//         
// Copyright (c) 2022 LOL Co.,Ltd..
// ALL RIGHTS RESERVED
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/11/26   flyskywalker    1.0                     Original
// -FHDR----------------------------------------------------------------------------
module DFF#(
    parameter DW=1
    )(
    input logic [DW-1:0]    D,
    input logic             clk,
    output logic[DW-1:0]    Q
);

always_ff@(posedge clk)
        Q <= D;
endmodule

module DFF_A#(
    parameter DW=1
    )(
    input logic [DW-1:0]    D,
    input logic             clk,
    input logic             rst_n,
    output logic[DW-1:0]    Q
);

always_ff@(posedge clk)
    if(!rst_n) 
        Q <= '0;
    else
        Q <= D;
endmodule

module DFF_AR#(
    parameter DW=1
    )(
    input logic [DW-1:0]    D,
    input logic             clk,
    input logic             rst_n,
    output logic[DW-1:0]    Q
);

always_ff@(posedge clk or negedge rst_n)
    if(!rst_n) 
        Q <= '0;
    else
        Q <= D;
endmodule
