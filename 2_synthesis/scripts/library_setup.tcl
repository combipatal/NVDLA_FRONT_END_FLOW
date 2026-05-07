if {![info exists ::env(TARGET_LIB)] || $::env(TARGET_LIB) eq ""} {
    puts "Error: TARGET_LIB is not set. Source 2_synthesis/1_input/env.sh before running."
    exit 1
}

set_app_var target_library [list $::env(TARGET_LIB)]

if {[info exists ::env(SYNTHETIC_LIB)] && $::env(SYNTHETIC_LIB) ne ""} {
    set_app_var synthetic_library [list $::env(SYNTHETIC_LIB)]
} else {
    set_app_var synthetic_library [list]
}

if {[info exists ::env(LINK_LIB)] && $::env(LINK_LIB) ne ""} {
    set_app_var link_library "$::env(LINK_LIB) $::env(SYNTHETIC_LIB)"
} else {
    set_app_var link_library "* $::env(TARGET_LIB) $::env(SYNTHETIC_LIB)"
}

set_app_var search_path [list . $::env(PROJECT_ROOT) $::env(NVDLA_ROOT)/vmod]

if {[info exists ::env(WORK_DIR)] && $::env(WORK_DIR) ne ""} {
    set work_dir $::env(WORK_DIR)
} else {
    set work_dir 2_synthesis/2_output/work
}

file mkdir $work_dir
define_design_lib WORK -path $work_dir
