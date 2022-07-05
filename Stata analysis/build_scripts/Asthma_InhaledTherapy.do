clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/Asthma_InhaledTherapy, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end

local year = 1.25*365.25   //one year defined as 15 months


foreach cohort in aa ca {
	
	use stata_data/`cohort'_q49, clear


	keep alf_pe event_cd category event_dt term

	//format date
	gen presc_dt = date(event_dt, "YMD")
	format %td presc_dt
	drop event_dt


	//remove dates outside study period
	drop if presc_dt > `end'
	
	
	//just want prescriptions from the past year
	drop if presc_dt < `end'-`year'

	preserve

	gen byte inhaler_pastyr = 1

	bysort alf_pe: keep if _n == 1

	keep alf_pe inhaler_pastyr

	compress
	save stata_data/`cohort'_inhalerpastyr, replace

	restore
	

	//just want prescriptions from the last 6 months
	drop if presc_dt < `end'-(0.5*365.25)


	tab category, missing
	keep if category == "ICS" | ///
			category == "LABA" | ///
			category == "LABA_ICS" | ///
			category == "LTRA"

	gsort alf_pe -presc_dt category

	gen byte inhaledtherapy = 1

	gen byte ics = 1 if category == "ICS" | category == "LABA_ICS"
	gen byte laba = 1 if category == "LABA" | category == "LABA_ICS"
	gen byte ltra = 1 if category == "LTRA"
	
	
	//therapy in the last 90 days
	by alf_pe: gen ics90 = 1 if presc_dt > presc_dt[1]-90 & ics == 1
	by alf_pe: gen laba90 = 1 if presc_dt > presc_dt[1]-90 & laba == 1
	by alf_pe: gen ltra90 = 1 if presc_dt > presc_dt[1]-90 & ltra == 1

	by alf_pe: egen ics90_max = max(ics90)
	by alf_pe: egen laba90_max = max(laba90)
	by alf_pe: egen ltra90_max = max(ltra90)
	
	/*
	//using full 6 months instead - comment out if changing back to 90 days
	by alf_pe: egen ics_max = max(ics)
	by alf_pe: egen laba_max = max(laba)
	by alf_pe: egen ltra_max = max(ltra)
	*/
	by alf_pe: keep if _n == 1

	drop ics laba ltra ics90 laba90 ltra90
	//drop ics laba ltra

	label define asthmatherapy 1 "ICS" 2 "LABA" 3 "LABA + ICS" 4 "LTRA" ///
							   5 "LTRA + ICS" 6 "LTRA + LABA + ICS"

	//Past 90 days code
	gen therapy_type = 1 if ics90_max == 1
	replace therapy_type = 2 if laba90_max == 1
	replace therapy_type = 4 if ltra90_max == 1

	replace therapy_type = 3 if laba90_max == 1 & ics90_max == 1

	replace therapy_type = 5 if ltra90_max == 1 & ics90_max == 1

	replace therapy_type = 6 if ltra90_max == 1 & laba90_max == 1 & ics90_max == 1
	
	/*
	//full 6 months
	gen therapy_type = 1 if ics_max == 1
	replace therapy_type = 2 if laba_max == 1
	replace therapy_type = 4 if ltra_max == 1

	replace therapy_type = 3 if laba_max == 1 & ics_max == 1

	replace therapy_type = 5 if ltra_max == 1 & ics_max == 1

	replace therapy_type = 6 if ltra_max == 1 & laba_max == 1 & ics_max == 1
	*/
	
	label values therapy_type asthmatherapy


	keep alf_pe inhaledtherapy therapy_type

	compress
	save stata_data/`cohort'_inhaledtherapy, replace
}


log close