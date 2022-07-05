clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/COPD_analysis, smcl replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end


use builds/copd_cohort_final, clear


// SECTION 1

tab gender, missing

sum age, meanonly
display "Mean age: " r(mean)

sum age if gender == 1, meanonly
display "Mean male age: " r(mean)

sum age if gender == 2, meanonly
display "Mean female age: " r(mean)


tab wimd_quintile, missing   //1 = most deprived; 0 = no data

tab1 asthma bronchiectasis chd diabetes heart_failure hypertension lung_cancer ///
	 stroke osteoporosis obese serious_mental_illness anxiety anxiety2yr ///
	 depression depression2yr learning_disability, missing


// SECTION 2

tab1 anypostbd postbdobstruction anyobstruction

tab xrayin6months


// SECTION 3

tab mrc_grade, missing

tab fev1pp, missing

tab1 o2assess_single //o2assess_persist

tab smokstat, missing

tab1 copdexacerbations_cat, missing


// SECTION 4

tab1 mrc35_prref anymrc_prref

tab inhalercheck

tab fluvax, missing

tab smokbcidrug

tab inhaledtherapy, missing
tab therapy_type



log close
translate analysis_logs/COPD_analysis.smcl outputs/COPD_analysis.pdf
