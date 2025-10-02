-- ~~~~~~~~~~(IMPORTING DATASET)~~~~~~~~~~~~
-- #####Creating Marketing Table

CREATE TABLE marketing_campaign ( ad_account_name VARCHAR(100), campaign_name VARCHAR(255), delivery_status VARCHAR(50), delivery_level VARCHAR(50), reach INTEGER, outbound_clicks INTEGER, outbound_type INTEGER, result_type VARCHAR(100), results INTEGER, cost_per_result NUMERIC(10,6),
amount_spent_aed NUMERIC(10,2), cpc NUMERIC(10,6),
reporting_starts DATE
);

COPY marketing_campaign( ad_account_name, campaign_name, delivery_status, delivery_level, reach, outbound_clicks, outbound_type, result_type, results, cost_per_result, amount_spent_aed, cpc, reporting_starts
)
FROM 'C:/Program Files/PostgreSQL/17/data/Marketing Campaign Data All Accounts (2023-2024)(Detail1).csv'
DELIMITER ','

CSV HEADER ENCODING 'LATIN1';

-- Running Query to check the Import select * from marketing_campaign limit 5;
-- Datatype of Each column SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'marketing_campaign';

-- ~~~~~~~~~~(ROWS AND COLUMNS)~~~~~~~~~~~~
-- ##### Checking Rows and Colums

-- number of rows SELECT
r.row_count, c.column_count
FROM
(SELECT COUNT(*) AS row_count FROM marketing_campaign) r
CROSS JOIN
(SELECT COUNT(*) AS column_count FROM information_schema.columns
WHERE table_name = 'marketing_campaign') c;
-- checking last rows
SELECT COUNT(*) FROM marketing_campaign; SELECT *
FROM marketing_campaign ORDER BY ad_account_name DESC LIMIT 10;
-- last 7 rows are null so deleting null rows DELETE FROM marketing_campaign
WHERE ad_account_name IS NULL;
-- checking last 5 rows again SELECT *
FROM marketing_campaign ORDER BY ad_account_name DESC LIMIT 5;
-- names of columns SELECT column_name
FROM information_schema.columns
WHERE table_name = 'marketing_campaign';

-- ~~~~~~~~~~(DATA CLEANING)~~~~~~~~~~~~
-- ####checking null values in each column SELECT string_agg(
format('COUNT(*) - COUNT(%I) AS %I_nulls', column_name,
column_name), ', '
) AS null_count_query

FROM information_schema.columns
WHERE table_name = 'marketing_campaign';
-- copy pasting output of previous query SELECT
COUNT(*) - COUNT(reporting_starts) AS reporting_starts_nulls, COUNT(*) - COUNT(outbound_type) AS outbound_type_nulls, COUNT(*) - COUNT(results) AS results_nulls,
COUNT(*) - COUNT(cost_per_result) AS cost_per_result_nulls, COUNT(*) - COUNT(amount_spent_aed) AS amount_spent_aed_nulls, COUNT(*) - COUNT(cpc) AS cpc_nulls,
COUNT(*) - COUNT(reach) AS reach_nulls,
COUNT(*) - COUNT(outbound_clicks) AS outbound_clicks_nulls, COUNT(*) - COUNT(campaign_name) AS campaign_name_nulls, COUNT(*) - COUNT(delivery_status) AS delivery_status_nulls, COUNT(*) - COUNT(delivery_level) AS delivery_level_nulls, COUNT(*) - COUNT(ad_account_name) AS ad_account_name_nulls, COUNT(*) - COUNT(result_type) AS result_type_nulls
FROM marketing_campaign;
-- cleaning null values
-- 1. cleaning campaign_name column SELECT *
FROM marketing_campaign WHERE campaign_name IS NULL;

UPDATE marketing_campaign SET campaign_name = 'Unnamed' WHERE campaign_name IS NULL;

SELECT *
FROM marketing_campaign
WHERE campaign_name = 'Unnamed';

