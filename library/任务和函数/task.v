module task_test(

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
          load; //调用任务
          state <= state + 1'b1;
        end
        2'd2:
        begin
          shift;//调用任务
          state <= state + 1'b1;
        end
        2'd3:
        begin
          out(save_data,data_out);//调用out任务
          state <= 2'd0;
        end

      endcase
    end
  end

  task load;
    begin
      save_data <= data_in;
    end
  endtask


  task shift;
    begin
      save_data <= save_data << 1;
    end
  endtask

  task out;
    input [7:0] a;
    output [7:0] b;

    begin
      b = a;
    end
  endtask



endmodule
