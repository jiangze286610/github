`timescale  1ns/1ns

module  top_seg_595
  (
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效
    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //输出使能信号
  );
  wire [3:0]   unit        ;  //个位BCD码
  wire [3:0]   ten         ;  //十位BCD码
  wire [3:0]   hun         ;  //百位BCD码
  wire [3:0]   tho         ;  //千位BCD码
  wire [3:0]   t_tho       ;  //万位BCD码
  wire [3:0]   h_hun       ;  //十万位BCD码
  //wire  define
  wire    [19:0]  data    ;   //数码管要显示的值
  wire    [5:0]   point   ;   //小数点显示,高电平有效top_seg_595
  wire            seg_en  ;   //数码管使能信号，高电平有效
  wire            sign    ;   //符号位，高电平显示负号
  wire    [5:0]   sel     ;   //数码管位选信号
  wire    [7:0]   seg     ;   //数码管段选信号

  //-------------data_gen_inst--------------
  data_tube    data_gen_inst
               (
                 .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
                 .sys_rst_n   (sys_rst_n),   //复位信号，低电平有效
                 .data        (data     ),   //数码管要显示的值
                 .point       (point    ),   //小数点显示,高电平有效
                 .seg_en      (seg_en   ),   //数码管使能信号，高电平有效
                 .sign        (sign     )    //符号位，高电平显示负号
               );
  bcd_8421  bcd_8421_inst
            (
              .sys_clk(sys_clk),
              .sys_rst_n(sys_rst_n),
              .data(data),
              .unit(unit),
              .ten(ten),
              .hun(hun),
              .tho(tho),
              .t_tho(t_tho),
              .h_hun(h_hun)
            );

  seg_dynamic  seg_dynamic_inst (
                 .sys_clk(sys_clk),
                 .sys_rst_n(sys_rst_n),
                 .data(data),
                 .point(point),
                 .seg_en(seg_en),
                 .sign(sign),
                 .sel(sel),
                 .seg(seg),
                 .unit(unit),
                 .ten(ten),
                 .hun(hun),
                 .tho(tho),
                 .t_tho(t_tho),
                 .h_hun(h_hun)
               );
  hc595_ctrl  hc595_ctrl_inst (
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .sel(sel),
                .seg(seg),
                .stcp(stcp),
                .shcp(shcp),
                .ds(ds),
                .oe(oe)
              );
endmodule
