# Cohesity REST API PowerShell Example - Instant SQL Clone Attach

Warning: this code is provided on a best effort basis and is not in any way officially supported or sanctioned by Cohesity. The code is intentionally kept simple to retain value as example code. The code in this repository is provided as-is and the author accepts no liability for damages resulting from its use.

This script demonstrates how to perform a SQL Clone Attach using PowerShell. The script takes a thin-provisioned clone of the latest backup of a SQL database and attaches it to a SQL server.

The script takes the following parameters:

* -vip (DNS or IP of the Cohesity Cluster)
* -username (Cohesity User Name)
* -domain (optional - defaults to 'local')
* -sourceServer (source SQL Server Name)
* -sourceDB (source Database Name)
* -targetServer (optional - SQL Server to attach clone to, defaults to same as sourceServer)
* -targetDB (optional - target Database Name - defaults to same as source)
* -targetInstance (optional - name of SQL instance on targetServer, defaults to MSSQLSERVER)

## Components

* cloneSQL.ps1: the main powershell script
* cohesity-api.ps1: the Cohesity REST API helper module

Place both files in a folder together and run the main script like so:

```powershell
./cloneSQL.ps1 -vip mycluster -username admin -sourceServer SQL2012PROD `
    -sourceDB CohesityDB -targetServer SQL2012DEV -targetDB CohesityDB-Dev

Connected!

Cloning CohesityDB to SQL2012DEV as CohesityDB-Dev
```

## Download the script

Run these commands from PowerShell to download the script(s) into your current directory

```powershell
# Begin download commands
(Invoke-WebRequest -Uri https://raw.githubusercontent.com/bseltz-cohesity/scripts/master/sql-scripts/cloneSQL/cloneSQL.ps1).content | Out-File cloneSQL.ps1; (Get-Content cloneSQL.ps1) | Set-Content cloneSQL.ps1
(Invoke-WebRequest -Uri https://raw.githubusercontent.com/bseltz-cohesity/scripts/master/sql-scripts/cloneSQL/cohesity-api.ps1).content | Out-File cohesity-api.ps1; (Get-Content cohesity-api.ps1) | Set-Content cohesity-api.ps1
# End download commands
```