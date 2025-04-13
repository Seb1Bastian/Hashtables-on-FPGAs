proc measure_design {KEY_WIDTH DATA_WIDTH HASH_ADR_WIDTH NUMBER_OF_TABLES BUCKET_SIZE EXPORT_DIRECTORY_PATH} {
    open_bd_design {<YOUR_BLOCK_DESIGN_FILE_PATH>}

    startgroup
    set_property -dict [list \
    CONFIG.HASH_ADR_WIDTH [expr {$HASH_ADR_WIDTH}] \
    CONFIG.KEY_WIDTH [expr {$KEY_WIDTH}] \
    CONFIG.NUMBER_OF_TABLES [expr {$NUMBER_OF_TABLES}] \
    ] [get_bd_cells matrix_wrapper_0]
    endgroup

    startgroup
    set_property -dict [list \
    CONFIG.DATA_WIDTH [expr {$DATA_WIDTH}] \
    CONFIG.HASH_TABLE_MAX_SIZE [expr {$HASH_ADR_WIDTH}] \
    CONFIG.NUMBER_OF_TABLES [expr {$NUMBER_OF_TABLES}] \
    CONFIG.BUCKET_SIZE [expr {$BUCKET_SIZE}] \
    CONFIG.CAM_SIZE [expr {$CAM_SIZE}] \
    ] [get_bd_cells axi_wrapper_0]
    endgroup

    save_bd_design
    close_bd_design [get_bd_designs design_1]

    #reset_run design_1_xbar_1_synth_1
    #reset_run design_1_xbar_0_synth_1
    #reset_run synth_1
    #reset_runs impl_1
    reset_project
    after 10000
    
    launch_runs synth_1 -jobs 8
    wait_on_run synth_1
    #get_properties STATUS [get_runs synth_1]
    launch_runs impl_1 -jobs 8
    wait_on_run impl_1
    #get_properties STATUS [get_runs impl_1]

    set t_path [expr {$EXPORT_DIRECTORY_PATH}]timing_summary_K[expr {$KEY_WIDTH}]_D[expr {$DATA_WIDTH}]_N[expr {$NUMBER_OF_TABLES}]_H[expr {$HASH_ADR_WIDTH}]_B[expr {$BUCKET_SIZE}]_C[expr {$CAM_SIZE}].txt
    set p_path [expr {$EXPORT_DIRECTORY_PATH}]power_report_K[expr {$KEY_WIDTH}]_D[expr {$DATA_WIDTH}]_N[expr {$NUMBER_OF_TABLES}]_H[expr {$HASH_ADR_WIDTH}]_B[expr {$BUCKET_SIZE}]_C[expr {$CAM_SIZE}].txt
    set r_path [expr {$EXPORT_DIRECTORY_PATH}]hierarchical_utilization_K[expr {$KEY_WIDTH}]_D[expr {$DATA_WIDTH}]_N[expr {$NUMBER_OF_TABLES}]_H[expr {$HASH_ADR_WIDTH}]_B[expr {$BUCKET_SIZE}]_C[expr {$CAM_SIZE}].rpt

    open_run impl_1
    report_timing_summary -file [expr {$t_path}]
    report_power -file [expr {$p_path}]
    report_utilization -hierarchical -file [expr {$r_path}]
    close_design

}



set NUMBER_OF_TABLES 8
set BUCKET_SIZE 1
set HASH_ADR_WIDTH 11
set KEY_WIDTH 32
set DATA_WIDTH 32
set CAM_SIZE 8

set EXPORT_DIRECTORY_PATH <YOUR_EXPORT_PATH>


measure_design $KEY_WIDTH $DATA_WIDTH $HASH_ADR_WIDTH $NUMBER_OF_TABLES $BUCKET_SIZE $EXPORT_DIRECTORY_PATH

