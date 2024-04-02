module  data_gen
  #(
     parameter   CNT_MAX = 23'd4999_999, //100ms计数值
     parameter   DATA_MAX= 20'd999_999   //显示的最大值
   )
   (
     input   wire            sys_clk     ,   //系统时钟，频率50MHz
     input   wire            sys_rst_n   ,   //复位信号，低电平有效
     input  wire      [15:0]      data_in     ,   //输入数据
     output  wire     [19:0]  data        ,   //数码管要显示的值
     output  wire    [5:0]   point       ,   //小数点显示,高电平有效
     output  reg             seg_en      ,   //数码管使能信号，高电平有效
     output  wire            sign            //符号位，高电平显示负号
   );
  wire [19:0]  data1;
  assign data1=(2**15)*data_in[15]+(2**14)*data_in[14]+(2**13)*data_in[13]+(2**12)*data_in[12]+(2**11)*data_in[11]+(2**10)*data_in[10]+(2**9)*data_in[9]+(2**8)*data_in[8]+(2**7)*data_in[7]+(2**6)*data_in[6]+(2**5)*data_in[5]+(2**4)*data_in[4]+(2**3)*data_in[3]+(2**2)*data_in[2]+(2**1)*data_in[1]+(2**0)*data_in[0];
  assign data=data1*10/12;
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
