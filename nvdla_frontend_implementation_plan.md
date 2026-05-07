# NVDLA Partition Front-End Implementation Plan

> 목표: NVIDIA NVDLA open-source RTL 중 연산 핵심 partition을 대상으로 Synopsys DC/PT/FM 중심 Front-End Implementation flow를 구축한다. 이후 필요 시 block-level DFT/ATPG와 2-partition netlist integration STA까지 확장한다.

---

## 0. 프로젝트 정의

### 프로젝트명

**NVDLA Compute Partition 기반 Synopsys Front-End Implementation Flow 구축**

### 한 줄 정의

RTL 설계자가 작성한 대형 NPU IP RTL을 전달받은 실무 상황을 가정하고, CMAC/CACC partition을 대상으로 synthesis, STA, Formality, timing sweep, 선택적 DFT/ATPG flow를 직접 구성한다.

### 핵심 partition

| 우선순위 | Partition | 내부 핵심 block | 의미 | 선택 이유 |
|---:|---|---|---|---|
| 1 | `NV_NVDLA_partition_m` | `NV_NVDLA_cmac` | Convolution MAC | NVDLA 연산 핵심. 포트폴리오 임팩트 큼 |
| 2 | `NV_NVDLA_partition_a` | `NV_NVDLA_cacc` | Convolution Accumulator | CMAC 결과 누산. 연산 datapath 후단 |
| 3 | `NV_NVDLA_partition_p` | `NV_NVDLA_sdp` | Single Data Processor | post-processing 연산. fallback |
| 비추천 | `NV_NVDLA_partition_c` | CDMA/CBUF/CSC | data movement/buffer/control | memory 계열 섞임 |

### 최종 추천 범위

```text
Main  : partition_m 단독 DC/PT/FM + period sweep
Extend: partition_a 단독 DC/PT/FM + same flow 재사용성 확인
Optional: partition_m + partition_a gate netlist link 후 top-level STA
Bonus : partition별 block-level DFT DRC / scan insertion / stuck-at ATPG
```

---

## 1. 포트폴리오 관점 목표

### 보여줄 역량

```text
대형 RTL/IP 구조 분석
partition-level synthesis boundary 이해
filelist/include/define 정리
Synopsys Design Compiler script 작성
SDC constraint 해석/수정
PrimeTime STA setup/report 분석
Formality RTL-to-netlist equivalence check
clock period sweep 기반 estimated Fmax 도출
rerunnable Tcl/Shell automation
block-level DFT 확장 가능성 검토
```

### 기존 AES128 프로젝트와 차별점

| 기존 AES128 | 이번 NVDLA |
|---|---|
| 직접 설계한 SoC | 외부 IP RTL 수령 |
| 소형/중형 자체 구조 | 대형 공개 NPU RTL |
| DFT/ATPG까지 직접 수행 | front-end implementation flow 확장 중심 |
| 내 설계 검증 | 남의 RTL을 flow에 올리는 실무 상황 재현 |

### 안전한 표현

```text
NVDLA 전체 구현 완료 X
NVDLA 실제 NVIDIA 제품 clock 재현 X
full-chip backend/signoff 완료 X
partition-level front-end implementation flow 구축 O
post-synthesis STA 기준 estimated Fmax 도출 O
block-level DFT/ATPG prototype O, 성공 시만
```

---

## 2. 전체 flow 구조

```text
NVDLA Git clone
  ↓
partition_m / partition_a 구조 분석
  ↓
filelist/include/define/library setup 정리
  ↓
DC synthesis
  - analyze
  - elaborate
  - link
  - read_sdc
  - compile_ultra
  - write netlist/ddc/sdc/svf
  - report_qor/timing/area/power
  ↓
PrimeTime STA
  - read netlist
  - read library
  - read_sdc
  - check_timing
  - report_timing
  - report_constraint
  ↓
Formality
  - read RTL
  - read implementation netlist
  - read SVF
  - match
  - verify
  ↓
clock period sweep
  - multiple target periods
  - DC + PT 반복
  - WNS/TNS/area/power table
  - estimated Fmax 도출
  ↓
Optional DFT/ATPG
  - block-level DFT DRC
  - scan insertion
  - stuck-at ATPG
  ↓
Optional 2-partition integration
  - wrapper 작성
  - m/a gate netlist link
  - cross-partition STA
  ↓
portfolio report
```

---

## 3. Repository/workspace 구조

