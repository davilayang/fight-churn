# Fight Churn with Data, Python

> Using Python to better understand the metrics and analytics

## Connection with Pandas

```python
import sqlalchemy
import pandas as pd

# Make a sql connection with sqlalchmey
conn_string = "postgresql://postgres-db/churn?user=postgres&password=password" 
engine = sqlalchemy.create_engine(conn_string)
conn = engine.connect()

# Query with Pandas, e.g. list all tables
df = pd.read_sql_query("SELECT * FROM information_schema.tables;", conn)
df.head()
```

## Others