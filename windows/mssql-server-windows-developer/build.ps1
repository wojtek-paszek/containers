param(
    [Parameter(Mandatory=$false)],
    [string]$VERSION,
    [string]$SQL_COLLATION
)

docker build -t pachoo/mssql-server-windows-developer:$VERSION --build-arg VERSION=$VERSION --build-arg SQL_COLLATION=$SQL_COLLATION .
