import pandas as pd
import os
from sqlalchemy import create_engine

# assign directory
directory = 't1_attachments'

engine = create_engine('postgresql://postgres:assessment2023@localhost:5432/DWchallenge_t1')

# iterate over files in directory
for filename in os.scandir(directory):
    if filename.is_file() and filename.name.endswith(".csv") :
        #print(filename.path, filename.name)
        df=pd.read_csv(filename)
        # Save the data from dataframe to postgres
        df.to_sql(
            str(filename.name[:10]),
            engine,
            index=False,  # Not copying over the index
            if_exists='replace'
        )
        print(filename.name[:10])