```text
nvdla-front-end-flow/
  README.md

  1_vcs/
    1_input/
    2_output/
    3_log/
    4_report/
    scripts/

  2_synthesis/
    1_input/
      env.sh
      constraints/
      filelists/
    2_output/
    3_log/
    4_report/
    scripts/

  3_sta/
    1_input/
    2_output/
    3_log/
    4_report/
    scripts/

  4_dft/
    1_input/
    2_output/
    3_log/
    4_report/
    scripts/

  5_formality/
    1_input/
    2_output/
    3_log/
    4_report/
    scripts/

  6_sweep/
    1_input/
    2_output/
    3_log/
    4_report/
    scripts/

  rtl/
    nvdla/                         # NVDLA clone or submodule

  docs/
    00_project_scope.md
    01_nvdla_partition_analysis.md
    02_synthesis_flow.md
    03_sta_analysis.md
    04_formality_analysis.md
    05_timing_sweep_analysis.md
    06_dft_atpg_feasibility.md
    07_issue_action_result.md
    portfolio_2page.md
```

---

## 4. Phase 1 — 환경/소스 준비

### Task 1.1: NVDLA clone

**Objective:** 원본 RTL 확보.

**Command:**

```bash
mkdir -p nvdla-front-end-flow/rtl
cd nvdla-front-end-flow/rtl
git clone https://github.com/nvdla/hw.git nvdla
```

**Verify:**

```bash
test -f nvdla/syn/scripts/dc_run.tcl
test -f nvdla/vmod/nvdla/top/NV_NVDLA_partition_m.v
test -f nvdla/vmod/nvdla/top/NV_NVDLA_partition_a.v
```

**Output:**

```text
rtl/nvdla/
```

---

### Task 1.2: Reference synthesis flow 분석

**Objective:** NVIDIA 제공 flow 구조 파악.

**Read:**

```text
rtl/nvdla/syn/scripts/dc_run.tcl
rtl/nvdla/syn/scripts/syn_launch.sh
rtl/nvdla/syn/scripts/default_config.sh
rtl/nvdla/syn/cons/NV_NVDLA_partition_m.sdc
rtl/nvdla/syn/cons/NV_NVDLA_partition_a.sdc
```

**Record:** `docs/01_nvdla_partition_analysis.md`

내용:

```text
TOP_NAMES
RTL_SEARCH_PATH
RTL_INCLUDE_SEARCH_PATH
TARGET_LIB/LINK_LIB 방식
SYN_MODE: wlm/dct/dcg/de
create_clock 기준
false_path/case_analysis/ideal_network
compile_ultra option
SVF generation
report set
```

---

### Task 1.3: tool/library path 확인

**Objective:** DC/PT/FM, DC 기반 DFT Compiler 기능, TetraMAX와 library 사용 가능성 확인.

**Command:**

```bash
which dc_shell || true
which pt_shell || true
which fm_shell || true
which tmax || true
```

**Need files:**

```text
.db or .lib standard cell timing library
optional: min/max corner library
optional: DFT-compatible scan cells
optional: TetraMAX fault library
```

**Create:** `configs/env.sh`

Template:

```bash
#!/usr/bin/env bash
export NVDLA_ROOT=$PWD/rtl/nvdla
export PROJECT_ROOT=$PWD
export TARGET_LIB="/path/to/typical.db"
export LINK_LIB="* /path/to/typical.db"
export MIN_LIB="/path/to/fast.db"
export MAX_LIB="/path/to/slow.db"
export DC_NUM_CORES=4
```

---

## 5. Phase 2 — partition 구조 분석

### Task 2.1: partition_m 내부 확인

**Objective:** CMAC partition 확인.

**File:**

```text
rtl/nvdla/vmod/nvdla/top/NV_NVDLA_partition_m.v
```

**Check points:**

```text
module name
clock/reset ports
test_mode ports
pwrbus ports
ready/valid interface
NV_NVDLA_cmac instance
retiming block instances
blackbox/RAM dependency
```

**Output:** `docs/01_nvdla_partition_analysis.md`

---

### Task 2.2: partition_a 내부 확인

**Objective:** CACC partition 확인.

**File:**

```text
rtl/nvdla/vmod/nvdla/top/NV_NVDLA_partition_a.v
```

**Check points:**

```text
NV_NVDLA_cacc instance
CMAC→CACC interface port
CACC→SDP output
clock/reset/test ports
pwrbus ports
```

---

### Task 2.3: interface mapping 후보 정리

**Objective:** optional cmac+cacc integration 준비.

**Find signals:**

```text
partition_m outputs likely:
  mac_a2accu_*
  mac_b2accu_*

partition_a inputs:
  mac_a2accu_dst_*
  mac_b2accu_src_*
```

**Record:**

```text
partition_m output → partition_a input mapping table
unused ports tie-off policy
external IO policy
clock/reset/test shared policy
```

