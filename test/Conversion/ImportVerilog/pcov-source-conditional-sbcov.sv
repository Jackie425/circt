// RUN: circt-verilog --parse-only %s | FileCheck %s
// REQUIRES: slang

// CHECK-LABEL: moore.module @TernarySbcovFilter
// CHECK-COUNT-4: pcov.src.branch_kind = "conditional"
// CHECK-NOT: pcov.src.branch_kind = "conditional"
module TernarySbcovFilter #(
  parameter bit USE_A = 1'b1,
  parameter int WIDTH = 4
) (
  input logic s,
  input logic t,
  input logic a,
  input logic b,
  input logic c,
  input logic [3:0] ga,
  input logic [3:0] gb,
  output logic y_cont,
  output logic y_param,
  output logic y_width,
  output logic y_proc,
  output logic y_nested,
  output logic y_func,
  output logic [3:0] y_gen
);
  function automatic logic pick_func(input logic q, input logic x, input logic z);
    pick_func = q ? x : z;
  endfunction

  assign y_cont = s ? a : b;
  assign y_param = USE_A ? a : b;
  assign y_width = (WIDTH == 4) ? a : b;
  assign y_func = pick_func(s, a, b);

  always_comb begin
    y_proc = s ? a : b;
    y_nested = s ? (t ? a : b) : c;
  end

  for (genvar i = 0; i < 4; i++) begin : gen_mux
    assign y_gen[i] = s ? ga[i] : gb[i];
  end
endmodule
