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

if {[shell_is_in_topographical_mode]} {
    foreach required_var {MW_TECH_FILE MW_REFERENCE_LIBS TLU_PLUS_MAX TLU_PLUS_MIN TECH2ITF_MAP MW_DESIGN_LIB} {
        if {![info exists ::env($required_var)] || $::env($required_var) eq ""} {
            puts "Error: $required_var is not set for topographical mode."
            exit 1
        }
    }

    foreach required_file [list $::env(MW_TECH_FILE) $::env(TLU_PLUS_MAX) $::env(TLU_PLUS_MIN) $::env(TECH2ITF_MAP)] {
        if {![file exists $required_file]} {
            puts "Error: Missing topographical setup file: $required_file"
            exit 1
        }
    }

    set mw_reference_library [split $::env(MW_REFERENCE_LIBS)]
    foreach ref_lib $mw_reference_library {
        if {![file isdirectory $ref_lib]} {
            puts "Error: Missing Milkyway reference library: $ref_lib"
            exit 1
        }
    }

    set mw_design_library $::env(MW_DESIGN_LIB)
    if {[file exists $mw_design_library] && ![file isdirectory $mw_design_library]} {
        puts "Error: Milkyway design library path is not a directory: $mw_design_library"
        exit 1
    } elseif {[file isdirectory $mw_design_library] && ![file exists "$mw_design_library/CEL"]} {
        file delete -force $mw_design_library
    }

    file mkdir [file dirname $mw_design_library]

    if {[file isdirectory $mw_design_library]} {
        if {[catch {open_mw_lib $mw_design_library} err]} {
            puts "Error: Failed to open Milkyway design library $mw_design_library: $err"
            exit 1
        }
    } else {
        if {[catch {
            create_mw_lib \
                -technology $::env(MW_TECH_FILE) \
                -mw_reference_library $mw_reference_library \
                -hier_separator {/} \
                -bus_naming_style {[%d]} \
                -open \
                $mw_design_library
        } err]} {
            puts "Error: Failed to create Milkyway design library $mw_design_library: $err"
            exit 1
        }
    }

    if {[catch {
        set_tlu_plus_files \
            -max_tluplus $::env(TLU_PLUS_MAX) \
            -min_tluplus $::env(TLU_PLUS_MIN) \
            -tech2itf_map $::env(TECH2ITF_MAP)
        check_tlu_plus_files
    } err]} {
        puts "Error: Failed to set/check TLU+ files: $err"
        exit 1
    }
}
