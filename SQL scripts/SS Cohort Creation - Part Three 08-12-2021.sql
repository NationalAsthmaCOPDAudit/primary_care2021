--------------------------------------------- Project 1317 Cohort Creation Part Three Script - 08/12/2021 ----------------------------------------------------

-- Select MIN EVENT DT for each cohort 

DECLARE GLOBAL TEMPORARY TABLE ASTHMA_ADULTS_MIN_DATES AS (
SELECT DISTINCT ALF_PE, MIN(EVENT_DT) AS FIRST_EVENT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec
WHERE ALF_PE IN(SELECT ALF_PE FROM sailw1317v.SS_ASTHMA_ADULTS ) AND EVENT_CD IN(SELECT EVENT_CD FROM sailw1317v.ASTHMA_CODES)
GROUP BY ALF_PE
ORDER BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE ASTHMA_CHILDREN_MIN_DATES AS (
SELECT DISTINCT ALF_PE, MIN(EVENT_DT) AS FIRST_EVENT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec
WHERE ALF_PE IN(SELECT ALF_PE FROM sailw1317v.SS_ASTHMA_CHILDREN) AND EVENT_CD IN(SELECT EVENT_CD FROM sailw1317v.ASTHMA_CODES)
GROUP BY ALF_PE
ORDER BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE COPD_MIN_DATES AS (
SELECT DISTINCT ALF_PE, MIN(EVENT_DT) AS FIRST_EVENT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec
WHERE ALF_PE IN(SELECT ALF_PE FROM sailw1317v.SS_COPD) AND EVENT_CD IN(SELECT EVENT_CD FROM SAILW1317V.COPD_CODES ac)
GROUP BY ALF_PE
ORDER BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Select MAX EVENT DT for each cohort 

DECLARE GLOBAL TEMPORARY TABLE ASTHMA_ADULTS_MAX_DATES AS (
SELECT DISTINCT ALF_PE, MAX(EVENT_DT) AS Latest_Event
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec
WHERE ALF_PE IN(SELECT ALF_PE FROM sailw1317v.SS_ASTHMA_ADULTS ) AND EVENT_CD IN(SELECT EVENT_CD FROM sailw1317v.ASTHMA_CODES)
GROUP BY ALF_PE
ORDER BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE ASTHMA_CHILDREN_MAX_DATES AS (
SELECT DISTINCT ALF_PE, MAX(EVENT_DT) AS Latest_Event
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec
WHERE ALF_PE IN(SELECT ALF_PE FROM sailw1317v.SS_ASTHMA_CHILDREN) AND EVENT_CD IN(SELECT EVENT_CD FROM sailw1317v.ASTHMA_CODES)
GROUP BY ALF_PE
ORDER BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE COPD_MAX_DATES AS (
SELECT DISTINCT ALF_PE, MAX(EVENT_DT) AS Latest_Event 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec
WHERE ALF_PE IN(SELECT ALF_PE FROM sailw1317v.SS_COPD) AND EVENT_CD IN(SELECT EVENT_CD FROM SAILW1317V.COPD_CODES ac)
GROUP BY ALF_PE
ORDER BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

--- JOIN IN COMORBIDITY EVENTS TO BASIC COHORTS 

-- Create Comorbidity Code tables 
-- COPD
DECLARE GLOBAL TEMPORARY TABLE COPD_Comorbidity AS (
SELECT  'ASTHMA' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.ASTHMA_CODES
UNION ALL
SELECT  'ANXIETY' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ANXIETY WHERE EVENT_CD NOT IN ('8IH30', '6897.','68970')
UNION ALL
SELECT  'ANXIETY_SCREENING' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ANXIETY WHERE EVENT_CD IN ('6897.','68970')
UNION ALL
SELECT  'BRONCHIECTASIS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_BRONCHIECTASIS 
UNION ALL
SELECT  'BMI' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_BMI
UNION ALL
SELECT  'CHD' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_CHD
UNION ALL
SELECT  'DIABETES' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_DIABETES
UNION ALL
SELECT  'DEPRESSION' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_DEPRESSION WHERE EVENT_CD NOT IN ( '68910', '8IH31', '6891.', '6896.', 'ZV790' )
UNION ALL
SELECT  'DEPRESSION_SCREENING' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_DEPRESSION WHERE EVENT_CD IN ( '68910', '6891.', '6896.', 'ZV790') 
UNION ALL
SELECT  'HEART_FAILURE' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_HEART_FAILURE 
UNION ALL
SELECT  'HYPERTENSION' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_HYPERTENSION 
UNION ALL
SELECT  'LEARNING_DISABILITY' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_LEARNING_DISABILITY 
UNION ALL
SELECT  'LUNG_CANCER' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_LUNG_CANCER 
UNION ALL
SELECT  'OSTEOPOROSIS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_OSTEOPOROSIS 
UNION ALL
SELECT  'SMI' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_SMI 
UNION ALL
SELECT  'STROKE' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_STROKE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Adult Asthma
DECLARE GLOBAL TEMPORARY TABLE Adult_Asthma_Comorbidity AS (
  SELECT  'COPD' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.COPD_CODES 
  UNION ALL
  SELECT  'ALLERGIC_RHINITIS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ALLERGIC_RHINITIS 
  UNION ALL
  SELECT  'ATOPY' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ATOPY 
  UNION ALL
  SELECT  'ANXIETY' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ANXIETY WHERE EVENT_CD NOT IN ('8IH30', '6897.','68970')
  UNION ALL
  SELECT  'ANXIETY_SCREENING' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ANXIETY WHERE EVENT_CD IN ('6897.','68970')
  UNION ALL
  SELECT  'BRONCHIECTASIS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_BRONCHIECTASIS 
  UNION ALL
  SELECT  'BMI' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_BMI 
  UNION ALL
  SELECT  'CHD' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_CHD 
  UNION ALL
  SELECT  'DIABETES' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_DIABETES 
  UNION ALL
  SELECT  'DEPRESSION' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_DEPRESSION WHERE EVENT_CD NOT IN ( '68910', '8IH31', '6891.', '6896.', 'ZV790' )
  UNION ALL
  SELECT  'DEPRESSION_SCREENING' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_DEPRESSION WHERE EVENT_CD IN ( '68910', '6891.', '6896.', 'ZV790') 
  UNION ALL
  SELECT  'ECZEMA' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ECZEMA 
  UNION ALL
  SELECT  'FH_ASTHMA' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_FH_ASTHMA WHERE EVENT_CD NOT IN ('122C0')
  UNION ALL
  SELECT  'HAYFEVER' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_HAYFEVER 
  UNION ALL
  SELECT  'HEART_FAILURE' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_HEART_FAILURE 
  UNION ALL
  SELECT  'HYPERTENSION' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_HYPERTENSION 
  UNION ALL
  SELECT  'LEARNING_DISABILITY' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_LEARNING_DISABILITY 
  UNION ALL
  SELECT  'LUNG_CANCER' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_LUNG_CANCER 
  UNION ALL
  SELECT  'NASAL_POLYPS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_NASAL_POLYPS 
  UNION ALL
  SELECT  'OSTEOPOROSIS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_OSTEOPOROSIS 
  UNION ALL
  SELECT  'REFLUX' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_REFLUX 
  UNION ALL
  SELECT  'SMI' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_SMI 
  UNION ALL
  SELECT  'STROKE' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_STROKE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;


-- Child Asthma
DECLARE GLOBAL TEMPORARY TABLE Child_Asthma_Comorbidity AS (
  SELECT  'COPD' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.COPD_CODES ac  
  UNION ALL
  SELECT  'ALLERGIC_RHINITIS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ALLERGIC_RHINITIS 
  UNION ALL
  SELECT  'ATOPY' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ATOPY 
  UNION ALL
  SELECT  'BMI' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_BMI  
  UNION ALL
  SELECT  'ECZEMA' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_ECZEMA 
  UNION ALL
  SELECT  'FH_ASTHMA' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_FH_ASTHMA WHERE EVENT_CD NOT IN ('122C0')
  UNION ALL
  SELECT  'HAYFEVER' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_HAYFEVER  
  UNION ALL
  SELECT  'LEARNING_DISABILITY' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_LEARNING_DISABILITY 
  UNION ALL
  SELECT  'NASAL_POLYPS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_NASAL_POLYPS
  UNION ALL
  SELECT  'REFLUX' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_REFLUX 
  UNION ALL
  SELECT  'MENTAL_HEALTH_PAEDS' AS EVENT_CAT, EVENT_CD, TERM FROM SAILW1317V.CM_MENTAL_HEALTH_PAEDS 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;


-------------------------- GRAND COHORT ONE - ADULTS --------------------------------------------------
-- select ALfs with comorbidity codes 
DECLARE GLOBAL TEMPORARY TABLE Cohort_With_Comorbidity AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.EVENT_CAT, wgec.EVENT_DT
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN SESSION.Adult_Asthma_Comorbidity AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_ASTHMA_ADULTS SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Aquire resolved codes list 
SELECT * FROM SESSION.Adult_Asthma_Comorbidity WHERE Term LIKE '%Resolved%' OR Term LIKE '%resolved%'


-- Delete Entries with resolved codes 
DELETE 
FROM SESSION.Cohort_With_Comorbidity
WHERE 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_ADULTS_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('2126F') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE) AND EVENT_CAT = 'COPD'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_ADULTS_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('212T.', '212X.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE) AND EVENT_CAT = 'SMI'
OR
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_ADULTS_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('212H.', '21263') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'DIABETES'
OR
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_ADULTS_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('21261', '212K.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'HYPERTENSION'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_ADULTS_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('2126J') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'ANXIETY'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_ADULTS_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('212S.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'DEPRESSION'

SELECT * FROM SESSION.Cohort_With_Comorbidity


-- Select all events for the cohort and add Comorbidity flags 
DECLARE GLOBAL TEMPORARY TABLE Adult_Asthma_With_Comorbidity AS (
SELECT 
SSA.TABLE_ID
, SSA.ALF_PE
, SSA.WOB
, SSA.AGE_AT_END_OF_FOLLOW_UP
, SSA.GNDR_CD
, FIRST_EVENT
, SSA.EVENT_CD
, SSA.EVENT_DT
, SSA.READ_DESC
, SSA.PRAC_CD_PE
, SSA.LOCAL_NUM_PE
, SSA.WIMD_2019_QUINTILE
, SSA.GP_PRACTICE_CLUSTER_CODE
, SSA.GP_PRACTICE_CLUSTER_NAME
, SSA.LOCALHEALTHBOARDCODE
, SSA.LOCALHEALTHBOARDNAME   
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'COPD' ) THEN 1 ELSE 0 END AS COPD_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'ALLERGIC_RHINITIS' ) THEN 1 ELSE 0 END AS ALLERGIC_RHINITIS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'ATOPY' ) THEN 1 ELSE 0 END AS ATOPY_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'ANXIETY' ) THEN 1 ELSE 0 END AS ANXIETY_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'BRONCHIECTASIS' ) THEN 1 ELSE 0 END AS BRONCHIECTASIS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'BMI' ) THEN 1 ELSE 0 END AS BMI_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'CHD' ) THEN 1 ELSE 0 END AS CHD_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'DIABETES' ) THEN 1 ELSE 0 END AS DIABETES_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'DEPRESSION' ) THEN 1 ELSE 0 END AS DEPRESSION_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'ECZEMA' ) THEN 1 ELSE 0 END AS ECZEMA_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'FH_ASTHMA' ) THEN 1 ELSE 0 END AS FH_ASTHMA_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'HAYFEVER' ) THEN 1 ELSE 0 END AS HAYFEVER_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'HEART_FAILURE' ) THEN 1 ELSE 0 END AS HEART_FAILURE_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'HYPERTENSION' ) THEN 1 ELSE 0 END AS HYPERTENSION_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'LEARNING_DISABILITY' ) THEN 1 ELSE 0 END AS LEARNING_DISABILITY_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'LUNG_CANCER' ) THEN 1 ELSE 0 END AS LUNG_CANCER_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'NASAL_POLYPS' ) THEN 1 ELSE 0 END AS NASAL_POLYPS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'OSTEOPOROSIS' ) THEN 1 ELSE 0 END AS OSTEOPOROSIS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'REFLUX' ) THEN 1 ELSE 0 END AS REFLUX_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'SMI' ) THEN 1 ELSE 0 END AS SMI_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'STROKE' ) THEN 1 ELSE 0 END AS STROKE_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'DEPRESSION_SCREENING' ) THEN 1 ELSE 0 END AS DEPRESSION_SCREENING_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Cohort_With_Comorbidity WHERE EVENT_CAT = 'ANXIETY_SCREENING' ) THEN 1 ELSE 0 END AS ANXIETY_SCREENING_FLAG
FROM sailw1317v.SS_ASTHMA_ADULTS SSA
LEFT JOIN SESSION.ASTHMA_ADULTS_MIN_DATES AAMD ON AAMD.ALF_PE = SSA.ALF_PE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_ASTHMA_ADULTS_COMORBIDITY

