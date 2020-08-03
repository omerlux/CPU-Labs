onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sync_delay/rst
add wave -noupdate /tb_sync_delay/ena
add wave -noupdate /tb_sync_delay/clk
add wave -noupdate -radix unsigned /tb_sync_delay/din
add wave -noupdate -radix unsigned /tb_sync_delay/dout_new
add wave -noupdate -radix unsigned /tb_sync_delay/dout_old
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {681722 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {409033 ps} {1403434 ps}
