module data_tube (
    input wire sys_clk,
    input wire sys_rst_n,
    output reg [19:0]data,
    output wire [5:0]point,
    output wire sign,
    output wire seg_en
  );
  assign  point   =   6'b000_010;
  assign  sign    =   1'b0;
  assign  seg_en    =   1'b1;
  //50Mhz clk 生成100ms计数器
  reg [22:0] cnt_100ms;
  parameter cnt_100ms_max =4_999_99;
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if(~sys_rst_n)
      cnt_100ms <= 23'd0;
    else if(cnt_100ms==cnt_100ms_max)
      cnt_100ms <= 23'd0;
    else
      cnt_100ms <= cnt_100ms + 1;
  end
  //100ms计数器计满标志位
  reg cnt_flag;
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if(~sys_rst_n)
      cnt_flag <= 0;
    else if(cnt_100ms==cnt_100ms_max)
      cnt_flag <= 1;
    else
      cnt_flag <= 0;
  end
  //标志位拉高计数器加1 0~999_999;

  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if(~sys_rst_n)
      data <= 20'd0;
    else if(data==20'd999_999)
      data <= 20'd0;
    else if(cnt_flag)
      data <= data+1;
    else
      data <= data;
  end
endmodule