**Output:** `docs/01_nvdla_partition_analysis.md`

---

## 6. Phase 3 — filelist/include/define 정리

### Task 3.1: baseline filelist 생성

**Objective:** DC analyze에 필요한 Verilog/SystemVerilog dependency 정리.

**Create:**

```text
filelists/NV_NVDLA_partition_m.f
filelists/NV_NVDLA_partition_a.f
```

**Start from NVIDIA style:**

```text
-y ${NVDLA_ROOT}/vmod
-y ${NVDLA_ROOT}/vmod/nvdla
-y ${NVDLA_ROOT}/vmod/nvdla/top
+incdir+${NVDLA_ROOT}/vmod/include
+libext+.v
+libext+.sv
+define+NV_SYNTHESIS
+define+DISABLE_TESTPOINTS
+define+RAM_INTERFACE
${NVDLA_ROOT}/vmod/nvdla/top/NV_NVDLA_partition_m.v
```

**주의:** exact path/define는 실제 compile error 보며 수정.

---

### Task 3.2: elaborate-only DC script 작성

**Create:** `scripts/run_dc_elab.tcl`

Skeleton:

```tcl
set MODULE $env(MODULE)
set FILELIST $env(FILELIST)
set REPORT_DIR $env(REPORT_DIR)
set DB_DIR $env(DB_DIR)

source configs/library_setup.tcl

analyze -format sverilog -vcs "-f $FILELIST" -work WORK
elaborate $MODULE
current_design $MODULE
link

redirect -file $REPORT_DIR/${MODULE}.check_design.elab.rpt { check_design }
write -format ddc -hierarchy -output $DB_DIR/${MODULE}.elab.ddc
exit
```

**Run:**

```bash
MODULE=NV_NVDLA_partition_m FILELIST=filelists/NV_NVDLA_partition_m.f dc_shell -no_gui -f scripts/run_dc_elab.tcl
```

**Pass criteria:**

```text
analyze pass
elaborate pass
link pass
no unresolved references, or documented blackbox policy
```

---

## 7. Phase 4 — SDC/constraint 구성

### Task 4.1: NVIDIA reference SDC 복사

**Create:**

```bash
cp rtl/nvdla/syn/cons/NV_NVDLA_partition_m.sdc constraints/NV_NVDLA_partition_m.sdc
cp rtl/nvdla/syn/cons/NV_NVDLA_partition_a.sdc constraints/NV_NVDLA_partition_a.sdc
```

---

### Task 4.2: clock 기준 정리

**Known from reference SDC:**

```tcl
create_clock [get_ports nvdla_core_clk] -period 0.9 -waveform {0 0.45}
```

**Interpretation:**

```text
0.9ns = reference target ≈ 1.11GHz
NVIDIA actual product clock 아님
내 library 기준 target은 period sweep으로 재도출
```

---

### Task 4.3: block-level IO budget 추가 검토

**Issue:** NVDLA reference SDC가 block-level IO delay를 충분히 안 줄 수 있음.

**Policy 후보:**

```tcl
set_clock_uncertainty 0.05 [get_clocks nvdla_core_clk]
set_input_delay  0.2 -clock nvdla_core_clk [remove_from_collection [all_inputs] [get_ports {nvdla_core_clk direct_reset_ dla_reset_rstn test_mode*}]]
set_output_delay 0.2 -clock nvdla_core_clk [all_outputs]
```

**주의:** 실제 적용 전 report_constraint/check_timing으로 효과 확인.

---

## 8. Phase 5 — DC synthesis flow

### Task 5.1: common library setup 작성

**Create:** `configs/library_setup.tcl`

Skeleton:

```tcl
set_app_var target_library [list $env(TARGET_LIB)]
set_app_var link_library "* $env(LINK_LIB)"
set_app_var search_path ". $env(NVDLA_ROOT)/vmod $env(NVDLA_ROOT)/vmod/nvdla $env(NVDLA_ROOT)/vmod/nvdla/top"
define_design_lib WORK -path ./work
```

---

### Task 5.2: full DC script 작성

**Create:** `scripts/run_dc.tcl`

Main steps:

```tcl
set_svf $FV_DIR/${MODULE}.svf
analyze -format sverilog -vcs "-f $FILELIST" -work WORK
elaborate $MODULE
current_design $MODULE
link
read_sdc $SDC_FILE
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
check_design
check_timing
compile_ultra -no_seq_output_inversion -scan
write -format ddc -hierarchy -output $DB_DIR/${MODULE}.ddc
write -format verilog -hierarchy -output $NET_DIR/${MODULE}.vg
write_sdc -nosplit $NET_DIR/${MODULE}.sdc
report_qor > $REPORT_DIR/${MODULE}.qor.rpt
report_timing -max_paths 50 -nworst 5 -transition_time -capacitance -nets > $REPORT_DIR/${MODULE}.timing.rpt
report_area -hierarchy > $REPORT_DIR/${MODULE}.area.rpt
report_power -hierarchy > $REPORT_DIR/${MODULE}.power.rpt
report_constraint -all_violators > $REPORT_DIR/${MODULE}.constraint.rpt
set_svf -off
exit
```

