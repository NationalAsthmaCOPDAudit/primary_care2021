clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/COPD_MRC, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end

local year = 1.25*365.25   //one year defined as 15 months


use stata_data/copd_mrc, clear


//format dates
foreach datevar in event_dt {
	
	gen new_`datevar' = date(`datevar', "YMD")
	format %td new_`datevar'
	
	order new_`datevar', after(`datevar')
	drop `datevar'
	rename new_`datevar' `datevar'
}


//sort by patient and most recent first
gsort alf_pe -event_dt


preserve
	
	
//just want dates from past year
drop if event_dt < `end'-`year'


//just keep most recent for each patient
by alf_pe: keep if _n == 1


rename latest_mrc mrc_grade

keep alf_pe mrc_grade


compress
save stata_data/copd_mrc_grade, replace


restore


//just want dates from past 3 years
drop if event_dt < `end'-(`year'*3)


//just keep most recent for each patient
by alf_pe: keep if _n == 1


rename latest_mrc mrc3yr

keep alf_pe mrc3yr


compress
save stata_data/copd_mrc3yr, replace


log close