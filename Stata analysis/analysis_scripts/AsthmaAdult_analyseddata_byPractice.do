clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/AsthmaAdult_analyseddata_byPractice, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 Primary Care Audit"


use builds/aa_cohort_final, clear


drop localhealthboardcode gp_practice_cluster_code
drop alf_pe local_num_pe wob firstasthma firstasthma_in_audit asthmaexacs smokerpast2yrs second_hand_smoke no_second_hand_smoke

order copd bronchiectasis chd diabetes heart_failure hypertension lung_cancer ///
	  stroke osteoporosis obese eczema atopy nasal_polyps reflux hayfever ///
	  family_history_of_asthma allergic_rhinitis serious_mental_illness ///
	  anxiety anxiety2yr depression depression2yr learning_disability, after(wimd_quintile)

order anyprebd, after(anypostbd)


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

gennumdenom smokstat, num(3) zero pc by(prac_cd_pe)
drop smokstat

gennumdenom sh_smoke, num(2) zero pc by(prac_cd_pe)
drop sh_smoke

gennumdenom asthmaexacs_cat, num(3) zero pc by(prac_cd_pe)
drop asthmaexacs_cat

gennumdenom therapy_type, num(6) pc by(prac_cd_pe)
drop therapy_type


by prac_cd_pe: keep if _n == 1

export delimited outputs/practice_files/AnalysedPrimaryCareAudit_AsthmaAdult_practice, replace


log close