`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/07/10
// Module Name   : data_gen
// Project Name  : top_seg_595
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 生成数码管显示数据
//
// Revision      : V1.0
// Additional Comments:
//
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  data_gen
  #(
     parameter   CNT_MAX = 23'd4999_999, //100ms计数值
     parameter   DATA_MAX= 20'd999_999   //显示的最大值
   )
   (
     input   wire            sys_clk     ,   //系统时钟，频率50MHz
     input   wire            sys_rst_n   ,   //复位信号，低电平有效
     input  wire      [7:0]      data_in     ,   //输入数据
     output  wire     [19:0]  data        ,   //数码管要显示的值
     output  wire    [5:0]   point       ,   //小数点显示,高电平有效
     output  reg             seg_en      ,   //数码管使能信号，高电平有效
     output  wire            sign            //符号位，高电平显示负号
   );

  //********************************************************************//
  //****************** Parameter and Internal Signal *******************//
  //********************************************************************//

  assign data={12'd0,data_in};
  //不显示小数点以及负数
  assign  point   =   6'b000_000;
  assign  sign    =   1'b0;

  //数码管使能信号给高即可
  always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
      seg_en  <=  1'b0;
    else
      seg_en  <=  1'b1;

endmodule
