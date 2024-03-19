module beep_uart (
    input wire sys_clk, // 时钟信号
    input wire sys_rst_n, // 低电平复位信号
    input wire beep_flag, // 蜂鸣器控制信号
    output reg beep // 蜂鸣器信号
  );
  //help
  reg[15:0] cnt_code;
  parameter CNT_CODE_MAX = 16'd16666 ;
  reg[2:0] cnt_num;
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      cnt_code <= 16'd0;
    else if(cnt_code==CNT_CODE_MAX)
      cnt_code <= 16'd0;
    else
      cnt_code <= cnt_code + 1'b1;

  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      beep <= 1'd0;
    else if(cnt_code<=CNT_CODE_MAX/8&&cnt_num<=1&&beep_flag)
      beep <= 1'd1;
    else
      beep <= 1'd0;

  reg[25:0] cnt_1s;
  parameter CNT_MAX_1S = 26'd49_999_999 ;

  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      cnt_1s <= 26'd0;
    else if(cnt_1s==CNT_MAX_1S)
      cnt_1s <= 26'd0;
    else
      cnt_1s <= cnt_1s + 1'b1;



  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      cnt_num <= 3'd0;
    else if(cnt_num==2)
      cnt_num <= cnt_num;
    else if(cnt_1s==CNT_MAX_1S)
      cnt_num <= cnt_num + 1'b1;
    else
      cnt_num <= cnt_num;

endmodule
