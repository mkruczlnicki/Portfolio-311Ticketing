--Goal: Calculate the total count of tickets by year & quarter. 
--Seeking to: Identify trends in overall data. Found seasonality peaking in 3rd quarter.
--Used Case statement to bucket tickets into Closed/Not Closed/Voided for easier analysis. Used Case statement and Date Part to create quarters. Filtered out status duplicates.
SELECT
	CONCAT(create_year,' ',quarter)
	,COUNT(*) AS count_of_tickets
	,CASE
		WHEN status ILIKE '%closed%' THEN 'Closed'
		WHEN status ILIKE '%void%' THEN 'Voided'
		ELSE 'Not Closed'
	END AS closed_category
FROM
(
SELECT
	status
	,ROUND(EXTRACT(DAY FROM(closed_date-created_date))::numeric,2) AS time_to_close
	,CASE
		WHEN DATE_PART('month',created_date) IN (1,2,3) THEN 'Q1'
		WHEN DATE_PART('month',created_date) IN (4,5,6) THEN 'Q2'
		WHEN DATE_PART('month',created_date) IN (7,8,9) THEN 'Q3'
		WHEN DATE_PART('month',created_date) IN (10,11,12) THEN 'Q4'
	END as quarter
	,DATE_PART('year',created_date) AS create_year
FROM dc_311_2016
WHERE status NOT ILIKE '%duplicate%'
) AS Temp1
GROUP BY 1,3;

--Goal: Calculate overall average time to close. 
--Seeking to: Identify trends in overall data. Found steadily decreasing average time to close tickets since late 2018.
--Used Case statement and Date Part to create quarters. Filtered out status duplicates and active tickets. Bucketing by closed/not closed/voided not necessary as only closed tickets have a "time_to_close" field.
SELECT
	CONCAT(create_year,' ',quarter)
	,COUNT(*) AS count_of_tickets
	,ROUND(SUM(time_to_close)/COUNT(*),2) AS avg_time_to_close
FROM
(
SELECT
	ROUND(EXTRACT(DAY FROM(closed_date-created_date))::numeric,2) AS time_to_close
	,CASE
		WHEN DATE_PART('month',created_date) IN (1,2,3) THEN 'Q1'
		WHEN DATE_PART('month',created_date) IN (4,5,6) THEN 'Q2'
		WHEN DATE_PART('month',created_date) IN (7,8,9) THEN 'Q3'
		WHEN DATE_PART('month',created_date) IN (10,11,12) THEN 'Q4'
	END as quarter
	,DATE_PART('year',created_date) AS create_year
FROM dc_311_2020
WHERE closed_date IS NOT NULL
	AND status NOT ILIKE '%duplicate%'
) AS Temp1
GROUP BY 1;

--Goal: Calculate Quarterly Average Time to Close Tickets by Agency
--Seeking to: Identify if the improvements in the time to close tickets can be pinpointed to certain government agencies. Found DDOT as an outlier in registering significant reduction in time to close tickets 
--Used Case statement and Date Part to create quarters. Filtered out status duplicates and active tickets. 
SELECT
	responsibleagency
	,quarter
	,COUNT(*) AS count_of_tickets
	,SUM(time_to_close) AS total_time_to_close
FROM
(
SELECT
	responsibleagency
	,ROUND(EXTRACT(DAY FROM(closed_date-created_date))::numeric,2) AS time_to_close
	,CASE
		WHEN DATE_PART('month',created_date) IN (1,2,3) THEN 'Q1'
		WHEN DATE_PART('month',created_date) IN (4,5,6) THEN 'Q2'
		WHEN DATE_PART('month',created_date) IN (7,8,9) THEN 'Q3'
		WHEN DATE_PART('month',created_date) IN (10,11,12) THEN 'Q4'
	END as quarter
	,DATE_PART('year',created_date) AS create_year
FROM dc_311_2020
WHERE closed_date IS NOT NULL
	AND status NOT ILIKE '%duplicate%'
) AS Temp1
GROUP BY 1,2;

--Goal: Calculate Time to Close by Ticket Category for DDOT
--Seeking to: Determine if some category of ticketing was the catalyst for the agency-wide improvement in efficiency. Found several segments that improved efficiency and likely were the result of technological improvements like LED lighting and digital payments for street parking.
--Used Case statement and Date Part to create quarters. Filtered out status duplicates and active tickets. 
SELECT
	category
	,create_year
	,quarter
	,CONCAT(create_year,' ',quarter)
	,COUNT(*) AS count_of_tickets
	,SUM(time_to_close) AS total_time_to_close
