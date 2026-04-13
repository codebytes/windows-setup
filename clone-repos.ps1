# Clone codebytes repositories
# Run this AFTER: gh auth login

$repoRoot = if (Test-Path 'D:\github') { 'D:\github' } else { "$env:USERPROFILE\source\repos" }

# Verify gh is authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not authenticated to GitHub. Run 'gh auth login' first." -ForegroundColor Red
    exit 1
}

Write-Host "Authenticated to GitHub. Cloning repos to $repoRoot..." -ForegroundColor Green

if (-not (Test-Path $repoRoot)) {
    New-Item -Path $repoRoot -ItemType Directory -Force | Out-Null
}

# List of repos to clone (add your repos here)
$repos = @(
    "codebytes/windows-setup"
    "codebytes/dotnet-presentations"
    "codebytes/dev-containers-workshop"
)

foreach ($repo in $repos) {
    $repoName = $repo.Split("/")[-1]
    $targetPath = Join-Path $repoRoot $repoName

    if (Test-Path $targetPath) {
        Write-Host "SKIP: $repoName already exists" -ForegroundColor Yellow
    } else {
        Write-Host "Cloning: $repo" -ForegroundColor Cyan
        gh repo clone $repo $targetPath
    }
}

Write-Host ""
Write-Host "Done! Your repos are in $repoRoot" -ForegroundColor Green
