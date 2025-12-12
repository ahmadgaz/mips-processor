module mips_ad (
    input  wire [31:0] a,
    input  wire        we,
    output reg         we1,
    output reg         we2,
    output reg         wem,
    output reg  [ 1:0] rdsel
);
  always_comb begin
    casez (a)
      32'h000000??: begin
        we1   = 1'b0;
        we2   = 1'b0;
        wem   = we;
        rdsel = 2'b00;
      end
      32'h000008??: begin
        we1   = we;
        we2   = 1'b0;
        wem   = 1'b0;
        rdsel = 2'b10;
      end
      32'h000009??: begin
        we1   = 1'b0;
        we2   = we;
        wem   = 1'b0;
        rdsel = 2'b11;
      end
      default: begin
        we1   = 1'bx;
        we2   = 1'bx;
        wem   = 1'bx;
        rdsel = 2'bxx;
      end
    endcase
  end
endmodule
