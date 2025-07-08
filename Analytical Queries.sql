-- Connect to database (MySQL only)
USE hospital_db;
-- ------------------------OBJECTIVE 1: ENCOUNTERS OVERVIEW ------------------------------------------

-- Question 1 . How many total encounters occurred each year?

SELECT YEAR(START) as Encounter_Year,COUNT(Id) as Encounters FROM encounters
GROUP BY YEAR(START)
ORDER BY COUNT(Id) DESC

# Insights : In 2014 ,The Most Number Encounter happened (3885 encounters)

#------------------------------------------------------------------------------------------------------

-- b. For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?

SELECT YEAR(START) Encounter_Year ,
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'ambulatory' THEN 1 ELSE 0 END)/COUNT(Id)*100,2) as "Ambulatory",
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'emergency' THEN 1 ELSE 0 END)/COUNT(Id)*100,2) as "Emergency",
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'inpatient' THEN 1 ELSE 0 END)/COUNT(Id)*100,2) as "Inpatient",
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'outpatient' THEN 1 ELSE 0 END)/COUNT(Id)*100,2) as "Outpatient",
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'urgentcare' THEN 1 ELSE 0 END)/COUNT(Id)*100,2) as "UrgentCare",
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'wellness' THEN 1 ELSE 0 END)/COUNT(Id)*100,2) as "Wellness"
FROM encounters
GROUP BY YEAR(START)

#INSIGHT : So as per the % Ratio We find that The Max Percentage of Encounter was Ambulatory Service for the Patient in Almost Every Year

-- ---------------------------------------------------------------------------------------------------------------------

-- c. What PERCENTAGE of encounters were over 24 hours versus under 24 hours?
# USING TIMESTAMPDIFF(unit,startdatetime,enddatetime)  
#SELECT * FROM encounters # TEST UNIT

SELECT  
		CONCAT(ROUND((SUM(CASE WHEN TIMESTAMPDIFF(HOUR,START,STOP) >= 24 THEN 1 ELSE 0 END)/COUNT(Id)) * 100,0),'%') AS Inpatient,
        CONCAT(ROUND((SUM(CASE WHEN TIMESTAMPDIFF(HOUR,START,STOP) < 24 THEN 1 ELSE 0 END)/COUNT(Id)) * 100,0),'%') AS OutPatient
FROM encounters

# INSIGHTS : 96 % of the Patient were Outpatient mean not admitted in Hospital for more than 24 hr.

#--------------------------------------------------------------------------------------------------
--            ------------------ OBJECTIVE 2: COST & COVERAGE INSIGHTS-----------------------------

-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
SELECT (
	SELECT COUNT(Id) FROM encounters
	WHERE PAYER_COVERAGE = 0.00) as Zero_Coverage_Encounter_Count,
  (                              
SELECT
	CONCAT(ROUND((SUM(CASE WHEN PAYER_COVERAGE = 0.00 THEN 1 ELSE 0 END )/COUNT(Id)) * 100,0),'%')
FROM encounters) as Zero_Coverage_Encounter_Percentage;

#INSIGHTS: 49 % (13586) Out of 27891 encounter patients are Zero Coverage

-- -------------------------------------------------------------------------------------------------------------

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?

SELECT DESCRIPTION as Procedure_Performed,
COUNT(DESCRIPTION) Top10_Proc_Performed ,
ROUND(AVG(BASE_COST),2) AS Average_Base_Cost
FROM procedures
GROUP BY DESCRIPTION
ORDER BY COUNT(DESCRIPTION) DESC
LIMIT 10

# INSIGHTS : Procedure : 'Assessment of health and social care needs (procedure)'Named  has mostly performed(4596) 
#and its Average Base_cost is $431.00.

#------------------------------------------------------------------------------------------------------------------------
-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?
WITH Top10_Procedure_Code_By_Avg_Cost_Frequency AS (
					SELECT DESCRIPTION ,
					ROUND(AVG(BASE_COST),2) AS Average_Base_Cost,
					COUNT(DESCRIPTION) AS Number_Of_Times_Performed,
					DENSE_RANK() OVER(ORDER BY AVG(BASE_COST) DESC, COUNT(DESCRIPTION) DESC ) Procedure_Code_By_Avg_Cost_Frequency
					FROM procedures
					GROUP BY DESCRIPTION) 

SELECT DESCRIPTION,Average_Base_Cost,Number_Of_Times_Performed FROM Top10_Procedure_Code_By_Avg_Cost_Frequency
WHERE Procedure_Code_By_Avg_Cost_Frequency <11

