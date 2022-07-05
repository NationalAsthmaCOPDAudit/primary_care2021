clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/COPD_analyseddata_byPractice, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 Primary Care Audit"


use builds/copd_cohort_final, clear


drop localhealthboardcode gp_practice_cluster_code
drop alf_pe local_num_pe wob firstcopd firstcopd_in_audit /*mrc_grade_ever*/ mrc3yr copdexacerbations smokerpast2yrs

order asthma bronchiectasis chd diabetes heart_failure hypertension lung_cancer ///
	  stroke osteoporosis obese serious_mental_illness anxiety anxiety2yr ///
	  depression depression2yr learning_disability, after(wimd_quintile)


local binaryvars "asthma bronchiectasis chd diabetes heart_failure hypertension"
local binaryvars "`binaryvars' lung_cancer stroke osteoporosis obese"
local binaryvars "`binaryvars' serious_mental_illness anxiety anxiety2yr"
local binaryvars "`binaryvars' depression depression2yr learning_disability"
local binaryvars "`binaryvars' anypostbd postbdobstruction anyobstruction xrayin6months"
local binaryvars "`binaryvars' fev1pp o2assess_single"
//local binaryvars "`binaryvars' o2assess_persist"
local binaryvars "`binaryvars' mrc35_prref anymrc_prref inhalercheck fluvax smokbcidrug"
local binaryvars "`binaryvars' inhaledtherapy"


//encode practices and clusters with numeric categories (no gaps) and labels that match var names
rename prac_cd_pe pracid
tostring pracid, replace
encode pracid, gen(prac_cd_pe)
order prac_cd_pe, after(pracid)
drop pracid

drop gp_practice_cluster_name localhealthboardname

gensumstat age, by(prac_cd_pe)
drop age

foreach binaryvar of local binaryvars {
	
	gennumdenom `binaryvar', pc by(prac_cd_pe)
	drop `binaryvar'
}

gennumdenom gender, num(2) pc by(prac_cd_pe)
drop gender

gennumdenom wimd_quintile, num(5) pc by(prac_cd_pe)
drop wimd_quintile

gennumdenom mrc_grade, num(5) zero pc by(prac_cd_pe)
drop mrc_grade

gennumdenom smokstat, num(3) zero pc by(prac_cd_pe)
drop smokstat

gennumdenom copdexacerbations_cat, num(3) zero pc by(prac_cd_pe)
drop copdexacerbations_cat

gennumdenom therapy_type, num(6) pc by(prac_cd_pe)
drop therapy_type


by prac_cd_pe: keep if _n == 1

export delimited outputs/practice_files/AnalysedPrimaryCareAudit_COPD_practice, replace


log close