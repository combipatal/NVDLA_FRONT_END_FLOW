if {![info exists ::env(TARGET_LIB)] || $::env(TARGET_LIB) eq ""} {
    puts "Error: TARGET_LIB is not set. Source configs/env.sh before running."
    exit 1
}

set_app_var target_library [list $::env(TARGET_LIB)]

if {[info exists ::env(LINK_LIB)] && $::env(LINK_LIB) ne ""} {
    set_app_var link_library $::env(LINK_LIB)
} else {
    set_app_var link_library "* $::env(TARGET_LIB)"
}

set_app_var search_path [list . $::env(PROJECT_ROOT) $::env(NVDLA_ROOT)/vmod]

file mkdir build/work
define_design_lib WORK -path build/work
