module test(
    input wire clk_fast,
    input wire clk_slow,
    input wire rstn,
    input wire data_in,
    output wire data_out
  );
  reg toggle;
  reg low_1,low_2;
  reg fast_1,fast_2;

  always @(posedge clk_fast or negedge rstn)
  begin
    if(~rstn)
      toggle <= 0;
    else if(data_in)
      toggle <= 1;
    else if(fast_1 ^ fast_2)
      toggle <= 0;
  end

  always @(posedge clk_slow or negedge rstn)
  begin
    if(~rstn)
      {low_1,low_2} <= {1'b0,1'b0};
    else
      {low_1,low_2} <= {toggle,low_1};
  end

  always @(posedge clk_fast or negedge rstn)
  begin
    if(~rstn)
      {fast_1,fast_2} <= {1'b0,1'b0};
    else
      {fast_1,fast_2} <= {low_1,fast_1};
  end

  assign data_out = low_2;
endmodule //fast_to_slow
