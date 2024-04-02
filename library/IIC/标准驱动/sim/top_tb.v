`timescale 1ns/1ps
module top_tb ();
  reg clk;
  reg rstn;
  reg key1_res;
  reg key2_res;
  wire sda;
  wire scl;
  initial
  begin
    clk=1'd0;
    rstn=1'd0;
    key1_res=1'd1;
    key2_res=1'd1;
    #200
     rstn=1'd1;
    key1_res=1'd0;
    #(1000000*20)
     #2000
     key1_res=1'd0;
    // key2_res=1'd0;
    #(1000000*20)
     #2000
     key2_res=1'd1;

  end
  always #10 clk=~clk;


  top  top_inst (
         .clk(clk),
         .rstn(rstn),
         .key1_res(key1_res),
         .key2_res(key2_res),
         .sda(sda),
         .scl(scl)
       );

endmodule
