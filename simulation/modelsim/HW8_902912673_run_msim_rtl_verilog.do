transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/simpleFIFO.v}
vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_vga2pixel.v}
vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_transpose.v}
vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_top.v}
vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_pixel2vga.v}
vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_edge.v}
vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_shift_reg.v}

vlog -vlog01compat -work work +incdir+C:/Users/Mike/Documents/Quartus/ECE\ 8813/HW8_902912673 {C:/Users/Mike/Documents/Quartus/ECE 8813/HW8_902912673/hw6_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  hw6_tb

add wave *
view structure
view signals
run -all
