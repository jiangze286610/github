module fsm_moore(
input	wire	clk,
input	wire	rst_n,
input	wire	data,
output	reg		out
);

reg[31:0]	state;					//moore
reg[31:0]	state1;
parameter	IDLE=6'b000001;
parameter	S0=6'b000010;
parameter	S1=6'b000100;
parameter	S2=6'b001000;
parameter	S3=6'b010000;
parameter	S4=6'b100000;

always@(posedge	clk	or negedge	rst_n) //3段式
if(~rst_n)
	state<=IDLE;
	else
state<=state1;

always@(*)
if(~rst_n)
	state1<=IDLE;
	else	begin
	case(state)
IDLE	:begin
			if(data==1)
			state1<=S0;
			else
			state1<=state1;
		end
S0		:begin
			if(data==0)
			state1<=S1;
			else
		state1<=state1;			
		end
S1		:begin
			if(data==1)
			state1<=S2;
			else
		state1<=S0;			
		end
S2		:begin
			if(data==1)
			state1<=S3;
			else
		state1<=IDLE;			
		end
S3		:begin
			if(data==1)
			state1<=S4;
			else
		state1<=S0;			
		end
S4		:begin
			if(data==0)
			state1<=IDLE;
			else
		state1<=S0;			
		end
default	state1<=IDLE;
endcase
end


always@(posedge	clk	or negedge	rst_n)
if(~rst_n)
	out<=1'd0;
	else	if(state==S4)
	out<=1'd1;
	else	out<=1'd0;
	

endmodule









