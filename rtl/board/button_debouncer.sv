module button_debouncer #(
    parameter int DEPTH = 16
) (
    input  wire clk,              /* 5 KHz clock */
    input  wire button,           /* Input button from constraints */
    output reg  debounced_button
);
  localparam int HISTMAX = (2 ** DEPTH) - 1;

  /* History of sampled input button */
  reg [DEPTH-1:0] history;
  always @(posedge clk) begin
    /* Move history back one sample and insert new sample */
    history <= {button, history[DEPTH-1:1]};
    /* Assert debounced button if it has been in a consistent state throughout history */
    debounced_button <= (history == HISTMAX) ? 1'b1 : 1'b0;
  end
endmodule

