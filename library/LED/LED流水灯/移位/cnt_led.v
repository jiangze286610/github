module cnt_led(
    input	wire	clk,
    input	wire	rst_n,
    output	reg[3:0]	led
  );
  reg[25:0]	cnt_1s;
  parameter	cnt_1s_max;
  reg	flag;
  always@(posedge	clk	or	negedge	rst_n)

    if(rst_n==0)
      cnt_1s<=26'd0;
    else	if(cnt_1s==26'd24_999_999)
      cnt_1s<=26'd0;
  else
    cnt_1s<=cnt_1s+1'b1;
  always@(posedge	clk	or	negedge	rst_n)
    //26'd24_999_999
    if(rst_n==0)
      flag<=0;
    else	if(led==4'b0111)
      flag<=1;
  else	if(led==4'b1110)
    flag<=0;
  else
    flag<=flag;

  always@(posedge clk or negedge rst_n)
    if(rst_n == 0)
      led <= 4'b1110;
    else    if(cnt_1s==26'd24_999_999&&flag==0)
      led <= (led<<1)+1'b1;
    else  if(cnt_1s==26'd24_999_999&&flag==1)
      led <= (led>>1)+4'b1000;
    else
      led<=led;
endmodule

