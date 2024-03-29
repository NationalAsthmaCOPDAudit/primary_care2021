---- Part 6 -- GRAND COHORT THREE - COPD Patients Audit Queries -------------------------------------------------------------------------------------------------------  

DECLARE GLOBAL TEMPORARY TABLE GC3 AS (
SELECT * FROM sailw1317v.SS_COPD_COMORBIDITY
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

----2.1 FEV1/FVC ratio
--Any ratio codes >=0.2 and <0.7
--Post-bronchodilator code (339m.) >=0.2 and <0.7
--No 339m. code

SELECT * FROM sailw1317v.AQ21_FEV1FVC_RATIO affr 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q21_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT, wgec.EVENT_VAL 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ21_FEV1FVC_RATIO AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT > '2019-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q21 AS ( SELECT wgec.* 
, CASE WHEN wgec.ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q21_Events WHERE EVENT_VAL BETWEEN '0.2' AND '0.7') THEN 1 ELSE 0 END AS Ratio_Code_Flag
, CASE WHEN wgec.ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q21_Events WHERE EVENT_CD = '339m.' AND EVENT_VAL BETWEEN '0.2' AND '0.7') THEN 1 ELSE 0 END AS Post_bronchodilator_Ratio_Code_Flag
, CASE WHEN wgec.ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q21_Events WHERE EVENT_CD In('339m.') GROUP BY ALF_PE) THEN 1 ELSE 0 END AS No_Post_bronchodilator_Ratio_Code_Flag
FROM sailw1317v.SS_COPD_COMORBIDITY wgec 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;


SELECT * FROM SESSION.GC3_Q21
ORDER BY ALF_PE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q21

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q21(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, Ratio_Code_Flag int
, Post_bronchodilator_Ratio_Code_Flag int
, No_Post_bronchodilator_Ratio_Code_Flag int)

INSERT INTO  sailw1317v.SS_GC3_Q21
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, Ratio_Code_Flag 
, Post_bronchodilator_Ratio_Code_Flag 
, No_Post_bronchodilator_Ratio_Code_Flag
FROM SESSION.GC3_Q21

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q21

----2.2 Chest X-ray (CXR) or CT scan
--CXR/CT within 6 months of diagnosis (6 months pre/post diagnosis)
SELECT COUNT(*) FROM sailw1317v.SS_COPD_COMORBIDITY

