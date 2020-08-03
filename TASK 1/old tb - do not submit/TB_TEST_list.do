onerror {resume}
add list -width 14 /tb_test/rst
add list /tb_test/ena
add list /tb_test/clk
add list /tb_test/cin
add list /tb_test/A
add list /tb_test/B
add list /tb_test/OPC
add list /tb_test/RES
add list /tb_test/STATUS
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
