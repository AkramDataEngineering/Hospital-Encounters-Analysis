🏥 Hospital Encounters Analysis — SQL Case Study
This project uses SQL to analyze hospital encounter data from a hypothetical hospital_db schema. It answers real-world healthcare operations and billing questions using raw relational tables (e.g., encounters, patients, payers).

🎯 Project Goals
Support healthcare operations and finance teams with clear insights about encounter volume, cost structure, coverage gaps, and patient behavior.

📌 Database Tables Used
encounters: visit-level data with dates, classes, procedures, costs

patients: patient-level demographics

payers (if available): insurance / coverage data

🗂️ OBJECTIVE 1: Encounters Overview
-- a. How many total encounters occurred each year?

-- b. For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?

-- c. What percentage of encounters were over 24 hours versus under 24 hours?


💰 OBJECTIVE 2: Cost & Coverage Insights
-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?

-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?

-- d. What is the average total claim cost for encounters, broken down by payer?

🧑‍⚕️ OBJECTIVE 3: Patient Behavior Analysis

-- a. How many unique patients were admitted each quarter over time?

-- b. How many patients were readmitted within 30 days of a previous encounter?

-- c. Which patients had the most readmissions?



🧩 Tools Used
MySQL for SQL querying

GitHub for version control and documentation

🗨️ Notes
This project is intended to demonstrate practical SQL analysis on healthcare encounters data.

The SQL patterns here can be adapted to other domains with event / transaction data.

