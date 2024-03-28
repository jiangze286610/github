 `timescale	1ns/1ps	
module fsm_moore_tb();
	reg	clk;
	reg	rst_n;
	reg	data;
	wire	out;
initial	begin
clk=1'd0;
	rst_n=1'd0;
	data=1'd0;
	#200	rst_n=1'd1;
		end
always	#10	clk=~clk;
always	#20.1	data={$random}%2;
defparam	fsm_moore.IDLE="IDLE";
defparam	fsm_moore.S0="S0";
defparam	fsm_moore.S1="S1";
defparam	fsm_moore.S2="S2";
defparam	fsm_moore.S3="S3";
defparam	fsm_moore.S4="S4";
fsm_moore fsm_moore(
.	clk		(clk	),
.	rst_n	(rst_n	),
.	data	(data	),
.	out		(out	)
);
endmodule