-- Create perminent table 
CREATE TABLE sailw1317v.SS_ASTHMA_ADULTS_COMORBIDITY(
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
, COPD_FLAG  INT
, ALLERGIC_RHINITIS_FLAG INT
, ATOPY_FLAG INT
, ANXIETY_FLAG INT
, BRONCHIECTASIS_FLAG INT
, BMI_FLAG INT
, CHD_FLAG INT
, DIABETES_FLAG INT
, DEPRESSION_FLAG INT
, ECZEMA_FLAG INT
, FH_ASTHMA_FLAG INT
, HAYFEVER_FLAG INT
, HEART_FAILURE_FLAG INT
, HYPERTENSION_FLAG INT
, LEARNING_DISABILITY_FLAG INT
, LUNG_CANCER_FLAG INT
, NASAL_POLYPS_FLAG INT
, OSTEOPOROSIS_FLAG INT
, REFLUX_FLAG INT
, SMI_FLAG INT
, STROKE_FLAG INT
, DEPRESSION_SCREENING_FLAG INT
, ANXIETY_SCREENING_FLAG INT)

INSERT INTO sailw1317v.SS_ASTHMA_ADULTS_COMORBIDITY
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
, COPD_FLAG  
, ALLERGIC_RHINITIS_FLAG 
, ATOPY_FLAG 
, ANXIETY_FLAG 
, BRONCHIECTASIS_FLAG 
, BMI_FLAG 
, CHD_FLAG 
, DIABETES_FLAG 
, DEPRESSION_FLAG 
, ECZEMA_FLAG
, FH_ASTHMA_FLAG
, HAYFEVER_FLAG
, HEART_FAILURE_FLAG
, HYPERTENSION_FLAG
, LEARNING_DISABILITY_FLAG
, LUNG_CANCER_FLAG
, NASAL_POLYPS_FLAG
, OSTEOPOROSIS_FLAG
, REFLUX_FLAG
, SMI_FLAG
, STROKE_FLAG
, DEPRESSION_SCREENING_FLAG 
, ANXIETY_SCREENING_FLAG
FROM SESSION.Adult_Asthma_With_Comorbidity

