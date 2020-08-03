onerror {resume}
add list -width 19 /tb_adder_sub/cin
add list /tb_adder_sub/sel
add list /tb_adder_sub/X
add list /tb_adder_sub/Y
add list /tb_adder_sub/s
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
