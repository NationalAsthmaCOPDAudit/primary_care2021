//PRACTICE COUNT

clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/PracticeCount, text replace


use builds/copd_cohort_final, clear


bysort prac_cd_pe: keep if _n == 1

count  //number of practices


contract localhealthboardname

export delimited outputs/copd_lhb_practices, replace



use builds/aa_cohort_final, clear


bysort prac_cd_pe: keep if _n == 1

count  //number of practices


contract localhealthboardname

export delimited outputs/aa_lhb_practices, replace



use builds/ca_cohort_final, clear


bysort prac_cd_pe: keep if _n == 1

count  //number of practices


contract localhealthboardname

export delimited outputs/ca_lhb_practices, replace



log close