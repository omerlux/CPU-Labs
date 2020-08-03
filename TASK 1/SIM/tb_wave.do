onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/rst
add wave -noupdate /tb/ena
add wave -noupdate /tb/clk
add wave -noupdate /tb/cin
add wave -noupdate -radix unsigned /tb/A
add wave -noupdate -radix unsigned /tb/B
add wave -noupdate /tb/OPC
add wave -noupdate -radix unsigned /tb/RES
add wave -noupdate /tb/STATUS
add wave -noupdate /tb/gen
add wave -noupdate /tb/done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1199059 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {990763 ps} {2039339 ps}
