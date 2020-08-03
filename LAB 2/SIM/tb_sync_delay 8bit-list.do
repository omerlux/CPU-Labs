onerror {resume}
add list -width 20 /tb_sync_delay/rst
add list /tb_sync_delay/ena
add list /tb_sync_delay/clk
add list /tb_sync_delay/din
add list /tb_sync_delay/dout_new
add list /tb_sync_delay/dout_old
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
