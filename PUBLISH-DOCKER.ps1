param([string]$Version = '2.0.0')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if ($Version -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,100}$') { throw 'Invalid Docker version tag.' }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    $dockerCandidates = @("$env:LOCALAPPDATA/Programs/DockerDesktop/resources/bin", "$env:ProgramFiles/Docker/Docker/resources/bin")
    foreach ($dockerBin in $dockerCandidates) { if (Test-Path -LiteralPath "$dockerBin/docker.exe") { $env:PATH = "$dockerBin;$env:PATH"; break } }
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Install Docker Desktop with Linux containers first.' }
docker info | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Docker engine unavailable.' }
docker login --username heetamin25
if ($LASTEXITCODE -ne 0) { throw 'Docker Hub login failed.' }
docker build --pull --tag "heetamin25/mongodb-lab18:$Version" --tag 'heetamin25/mongodb-lab18:latest' .
if ($LASTEXITCODE -ne 0) { throw 'Build failed; nothing pushed.' }
docker push "heetamin25/mongodb-lab18:$Version"
if ($LASTEXITCODE -ne 0) { throw 'Version push failed.' }
docker push 'heetamin25/mongodb-lab18:latest'
if ($LASTEXITCODE -ne 0) { throw 'Latest push failed.' }
Write-Host "Published heetamin25/mongodb-lab18:$Version and latest. MongoDB runs via the separate official image in Compose."