#INSIGHT: 'Admit to ICU (procedure)' was having the Max Average base Cost of $ 206260.40 and Performed 5 times Only
# But Rank 6th Procedure : 'Electrical cardioversion' was performed Max time among all Top 10

--	--------------------------------------------------------------------------------------------------

-- d. What is the average total claim cost for encounters, broken down by payer?
# We are going to use Two Tables encounter and Payers
SELECT p.NAME,ROUND(AVG(e.TOTAL_CLAIM_COST),2)  Average_Claim_Cost_By_Insurance FROM encounters e
INNER JOIN payers p
ON e.PAYER = p.Id
GROUP BY p.NAME
ORDER BY AVG(e.TOTAL_CLAIM_COST) DESC

#INSIGHTS : Medicaid has Highest Avg Total Claim Cost  of About $6205.22 and Lowest is for Dual Eligibile like MSP or MA Plan.

--	------------------------------------------------------------------------------------------------------------------------------
-- --------------------------- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS----------------------------------------------------------------

-- a. How many unique patients were admitted each quarter over time?
# USE  Table encounters and patients : IF we Consider Patient With Hospital Time more than or =  24 then Use this Query
WITH CTE_Admitted_Patient AS (
							SELECT QUARTER(START) AS Quartr,
                            YEAR(START) as Year,
                            COUNT(DISTINCT PATIENT) as Unique_Patient_Count FROM encounters
							WHERE TIMESTAMPDIFF(HOUR,START,STOP) >=24
							GROUP BY QUARTER(START),YEAR(START)
							ORDER BY Year ASC,Quartr ASC
							  )
SELECT CONCAT('Q' ,Quartr ,'-',Year) as Quarter_Year, Unique_Patient_Count FROM CTE_Admitted_Patient
--  -------------------OR If we consider all the Patient admitted one Then Chose this.
WITH CTE_Admitted_Patient AS (
SELECT YEAR(START) year,
	   MONTH(START) mnt,
       CASE WHEN MONTH(START) IN (1,2,3) THEN 'Q1' 
			WHEN MONTH(START) IN (4,5,6) THEN 'Q2'
            WHEN MONTH(START) IN (7,8,9) THEN 'Q3' 
            WHEN MONTH(START) IN (10,11,12) THEN 'Q4' END as Qtr,
            PATIENT,ENCOUNTERCLASS
FROM encounters   )
SELECT CONCAT(Qtr,'-',year), COUNT(DISTINCT PATIENT) as Unique_Patient FROM  CTE_Admitted_Patient GROUP BY year,Qtr 

#----------------------------------------------------------------------------------------------------------------------

-- b. How many patients were readmitted within 30 days of a previous encounter?
WITH Visits AS (
SELECT PATIENT,
DATE(START) as First_Visit,
LEAD(DATE(START)) OVER(PARTITION BY PATIENT ORDER BY DATE(START)) as Next_Visit
FROM encounters ) 
SELECT COUNT(DISTINCT PATIENT) Patient_with_Visit_within_30Days FROM Visits
WHERE DATEDIFF(Next_Visit,First_Visit) <30

#INSIGHT: Total 770 Patients were Revisited to the Providers within 30 day  period from first Visit.

#----------------------------------------------------------------------------------------------------
-- c. Which patients had the most readmissions?
SELECT Patient_with_Visit_within_30Days,CONCAT(PREFIX, ' ',FIRST ,' ',LAST) as Patient_Name ,Number_Of_Times_Visited

 FROM (
					WITH Visits AS (
					SELECT PATIENT,
					DATE(START) as First_Visit,
					LEAD(DATE(START)) OVER(PARTITION BY PATIENT ORDER BY DATE(START)) as Next_Visit
					FROM encounters ) 
					SELECT PATIENT Patient_with_Visit_within_30Days,COUNT(1) as Number_Of_Times_Visited FROM Visits
					WHERE DATEDIFF(Next_Visit,First_Visit) <30
					GROUP BY PATIENT
					ORDER BY COUNT(1) DESC 
			) AS V
INNER JOIN patients p
ON p.Id = v.Patient_with_Visit_within_30Days  
ORDER BY  Number_Of_Times_Visited DESC    

##INSIGHTS :Patient  'Mrs. Kimberly627 Collier206'  has most Number of Visits Within 30 Days 
#Which is Very Suspicious from Medical POint of View , Followed by Patient 'Mr. Mariano761 OKon634' with 876 visit



