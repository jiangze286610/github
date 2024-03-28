module fsm_moore(
input	wire	clk,
input	wire	rst_n,
input	wire	data,
output	reg		out
);
reg[31:0]	state;					//moore
parameter	IDLE=6'b000001;
parameter	S0=6'b000010;
parameter	S1=6'b000100;
parameter	S2=6'b001000;
parameter	S3=6'b010000;
parameter	S4=6'b100000;
 always@(posedge	clk	or	negedge	rst_n)      //1段式
if(~rst_n)
begin
state<=IDLE;
end
else
case(state)
IDLE	:begin
			if(data==1)
			state<=S0;
			else
			state<=state;
		end
S0		:begin
			if(data==0)
			state<=S1;
			else
		state<=S0;			
		end
S1		:begin
			if(data==1)
			state<=S2;
			else
		state<=IDLE;			
		end
S2		:begin
			if(data==1)
			state<=S3;
			else
		state<=IDLE;			
		end
S3		:begin
			if(data==1)
			state<=S4;
			else
		state<=IDLE;			
		end
S4		:begin
			if(data==0)
			state<=IDLE;
			else
		state<=S0;			
		end
default	state<=IDLE;
endcase

always@(posedge	clk	or negedge	rst_n)
if(~rst_n)
	out<=1'd0;
	else	if(state==S4)
	out<=1'd1;
	else	out<=1'd0; 
endmodule








