// RUN: circt-verilog --parse-only --always-at-star-as-comb=0 %s | FileCheck %s --check-prefixes=CHECK,CHECK-STAR
// RUN: circt-verilog --parse-only --always-at-star-as-comb=1 %s | FileCheck %s --check-prefixes=CHECK,CHECK-COMB
// REQUIRES: slang

// Internal issue in Slang v3 about jump depending on uninitialised value.
// UNSUPPORTED: valgrind

// CHECK-LABEL: moore.module @Foo()
module Foo;
  // CHECK:      moore.procedure initial attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-NEXT:   func.call @foo
  // CHECK-NEXT:   moore.return
  // CHECK-NEXT: }
  initial foo();

  // CHECK:      moore.procedure final attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-NEXT:   func.call @foo
  // CHECK-NEXT:   moore.return
  // CHECK-NEXT: }
  final foo();

  // CHECK:      moore.procedure always attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-NEXT:   func.call @foo
  // CHECK-NEXT:   moore.return
  // CHECK-NEXT: }
  always foo();

  // CHECK:      moore.procedure always_comb attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-NEXT:   func.call @foo
  // CHECK-NEXT:   moore.return
  // CHECK-NEXT: }
  always_comb foo();

  // CHECK:      moore.procedure always_latch attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-NEXT:   func.call @foo
  // CHECK-NEXT:   moore.return
  // CHECK-NEXT: }
  always_latch foo();

  // CHECK:      moore.procedure always_ff attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-NEXT:   moore.wait_event {
  // CHECK-NEXT:   }
  // CHECK-NEXT:   func.call @foo
  // CHECK-NEXT:   moore.return
  // CHECK-NEXT: }
  always_ff @* foo();

  // CHECK-STAR:      moore.procedure always attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-STAR-NEXT:   moore.wait_event {
  // CHECK-STAR-NEXT:   }
  // CHECK-STAR-NEXT:   func.call @foo
  // CHECK-STAR-NEXT:   moore.return
  // CHECK-STAR-NEXT: }
  // CHECK-COMB:      moore.procedure always_comb attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK-COMB-NEXT:   func.call @foo
  // CHECK-COMB-NEXT:   moore.return
  // CHECK-COMB-NEXT: }
  always @* foo();
endmodule

function void foo();
endfunction

// CHECK-LABEL: moore.module @SourceRegionNoControl()
module SourceRegionNoControl;
  logic a, b;
  // CHECK: moore.procedure initial attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK: moore.return
  initial b = a;
endmodule

// CHECK-LABEL: moore.module @SourceRegionIfControl()
module SourceRegionIfControl;
  logic a, b;
  // CHECK: moore.procedure initial attributes {pcov.src.regions =
  // CHECK: cf.cond_br {{.*}} {pcov.src.control_id = 0 : i32, pcov.src.region_id = 0 : i32}
  initial if (a) b = 1; else b = 0;
endmodule

// CHECK-LABEL: moore.module @SourceRegionFunctionOnly()
module SourceRegionFunctionOnly;
  logic a, b;
  // CHECK: moore.procedure initial attributes {pcov.src.regions = [{id = 0 : i32}]} {
  // CHECK: func.call @source_region_function_only
  // CHECK-NEXT: moore.blocking_assign
  // CHECK-NEXT: moore.return
  initial b = source_region_function_only(a);
endmodule

function logic source_region_function_only(logic a);
  if (a)
    source_region_function_only = 1;
  else
    source_region_function_only = 0;
endfunction