SELECT * FROM sailw1317v.SS_ASTHMA_ADULTS_COMORBIDITY


-------------------------- GRAND COHORT TWO - CHILDREN (Ages 12-18) -----------------------------------
-- select ALfs with comorbidity codes 
DECLARE GLOBAL TEMPORARY TABLE Child_Cohort_With_Comorbidity AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.EVENT_CAT , wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN SESSION.Child_Asthma_Comorbidity AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_ASTHMA_CHILDREN SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Aquire resolved codes list 
SELECT * FROM SESSION.Adult_Asthma_Comorbidity WHERE Term LIKE '%Resolved%' OR Term LIKE '%resolved%'

-- Delete Entries with resolved codes 
DELETE 
FROM SESSION.Child_Cohort_With_Comorbidity
WHERE 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_CHILDREN_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('2126F') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE) AND EVENT_CAT = 'COPD'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_CHILDREN_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN  ('212T.', '212X.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE) AND EVENT_CAT = 'SMI'
OR
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_CHILDREN_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN  ('212H.', '21263') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'DIABETES'
OR
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_CHILDREN_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('21261', '212K.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'HYPERTENSION'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_CHILDREN_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN  ('2126J') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'ANXIETY'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity cc LEFT JOIN SESSION.ASTHMA_CHILDREN_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('212S.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'DEPRESSION'

-- Select all events for the cohort 
DECLARE GLOBAL TEMPORARY TABLE Child_Asthma_With_Comorbidity AS (
SELECT 
SSA.TABLE_ID
, SSA.ALF_PE
, SSA.WOB
, SSA.AGE_AT_END_OF_FOLLOW_UP
, FIRST_EVENT 
, SSA.GNDR_CD
, SSA.EVENT_CD
, SSA.EVENT_DT
, SSA.READ_DESC
, SSA.PRAC_CD_PE
, SSA.LOCAL_NUM_PE
, SSA.WIMD_2019_QUINTILE
, SSA.GP_PRACTICE_CLUSTER_CODE
, SSA.GP_PRACTICE_CLUSTER_NAME
, SSA.LOCALHEALTHBOARDCODE
, SSA.LOCALHEALTHBOARDNAME   
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'COPD' ) THEN 1 ELSE 0 END AS COPD_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'ALLERGIC_RHINITIS' ) THEN 1 ELSE 0 END AS ALLERGIC_RHINITIS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'ATOPY' ) THEN 1 ELSE 0 END AS ATOPY_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'BMI' ) THEN 1 ELSE 0 END AS BMI_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'ECZEMA' ) THEN 1 ELSE 0 END AS ECZEMA_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'FH_ASTHMA' ) THEN 1 ELSE 0 END AS FH_ASTHMA_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'HAYFEVER' ) THEN 1 ELSE 0 END AS HAYFEVER_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'LEARNING_DISABILITY' ) THEN 1 ELSE 0 END AS LEARNING_DISABILITY_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'NASAL_POLYPS' ) THEN 1 ELSE 0 END AS NASAL_POLYPS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'REFLUX' ) THEN 1 ELSE 0 END AS REFLUX_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Child_Cohort_With_Comorbidity WHERE EVENT_CAT = 'MENTAL_HEALTH_PAEDS' ) THEN 1 ELSE 0 END AS MHP_FLAG
FROM sailw1317v.SS_ASTHMA_CHILDREN SSA
LEFT JOIN SESSION.ASTHMA_CHILDREN_MIN_DATES AAMD ON AAMD.ALF_PE = SSA.ALF_PE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_ASTHMA_CHILD_COMORBIDITY

