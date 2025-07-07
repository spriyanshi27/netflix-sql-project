
import pandas as pd
import sqlalchemy as sal
from sqlalchemy.types import Unicode

# load the CSV
df = pd.read_csv(r"C:\Users\Priyanshi\Desktop\netflix_titles.csv")

# connect to SQL Server
engine = sal.create_engine("mssql://LAPTOP-JEHG20TQ\SQLEXPRESS/master?driver=ODBC+DRIVER+17+FOR+SQL+SERVER")
conn = engine.connect()

# write to SQL table
df.to_sql(
    'netflix_raw',
    con=conn,
    index=False,
    if_exists='append',
    dtype={'title': Unicode()}
)

# close connection
conn.close()

# basic checks
print(df.head())
print(df[df['show_id'] == 's5023'])
print("Max description length:", max(df['description'].dropna().str.len()))
print("Missing values:\n", df.isna().sum())
