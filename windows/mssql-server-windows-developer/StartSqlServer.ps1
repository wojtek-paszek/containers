# The script sets:
# - the SA password and starts the SQL Server
# - paths of SQL Server database files

param(
    [Parameter(Mandatory=$false)]
    [string]$SA_PASSWORD,

    [Parameter(Mandatory=$false)]
    [string]$ACCEPT_EULA
)

if ($ACCEPT_EULA -ne "Y" -And $ACCEPT_EULA -ne "y")
{
    Write-Verbose "ERROR: You must accept the End User License Agreement before this container can start."
    Write-Verbose "Set the environment variable ACCEPT_EULA to 'Y' if you accept the agreement."

    exit 1
}

Write-Verbose "Preparing paths of database files"
New-Item -Force -ItemType Directory -Path "C:\MSSQL"
New-Item -Force -ItemType Directory -Path "C:\MSSQL\Data"
New-Item -Force -ItemType Directory -Path "C:\MSSQL\Log"
New-Item -Force -ItemType Directory -Path "C:\MSSQL\Backup"

# Start SQL Server service
Write-Verbose "Starting SQL Server"
Start-Service MSSQLSERVER

if ($sa_password -eq "_") {
    Write-Verbose "WARNING: Using default SA password = '_'"
}

Write-Verbose "Changing SA login credentials"
$sqlcmd = "ALTER LOGIN sa WITH password=" + "'" + $sa_password + "'" + "; ALTER LOGIN sa ENABLE;"
& sqlcmd -Q $sqlcmd

Write-Verbose "Setting database files paths"
$setPathsCommand =
   "EXEC xp_instance_regwrite
        N'HKEY_LOCAL_MACHINE',
        N'Software\Microsoft\MSSQLServer\MSSQLServer',
        N'DefaultData',
        REG_SZ,
        N'C:\MSSQL\Data';

    EXEC xp_instance_regwrite
        N'HKEY_LOCAL_MACHINE',
        N'Software\Microsoft\MSSQLServer\MSSQLServer',
        N'DefaultLog',
        REG_SZ,
        N'C:\MSSQL\Log';

    EXEC xp_instance_regwrite
        N'HKEY_LOCAL_MACHINE',
        N'Software\Microsoft\MSSQLServer\MSSQLServer',
        N'BackupDirectory',
        REG_SZ,
        N'C:\MSSQL\Backup';"
& sqlcmd -Q $setPathsCommand

Write-Verbose "Started SQL Server"

$lastCheck = (Get-Date).AddSeconds(-2)
while ($true)
{
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message
    $lastCheck = Get-Date
    Start-Sleep -Seconds 2
}
