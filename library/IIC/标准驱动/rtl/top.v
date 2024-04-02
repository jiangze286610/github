module top (
    input  wire         clk        ,
    input  wire         rstn      ,
    input  wire        key1_res,
    input  wire        key2_res,
    inout                sda,
    output wire         scl,
    output wire         stcp,
    output wire         shcp,
    output wire         ds,
    output wire         oe
  );
  wire  i2c_start_flag;
  wire  i2c_rd_flag;
  wire  i2c_wr_flag;
  wire  [15:0]  i2c_addr;
  wire  [ 7:0]  i2c_data_wr;
  wire  start_done;
  wire  key_done;
  wire[7:0] i2c_data_rd;
  e2prom_rw  e2prom_rw_inst (
               .clk(clk),
               .rstn(rstn),
               .key1_res(key1_res),
               .key2_res(key2_res),
               .i2c_start_flag(i2c_start_flag),
               .i2c_rd_flag(i2c_rd_flag),
               .i2c_wr_flag(i2c_wr_flag),
               .i2c_addr(i2c_addr),
               .i2c_data_wr(i2c_data_wr),
               .start_done(start_done),
               . key_done(key_done)
             );

  e2prom_ctrl  e2prom_ctrl_inst (
                 .clk(clk),
                 .rstn(rstn),
                 .i2c_start_flag(i2c_start_flag),
                 .i2c_rd_flag(i2c_rd_flag),
                 .i2c_wr_flag(i2c_wr_flag),
                 .i2c_data_rd(i2c_data_rd),
                 .scl(scl),
                 .sda(sda),
                 .i2c_addr(i2c_addr),
                 .i2c_data_wr(i2c_data_wr),
                 .start_done(start_done),
                 . key_done(key_done)
               );
  top_seg_595  top_seg_595 (
                 .sys_clk(clk),
                 .sys_rst_n(rstn),
                 .data_in(i2c_data_rd),
                 .stcp(stcp),
                 .shcp(shcp),
                 .ds(ds),
                 .oe(oe)
               );

endmodule
