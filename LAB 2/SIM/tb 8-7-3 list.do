onerror {resume}
add list -width 9 /tb/rst
add list /tb/ena
add list /tb/clk
add list /tb/din
add list /tb/cond
add list /tb/detector
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
