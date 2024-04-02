module e2prom_ctrl(
    input  wire         clk        ,
    input  wire         rstn      ,
    input  wire         i2c_start_flag , //开始信号
    input  wire         i2c_rd_flag  ,//读信号
    input  wire         i2c_wr_flag  ,  //写信号
    input  wire [15:0]  i2c_addr   ,  //地址
    input  wire [ 7:0]  i2c_data_wr , //写数据
    output  reg [ 7:0]  i2c_data_rd , //读数据
    output  reg          scl        , //时钟
    inout                sda        , //数据
    output  reg          start_done,  //开始结束
    output  reg          key_done,  //读写结束
    output  reg         ack     //应答
  );
  //blue////////////////////////////////////////////////////////////////////////
  parameter   SLAVE_ADDR = 7'b1010011   ,  //EEPROM从机地址
              SLAVE_ADDR_WR= 8'b10100110   ,  //EEPROM从机地址写
              SLAVE_ADDR_RD= 8'b10100111   ;  //EEPROM从机地址读
  localparam IDLE       = 3'd0,//空闲状态
             START      = 3'd1,//发送器件地址写
             ADDR_16    = 3'd2,//发送高8位地址
             ADDR_8     = 3'd3,//发送低8位地址
             DATA_WR    = 3'd4,//写数据
             DATA_ADDR_RD=3'd5,//读数据设备地址
             DATA_RD    = 3'd6,//读数据
             STOP       = 3'd7;//停止状态
  reg    [ 2:0]  cur_state ; //状态机当前状态
  reg    [ 2:0]  next_state; //状态机下一状态
  //yellow///////////////////////////////////////////////////////////////////////
  reg            tx_done   ; //状态结束
  reg               sda_out; //SDA输出端
  reg               sda_dir;  //SDA使能端
  reg    [ 6:0]  cnt       ; //计数
  reg    [ 4:0]  clk_cnt   ; //分频时钟计数
  reg             iic_clk_4; //1M时钟
  reg  [15:0]  i2c_data_rd_16; //读16位数据
  localparam ctrl=1;        // 设备地址16位为1 8位为0
  //ORANGE///////////////////////////////////////////////////////////////////////
  assign sda = sda_dir ? sda_out : 1'bZ; //双向数据线
  //iic_clk_4  1Mhz
  always @(posedge clk or negedge rstn)
    if(!rstn)
      iic_clk_4 <= 1'd0;
    else
      if(clk_cnt == 24)
        iic_clk_4 <= ~iic_clk_4;
      else
        iic_clk_4 <= iic_clk_4;
  always @(posedge clk or negedge rstn)
    if(!rstn)
      clk_cnt <= 5'd0;
    else
      if(clk_cnt == 5'd24)
        clk_cnt <= 5'd0;
      else
        clk_cnt <= clk_cnt+1'b1;
  //yellow三段式状态机//第一段描述现态//////////////////////////////////////////////////////////////
  always @(posedge iic_clk_4 or negedge rstn)
    if(!rstn)
      cur_state <= IDLE;
    else
      cur_state <= next_state;
  //第二段组合逻辑状态机描述次态状态转移///////////////////////////////////////////////////////////
  always @(*)
  begin
    case(cur_state)
      IDLE:
      begin
        if(i2c_start_flag)
          next_state = START;
        else
          next_state = IDLE;
      end
      START:
      begin
        if(tx_done&&ctrl)
          next_state = ADDR_16;
        else if(tx_done&&ctrl==0)
          next_state = ADDR_8;
        else
          next_state = START;
      end
      ADDR_16:
      begin
        if(tx_done)
          next_state = ADDR_8;
        else
          next_state = ADDR_16;
      end
      ADDR_8:
      begin
        if(tx_done)
          if(i2c_wr_flag)
            next_state = DATA_WR;
          else if(i2c_rd_flag)
            next_state = DATA_ADDR_RD;
          else
            next_state=ADDR_8;
        else
          next_state = ADDR_8;
      end
      DATA_ADDR_RD:
      begin
        if(tx_done)
          next_state = DATA_RD;
        else
          next_state = DATA_ADDR_RD;
      end
      DATA_WR:
      begin
        if(tx_done)
          next_state = STOP;
        else
          next_state = DATA_WR;
      end
      DATA_RD:
      begin
        if(tx_done)
          next_state = STOP;
        else
          next_state = DATA_RD;
      end
      STOP:
      begin
        if(tx_done)
          next_state = IDLE;
        else
          next_state = STOP;
      end
      default:
        next_state = ADDR_8;
    endcase
  end
  //orange时序逻辑状态机描述输出///////////////////////////////////////////////////////////
  always @(posedge iic_clk_4 or negedge rstn)
    if(!rstn)
    begin
      i2c_data_rd<=8'd0;
      scl<=1'd0;
      sda_out<=1'd1;
      sda_dir<=1'd1;
      cnt<=7'd0;
      start_done<=1'd0;
      key_done <=1'd0;
      tx_done<=1'd0;
      ack<=1'd0;
    end
    else
    begin
      start_done<=1'd0;
      key_done <=1'd0;
      tx_done<=1'd0;
      cnt<=cnt+1'b1;
      ack<=1'd0;
      case(cur_state)
        IDLE:
          IDLE_TASK;//空闲状态
        START:
        begin
          START_TASK;//发送设备地址
        end
        ADDR_16:
          ADDR_16_TASK;//发送高8位地址
        ADDR_8:
          ADDR_8_TASK;//发送低8位地址
        DATA_WR:
          DATA_WR_TASK;//写数据
        DATA_ADDR_RD:
          DATA_ADDR_RD_TASK;//读数据设备地址
        DATA_RD:
          DATA_RD_TASK;//读8位数据
        STOP:
          STOP_TASK;//停止
        default :
          ;
      endcase
    end
  //pink/////////////////////任务封装////////////////////////////////////////////////////////////////////////////
  task IDLE_TASK;
    begin
      cnt<=7'd0;
      scl<=1'd1;
      sda_dir <= 1'b1;
      sda_out<=1'd1;
    end
  endtask
  ///开始任务///////////////////////////////////////////////////////////////////////////////////////////////////
  task START_TASK;
    begin
      case(cnt)
        7'd0:
          sda_out <= 1'b0;
        7'd3 :
          scl <= 1'b0;
        7'd4 :
          sda_out <= SLAVE_ADDR_WR[7];
        7'd5 :
          scl <= 1'b1;
        7'd7 :
          scl <= 1'b0;
        7'd8 :
          sda_out <= SLAVE_ADDR_WR[6];
        7'd9 :
          scl <= 1'b1;
        7'd11:
          scl <= 1'b0;
        7'd12:
          sda_out <= SLAVE_ADDR_WR[5];
        7'd13:
          scl <= 1'b1;
        7'd15:
          scl <= 1'b0;
        7'd16:
          sda_out <= SLAVE_ADDR_WR[4];
        7'd17:
          scl <= 1'b1;
        7'd19:
          scl <= 1'b0;
        7'd20:
          sda_out <= SLAVE_ADDR_WR[3];
        7'd21:
          scl <= 1'b1;
        7'd23:
          scl <= 1'b0;
        7'd24:
          sda_out <= SLAVE_ADDR_WR[2];
        7'd25:
          scl <= 1'b1;
        7'd27:
          scl <= 1'b0;
        7'd28:
          sda_out <= SLAVE_ADDR_WR[1];
        7'd29:
          scl <= 1'b1;
        7'd31:
          scl <= 1'b0;
        7'd32:
          sda_out <= SLAVE_ADDR_WR[0];
        7'd33:
          scl <= 1'b1;
        7'd35:
          scl <= 1'b0;
        7'd36:
        begin
          sda_dir <= 1'b0;
        end
        7'd37:
        begin
          scl <= 1'b1;
          if(sda==0)
            ack<=1;
        end
        7'd39:
        begin
          scl <= 1'b0;
          tx_done <= 1'b1;
        end
        7'd40:
        begin
          sda_dir <= 1'b1;
          cnt <= 1'b0;
        end
        default:
          ;
      endcase
    end
  endtask
  //发送高8位地址任务//////////////////////////////////////////////////////////////////////////////////////////////
  task ADDR_16_TASK;
    begin
      case(cnt)
        7'd0:
          sda_out <= 1'b0;
        7'd3 :
          scl <= 1'b0;
        7'd4 :
          sda_out <= i2c_addr[15];
        7'd5 :
          scl <= 1'b1;
        7'd7 :
          scl <= 1'b0;
        7'd8 :
          sda_out <= i2c_addr[14];
        7'd9 :
          scl <= 1'b1;
        7'd11:
          scl <= 1'b0;
        7'd12:
          sda_out <= i2c_addr[13];
        7'd13:
          scl <= 1'b1;
        7'd15:
          scl <= 1'b0;
        7'd16:
          sda_out <= i2c_addr[12];
        7'd17:
          scl <= 1'b1;
        7'd19:
          scl <= 1'b0;
        7'd20:
          sda_out <= i2c_addr[11];
        7'd21:
          scl <= 1'b1;
        7'd23:
          scl <= 1'b0;
        7'd24:
          sda_out <= i2c_addr[10];
        7'd25:
          scl <= 1'b1;
        7'd27:
          scl <= 1'b0;
        7'd28:
          sda_out <= i2c_addr[9];
        7'd29:
          scl <= 1'b1;
        7'd31:
          scl <= 1'b0;
        7'd32:
          sda_out <= i2c_addr[8];
        7'd33:
          scl <= 1'b1;
        7'd35:
          scl <= 1'b0;
        7'd36:
        begin
          sda_dir <= 1'b0;
        end
        7'd37:
        begin
          scl <= 1'b1;
          if(sda==0)
            ack<=1;
        end
        7'd39:
        begin
          scl <= 1'b0;
          tx_done <= 1'b1;
        end
        7'd40:
        begin
          sda_dir <= 1'b1;
          cnt <= 1'b0;
        end
        default:
          ;
      endcase
    end
  endtask
  //发送低8位地址任务//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task ADDR_8_TASK;
    begin
      case(cnt)
        7'd0:
          sda_out <= 1'b0;
        7'd3 :
          scl <= 1'b0;
        7'd4 :
          sda_out <= i2c_addr[7];
        7'd5 :
          scl <= 1'b1;
        7'd7 :
          scl <= 1'b0;
        7'd8 :
          sda_out <= i2c_addr[6];
        7'd9 :
          scl <= 1'b1;
        7'd11:
          scl <= 1'b0;
        7'd12:
          sda_out <= i2c_addr[5];
        7'd13:
          scl <= 1'b1;
        7'd15:
          scl <= 1'b0;
        7'd16:
          sda_out <= i2c_addr[4];
        7'd17:
          scl <= 1'b1;
        7'd19:
          scl <= 1'b0;
        7'd20:
          sda_out <= i2c_addr[3];
        7'd21:
          scl <= 1'b1;
        7'd23:
          scl <= 1'b0;
        7'd24:
          sda_out <= i2c_addr[2];
        7'd25:
          scl <= 1'b1;
        7'd27:
          scl <= 1'b0;
        7'd28:
          sda_out <= i2c_addr[1];
        7'd29:
          scl <= 1'b1;
        7'd31:
          scl <= 1'b0;
        7'd32:
          sda_out <= i2c_addr[0];
        7'd33:
          scl <= 1'b1;
        7'd35:
          scl <= 1'b0;
        7'd36:
        begin
          sda_dir <= 1'b0;
        end
        7'd37:
        begin
          scl <= 1'b1;
          if(sda==0)
            ack<=1;
        end
        7'd39:
        begin
          scl <= 1'b0;
          tx_done <= 1'b1;
        end
        7'd40:
        begin
          sda_dir <= 1'b1;
          cnt <= 1'b0;
        end
        default:
          ;
      endcase
    end
  endtask
  //写数据任务//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task DATA_WR_TASK;
    begin
      case(cnt)
        7'd0:
          sda_out <= 1'b0;
        7'd3 :
          scl <= 1'b0;
        7'd4 :
          sda_out <= i2c_data_wr[7];
        7'd5 :
          scl <= 1'b1;
        7'd7 :
          scl <= 1'b0;
        7'd8 :
          sda_out <= i2c_data_wr[6];
        7'd9 :
          scl <= 1'b1;
        7'd11:
          scl <= 1'b0;
        7'd12:
          sda_out <= i2c_data_wr[5];
        7'd13:
          scl <= 1'b1;
        7'd15:
          scl <= 1'b0;
        7'd16:
          sda_out <= i2c_data_wr[4];
        7'd17:
          scl <= 1'b1;
        7'd19:
          scl <= 1'b0;
        7'd20:
          sda_out <= i2c_data_wr[3];
        7'd21:
          scl <= 1'b1;
        7'd23:
          scl <= 1'b0;
        7'd24:
          sda_out <= i2c_data_wr[2];
        7'd25:
          scl <= 1'b1;
        7'd27:
          scl <= 1'b0;
        7'd28:
          sda_out <= i2c_data_wr[1];
        7'd29:
          scl <= 1'b1;
        7'd31:
          scl <= 1'b0;
        7'd32:
          sda_out <= i2c_data_wr[0];
        7'd33:
          scl <= 1'b1;
        7'd35:
          scl <= 1'b0;
        7'd36:
        begin
          sda_dir <= 1'b0;
        end
        7'd37:
        begin
          scl <= 1'b1;
          if(sda==0)
            ack<=1;
        end
        7'd39:
        begin
          scl <= 1'b0;
          tx_done <= 1'b1;
        end
        7'd40:
        begin
          sda_dir <= 1'b1;
          cnt <= 1'b0;
        end
        default:
          ;
      endcase
    end
  endtask
  //读数据设备地址任务///////////////////////////////////////////////////////////////////////////////////////////////
  task DATA_ADDR_RD_TASK;
    begin
      case(cnt)
        7'd0 :
        begin
          sda_out <= 1'b1;
          scl <= 1'b1;
        end
        7'd2 :
          sda_out <= 1'b0;//起始条件
        7'd3 :
          scl <= 1'b0;
        7'd4 :
          sda_out <= SLAVE_ADDR_RD[7];
        7'd5 :
          scl <= 1'b1;
        7'd7 :
          scl <= 1'b0;
        7'd8 :
          sda_out <= SLAVE_ADDR_RD[6];
        7'd9 :
          scl <= 1'b1;
        7'd11:
          scl <= 1'b0;
        7'd12:
          sda_out <= SLAVE_ADDR_RD[5];
        7'd13:
          scl <= 1'b1;
        7'd15:
          scl <= 1'b0;
        7'd16:
          sda_out <= SLAVE_ADDR_RD[4];
        7'd17:
          scl <= 1'b1;
        7'd19:
          scl <= 1'b0;
        7'd20:
          sda_out <= SLAVE_ADDR_RD[3];
        7'd21:
          scl <= 1'b1;
        7'd23:
          scl <= 1'b0;
        7'd24:
          sda_out <= SLAVE_ADDR_RD[2];
        7'd25:
          scl <= 1'b1;
        7'd27:
          scl <= 1'b0;
        7'd28:
          sda_out <= SLAVE_ADDR_RD[1];
        7'd29:
          scl <= 1'b1;
        7'd31:
          scl <= 1'b0;
        7'd32:
          sda_out <= SLAVE_ADDR_RD[0];
        7'd33:
          scl <= 1'b1;
        7'd35:
          scl <= 1'b0;
        7'd36:
        begin
          sda_dir <= 1'b0;
          sda_out <= 1'b1;
        end
        7'd37:
        begin
          scl <= 1'b1;
          if(sda==0)
            ack<=1;
        end
        7'd38:
        begin
          tx_done <= 1'b1;
        end
        7'd39:
        begin
          scl <= 1'b0;
          cnt <= 1'b0;
        end
        default:
          ;
      endcase
    end
  endtask
  //读8位数据任务//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task DATA_RD_TASK;
    begin
      case(cnt)
        7'd0:
          sda_dir <= 1'b0;
        7'd1:
        begin
          i2c_data_rd[7] <= sda;
          scl       <= 1'b1;
        end
        7'd3:
          scl  <= 1'b0;
        7'd5:
        begin
          i2c_data_rd[6] <= sda ;
          scl       <= 1'b1   ;
        end
        7'd7:
          scl  <= 1'b0;
        7'd9:
        begin
          i2c_data_rd[5] <= sda;
          scl       <= 1'b1  ;
        end
        7'd11:
          scl  <= 1'b0;
        7'd13:
        begin
          i2c_data_rd[4] <= sda;
          scl       <= 1'b1  ;
        end
        7'd15:
          scl  <= 1'b0;
        7'd17:
        begin
          i2c_data_rd[3] <= sda;
          scl       <= 1'b1  ;
        end
        7'd19:
          scl  <= 1'b0;
        7'd21:
        begin
          i2c_data_rd[2] <= sda;
          scl       <= 1'b1  ;
        end
        7'd23:
          scl  <= 1'b0;
        7'd25:
        begin
          i2c_data_rd[1] <= sda;
          scl       <= 1'b1  ;
        end
        7'd27:
          scl  <= 1'b0;
        7'd29:
        begin
          i2c_data_rd[0] <= sda;
          scl       <= 1'b1  ;
        end
        7'd31:
          scl  <= 1'b0;
        7'd32:
        begin
          sda_dir <= 1'b1;
          sda_out <= 1'b1;
        end
        7'd33:
        begin
          scl <= 1'b1;
        end
        7'd34:
          tx_done <= 1'b1;
        7'd35:
        begin
          scl <= 1'b0;
          cnt <= 1'b0;
        end
        default  :
          ;
      endcase
    end
  endtask
  //读16位数据任务//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task DATA_RD_16_TASK;
    begin
      case(cnt)
        7'd0:
          sda_dir <= 1'b0;
        7'd1:
        begin
          i2c_data_rd_16[15] <= sda;
          scl       <= 1'b1;
        end
        7'd3:
          scl  <= 1'b0;
        7'd5:
        begin
          i2c_data_rd_16[14] <= sda ;
          scl       <= 1'b1   ;
        end
        7'd7:
          scl  <= 1'b0;
        7'd9:
        begin
          i2c_data_rd_16[13] <= sda;
          scl       <= 1'b1  ;
        end
        7'd11:
          scl  <= 1'b0;
        7'd13:
        begin
          i2c_data_rd_16[12] <= sda;
          scl       <= 1'b1  ;
        end
        7'd15:
          scl  <= 1'b0;
        7'd17:
        begin
          i2c_data_rd_16[11] <= sda;
          scl       <= 1'b1  ;
        end
        7'd19:
          scl  <= 1'b0;
        7'd21:
        begin
          i2c_data_rd_16[10] <= sda;
          scl       <= 1'b1  ;
        end
        7'd23:
          scl  <= 1'b0;
        7'd25:
        begin
          i2c_data_rd_16[9] <= sda;
          scl       <= 1'b1  ;
        end
        7'd27:
          scl  <= 1'b0;
        7'd29:
        begin
          i2c_data_rd_16[8] <= sda;
          scl       <= 1'b1  ;
        end
        7'd31:
        begin
          scl  <= 1'b0;
          sda_dir <= 1'b1;
          sda_out <= 1'b0;  //主机应答
        end
        7'd33:
          scl  <= 1'b1;
        7'd35:
          scl  <= 1'b0;
        7'd40:
          sda_dir <= 1'b0;
        7'd41:
        begin
          i2c_data_rd_16[7] <= sda;
          scl       <= 1'b1;
        end
        7'd43:
          scl  <= 1'b0;
        7'd45:
        begin
          i2c_data_rd_16[6] <= sda ;
          scl       <= 1'b1   ;
        end
        7'd47:
          scl  <= 1'b0;
        7'd49:
        begin
          i2c_data_rd_16[5] <= sda;
          scl       <= 1'b1  ;
        end
        7'd51:
          scl  <= 1'b0;
        7'd53:
        begin
          i2c_data_rd_16[4] <= sda;
          scl       <= 1'b1  ;
        end
        7'd55:
          scl  <= 1'b0;
        7'd57:
        begin
          i2c_data_rd_16[3] <= sda;
          scl       <= 1'b1  ;
        end
        7'd59:
          scl  <= 1'b0;
        7'd61:
        begin
          i2c_data_rd_16[2] <= sda;
          scl       <= 1'b1  ;
        end
        7'd63:
          scl  <= 1'b0;
        7'd65:
        begin
          i2c_data_rd_16[1] <= sda;
          scl       <= 1'b1  ;
        end
        7'd67:
          scl  <= 1'b0;
        7'd69:
        begin
          i2c_data_rd_16[0] <= sda;
          scl       <= 1'b1  ;
        end
        7'd71:
          scl  <= 1'b0;
        7'd72:
        begin
          sda_dir <= 1'b1;
          sda_out <= 1'b1;
        end
        7'd73:
        begin
          scl <= 1'b1;
        end
        7'd74:
          tx_done <= 1'b1;
        7'd75:
        begin
          scl <= 1'b0;
          cnt <= 1'b0;
        end
        default  :
          ;
      endcase
    end
  endtask
  //停止任务//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task STOP_TASK;
    begin
      case(cnt)
        7'd0:
        begin
          start_done<=1'b1;
          key_done<=1'b1;
          sda_dir <= 1'b1;
          sda_out <= 1'b0;
        end
        7'd1 :
          scl     <= 1'b1;
        7'd3 :
          sda_out <= 1'b1;
        7'd15:
          tx_done <= 1'b1;
        7'd16:
        begin
          cnt      <= 1'b0;
        end
        default  :
          ;
      endcase
    end
  endtask
endmodule


