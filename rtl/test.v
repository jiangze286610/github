
module  seg_top
  (
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低有效
    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //输出使能信号
  );

  wire    [5:0]   sel;
  wire    [7:0]   seg;

  seg_static  seg_static
              (
                .sys_clk     (sys_clk   ),   //系统时钟，频率50MHz
                .sys_rst_n   (sys_rst_n ),   //复位信号，低电平有效

                .sel         (sel       ),   //数码管位选信号
                .seg         (seg       )    //数码管段选信号
              );

  hc595_ctrl  hc595_ctrl
              (
                .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
                .sys_rst_n   (sys_rst_n),   //复位信号，低有效
                .sel         (sel      ),   //数码管位选信号
                .seg         (seg      ),   //数码管段选信号

                .stcp        (stcp     ),   //输出数据存储寄时钟
                .shcp        (shcp     ),   //移位寄存器的时钟输入
                .ds          (ds       ),   //串行数据输入
                .oe          (oe       )    //输出使能信号
              );

endmodule
