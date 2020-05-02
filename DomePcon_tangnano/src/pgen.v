`timescale 1 ns / 1 ps
module pgen(
	    clk,
	    xrst,
	    vs_in,
	    hs_in,
	    de_in,
	    vs_out,
	    hs_out,
	    de_out,
	    rdata_out,
	    gdata_out,
	    bdata_out
	    );

   parameter P_DAT_BIT = 6;
   parameter P_DL = 2;
   
   input                  clk;
   input 		  xrst;
   
   input 		  vs_in;
   input 		  hs_in;
   input                  de_in;

   output                 vs_out;
   output                 hs_out;
   output                 de_out;
   output [P_DAT_BIT-1:0] rdata_out;
   output [P_DAT_BIT-1:0] gdata_out;
   output [P_DAT_BIT-1:0] bdata_out;
   
   reg [8:0] 	vdecnt; // 0~239H
   reg [8:0] 	hdecnt; // 0~319clk

   reg 		vs_d1, hs_d1, de_d1;
 
	reg [3:0] color_state;
	
   wire 	vs_r;
   wire 	hs_r;
   wire 	de_f;

   reg [P_DAT_BIT*3-1:0] pre_data_out;

	reg       vs_out;
	reg       hs_out;
	reg       de_out;
   reg [P_DAT_BIT-1:0] rdata_out;
   reg [P_DAT_BIT-1:0] gdata_out;
   reg [P_DAT_BIT-1:0] bdata_out;

	
   //--------------------------------------
   // main
   //--------------------------------------

   // Rise/Fall edge
   always@(posedge clk or negedge xrst) begin
      if(~xrst) begin
	 vs_d1 <= 1'b0;
	 hs_d1 <= 1'b0;
	 de_d1 <= 1'b0;
      end
      else begin
	 vs_d1 <= #P_DL vs_in;
	 hs_d1 <= #P_DL hs_in;
	 de_d1 <= #P_DL de_in;
      end
   end

   assign vs_r = vs_in & ~vs_d1;
   assign hs_r = hs_in & ~hs_d1;   
   assign de_f = ~de_in & de_d1;
   
   // vdecnt
   always@(posedge clk or negedge xrst) begin
      if(~xrst)
	vdecnt <= 9'd0;
      else if(vs_r)
	vdecnt <= #P_DL 9'd0;
      else if(de_f)
	vdecnt <= #P_DL vdecnt + 9'd1;	
   end
   
   // hdecnt
   always@(posedge clk or negedge xrst) begin
      if(~xrst)
	hdecnt <= 9'd0;
      else if(hs_r)
	hdecnt <= #P_DL 9'd0;
      else if(de_in)
	hdecnt <= #P_DL hdecnt + 9'd1;	
   end

   //--------------------------------------
   // H Color bar
   //--------------------------------------

   // color state
   always@(posedge clk or negedge xrst) begin
      if(~xrst)
	color_state <= 4'd0;
      else if(hs_r)
	color_state <= #P_DL 4'd0; // dummy
      else if(hdecnt == 9'd61)
	color_state <= #P_DL 4'd1; // white
      else if(hdecnt == 9'd85)
	color_state <= #P_DL 4'd2; // yellow
      else if(hdecnt == 9'd109)
	color_state <= #P_DL 4'd3; // cyan
      else if(hdecnt == 9'd133)
	color_state <= #P_DL 4'd4; // green
      else if(hdecnt == 9'd157)
	color_state <= #P_DL 4'd5; // magenta
      else if(hdecnt == 9'd181)
	color_state <= #P_DL 4'd6; // red
      else if(hdecnt == 9'd205)
	color_state <= #P_DL 4'd7; // blue
      else if(hdecnt == 9'd229)
	color_state <= #P_DL 4'd8; // black
      else if(hdecnt == 9'd257)
	color_state <= #P_DL 4'd9; // dummy
      else
	color_state <= #P_DL color_state; // keep
   end
   
   // color select
   always@(*) begin
      case(color_state)
	 4'd0: pre_data_out = {6'd0,  6'd0,  6'd0 }; // dummy
	 4'd1: pre_data_out = {6'd63, 6'd63, 6'd63}; // White
	 4'd2: pre_data_out = {6'd63, 6'd63, 6'd0 }; // Yellow
	 4'd3: pre_data_out = {6'd0,  6'd63, 6'd63}; // Cyan
	 4'd4: pre_data_out = {6'd0,  6'd63, 6'd0 }; // Green
	 4'd5: pre_data_out = {6'd63, 6'd0,  6'd63}; // Magenta
	 4'd6: pre_data_out = {6'd63, 6'd0,  6'd0 }; // Red
	 4'd7: pre_data_out = {6'd0,  6'd0,  6'd63}; // Blue
	 4'd8: pre_data_out = {6'd0,  6'd0,  6'd0 }; // Black
	 4'd9: pre_data_out = {6'd0,  6'd0,  6'd0 }; // Dummy
	 default: pre_data_out = 18'hxxxxx;
      endcase // case (color_state)
   end
   
   // Output FF
   always@(posedge clk or negedge xrst) begin
      if(~xrst) begin
	 vs_out <= 1'b0;
	 hs_out <= 1'b0;
	 de_out <= 1'b0;	 
	 rdata_out <= 6'd0;
	 gdata_out <= 6'd0;
	 bdata_out <= 6'd0;	 
      end
      else begin
	 vs_out <= #P_DL vs_d1;
	 hs_out <= #P_DL hs_d1;
	 de_out <= #P_DL de_d1;
	 rdata_out <= #P_DL pre_data_out[17:12];
	 gdata_out <= #P_DL pre_data_out[11:6];
	 bdata_out <= #P_DL pre_data_out[5:0];	 
      end
   end
   
	 
endmodule // pgen

