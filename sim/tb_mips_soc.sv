`timescale 1ns / 1ps

module tb_mips_soc;
  logic clk;
  logic rst;

  initial begin
    clk = 1'b0;
    rst = 1'b0;
  end

  always #5 clk = ~clk;




  // ----------------------------
  // DUT
  // ----------------------------
  logic [4:0] ra3;
  logic [31:0] gpi1;
  wire [31:0] rd3;
  wire [31:0] gpo1, gpo2;

  wire [31:0] pc_current, instr, alu_out, wd_dm, rd_dm;
  wire we_dm;

  mips_soc dut (
      .clk       (clk),
      .rst       (rst),
      .ra3       (ra3),
      .gpi1      (gpi1),
      .gpi2      (gpo1),
      .pc_current(pc_current),
      .instr     (instr),
      .alu_out   (alu_out),
      .wd_dm     (wd_dm),
      .rd_dm     (rd_dm),
      .gpo1      (gpo1),
      .gpo2      (gpo2),
      .rd3       (rd3),
      .we_dm     (we_dm)
  );




  // ----------------------------
  // Config
  // ----------------------------

  // Plusargs
  logic  [31:0] HALT_PC = 32'h0000_0100;
  int           TIMEOUT_CYCLES = 2000;
  int           VERBOSE = 0;
  int           WAVES = 0;
  string        expect_file;

  // Expected register checks
  logic  [31:0] exp_reg                 [32];
  bit           exp_reg_valid           [32];




  // ----------------------------
  // Utilities
  // ----------------------------

  // Reset
  task automatic reset_dut();
    rst = 1'b1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
  endtask

  // Execution loop
  task automatic run_until_halt();
    int cycles = 0;

    while (pc_current !== HALT_PC) begin
      @(posedge clk);
      cycles++;

      if (VERBOSE != 0) begin
        $display("C%0d T%0t: pc=%h instr=%h alu=%h we_dm=%b wd=%h rd=%h gpo1=%h gpo2=%h", cycles,
                 $time, pc_current, instr, alu_out, we_dm, wd_dm, rd_dm, gpo1, gpo2);
      end

      if (!rst && (^pc_current === 1'bx)) $fatal(1, "PC went X at time %0t", $time);
      if (cycles > TIMEOUT_CYCLES)
        $fatal(1, "TIMEOUT at pc=%h after %0d cycles", pc_current, cycles);
    end

    $display("[TB] Reached HALT_PC=%h at time %0t", HALT_PC, $time);
  endtask

  // Check given register
  task automatic check_reg(input int r, input logic [31:0] expected);
    ra3 = r[4:0];
    #1;  // Allow read to settle
    if (rd3 !== expected) begin
      $fatal(1, "REG FAIL r%0d got=%h expected=%h", r, rd3, expected);
    end
  endtask

  // Check every register
  task automatic check_all_expected_regs();
    for (int r = 0; r < 32; r++) begin
      if (exp_reg_valid[r]) begin
        check_reg(r, exp_reg[r]);
      end
    end
  endtask

  // Simple expectations file parser
  // Example lines:
  //   HALT_PC 0x00000100
  //   TIMEOUT 2000
  //   REG 2 0x00000005
  //   REG 31 0xDEADBEEF
  task automatic load_expectations(input string fname);
    int fd;
    string line;
    string key;
    logic [31:0] val;

    int r;
    int tmo;
    logic [31:0] haltpc;

    // Clear
    for (int i = 0; i < 32; i++) begin
      exp_reg_valid[i] = 0;
      exp_reg[i]       = '0;
    end

    fd = $fopen(fname, "r");
    if (fd == 0) $fatal(1, "Could not open EXPECT file: %s", fname);

    while (!$feof(
        fd
    )) begin
      line = "";
      void'($fgets(line, fd));

      // Skip empty/comments
      if (line.len() == 0) continue;
      if (line.substr(0, 0) == "#") continue;

      // HALT_PC <hex>
      if ($sscanf(line, "HALT_PC %h", haltpc) == 1) begin
        HALT_PC = haltpc;
        continue;
      end

      // TIMEOUT <num>
      if ($sscanf(line, "TIMEOUT %d", tmo) == 1) begin
        TIMEOUT_CYCLES = tmo;
        continue;
      end

      // REG <num> <hex>
      if ($sscanf(line, "REG %d %h", r, val) == 2) begin
        if (r < 0 || r > 31) $fatal(1, "Bad reg index in EXPECT: %0d", r);
        exp_reg_valid[r] = 1;
        exp_reg[r]       = val;
        continue;
      end
    end

    $fclose(fd);
    $display("[TB] Loaded expectations from %s", fname);
  endtask




  // ----------------------------
  // Test flow
  // ----------------------------
  initial begin
    // Defaults
    ra3  = 5'd0;
    gpi1 = 32'd3;

    // Plusargs
    void'($value$plusargs("HALT_PC=%h", HALT_PC));
    void'($value$plusargs("TIMEOUT=%d", TIMEOUT_CYCLES));
    void'($value$plusargs("VERBOSE=%d", VERBOSE));
    void'($value$plusargs("WAVES=%d", WAVES));
    if ($value$plusargs("EXPECT=%s", expect_file)) begin
      load_expectations(expect_file);
    end else begin
      // No reg checks
      $display("[TB] No +EXPECT=... provided; will only run-to-halt and PASS.");
    end

    if (WAVES != 0) begin
      $dumpfile("tb_mips_soc.vcd");
      $dumpvars(0, tb_mips_soc);
    end

    reset_dut();
    run_until_halt();
    repeat (5) @(posedge clk);  // Let pipeline drain / WB commit
    check_all_expected_regs();

    $display("[TB] PASS");
    $finish;
  end
endmodule