-- Create perminent table 
CREATE TABLE sailw1317v.SS_ASTHMA_CHILD_COMORBIDITY(
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
, COPD_FLAG  INT
, ALLERGIC_RHINITIS_FLAG INT
, ATOPY_FLAG INT
, BMI_FLAG INT
, ECZEMA_FLAG INT
, FH_ASTHMA_FLAG INT
, HAYFEVER_FLAG INT
, LEARNING_DISABILITY_FLAG INT
, NASAL_POLYPS_FLAG INT
, REFLUX_FLAG INT
, MHP_FLAG INT)

INSERT INTO sailw1317v.SS_ASTHMA_CHILD_COMORBIDITY
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
, COPD_FLAG  
, ALLERGIC_RHINITIS_FLAG 
, ATOPY_FLAG 
, BMI_FLAG
, ECZEMA_FLAG 
, FH_ASTHMA_FLAG 
, HAYFEVER_FLAG 
, LEARNING_DISABILITY_FLAG 
, NASAL_POLYPS_FLAG 
, REFLUX_FLAG 
, MHP_FLAG
FROM SESSION.Child_Asthma_With_Comorbidity

SELECT * FROM sailw1317v.SS_ASTHMA_CHILD_COMORBIDITY

-------------------------- GRAND COHORT THREE - COPD Patients -----------------------------------------
-- select ALfs with comorbidity codes 
DECLARE GLOBAL TEMPORARY TABLE Copd_Cohort_With_Comorbidity AS ( SELECT wgec.ALF_PE, wgec.EVENT_CD, AAC.EVENT_CAT, wgec.EVENT_DT 
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101 wgec 
INNER JOIN SESSION.COPD_Comorbidity AAC ON  wgec.EVENT_CD = AAC.EVENT_CD
INNER JOIN sailw1317v.SS_COPD SSA ON wgec.ALF_PE = SSA.ALF_PE
WHERE wgec.EVENT_CD = aac.EVENT_CD  
) WITH DATA WITH replace ON commit PRESERVE ROWS ;


