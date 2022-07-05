clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/COPD_analyseddata_byLHB, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 Primary Care Audit"


use builds/copd_cohort_final, clear


drop localhealthboardcode gp_practice_cluster_code
drop alf_pe local_num_pe wob firstcopd firstcopd_in_audit /*mrc_grade_ever*/ mrc3yr copdexacerbations smokerpast2yrs

order asthma bronchiectasis chd diabetes heart_failure hypertension lung_cancer ///
	  stroke osteoporosis obese serious_mental_illness anxiety anxiety2yr ///
	  depression depression2yr learning_disability, after(wimd_quintile)


local binaryvars "asthma bronchiectasis chd diabetes heart_failure hypertension"
local binaryvars "`binaryvars' lung_cancer stroke osteoporosis obese"
local binaryvars "`binaryvars' serious_mental_illness anxiety anxiety2yr"
local binaryvars "`binaryvars' depression depression2yr learning_disability"
local binaryvars "`binaryvars' anypostbd postbdobstruction anyobstruction xrayin6months"
local binaryvars "`binaryvars' fev1pp o2assess_single"
//local binaryvars "`binaryvars' o2assess_persist"
local binaryvars "`binaryvars' mrc35_prref anymrc_prref inhalercheck fluvax smokbcidrug"
local binaryvars "`binaryvars' inhaledtherapy"


//remove LHBs with too few patients
tab localhealthboardname
tab gp_practice_cluster_name if localhealthboardname == "Cwm Taf ULHB"
tab gp_practice_cluster_name if localhealthboardname == "Powys Teaching LHB"

drop if localhealthboardname == "Cwm Taf ULHB"
drop if localhealthboardname == "Powys Teaching LHB"


//encode practices and clusters with numeric categories (no gaps) and labels that match var names
drop prac_cd_pe

encode gp_practice_cluster_name, gen(clustername)
order clustername, after(gp_practice_cluster_name)
drop gp_practice_cluster_name

encode localhealthboardname, gen(lhb)
order lhb, after(localhealthboardname)
drop localhealthboardname


local levels "lhb clustername"

foreach level of local levels {

	preserve
	
	if "`level'" == "clustername" {
		
		local suppression = 87
		
		//drop lhb
	}
	else if "`level'" == "lhb" {

		local suppression = 80
		
		drop clustername
	}
	
	gensumstat age, by(`level')
	drop age
	
	foreach binaryvar of local binaryvars {
		
		if "`binaryvar'" != "learning_disability" {
			
			gensupnumdenom `binaryvar', by(`level') sup(`suppression')
		}
		drop `binaryvar'
	}

	gensupnumdenom gender, num(2) by(`level') sup(`suppression')
	drop gender

	gensupnumdenom wimd_quintile, num(5) by(`level') sup(`suppression')
	drop wimd_quintile

	gensupnumdenom mrc_grade, num(5) zero by(`level') sup(`suppression')
	drop mrc_grade

	gensupnumdenom smokstat, num(3) zero by(`level') sup(`suppression')
	drop smokstat

	gensupnumdenom copdexacerbations_cat, num(3) zero by(`level') sup(`suppression')
	drop copdexacerbations_cat

	gensupnumdenom therapy_type, num(6) by(`level') sup(`suppression')
	drop therapy_type


	by `level': keep if _n == 1
	
	if "`level'" == "clustername" {
		
		gsort lhb clustername
	}

	export delimited outputs/AnalysedPrimaryCareAudit_COPD_`level', replace
	
	restore
}


log close