onerror {resume}
add list -width 20 /tb_condition/cond
add list /tb_condition/rise
add list /tb_condition/din_new
add list /tb_condition/din_old
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