---

### Task 5.3: partition_m baseline synthesis

**Run:**

```bash
source configs/env.sh
./scripts/run_one_dc.sh NV_NVDLA_partition_m
```

**Pass criteria:**

```text
.vg generated
.ddc generated
.sdc generated
.svf generated
qor/timing/area/power reports generated
check_design major error 없음
```

---

### Task 5.4: partition_a baseline synthesis

Same as partition_m.

**Goal:** 동일 flow 재사용 확인.

---

## 9. Phase 6 — PrimeTime STA

### Task 6.1: PT setup 작성

**Create:** `scripts/run_pt.tcl`

Skeleton:

```tcl
set MODULE $env(MODULE)
set NETLIST $env(NETLIST)
set SDC_FILE $env(SDC_FILE)
set REPORT_DIR $env(REPORT_DIR)

set target_library [list $env(TARGET_LIB)]
set link_library "* $env(LINK_LIB)"

read_verilog $NETLIST
current_design $MODULE
link_design $MODULE
read_sdc $SDC_FILE
update_timing

redirect -file $REPORT_DIR/${MODULE}.pt.check_timing.rpt { check_timing -verbose }
redirect -file $REPORT_DIR/${MODULE}.pt.clocks.rpt { report_clock }
redirect -file $REPORT_DIR/${MODULE}.pt.constraint.rpt { report_constraint -all_violators }
redirect -file $REPORT_DIR/${MODULE}.pt.timing.max.rpt { report_timing -delay_type max -max_paths 50 -nworst 5 -input_pins -nets -transition_time -capacitance }
redirect -file $REPORT_DIR/${MODULE}.pt.timing.min.rpt { report_timing -delay_type min -max_paths 50 -nworst 5 -input_pins -nets -transition_time -capacitance }
redirect -file $REPORT_DIR/${MODULE}.pt.qor.rpt { report_qor }
exit
```

---

### Task 6.2: partition_m PT STA

**Run:**

```bash
MODULE=NV_NVDLA_partition_m \
NETLIST=build/partition_m/net/NV_NVDLA_partition_m.vg \
SDC_FILE=build/partition_m/net/NV_NVDLA_partition_m.sdc \
REPORT_DIR=reports/partition_m/pt \
pt_shell -f scripts/run_pt.tcl
```

**Analyze:**

```text
WNS/TNS
violating paths
unconstrained paths
missing generated clocks
invalid exceptions
min/hold violations
```

---

### Task 6.3: partition_a PT STA

Same as partition_m.

---

## 10. Phase 7 — Formality RTL-to-netlist 검증

### Task 7.1: FM script 작성

**Create:** `scripts/run_fm.tcl`

Main logic:

```tcl
set MODULE $env(MODULE)
set FILELIST $env(FILELIST)
set NETLIST $env(NETLIST)
set SVF $env(SVF)
set REPORT_DIR $env(REPORT_DIR)

set_app_var hdlin_ignore_parallel_case true
set_app_var hdlin_ignore_full_case true

set_svf $SVF

read_verilog -container r -libname WORK -f $FILELIST
set_top r:/WORK/$MODULE

read_verilog -container i -libname WORK $NETLIST
set_top i:/WORK/$MODULE

match
redirect -file $REPORT_DIR/${MODULE}.fm.match.rpt { report_matched_points }
verify
redirect -file $REPORT_DIR/${MODULE}.fm.verify.rpt { report_verification }
exit
```

**주의:** Formality filelist syntax는 tool/version 따라 조정 필요.

---

### Task 7.2: partition_m FM

**Pass criteria:**

```text
match 성공
verify 성공
unmatched/aborted point 없거나 원인 분석 완료
```

---

### Task 7.3: partition_a FM

Same.

---

## 11. Phase 8 — clock period sweep / estimated Fmax

### Task 8.1: sweep period list 정의

**Create:** `configs/sweep_config.csv`

```csv
period_ns,comment
3.0,loose
2.5,loose
2.0,baseline realistic
1.8,tighter
1.6,tighter
1.4,aggressive
1.2,very aggressive
1.0,near reference
0.9,nvdla reference
```

---

### Task 8.2: SDC period override 방식 작성

