-- create table with only col post_video_view_time_by_age_bucket_and_gender
CREATE TABLE data_t2_extract AS (SELECT index, CAST(post_video_view_time_by_age_bucket_and_gender AS json) FROM data_t2);

-- create new table "data_t2_extract_table" that has json keys as columns 
SELECT create_jsonb_flat_table('data_t2_extract', 'index', 'post_video_view_time_by_age_bucket_and_gender');

-- set values type text in data_t2_extract_table to int type
do $$
declare
t record;
begin
    for t IN select column_name, table_name
            from information_schema.columns
            where data_type='text' AND table_name = 'data_t2_extract_table'
    loop
        execute 'alter table ' || t.table_name || ' alter column "' || t.column_name|| '" type int USING "' || t.column_name|| '" :: int';
    end loop;
end$$;

-- list of columns with f
select column_name
   from information_schema.columns
   where table_name = 'data_t2_extract_table'
     and column_name like '%F%';

-- calcualte sums for sets of columns TODO: possible automate this in loop?
SELECT ("F.13-17" + "F.18-24" + "F.25-34" + "F.35-44" + "F.45-54" + "F.55-64" + "F.65+") AS f_posts,
	("M.13-17" + "M.18-24" + "M.25-34" + "M.35-44" + "M.45-54" + "M.55-64" + "M.65+") AS m_posts,
	("U.18-24" + "U.25-34" + "U.35-44" + COALESCE("U.45-54",0) + COALESCE("U.55-64",0) + "U.65+") AS u_posts,
	("F.18-24" + "F.25-34"+"M.18-24" + "M.25-34"+"U.18-24" + "U.25-34") AS posts_18_34
FROM data_t2_extract_table




------------tests, delete for final version
SELECT * FROM data_t2_extract_table



SELECT c.CategoryName,
  (select sum(val)
   from (SELECT TOP 5 od2.UnitPrice*od2.Quantity as val
         FROM [Order Details] od2, Products p2
         WHERE od2.ProductID = p2.ProductID
         AND c.CategoryID = p2.CategoryID
         ORDER BY 1 DESC
        ) t
  )



SELECT index,
	(SELECT SUM(t)
	 FROM (select column_name AS val
   			from information_schema.columns
   			where table_name = 'data_t2_extract_table'
     		and column_name like '%F%') t
	 )
FROM data_t2_extract_table