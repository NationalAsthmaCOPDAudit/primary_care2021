clear all
set more off
//set trace on

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/Import, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"


//ADULT ASTHMA
local filenames: dir "`data_dir'/Adult Asthma" files "*.csv"

foreach file of local filenames {
	
	display "Importing: `file'"
	
	import delimited "`data_dir'/Adult Asthma/`file'", clear
	
	local filename = "aa_" + substr("`file'", 8, 3)
	display "`filename'"
	
	save "stata_data/`filename'", replace
}

//ADULT ASTHMA COMORBIDITIES
import delimited "`data_dir'/SS_ASTHMA_ADULTS_COMORBIDITY_202203311056", clear

save "stata_data/aa_comorbidities", replace


//CHILD ASTHMA
local filenames: dir "`data_dir'/Child Asthma" files "*.csv"

foreach file of local filenames {
	
	display "Importing: `file'"
	
	import delimited "`data_dir'/Child Asthma/`file'", clear
	
	local filename = "ca_" + substr("`file'", 8, 3)
	display "`filename'"
	
	save "stata_data/`filename'", replace
}

//CHILD ASTHMA COMORBIDITIES
import delimited "`data_dir'/SS_ASTHMA_CHILD_COMORBIDITY_202203311058", clear

save "stata_data/ca_comorbidities", replace


//COPD
local filenames: dir "`data_dir'/COPD" files "*.csv"

foreach file of local filenames {
	
	display "Importing: `file'"
	
	import delimited "`data_dir'/COPD/`file'", clear
	
	local filename = "copd_" + substr("`file'", 8, 3)
	display "`filename'"
	
	save "stata_data/`filename'", replace
}


//BMI
import delimited "`data_dir'/BMI/SS_22K_FLAG_ASTHMA_202202101546", clear

save "stata_data/aa_bmi", replace


import delimited "`data_dir'/BMI/SS_22K_FLAG_COPD_202202101547", clear

save "stata_data/copd_bmi", replace


//COPD COMORBIDITIES
import delimited "`data_dir'/SS_COPD_COMORBIDITY_202204011540", clear

save "stata_data/copd_comorbidities", replace


//set trace off
log close