-- Aquire resolved codes list 
SELECT * FROM SESSION.Adult_Asthma_Comorbidity WHERE Term LIKE '%Resolved%' OR Term LIKE '%resolved%'

-- Delete Entries with resolved codes 

DELETE 
FROM SESSION.Copd_Cohort_With_Comorbidity
WHERE
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity cc LEFT JOIN SESSION.COPD_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('2126F') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE) AND EVENT_CAT = 'COPD'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity cc LEFT JOIN SESSION.COPD_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN('212T.', '212X.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE) AND EVENT_CAT = 'SMI'
OR
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity cc LEFT JOIN SESSION.COPD_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('212H.', '21263') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'DIABETES'
OR
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity cc LEFT JOIN SESSION.COPD_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('21261', '212K.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'HYPERTENSION'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity cc LEFT JOIN SESSION.COPD_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('2126J') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'ANXIETY'
OR 
ALF_PE IN ( SELECT cc.ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity cc LEFT JOIN SESSION.COPD_MAX_DATES le ON cc.ALF_PE = le.ALF_PE WHERE EVENT_CD IN ('212S.') AND EVENT_DT = Latest_Event GROUP BY cc.ALF_PE)  AND EVENT_CAT = 'DEPRESSION'

-- Select all events for the cohort and add Comorbidity flags 
DECLARE GLOBAL TEMPORARY TABLE COPD_With_Comorbidity AS (
SELECT 
SSA.TABLE_ID
, SSA.ALF_PE
, SSA.WOB
, SSA.AGE_AT_END_OF_FOLLOW_UP
, FIRST_EVENT 
, SSA.GNDR_CD
, SSA.EVENT_CD
, SSA.EVENT_DT
, SSA.READ_DESC
, SSA.PRAC_CD_PE
, SSA.LOCAL_NUM_PE
, SSA.WIMD_2019_QUINTILE
, SSA.GP_PRACTICE_CLUSTER_CODE
, SSA.GP_PRACTICE_CLUSTER_NAME
, SSA.LOCALHEALTHBOARDCODE
, SSA.LOCALHEALTHBOARDNAME   
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'ASTHMA' ) THEN 1 ELSE 0 END AS ASTHMA_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'ANXIETY' ) THEN 1 ELSE 0 END AS ANXIETY_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'BRONCHIECTASIS' ) THEN 1 ELSE 0 END AS BRONCHIECTASIS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'BMI' ) THEN 1 ELSE 0 END AS BMI_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'CHD' ) THEN 1 ELSE 0 END AS CHD_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'DIABETES' ) THEN 1 ELSE 0 END AS DIABETES_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'DEPRESSION' ) THEN 1 ELSE 0 END AS DEPRESSION_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'HEART_FAILURE ' ) THEN 1 ELSE 0 END HEART_FAILURE_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'HYPERTENSION' ) THEN 1 ELSE 0 END AS HYPERTENSION_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'LEARNING_DISABILITY' ) THEN 1 ELSE 0 END AS LEARNING_DISABILITY_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'LUNG_CANCER' ) THEN 1 ELSE 0 END AS LUNG_CANCER_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'OSTEOPOROSIS' ) THEN 1 ELSE 0 END AS OSTEOPOROSIS_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'SMI' ) THEN 1 ELSE 0 END AS SMI_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'STROKE' ) THEN 1 ELSE 0 END AS STROKE_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'DEPRESSION_SCREENING' ) THEN 1 ELSE 0 END AS DEPRESSION_SCREENING_FLAG
, CASE WHEN SSA.ALF_PE IN (SELECT ALF_PE FROM SESSION.Copd_Cohort_With_Comorbidity WHERE EVENT_CAT = 'ANXIETY_SCREENING' ) THEN 1 ELSE 0 END AS ANXIETY_SCREENING_FLAG
FROM sailw1317v.SS_COPD SSA
LEFT JOIN SESSION.COPD_MIN_DATES AAMD ON AAMD.ALF_PE = SSA.ALF_PE 
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- DROP TABLE TO ADD CHANGES
DROP TABLE sailw1317v.SS_COPD_COMORBIDITY

