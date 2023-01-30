# dw_challenge
Solutions to dw_challange
## Task1 = t1
#### t1_get_attachments.py
- loads emails from dw_challange2023@gmail.com  
The correct access file *token.json* in the working directory is needed.
- seachers for emails with subject line 'Your report is ready' 
- download attached files to directory working_dir/t1_attachments 

#### t1_csv_to_sql.py 
...loads the csv files as one table (excluding duplicates) into sql database *DWchallenge_t1*.

#### t1_create_database.sql 
... creates the tables and relations for the database.  

The tables were created with trying to reduce space usage.   
Further steps could be data cealing. For example in the list of sponsors, McDonalds occurs twice as it has two differenct sponsor categories. This could be changed  and thus the "Sponsor Id" could serve as unique identifier.

The complete database can be seen in *t1_erd.pgerd* and *t1_schema_ERD.png*.

#### t1_insights.sql
... contains queries that can be used to create different insights.
The results of those queries are as sceen shots in the files *t1_insight_*.png*
Other possible insights could for example include grouping for page categories.

## Task2 = t2
#### t2_csv_to_sqldb.py
... loads dwh_dl_facebook_post_insights.csv to DWchallenge_t2 sql database

#### t2.sql
... unpacks the column 'post_video_view_time_by_age_bucket_and_gender' into data_t2_table, respectively data_t2_table_long, using *fct_create_jsonb_flat_table.sql*.  
It also calculates the sums of the view times for each gender and ages 18-34 ages. The results fo the query are shown in *t2_3_sums_sceenshot.png*.
