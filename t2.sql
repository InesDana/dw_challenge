-- create new table "data_t2_table" that has json keys from column 'post_video_view_time_by_age_bucket_and_gender' in data_t2 as columns 
-- function create_jsonb_flat_table in file 'fct_create_jsonb_flat_table.sql'
SELECT create_jsonb_flat_table('data_t2', 'index', 'CAST(post_video_view_time_by_age_bucket_and_gender AS json)');

-- set values type text in data_t2_table to type int 
DO $$
DECLARE t record;
BEGIN
    FOR t IN SELECT column_name
            FROM information_schema.columns
            WHERE data_type='text' AND table_name = 'data_t2_table'
    LOOP
        EXECUTE 'alter table data_t2_table alter column "' || t.column_name|| '" type int USING "' || t.column_name|| '" :: int';
    END LOOP;
END$$;


-- From 2022_Junior_DE_Task.pdf Task 2.2 I was uncertai whether data_t2_table was sufficient, therefore also created data_t2_table_long
-- create table with only 'post_video_view_time_by_age_bucket_and_gender' unpacked and all other columns in original from as in dwh_dl_facebook_post_insights.csv
DROP TABLE IF EXISTS data_t2_table_long;
CREATE TABLE data_t2_table_long AS (SELECT * FROM data_t2 
											INNER JOIN data_t2_table USING (index));
ALTER TABLE data_t2_table_long
DROP COLUMN post_video_view_time_by_age_bucket_and_gender;

-- set change names of columns unpacked from post_video_view_time_by_age_bucket_and_gender
DO $$
DECLARE t record;
BEGIN
    FOR t IN SELECT column_name
            FROM information_schema.columns
            WHERE (column_name LIKE '%F.%' OR column_name LIKE '%M.%' OR column_name LIKE '%U.%')
				   AND table_name = 'data_t2_table_long'
    LOOP
        EXECUTE 'alter table data_t2_table_long rename column "' || t.column_name|| '" to "post_video_view_time_by_age_bucket_and_gender_' || t.column_name ||'"';
    END LOOP;
END$$;



-- list of columns arge 18-34 (also used for the other sums check column lists)
SELECT column_name
   FROM information_schema.columns
   WHERE table_name = 'data_t2_table'
     AND (column_name LIKE '%18%' OR column_name LIKE '%34%');

-- calcualte sums for sets of columns        
SELECT ("F.13-17" + "F.18-24" + "F.25-34" + "F.35-44" + "F.45-54" + "F.55-64" + "F.65+") AS f_posts,
	("M.13-17" + "M.18-24" + "M.25-34" + "M.35-44" + "M.45-54" + "M.55-64" + "M.65+") AS m_posts,
	("U.18-24" + "U.25-34" + "U.35-44" + COALESCE("U.45-54",0) + COALESCE("U.55-64",0) + "U.65+") AS u_posts,
	("F.18-24" + "F.25-34"+"M.18-24" + "M.25-34"+"U.18-24" + "U.25-34") AS posts_18_34
FROM data_t2_table;