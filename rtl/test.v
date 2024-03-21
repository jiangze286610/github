`timescale  1ns/1ns
module  hc595_ctrl
  (
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    input   wire    [5:0]   sel         ,   //数码管位选信号
    input   wire    [7:0]   seg         ,   //数码管段选信号

    output  reg             stcp        ,   //数据存储器时钟
    output  reg             shcp        ,   //移位寄存器时钟
    output  reg             ds          ,   //串行数据输入
    output  wire            oe              //使能信号，低有效
  );

  wire [13:0]   hc595_data;
  //连续赋值
  assign oe=~sys_rst_n;
  assign hc595_data = {seg[0],seg[1],seg[2],seg[3],seg[4],seg[5],seg[6],seg[7],sel};
  //4计数器
  reg [1:0]   cnt_4;
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (~sys_rst_n)
      cnt_4 <= 2'b00;
    else if(cnt_4 == 2'b11)
      cnt_4 <= 2'b00;
    else
      cnt_4 <= cnt_4 + 1;
  end
  //4分频信号 shcp
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (~sys_rst_n)
      shcp <= 1'b0;
    else if(cnt_4==2'b11||cnt_4==2'b10)
      shcp <= 1'b1;
    else
      shcp <= 1'b0;
  end
  reg [3:0]   cnt_data;
  //stcp信号
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (~sys_rst_n)
      stcp <= 1'b0;
    else if(cnt_4==2'b11&&cnt_data==4'd13)
      stcp <= 1'b1;
    else
      stcp <= 1'b0;
  end
  //传输数据位数计数器
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (~sys_rst_n)
      cnt_data <= 4'b0000;
    else if(cnt_4==2'b11&&cnt_data==4'd13)
      cnt_data <= 4'b0000;
    else if(cnt_4==2'b11)
      cnt_data <= cnt_data + 1;
    else
      cnt_data <= cnt_data;
  end
  //ds信号
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (~sys_rst_n)
      ds <= 1'b0;
    else if(cnt_4==2'b00)
      ds <= hc595_data[cnt_data];
    else
      ds <= ds;
  end

endmodule

