
module  seg_static
  (
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效
    output  reg     [5:0]   sel         ,   //数码管位选信号
    output  reg     [7:0]   seg             //数码管段选信号
  );
  //十六进制数显示编码
  parameter   SEG_0 = 8'b1100_0000,   SEG_1 = 8'b1111_1001,
              SEG_2 = 8'b1010_0100,   SEG_3 = 8'b1011_0000,
              SEG_4 = 8'b1001_1001,   SEG_5 = 8'b1001_0010,
              SEG_6 = 8'b1000_0010,   SEG_7 = 8'b1111_1000,
              SEG_8 = 8'b1000_0000,   SEG_9 = 8'b1001_0000,
              SEG_A = 8'b1000_1000,   SEG_B = 8'b1000_0011,
              SEG_C = 8'b1100_0110,   SEG_D = 8'b1010_0001,
              SEG_E = 8'b1000_0110,   SEG_F = 8'b1000_1110;
  parameter   IDLE  = 8'b1111_1111;   //不显示状态9
  //1s 计数器
  parameter  cnt_1s_max=49'd49999_999;
  reg [25:0]  cnt_1s;
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (!sys_rst_n)
      cnt_1s <= 26'b0;
    else
      cnt_1s <= cnt_1s + 1;
  end
  //数码管位选信号
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (!sys_rst_n)
      sel <= 6'b000000;
    else
      sel <= 6'b111111;
  end
  //1s计数标志位
  reg         flag_1s;
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (!sys_rst_n)
      flag_1s <= 1'b0;
    else if(cnt_1s == cnt_1s_max)
      flag_1s <=1'b1;
    else
      flag_1s <=flag_1s;
  end
  //0~F显示技术
  reg [3:0]   cnt_num;
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (!sys_rst_n)
      cnt_num <= 4'b0000;
    else if(flag_1s)
      cnt_num <= cnt_num + 1;
    else
      cnt_num <= cnt_num;
  end
  //数码管段选信号
  always @(posedge sys_clk or negedge sys_rst_n)
  begin
    if (~sys_rst_n)
    begin
      seg<=8'b1111_1111;
    end
    else
    begin
      case(cnt_num)
        4'd0:
          seg<=SEG_0;
        4'd1:
          seg<=SEG_1;
        4'd2:
          seg<=SEG_2;
        4'd3:
          seg<=SEG_3;
        4'd4:
          seg<=SEG_4;
        4'd5:
          seg<=SEG_5;
        4'd6:
          seg<=SEG_6;
        4'd7:
          seg<=SEG_7;
        4'd8:
          seg<=SEG_8;
        4'd9:
          seg<=SEG_9;
        4'd10:
          seg<=SEG_A;
        4'd11:
          seg<=SEG_B;
        4'd12:
          seg<=SEG_C;
        4'd13:
          seg<=SEG_D;
        4'd14:
          seg<=SEG_E;
        4'd15:
          seg<=SEG_F;
        default:
          seg<=8'b1111_1111;
      endcase
    end
  end
endmodule
