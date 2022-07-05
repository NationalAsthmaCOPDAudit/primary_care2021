clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/AsthmaExacerbations, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end

local year = 1.25*365.25   //one year defined as 15 months


foreach cohort in aa ca {
	
	use stata_data/`cohort'_q37, clear


	//format dates
	foreach datevar in event_dt {
		
		gen new_`datevar' = date(`datevar', "YMD")
		format %td new_`datevar'
		
		order new_`datevar', after(`datevar')
		drop `datevar'
		rename new_`datevar' `datevar'
	}


	//remove dates outside study period
	drop if event_dt > `end'

	//just want dates from past year
	drop if event_dt < `end'-`year'


	drop if event_dt < `end'-365.25   //just from the past 12 months


	tab category, missing
	gen annualreview = (category == "Annual review")


	//remove patients that only have annual review codes
	gsort alf_pe annualreview
	by alf_pe: drop if annualreview[1] == 1


	gsort alf_pe event_dt -annualreview


	//exclude prescriptions on same day as review
	//exclude events closer than 14 days
	//count events

	by alf_pe event_dt: gen byte revday = 1 if annualreview[1] == 1


	gsort alf_pe annualreview event_dt


	//Mark events to be excluded if they are closer together than 14 days
	by alf_pe: gen byte exclude = 1 if event_dt[_n-1]+14 > event_dt & _n != 1 ///
										   & annualreview == 0

	//Mark exacerbations
	by alf_pe: gen byte asthmaexac = 1 if exclude != 1 & revday != 1

	by alf_pe: egen asthmaexacs = total(asthmaexac)

	by alf_pe: keep if _n == 1

	tab asthmaexacs, missing


	keep alf_pe asthmaexacs

	compress
	save stata_data/`cohort'_validated_exacerbation, replace
}

log close