module e2prom_rw (
    input wire     clk        ,
    input wire     rstn      ,
    input wire     key1_res,
    input wire     key2_res,
    input wire     start_done,
    input wire     key_done,
    output  reg        i2c_start_flag   ,
    output  reg         i2c_rd_flag  ,
    output  reg         i2c_wr_flag,
    output  reg  [15:0]  i2c_addr,
    output  reg  [ 7:0]  i2c_data_wr
  );
  //按键消抖模块
  wire key1_flag;
  wire key2_flag;
  key_filter # (
               .CNT_MAX(20'd999_999)
             )
             key_filter_inst1 (
               .sys_clk(clk),
               .sys_rst_n(rstn),
               .key_in(key1_res),
               .key_flag(key1_flag)
             );
  key_filter # (
               .CNT_MAX(20'd999_999)
             )
             key_filter_inst2 (
               .sys_clk(clk),
               .sys_rst_n(rstn),
               .key_in(key2_res),
               .key_flag(key2_flag)
             );
  //1M时钟模块//////////////////////////
  reg    [ 4:0]  clk_cnt   ; //分频时钟计数
  reg             clk_1mhz; //1M时钟

  always @(posedge clk or negedge rstn)
    if(!rstn)
      clk_1mhz <= 1'd0;
    else
      if(clk_cnt == 24)
        clk_1mhz <= ~clk_1mhz;
      else
        clk_1mhz <= clk_1mhz;
  always @(posedge clk or negedge rstn)
    if(!rstn)
      clk_cnt <= 5'd0;
    else
      if(clk_cnt == 5'd24)
        clk_cnt <= 5'd0;
      else
        clk_cnt <= clk_cnt+1'b1;
  ////参数变量////////////////////////////
  reg [6:0]cnt_num;
  reg [24:0]cnt_500ms;
  reg [19:0]cnt_10ms;
  parameter CNT_NUM_MAX=7'd100;  //读写数据个数
  parameter IIC_ADDR_START=7'd77;//地址开始端
  parameter IIC_WR_START=7'd55;//写数据开始端
  //10ms计数器///////////////////////////
  parameter CNT_10_MAX=20'd499_999;
  always @(posedge clk or negedge rstn)
    if(!rstn)
      cnt_10ms<=20'd0;
    else if(key1_flag||key2_flag)
      cnt_10ms<=20'd0;
    else if(cnt_10ms==CNT_10_MAX)
      cnt_10ms<=20'd0;
    else if(i2c_wr_flag)
      cnt_10ms<=cnt_10ms+1;
    else
      cnt_10ms<=cnt_10ms;
  //0.5s计数器
  parameter CNT_500_MAX=25'd24999_999;
  always @(posedge clk or negedge rstn)
    if(!rstn)
      cnt_500ms<=25'd0;
    else if(key1_flag||key2_flag)
      cnt_500ms<=25'd0;
    else if(cnt_10ms==CNT_500_MAX)
      cnt_500ms<=25'd0;
    else if(i2c_rd_flag)
      cnt_500ms<=cnt_500ms+1;
    else
      cnt_500ms<=cnt_500ms;
  //读写个数////////////////////////////////
  always @(posedge clk_1mhz or negedge rstn)
    if(!rstn)
      cnt_num<=7'b0;
    else if(cnt_num==CNT_NUM_MAX)
      cnt_num<=7'b0;
    else if(key_done)
      cnt_num<=cnt_num+1;
    else
      cnt_num<=cnt_num;
  always @(posedge clk_1mhz or negedge rstn)
    if(!rstn)
      i2c_addr<=IIC_ADDR_START;
    else if(cnt_num==CNT_NUM_MAX)
      i2c_addr<=IIC_ADDR_START;
    else if(key_done)
      i2c_addr<=i2c_addr+1;
    else
      i2c_addr<=i2c_addr;
  //写数据///////////////////////////////////
  always @(posedge clk_1mhz or negedge rstn)
    if(!rstn)
      i2c_data_wr<=IIC_WR_START;
    else if(cnt_num==CNT_NUM_MAX)
      i2c_data_wr<=IIC_WR_START;
    else if(key_done)
      i2c_data_wr<=i2c_data_wr+1;
    else
      i2c_data_wr<=i2c_data_wr;
  //开始标志位///////////////////////////////
  always @(posedge clk or negedge rstn)
    if(!rstn)
      i2c_start_flag<=1'b0;
    else if(key_done)
      i2c_start_flag<=1'b0;
    else if(cnt_10ms==CNT_10_MAX||cnt_500ms==CNT_500_MAX)
      i2c_start_flag<=1'b1;
    else if(key1_flag||key2_flag)
      i2c_start_flag<=1'b1;
    else if(cnt_num==CNT_NUM_MAX)
      i2c_start_flag<=1'b0;
    else
      i2c_start_flag<=i2c_start_flag;
  //写标志///////////////////////////////
  always @(posedge clk or negedge rstn)
    if(!rstn)
      i2c_wr_flag<=1'b0;
    else if(key1_flag)
      i2c_wr_flag<=1'b1;
    else if(cnt_num==CNT_NUM_MAX)
      i2c_wr_flag<=1'b0;
    else
      i2c_wr_flag<=i2c_wr_flag;
  //读标志///////////////////////////////
  always @(posedge clk or negedge rstn)
    if(!rstn)
      i2c_rd_flag<=1'b0;
    else if(key2_flag)
      i2c_rd_flag<=1'b1;
    else if(cnt_num==CNT_NUM_MAX)
      i2c_rd_flag<=1'b0;
    else
      i2c_rd_flag<=i2c_rd_flag;
endmodule
