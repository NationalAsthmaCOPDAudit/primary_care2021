clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/Asthma_Finalise, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end


label define exacer_cat 3 ">2"


foreach cohort in aa ca {
	
	use builds/`cohort'_cohort_initial, clear

	//Screening (sort of) fix
	if "`cohort'" == "aa" {
		
		tab1 anxiety2yr depression2yr, missing
		drop anxiety2yr depression2yr

		preserve

		use builds/`cohort'_cohort_final_2022-03-28, clear

		keep alf_pe anxiety2yr depression2yr

		tempfile screening
		save `screening'

		restore

		merge 1:1 alf_pe using `screening'
		drop if _merge == 2
		drop _merge

		order anxiety2yr, after(anxiety)
		order depression2yr, after(depression)

		tab1 anxiety2yr depression2yr, missing
	}
	
	//Fix denominators for section 2 variables restricted to diagnoses in last 2 years
	replace anypostbd = . if firstasthma < `end'-(2*365.25)
	replace postbdobstruction = . if firstasthma < `end'-(2*365.25)

	replace anyprebd = . if firstasthma < `end'-(2*365.25)
	replace prebdobstruction = . if firstasthma < `end'-(2*365.25)

	//replace anyobstruction = . if firstasthma < `end'-(2*365.25)

	replace anyspirom = . if firstasthma < `end'-(2*365.25)

	replace ratio_reverse = . if firstasthma < `end'-(2*365.25)

	replace spirom_reverse = . if firstasthma < `end'-(2*365.25)

	replace anypeakflow = . if firstasthma < `end'-(2*365.25)

	replace prepostpeakflow = . if firstasthma < `end'-(2*365.25)

	replace peakflowdiary = . if firstasthma < `end'-(2*365.25)

	replace feno = . if firstasthma < `end'-(2*365.25)


	//GENERATE OBJECTIVE MEASUREMENT VARIABLE
	gen byte objectivemeasure = (anyspirom == 1 | anypeakflow == 1 | feno == 1)
	replace objectivemeasure = . if firstasthma < `end'-(2*365.25)

	tab objectivemeasure


	//GENERATE SECOND-HAND SMOKE VARIABLE
	label define sh_smoke 0 "Not asked about second-hand smoke exposure" ///
						  1 "Not exposed to second-hand smoke" ///
						  2 "Exposed to second-hand smoke"

	gen byte sh_smoke = 0
	replace sh_smoke = 1 if no_second_hand_smoke == 1
	replace sh_smoke = 2 if second_hand_smoke == 1

	label values sh_smoke sh_smoke

	tab sh_smoke, missing


	//SMOKING STATUS
	merge 1:1 alf_pe using stata_data/`cohort'_smokstat
	drop if _merge == 2
	drop _merge
	
	merge 1:1 alf_pe using stata_data/`cohort'_smokerpast2yrs
	drop if _merge == 2
	drop _merge

	replace smokstat = 0 if smokstat == .
	replace smokerpast2yrs = 0 if smokerpast2yrs == .

	tab1 smokstat smokerpast2yrs, missing


	//EXACERBATIONS
	merge 1:1 alf_pe using stata_data/`cohort'_validated_exacerbation
	drop if _merge == 2
	drop _merge

	replace asthmaexacs = 0 if asthmaexacs == .

	tab1 asthmaexacs, missing

	//generate categories
	foreach var in asthmaexacs {

		gen     `var'_cat = `var'
		replace `var'_cat = 3 if `var' > 2

		label values `var'_cat exacer_cat

		tab `var'_cat, missing
	}

	
	//INHALER CHECK
	merge 1:1 alf_pe using stata_data/`cohort'_inhalerpastyr
	drop if _merge == 2
	drop _merge

	replace inhaler_pastyr = 0 if inhaler_pastyr == .
	tab inhaler_pastyr, missing

	tab inhalercheck
	replace inhalercheck = . if inhaler_pastyr == 0
	tab inhalercheck

	drop inhaler_pastyr

	
	//SMOKING CESSATION
	tab smokbcidrug smokerpast2yrs
	tab smokbcidrug
	replace smokbcidrug = . if smokerpast2yrs != 1
	tab smokbcidrug
	
	
	//INHALED THERAPY
	merge 1:1 alf_pe using stata_data/`cohort'_inhaledtherapy
	drop if _merge == 2
	drop _merge

	replace inhaledtherapy = 0 if inhaledtherapy == .

	tab1 inhaledtherapy therapy_type



	order objectivemeasure ///
		  anypeakflow_ever prepostpeakflow_ever peakflowdiary_ever ///
		  anypeakflow prepostpeakflow peakflowdiary ///
		  feno ///
		  anypostbd anyprebd postbdobstruction prebdobstruction /*anyobstruction*/ ///
		  anyspirom ratio_reverse spirom_reverse ///
		  ocscourses3ormore ocs3plusref ///
		  smokstat smokerpast2yrs ///
		  second_hand_smoke no_second_hand_smoke sh_smoke ///
		  asthmaexacs asthmaexacs_cat ///
		  paap rcp3 ///
		  saba_morethan2 ics_lessthan6 ///
		  inhalercheck ///
		  fluvax ///
		  smokbcidrug ///
		  inhaledtherapy, before(therapy_type)


	save builds/`cohort'_cohort_final, replace
}


log close