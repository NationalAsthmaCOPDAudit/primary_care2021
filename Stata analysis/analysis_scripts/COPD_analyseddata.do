clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/COPD_analyseddata, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 Primary Care Audit"

local suppression = 5


use builds/copd_cohort_final, clear


drop wob firstcopd firstcopd_in_audit /*mrc_grade_ever*/ mrc3yr copdexacerbations smokerpast2yrs

order asthma bronchiectasis chd diabetes heart_failure hypertension lung_cancer ///
	  stroke osteoporosis obese serious_mental_illness anxiety anxiety2yr ///
	  depression depression2yr learning_disability, after(wimd_quintile)


gensumstat age
drop age


local binaryvars "asthma bronchiectasis chd diabetes heart_failure hypertension"
local binaryvars "`binaryvars' lung_cancer stroke osteoporosis obese"
local binaryvars "`binaryvars' serious_mental_illness anxiety anxiety2yr"
local binaryvars "`binaryvars' depression depression2yr learning_disability"
local binaryvars "`binaryvars' anypostbd postbdobstruction anyobstruction xrayin6months"
local binaryvars "`binaryvars' fev1pp o2assess_single"
//local binaryvars "`binaryvars' o2assess_persist"
local binaryvars "`binaryvars' mrc35_prref anymrc_prref inhalercheck fluvax smokbcidrug"
local binaryvars "`binaryvars' inhaledtherapy"

foreach binaryvar of local binaryvars {
	
	gensupnumdenom `binaryvar', sup(`suppression')
	drop `binaryvar'
}


gensupnumdenom gender, num(2) sup(`suppression')
drop gender

gensupnumdenom wimd_quintile, num(5) sup(`suppression')
drop wimd_quintile

gensupnumdenom mrc_grade, num(5) zero sup(`suppression')
drop mrc_grade

gensupnumdenom smokstat, num(3) zero sup(`suppression')
drop smokstat

gensupnumdenom copdexacerbations_cat, num(3) zero sup(`suppression')
drop copdexacerbations_cat

gensupnumdenom therapy_type, num(6) sup(`suppression')
drop therapy_type


drop localhealthboardcode localhealthboardname gp_practice_cluster_code gp_practice_cluster_name prac_cd_pe local_num_pe alf_pe
keep if _n == 1

gen grouping = "National"
order grouping


export delimited outputs/AnalysedPrimaryCareAudit_COPD, replace

log close



log using outputs/copd_labels, text replace

use builds/copd_cohort_final, clear
label list

log close