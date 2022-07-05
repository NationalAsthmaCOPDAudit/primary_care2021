clear all
set more off
//set trace on

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/Build_COPD, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end


//Format data and restrict to first event per patient
foreach query in comorbidities bmi q21 q22 /*q31*/ q32 q33 q41 q46 q47 q48 {
	
	use "stata_data/copd_`query'", clear
	
	//format dates
	foreach datevar in wob first_event event_dt {
		
		gen new_`datevar' = date(`datevar', "YMD")
		format %td new_`datevar'
		
		order new_`datevar', after(`datevar')
		drop `datevar'
		rename new_`datevar' `datevar'
	}
	
	//remove patients without or with obviously incorrect date of first asthma
	drop if first_event == .
	drop if first_event <= date("1901-01-01", "YMD")
	
	//add gender label
	label define gender 0 "Not known" ///
						1 "Male" ///
						2 "Female" ///
						3 "Indeterminate or anticipated sex change" ///
						9 "Not specified"
	label values gndr_cd gender
	
	gsort alf_pe event_dt
	by alf_pe: keep if _n == 1
	rename event_dt firstcopd_in_audit
	
	drop table_id event_cd read_desc
	//drop gp_practice_cluster_code gp_practice_cluster_name wimd_2019_quintile
	
	compress
	save "stata_data/copd_`query'_1row", replace
}


//start with comorbidity file
use stata_data/copd_comorbidities_1row, clear

order localhealthboardcode localhealthboardname gp_practice_cluster_code gp_practice_cluster_name prac_cd_pe local_num_pe alf_pe wob gndr_cd age_at_end_of_follow_up wimd_2019_quintile


foreach query in bmi q21 q22 /*q31*/ q32 q33 q41 q46 q47 q48 {
	
	merge 1:1 alf_pe using "stata_data/copd_`query'_1row", update
	drop if _merge < 3
	rename _merge merge_`query'
	drop merge_`query'  //comment out for debugging
}


//rename variables to align with previous analysis
rename gndr_cd gender
rename age_at_end_of_follow_up age
rename wimd_2019_quintile wimd_quintile
rename first_event firstcopd

foreach var of varlist _all {
	
	if strmatch("`var'", "*_flag") {
		
		local newname = subinstr("`var'", "_flag", "", .)
		
		display ""
		display "Before: `var'"
		rename `var' `newname'
		display "After: `newname'"
	}
}

rename smi serious_mental_illness
rename anxiety_screening anxiety2yr       //doesn't include diagnosis in past 2 yrs
rename depression_screening depression2yr //doesn't include diagnosis in past 2 yrs
drop bmi
rename cod22k obese

order asthma bronchiectasis chd diabetes heart_failure hypertension lung_cancer stroke osteoporosis serious_mental_illness anxiety anxiety2yr depression depression2yr learning_disability obese, after(firstcopd_in_audit)

rename ratio_code anyobstruction
rename post_bronchodilator_ratio_code_f postbdobstruction

tab any_post_bronchodilator
//recode no_post_bronchodilator_ratio_cod (0=1) (1=0)  //inverted to represent received
rename any_post_bronchodilator anypostbd
tab anypostbd

rename xray_flag_post_diagnosis xrayin6months

rename paap_last_year fev1pp

rename less_than_92_oxygen_sat o2assess_single

rename more_than_3_pr_code mrc35_prref
rename pr_code anymrc_prref

rename inhaler_check_last_year inhalercheck  //no check for prescription
rename flu_vax fluvax
rename smoking_cessation smokbcidrug


order anypostbd postbdobstruction anyobstruction ///
	  xrayin6months ///
	  /*mrc_grade_ever mrc_grade*/ ///
	  fev1pp ///
	  o2assess_single /*o2assess_persist*/ ///
	  /*smokstat*/ ///
	  /*copdexacerbations copdexacerbations_cat*/ ///
	  mrc35_prref anymrc_prref ///
	  inhalercheck ///
	  fluvax ///
	  smokbcidrug ///
	  /*inhaledtherapy therapy_type*/, after(obese)

//no presistent low O2 var


compress
save builds/copd_cohort_initial, replace


log close