Option A: SDC template variable.

```tcl
create_clock [get_ports nvdla_core_clk] -period $::env(CLOCK_PERIOD) -waveform [list 0 [expr {$::env(CLOCK_PERIOD)/2.0}]]
```

Option B: run script에서 generated SDC 생성.

```bash
sed "s/-period 0.9/-period ${PERIOD}/" constraints/NV_NVDLA_partition_m.sdc > build/sweep/${PERIOD}/constraint.sdc
```

추천: Option B. 단순.

---

### Task 8.3: run_sweep.sh 작성

**Create:** `scripts/run_sweep.sh`

Flow:

```text
for period in sweep list:
  create build dir
  create SDC with period
  run DC
  run PT
  parse WNS/TNS/area/power
  append summary.csv
```

---

### Task 8.4: report parser 작성

**Create:** `scripts/parse_reports.py`

Extract:

```text
period_ns
frequency_mhz = 1000 / period_ns
DC WNS/TNS if available
PT WNS/TNS
area
power
violating path count
result PASS/FAIL
```

**Output:**

```text
reports/partition_m/sweep/summary.csv
reports/partition_a/sweep/summary.csv
```

---

### Task 8.5: estimated Fmax 산출

**Method:**

```text
timing clean = PT WNS >= 0 and TNS = 0 and no setup violations
highest frequency among timing-clean periods = estimated Fmax
```

**주의 표현:**

```text
post-synthesis STA 기준 estimated Fmax
사용 library/corner 기준
P&R/signoff SPEF 기반 final silicon Fmax 아님
```

---

## 12. Phase 9 — optional 2-partition netlist integration

### Task 9.1: cmac_cacc wrapper 설계

**Create:** `wrappers/cmac_cacc_top.v`

Concept:

```verilog
module cmac_cacc_top (...);
  NV_NVDLA_partition_m u_cmac (...);
  NV_NVDLA_partition_a u_cacc (...);
endmodule
```

**Connect:**

```text
shared nvdla_core_clk
shared reset/test_mode/clock override
partition_m mac_a2accu_* → partition_a mac_a2accu_dst_*
partition_m mac_b2accu_* → partition_a mac_b2accu_src_*
external CSB/config left as top IO or tied-off only if justified
unused ready/valid handled explicitly
```

**주의:** 억지 tie-off는 기능 의미 약화. 목적은 top-level link/STA feasibility.

---

### Task 9.2: linked top-level STA

**Inputs:**

```text
wrappers/cmac_cacc_top.v
partition_m gate netlist
partition_a gate netlist
stdcell db
cmac_cacc_top.sdc
```

**PT flow:**

```tcl
read_verilog wrappers/cmac_cacc_top.v
read_verilog build/partition_m/net/NV_NVDLA_partition_m.vg
read_verilog build/partition_a/net/NV_NVDLA_partition_a.vg
current_design cmac_cacc_top
link_design cmac_cacc_top
read_sdc constraints/cmac_cacc_top.sdc
update_timing
report_timing
```

**Goal:**

```text
m→a cross-partition timing path 확인
interface path constraint 필요성 확인
```

---

### Task 9.3: integration FM, only if wrapper stable

**Reference:**

```text
RTL wrapper + partition_m RTL + partition_a RTL
```

**Implementation:**

```text
gate wrapper + partition_m netlist + partition_a netlist
```

**Risk:** 높음. 포트폴리오 main 아님.

---

## 13. Phase 10 — optional block-level DFT/ATPG

### Task 10.1: DFT scope 결정

Recommended:

```text
partition_m block-level only
partition_a block-level only
no top-level scan stitching at first
DFT DRC/scan insertion은 dc_shell에서 DFT Compiler 기능으로 수행
stuck-at ATPG는 tmax로 수행
```

Avoid:

```text
cmac+cacc top-level ATPG main goal
NVDLA full-chip DFT
```

---

### Task 10.2: DC 기반 DFT DRC script 작성

**Create:** `scripts/run_dc_dft.tcl`

**Run with:** `dc_shell -no_gui -f scripts/run_dc_dft.tcl`

Concept:

```tcl
read_verilog synthesized_netlist.vg
current_design $MODULE
link
read_sdc $SDC_FILE

set_dft_signal -view existing_dft -type ScanClock -port nvdla_core_clk -timing {45 55}
set_dft_signal -view existing_dft -type Reset -port dla_reset_rstn -active_state 0
set_dft_signal -view spec -type ScanEnable -port scan_enable -active_state 1
set_dft_signal -view spec -type TestMode -port test_mode -active_state 1

create_test_protocol
preview_dft
dft_drc
```

