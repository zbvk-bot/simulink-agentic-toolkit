$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRaw = "https://raw.githubusercontent.com/zbvk-bot/simulink-agentic-toolkit/main"
$targetDir = Join-Path $env:USERPROFILE "simulink-ollama-agent"

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $targetDir "tools") | Out-Null

Write-Host "Скачивание файлов агента..."
Invoke-WebRequest -Uri "$repoRaw/start.py" -OutFile (Join-Path $targetDir "start.py")
Invoke-WebRequest -Uri "$repoRaw/tools/tools.json" -OutFile (Join-Path $targetDir "tools\tools.json")

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

$pythonCmd = $null
foreach ($candidate in @("python", "py")) {
    if (Test-Command $candidate) { $pythonCmd = $candidate; break }
}
if (-not $pythonCmd) {
    Write-Host "Python не найден."
    Write-Host "Установите Python 3 с https://www.python.org/downloads/ и запустите установщик ещё раз."
    Read-Host "Нажмите Enter для выхода"
    exit 1
}

if (-not (Test-Command "ollama")) {
    Write-Host "Ollama не найдена."
    Write-Host "Установите её с https://ollama.com/download и запустите установщик ещё раз."
    Read-Host "Нажмите Enter для выхода"
    exit 1
}

try {
    Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 | Out-Null
} catch {
    Write-Host "Похоже, Ollama не запущена."
    Write-Host "Запустите Ollama и повторите установку."
    Read-Host "Нажмите Enter для выхода"
    exit 1
}

$suggestedModel = "qwen3:8b"
$modelsResponse = Invoke-RestMethod -Uri "http://localhost:11434/api/tags"
$installedModels = @($modelsResponse.models | ForEach-Object { $_.name })

$modelName = $null
if ($installedModels.Count -gt 0) {
    Write-Host ""
    Write-Host "Установленные модели Ollama:"
    for ($i = 0; $i -lt $installedModels.Count; $i++) {
        Write-Host "  $($i + 1)) $($installedModels[$i])"
    }
    Write-Host "  0) Скачать предложенную модель ($suggestedModel)"
    $choice = Read-Host "Введите номер модели"
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $installedModels.Count) {
        $modelName = $installedModels[[int]$choice - 1]
    }
}

if (-not $modelName) {
    $modelName = $suggestedModel
    $hasSuggested = $installedModels | Where-Object { $_ -like "$suggestedModel*" }
    if (-not $hasSuggested) {
        & ollama pull $modelName
    }
}

$defaultServer = Join-Path $env:USERPROFILE ".matlab\agentic-toolkits\bin\matlab-mcp-server.exe"
if (-not (Test-Path $defaultServer)) {
    Write-Host "MATLAB MCP-сервер не найден по стандартному пути:"
    Write-Host $defaultServer
    Write-Host "Убедитесь, что MATLAB установлен и вы выполнили setupAgenticToolkit(""install"") в MATLAB."
    $customServer = Read-Host "Если сервер установлен в другом месте, вставьте полный путь (или нажмите Enter, чтобы пропустить)"
    if ($customServer -and (Test-Path $customServer)) {
        $defaultServer = $customServer
    } else {
        Write-Host "Продолжаем без сервера - агент не запустится, пока MATLAB MCP-сервер не будет доступен."
    }
}

$toolsPath = Join-Path $targetDir "tools\tools.json"
$startPath = Join-Path $targetDir "start.py"

Write-Host "Установка завершена. Запуск агента..."
& $pythonCmd $startPath --server $defaultServer --tools $toolsPath --model $modelName
Read-Host "Нажмите Enter для выхода"