SELECT *
FROM marketing_campaign WHERE campaign_name IS NULL;
-- 2. cleaning outbound_clicks column SELECT *
FROM marketing_campaign
WHERE outbound_clicks IS NULL;
-- the column outbound_clicks, outbound_type and cpc have 2 blank enteries and all of them belong to same rows
-- thats why filling the null values with 0 UPDATE marketing_campaign
SET
outbound_type = COALESCE(outbound_type, 0), outbound_clicks = COALESCE(outbound_clicks, 0), cpc = COALESCE(cpc, 0)
WHERE outbound_type IS NULL OR outbound_clicks IS NULL OR cpc IS NULL;
-- checking update SELECT *

FROM marketing_campaign WHERE outbound_clicks = 0;
-- checking all null values once again. SELECT
COUNT(*) - COUNT(reporting_starts) AS reporting_starts_nulls, COUNT(*) - COUNT(outbound_type) AS outbound_type_nulls, COUNT(*) - COUNT(results) AS results_nulls,
COUNT(*) - COUNT(cost_per_result) AS cost_per_result_nulls, COUNT(*) - COUNT(amount_spent_aed) AS amount_spent_aed_nulls, COUNT(*) - COUNT(cpc) AS cpc_nulls,
COUNT(*) - COUNT(reach) AS reach_nulls,
COUNT(*) - COUNT(outbound_clicks) AS outbound_clicks_nulls, COUNT(*) - COUNT(campaign_name) AS campaign_name_nulls, COUNT(*) - COUNT(delivery_status) AS delivery_status_nulls, COUNT(*) - COUNT(delivery_level) AS delivery_level_nulls, COUNT(*) - COUNT(ad_account_name) AS ad_account_name_nulls, COUNT(*) - COUNT(result_type) AS result_type_nulls
FROM marketing_campaign;
-- the table is now free from null values

-- #####Checking for dublicates rows SELECT COUNT(*) AS duplicate_rows FROM (
SELECT campaign_name FROM marketing_campaign
GROUP BY campaign_name, reach, cpc HAVING COUNT(*) > 1
) sub;
--there is no duplicate rows in marketing dataset

-- fixing problematic row with reach 0
-- replacing the 0 value with median SELECT *
FROM marketing_campaign WHERE reach = 0;
UPDATE marketing_campaign SET reach = sub.median_reach FROM (
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY reach) AS
median_reach
FROM marketing_campaign WHERE reach <> 0
) sub
WHERE reach = 0;

-- ~~~~~~~~~~~~(Data Description)~~~~~~~~~~

-- For numericals value SELECT string_agg(format(
$f$ SELECT
%L AS column_name,

MIN(%I) AS min_value, MAX(%I) AS max_value, AVG(%I) AS avg_value, STDDEV(%I) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY %I) AS
median_value,
MODE() WITHIN GROUP (ORDER BY %I) AS mode_value
FROM marketing_campaign
$f$,
column_name, column_name, column_name, column_name, column_name, column_name, column_name
), ' UNION ALL ')
FROM information_schema.columns
WHERE table_name = 'marketing_campaign'
AND data_type IN ('integer', 'numeric', 'real', 'double precision');
-- copy pasting output of previous query SELECT
'reach' AS column_name, MIN(reach) AS min_value, MAX(reach) AS max_value, AVG(reach) AS avg_value, STDDEV(reach) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY reach) AS
median_value,
MODE() WITHIN GROUP (ORDER BY reach) AS mode_value FROM marketing_campaign
UNION ALL SELECT
'outbound_clicks' AS column_name, MIN(outbound_clicks) AS min_value, MAX(outbound_clicks) AS max_value, AVG(outbound_clicks) AS avg_value, STDDEV(outbound_clicks) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY outbound_clicks) AS
median_value,
MODE() WITHIN GROUP (ORDER BY outbound_clicks) AS mode_value FROM marketing_campaign
UNION ALL SELECT
'outbound_type' AS column_name, MIN(outbound_type) AS min_value, MAX(outbound_type) AS max_value, AVG(outbound_type) AS avg_value, STDDEV(outbound_type) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY outbound_type) AS
median_value,
MODE() WITHIN GROUP (ORDER BY outbound_type) AS mode_value FROM marketing_campaign
UNION ALL SELECT
'results' AS column_name,