FROM
(
SELECT
	responsibleagency
	,category
	,ROUND(EXTRACT(DAY FROM(closed_date-created_date))::numeric,2) AS time_to_close
	,CASE
		WHEN DATE_PART('month',created_date) IN (1,2,3) THEN 'Q1'
		WHEN DATE_PART('month',created_date) IN (4,5,6) THEN 'Q2'
		WHEN DATE_PART('month',created_date) IN (7,8,9) THEN 'Q3'
		WHEN DATE_PART('month',created_date) IN (10,11,12) THEN 'Q4'
	END as quarter
	,DATE_PART('year',created_date) AS create_year
FROM dc_311_2016
WHERE closed_date IS NOT NULL
	AND status NOT ILIKE '%duplicate%'
) AS Temp1
WHERE responsibleagency = 'DDOT'
GROUP BY 1,2,3;

--Goal: Calculate total tickets created by quarter and segmented by responsibleagency.
--Seeking to: Identify which agencies may be creating tickets in seasonal trends. This could help to forecast demand and improve ticket response times. Found DPW exibited the highest number of tickets created and had strong seasonality.
--Used Case statement and Date Part to create quarters. Filtered out status duplicates and active tickets. 
SELECT
	responsibleagency
	,CONCAT(create_year,' ',quarter)
	,COUNT(*) AS count_of_tickets
FROM
(
SELECT
	status
	,responsibleagency
	,ROUND(EXTRACT(DAY FROM(closed_date-created_date))::numeric,2) AS time_to_close
	,CASE
		WHEN DATE_PART('month',created_date) IN (1,2,3) THEN 'Q1'
		WHEN DATE_PART('month',created_date) IN (4,5,6) THEN 'Q2'
		WHEN DATE_PART('month',created_date) IN (7,8,9) THEN 'Q3'
		WHEN DATE_PART('month',created_date) IN (10,11,12) THEN 'Q4'
	END as quarter
	,DATE_PART('year',created_date) AS create_year
FROM dc_311_2016
WHERE status NOT ILIKE '%duplicate%'
) AS Temp1
GROUP BY 1,2;

--Goal: Calculate the impact of seasonality and higher ticket volume on DPW's ticket closure times
--Seeking to: Identify if during periods of higher volume, DPW experiences greater inefficiencies and is slower to close tickets. Found that this was somewhat true, but overall, the agency was fairly good at maintainging prompt and consistent ticket closing timelines
SELECT
	category
	,responsibleagency
	,quarter
	,COUNT(*) AS count_of_tickets
	,SUM(time_to_close) AS total_time_to_close
FROM
(
SELECT
	category
	,responsibleagency
	,ROUND(EXTRACT(DAY FROM(closed_date-created_date))::numeric,2) AS time_to_close
	,CASE
		WHEN DATE_PART('month',created_date) IN (1,2,3) THEN 'Q1'
		WHEN DATE_PART('month',created_date) IN (4,5,6) THEN 'Q2'
		WHEN DATE_PART('month',created_date) IN (7,8,9) THEN 'Q3'
		WHEN DATE_PART('month',created_date) IN (10,11,12) THEN 'Q4'
	END as quarter
	,DATE_PART('year',created_date) AS create_year
FROM dc_311_2020
WHERE closed_date IS NOT NULL
	AND status NOT ILIKE '%duplicate%'
	AND responsibleagency = 'DPW'
) AS Temp1
GROUP BY 1,2,3
ORDER BY count_of_tickets DESC;

--Goal: Calculate Time to Close by Ticket Category for DPW
--Seeking to: Determine if some category of ticketing is driving the seasonal trends. Found the highest volume tickets were for categories that would be challenging to gain efficiencies on without increased labor (trash collection, public space cleaning, snow removal)
SELECT
	category
	,responsibleagency
	,COUNT(*) AS count_of_tickets
	,create_year
	,SUM(time_to_close) AS total_time_to_close
FROM
(
SELECT
	category
	,responsibleagency
	,ROUND(EXTRACT(DAY FROM(closed_date-created_date))::numeric,2) AS time_to_close
	,CASE
		WHEN DATE_PART('month',created_date) IN (1,2,3) THEN 'Q1'
		WHEN DATE_PART('month',created_date) IN (4,5,6) THEN 'Q2'
		WHEN DATE_PART('month',created_date) IN (7,8,9) THEN 'Q3'
		WHEN DATE_PART('month',created_date) IN (10,11,12) THEN 'Q4'
	END as quarter
	,DATE_PART('year',created_date) AS create_year
FROM dc_311_2019
WHERE status NOT ILIKE '%duplicate%'
	AND responsibleagency = 'DPW'
) AS Temp1
GROUP BY 1,2,4
ORDER BY count_of_tickets DESC;