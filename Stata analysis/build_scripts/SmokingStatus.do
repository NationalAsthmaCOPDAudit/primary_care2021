clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/SmokingStatus, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end

local year = 1.25*365.25   //one year defined as 15 months


foreach cohort in aa ca copd {
	
	use stata_data/`cohort'_q35, clear


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
	
	
	//define smoking status label
	label define smokstat 0 "Not asked about smoking" 1 "Never smoker" 2 "Ex smoker" ///
						  3 "Current smoker"
	gen byte smokstat = 1 if category == "Never smoker"
	replace smokstat = 2 if category == "Ex smoker"
	replace smokstat = 3 if category == "Current smoker"
	label values smokstat smokstat
	drop category
	
	
	//sort with most recent records on top, most severe status on top
	gsort alf_pe -event_dt -smokstat
	
	
	//generate var to flag ever smokers
	gen eversmoke = 1 if smokstat == 2 | smokstat == 3
	by alf_pe: egen eversmoke_max = max(eversmoke)
	
	
	preserve
	
	
	//just want dates from past year
	drop if event_dt < `end'-`year'
	

	by alf_pe: keep if _n == 1

	//make never-smokers ex-smokers if they have smoking code in the past
	replace smokstat = 2 if smokstat == 1 & eversmoke_max == 1


	keep alf_pe smokstat

	compress
	save stata_data/`cohort'_smokstat, replace
	
	
	restore
	
	
	//just want dates from past 2 years
	drop if event_dt < `end' - (`year' * 2)
	
	
	//replace with ever smokers from past 2 years
	by alf_pe: egen smokerpast2yrs = max(eversmoke)
	
	
	by alf_pe: keep if _n == 1
	
	keep alf_pe smokerpast2yrs
	
	
	compress
	save stata_data/`cohort'_smokerpast2yrs, replace
}


log close