module maindec (
    input  wire [5:0] opcode,
    output wire       we_reg,
    output wire [1:0] reg_dst,  // Chooses which register to write to
    output wire       alu_src,  // Chooses input B for the ALU
    output wire       branch,
    output wire       we_dm,
    output wire [1:0] dm2reg,   // Chooses what data to write to register
    output wire       jump,
    output wire [1:0] alu_op
);

  // -----------------------
  // Encodings
  // -----------------------

  // reg_dst encodings
  localparam logic REGDSTRT = 2'b00;
  localparam logic REGDSTRD = 2'b01;
  localparam logic REGDSTRA = 2'b10;

  // dm2reg encodings
  localparam logic DM2REGALU = 2'b00;
  localparam logic DM2REGDM = 2'b01;
  localparam logic DM2REGPC4 = 2'b10;

  // alu_op encodings
  localparam logic ALUOPADD = 2'b00;
  localparam logic ALUOPSUB = 2'b01;
  localparam logic ALUOPFUNCT = 2'b10;

  // single-bit controls
  localparam logic WREGEN = 1'b1;
  localparam logic ALUSRCREG = 1'b0;
  localparam logic ALUSRCIMM = 1'b1;
  localparam logic BRANCHEN = 1'b1;
  localparam logic WDMEN = 1'b1;
  localparam logic JUMPEN = 1'b1;

  // -----------------------
  // Control bus
  // -----------------------
  reg [10:0] ctrl;
  assign {we_reg, reg_dst, alu_src, branch, we_dm, dm2reg, jump, alu_op} = ctrl;

  // -----------------------
  // Decode logic
  // -----------------------
  always_comb begin
    case (opcode)

      6'b00_0000:  // R-type
      ctrl = {WREGEN, REGDSTRD, ALUSRCREG, !BRANCHEN, !WDMEN, DM2REGALU, !JUMPEN, ALUOPFUNCT};

      6'b10_0011:  // LW
      ctrl = {WREGEN, REGDSTRT, ALUSRCIMM, !BRANCHEN, !WDMEN, DM2REGDM, !JUMPEN, ALUOPADD};

      6'b10_1011:  // SW
      ctrl = {!WREGEN, REGDSTRT, ALUSRCIMM, !BRANCHEN, WDMEN, DM2REGALU, !JUMPEN, ALUOPADD};

      6'b00_0100:  // BEQ
      ctrl = {!WREGEN, REGDSTRT, ALUSRCREG, BRANCHEN, !WDMEN, DM2REGALU, !JUMPEN, ALUOPSUB};

      6'b00_1000:  // ADDI
      ctrl = {WREGEN, REGDSTRT, ALUSRCIMM, !BRANCHEN, !WDMEN, DM2REGALU, !JUMPEN, ALUOPADD};

      6'b00_0010:  // J
      ctrl = {!WREGEN, REGDSTRT, ALUSRCREG, !BRANCHEN, !WDMEN, DM2REGALU, JUMPEN, ALUOPADD};

      6'b00_0011:  // JAL
      ctrl = {WREGEN, REGDSTRA, ALUSRCREG, !BRANCHEN, !WDMEN, DM2REGPC4, JUMPEN, ALUOPADD};

      default: ctrl = 11'bx_xx_x_x_x_xx_x_xx;
    endcase
  end
endmodule
