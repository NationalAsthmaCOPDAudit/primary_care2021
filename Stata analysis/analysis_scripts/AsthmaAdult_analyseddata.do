clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/AsthmaAdult_analyseddata, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 Primary Care Audit"

local suppression = 6


use builds/aa_cohort_final, clear


drop wob firstasthma firstasthma_in_audit asthmaexacs smokerpast2yrs second_hand_smoke no_second_hand_smoke

order copd bronchiectasis chd diabetes heart_failure hypertension lung_cancer ///
	  stroke osteoporosis obese eczema atopy nasal_polyps reflux hayfever ///
	  family_history_of_asthma allergic_rhinitis serious_mental_illness ///
	  anxiety anxiety2yr depression depression2yr learning_disability, after(wimd_quintile)

order anyprebd, after(anypostbd)


gensumstat age
drop age


local binaryvars "copd bronchiectasis chd diabetes heart_failure hypertension"
local binaryvars "`binaryvars' lung_cancer stroke osteoporosis obese eczema"
local binaryvars "`binaryvars' atopy nasal_polyps reflux hayfever family_history_of_asthma"
local binaryvars "`binaryvars' allergic_rhinitis serious_mental_illness anxiety anxiety2yr"
local binaryvars "`binaryvars' depression depression2yr learning_disability"
local binaryvars "`binaryvars' anypostbd anyprebd postbdobstruction prebdobstruction"
//local binaryvars "`binaryvars' anyobstruction"
local binaryvars "`binaryvars' anyspirom ratio_reverse spirom_reverse"
local binaryvars "`binaryvars' anypeakflow_ever prepostpeakflow_ever peakflowdiary_ever"
local binaryvars "`binaryvars' anypeakflow prepostpeakflow peakflowdiary feno"
local binaryvars "`binaryvars' objectivemeasure ocscourses3ormore ocs3plusref"
local binaryvars "`binaryvars' paap rcp3 saba_morethan2 ics_lessthan6 inhalercheck"
local binaryvars "`binaryvars' fluvax smokbcidrug inhaledtherapy"

foreach binaryvar of local binaryvars {
	
	gensupnumdenom `binaryvar', sup(`suppression')
	drop `binaryvar'
}


gensupnumdenom gender, num(2) sup(`suppression')
drop gender

gensupnumdenom wimd_quintile, num(5) sup(`suppression')
drop wimd_quintile

gensupnumdenom smokstat, num(3) zero sup(`suppression')
drop smokstat

gensupnumdenom sh_smoke, num(2) zero sup(`suppression')
drop sh_smoke

gensupnumdenom asthmaexacs_cat, num(3) zero sup(`suppression')
drop asthmaexacs_cat

gensupnumdenom therapy_type, num(6) sup(`suppression')
drop therapy_type


drop localhealthboardcode localhealthboardname gp_practice_cluster_code gp_practice_cluster_name prac_cd_pe local_num_pe alf_pe
keep if _n == 1

gen grouping = "National"
order grouping


export delimited outputs/AnalysedPrimaryCareAudit_AsthmaAdult, replace

log close



log using outputs/aa_labels, text replace

use builds/aa_cohort_final, clear
label list

log close