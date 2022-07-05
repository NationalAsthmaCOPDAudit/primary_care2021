clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/COPD_InhaledTherapy, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end

local year = 1.25*365.25   //one year defined as 15 months


use stata_data/copd_q49, clear


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
save stata_data/copd_inhalerpastyr, replace

restore


//just want prescriptions from the last 6 months
drop if presc_dt < `end'-(0.5*365.25)


tab category, missing
keep if category == "ICS" | ///
		category == "LABA" | ///
		category == "LABA_ICS" | ///
		category == "LAMA" | ///
		category == "LABA_LAMA"

gsort alf_pe -presc_dt category

gen byte inhaledtherapy = 1

gen byte ics = 1 if category == "ICS" | category == "LABA_ICS"
gen byte laba = 1 if category == "LABA" | category == "LABA_ICS" | category == "LABA_LAMA"
gen byte lama = 1 if category == "LAMA" | category == "LABA_LAMA"


//therapy in the last 90 days
by alf_pe: gen ics90 = 1 if presc_dt > presc_dt[1]-90 & ics == 1
by alf_pe: gen laba90 = 1 if presc_dt > presc_dt[1]-90 & laba == 1
by alf_pe: gen lama90 = 1 if presc_dt > presc_dt[1]-90 & lama == 1

by alf_pe: egen ics90_max = max(ics90)
by alf_pe: egen laba90_max = max(laba90)
by alf_pe: egen lama90_max = max(lama90)

/*
//Using whole 6 months instead (comment out if going back to 90 days)
by alf_pe: egen ics_max = max(ics)
by alf_pe: egen laba_max = max(laba)
by alf_pe: egen lama_max = max(lama)
*/
by alf_pe: keep if _n == 1

drop ics laba lama ics90 laba90 lama90
//drop ics laba lama

label define copdtherapy 1 "ICS" 2 "LABA" 3 "LABA + ICS" 4 "LAMA" 5 "LABA + LAMA" ///
						 6 "Triple therapy"

//PAST 90 DAY CODE
gen therapy_type = 1 if ics90_max == 1
replace therapy_type = 2 if laba90_max == 1
replace therapy_type = 4 if lama90_max == 1

replace therapy_type = 3 if laba90_max == 1 & ics90_max == 1

replace therapy_type = 5 if laba90_max == 1 & lama90_max == 1

replace therapy_type = 6 if laba90_max == 1 & lama90_max == 1 & ics90_max == 1

/*
//Whole 6 months code - comment out if changing
gen therapy_type = 1 if ics_max == 1
replace therapy_type = 2 if laba_max == 1
replace therapy_type = 4 if lama_max == 1

replace therapy_type = 3 if laba_max == 1 & ics_max == 1

replace therapy_type = 5 if laba_max == 1 & lama_max == 1

replace therapy_type = 6 if laba_max == 1 & lama_max == 1 & ics_max == 1
*/

label values therapy_type copdtherapy

keep alf_pe inhaledtherapy therapy_type

compress
save stata_data/copd_inhaledtherapy, replace


log close