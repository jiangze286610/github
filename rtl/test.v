module data_tx (
    input  wire sys_clk,
    input  wire sys_rst_n,
    output  wire [7:0] pi_data,
    output reg pi_flag
  );
  reg	[3:0]cnt_num;
  reg	[25:0]	cnt_1ms;
  reg	[25:0]	cnt_mayuan;

  wire	[7:0]	data_reg[0:7];
  assign data_reg[0]=8'h11;
  assign data_reg[1]=8'h22;
  assign data_reg[2]=8'h33;
  assign data_reg[3]=8'h44;
  assign data_reg[4]=8'h55;
  assign data_reg[5]=8'h66;
  assign data_reg[6]=8'h77;
  assign data_reg[7]=8'h88;

  /* always@(*)
          if(sys_rst_n == 1'b0)
              pi_data <=8'd0;
  			else
  			pi_data<=data_reg[cnt_num-1'b1]; */

  assign	pi_data=data_reg[cnt_num-1'b1];
  always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
      cnt_1ms <= 26'b0;
    else	if(cnt_1ms==26'd49_999_999)
      cnt_1ms <= 26'd0;
  else
    cnt_1ms <= cnt_1ms+1'b1;

  always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
      cnt_mayuan <= 26'b0;
    else	if(cnt_num==4'd8)
      cnt_mayuan <= 26'd0;
  else	if(cnt_mayuan==26'd52080)
    cnt_mayuan <= 26'd0;
  else
    cnt_mayuan <= cnt_mayuan+1'b1;
  always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
      pi_flag <= 1'b0;
    else if(cnt_num==4'd8)
    begin
      if(cnt_1ms==26'd49_999_999)
        pi_flag<=1'b1;
      else
        pi_flag<=1'b0;
    end
    else	if(cnt_mayuan==26'd52080)
      pi_flag <= 1'b1;
  else
    pi_flag <= 1'b0;
  always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
      cnt_num <= 4'd0;
    else	if(cnt_num==8&&pi_flag==1)
      cnt_num <= 4'd1;
  else	if(pi_flag==1)
    cnt_num <= cnt_num+1'b1;
  else
    cnt_num <= cnt_num;
endmodule
