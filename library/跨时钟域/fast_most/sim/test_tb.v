module test_tb();
  reg rst;
  reg clka;
  reg clkb;
  reg signal_a;
  wire singal_b;

  test  test_inst (
          .clk_fast(clka),
          .clk_slow(clkb),
          .rstn(rst),
          .data_in(signal_a),
          .data_out(singal_b)
        );
  initial
    clka = 0;
  always #5 clka = ~clka;

  initial
    clkb = 0;
  always #16 clkb = ~clkb;

  initial
  begin
    rst =0;
    #10;
    rst =1;
  end
  always@(posedge clka or negedge rst)
  begin
    if(~rst)
    begin
      signal_a <=0;
    end
    else
    begin
      repeat (10)
      begin
        signal_a = {$random}%2;
        #10;
        signal_a = 0;
        #200;
      end
    end
  end

endmodule
