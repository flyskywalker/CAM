// +FHDR----------------------------------------------------------------------------
// Project Name  : CAM
// Author        : flyskywalker
// Email         : flyskywalker92@gmail.com
// Website       : https://github.com/flyskywalker
// Created On    : 2022/12/12 21:50
// Last Modified : 2022/12/16 00:17
// File Name     : CAM_tb.sv
// Description   :
//         
// Copyright (c) 2022 LOL Co.,Ltd..
// ALL RIGHTS RESERVED
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/12/12   flyskywalker    1.0                     Original
// -FHDR----------------------------------------------------------------------------
module CAM_tb(); 
parameter CAM_DW = 32;
parameter CAM_MW = 3;
parameter CAM_AW = 8;

localparam QUENE_LEN = 1<<CAM_AW;
typedef int unsigned uint;
logic [CAM_DW-1:0] data_in;
logic              input_valid;
logic [CAM_AW-1:0] addr_in;
logic [CAM_AW-1:0] addr_out;
logic [CAM_MW-1:0] mask_in;
logic [CAM_MW-1:0] mask_strb;
logic [CAM_DW-1:0] data_out;
logic              data_ready;
logic              data_valid;
logic              hit;
logic              mask_en;

logic              clk,rst_n;
always #5 clk = ~clk;

CAM i_CAM(.*);

logic [CAM_DW-1:0] input_data_array[QUENE_LEN];
uint               input_data_quene[QUENE_LEN];
logic [CAM_DW-1:0] reorder_data_array[QUENE_LEN];
logic [CAM_AW-1:0] input_addr_array[QUENE_LEN];
logic [CAM_AW-1:0] reorder_addr_array[QUENE_LEN];


initial begin
    for(int i=0;i<QUENE_LEN;i++) begin
        input_data_array[i] = (i>(QUENE_LEN/2))?{3'b010,29'b0}:
                                     (i>(QUENE_LEN/3))?{3'b101,29'ha}:
                                     (i>(QUENE_LEN/4))?{3'b001,29'h5}:
                                     {3'b100,29'h7};
        input_addr_array[i] = i; 
        input_data_quene[i] = input_data_array[i];
    end
    input_data_quene.sort();
    clk = 0;
    rst_n = 1;
    #7 rst_n = 0;
    data_in = '0;
    input_valid = '0;
    addr_in = '0;
    mask_in = '0;
    mask_strb = '0;
    data_valid = '0;
    mask_en = '0;
    #10;
    @(posedge clk);
        rst_n = 1;
end

task write_data (logic [CAM_DW-1:0] data, logic [CAM_AW-1:0] addr);
    @(posedge clk);
        addr_in = addr;
        data_in = data;
        input_valid = 1'b1;
    $display("Time:%t, Write data = 0x%0h, Write addr = 0x%0h",$time,data,addr);
endtask

task write_mask (logic [CAM_MW-1:0] mask, logic [CAM_MW-1:0] strb);
    @(posedge clk);
        mask_in = mask;
        mask_strb = strb;
        mask_en = 1;
    $display("Time:%t, Data Mask = 0x%0h, Mask strobe = 0x%0h",$time,mask,strb);
endtask

task read_data (output logic [CAM_DW-1:0] data, output logic [CAM_AW-1:0] addr, output logic no_hit);
    for (int i=0;i<15;i++) begin
        @(posedge clk);
        data_valid = 1'b0;
        //no_hit = !hit;
        if(hit) begin
            data = data_out;
            addr = addr_out;
            data_valid = 1'b1;
            $display("Time:%t, Hit data = 0x%0h, Hit addr = 0x%0h",$time,data,addr);
            return;
            end
        else begin
            continue;
        end
    end
endtask

logic [CAM_DW-1:0] data;
logic [CAM_AW-1:0] addr;
logic              no_hit;
logic [CAM_MW-1:0] mask_init=0;
initial begin
    wait(rst_n == 0)
    wait(rst_n == 1)
    for(int i=0;i<QUENE_LEN;i++) begin
        write_data(input_data_array[i],input_addr_array[i]);
    end
    input_valid = 0;
end

initial begin
    @(negedge input_valid);
    for(int i=0;i<QUENE_LEN;i++) begin
        write_mask(mask_init,3'b111);
        read_data(reorder_data_array[i],reorder_addr_array[i],no_hit);
        @(posedge clk);
        if(!hit)begin
            mask_en=0;
            data_valid=0;
            if(mask_init < 3'b111) mask_init++;
            else $finish;
        end
    end
    data_valid = 1'b0;
    @(posedge clk);
    $finish;
end
endmodule