**Note:** 실제 scan_enable port 없으면 wrapper/test port 추가 필요.

---

### Task 10.3: DC 기반 scan insertion

**Goal:** scan netlist 생성.

```tcl
insert_dft
write -format verilog -hierarchy -output ${MODULE}.scan.vg
write_test_protocol -output ${MODULE}.spf
report_scan_path > scan_path.rpt
report_dft > dft.rpt
```

**Pass criteria:**

```text
scan netlist generated
DFT DRC major violation reduced/documented
scan chain report generated
```

---

### Task 10.4: TetraMAX stuck-at ATPG

**Create:** `scripts/run_tmax.tcl`

**Run with:** `tmax -shell` 후 `source scripts/run_tmax.tcl`

**Inputs:**

```text
scan netlist
SPF/STIL protocol
stdcell ATPG model/library
```

**Flow:**

```tcl
read_netlist ${MODULE}.scan.vg
run_build_model $MODULE
read_sdc or read constraints as needed
read_spf ${MODULE}.spf
run_drc
set_faults -model stuck
add_faults -all
run_atpg
report_summaries
write_patterns
```

**Metrics:**

```text
fault coverage
test coverage
pattern count
aborted/untestable fault reason
```

**Safe wording:**

```text
block-level stuck-at ATPG prototype
```

---

## 14. Report/documentation plan

### docs/02_synthesis_flow.md

내용:

```text
flow structure
DC commands
library setup
filelist/include/define issue
check_design result
QoR/timing/area/power summary
```

### docs/03_sta_analysis.md

내용:

```text
PT setup
clock definition
constraint validation
WNS/TNS
critical path type
unconstrained path handling
```

### docs/04_formality_analysis.md

내용:

```text
SVF role
reference/implementation setup
match result
verify result
debug notes
```

### docs/05_timing_sweep_analysis.md

내용:

```text
period sweep table
PASS/FAIL boundary
estimated Fmax
area/power/timing trade-off
why post-synthesis estimated only
```

### docs/06_dft_atpg_feasibility.md

내용:

```text
DFT DRC setup
scan signal definition
clock/reset/test_mode issue
scan insertion result
ATPG coverage if available
```

### docs/07_issue_action_result.md

형식:

```text
Issue:
Action:
Result:
Lesson:
Evidence:
```

---

## 15. Expected issues / 대응

### Issue 1: analyze/elaborate 실패

원인:

```text
missing include
missing define
filelist order
unresolved module
ifdef branch mismatch
```

대응:

```text
NVIDIA syn_launch.sh generated .files.vc 구조 참고
+incdir, +define, -y, +libext 정리
```

---

### Issue 2: unresolved RAM/macro

원인:

```text
RAM wrapper/macro not in filelist
blackbox expected
```

대응:

```text
RAM_INTERFACE define 확인
memory macro는 blackbox or wrapper model 처리
포트폴리오에는 memory macro dependency로 기록
```

---

### Issue 3: 0.9ns timing fail

원인:

```text
NVIDIA reference target과 내 library/corner 차이
physical info 없음
```

대응:

```text
0.9ns를 재현 목표로 고정하지 않음
period sweep으로 achievable period 도출
```

---

### Issue 4: PT unconstrained path

원인:

```text
missing IO delay
missing generated clock
invalid false path
```

대응:

```text
check_timing -verbose
report_clocks
report_constraint
SDC 보완
```

---

### Issue 5: FM mismatch

원인:

```text
SVF 미적용
library mismatch
undriven/tie-off 차이
clock gating/scan option 영향
blackbox mismatch
```

대응:

```text
set_svf 확인
same filelist/reference RTL 사용
implementation netlist link 확인
unmatched point report 분석
```

---

### Issue 6: DFT DRC violation 많음

원인:

```text
clock gating control
async reset 제어
no scan_enable
RAM blackbox X source
multiple clocks/test protocol 부족
```

대응:

```text
DFT는 optional/feasibility로 유지
scan_enable wrapper 추가 검토
test_mode/case_analysis 정리
violation 분석만 해도 포트폴리오 가치 있음
```

---

## 16. Success criteria

### Minimum success

```text
partition_m elaborate/link 성공
partition_m DC synthesis netlist 생성
partition_m PT STA report 생성
partition_m FM verify 시도 및 결과 분석
```

### Good success

```text
partition_m DC/PT/FM pass
period sweep summary.csv 생성
estimated Fmax 도출
critical path 분석 문서화
```

### Strong success

```text
partition_m + partition_a 둘 다 DC/PT/FM
동일 flow 재사용성 확인
area/power/timing 비교
```

### Excellent success

