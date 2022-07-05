clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/AsthmaChild_analysis, smcl replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end


use builds/ca_cohort_final, clear


// SECTION 1

tab gender, missing

sum age, meanonly
display "Mean age: " r(mean)

sum age if gender == 1, meanonly
display "Mean male age: " r(mean)

sum age if gender == 2, meanonly
display "Mean female age: " r(mean)


tab wimd_quintile, missing   //1 = most deprived; 0 = no data

tab1 eczema atopy nasal_polyps reflux hayfever family_history_of_asthma ///
	 allergic_rhinitis mental_health_issues_paeds learning_disability, missing


// SECTION 2 - PRE-BD OBSTRUCTION REDACTED

tab1 anypostbd anyprebd postbdobstruction /*prebdobstruction*/ /*anyobstruction*/

tab1 anyspirom ratio_reverse spirom_reverse

tab1 anypeakflow_ever prepostpeakflow_ever peakflowdiary_ever

tab1 anypeakflow prepostpeakflow peakflowdiary

tab feno

tab objectivemeasure


// SECTION 3

tab ocscourses3ormore, missing
tab ocs3plusref, missing

tab smokstat, missing

tab sh_smoke, missing

tab1 asthmaexacs_cat, missing


// SECTION 4

tab paap, missing

tab rcp3, missing

tab saba_morethan2, missing

tab ics_lessthan6, missing

tab inhalercheck

tab fluvax, missing

tab smokbcidrug

tab inhaledtherapy, missing
//tab therapy_type  //count too low - REDACTED - see CSV instead



log close
translate analysis_logs/AsthmaChild_analysis.smcl outputs/AsthmaChild_analysis.pdf
