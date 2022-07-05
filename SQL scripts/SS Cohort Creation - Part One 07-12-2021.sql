--------------------------------------------- Project 1317 Cohort Creation Part One Script - 07/12/2021 ----------------------------------------------------

---- BASIC COHORTS (Temporary Tables)
 --------- ASTHMA - Starts line 25

 --------- COPD - Starts line 61
 
 --------- INHALER - Starts line 89
 
 --------- UNION AND PERMINANT TABLES - starts line 861
 --- Remove those with multiple distinct practice codes - starts line 1191

-- Declare tables of codes
DECLARE GLOBAL TEMPORARY TABLE Asthma_Codes AS (
SELECT * FROM SAILW1317V.ASTHMA_CODES
) WITH DATA WITH replace ON commit PRESERVE ROWS ;


DECLARE GLOBAL TEMPORARY TABLE COPD_Codes AS (
SELECT * FROM SAILW1317V.COPD_CODES
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.Basic_Events_Asthma

---------------------------------------------------------------------------------- ASTHMA ----------------------------------------------------------------------

-- create temporary table framework
DECLARE GLOBAL TEMPORARY TABLE Basic_Events_Asthma_V1 AS (SELECT 'Asthma' AS TABLE_ID, wgec.ALF_PE, wgec.WOB, ('2021' - YEAR(wgec.WOB)) AS AGE_AT_END_OF_FOLLOW_UP, DOD, wgec.GNDR_CD, wgec.EVENT_CD, EVENT_DT, READ_DESC, PRAC_CD_PE, LOCAL_NUM_PE, WIMD_2019_QUINTILE, GP_PRACTICE_CLUSTER_CODE, GP_PRACTICE_CLUSTER_NAME, LOCALHEALTHBOARDCODE, LOCALHEALTHBOARDNAME  
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101  wgec 
LEFT JOIN SAILREFRV.READ_CD rd ON wgec.EVENT_CD = rd.READ_CD 
LEFT JOIN SAIL1317V.WDSD_AR_PERS_20211108 per  ON per.ALF_PE = wgec.ALF_PE
LEFT JOIN  SAIL1317V.WDSD_CLEAN_ADD_GEOG_CHAR_LSOA2011_20211108 lsoa ON wgec.ALF_PE = lsoa.ALF_PE
LEFT JOIN SAIL1317V.WLGP_REFR_WELSH_GP_CLUSTER_PRACTICES20211101 wrwgcp ON wrwgcp.WCODE_PE = wgec.PRAC_CD_PE 
LEFT JOIN SESSION.Asthma_Codes ac ON  wgec.EVENT_CD = ac.EVENT_CD
WHERE wgec.EVENT_CD = ac.EVENT_CD
AND EVENT_DT >= '01/04/2020' 
AND (DOD > '01/08/2021' OR DOD IS NULL)
AND lsoa.END_DATE >= '01/04/2020'
AND (wgec.GNDR_CD = '1' OR wgec.GNDR_CD = '2')
AND wgec.WOB >= '01/01/1921'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Establish date of first diagnosis and join
DECLARE GLOBAL TEMPORARY TABLE MIN_ASTHMA_DIAG AS (
SELECT DISTINCT ALF_PE, MIN(EVENT_DT) AS FIRST_DIAGNOSIS_DT
FROM SESSION.Basic_Events_Asthma_V1
GROUP BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE Basic_Events_Asthma AS (
SELECT TABLE_ID, BE.ALF_PE, WOB, AGE_AT_END_OF_FOLLOW_UP, DOD, GNDR_CD, EVENT_CD, EVENT_DT, FIRST_DIAGNOSIS_DT, READ_DESC, PRAC_CD_PE, LOCAL_NUM_PE, WIMD_2019_QUINTILE, GP_PRACTICE_CLUSTER_CODE, GP_PRACTICE_CLUSTER_NAME, LOCALHEALTHBOARDCODE, LOCALHEALTHBOARDNAME  
FROM SESSION.Basic_Events_Asthma_V1 BE
LEFT JOIN SESSION.MIN_ASTHMA_DIAG mad ON mad.ALF_PE = BE.ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

--  View data 
SELECT * FROM SESSION.Basic_Events_Asthma
ORDER BY ALF_PE, EVENT_DT, EVENT_CD

-- Cohort of patients with no events 
DECLARE GLOBAL TEMPORARY TABLE Basic_Cohort_Asthma AS (SELECT DISTINCT ALF_PE, TABLE_ID, WOB
FROM SESSION.Basic_Events_Asthma
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

SELECT * FROM SESSION.Basic_Events_COPD

-- Check counts - Cohort - 99,463 --108594 after refresh 
SELECT Count(ALF_PE) FROM SESSION.Basic_Cohort_Asthma

-- Check counts - Events - 570,563 -- 658 934 after refresh 
SELECT Count(ALF_PE) FROM SESSION.Basic_Events_Asthma

------------------------------------------------------------------------- COPD---------------------------------------------------------------------------------
-- create temporary table framework
DECLARE GLOBAL TEMPORARY TABLE Basic_Events_COPD_V1 AS (SELECT 'COPD' AS TABLE_ID, wgec.ALF_PE, wgec.WOB, ('2021' - YEAR(wgec.WOB)) AS AGE_AT_END_OF_FOLLOW_UP, DOD, wgec.GNDR_CD, wgec.EVENT_CD, EVENT_DT, READ_DESC, PRAC_CD_PE, LOCAL_NUM_PE, WIMD_2019_QUINTILE, GP_PRACTICE_CLUSTER_CODE, GP_PRACTICE_CLUSTER_NAME, LOCALHEALTHBOARDCODE, LOCALHEALTHBOARDNAME  
FROM SAIL1317V.WLGP_GP_EVENT_CLEANSED_20211101  wgec 
LEFT JOIN SAILREFRV.READ_CD rd ON wgec.EVENT_CD = rd.READ_CD 
LEFT JOIN SAIL1317V.WDSD_AR_PERS_20211108 per  ON per.ALF_PE = wgec.ALF_PE
LEFT JOIN  SAIL1317V.WDSD_CLEAN_ADD_GEOG_CHAR_LSOA2011_20211108 lsoa ON wgec.ALF_PE = lsoa.ALF_PE
LEFT JOIN SAIL1317V.WLGP_REFR_WELSH_GP_CLUSTER_PRACTICES20211101 wrwgcp ON wrwgcp.WCODE_PE = wgec.PRAC_CD_PE 
LEFT JOIN SESSION.COPD_Codes ac ON  wgec.EVENT_CD = ac.EVENT_CD
WHERE wgec.EVENT_CD = ac.EVENT_CD
AND EVENT_DT >= '01/04/2020' 
AND (DOD >= '01/08/2021' OR DOD IS NULL)
AND lsoa.END_DATE >= '01/04/2020' 
AND (wgec.GNDR_CD = '1' OR wgec.GNDR_CD = '2')
AND wgec.WOB >= '01/01/1921'
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Establish date of first diagnosis and join
DECLARE GLOBAL TEMPORARY TABLE MIN_COPD_DIAG AS (
SELECT DISTINCT ALF_PE, MIN(EVENT_DT) AS FIRST_DIAGNOSIS_DT
FROM SESSION.Basic_Events_COPD_V1
GROUP BY ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

DECLARE GLOBAL TEMPORARY TABLE Basic_Events_COPD AS (
SELECT TABLE_ID, BE.ALF_PE, WOB, AGE_AT_END_OF_FOLLOW_UP, DOD, GNDR_CD, EVENT_CD, EVENT_DT, FIRST_DIAGNOSIS_DT, READ_DESC, PRAC_CD_PE, LOCAL_NUM_PE, WIMD_2019_QUINTILE, GP_PRACTICE_CLUSTER_CODE, GP_PRACTICE_CLUSTER_NAME, LOCALHEALTHBOARDCODE, LOCALHEALTHBOARDNAME  
FROM SESSION.Basic_Events_COPD_V1 BE
LEFT JOIN SESSION.MIN_COPD_DIAG mad ON mad.ALF_PE = BE.ALF_PE
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Cohort of patients with no events 
DECLARE GLOBAL TEMPORARY TABLE Basic_Cohort_COPD AS ( SELECT DISTINCT ALF_PE, TABLE_ID, WOB
FROM SESSION.Basic_Events_COPD
) WITH DATA WITH replace ON commit PRESERVE ROWS ;

-- Check counts - Cohort - 30,514 -- 33,761  after refresh 
SELECT Count(ALF_PE) FROM SESSION.Basic_Cohort_COPD

-- Check counts - Events - 64,283 -- 75999 after refresh 
SELECT Count(ALF_PE) FROM SESSION.Basic_Events_COPD


----------------------------------------------------------------- UNION AND PERMINANT TABLES -----------------------------------------------------------------

--- Cohort Events 
DECLARE GLOBAL TEMPORARY TABLE Grand_Events_Cohort AS (
	SELECT TABLE_ID, ALF_PE, WOB, AGE_AT_END_OF_FOLLOW_UP, DOD, GNDR_CD, EVENT_CD, EVENT_DT, READ_DESC, PRAC_CD_PE, LOCAL_NUM_PE, WIMD_2019_QUINTILE, GP_PRACTICE_CLUSTER_CODE, GP_PRACTICE_CLUSTER_NAME, LOCALHEALTHBOARDCODE, LOCALHEALTHBOARDNAME   FROM SESSION.Basic_Events_Asthma
			UNION ALL  		
    SELECT TABLE_ID, ALF_PE, WOB, AGE_AT_END_OF_FOLLOW_UP, DOD, GNDR_CD, EVENT_CD, EVENT_DT, READ_DESC, PRAC_CD_PE, LOCAL_NUM_PE, WIMD_2019_QUINTILE, GP_PRACTICE_CLUSTER_CODE, GP_PRACTICE_CLUSTER_NAME, LOCALHEALTHBOARDCODE, LOCALHEALTHBOARDNAME   FROM SESSION.Basic_Events_COPD
      )WITH DATA WITH replace ON commit PRESERVE ROWS;

--- Remove those with multiple distinct practice codes 
DECLARE GLOBAL TEMPORARY TABLE Refining_code_setup AS(
SELECT ALF_PE, COUNT(DISTINCT PRAC_CD_PE) AS NUMBER_OF_PRACTICES
FROM SESSION.Grand_Events_Cohort
GROUP BY ALF_PE
)WITH DATA WITH replace ON commit PRESERVE ROWS;

DECLARE GLOBAL TEMPORARY TABLE Refining_code AS(
SELECT ALF_PE, NUMBER_OF_PRACTICES
FROM SESSION. Refining_code_setup
WHERE NUMBER_OF_PRACTICES = '1'
)WITH DATA WITH replace ON commit PRESERVE ROWS;

DECLARE GLOBAL TEMPORARY TABLE Grand_Events_Cohort_Refined AS (
SELECT TABLE_ID, GEC.ALF_PE, WOB, AGE_AT_END_OF_FOLLOW_UP, DOD, GNDR_CD, EVENT_CD, EVENT_DT, READ_DESC, PRAC_CD_PE, LOCAL_NUM_PE, WIMD_2019_QUINTILE, GP_PRACTICE_CLUSTER_CODE, GP_PRACTICE_CLUSTER_NAME, LOCALHEALTHBOARDCODE, LOCALHEALTHBOARDNAME   
FROM SESSION.Grand_Events_Cohort GEC
INNER JOIN SESSION.Refining_code RC ON GEC.ALF_PE = RC.ALF_PE
)WITH DATA WITH replace ON commit PRESERVE ROWS;

-- Check Counts 
-- 736,648
SELECT count(*) FROM SESSION.Grand_Events_Cohort;
-- 692,654
SELECT count(*) FROM SESSION.Grand_Events_Cohort_Refined;

-- Code to drop table before adding alterations 
DROP TABLE sailw1317v.SS_BASIC_EVENTS  

-- Create perminent table 
CREATE TABLE sailw1317v.SS_BASIC_EVENTS(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT
,WOB            DATE
,AGE_AT_END_OF_FOLLOW_UP  BIGINT
,GNDR_CD        INT
,EVENT_CD       VARCHAR(100)
,EVENT_DT       DATE
,READ_DESC      VARCHAR(100)
,PRAC_CD_PE        VARCHAR(100)
,LOCAL_NUM_PE       VARCHAR(100)
,WIMD_2019_QUINTILE  INT
,GP_PRACTICE_CLUSTER_CODE VARCHAR(100)
,GP_PRACTICE_CLUSTER_NAME VARCHAR(100)
,LOCALHEALTHBOARDCODE VARCHAR(100)
,LOCALHEALTHBOARDNAME VARCHAR(100))

INSERT INTO sailw1317v.SS_BASIC_EVENTS
SELECT TABLE_ID 
,ALF_PE  
,WOB   
,AGE_AT_END_OF_FOLLOW_UP 
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
FROM SESSION.Grand_Events_Cohort_Refined

-- COHORT PEOPLE
DECLARE GLOBAL TEMPORARY TABLE Grand_People_Cohort AS (
	SELECT TABLE_ID ,ALF_PE FROM SESSION.Basic_Cohort_Asthma
			UNION ALL  		
    SELECT TABLE_ID ,ALF_PE FROM SESSION.Basic_Cohort_COPD
)WITH DATA WITH replace ON commit PRESERVE ROWS;

DECLARE GLOBAL TEMPORARY TABLE Grand_People_Cohort_Refined AS (
SELECT TABLE_ID , GEC.ALF_PE FROM SESSION.Grand_People_Cohort GEC
INNER JOIN SESSION.Refining_code RC ON GEC.ALF_PE = RC.ALF_PE
)WITH DATA WITH replace ON commit PRESERVE ROWS;

-- Check Counts 
-- 142,607
SELECT count(*) FROM SESSION.Grand_People_Cohort;
-- 139,713
SELECT count(*) FROM SESSION.Grand_People_Cohort_Refined;

-- Check Counts of distinct individuals 134,243
SELECT count(DISTINCT ALF_PE) FROM SESSION.Grand_People_Cohort_Refined

-- show how many tables each ALF is in   
SELECT alf_pe, count(alf_pe) AS PRESENCE_IN_TABLES
FROM SESSION.Grand_People_Cohort_Refined
GROUP BY alf_pe
ORDER BY PRESENCE_IN_TABLES

-- Code to drop table before adding alterations 
DROP TABLE sailw1317v.SS_BASIC_PEOPLE

-- Create perminent table 
CREATE TABLE sailw1317v.SS_BASIC_PEOPLE(
TABLE_ID        VARCHAR(100)
,ALF_PE         BIGINT)

INSERT INTO sailw1317v.SS_BASIC_PEOPLE
SELECT TABLE_ID 
,ALF_PE   
FROM SESSION.Grand_People_Cohort_Refined