```text
m+a gate netlist integration STA
partition-level DFT DRC/scan insertion
stuck-at ATPG coverage 산출
```

---

## 17. Portfolio 2-page 구성

### Page 1 — Flow / Scope / Result

```text
Title: NVDLA Compute Partition Front-End Implementation Flow
Scope: CMAC/CACC partition
Flow diagram: RTL → DC → PT → FM → Sweep → optional DFT
Key outputs: netlist, SDC, SVF, reports
KPI: timing-clean period, estimated Fmax, area, power, FM result
```

### Page 2 — Issue / Action / Result / Lesson

```text
Issue 1: 대형 IP dependency/filelist 정리
Action: NVIDIA reference flow 분석, include/define/filelist 재구성
Result: partition_m elaborate/link/synthesis 성공
Lesson: external IP는 RTL coding보다 environment/constraint integrity가 핵심

Issue 2: reference clock vs local library 차이
Action: clock period sweep
Result: local library 기준 estimated Fmax 도출
Lesson: public SDC target은 reference이며, STA는 library/corner/context 기반으로 해석해야 함

Issue 3: equivalence/signoff preparation
Action: SVF 기반 Formality RTL-to-netlist 검증
Result: synthesis transform 검증 or mismatch 원인 분석
Lesson: synthesis result는 timing뿐 아니라 logic equivalence까지 확인 필요
```

---

## 18. Final recommended execution order

```text
1. clone + env setup
2. partition_m analyze/elaborate/link
3. partition_m DC synthesis
4. partition_m PT STA
5. partition_m FM
6. partition_m period sweep
7. partition_a same flow
8. compare m vs a
9. optional block-level DFT DRC/scan insertion
10. optional m+a netlist link STA
11. docs/report/portfolio 정리
```

---

## 19. Commit strategy

```bash
git add docs/ configs/ scripts/ constraints/ filelists/
git commit -m "docs: define nvdla frontend implementation scope"

git commit -m "feat: add dc synthesis flow for nvdla partition"
git commit -m "feat: add primetime sta flow"
git commit -m "feat: add formality verification flow"
git commit -m "feat: add clock period sweep automation"
git commit -m "docs: add timing sweep and issue analysis"
```

---

## 20. 최종 결론

```text
메인은 partition_m(CMAC) 단독 DC/PT/FM + period sweep.
확장은 partition_a(CACC) 동일 flow.
두 partition 합침은 gate netlist를 wrapper에서 link하는 것.
DFT/ATPG는 block별 prototype이 안전.
전체 NVDLA/full-chip signoff 표현 금지.
```


---

## 21. Final Review 반영 사항

### 21.1 Project root 정책

프로젝트 폴더명은 현재 확정하지 않는다. 실제 실행을 시작하는 repo 안에 아래 구조를 둔다.

```text
task_plan.md
findings.md
progress.md
README.md
scripts/
configs/
constraints/
filelists/
docs/
```

핵심은 폴더명이 아니라, 실행 repo 안에서 plan/files/scripts/reports를 같이 관리하는 것이다.

### 21.2 공개 산출물 / 보안 정책

Synopsys tool, PDK, standard cell library 정보는 공개하지 않는다.

공개 금지:

```text
.db/.lib
raw mapped gate netlist, if proprietary cell names leak
raw reports with library path/cell names/license server/tool host info
license server info
proprietary library paths
```

공개 가능:

```text
sanitized Tcl/Shell/Python templates
redacted report snippets
summary CSV/table with no proprietary path/cell leakage
WNS/TNS/area/power normalized or sanitized values
issue-action-result documentation
portfolio PDF/markdown summary
```

포트폴리오/Git 업로드 전 `artifact sanitization` 단계를 수행한다.

### 21.3 NVDLA source/license 정책

NVDLA source는 clone/submodule 방식으로 관리하고, 사용 commit hash를 기록한다.

```bash
git -C rtl/nvdla rev-parse HEAD
```

문서에 NVDLA Open Hardware License reference를 남긴다. 필요한 경우 전체 RTL을 vendoring하지 않고 clone instruction 또는 submodule로 처리한다.

### 21.4 library setup env 정책

`LINK_LIB`에 `*`를 넣지 않는다. 중복 방지.

권장 env:

```bash
export TARGET_LIB="/path/to/typical.db"
export EXTRA_LINK_LIBS=""
```

권장 Tcl:

```tcl
set_app_var target_library [list $env(TARGET_LIB)]
set_app_var link_library "* $env(TARGET_LIB) $env(EXTRA_LINK_LIBS)"
```

### 21.5 Tcl path 정책

build directory에서 실행해도 깨지지 않도록 모든 script는 `PROJECT_ROOT` 기준 path를 사용한다.

