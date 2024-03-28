

module cnt_led
  #(
     parameter	CNT_MAX=26'd24_999_999
   )
   (
     input	wire	clk,
     input	wire	rst_n,
     output	reg[3:0]	led
   );

  reg[25:0]	cnt_1s;
  reg	flag;
  always@(posedge	clk	or	negedge	rst_n)

    if(rst_n==0)
      cnt_1s<=26'd0;
    else	if(cnt_1s==CNT_MAX)
      cnt_1s<=26'd0;
  else
    cnt_1s<=cnt_1s+1'b1;
  always@(posedge	clk	or	negedge	rst_n)
    if(rst_n==0)
    begin
      flag<=0;
      led <= 4'b1110 ;
    end
    else	if(led==4'b1110&&cnt_1s==CNT_MAX&&flag==0)
      led <= 4'b1101;
  else	if(led==4'b1101&&cnt_1s==CNT_MAX&&flag==0)
    led <= 4'b1011;
  else	if(led==4'b1011&&cnt_1s==CNT_MAX&&flag==0)
  begin
    led <= 4'b0111;
    flag=1;
  end
  else	if(led==4'b0111&&cnt_1s==CNT_MAX&&flag==1)
    led <= 4'b1011;
  else	if(led==4'b1011&&cnt_1s==CNT_MAX&&flag==1)
    led <= 4'b1101;
  else	if(led==4'b1101&&cnt_1s==CNT_MAX&&flag==1)
  begin
    led <= 4'b1110;
    flag=0;
  end
  else
    led <=led;
endmodule
