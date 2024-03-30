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
    output  wire  [15:0]  i2c_addr,
    output  wire  [ 7:0]  i2c_data_wr
  );
  wire key1_flag;
  wire key2_flag;
  assign i2c_addr=16'd1;
  assign i2c_data_wr=8'd123;
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
  always @(posedge clk or negedge rstn)
    if(!rstn)
      i2c_start_flag<=1'b0;
    else if(key1_flag||key2_flag)
      i2c_start_flag<=1'b1;
    else if(start_done)
      i2c_start_flag<=1'b0;
    else
      i2c_start_flag<=i2c_start_flag;

  always @(posedge clk or negedge rstn)
    if(!rstn)
      i2c_wr_flag<=1'b0;
    else if(key1_flag)
      i2c_wr_flag<=1'b1;
    else if(key_done)
      i2c_wr_flag<=1'b0;
    else
      i2c_wr_flag<=i2c_wr_flag;

  always @(posedge clk or negedge rstn)
    if(!rstn)
      i2c_rd_flag<=1'b0;
    else if(key2_flag)
      i2c_rd_flag<=1'b1;
    else if(key_done)
      i2c_rd_flag<=1'b0;
    else
      i2c_rd_flag<=i2c_rd_flag;

endmodule
