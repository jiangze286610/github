module e2prom_ctrl (
    input  wire         clk        ,
    input  wire         rstn      ,
    input  wire         i2c_start_flag   ,
    input  wire         i2c_rd_flag  ,
    input  wire         i2c_wr_flag  ,
    input  wire [15:0]  i2c_addr   ,
    input  wire [ 7:0]  i2c_data_wr ,
    output  reg  [ 7:0]  i2c_data_rd ,
    output  reg          scl        ,
    inout                sda        ,
    output  reg          start_done,
    output  reg          key_done
  );
  //blue////////////////////////////////////////////////////////////////////////
  parameter   SLAVE_ADDR = 7'b1010011   ,  //EEPROM从机地址
              SLAVE_ADDR_WR= 8'b10100110   ,
              SLAVE_ADDR_RD= 8'b10100111   ;
  localparam IDLE       = 3'd0,//空闲状态
             START      = 3'd1,//发送器件地址读、写
             ADDR_16    = 3'd2,//发送高8位地址
             ADDR_8     = 3'd3,//发送低8位地址
             DATA_WR    = 3'd4,//写数据
             DATA_RD    = 3'd5,//读数据
             STOP       = 3'd6,//停止状态
             DATA_ADDR_RD=3'd7;
  reg    [ 2:0]  cur_state ; //状态机当前状态
  reg    [ 2:0]  next_state; //状态机下一状态
  //yellow///////////////////////////////////////////////////////////////////////
  reg            tx_done   ; //状态结束
  reg               sda_out;
  reg               sda_dir;
  reg    [ 6:0]  cnt       ; //计数
  reg    [ 4:0]  clk_cnt   ; //分频时钟计数
  reg             iic_clk_4;
  /*   reg  [ 7:0]  device_addr; */
  //ORANGE///////////////////////////////////////////////////////////////////////
  assign sda = sda_dir ? sda_out : 1'bZ;
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
      if(clk_cnt == 24)
        clk_cnt <= 5'd0;
      else
        clk_cnt <= clk_cnt+1'b1;
  //yellow三段式状态机///////////////////////////////////////////////////////////////
  always @(posedge iic_clk_4 or negedge rstn)
    if(!rstn)
      cur_state <= IDLE;
    else
      cur_state <= next_state;
  //第二段组合逻辑状态机描述状态转移
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
        if(tx_done)
          next_state = ADDR_16;
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
      tx_done<=1'd0;
      sda_dir<=1'd1;

      cnt<=7'd0;
      start_done<=1'd0;
      key_done <=1'd0;
    end
    else
    begin
      start_done<=1'd0;
      key_done <=1'd0;
      tx_done<=1'd0;
      cnt<=cnt+1'b1;
      case(cur_state)
        IDLE:
        begin
          cnt<=7'd0;
          scl<=1'd1;
          sda_dir <= 1'b1;
          sda_out<=1'd1;
        end
        START:
        begin
          case(cnt)
            7'd1 :
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
              sda_out <= 1'b1;
            end
            7'd37:
              scl     <= 1'b1;
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
        ADDR_16:
        begin
          case(cnt)
            7'd0 :
            begin
              sda_dir <= 1'b1 ;
              sda_out <= i2c_addr[15];
            end
            7'd1 :
              scl <= 1'b1;
            7'd3 :
              scl <= 1'b0;
            7'd4 :
              sda_out <= i2c_addr[14];
            7'd5 :
              scl <= 1'b1;
            7'd7 :
              scl <= 1'b0;
            7'd8 :
              sda_out <= i2c_addr[13];
            7'd9 :
              scl <= 1'b1;
            7'd11:
              scl <= 1'b0;
            7'd12:
              sda_out <= i2c_addr[12];
            7'd13:
              scl <= 1'b1;
            7'd15:
              scl <= 1'b0;
            7'd16:
              sda_out <= i2c_addr[11];
            7'd17:
              scl <= 1'b1;
            7'd19:
              scl <= 1'b0;
            7'd20:
              sda_out <= i2c_addr[10];
            7'd21:
              scl <= 1'b1;
            7'd23:
              scl <= 1'b0;
            7'd24:
              sda_out <= i2c_addr[9];
            7'd25:
              scl <= 1'b1;
            7'd27:
              scl <= 1'b0;
            7'd28:
              sda_out <= i2c_addr[8];
            7'd29:
              scl <= 1'b1;
            7'd31:
              scl <= 1'b0;
            7'd32:
            begin
              sda_dir <= 1'b0;
              sda_out <= 1'b1;
            end
            7'd33:
              scl  <= 1'b1;
            7'd34:
            begin
              tx_done <= 1'b1;
            end
            7'd35:
            begin
              scl <= 1'b0;
              cnt <= 1'b0;
            end
            default:
              ;
          endcase
        end
        ADDR_8:
        begin
          case(cnt)
            7'd0:
            begin
              sda_dir <= 1'b1 ;
              sda_out <= i2c_addr[7];
            end
            7'd1 :
              scl <= 1'b1;
            7'd3 :
              scl <= 1'b0;
            7'd4 :
              sda_out <= i2c_addr[6];
            7'd5 :
              scl <= 1'b1;
            7'd7 :
              scl <= 1'b0;
            7'd8 :
              sda_out <= i2c_addr[5];
            7'd9 :
              scl <= 1'b1;
            7'd11:
              scl <= 1'b0;
            7'd12:
              sda_out <= i2c_addr[4];
            7'd13:
              scl <= 1'b1;
            7'd15:
              scl <= 1'b0;
            7'd16:
              sda_out <= i2c_addr[3];
            7'd17:
              scl <= 1'b1;
            7'd19:
              scl <= 1'b0;
            7'd20:
              sda_out <= i2c_addr[2];
            7'd21:
              scl <= 1'b1;
            7'd23:
              scl <= 1'b0;
            7'd24:
              sda_out <= i2c_addr[1];
            7'd25:
              scl <= 1'b1;
            7'd27:
              scl <= 1'b0;
            7'd28:
              sda_out <= i2c_addr[0];
            7'd29:
              scl <= 1'b1;
            7'd31:
              scl <= 1'b0;
            7'd32:
            begin
              sda_dir <= 1'b0;
              sda_out <= 1'b1;
            end
            7'd33:
              scl     <= 1'b1;
            7'd34:
            begin
              tx_done <= 1'b1;
            end
            7'd35:
            begin
              scl <= 1'b0;
              cnt <= 1'b0;
            end
            default:
              ;
          endcase

        end

        DATA_WR:
        begin
          case(cnt)
            7'd0:
            begin
              sda_out <= i2c_data_wr[7];
              sda_dir <= 1'b1;
            end
            7'd1 :
              scl <= 1'b1;
            7'd3 :
              scl <= 1'b0;
            7'd4 :
              sda_out <= i2c_data_wr[6];
            7'd5 :
              scl <= 1'b1;
            7'd7 :
              scl <= 1'b0;
            7'd8 :
              sda_out <= i2c_data_wr[5];
            7'd9 :
              scl <= 1'b1;
            7'd11:
              scl <= 1'b0;
            7'd12:
              sda_out <= i2c_data_wr[4];
            7'd13:
              scl <= 1'b1;
            7'd15:
              scl <= 1'b0;
            7'd16:
              sda_out <= i2c_data_wr[3];
            7'd17:
              scl <= 1'b1;
            7'd19:
              scl <= 1'b0;
            7'd20:
              sda_out <= i2c_data_wr[2];
            7'd21:
              scl <= 1'b1;
            7'd23:
              scl <= 1'b0;
            7'd24:
              sda_out <= i2c_data_wr[1];
            7'd25:
              scl <= 1'b1;
            7'd27:
              scl <= 1'b0;
            7'd28:
              sda_out <= i2c_data_wr[0];
            7'd29:
              scl <= 1'b1;
            7'd31:
              scl <= 1'b0;
            7'd32:
            begin
              sda_dir <= 1'b0;
              sda_out <= 1'b1;
            end
            7'd33:
              scl <= 1'b1;
            7'd34:
            begin
              tx_done <= 1'b1;
            end
            7'd35:
            begin
              scl  <= 1'b0;
              cnt  <= 1'b0;
            end
            default  :
              ;
          endcase
        end

        DATA_ADDR_RD:
        begin
          case(cnt)
            7'd0 :
            begin
              sda_dir <= 1'b1;
              sda_out <= 1'b1;
            end
            7'd1 :
              scl <= 1'b1;
            7'd2 :
              sda_out <= 1'b0;
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
              scl     <= 1'b1;
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
        DATA_RD:
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
              scl     <= 1'b1;
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
        STOP:
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
        default :
          ;
      endcase
    end
endmodule


