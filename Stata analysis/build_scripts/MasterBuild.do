clear all
set more off

cd "S:\1317 - Asthma and COPD Audit Programme (NACAP)\stata"


//MASTER DO FILE FOR BUILDING DATASETS


do build_scripts/Import
do build_scripts/ImportComorbidities

do build_scripts/Build_Asthma
do build_scripts/Build_COPD

do build_scripts/SmokingStatus

do build_scripts/COPD_MRC

do build_scripts/AsthmaExacerbations
do build_scripts/COPDExacerbations

do build_scripts/Asthma_InhaledTherapy
do build_scripts/COPD_InhaledTherapy

do build_scripts/Asthma_Finalise
do build_scripts/COPD_Finalise