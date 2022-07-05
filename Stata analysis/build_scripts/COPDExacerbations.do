clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/COPDExacerbations, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end

local year = 1.25*365.25   //one year defined as 15 months


use stata_data/copd_q37, clear


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

//Bottom = Exacerbations, LRTI
gen byte order = 3
//Top = Penicillins, Doxycycline, Marcolides, Quinolone
replace order = 1 if category == "Antibiotics"
//2nd = Oral steroids
replace order = 2 if category == "Oral steroids"

tab category order, missing

gsort alf_pe event_dt order

//Label antibiotics that have an oral steroid prescription on the same day
by alf_pe: gen byte ocs_ab_sameday = 1 ///
			if order == 1 & order[_n+1] == 2 & event_dt == event_dt[_n+1]

tab ocs_ab_sameday, missing

//Drop oral steroid prescriptions or antiobiotic prescriptions that don't occur on the same day
drop if order == 2 | (order == 1 & ocs_ab_sameday != 1)

//Mark events to be excluded if they are closer together than 14 days
by alf_pe: gen byte exclude = 1 if event_dt[_n-1]+14 > event_dt & _n != 1

tab exclude, missing

//Mark separate exacerbation events
by alf_pe: gen byte copdexacer = 1 if exclude != 1

//Generate total number of exacerbations for patient
by alf_pe: egen copdexacerbations = total(copdexacer)

by alf_pe: keep if _n == 1

tab copdexacerbations, missing

keep alf_pe copdexacerbations

compress
save stata_data/copd_validated_exacerbation, replace


log close