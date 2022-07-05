clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using build_logs/COPD_Finalise, text replace


local work_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"
local data_dir "S:\1317 - Asthma and COPD Audit Programme (NACAP)\CSV Files"

local start = date("2020-04-01", "YMD")       //study start
local end = date("2021-09-30", "YMD")         //study end


label define exacer_cat 3 ">2"


use builds/copd_cohort_initial, clear


//Asthma comorbidity fix
merge 1:1 alf_pe using stata_data/copd_firstasthma
drop if _merge == 2
drop _merge

order firstasthma, before(asthma)

tab asthma, missing

replace asthma = 0 if firstasthma == .

//asthma misdiagnosis if less than 2 years before COPD diagnosis
replace asthma = 0 if firstcopd < firstasthma + (2*365.25)

tab asthma, missing
drop firstasthma


//Screening (sort of) fix
tab1 anxiety2yr depression2yr, missing
drop anxiety2yr depression2yr

preserve

use builds/copd_cohort_final_2022-03-28, clear

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


//Fix denominators for section 2 variables restricted to diagnoses in last 2 years
replace anypostbd = . if firstcopd < `end'-(2*365.25)
replace postbdobstruction = . if firstcopd < `end'-(2*365.25)

replace anyobstruction = . if firstcopd < `end'-(2*365.25)

replace xrayin6months = . if firstcopd < `end'-(2*365.25)


//MRC GRADE
merge 1:1 alf_pe using stata_data/copd_mrc_grade
drop if _merge == 2
drop _merge

merge 1:1 alf_pe using stata_data/copd_mrc3yr
drop if _merge == 2
drop _merge

replace mrc_grade = 0 if mrc_grade == .
replace mrc3yr = 0 if mrc3yr == .

label define mrc_grade 0 "Not recorded"
label values mrc_grade mrc_grade mrc3yr

tab1 mrc_grade mrc3yr, missing


//SMOKING STATUS
merge 1:1 alf_pe using stata_data/copd_smokstat
drop if _merge == 2
drop _merge

merge 1:1 alf_pe using stata_data/copd_smokerpast2yrs
drop if _merge == 2
drop _merge

replace smokstat = 0 if smokstat == .
replace smokerpast2yrs = 0 if smokerpast2yrs == .

tab1 smokstat smokerpast2yrs, missing


//EXACERBATIONS
merge 1:1 alf_pe using stata_data/copd_validated_exacerbation
drop if _merge == 2
drop _merge

replace copdexacerbations = 0 if copdexacerbations == .

tab1 copdexacerbations, missing


//generate categories
label define exacer_cat 3 ">2"

foreach var in copdexacerbations {

	gen     `var'_cat = `var'
	replace `var'_cat = 3 if `var' > 2

	label values `var'_cat exacer_cat

	tab `var'_cat, missing
}


//PULMONARY REHAB - **USE MRC EVER IF AVAILABLE**
tab mrc3yr mrc35_prref

replace mrc35_prref = . if mrc3yr < 3 | mrc3yr == .

tab mrc3yr mrc35_prref
tab mrc35_prref


tab mrc3yr anymrc_prref

replace anymrc_prref = . if mrc3yr == 0 | mrc3yr == .

tab mrc3yr anymrc_prref
tab anymrc_prref


//INHALER CHECK
merge 1:1 alf_pe using stata_data/copd_inhalerpastyr
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
merge 1:1 alf_pe using stata_data/copd_inhaledtherapy
drop if _merge == 2
drop _merge

replace inhaledtherapy = 0 if inhaledtherapy == .

tab1 inhaledtherapy therapy_type



order anypostbd postbdobstruction anyobstruction ///
	  xrayin6months ///
	  mrc_grade mrc3yr ///
	  fev1pp ///
	  o2assess_single /*o2assess_persist*/ ///
	  smokstat smokerpast2yrs ///
	  copdexacerbations copdexacerbations_cat ///
	  mrc35_prref anymrc_prref ///
	  inhalercheck ///
	  fluvax ///
	  smokbcidrug ///
	  inhaledtherapy therapy_type, after(obese)

//no presistent low O2 var or MRC grade


save builds/copd_cohort_final, replace


log close