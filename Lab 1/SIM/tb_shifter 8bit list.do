onerror {resume}
add list -width 17 /tb_shifter/cin
add list /tb_shifter/sel
add list /tb_shifter/X
add list /tb_shifter/Y
add list /tb_shifter/s
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
