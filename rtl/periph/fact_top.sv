module fact_top (
    input clk,
    input rst,
    input [1:0] a,
    input we,
    input [3:0] wd,

    output [31:0] rd
);
  wire we2;
  wire we1;
  wire [1:0] rdsel;
  wire [31:0] n_curr;
  wire go_curr;
  wire go_pulse_curr;
  wire done_next, err_next;
  wire [31:0] nf_next;
  wire done_curr, err_curr;
  wire [31:0] nf_curr;
  wire we2_and_we0 = we2 & wd[0];

  fact_ad fact_ad (
      .a(a),
      .we(we),
      .we2(we2),
      .we1(we1),
      .rdsel(rdsel)
  );
  dreg #(32) n_reg (
      .d  ({28'b0, wd}),
      .en (we1),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .q  (n_curr)
  );
  dreg #(1) go_reg (
      .d  (wd[0]),
      .en (we2),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .q  (go_curr)
  );
  dreg #(1) go_pulse_reg (
      .d  (we2_and_we0),
      .en (1),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .q  (go_pulse_curr)
  );
  fact #(32) fact (
      .n(n_curr),
      .go(go_pulse_curr),
      .rst(rst),
      .clk(clk),
      .done(done_next),
      .err(err_next),
      .nf(nf_next)
  );
  dreg #(1) done_reg (
      .d  (done_next),
      .en (1),
      .rst(we2_and_we0),
      .clr(1'b0),
      .clk(clk),
      .q  (done_curr)
  );
  dreg #(1) err_reg (
      .d  (err_next),
      .en (1),
      .rst(we2_and_we0),
      .clr(1'b0),
      .clk(clk),
      .q  (err_curr)
  );
  dreg #(32) res_reg (
      .d  (nf_next),
      .en (done_next),
      .rst(rst),
      .clr(1'b0),
      .clk(clk),
      .q  (nf_curr)
  );
  mux4 #(32) rd_mux (
      .a  (n_curr),
      .b  ({31'b0, go_curr}),
      .c  ({30'b0, err_curr, done_curr}),
      .d  (nf_curr),
      .sel(rdsel),
      .y  (rd)
  );
endmodule
