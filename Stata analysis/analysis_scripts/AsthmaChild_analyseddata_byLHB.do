clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"

capture log close
log using analysis_logs/AsthmaChild_analyseddata_byLHB, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 Primary Care Audit"


use builds/ca_cohort_final, clear


drop localhealthboardcode gp_practice_cluster_code
drop alf_pe local_num_pe wob firstasthma firstasthma_in_audit asthmaexacs smokerpast2yrs second_hand_smoke no_second_hand_smoke

order eczema atopy nasal_polyps reflux hayfever family_history_of_asthma ///
	  allergic_rhinitis mental_health_issues_paeds learning_disability, after(wimd_quintile)

order anyprebd, after(anypostbd)


local binaryvars "eczema atopy nasal_polyps reflux hayfever"
local binaryvars "`binaryvars' family_history_of_asthma allergic_rhinitis"
local binaryvars "`binaryvars' mental_health_issues_paeds learning_disability"
local binaryvars "`binaryvars' anypostbd anyprebd postbdobstruction prebdobstruction"
//local binaryvars "`binaryvars' anyobstruction"
local binaryvars "`binaryvars' anyspirom ratio_reverse spirom_reverse"
local binaryvars "`binaryvars' anypeakflow_ever prepostpeakflow_ever peakflowdiary_ever"
local binaryvars "`binaryvars' anypeakflow prepostpeakflow peakflowdiary feno"
local binaryvars "`binaryvars' objectivemeasure ocscourses3ormore ocs3plusref"
local binaryvars "`binaryvars' paap rcp3 saba_morethan2 ics_lessthan6 inhalercheck"
local binaryvars "`binaryvars' fluvax smokbcidrug inhaledtherapy"


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
local suppression = 85

foreach level of local levels {

	preserve
	
	if "`level'" == "clustername" {
		
		local suppression = 85
		
		//drop lhb
	}
	else if "`level'" == "lhb" {

		local suppression = 85
		
		drop clustername
	}
	
	gensumstat age, by(`level')
	drop age
	
	foreach binaryvar of local binaryvars {
		
		gensupnumdenom `binaryvar', by(`level') sup(`suppression')
		drop `binaryvar'
	}

	gensupnumdenom gender, num(2) by(`level') sup(`suppression')
	drop gender
	
	//WIMD not possible at cluster level
	if "`level'" == "lhb" {
		
		gensupnumdenom wimd_quintile, num(5) by(`level') sup(`suppression')
	}
	drop wimd_quintile
	
	//Smoking status not possible at cluster level
	if "`level'" == "lhb" {
	
		gensupnumdenom smokstat, num(3) zero by(`level') sup(`suppression')
	}
	drop smokstat
		
	//gensupnumdenom sh_smoke, num(2) zero by(`level') sup(`suppression')
	drop sh_smoke

	gensupnumdenom asthmaexacs_cat, num(3) zero by(`level') sup(`suppression')
	drop asthmaexacs_cat

	//gensupnumdenom therapy_type, num(6) by(`level') sup(`suppression')
	drop therapy_type
	
	
	by `level': keep if _n == 1
	
	if "`level'" == "clustername" {
		
		gsort lhb clustername
	}

	export delimited outputs/AnalysedPrimaryCareAudit_AsthmaChild_`level', replace

	restore
}


log close