MIN(results) AS min_value, MAX(results) AS max_value, AVG(results) AS avg_value, STDDEV(results) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY results) AS
median_value,
MODE() WITHIN GROUP (ORDER BY results) AS mode_value FROM marketing_campaign
UNION ALL SELECT
'cost_per_result' AS column_name, MIN(cost_per_result) AS min_value, MAX(cost_per_result) AS max_value, AVG(cost_per_result) AS avg_value, STDDEV(cost_per_result) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cost_per_result) AS
median_value,
MODE() WITHIN GROUP (ORDER BY cost_per_result) AS mode_value FROM marketing_campaign
UNION ALL SELECT
'amount_spent_aed' AS column_name, MIN(amount_spent_aed) AS min_value, MAX(amount_spent_aed) AS max_value, AVG(amount_spent_aed) AS avg_value, STDDEV(amount_spent_aed) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount_spent_aed) AS median_value,
MODE() WITHIN GROUP (ORDER BY amount_spent_aed) AS mode_value FROM marketing_campaign
UNION ALL SELECT
'cpc' AS column_name, MIN(cpc) AS min_value, MAX(cpc) AS max_value, AVG(cpc) AS avg_value, STDDEV(cpc) AS stddev_value,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cpc) AS
median_value,
MODE() WITHIN GROUP (ORDER BY cpc) AS mode_value FROM marketing_campaign;

-- for catagorical data
-- getting catagorical columns name SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'marketing_campaign'
AND data_type IN ('character varying', 'text', 'char');
-- for ad_account name
SELECT ad_account_name AS value, COUNT(*) AS value_count FROM marketing_campaign
GROUP BY ad_account_name

ORDER BY value_count DESC;
-- for campaign_name
SELECT campaign_name AS value, COUNT(*) AS value_count FROM marketing_campaign
GROUP BY campaign_name ORDER BY value_count DESC;
-- for delivery_status
SELECT delivery_status AS value, COUNT(*) AS value_count FROM marketing_campaign
GROUP BY delivery_status ORDER BY value_count DESC;
-- for delivery_level
SELECT delivery_level AS value, COUNT(*) AS value_count FROM marketing_campaign
GROUP BY delivery_level ORDER BY value_count DESC;
-- for result_type
SELECT result_type AS value, COUNT(*) AS value_count FROM marketing_campaign
GROUP BY result_type ORDER BY value_count DESC;
-- for reporting_starts
SELECT reporting_starts AS value, COUNT(*) AS value_count FROM marketing_campaign
GROUP BY reporting_starts ORDER BY value_count DESC;

-- ~~~~~~~~~~~(DETECTING OUTLIERS)~~~~~~~~~~~~~
-- Getting numerical columns SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'marketing_campaign'
AND data_type IN ('smallint', 'integer', 'bigint',
'decimal', 'numeric', 'real', 'double
precision');
-- for ~~~~~~(reach)~~~~~~
-- no of outliers WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY reach) AS q1, percentile_cont(0.75) WITHIN GROUP (ORDER BY reach) AS q3, MIN(reach) AS min_val,
MAX(reach) AS max_val FROM marketing_campaign
),
outliers AS (
SELECT COUNT(*) AS outlier_count FROM marketing_campaign, bounds
WHERE reach < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR reach > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1)
) SELECT

b.min_val, b.max_val,
b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound, b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound, o.outlier_count
FROM bounds b CROSS JOIN outliers o;
-- outliers rows WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY reach) AS q1, percentile_cont(0.75) WITHIN GROUP (ORDER BY reach) AS q3
FROM marketing_campaign
) SELECT *
FROM marketing_campaign, bounds
WHERE reach < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR reach > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1)
ORDER BY reach DESC;
-- for ~~~~~~(outbound_clicks) WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY outbound_clicks)

