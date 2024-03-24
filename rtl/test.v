module data_compare (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [7:0] po_data,
    input wire po_flag,
    output reg [19:0]data
  );
  parameter data1 ="$GNRMC";//正确数据开头
  parameter data2 ="*";
  parameter data3 ="$";
  reg[47:0] data_reg;//进入存储数据
  reg[47:0] data_reg1;//时间信息存储数据
  reg [7:0]data_jy;//异或校验十六进制结果
  reg[15:0] data_jysj;//GPS校验数据存储ASKII码
  reg [3:0] data_jysj1;//高位ASKII码转换为十六进制
  reg [3:0] data_jysj2;//低位ASKII码转换为十六进制
  wire [7:0] data_jysj3;//ASKII码转换为8位十六进制
  reg flag1; //时间采集标志位
  reg flag2; //异或校验开始结束标志位
  reg flag3; //异或校验正确标志位
  reg flag4; //校验正确标志位
  reg [2:0] cnt_7;//存储时间计数器
  reg [1:0] cnt_2;//GPS存储校验ASKII码计数器
  //进入数据移位储存
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      data_reg <= 48'd0;
    else if (po_flag)
      data_reg<={data_reg[39:0],po_data};
    else
      data_reg<=data_reg;
  //开头正确存储时间标志位
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      flag1 <= 1'd0;
    else if(cnt_7==3'd7)
      flag1 <= 1'd0;
    else if (data_reg==data1)
      flag1 <= 1'd1;
    else
      flag1 <= flag1;
  //存储时间计数器
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      cnt_7 <= 3'd0;
    else if (cnt_7==3'd7)
      cnt_7 <= 3'd0;
    else if (flag1&&po_flag)
      cnt_7 <= cnt_7+1;
    else
      cnt_7 <= cnt_7;
  //data_reg1 时间数据存储寄存器
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      data_reg1 <= 48'd0;
    else if (cnt_7==3'd7)
      data_reg1<=data_reg;
    else
      data_reg1<=data_reg1;
  //异或校验开始结束标志位
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      flag2 <= 1'd0;
    else if (po_data==data3&&po_flag)
      flag2 <= 1'd1;
    else if (po_data==data2&&po_flag)
      flag2 <= 1'd0;
    else
      flag2 <= flag2;
  //异或校验正确标志位
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      flag3 <= 1'd0;
    else if(po_data==data3)
      flag3 <= 1'd0;
    else if (data_jy==data_jysj3)
      flag3 <= 1'd1;
    else
      flag3 <= 1'd0;
  //异或校验十六进制结果
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      data_jy <= 8'd0;
    else if(po_data==data3)
      data_jy <= 8'd0;
    else if (po_data==data2)
      data_jy <= data_jy;
    else if (flag2&&po_flag)
      data_jy <= data_jy^po_data;
    else
      data_jy <= data_jy;
  //GPS存储校验ASKII码计数器
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      cnt_2 <= 2'd3;
    else if (po_data==data2&&po_flag)
      cnt_2 <= 3'd0;
    else if (cnt_2==2)
      cnt_2 <= cnt_2;
    else if (po_flag)
      cnt_2 <= cnt_2+1;
    else
      cnt_2 <= cnt_2;
  //GPS校验数据存储ASKII码
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      data_jysj <= 16'd0;
    else if (po_flag&&cnt_2<=1)
      data_jysj<={data_jysj[7:0],po_data};
    else
      data_jysj<=data_jysj;
  //ASKII码转换为十六进制
  always@(*)
  begin
    if (!sys_rst_n)
      data_jysj1 = 16'd0;
    else
    begin
      case(data_jysj[15:8])
        8'd48 :
          data_jysj1 = 4'h0;
        8'd49 :
          data_jysj1 = 4'h1;
        8'd50 :
          data_jysj1 = 4'h2;
        8'd51 :
          data_jysj1 = 4'h3;
        8'd52 :
          data_jysj1 = 4'h4;
        8'd53 :
          data_jysj1 = 4'h5;
        8'd54 :
          data_jysj1 = 4'h6;
        8'd55 :
          data_jysj1 = 4'h7;
        8'd56 :
          data_jysj1 = 4'h8;
        8'd57 :
          data_jysj1 = 4'h9;
        8'd65 :
          data_jysj1 = 4'hA;
        8'd66 :
          data_jysj1 = 4'hB;
        8'd67 :
          data_jysj1 = 4'hC;
        8'd68 :
          data_jysj1 = 4'hD;
        8'd69 :
          data_jysj1 = 4'hE;
        8'd70 :
          data_jysj1 = 4'hF;
        default :
          data_jysj1 =data_jysj1;
      endcase
    end
  end
  always@(*)
  begin
    if (!sys_rst_n)
      data_jysj2 = 16'd0;
    else
    begin
      case(data_jysj[7:0])
        8'd48 :
          data_jysj2 = 4'h0;
        8'd49 :
          data_jysj2 = 4'h1;
        8'd50 :
          data_jysj2 = 4'h2;
        8'd51 :
          data_jysj2 = 4'h3;
        8'd52 :
          data_jysj2 = 4'h4;
        8'd53 :
          data_jysj2 = 4'h5;
        8'd54 :
          data_jysj2 = 4'h6;
        8'd55 :
          data_jysj2 = 4'h7;
        8'd56 :
          data_jysj2 = 4'h8;
        8'd57 :
          data_jysj2 = 4'h9;
        8'd65 :
          data_jysj2 = 4'hA;
        8'd66 :
          data_jysj2 = 4'hB;
        8'd67 :
          data_jysj2 = 4'hC;
        8'd68 :
          data_jysj2 = 4'hD;
        8'd69 :
          data_jysj2 = 4'hE;
        8'd70 :
          data_jysj2 = 4'hF;
        default :
          data_jysj2 =data_jysj2;
      endcase
    end
  end
  assign data_jysj3={data_jysj1,data_jysj2};
  //校验正确标志位
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      flag4<= 1'd0;
    else if (po_data==data3)
      flag4<= 1'd0;
    else if (data_reg==data1)
      flag4<= 1'd1;
    else
      flag4<= flag4;
  //时间数据输出 每位 ASKII码转换为十进制
  reg [7:0] shi_shiwei;
  reg [7:0] shi_gewei;
  reg [7:0] fen_shiwei;
  reg [7:0] fen_gewei;
  reg [7:0] miao_shiwei;
  reg [7:0] miao_gewei;
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
    begin
      shi_shiwei<=8'd0;
      shi_gewei<=8'd0;
      fen_shiwei<=8'd0;
      fen_gewei<=8'd0;
      miao_shiwei<=8'd0;
      miao_gewei<=8'd0;
    end
    else if(flag3&&flag4)
    begin
      shi_shiwei = data_reg1[47:40]-48;
      shi_gewei = data_reg1[39:32]-48;
      fen_shiwei = data_reg1[31:24]-48;
      fen_gewei = data_reg1[23:16]-48;
      miao_shiwei = data_reg1[15:8]-48;
      miao_gewei = data_reg1[7:0]-48;
    end
    else
    begin
      shi_shiwei<=shi_shiwei;
      shi_gewei<=shi_gewei;
      fen_shiwei<=fen_shiwei;
      fen_gewei<=fen_gewei;
      miao_shiwei<=miao_shiwei;
      miao_gewei<=miao_gewei;
    end
  //时间数据输出
  always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
      data <= 20'd0;
    else if (shi_shiwei>=1&&shi_gewei>=6)
      data <=(shi_shiwei*100000+(shi_gewei+8)*10000+fen_shiwei*1000+fen_gewei*100+miao_shiwei*10+miao_gewei*1)-20'd240000;
    else if(shi_gewei<16)
      data <=shi_shiwei*100000+(shi_gewei+8)*10000+fen_shiwei*1000+fen_gewei*100+miao_shiwei*10+miao_gewei*1;
    else
      data<=data;
endmodule
