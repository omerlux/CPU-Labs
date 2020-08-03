onerror {resume}
add list -width 9 /tb/rst
add list /tb/ena
add list /tb/clk
add list /tb/cin
add list /tb/A
add list /tb/B
add list /tb/OPC
add list /tb/RES
add list /tb/STATUS
add list /tb/gen
add list /tb/done
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
