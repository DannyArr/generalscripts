# SQL Script Run

A PowerShell module to run T-SQL scripts using SQLCMD.exe. 

A path is provided to a location of the scipts. Any sub-directories will be included. Scripts will be executing in alphanumeric order by directory, then filename. 

For example:

  1) .\folder1\script1.sql
  2) .\folder1\script2.sql
  3) .\folder2\script1.sql
  4) .\folder2\script2.sql

## Functions:

For further details on each funtion execute "Get-Help *function_name*"

#### Get-SqlConfig
Retrieves config from the JSON config file. Will retrieve config for the host that matches where the function is being run.

#### Get-SqlScript
Will list out all .sql scripts (will recurse) for a given path in alpha-numeric order.

#### Invoke-SqlScript
Will execute a script using SQLCMD.exe. It can be piped, but will stop the pipeline and break any execution of a script if an error is encountered. All output from SQLCMD is logged.
