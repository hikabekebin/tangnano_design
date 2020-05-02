`timescale 1 ns / 1 ps
module DomePcon (
		 clk_24,
		 xrst,
		 clk_out,
		 vs_out,
		 hs_out,
		 de_out,
		 rdata_out,
		 gdata_out,
		 bdata_out,
		 xstby,
		 rev
		 );

	parameter P_DAT_BIT = 6;
		 
   input                  clk_24;
   input                  xrst;

   output                 clk_out;
   output 		  vs_out;
   output                 hs_out;
   output                 de_out;
   output [P_DAT_BIT-1:0] rdata_out;
   output [P_DAT_BIT-1:0] gdata_out;
   output [P_DAT_BIT-1:0] bdata_out;
   output 		  xstby;
   output 		  rev;

   wire 		  clk_pix;

   wire                   syncgen_vs;
   wire                   syncgen_hs;
   wire                   syncgen_de;   

   wire                   pgen_vs;
   wire                   pgen_hs;
   wire                   pgen_de;   
   wire [P_DAT_BIT-1:0]   pgen_rdata;
   wire [P_DAT_BIT-1:0]   pgen_gdata;
   wire [P_DAT_BIT-1:0]   pgen_bdata;   
   
   // PLL 24MHz -> 8MHz
    pll_clkpix pll_pix(
        .clkout(clk_pix), //output clkout
        .clkin(clk_24) //input clkin
    );

   assign clk_out = clk_pix;
   
   // syncgen
   syncgen syncgen (
		    .clk   (clk_pix),
		    .xrst  (xrst),
		    .vs_out(syncgen_vs),
		    .hs_out(syncgen_hs),
		    .de_out(syncgen_de)
		    );

   // pgen
   pgen pgen (
	      .clk      (clk_pix),
	      .xrst     (xrst),
	      .vs_in    (syncgen_vs),
	      .hs_in    (syncgen_hs),
	      .de_in    (syncgen_de),
	      .vs_out   (pgen_vs),
	      .hs_out   (pgen_hs),
	      .de_out   (pgen_de),
	      .rdata_out(pgen_rdata),
	      .gdata_out(pgen_gdata),
	      .bdata_out(pgen_bdata)
	      );

   // tg
   tg tg (
	  .clk       (clk_pix),
	  .xrst      (xrst),
	  .vs_in     (pgen_vs),
	  .hs_in     (pgen_hs),
	  .de_in     (pgen_de),
	  .rdata_in  (pgen_rdata),
	  .gdata_in  (pgen_gdata),
	  .bdata_in  (pgen_bdata),
	  .vs_out    (vs_out),
	  .hs_out    (hs_out),
	  .de_out    (de_out),
	  .rdata_out (rdata_out),
	  .gdata_out (gdata_out),
	  .bdata_out (bdata_out),
	  .xstby     (xstby),
	  .rev       (rev)
	  );

endmodule // DomePcon
