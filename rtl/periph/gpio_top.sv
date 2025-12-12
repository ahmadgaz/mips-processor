module gpio_top (
    input clk,
    input rst,
    input [1:0] a,
    input we,
    input [31:0] wd,
    input [31:0] gpi1,
    input [31:0] gpi2,

    output [31:0] rd,
    output [31:0] gpo1,
    output [31:0] gpo2
);
  wire we2;
  wire we1;
  wire [1:0] rdsel;

  gpio_ad gpio_ad (
      .a(a),
      .we(we),
      .we2(we2),
      .we1(we1),
      .rdsel(rdsel)
  );
  dreg #(32) gpo1_reg (
      .d  (wd),
      .en (we1),
      .rst(rst),
      .clk(clk),
      .q  (gpo1)
  );
  dreg #(32) gpo2_reg (
      .d  (wd),
      .en (we2),
      .rst(rst),
      .clk(clk),
      .q  (gpo2)
  );
  mux4 #(32) rd_mux (
      .a  (gpi1),
      .b  (gpi2),
      .c  (gpo1),
      .d  (gpo2),
      .sel(rdsel),
      .y  (rd)
  );
endmodule
