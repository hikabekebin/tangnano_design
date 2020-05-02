`timescale 1 ns / 1 ps
module tg (
	   clk,
	   xrst,
	   vs_in,
	   hs_in,
	   de_in,
	   rdata_in,
	   gdata_in,
	   bdata_in,
	   vs_out,
	   hs_out,
	   de_out,
	   rdata_out,
	   gdata_out,
	   bdata_out,
	   xstby,
	   rev
	   );

   parameter P_DL = 2;
   parameter P_DAT_BIT = 6;

   input                  clk;
   input 		  xrst;
   
   input 		  vs_in;
   input 		  hs_in;
   input                  de_in;
   input [P_DAT_BIT-1:0]  rdata_in;
   input [P_DAT_BIT-1:0]  gdata_in;
   input [P_DAT_BIT-1:0]  bdata_in;
   
   output                 vs_out;
   output                 hs_out;
   output                 de_out;
   output [P_DAT_BIT-1:0] rdata_out;
   output [P_DAT_BIT-1:0] gdata_out;
   output [P_DAT_BIT-1:0] bdata_out;
   output 		  xstby;
   output 		  rev; 		  
   
   reg                 vs_out;
   reg                 hs_out;
   reg                 de_out;
   reg [P_DAT_BIT-1:0] rdata_out;
   reg [P_DAT_BIT-1:0] gdata_out;   
   reg [P_DAT_BIT-1:0] bdata_out;
   reg                 xstby;
   //reg                 rev;

   reg [12:0] 	       cnt_xstby;

   wire 	       pre_xstby;
   
   // Output FF
   always@(posedge clk or negedge xrst) begin
      if(~xrst) begin
	 vs_out <= 1'b1;
	 hs_out <= 1'b1;
	 de_out <= 1'b0;	 
     rdata_out <= 6'd0;
	 gdata_out <= 6'd0;
	 bdata_out <= 6'd0;
      end
      else begin
	 vs_out <= #P_DL ~vs_in;
	 hs_out <= #P_DL ~hs_in;
	 de_out <= #P_DL de_in;	 
     rdata_out <= #P_DL rdata_in;
	 gdata_out <= #P_DL gdata_in;
	 bdata_out <= #P_DL bdata_in;
      end // else: !if(~xrst)  
   end // always@ (posedge clk or negedge xrst)
   

   // xstby counter (for 1ms wait)
   always@(posedge clk or negedge xrst) begin
      if(~xrst)
	cnt_xstby <= 13'd0;
      else if(cnt_xstby >= 13'd6250)
	cnt_xstby <= #P_DL cnt_xstby;
      else
	cnt_xstby <= #P_DL cnt_xstby + 13'd1;
   end
   
   assign pre_xstby = (cnt_xstby == 13'd6249);

   // xstby counter (for 1ms wait)
   always@(posedge clk or negedge xrst) begin
      if(~xrst)
	xstby <= 1'b1;
      else if(pre_xstby)
	xstby <= #P_DL 1'b0;
   end

   // rev : 0 fix
   assign rev = 1'b0;
   
endmodule
   
