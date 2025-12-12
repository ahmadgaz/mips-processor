module auxdec (
    input  wire [1:0] alu_op,
    input  wire [5:0] funct,
    output wire [2:0] alu_ctrl,    // Choose the ALU operation
    output wire [1:0] rf_awd_src,  // Register file write data source (auxillary)
    output wire       hilo_we,     // Write enable for hi/lo registers
    output wire       j_src        // Source of jump
);

  // -----------------------
  // Encodings
  // -----------------------

  // alu_ctrl encodings
  localparam logic ALUADD = 3'b010;
  localparam logic ALUSUB = 3'b110;
  localparam logic ALUAND = 3'b000;
  localparam logic ALUOR = 3'b001;
  localparam logic ALUSLT = 3'b111;
  localparam logic ALUSLL = 3'b100;
  localparam logic ALUSRL = 3'b101;

  // rf_awd_src encodings
  localparam logic RFAWDALU = 2'b00;
  localparam logic RFAWDHI = 2'b01;
  localparam logic RFAWDLO = 2'b10;

  // hilo_we encoding
  localparam logic HILOEN = 1'b1;

  // j_src encodings
  localparam logic JNEXTPC = 1'b0;
  localparam logic JREG = 1'b1;

  // -----------------------
  // Control bus
  // -----------------------
  reg [6:0] ctrl;
  assign {alu_ctrl, rf_awd_src, hilo_we, j_src} = ctrl;

  // -----------------------
  // Decode logic
  // -----------------------
  always_comb begin
    case (alu_op)

      2'b00:  // ADD
      ctrl = {ALUADD, RFAWDALU, !HILOEN, JNEXTPC};

      2'b01:  // SUB
      ctrl = {ALUSUB, RFAWDALU, !HILOEN, JNEXTPC};

      2'b10:  // FUNCT
      case (funct)

        6'b10_0000:  // ADD
        ctrl = {ALUADD, RFAWDALU, !HILOEN, JNEXTPC};

        6'b10_0010:  // SUB
        ctrl = {ALUSUB, RFAWDALU, !HILOEN, JNEXTPC};

        6'b10_0100:  // AND
        ctrl = {ALUAND, RFAWDALU, !HILOEN, JNEXTPC};

        6'b10_0101:  // OR
        ctrl = {ALUOR, RFAWDALU, !HILOEN, JNEXTPC};

        6'b10_1010:  // SLT
        ctrl = {ALUSLT, RFAWDALU, !HILOEN, JNEXTPC};

        6'b00_0000:  // SLL
        ctrl = {ALUSLL, RFAWDALU, !HILOEN, JNEXTPC};

        6'b00_0010:  // SRL
        ctrl = {ALUSRL, RFAWDALU, !HILOEN, JNEXTPC};

        6'b01_1001:  // MULTU
        ctrl = {ALUAND, RFAWDALU, HILOEN, JNEXTPC};

        6'b01_0000:  // MFHI
        ctrl = {ALUAND, RFAWDHI, !HILOEN, JNEXTPC};

        6'b01_0010:  // MFLO
        ctrl = {ALUAND, RFAWDLO, !HILOEN, JNEXTPC};

        6'b00_1000:  // JR
        ctrl = {ALUAND, RFAWDALU, !HILOEN, JREG};

        default: ctrl = 7'bxxx_xx_x_x;
      endcase

      default: ctrl = 7'bxxx_xx_x_x;
    endcase
  end
endmodule
