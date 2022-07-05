clear all
set more off
//set trace on

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/Build_Asthma, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end


//For adult asthma and child asthma
foreach cohort in aa ca {
	
	//Format data and restrict to first event per patient
	foreach query in comorbidities bmi q23 q24 q25 q26 q34 q36 q42 q43 q44 q45 q46 q47 q48 {
		
		if "`cohort'" == "ca" & "`query'" == "bmi" {
			
			display "No BMI/obesity data for children."
		}
		else {
			
			use "stata_data/`cohort'_`query'", clear
			
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
			rename event_dt firstasthma_in_audit
			
			//table_id not present in one file so check it exists
			capture confirm variable table_id
			if !_rc {
				drop table_id
			}
			drop event_cd read_desc
			//drop gp_practice_cluster_code gp_practice_cluster_name wimd_2019_quintile
			
			compress
			save "stata_data/`cohort'_`query'_1row", replace
		}
	}

	
	//start with comorbidity file
	use stata_data/`cohort'_comorbidities_1row, clear
	
	order localhealthboardcode localhealthboardname gp_practice_cluster_code gp_practice_cluster_name prac_cd_pe local_num_pe alf_pe wob gndr_cd age_at_end_of_follow_up wimd_2019_quintile


	foreach query in bmi q24 q25 q26 q34 q36 q42 q43 q44 q45 q46 q47 q48 {
		
		if "`cohort'" == "ca" & "`query'" == "bmi" {
			
			display "No BMI/obesity data for children."
		}
		else {
			
			merge 1:1 alf_pe using "stata_data/`cohort'_`query'_1row", update
			drop if _merge < 3
			rename _merge merge_`query'
			drop merge_`query'  //comment out for debugging
		}
	}


	//rename variables to align with previous analysis
	rename gndr_cd gender
	rename age_at_end_of_follow_up age
	rename wimd_2019_quintile wimd_quintile
	rename first_event firstasthma

	foreach var of varlist _all {
		
		if strmatch("`var'", "*_flag") {
			
			local newname = subinstr("`var'", "_flag", "", .)
			
			display ""
			display "Before: `var'"
			rename `var' `newname'
			display "After: `newname'"
		}
	}
	
	
	rename fh_asthma family_history_of_asthma
	drop bmi
	
	if "`cohort'" == "aa" {
		
		rename smi serious_mental_illness
		rename anxiety_screening anxiety2yr       //diagnoses in past 2 yrs not included
		rename depression_screening depression2yr //diagnoses in past 2 yrs not included
		rename cod22k obese
		
		order copd bronchiectasis chd diabetes heart_failure hypertension ///
			  lung_cancer stroke osteoporosis eczema atopy nasal_polyps ///
			  reflux hayfever family_history_of_asthma allergic_rhinitis ///
			  serious_mental_illness anxiety anxiety2yr depression depression2yr ///
			  learning_disability obese, after(firstasthma_in_audit)
	}
	else if "`cohort'" == "ca" {
		
		drop copd
		
		rename mhp mental_health_issues_paeds
		
		order eczema atopy nasal_polyps reflux hayfever family_history_of_asthma ///
			  allergic_rhinitis mental_health_issues_paeds learning_disability ///
			  , after(firstasthma_in_audit)
	}
	
	
	if "`cohort'" == "ca" {
		
		rename rcp_last_year_6_to_11  saba_morethan2_6_to_11
		rename rcp_last_year_12_to_18 saba_morethan2_12_to_18
		
		gen saba_last_year = (saba_morethan2_6_to_11 == 1 | saba_morethan2_12_to_18 == 1)
		tab saba_last_year saba_morethan2_6_to_11
		tab saba_last_year saba_morethan2_12_to_18
		drop saba_morethan2_6_to_11 saba_morethan2_12_to_18
		
		drop ics_last_year_6_to_11  ics_last_year_12_to_18
	}
	
	rename peak_flow anypeakflow_ever
	rename before_bronchodilation prepostpeakflow_ever
	rename peak_flow_diary peakflowdiary_ever

	rename peak_flow_flag_2_years anypeakflow
	rename before_bronchodilation_2_years prepostpeakflow
	rename peak_flow_diary_2_years peakflowdiary

	tab no_post_bronchodilator_ratio_cod
	//recode no_post_bronchodilator_ratio_cod (0=1) (1=0)  //inverted to represent received
	rename no_post_bronchodilator_ratio_cod anypostbd
	tab anypostbd

	tab no_pre_bronchodilator_ratio_code
	//recode no_pre_bronchodilator_ratio_code (0=1) (1=0)  //inverted to represent received
	rename no_pre_bronchodilator_ratio_code anyprebd
	tab anyprebd

	rename post_bronchodilator_ratio_code postbdobstruction
	rename pre_bronchodilator_ratio_code prebdobstruction

	tab no_spirometry
	recode no_spirometry (0=1) (1=0)  //inverted to represent received
	rename no_spirometry anyspirom
	tab anyspirom

	rename fvc_reversibility ratio_reverse
	rename reversibility spirom_reverse

	rename ocs_past_year ocscourses3ormore
	rename ocs_and_care_past_year ocs3plusref

	rename paap_last_year paap
	rename rcp_last_year rcp3
	
	rename saba_last_year saba_morethan2
	rename ics_last_year  ics_lessthan6

	rename inhaler_check_last_year inhalercheck  //no check for prescription
	rename flu_vax fluvax
	rename smoking_cessation smokbcidrug

	order anypeakflow_ever prepostpeakflow_ever peakflowdiary_ever ///
		  anypeakflow prepostpeakflow peakflowdiary ///
		  feno ///
		  anypostbd anyprebd postbdobstruction prebdobstruction /*anyobstruction*/ ///
		  anyspirom ratio_reverse spirom_reverse ///
		  ocscourses3ormore ocs3plusref ///
		  second_hand_smoke no_second_hand_smoke ///
		  paap rcp3 ///
		  saba_morethan2 ics_lessthan6 ///
		  inhalercheck ///
		  fluvax, before(smokbcidrug)

	//anyobstruction code missing


	compress
	save builds/`cohort'_cohort_initial, replace
}


log close