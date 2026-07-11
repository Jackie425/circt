// RUN: not circt-verilog %s -o /dev/null 2>&1 \
// RUN:   | FileCheck %s --check-prefix=NO-FORMAT
// RUN: circt-verilog --translate-off-format=pragma,translate_off,translate_on %s \
// RUN:   | FileCheck %s --check-prefix=PRAGMA \
// RUN:       --implicit-check-not=PragmaSentinel
// RUN: circt-verilog --translate-off-format=pragma,translate_off,translate_on \
// RUN:   --translate-off-format=synthesis,translate_off,translate_on %s \
// RUN:   | FileCheck %s --check-prefix=BOTH \
// RUN:       --implicit-check-not=PragmaSentinel \
// RUN:       --implicit-check-not=SynthesisSentinel
// REQUIRES: slang

// NO-FORMAT: error:
// PRAGMA-DAG: hw.module @AlwaysPresent
// PRAGMA-DAG: hw.module @SynthesisSentinel
// BOTH: hw.module @AlwaysPresent

module AlwaysPresent;
endmodule

// pragma translate_off
this is deliberately not legal SystemVerilog !!!
module PragmaSentinel;
endmodule
// pragma translate_on

// synthesis translate_off
module SynthesisSentinel;
endmodule
// synthesis translate_on
