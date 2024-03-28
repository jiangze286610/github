module cnt_led(
    input	wire	clk,
    input	wire	rst_n,
    output	reg[3:0]	led
  );
  reg[25:0]	cnt_1s;
  always@(posedge	clk	or	negedge	rst_n)

    if(rst_n==0)
      cnt_1s<=26'd0;
    else	if(cnt_1s==26'd49_999_999)
      cnt_1s<=26'd0;
  else
    cnt_1s<=cnt_1s+1'b1;

  always@(posedge clk or negedge rst_n)
    if(rst_n == 0)

      led <= 4'b0000;
    else    if(cnt_1s==26'd49_999_999)
      led <= ~led;
    else
      led<=led;
endmodule
