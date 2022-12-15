// +FHDR----------------------------------------------------------------------------
// Project Name  : CAM
// Author        : flyskywalker
// Email         : flyskywalker92@gmail.com
// Website       : https://github.com/flyskywalker
// Created On    : 2022/11/26 20:52
// Last Modified : 2022/12/15 22:35
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

    input logic [CAM_DW-1:0] data_in,           //input data
    input logic              input_valid,       //input data_valid
    input logic [CAM_AW-1:0] addr_in,           //input addr

    input logic [CAM_MW-1:0] mask_in,           //input mask
    input logic [CAM_MW-1:0] mask_strb,         //input mask strobe
    input logic              mask_en,           //input mask matching function enable

    output logic[CAM_DW-1:0] data_out,          //output matched/hit data
    output logic[CAM_AW-1:0] addr_out,          //output hit addr
    input  logic             data_valid,        //output data is accept by master
    output logic             hit                //any hit?
);
    localparam DEPTH = 1<<CAM_AW;               //DEPTH is the number of maximal addr/line
    logic [CAM_DW-1:0] mem [DEPTH];             //memory seq part
    logic [CAM_DW-1:0] mem_comb [DEPTH];        //memory comb part
    logic [CAM_MW-1:0] mem_strb [DEPTH];        //strobed memory data
    logic [DEPTH-1:0]  line_hit;                //is data stored in this mem line is matched/hit with mask?
    logic [DEPTH-1:0]  first_hit;               //which line is the first hit line (onehot coded)
    logic [DEPTH-1:0]  clr;                     //clr which line's data
    logic [DEPTH-1:0]  line_occupied;           //does this line contains valid data? seq part
    logic [DEPTH-1:0]  line_occupied_comb;      //like above, comb part
    genvar i;

    generate
        for(i=0;i<DEPTH;i=i+1) begin            //the maximal number of memory line is DEPTH
        //seq part for line occupied
            DFF_AR #(.DW(1))
                i_line_occupied(
                .D(line_occupied_comb[i]),
                .clk(clk),
                .rst_n(rst_n),                  //in order to reduce power consumption (decrease data path toggle), only flag bit shall be reset/clear
                .Q(line_occupied[i]));
        //comb part for line occupied
            always_comb begin
                line_occupied_comb[i] = line_occupied[i];
                if((i == addr_in) && input_valid)   //when line addr == input addr & input data is valid, flag bit is asserted
                    line_occupied_comb[i] = 1'b1;
                if(clr[i])                          //only clear flag bit
                    line_occupied_comb[i] = 1'b0;
            end

        //seq part for mem access               // no reset/initialization for mem
            DFF #(.DW(CAM_DW))
                i_MEM(
                .D(mem_comb[i]),
                .clk(clk),
                .Q(mem[i]));
        //comb part for mem access
            always_comb begin
                mem_comb[i] = mem[i];
                if((i == addr_in) && input_valid)   //when line addr == input addr & input data is valid, input data will be stored in this line
                    mem_comb[i] = data_in;
            end
        
        //comb part for mem clr
            assign clr[i] = first_hit[i] & data_valid;  //when current line is the first hit line & stored data is captured by master, clear this line
       
        //comb line hit detector
            always_comb begin
                mem_strb[i] = '0;
                line_hit[i] = '0;
                mem_strb[i] = mem[i][CAM_DW-1 -: CAM_MW] & mask_strb;       //use storbe bit to collect excepted matching bit of line data
                if(line_occupied[i] && (mem_strb[i] == mask_in) && mask_en) //when flag bit is set(line data is valid) & storbed data == mask & mask function enable, this line is hit!
                    line_hit[i] = 1'b1;
            end
        end
    endgenerate

    assign first_hit = line_hit & (~(line_hit-1));  //find the first hit line (fix priority arbiter, onehot)
    assign hit = | line_hit;                        //any hit?
    
    // output logic
    always_comb begin
        for(int j=0;j<DEPTH;j++) begin
            if(first_hit[j]) begin              //only first hit line's data/addr could be captured by master
                data_out = mem[j];
                addr_out = j;
            end
        end
    end
endmodule
