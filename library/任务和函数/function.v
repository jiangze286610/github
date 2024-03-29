
module function_test(

    input clk,
    input rst_n,

    input start,
    input [7:0] data_in,//输入的数据
    output reg [7:0] data_out//输出的数据
  );

  reg [7:0] save_data;//定义1个8位的寄存器
  reg [1:0] state;//定义2位的状态机

  always @ (posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      state <= 2'd0;
      save_data <= 8'd0;
      data_out <= 8'd0;
    end
    else
    begin
      case(state)
        2'd0:
        begin
          if(start)//如果启动信号start有效，状态机跳转
            state <= state + 1'b1;
          else
            state <= state;
        end
        2'd1:
        begin
          save_data <= load_data(data_in);//调用load_data函数
          state <= state + 1'b1;
        end
        2'd2:
        begin
          save_data <= shift(save_data);//调用shift函数
          state <= state + 1'b1;
        end
        2'd3:
        begin
          data_out <= load_data(save_data);
          state <= 2'd0;
        end

      endcase
    end
  end

  function [7:0] load_data;
    input [7:0] data;
    begin
      load_data = data;
    end
  endfunction


  function [7:0] shift;
    input [7:0] shift_data;
    begin
      shift = shift_data << 1;
    end
  endfunction



endmodule