AS q1, AS q3,

percentile_cont(0.75) WITHIN GROUP (ORDER BY outbound_clicks) MIN(outbound_clicks) AS min_val,
MAX(outbound_clicks) AS max_val

FROM marketing_campaign
),
outliers AS (
SELECT COUNT(*) AS outlier_count FROM marketing_campaign, bounds
WHERE outbound_clicks < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR outbound_clicks > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1)
) SELECT
b.min_val, b.max_val,
b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound, b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound, o.outlier_count
FROM bounds b CROSS JOIN outliers o;
-- outliers rows WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY outbound_clicks)

AS q1,

AS q3


percentile_cont(0.75) WITHIN GROUP (ORDER BY outbound_clicks)

FROM marketing_campaign
)
SELECT *

FROM marketing_campaign, bounds
WHERE outbound_clicks < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR outbound_clicks > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1);
-- for ~~~~~~(outbound_type)~~~~~~ WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY outbound_type)

AS q1, AS q3,

percentile_cont(0.75) WITHIN GROUP (ORDER BY outbound_type) MIN(outbound_type) AS min_val,
MAX(outbound_type) AS max_val

FROM marketing_campaign
),
outliers AS (
SELECT COUNT(*) AS outlier_count FROM marketing_campaign, bounds
WHERE outbound_type < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR outbound_type > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1)
) SELECT
b.min_val, b.max_val,
b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound, b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound, o.outlier_count
FROM bounds b CROSS JOIN outliers o;
-- outliers rows WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY outbound_type)

AS q1,

AS q3


percentile_cont(0.75) WITHIN GROUP (ORDER BY outbound_type)

FROM marketing_campaign
)
SELECT *
FROM marketing_campaign, bounds
WHERE outbound_type < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR outbound_type > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1);
-- for ~~~~~~~~~~~~(results)~~~~~~~~~ WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY results) AS q1, percentile_cont(0.75) WITHIN GROUP (ORDER BY results) AS q3, MIN(results) AS min_val,
MAX(results) AS max_val FROM marketing_campaign),
outliers AS (
SELECT COUNT(*) AS outlier_count FROM marketing_campaign, bounds
WHERE results < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1)

OR results > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1))
SELECT
b.min_val, b.max_val,
b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound, b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound, o.outlier_count
FROM bounds b CROSS JOIN outliers o;
-- outliers rows WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY results) AS q1, percentile_cont(0.75) WITHIN GROUP (ORDER BY results) AS q3
FROM marketing_campaign
) SELECT *
FROM marketing_campaign, bounds
WHERE results < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR results > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1)
ORDER BY results DESC;
-- for ~~~~~~~~~~~(cost_per_result)~~~~~~~~~~ WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY cost_per_result)

AS q1, AS q3,

percentile_cont(0.75) WITHIN GROUP (ORDER BY cost_per_result) MIN(cost_per_result) AS min_val,
MAX(cost_per_result) AS max_val

FROM marketing_campaign), outliers AS (
SELECT COUNT(*) AS outlier_count FROM marketing_campaign, bounds
WHERE cost_per_result < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR cost_per_result > bounds.q3 + 1.5 * (bounds.q3 -
bounds.q1)) SELECT
b.min_val, b.max_val,
b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound, b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound, o.outlier_count
FROM bounds b CROSS JOIN outliers o;
-- outliers rows WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY cost_per_result)

AS q1,

AS q3


percentile_cont(0.75) WITHIN GROUP (ORDER BY cost_per_result)

FROM marketing_campaign
)

