SELECT * FROM public.opportunity_raw
ORDER BY opportunity_id ASC;


SELECT COUNT(*) AS total_rows
FROM public.opportunity_raw;


SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'opportunity_raw'
  AND table_schema = 'public';

SELECT 
    COUNT(*) FILTER (WHERE opportunity_id IS NULL) AS missing_opportunity_id,
    COUNT(*) FILTER (WHERE opportunity_name IS NULL) AS missing_opportunity_name,
    COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE opportunity_code IS NULL) AS missing_opportunity_code,
    COUNT(*) FILTER (WHERE tracking_questions IS NULL) AS missing_tracking_questions
FROM public.opportunity_raw;

SELECT
    (COUNT(opportunity_id) <> COUNT(DISTINCT opportunity_id)) AS opportunity_id_has_duplicates,
    (COUNT(opportunity_name) <> COUNT(DISTINCT opportunity_name)) AS opportunity_name_has_duplicates,
    (COUNT(category) <> COUNT(DISTINCT category)) AS category_has_duplicates,
    (COUNT(opportunity_code) <> COUNT(DISTINCT opportunity_code)) AS opportunity_code_has_duplicates,
    (COUNT(tracking_questions) <> COUNT(DISTINCT tracking_questions)) AS tracking_questions_has_duplicates
FROM public.opportunity_raw;

SELECT
  COUNT(CASE WHEN opportunity_id IS NULL THEN 1 END) AS opportunity_id_null_count,
  COUNT(CASE WHEN opportunity_name IS NULL THEN 1 END) AS opportunity_name_null_count,
  COUNT(CASE WHEN category IS NULL THEN 1 END) AS category_null_count,
  COUNT(CASE WHEN opportunity_code IS NULL THEN 1 END) AS opportunity_code_null_count,
  COUNT(CASE WHEN tracking_questions IS NULL THEN 1 END) AS tracking_questions_null_count
FROM opportunity_raw;




-- EDA Part

SELECT category, COUNT(*) AS frequency
FROM opportunity_raw
GROUP BY category
ORDER BY frequency DESC;

SELECT opportunity_name, COUNT(*) AS repetition_count
FROM opportunity_raw
GROUP BY opportunity_name
HAVING COUNT(*) > 1
ORDER BY repetition_count DESC;



SELECT COUNT(*) AS count_null_text
FROM opportunity_raw
WHERE tracking_questions = 'NULL';


SELECT
  category,
  SUM(CASE WHEN tracking_questions IS NOT NULL AND tracking_questions <> 'NULL' THEN 1 ELSE 0 END) AS with_valid_tracking_questions,
  SUM(CASE WHEN tracking_questions IS NULL OR tracking_questions = 'NULL' THEN 1 ELSE 0 END) AS without_valid_tracking_questions
FROM opportunity_raw
GROUP BY category
ORDER BY category;





