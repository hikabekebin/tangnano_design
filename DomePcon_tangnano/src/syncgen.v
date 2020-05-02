`timescale 1 ns / 1 ps
module syncgen(
	       clk,
	       xrst,
	       vs_out,
	       hs_out,
	       de_out
	       );

   // parameter
   parameter P_DL = 2;

   //parameter P_VTOTAL = 9'd262;
   parameter P_VTOTAL = 9'd291;
   parameter P_VWIDTH = 9'd3;
   parameter P_VBP = 9'd6;
   parameter P_VACT = 9'd196;

   //parameter P_HTOTAL = 10'd429;
   parameter P_HTOTAL = 10'd458;
   parameter P_HWIDTH = 10'd10;
   parameter P_HBP = 10'd42;
   parameter P_HACT = 10'd320;
   
   // input ports
   input clk;
   input xrst;
   
   // output ports
   output vs_out;
   output hs_out;
   output de_out;

   // Reg
   reg 	  vs_out;
   reg 	  hs_out;
   reg 	  de_out;

   reg [9:0] hcnt;
   reg [8:0] vcnt;

   reg pre_hs_d1;
   reg hde_d1;   
   
   // wire
   wire      hcnt_0;
   wire      pre_hs;
   wire      pre_hde;
   
	wire hde;
	wire pre_vs;
	wire vde;
	wire pre_de;
	
   
   //--------------------------------------
   // main
   //--------------------------------------

   // H counter
   always@(posedge clk or negedge xrst) begin
      if(~xrst)
	hcnt <= 10'd1023;
      else if(hcnt == P_HTOTAL)
	hcnt <= #P_DL 10'd0;
      else
	hcnt <= hcnt + 10'd1;
   end

   // hsync, hde
   assign hcnt_0 = (hcnt == 10'd0);
   assign pre_hs = (hcnt < P_HWIDTH);
   assign hde = (hcnt >= P_HBP && hcnt < P_HBP + P_HACT);
   
   // 1cycle Delay
   always@(posedge clk or negedge xrst) begin
      if(~xrst) begin
			pre_hs_d1 <= 1'b0;
			hde_d1 <= 1'b0;
      end
      else begin
			pre_hs_d1 <= #P_DL pre_hs;
			hde_d1 <= #P_DL hde;
      end
   end
      
   // V counter
   always@(posedge clk or negedge xrst) begin
      if(~xrst)
	vcnt <= 9'd511;
      else if(vcnt == P_VTOTAL)
	vcnt <= #P_DL 9'd0;
      else if(hcnt_0)
	vcnt <= vcnt + 10'd1;
   end

   // vsync, vde
   assign pre_vs = (vcnt < P_VWIDTH);
   assign vde = (vcnt >= P_VBP && vcnt < P_VBP + P_VACT);
   
   // de
   assign pre_de = vde & hde_d1;
   
   // Output FF
   always@(posedge clk or negedge xrst) begin
      if(~xrst) begin
	 vs_out <= 1'b0;
	 hs_out <= 1'b0;
	 de_out <= 1'b0;
      end
      else begin
	 vs_out <= #P_DL pre_vs;
	 hs_out <= #P_DL pre_hs_d1;
	 de_out <= #P_DL pre_de;
      end
   end

endmodule // syncgen

