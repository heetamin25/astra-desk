$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    $dockerCandidates = @("$env:LOCALAPPDATA/Programs/DockerDesktop/resources/bin", "$env:ProgramFiles/Docker/Docker/resources/bin")
    foreach ($dockerBin in $dockerCandidates) { if (Test-Path -LiteralPath "$dockerBin/docker.exe") { $env:PATH = "$dockerBin;$env:PATH"; break } }
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Install Docker Desktop and start Linux containers, then retry.' }
if (-not (Test-Path -LiteralPath '.env')) {
    function New-LocalSecret { $b = New-Object byte[] 32; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); -join ($b | ForEach-Object { $_.ToString('x2') }) }
    $appSecret = New-LocalSecret
    $dbSecret = New-LocalSecret
    @("APP_USERNAME=admin", "APP_PASSWORD=$appSecret", "MONGO_PASSWORD=$dbSecret", 'GEMINI_API_KEY=', 'GEMINI_MODEL=gemini-3.1-flash-lite') | Set-Content -LiteralPath '.env' -Encoding ascii
    Write-Host 'Created private .env. Add GEMINI_API_KEY there. Login username: admin; password is APP_PASSWORD in .env.'
}
docker info | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Start Docker Desktop with Linux containers.' }
docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Invalid Compose configuration. Check .env.' }
docker compose up --build -d --wait --wait-timeout 180
if ($LASTEXITCODE -ne 0) { throw 'Startup failed. Run docker compose logs --tail 100 app mongo.' }
Write-Host 'Ready at http://localhost:8019. Import public evidence in AI Chatbot, then ask a question.'
