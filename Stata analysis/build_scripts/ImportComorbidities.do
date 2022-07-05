clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/ImportComorbidities, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end

/*
//ADULT ASTHMA
local filenames: dir "`data_dir'/Adult Asthma/Comorbidity" files "*.csv"

foreach file of local filenames {
	
	display "Importing: `file'"
	
	import delimited "`data_dir'/Adult Asthma/Comorbidity/`file'", clear
	
	local filename = "aa_cm_" + strreverse(substr(strreverse(substr("`file'", 17, .)), 18, .))
	display "`filename'"
	
	
	keep alf_pe event_cd event_dt
	
	gen cm_date = date(event_dt, "YMD")
	format %td cm_date
	drop event_dt
	
	bysort alf_pe: keep if _n == 1
	gen byte `filename' = 1
		
	
	compress
	save "stata_data/`filename'", replace
}


//CHILD ASTHMA
local filenames: dir "`data_dir'/Child Asthma/Comorbidities" files "*.csv"

foreach file of local filenames {
	
	display "Importing: `file'"
	
	import delimited "`data_dir'/Child Asthma/Comorbidities/`file'", clear
	
	local filename = "ca_cm_" + strreverse(substr(strreverse(substr("`file'", 10, .)), 18, .))
	display "`filename'"
	
	
	keep alf_pe event_cd event_dt
	
	gen cm_date = date(event_dt, "YMD")
	format %td cm_date
	drop event_dt
	
	bysort alf_pe: keep if _n == 1
	gen byte `filename' = 1
	
	
	compress
	save "stata_data/`filename'", replace
}
*/
/*
//COPD
local filenames: dir "`data_dir'/COPD Comorbidity breakdown" files "*.csv"

foreach file of local filenames {
	
	display "Importing: `file'"
	
	import delimited "`data_dir'/COPD Comorbidity breakdown/`file'", clear
	
	local filename = "copd_" + substr("`file'", 8, 3)
	display "`filename'"
	
	save "stata_data/`filename'", replace
}
*/


import delimited "`data_dir'/COPD Comorbidity breakdown/SS_COPD_ASTHMA_202204010933", clear

keep alf_pe event_cd event_dt


gen firstasthma = date(event_dt, "YMD")
format %td firstasthma
drop event_dt

drop if firstasthma > `end'


gen resolved = (event_cd == "21262" | event_cd == "212G.")

gsort alf_pe -firstasthma -resolved

by alf_pe: drop if resolved[1] == 1


drop if resolved == 1

gsort alf_pe firstasthma

by alf_pe: keep if _n == 1


keep alf_pe firstasthma


compress
save stata_data/copd_firstasthma, replace


log close