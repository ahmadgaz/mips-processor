module fact_cu (
    input clk,
    input rst,
    input go,
    input gt_in,
    input gt_fact,
    output reg load_cnt,
    output reg en,
    output reg sel_1,
    output reg load_reg,
    output reg sel_2,
    output reg done,
    output reg error
);
  localparam logic [2:0]
    S0 = 3'd0,
    S1 = 3'd1,
    S2 = 3'd2,
    S3 = 3'd3,
    S4 = 3'd4;
  reg [2:0] cs, ns;

  always @(posedge clk) begin
    if (rst) cs <= S0;
    else cs <= ns;
  end

  always_comb begin
    ns = cs;
    load_cnt = 1'b0;
    en = 1'b0;
    sel_1 = 1'b0;
    load_reg = 1'b0;
    sel_2 = 1'b0;
    done = 1'b0;
    error = 1'b0;

    case (cs)
      S0: begin
        if (!go) begin
          ns = S0;
          done = 1'b1;
          sel_2 = 1'b1;
        end else if (gt_in) begin
          ns = S0;
          done = 1'b1;
          error = 1'b1;
        end else begin
          ns = S1;
          load_cnt = 1'b1;
          load_reg = 1'b1;
        end
      end
      S1: begin
        ns = S2;
        sel_1 = 1'b1;
        load_reg = 1'b1;
      end
      S2: begin
        if (gt_fact) begin
          ns = S4;
          en = 1'b1;
          sel_1 = 1'b1;
        end else begin
          ns   = S3;
          done = 1'b1;
        end
      end
      S3: begin
        ns = S0;
        sel_2 = 1'b1;
        done = 1'b1;
      end
      S4: begin
        ns = S2;
        sel_1 = 1'b1;
        load_reg = 1'b1;
      end
      default: ns = S0;
    endcase
  end
endmodule
