///写法一//
module test(
    input rst,       // 复位信号
    input clka,     // 慢时钟a
    input clkb,     // 慢时钟b
    input signal_a, // 时钟域a下的数据
    output singal_b // 快时钟区域下的同步输出
  );

  reg   signal_a_d1, signal_a_d2,signal_a_d3;
  wire  signal_a_pos,  signal_a_neg;

  assign  singal_b = signal_a_d2;
  assign  signal_a_pos = signal_a_d2 & (~signal_a_d3);  //上升沿
  assign  signal_a_neg = (~signal_a_d2) & signal_a_d3; // 下降沿

  always @ (posedge clkb or negedge rst)
  begin    // 在快时钟域下延迟两拍
    if(~rst)
    begin
      signal_a_d1 <= 1'd0;
      signal_a_d2 <= 1'd0;
      signal_a_d3 <= 1'd0;
    end
    else
    begin
      signal_a_d1 <=signal_a;
      signal_a_d2 <= signal_a_d1;
      signal_a_d3 <= signal_a_d2;
    end
  end

endmodule

/* //写法二//
module test(
    input rst,       // 复位信号
    input clka,     // 慢时钟a
    input clkb,     // 慢时钟b
    input signal_a, // 时钟域a下的数据
    output singal_b // 快时钟区域下的同步输出
  );
 
  reg  [2:0] signal_a_d;
  wire  signal_a_pos,  signal_a_neg;
 
 
  assign  singal_b = signal_a_d[1];
  assign  signal_a_pos = signal_a_d[1] & (~signal_a_d[2]);  //上升沿
  assign  signal_a_neg = (~signal_a_d[1]) & signal_a_d[2]; // 下降沿
 
  always @ (posedge clkb or negedge rst)
  begin    // 在快时钟域下延迟两拍
    if(~rst)
    begin
      signal_a_d <= 0;
    end
    else
    begin
      signal_a_d <= {signal_a_d[1:0],signal_a};
    end
  end
endmodule  */


