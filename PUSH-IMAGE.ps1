param([string]$ImageFile = 'astra-desk.tar', [string]$Version = '1.0.0')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if ($Version -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,100}$') { throw 'Invalid Docker tag.' }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    foreach ($dockerBin in @("$env:LOCALAPPDATA/Programs/DockerDesktop/resources/bin", "$env:ProgramFiles/Docker/Docker/resources/bin")) {
        if (Test-Path -LiteralPath "$dockerBin/docker.exe") { $env:PATH = "$dockerBin;$env:PATH"; break }
    }
}
if (-not (Test-Path -LiteralPath $ImageFile)) { throw 'Extract the GitHub Actions docker-image artifact here first.' }
docker load --input $ImageFile
if ($LASTEXITCODE -ne 0) { throw 'Image load failed.' }
docker tag heetamin25/mongodb-lab18:latest "heetamin25/mongodb-lab18:$Version"
if ($LASTEXITCODE -ne 0) { throw 'Expected Astra Desk image not found.' }
docker login --username heetamin25
if ($LASTEXITCODE -ne 0) { throw 'Docker Hub login failed.' }
docker push "heetamin25/mongodb-lab18:$Version"
if ($LASTEXITCODE -ne 0) { throw 'Version push failed.' }
docker push heetamin25/mongodb-lab18:latest
if ($LASTEXITCODE -ne 0) { throw 'Latest push failed.' }
Write-Host 'Astra Desk image published to Docker Hub.'