```tcl
set PROJECT_ROOT $env(PROJECT_ROOT)
source $PROJECT_ROOT/configs/library_setup.tcl
```

필요 directory는 Tcl/Shell에서 생성한다.

```tcl
file mkdir $WORK_DIR $REPORT_DIR $DB_DIR $NET_DIR $FV_DIR
```

### 21.6 DC analyze smoke test 우선

compile 전에 반드시 analyze/elaborate/link only를 먼저 통과시킨다.

```text
1. analyze
2. elaborate
3. current_design
4. link
5. check_design
6. write elaborated ddc
```

이 단계가 불안정하면 compile/PT/FM으로 넘어가지 않는다.

### 21.7 clock period sweep 방식

`sed`로 `-period 0.9`만 바꾸는 방식은 피한다. waveform mismatch 위험이 있다.

권장: SDC template/env 방식.

```tcl
set CLK_PERIOD $::env(CLOCK_PERIOD)
create_clock [get_ports nvdla_core_clk] \
  -period $CLK_PERIOD \
  -waveform [list 0 [expr {$CLK_PERIOD/2.0}]]
```

### 21.8 STA 해석 caveat

post-synthesis STA 결과는 사용한 library/corner/constraint/wire model 기준이다.

표현:

```text
post-synthesis STA 기준 estimated Fmax
setup timing 중심 분석
hold는 pre-CTS sanity check 수준
final hold closure는 P&R/CTS/SPEF 이후 필요
```

금지 표현:

```text
NVDLA 실제 최대 주파수 검증
silicon signoff Fmax 확보
post-route hold closure 완료
```

### 21.9 Formality setup 기준

FM은 아래 조건을 맞춘다.

```text
same RTL filelist/defines as DC
same blackbox/RAM policy
SVF from same synthesis run
implementation netlist linked with same library
constant/tie-off policy documented
```

minimum success에서는 `FM pass` 또는 `mismatch root cause documented`를 허용한다.

### 21.10 DFT/ATPG 시작 조건

DFT/ATPG는 DC/PT/FM 안정화 이후에만 시작한다.

```text
DFT start condition:
  partition_m DC synthesis success
  partition_m PT STA completed
  partition_m FM pass or mismatch root cause documented
```

DFT/ATPG는 계속 optional이다.

### 21.11 m+a integration 표현 제한

m+a integration은 gate netlist를 wrapper에서 link하는 것이다.

허용 표현:

```text
linked gate netlist integration
cross-partition STA feasibility
interface timing visibility
```

금지 표현:

```text
full NVDLA convolution pipeline verification
full SoC integration
full-chip implementation/signoff
```

### 21.12 fallback rule

```text
If partition_m does not pass elaborate/link after 3 debug cycles:
  switch to partition_a.
If partition_a also fails:
  switch to partition_p.
```

실패 반복 시 같은 접근을 계속 밀지 않고 filelist/define/blackbox policy를 재검토한다.

### 21.13 evidence checklist

필수 증빙:

```text
DC:
  check_design.rpt
  check_timing.rpt
  qor.rpt
  timing.rpt
  area.rpt
  power.rpt
  netlist .vg
  svf

PT:
  check_timing.rpt
  clocks.rpt
  constraint.rpt
  timing.max.rpt
  timing.min.rpt
  qor.rpt

FM:
  match.rpt
  verify.rpt

Sweep:
  summary.csv
  pass/fail boundary
  estimated Fmax calculation

Optional DFT:
  dft_drc.rpt
  scan_path.rpt
  atpg coverage summary, if available
```

---

## 22. 최종 실행 순서

```text
0. 실제 실행 repo 결정 후 planning files 생성
1. NVDLA clone/submodule + commit/license 기록
2. Synopsys tool/library availability smoke test
3. partition_m(CMAC) hierarchy/filelist/SDC 분석
4. partition_m DC analyze/elaborate/link only
5. partition_m baseline DC synthesis
6. partition_m PT STA
7. partition_m Formality
8. partition_m period sweep + estimated Fmax
9. partition_a(CACC) same flow, if partition_m stable
10. partition_m/a comparison
11. optional block-level DFT DRC/scan insertion
12. optional stuck-at ATPG
13. optional m+a linked gate netlist STA
14. artifact sanitization
15. portfolio 2-page/report 작성
```

---

## 23. 최종 한 줄 결론

```text
메인은 NVDLA partition_m(CMAC) DC/PT/FM + period sweep이다.
partition_a(CACC)는 flow 재사용성 확장이다.
DFT/ATPG와 m+a linked STA는 optional이다.
공개 산출물은 반드시 sanitize한다.
```
