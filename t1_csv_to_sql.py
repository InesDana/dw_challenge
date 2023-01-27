import pandas as pd
import os
from sqlalchemy import create_engine

# assign directory
directory = 't1_attachments'

engine = create_engine('postgresql://postgres:assessment2023@localhost:5432/DWchallenge_t1')
table_name = 'reports'
# iterate over files in directory and read
counter =0
for filename in os.scandir(directory):
    if filename.is_file() and filename.name.endswith(".csv") :
        counter = counter +1
        if counter == 1:
            df = pd.read_csv(filename)
        else:
            df = df.append(pd.read_csv(filename),ignore_index=True)


df=df.drop_duplicates()

 # Save the data from dataframe to postgres
df.to_sql(
            table_name,
            engine,
            index=True,  # Not copying over the index
            if_exists='replace'  # append or replace table
        )
print(table_name+' table saved to database')
