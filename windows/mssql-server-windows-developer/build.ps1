param(
    [Parameter(Mandatory=$false)]
    [string]$VERSION
)

docker build -t pachoo/mssql-server-windows-developer:$VERSION --build-arg VERSION=$VERSION .
