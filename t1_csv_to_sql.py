import pandas as pd
import os
from sqlalchemy import create_engine

# assign directory
directory = 't1_attachments'

engine = create_engine('postgresql://postgres:assessment2023@localhost:5432/DWchallenge_t1')

# iterate over files in directory
for filename in os.scandir(directory):
    if filename.is_file() and filename.name.endswith(".csv") :
        df=pd.read_csv(filename)
        # Save the data from dataframe to postgres
        table_name='report_'+filename.name[:4]+'_'+filename.name[5:7]+'_'+filename.name[8:10]
        df.to_sql(
            table_name,
            engine,
            index=False,  # Not copying over the index
            if_exists='replace' # replace table
        )
        print(table_name+' table saved to database')





