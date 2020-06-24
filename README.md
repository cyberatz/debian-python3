# debian-python3

debian container containing python3, ODBC Driver 17 for SQL Server, pymysql, pyodbc, pandas and more. 

# Build
## Build status: 
![Build Status](https://travis-ci.com/cyberatz/debian-python3.svg?branch=master&status=started)

## Manual Build
docker build -t debian-python3 .

# Run
## Kerberos 
- 

## Use python
docker run --rm -ti -v $(pwd):/app andrevs/debian-python3 /app/<file.py>
