module fact #(
    parameter int WIDTH = 32
) (
    input clk,
    input rst,
    input [WIDTH-1:0] n,
    input go,

    output done,
    output err,
    output [WIDTH-1:0] nf
);
  wire load_cnt;
  wire en;
  wire sel_1;
  wire load_reg;
  wire sel_2;
  wire gt_in;
  wire gt_fact;

  fact_cu cu (
      .clk(clk),
      .rst(rst),
      .go(go),
      .gt_in(gt_in),
      .gt_fact(gt_fact),
      .load_cnt(load_cnt),
      .en(en),
      .sel_1(sel_1),
      .load_reg(load_reg),
      .sel_2(sel_2),
      .done(done),
      .error(err)
  );

  fact_dp #(
      .WIDTH(WIDTH)
  ) dp (
      .clk(clk),
      .load_cnt(load_cnt),
      .en(en),
      .sel_1(sel_1),
      .load_reg(load_reg),
      .sel_2(sel_2),
      .n(n),
      .gt_in(gt_in),
      .gt_fact(gt_fact),
      .nf(nf)
  );
endmodule
