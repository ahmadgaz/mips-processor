module fact_dp #(
    parameter int WIDTH = 32
) (
    input clk,
    input load_cnt,
    input en,
    input sel_1,
    input load_reg,
    input sel_2,
    input [WIDTH-1:0] n,
    output gt_in,
    output gt_fact,
    output [WIDTH-1:0] nf
);
  wire [WIDTH-1:0] n_internal;
  wire [WIDTH-1:0] curr_prod;
  wire [WIDTH-1:0] mul_prod;
  wire [WIDTH-1:0] next_prod;
  assign gt_in = n > 12;
  assign gt_fact = n_internal > 1;
  assign mul_prod = curr_prod * n_internal;
  assign next_prod = (sel_1) ? mul_prod : 1;
  assign nf = (sel_2) ? curr_prod : 0;
  down_cnt #(
      .WIDTH(WIDTH)
  ) cnt (
      .clk(clk),
      .en(en),
      .load_cnt(load_cnt),
      .d(n),
      .q(n_internal)
  );
  dreg #(
      .WIDTH(WIDTH)
  ) register (
      .clk(clk),
      .rst(0),
      .en (load_reg),
      .d  (next_prod),
      .q  (curr_prod)
  );
endmodule
