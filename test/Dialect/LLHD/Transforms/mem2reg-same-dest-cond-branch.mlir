// RUN: circt-opt --llhd-mem2reg %s | FileCheck %s

func.func private @use_i42(%arg0: i42)

// CHECK-LABEL: hw.module @SameDestCondBranch
hw.module @SameDestCondBranch(in %u: i42, in %v: i42, in %sel: i1, in %dup: i1) {
  %time = llhd.constant_time <0ns, 0d, 1e>
  %sig = llhd.sig %u : i42
  llhd.process {
    cf.cond_br %sel, ^bb1, ^bb2
  ^bb1:
    // CHECK-NOT: llhd.drv
    llhd.drv %sig, %u after %time : i42
    // CHECK: cf.br ^bb3(%u : i42)
    cf.br ^bb3
  ^bb2:
    // CHECK-NOT: llhd.drv
    llhd.drv %sig, %v after %time : i42
    // CHECK: cf.cond_br %dup, ^bb3(%v : i42), ^bb3(%v : i42)
    cf.cond_br %dup, ^bb3, ^bb3
  ^bb3:
    // CHECK: ^bb3([[VALUE:%.+]]: i42):
    // CHECK-NOT: llhd.prb
    %prb = llhd.prb %sig : i42
    // CHECK: func.call @use_i42([[VALUE]])
    func.call @use_i42(%prb) : (i42) -> ()
    llhd.halt
  }
}