-- Create perminent table 
CREATE TABLE sailw1317v.SS_COPD_COMORBIDITY(
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
, ASTHMA_FLAG  INT
, ANXIETY_FLAG INT
, BRONCHIECTASIS_FLAG INT
, BMI_FLAG INT
, CHD_FLAG INT
, DIABETES_FLAG INT
, DEPRESSION_FLAG INT
, HEART_FAILURE_FLAG INT
, HYPERTENSION_FLAG INT
, LEARNING_DISABILITY_FLAG INT
, LUNG_CANCER_FLAG INT
, OSTEOPOROSIS_FLAG INT
, SMI_FLAG INT
, STROKE_FLAG INT
, DEPRESSION_SCREENING_FLAG INT
, ANXIETY_SCREENING_FLAG INT)

INSERT INTO  sailw1317v.SS_COPD_COMORBIDITY
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
, ASTHMA_FLAG  
, ANXIETY_FLAG 
, BRONCHIECTASIS_FLAG
, BMI_FLAG 
, CHD_FLAG 
, DIABETES_FLAG 
, DEPRESSION_FLAG 
, HEART_FAILURE_FLAG 
, HYPERTENSION_FLAG 
, LEARNING_DISABILITY_FLAG 
, LUNG_CANCER_FLAG 
, OSTEOPOROSIS_FLAG 
, SMI_FLAG 
, STROKE_FLAG 
, DEPRESSION_SCREENING_FLAG
, ANXIETY_SCREENING_FLAG 
FROM SESSION.COPD_With_Comorbidity 

SELECT * FROM sailw1317v.SS_COPD_COMORBIDITY

-- SELECT TABLES FOR EXTRACTION
-- ASTHMA
SELECT * FROM sailw1317v.SS_ASTHMA_ADULTS_COMORBIDITY 

SELECT COUNT(DISTINCT ALF_PE) FROM sailw1317v.SS_ASTHMA_ADULTS_COMORBIDITY 

-- CHILD ASTHMA
SELECT * FROM sailw1317v.SS_ASTHMA_CHILD_COMORBIDITY 

SELECT COUNT(DISTINCT ALF_PE) FROM sailw1317v.SS_ASTHMA_CHILD_COMORBIDITY 

--COPD
SELECT * FROM sailw1317v.SS_COPD_COMORBIDITY

SELECT COUNT(DISTINCT ALF_PE) FROM sailw1317v.SS_COPD_COMORBIDITY