SELECT *
FROM marketing_campaign, bounds
WHERE cost_per_result < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR cost_per_result > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1);
-- for ~~~~~~~~~~~(amount_spent_aed)~~~~~~~~~~~~~~~ WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY amount_spent_aed) AS q1,
percentile_cont(0.75) WITHIN GROUP (ORDER BY amount_spent_aed) AS q3,
MIN(amount_spent_aed) AS min_val, MAX(amount_spent_aed) AS max_val
FROM marketing_campaign), outliers AS (
SELECT COUNT(*) AS outlier_count FROM marketing_campaign, bounds
WHERE amount_spent_aed < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1)
OR amount_spent_aed > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1))
SELECT
b.min_val, b.max_val,
b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound, b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound, o.outlier_count
FROM bounds b CROSS JOIN outliers o;
-- outliers rows WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY amount_spent_aed) AS q1,
percentile_cont(0.75) WITHIN GROUP (ORDER BY amount_spent_aed) AS q3
FROM marketing_campaign
) SELECT *
FROM marketing_campaign, bounds
WHERE amount_spent_aed < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR amount_spent_aed > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1);
-- for ~~~~~~~~~~~(cpc)~~~~~~~~~~~ WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY cpc) AS q1, percentile_cont(0.75) WITHIN GROUP (ORDER BY cpc) AS q3, MIN(cpc) AS min_val,
MAX(cpc) AS max_val FROM marketing_campaign),
outliers AS (
SELECT COUNT(*) AS outlier_count FROM marketing_campaign, bounds

WHERE cpc < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR cpc > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1))
SELECT
b.min_val, b.max_val,
b.q1 - 1.5 * (b.q3 - b.q1) AS lower_bound, b.q3 + 1.5 * (b.q3 - b.q1) AS upper_bound, o.outlier_count
FROM bounds b CROSS JOIN outliers o;
-- outliers rows WITH bounds AS (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY cpc) AS q1, percentile_cont(0.75) WITHIN GROUP (ORDER BY cpc) AS q3
FROM marketing_campaign
) SELECT *
FROM marketing_campaign, bounds
WHERE cpc < bounds.q1 - 1.5 * (bounds.q3 - bounds.q1) OR cpc > bounds.q3 + 1.5 * (bounds.q3 - bounds.q1);

-- ~~~~~~~(CALCULATING CORRELATION)~~~~~~~~~~~~ SELECT
corr(reach, outbound_clicks) AS corr_reach_outbound_clicks, corr(reach, results) AS corr_reach_results,
corr(reach, cost_per_result) AS corr_reach_cost_per_result, corr(reach, amount_spent_aed) AS corr_reach_amount_spent_aed, corr(reach, cpc) AS corr_reach_cpc,
corr(outbound_clicks, results) AS corr_outbound_clicks_results, corr(outbound_clicks, cost_per_result) AS
corr_outbound_clicks_cost_per_result, corr(outbound_clicks, amount_spent_aed) AS
corr_outbound_clicks_amount_spent_aed, corr(outbound_clicks, cpc) AS corr_outbound_clicks_cpc,
corr(results, cost_per_result) AS corr_results_cost_per_result, corr(results, amount_spent_aed) AS corr_results_amount_spent_aed, corr(results, cpc) AS corr_results_cpc,
corr(cost_per_result, amount_spent_aed) AS corr_cost_per_result_amount_spent_aed,
corr(cost_per_result, cpc) AS corr_cost_per_result_cpc, corr(amount_spent_aed, cpc) AS corr_amount_spent_aed_cpc
FROM marketing_campaign;

-- ~~~~~~~~(KPIfor ad accounts)~~~~~~~~~~ SELECT
ad_account_name, AVG(cost_per_result) AS avg_cpc,
SUM(amount_spent_aed) AS total_amount_spent, SUM(results)::float / NULLIF(SUM(reach), 0) AS conversion_rate
FROM marketing_campaign GROUP BY ad_account_name ORDER BY ad_account_name;

SELECT
ad_account_name, AVG(reach) AS avg_reach,
AVG(outbound_clicks) AS avg_outbound_clicks, AVG(results) AS avg_results
FROM marketing_campaign GROUP BY ad_account_name;

SELECT
ad_account_name,
AVG(cost_per_result) AS avg_cost_per_result FROM marketing_campaign
GROUP BY ad_account_name ORDER BY ad_account_name;