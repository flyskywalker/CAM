// +FHDR----------------------------------------------------------------------------
// Project Name  : CAM
// Author        : flyskywalker
// Email         : flyskywalker92@gmail.com
// Website       : https://github.com/flyskywalker
// Created On    : 2022/11/26 20:52
// Last Modified : 2022/12/12 23:23
// File Name     : CAM.sv
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
//import CAM_PKG::*

module CAM #(
    parameter CAM_DW = 32,
    parameter CAM_MW = 3,
    parameter CAM_AW = 8
)(
    input logic clk,
    input logic rst_n,

    input logic [CAM_DW-1:0] data_in,
    input logic              input_valid,
    input logic [CAM_AW-1:0] addr_in,

    input logic [CAM_MW-1:0] mask_in,
    input logic [CAM_MW-1:0] mask_strb,

    output logic[CAM_DW-1:0] data_out,
    output logic[CAM_AW-1:0] addr_out,
    output logic             data_ready,
    input  logic             data_valid,
    output logic             hit
);
    localparam DEPTH = 1<<CAM_AW;
    logic [CAM_DW-1:0] mem [DEPTH];
    logic [CAM_DW-1:0] mem_comb [DEPTH];
    logic [CAM_MW-1:0] mem_strb [DEPTH];
    logic [DEPTH-1:0]  line_hit;
    logic [DEPTH-1:0]  first_hit;
    logic [DEPTH-1:0]  clr;
    logic [DEPTH-1:0]  line_occupied;
    logic [DEPTH-1:0]  line_occupied_comb;
    genvar i;

    generate
        for(i=0;i<DEPTH;i=i+1) begin
        //seq part for line occupied
            DFF_AR #(.DW(1))
                i_line_occupied(
                .D(line_occupied_comb[i]),
                .clk(clk),
                .rst_n(rst_n),
                .Q(line_occupied[i]));
        //comb part for line occupied
            always_comb begin
                line_occupied_comb[i] = line_occupied[i];
                if((i == addr_in) && input_valid)
                    line_occupied_comb[i] = 1'b1;
                if(clr[i])
                    line_occupied_comb[i] = 1'b0;
            end

        //seq part for mem access
            DFF #(.DW(CAM_DW))
                i_MEM(
                .D(mem_comb[i]),
                .clk(clk),
                .Q(mem[i]));
        //comb part for mem access
            always_comb begin
                mem_comb[i] = mem[i];
                if((i == addr_in) && input_valid)
                    mem_comb[i] = data_in;
            end
        
        //comb part for mem clr
            assign clr[i] = first_hit[i] & data_valid;
       
        //comb line hit detector
            always_comb begin
                mem_strb[i] = '0;
                line_hit[i] = '0;
                mem_strb[i] = mem[i][CAM_DW-1 -: CAM_MW] & mask_strb;
                if(line_occupied[i] && (mem_strb[i] == mask_in))
                    line_hit[i] = 1'b1;
            end
        end
    endgenerate

    assign first_hit = line_hit & (~(line_hit-1));
    assign hit = | line_hit;
    
    // output logic
    always_comb begin
        for(int j=0;j<DEPTH;j++) begin
            if(first_hit[j])
                data_out = mem[j];
                addr_out = j;
        end
    end
endmodule
