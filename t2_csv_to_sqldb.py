import pandas as pd
import os
from sqlalchemy import create_engine

#load data
filename = 'Junior_DE_Task/dwh_dl_facebook_post_insights.csv'
df = pd.read_csv(filename)

engine = create_engine('postgresql://postgres:assessment2023@localhost:5432/DWchallenge_t2')
table_name = 'data_t2'

 # Save the data from dataframe to postgres
df.to_sql(
            table_name,
            engine,
            index=True,  # Not copying over the index
            if_exists='replace'  # append or replace table
        )
print(table_name+' table saved to database')