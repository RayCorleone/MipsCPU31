proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param simulator.modelsimInstallPath D:/Modeltech_pe_10.4c/win32pe
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir D:/Ray/Vivado/CPU31/CPU31.cache/wt [current_project]
  set_property parent.project_path D:/Ray/Vivado/CPU31/CPU31.xpr [current_project]
  set_property ip_repo_paths d:/Ray/Vivado/CPU31/CPU31.cache/ip [current_project]
  set_property ip_output_repo d:/Ray/Vivado/CPU31/CPU31.cache/ip [current_project]
  add_files -quiet D:/Ray/Vivado/CPU31/CPU31.runs/synth_1/onBoard.dcp
  add_files -quiet D:/Ray/Vivado/CPU31/CPU31.srcs/sources_1/ip/imem/imem.dcp
  set_property netlist_only true [get_files D:/Ray/Vivado/CPU31/CPU31.srcs/sources_1/ip/imem/imem.dcp]
  read_xdc -mode out_of_context -ref imem -cells U0 d:/Ray/Vivado/CPU31/CPU31.srcs/sources_1/ip/imem/imem_ooc.xdc
  set_property processing_order EARLY [get_files d:/Ray/Vivado/CPU31/CPU31.srcs/sources_1/ip/imem/imem_ooc.xdc]
  read_xdc D:/Ray/Vivado/CPU31/CPU31.srcs/constrs_1/new/xdc.xdc
  link_design -top onBoard -part xc7a100tcsg324-1
  write_hwdef -file onBoard.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force onBoard_opt.dcp
  report_drc -file onBoard_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force onBoard_placed.dcp
  report_io -file onBoard_io_placed.rpt
  report_utilization -file onBoard_utilization_placed.rpt -pb onBoard_utilization_placed.pb
  report_control_sets -verbose -file onBoard_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force onBoard_routed.dcp
  report_drc -file onBoard_drc_routed.rpt -pb onBoard_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file onBoard_timing_summary_routed.rpt -rpx onBoard_timing_summary_routed.rpx
  report_power -file onBoard_power_routed.rpt -pb onBoard_power_summary_routed.pb -rpx onBoard_power_routed.rpx
  report_route_status -file onBoard_route_status.rpt -pb onBoard_route_status.pb
  report_clock_utilization -file onBoard_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force onBoard.mmi }
  write_bitstream -force onBoard.bit 
  catch { write_sysdef -hwdef onBoard.hwdef -bitfile onBoard.bit -meminfo onBoard.mmi -file onBoard.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

