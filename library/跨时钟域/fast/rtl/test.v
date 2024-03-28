//快时钟域到慢时钟域
module test(
    input wire rst,       // 复位信号
    input wire clka,     // 快时钟a
    input wire clkb,     // 慢时钟b
    input wire signal_a, // 快时钟域a下的数据
    output wire  singal_b // 慢时钟域b下的同步输出
  );
  reg  [2:0] signal_a_d;
  reg  signal_a_d1_or;
  reg  [2:0] signal_b_d1_or;

  assign  singal_b = (~signal_b_d1_or[2]) & signal_b_d1_or[1];

  always @ (posedge clka , negedge rst)
  begin    // 在快时钟域下延迟两拍,对信号进行展宽
    if(~rst)
    begin
      signal_a_d <= 2'd0;
    end
    else
    begin
      signal_a_d <= {signal_a_d[1:0],signal_a};  // 具体展宽几拍可以根据实际情况进行展开
    end
  end

  always @ (posedge clka or negedge rst)
  begin    // 对信号做或实现信号的展宽
    if(~rst)
    begin
      signal_a_d1_or <= 1'd0;
    end
    else
    begin
      signal_a_d1_or <= signal_a_d[1] | signal_a_d[0] |signal_a_d[2] ;
    end
  end

  always @ (posedge clkb or negedge rst)
  begin    // 在慢时钟域下对进行打拍，消除亚稳态
    if(~rst)
    begin
      signal_b_d1_or <= 1'd0;
    end
    else
    begin
      signal_b_d1_or <= {signal_b_d1_or[1:0],signal_a_d1_or} ;
    end
  end

endmodule

