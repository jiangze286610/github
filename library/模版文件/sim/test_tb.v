module test_tb();
  reg rst;
  reg clka;
  reg clkb;
  reg signal_a;
  wire singal_b;

  test test(
         .rst       (rst) ,       // 复位信号
         .clka      (clka) ,     // 慢时钟a
         .clkb      (clkb) ,     // 慢时钟b
         .signal_a  (signal_a) , // 时钟域a下的数据
         .singal_b  (singal_b)     // 快时钟区域下的同步输出
       );

  initial
    clka = 0;
  always #5 clka = ~clka;

  initial
    clkb = 0;
  always #10 clkb = ~clkb;

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
