onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_test/rst
add wave -noupdate /tb_test/ena
add wave -noupdate /tb_test/clk
add wave -noupdate /tb_test/cin
add wave -noupdate /tb_test/A
add wave -noupdate /tb_test/B
add wave -noupdate /tb_test/OPC
add wave -noupdate -radix binary /tb_test/RES
add wave -noupdate /tb_test/STATUS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2548979 ps} 0}
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
WaveRestoreZoom {2304 ns} {3328 ns}
