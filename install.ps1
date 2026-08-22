$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRaw = "https://raw.githubusercontent.com/zbvk-bot/simulink-agentic-toolkit/main"
$targetDir = Join-Path $env:USERPROFILE "simulink-ollama-agent"

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $targetDir "tools") | Out-Null

Write-Host "Скачивание файлов агента..."
Invoke-WebRequest -Uri "$repoRaw/start.py" -OutFile (Join-Path $targetDir "start.py") -UseBasicParsing
Invoke-WebRequest -Uri "$repoRaw/tools/tools.json" -OutFile (Join-Path $targetDir "tools\tools.json") -UseBasicParsing

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Test-RealPython($name) {
    try {
        $output = & $name --version 2>&1 | Out-String
    } catch {
        return $false
    }
    return $output -match "Python 3"
}

$pythonCmd = $null
foreach ($candidate in @("py", "python", "python3")) {
    if ((Test-Command $candidate) -and (Test-RealPython $candidate)) {
        $pythonCmd = $candidate
        break
    }
}
if (-not $pythonCmd) {
    Write-Host "Python не найден (или в системе стоит только заглушка Microsoft Store)."
    Write-Host "Установите настоящий Python 3 с https://www.python.org/downloads/ (при установке отметьте ""Add python.exe to PATH""), затем запустите установщик ещё раз."
    Write-Host "Если Python уже стоял раньше, но команда 'python' открывает Microsoft Store - отключите алиас: Параметры -> Приложения -> Дополнительные параметры приложений -> Псевдонимы выполнения приложений -> выключите python.exe / python3.exe."
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
    Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 -UseBasicParsing | Out-Null
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
$runBatPath = Join-Path $targetDir "run.bat"

@"
@echo off
$pythonCmd "$startPath" --server "$defaultServer" --tools "$toolsPath" --model "$modelName"
pause
"@ | Set-Content -Path $runBatPath -Encoding ASCII

Write-Host "Установка завершена. Запуск агента..."
Write-Host "В следующий раз можно запускать сразу: $runBatPath"
& $pythonCmd $startPath --server $defaultServer --tools $toolsPath --model $modelName
Read-Host "Нажмите Enter для выхода"