SELECT * FROM sailw1317v.AQ22_XRAY ax 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q22_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ22_XRAY AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q22 AS ( SELECT wgec.* 
, CASE WHEN SCC.EVENT_DT BETWEEN FIRST_EVENT AND (FIRST_EVENT + 6 MONTHS) AND SCC.EVENT_CD IN(SELECT EVENT_CD FROM sailw1317v.AQ22_XRAY) THEN 1 ELSE 0 END AS XRAY_FLAG_POST_DIAGNOSIS
FROM sailw1317v.SS_COPD_COMORBIDITY wgec 
INNER JOIN SESSION.Cohort3_Q22_Events SCC ON wgec.ALF_PE = scc.ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC3_Q22
ORDER BY ALF_PE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q22

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q22(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, XRAY_FLAG_POST_DIAGNOSIS INT)

INSERT INTO  sailw1317v.SS_GC3_Q22
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, XRAY_FLAG_POST_DIAGNOSIS
FROM SESSION.GC3_Q22

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT DISTINCT * FROM sailw1317v.SS_GC3_Q22
ORDER BY ALF_PE 

--3.1 MRC grade
--Proportion of each score or ‘not recorded’ in the past year
SELECT * FROM sailw1317v.AQ31_MRC am 

--calculate latest MRC GRADE 
DECLARE GLOBAL TEMPORARY TABLE LATEST_EVENT AS( SELECT wgec.ALF_PE, MAX(wgec.EVENT_DT) AS LATEST_DATE
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec  
INNER JOIN sailw1317v.AQ31_MRC AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = AAC.EVENT_CD
GROUP BY wgec.ALF_PE
ORDER BY wgec.ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE LATEST_MRC AS( 
SELECT wgec.ALF_PE, MRC_GRADE, LATEST_DATE 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec  
INNER JOIN sailw1317v.AQ31_MRC AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
INNER JOIN SESSION.LATEST_EVENT le ON le.LATEST_DATE = wgec.EVENT_DT AND le.ALF_PE = wgec.ALF_PE 
WHERE le.LATEST_DATE = wgec.EVENT_DT
GROUP BY wgec.ALF_PE, MRC_GRADE, LATEST_DATE 
ORDER BY wgec.ALF_PE, MRC_GRADE, LATEST_DATE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q31_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, AAC.MRC_GRADE, wgec.EVENT_DT, le.MRC_GRADE AS LATEST_MRC 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec  
INNER JOIN sailw1317v.AQ31_MRC AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
LEFT JOIN SESSION. LATEST_MRC le ON le.LATEST_DATE = wgec.EVENT_DT AND le.ALF_PE = wgec.ALF_PE 
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2020-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q31_Events2 AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, AAC.MRC_GRADE, wgec.EVENT_DT, le.MRC_GRADE AS LATEST_MRC 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec  
INNER JOIN sailw1317v.AQ31_MRC AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
LEFT JOIN SESSION. LATEST_MRC le ON le.LATEST_DATE = wgec.EVENT_DT AND le.ALF_PE = wgec.ALF_PE 
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2018-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q31_Events3 AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, AAC.MRC_GRADE, wgec.EVENT_DT, le.MRC_GRADE AS LATEST_MRC 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec  
INNER JOIN sailw1317v.AQ31_MRC AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
LEFT JOIN SESSION. LATEST_MRC le ON le.LATEST_DATE = wgec.EVENT_DT AND le.ALF_PE = wgec.ALF_PE 
WHERE wgec.EVENT_CD = aac.EVENT_CD
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- 1 YEAR
DECLARE GLOBAL TEMPORARY TABLE GC3_Q312 AS (
SELECT saa.ALF_PE, saa.EVENT_CD , saa.EVENT_DT, TERM, LATEST_MRC
FROM sailw1317v.SS_COPD_COMORBIDITY saa
LEFT JOIN SESSION.Cohort3_Q31_Events wgec ON  wgec.ALF_PE = saa.ALF_PE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q31 AS (
SELECT LATEST_MRC, COUNT(DISTINCT ALF_PE) AS NUMBER_OF_PATIENTS FROM SESSION.GC3_Q312
GROUP BY LATEST_MRC
ORDER BY LATEST_MRC
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- 3 YEARS

DECLARE GLOBAL TEMPORARY TABLE GC3_Q313 AS (
SELECT saa.ALF_PE, saa.EVENT_CD , saa.EVENT_DT, TERM, LATEST_MRC
FROM sailw1317v.SS_COPD_COMORBIDITY saa
LEFT JOIN SESSION.Cohort3_Q31_Events2 wgec ON  wgec.ALF_PE = saa.ALF_PE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q31v2 AS (
SELECT LATEST_MRC, COUNT(DISTINCT ALF_PE) AS NUMBER_OF_PATIENTS FROM SESSION.GC3_Q313
GROUP BY LATEST_MRC
ORDER BY LATEST_MRC
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC3_Q31

-- ALL TIME

DECLARE GLOBAL TEMPORARY TABLE GC3_Q314 AS (
SELECT saa.ALF_PE, saa.EVENT_CD , saa.EVENT_DT, TERM, LATEST_MRC
FROM sailw1317v.SS_COPD_COMORBIDITY saa
LEFT JOIN SESSION.Cohort3_Q31_Events3 wgec ON  wgec.ALF_PE = saa.ALF_PE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q31v3 AS (
SELECT LATEST_MRC, COUNT(DISTINCT ALF_PE) AS NUMBER_OF_PATIENTS FROM SESSION.GC3_Q314
GROUP BY LATEST_MRC
ORDER BY LATEST_MRC
) WITH DATA WITH replace ON commit PRESERVE ROWS ;


-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q31

-- Create perminent table - One year
CREATE TABLE sailw1317v.SS_GC3_Q31(
LATEST_MRC VARCHAR(100) 
,NUMBER_OF_PATIENTS INT)

INSERT INTO  sailw1317v.SS_GC3_Q31
SELECT LATEST_MRC 
,NUMBER_OF_PATIENTS
FROM SESSION.GC3_Q31

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q31

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q312

-- Create perminent table - 3 years 
CREATE TABLE sailw1317v.SS_GC3_Q312(
LATEST_MRC VARCHAR(100) 
,NUMBER_OF_PATIENTS INT)

INSERT INTO  sailw1317v.SS_GC3_Q312
SELECT LATEST_MRC 
,NUMBER_OF_PATIENTS
FROM SESSION.GC3_Q31v2

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q312

-- Create perminent table - All Time 
CREATE TABLE sailw1317v.SS_GC3_Q313(
LATEST_MRC VARCHAR(100) 
,NUMBER_OF_PATIENTS INT)

INSERT INTO  sailw1317v.SS_GC3_Q313
SELECT LATEST_MRC 
,NUMBER_OF_PATIENTS
FROM SESSION.GC3_Q31v3

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q313


----3.2 FEV1 %-predicted
--Recorded in the last year
SELECT * FROM sailw1317v.AQ32_FEV1_PCPREDICTED afp 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q32_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ32_FEV1_PCPREDICTED AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2020-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q32 AS (
SELECT saa.* 
, CASE WHEN saa.ALF_PE IN (SELECT DISTINCT ALF_PE FROM SESSION.Cohort3_Q32_Events) THEN 1 ELSE 0 END AS PAAP_LAST_YEAR
FROM sailw1317v.SS_COPD_COMORBIDITY saa
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC3_32
ORDER BY ALF_PE


-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q32

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q32(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, PAAP_LAST_YEAR INT)

INSERT INTO  sailw1317v.SS_GC3_Q32
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, PAAP_LAST_YEAR
FROM SESSION.GC3_Q32

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q32


----3.3 Oxygen saturation -- WIP
--People with a single oxygen saturation of 92% or less in the past 2 years
--People with at least 2 measurements (within 3 months of each other) of oxygen saturation 92% or less in the past 2 years
SELECT * FROM sailw1317v.AQ33_OXYGEN_SAT aos 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q33_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT, wgec.EVENT_VAL 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ33_OXYGEN_SAT AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2019-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q33 AS ( 
SELECT wgec.* 
, CASE WHEN wgec.ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q33_Events WHERE EVENT_VAL < '92'GROUP BY ALF_PE HAVING (COUNT(DISTINCT ALF_PE) = 1)) THEN 1 ELSE 0 END AS LESS_THAN_92_OXYGEN_SAT
FROM sailw1317v.SS_COPD_COMORBIDITY wgec 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.Cohort3_Q33_Events

SELECT * FROM SESSION.GC3_Q33
ORDER BY ALF_PE

--, CASE WHEN wgec.ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q33_Events WHERE EVENT_VAL < '92' AND EVENT_DT = + 3 MONTHS) GROUP BY ALF_PE HAVING COUNT(ALF_PE) >= 2) THEN 1 ELSE 0 END AS LESS_THAN_92_OXYGEN_SAT_TWICE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q33

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q33(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, LESS_THAN_92_OXYGEN_SAT INT)

INSERT INTO  sailw1317v.SS_GC3_Q33
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, LESS_THAN_92_OXYGEN_SAT
FROM SESSION.GC3_Q33

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q33

----3.5 Smoking status
--Number of people with each smoking status or ‘not asked about smoking’ in the past year
 SELECT * FROM sailw1317v.AQ35_SMOKING_STATUS ass 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q35_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT, AAC.CATEGORY 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ35_SMOKING_STATUS AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2019-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q35 AS(
SELECT * FROM SESSION.Cohort3_Q35_Events
GROUP BY ALF_PE, EVENT_CD, TERM, EVENT_DT, CATEGORY 
ORDER BY ALF_PE, EVENT_DT
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- DROP TABLE FOR ALTERATIONS 
DROP TABLE sailw1317v.SS_GC3_Q35

--CREATE PERMINENT TABLE
CREATE TABLE sailw1317v.SS_GC3_Q35
(
 ALF_PE VARCHAR(100), EVENT_CD VARCHAR(100), TERM VARCHAR(100), EVENT_DT DATE, CATEGORY VARCHAR(100)
)

INSERT INTO  sailw1317v.SS_GC3_Q35
SELECT 
ALF_PE, EVENT_CD, TERM, EVENT_DT, CATEGORY 
FROM SESSION.GC3_Q35 
ORDER BY ALF_PE, EVENT_DT

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q35


--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q35

----3.7 Exacerbations 

SELECT * FROM sailw1317v.AQ37_ASTHMA_ATTACKS Q37

DECLARE GLOBAL TEMPORARY TABLE Cohort_Q37_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, AAC.CATEGORY, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ37_COPD_EXACERBATIONS AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2020-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q37 as(
SELECT * FROM SESSION.Cohort_Q37_Events
GROUP BY ALF_PE, EVENT_CD, TERM, CATEGORY, EVENT_DT
ORDER BY ALF_PE, EVENT_DT
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC3_Q37
ORDER BY ALF_PE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q37

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q37(
ALF_PE VARCHAR(100)
, EVENT_CD VARCHAR(100)
, TERM VARCHAR(100)
, CATEGORY VARCHAR(100)
, EVENT_DT DATE)

INSERT INTO  sailw1317v.SS_GC3_Q37
SELECT ALF_PE 
, EVENT_CD 
, TERM 
, CATEGORY
, EVENT_DT 
FROM SESSION.GC3_Q37

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q37

----4.1 Pulmonary rehabilitation
--Referred to PR (with MRC >=3) in the past 3 years
--Referred to PR (any MRC score [exclude those without an MRC score]) in the past 3 years
SELECT * FROM sailw1317v.AQ41_PULMONARY_REHAB apr 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q41_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT, wgec.EVENT_VAL 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ41_PULMONARY_REHAB AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_DT BETWEEN '2018-11-01' AND '2021-11-01' 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q41 AS (SELECT wgec.* 
, CASE WHEN wgec.ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q41_Events WHERE EVENT_CD = '8H7u.' GROUP BY ALF_PE, EVENT_DT HAVING COUNT(ALF_PE) >= 3) THEN 1 ELSE 0 END AS More_Than_3_PR_Code_Flag
, CASE WHEN wgec.ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q41_Events) THEN 1 ELSE 0 END AS PR_Code_Flag
FROM sailw1317v.SS_COPD_COMORBIDITY wgec 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC3_Q41
ORDER BY ALF_PE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q41

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q41(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, More_Than_3_PR_Code_Flag INT
, PR_Code_Flag INT)

INSERT INTO  sailw1317v.SS_GC3_Q41
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, More_Than_3_PR_Code_Flag
, PR_Code_Flag
FROM SESSION.GC3_Q41

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q41


--4.6 Inhaler technique check
--Number of people prescribed an inhaler who have had their technique checked in the past year

SELECT * FROM sailw1317v.AQ46_INHALER_TECHNIQUE ait 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q46_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN  sailw1317v.AQ46_INHALER_TECHNIQUE AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2020-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q46 AS (
SELECT saa.* 
, CASE WHEN saa.ALF_PE IN (SELECT DISTINCT ALF_PE FROM SESSION.Cohort3_Q46_Events WHERE EVENT_CD NOT IN ('66Yv.', '663o.')) THEN 1 ELSE 0 END AS INHALER_CHECK_LAST_YEAR
FROM sailw1317v.SS_COPD_COMORBIDITY saa
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC3_46
ORDER BY ALF_PE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q46

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q46(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, INHALER_CHECK_LAST_YEAR INT)

INSERT INTO  sailw1317v.SS_GC3_Q46
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, INHALER_CHECK_LAST_YEAR
FROM SESSION.GC3_Q46

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q46

--4.7 Influenza immunisation
--Number of people receiving the flu vaccine in the preceding 1st August to 31st March

SELECT * FROM sailw1317v.AQ47_FLU_VAX afv 

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q47_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ47_FLU_VAX AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND wgec.EVENT_DT BETWEEN '2020-08-01' AND '2021-03-31'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q47 AS (
SELECT saa.* 
, CASE WHEN saa.ALF_PE IN (SELECT DISTINCT ALF_PE FROM SESSION.Cohort3_Q47_Events) THEN 1 ELSE 0 END AS FLU_VAX_FLAG
FROM sailw1317v.SS_COPD_COMORBIDITY saa
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT COUNT(DISTINCT ALF_PE) FROM SESSION.GC3_Q47 WHERE FLU_VAX_FLAG = '1' --25,444

SELECT * FROM SESSION.GC3_Q47
ORDER BY ALF_PE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q47

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q47(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, FLU_VAX_FLAG INT)

INSERT INTO  sailw1317v.SS_GC3_Q47
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, FLU_VAX_FLAG
FROM SESSION.GC3_Q47

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q47

--4.8 Smoking cessation  
--Number of people recorded as current smokers at any point in the last 2 years who received a referral for a behavioural change intervention AND a stop smoking drug prescription

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q48_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, AAC.CATEGORY, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ48_SMOKING_CESSATION AAC ON wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND WGEC.EVENT_DT BETWEEN '2019-11-01' AND '2021-11-01'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q48_EventsPT2 AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, AAC.CATEGORY, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ35_SMOKING_STATUS AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD AND WGEC.EVENT_DT BETWEEN '2019-11-01' AND '2021-11-01' AND CATEGORY = 'Current smoker'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT ALF_PE FROM SESSION.Cohort_Q48_Events GROUP BY ALF_PE  HAVING COUNT(DISTINCT CATEGORY) >= 2

DECLARE GLOBAL TEMPORARY TABLE GC3_Q48 AS (
SELECT saa.* 
, CASE WHEN saa.ALF_PE IN (SELECT DISTINCT ALF_PE FROM SESSION.Cohort3_Q48_EventsPT2 WHERE ALF_PE IN(SELECT ALF_PE FROM SESSION.Cohort3_Q48_Events GROUP BY ALF_PE HAVING COUNT(DISTINCT CATEGORY ) >= 2)) THEN 1 ELSE 0 END AS SMOKING_CESSATION_FLAG
FROM sailw1317v.SS_COPD_COMORBIDITY saa
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC1_Q48 WHERE SMOKING_CESSATION_FLAG = 1

SELECT * FROM SESSION.GC3_48
ORDER BY ALF_PE

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q48

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q48(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, SMOKING_CESSATION_FLAG INT)

INSERT INTO  sailw1317v.SS_GC3_Q48
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD        
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, SMOKING_CESSATION_FLAG
FROM SESSION.GC3_Q48

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q48

--4.9 Inhaled therapy
--Prescribed an inhaled drug therapy in the last 6 months
--Number of people receiving each type of prescription (categorised in codelist)

SELECT * FROM sailw1317v.AQ49_COPD_INHALED_THERAPY aai 

-- AQUIRE FIRST PERSCRIPTION DATE 
DECLARE GLOBAL TEMPORARY TABLE FIRST_INHALER_PERSCRIPTION AS( 
SELECT wgec.ALF_PE, MIN(wgec.EVENT_DT) AS FIRST_INHALER_PERSCRIPTION_DATE
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ49_COPD_INHALED_THERAPY AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = AAC.EVENT_CD
GROUP BY wgec.ALF_PE
ORDER BY wgec.ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE FIRST_INHALER_PERSCRIPTION_EVENT AS( 
SELECT DISTINCT wgec.ALF_PE, wgec.EVENT_CD AS FIRST_INHALER_PERSCRIPTION, FIRST_INHALER_PERSCRIPTION_DATE , AAC.CATEGORY
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ49_COPD_INHALED_THERAPY AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
INNER JOIN SESSION.FIRST_INHALER_PERSCRIPTION fip ON fip.ALF_PE = wgec.ALF_PE AND fip.FIRST_INHALER_PERSCRIPTION_DATE = wgec.EVENT_DT
ORDER BY wgec.ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

---
DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q49_Events AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.TERM, wgec.EVENT_DT, aac.CATEGORY
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.AQ49_COPD_INHALED_THERAPY AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE Cohort3_Q49_Events_PT2 AS (SELECT COUNT(DISTINCT wgec.ALF_PE) AS PATIENT_COUNT, AAC.CATEGORY
FROM sailw1317v.SS_COPD_COMORBIDITY wgec 
INNER JOIN sailw1317v.AQ49_COPD_INHALED_THERAPY AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
WHERE wgec.EVENT_CD = aac.EVENT_CD
GROUP BY AAC.CATEGORY
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE GC3_Q49 AS (
SELECT saa.* 
,FIRST_INHALER_PERSCRIPTION
,FIRST_INHALER_PERSCRIPTION_DATE
, CATEGORY
, CASE WHEN saa.ALF_PE IN (SELECT DISTINCT ALF_PE FROM SESSION.Cohort3_Q49_Events) THEN 1 ELSE 0 END AS INHALER_PERSC_FLAG
FROM sailw1317v.SS_COPD_COMORBIDITY saa
LEFT JOIN SESSION.FIRST_INHALER_PERSCRIPTION_EVENT fip ON fip.ALF_PE = saa.ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.GC3_49
ORDER BY ALF_PE

--- FOR ALL INHALER EVENTS

DECLARE GLOBAL TEMPORARY TABLE GC3_Q492 AS (
SELECT wgec.*, ai.CATEGORY, ai.TERM
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN sailw1317v.SS_COPD_COMORBIDITY saa ON wgec.alf_PE = saa.ALF_PE 
INNER JOIN sailw1317v.AQ49_COPD_INHALED_THERAPY ai ON wgec.EVENT_CD = ai.EVENT_CD 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;


-- Counts per drug type 
SELECT CATEGORY, COUNT(DISTINCT ALF_PE) AS NUMBER_OF_PATIENTS FROM SESSION.Cohort3_Q49_Events_PT2
GROUP BY CATEGORY

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q49

-- Create perminent table 
CREATE TABLE sailw1317v.SS_GC3_Q49(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,FIRST_EVENT DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,CATEGORY       VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100)
, INHALER_PERSC_FLAG INT
,FIRST_INHALER_PERSCRIPTION VARCHAR(100)
,FIRST_INHALER_PERSCRIPTION_DATE DATE)

INSERT INTO  sailw1317v.SS_GC3_Q49
SELECT TABLE_ID        
,ALF_PE         
,WOB            
,AGE_AT_END_OF_FOLLOW_UP 
,FIRST_EVENT
,GNDR_CD        
,EVENT_CD  
,CATEGORY
,EVENT_DT      
,READ_DESC     
,PRAC_CD_PE       
,LOCAL_NUM_PE       
,WIMD_2019_QUINTILE  
,GP_PRACTICE_CLUSTER_CODE
,GP_PRACTICE_CLUSTER_NAME 
,LOCALHEALTHBOARDCODE 
,LOCALHEALTHBOARDNAME 
, INHALER_PERSC_FLAG
,FIRST_INHALER_PERSCRIPTION
,FIRST_INHALER_PERSCRIPTION_DATE
FROM SESSION.GC3_Q49

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q49 sgq 

--FOR ALL INHALER EVENTS

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_GC3_Q49_ALL

CREATE TABLE sailw1317v.SS_GC3_Q49_ALL(
ALF_PE         BIGINT
,WOB            DATE
,GNDR_CD        INT
,EVENT_CD        VARCHAR(100)
,CATEGORY       VARCHAR(100)
,EVENT_DT       DATE
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
, TERM VARCHAR(100))

INSERT INTO  sailw1317v.SS_GC3_Q49_ALL
SELECT ALF_PE         
,WOB            
,GNDR_CD        
,EVENT_CD  
,CATEGORY
,EVENT_DT          
,PRAC_CD_PE      
,LOCAL_NUM_PE        
, TERM 
FROM SESSION.GC3_Q492

--SELECT NEW TABLE FOR CSV EXTRACTION 
SELECT * FROM sailw1317v.SS_GC3_Q49_ALL 
ORDER BY ALF_PE
