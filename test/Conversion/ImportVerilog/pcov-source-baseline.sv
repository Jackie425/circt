// RUN: circt-verilog --parse-only %s | FileCheck %s
// REQUIRES: slang

// CHECK-LABEL: moore.module @StatementSimple
module StatementSimple(input logic a, output logic y);
  // CHECK: moore.assign
  // CHECK-SAME: pcov.src.statement_id = 0
  // CHECK-SAME: pcov.src.statement_kind = "continuous_assign"
  assign y = a;
endmodule

// CHECK-LABEL: moore.module @StatementGenerate
module StatementGenerate(input logic [3:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 4; i++) begin : g
    // CHECK: moore.assign
    // CHECK-SAME: pcov.src.statement_kind = "continuous_assign"
    assign y[i] = a[i];
  end
endmodule

// CHECK-LABEL: moore.module @BranchIf
module BranchIf(input logic a, output logic y);
  always_comb begin
    // CHECK: cf.cond_br
    // CHECK-SAME: pcov.src.branch_alternatives = [{id = 0 : i32, name = "true"}, {id = 1 : i32, name = "false"}]
    // CHECK-SAME: pcov.src.branch_id = 0
    if (a) y = 1'b1; else y = 1'b0;
  end
endmodule

// CHECK-LABEL: moore.module @BranchCase
module BranchCase(input logic [1:0] s, output logic y);
  always_comb begin
    // CHECK: cf.cond_br
    // CHECK-SAME: pcov.src.branch_alternatives = [{id = 0 : i32, name = "case_item_0"}, {id = 1 : i32, name = "case_item_1"}, {id = 2 : i32, name = "default"}]
    // CHECK-SAME: pcov.src.branch_id = 0
    case (s)
      2'd0: y = 1'b0;
      2'd1, 2'd2: y = 1'b1;
      default: y = 1'b0;
    endcase
  end
endmodule

// CHECK-LABEL: moore.module @BranchConditional
module BranchConditional(input logic s, input logic a, input logic b, output logic y);
  // CHECK: moore.conditional
  // CHECK-SAME: pcov.src.branch_alternatives = [{id = 0 : i32, name = "true"}, {id = 1 : i32, name = "false"}]
  // CHECK-SAME: pcov.src.branch_kind = "conditional"
  // CHECK-SAME: pcov.src.false_alternative_id = 1
  // CHECK-SAME: pcov.src.true_alternative_id = 0
  assign y = s ? a : b;
endmodule
