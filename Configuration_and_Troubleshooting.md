# Настройка и устранение неполадок
На этой странице описано, как настроить Simulink® Agentic Toolkit. Обзор Simulink Agentic Toolkit см. в [README](README.md).

## Требования

- **MATLAB R2023a или новее** с **Simulink**
- Поддерживаемый **ИИ-агент для написания кода**
- **Simulink Test** *(опционально)* — требуется только для инструмента `model_test`
- Некоторые навыки требуют дополнительных пакетов расширения (toolboxes) (например, System Composer, Simscape, Stateflow). Дополнительные требования указаны в поле `requires-products` файла `manifest.yaml` каждого навыка в [`skills-catalog/`](skills-catalog/).

### Установка из локальных файлов (компьютер без доступа в интернет)

Чтобы установить Simulink Agentic Toolkit в автономном или изолированном (air-gapped) окружении, сначала загрузите следующие артефакты на компьютере с доступом в интернет и перенесите их на целевую машину или в общее расположение.

| Артефакт | Где получить |
|----------|----------------|
| Бинарный файл MCP-сервера | [Последний релиз](https://github.com/matlab/matlab-mcp-server/releases/latest) — загрузите бинарный файл для вашей платформы (например, `matlab-mcp-server-macos-arm64`, `matlab-mcp-server-windows-x64.exe`) |
| Пакет расширения MCP-сервера (toolbox) | [Последний релиз](https://github.com/matlab/matlab-mcp-server/releases/latest) — загрузите `MATLABMCPServerToolbox.mltbx` |
| Simulink Agentic Toolkit | Клонируйте или загрузите из [GitHub](https://github.com/matlab/simulink-agentic-toolkit) |
| MATLAB Agentic Toolkit | Клонируйте или загрузите из [GitHub](https://github.com/matlab/matlab-agentic-toolkit) (требуется только при установке с `Toolkit="matlab"`) |


После загрузки этих артефактов выполните команду `setupAgenticToolkit` в командном окне MATLAB со следующими именованными аргументами.

| Аргумент | Значение |
|----------|-----------------|
| `MCPServerLocation` | Путь к загруженному бинарному файлу MCP-сервера |
| `MCPToolboxLocation` | Путь к загруженному пакету расширения MATLAB (`.mltbx`) |
| `MATLABAgenticToolkitLocation` | Путь к клону репозитория MATLAB Agentic Toolkit |
| `SimulinkAgenticToolkitLocation` | Путь к клону репозитория Simulink Agentic Toolkit |

Программа установки загружает из интернета любой артефакт, который вы не предоставили локально. Чтобы запретить доступ в интернет и сообщать об ошибке, если артефакт недоступен, установите `Offline=true`. Например, используйте эту команду для установки Simulink Agentic Toolkit из локальных файлов.

```matlab
setupAgenticToolkit("install", Offline=true,  ...
    MCPServerLocation="/shared/agentic-toolkits/bin/matlab-mcp-server-linux-x64", ...
    MCPToolboxLocation="/shared/agentic-toolkits/toolboxes/MATLABMCPServerToolbox.mltbx", ...
    SimulinkAgenticToolkitLocation="/shared/agentic-toolkits/simulink-agentic-toolkit")
```

### Конфигурация автоматизированной настройки

Если вы используете автоматизированную настройку с помощью функции `setupAgenticToolkit`, она записывает две вещи: конфигурацию MCP-сервера (чтобы ваш агент мог общаться с MATLAB) и регистрации навыков (чтобы ваш агент обладал экспертизой по Simulink). Детали зависят от платформы.

| Платформа | Конфигурация MCP | Доставка навыков | Как обновить набор инструментов |
|----------|------------------|-----------------|-------------------|
| Claude Code | `~/.claude.json` (mcpServers) | система `claude plugin` | `setupAgenticToolkit("update")` |
| GitHub Copilot | Пользовательский `mcp.json` VS Code | символические ссылки в `~/.agents/skills/` | `setupAgenticToolkit("update")` |
| OpenAI Codex | `~/.codex/config.toml` | символические ссылки в `~/.agents/skills/` | `setupAgenticToolkit("update")` |
| Gemini CLI | `~/.gemini/settings.json` | символические ссылки в `~/.agents/skills/` | `setupAgenticToolkit("update")` |
| Sourcegraph Amp | `~/.config/amp/settings.json` | прямая ссылка `amp.skills.path` | `setupAgenticToolkit("update")` |

**Как работает доставка навыков:** Claude Code использует встроенную систему `claude plugin` — настройка автоматически регистрирует marketplace и устанавливает плагины. Другие платформы обнаруживают навыки в `~/.agents/skills/` через символические ссылки, которые создаёт настройка, указывающие на установленный набор инструментов. При повторном запуске установки связанные навыки обновляются автоматически. Если добавлены новые навыки, повторно запустите настройку (configure) для создания дополнительных ссылок.

### Особенности для отдельных платформ

**Claude Code** — настройка записывает конфигурацию MCP в `~/.claude.json` и регистрирует навыки через систему `claude plugin` (marketplace + установка плагина). Если CLI `claude` отсутствует в PATH, настройка переходит на резервный вариант — символические ссылки на навыки в `~/.claude/skills/`.

**GitHub Copilot** — настройка записывает глобальную конфигурацию MCP в пользовательский `mcp.json` VS Code (`~/Library/Application Support/Code/User/mcp.json` на macOS, `~/.config/Code/User/mcp.json` на Linux, `%APPDATA%\Code\User\mcp.json` на Windows) и создаёт символические ссылки на навыки в `~/.agents/skills/`. После завершения настройки перезагрузите VS Code (Cmd/Ctrl + Shift + P, затем "Developer: Reload Window").

**OpenAI Codex** — настройка записывает `~/.codex/config.toml`. Навыки устанавливаются как глобальные символические ссылки в `~/.agents/skills/`. После настройки вы можете захотеть настроить два параметра в секции `[mcp_servers.matlab]` файла `~/.codex/config.toml`:
- `tool_timeout_sec = 600` — увеличивает тайм-аут инструмента по сравнению со значением по умолчанию (которое слишком мало для многих операций MATLAB, таких как наборы тестов и симуляции). Для очень длительных задач увеличьте значение ещё больше.
- `env_vars = ['WINDIR']` — **только для Windows.** Требуется для работы Simulink, поскольку Codex по умолчанию удаляет переменные окружения из дочерних процессов MCP-сервера.

**Gemini CLI** — настройка записывает глобальную конфигурацию в `~/.gemini/settings.json` и создаёт символические ссылки на навыки в `~/.agents/skills/`. После настройки начните новую сессию Gemini.

**Sourcegraph Amp** — настройка записывает данные в `~/.config/amp/settings.json`, используя префикс `amp.` для всех ключей. Навыки загружаются напрямую из набора инструментов через `amp.skills.path` (символические ссылки не нужны). Если у вас настроены правила `amp.mcpPermissions`, блокирующие MCP-серверы, настройка обнаружит это и запросит подтверждение перед внесением изменений.


## Настройка вручную

Если вы предпочитаете самостоятельно управлять установкой MCP-сервера и конфигурацией агента, вы можете настроить набор инструментов вручную, следуя инструкциям в репозитории [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-core-server) для установки бинарного файла MCP-сервера и его настройки с вашим агентом для написания кода. Обзор настройки вручную см. в [README](README.md).



## Обновление Simulink Agentic Toolkit

Выполните действие обновления в MATLAB, чтобы загрузить последнюю версию набора инструментов и MCP-сервера:

```matlab
setupAgenticToolkit("update")
```

После обновления:

1. **Повторно выполните `satk_initialize`** в MATLAB, чтобы учесть изменения инструментов
2. **Перезапустите сессию агента**, чтобы загрузить обновлённые навыки


## Другие действия настройки

Функция `setupAgenticToolkit` поддерживает несколько действий:

| Действие | Команда | Описание |
|--------|---------|-------------|
| Установка | `setupAgenticToolkit("install")` | Загрузить MCP-сервер и файлы набора инструментов, затем выполнить настройку |
| Настройка (Configure) | `setupAgenticToolkit("configure")` | Настроить агента с MCP и навыками |
| Обновление | `setupAgenticToolkit("update")` | Загрузить последние версии MCP-сервера и файлов набора инструментов |
| Удаление | `setupAgenticToolkit("uninstall")` | Удалить установленные наборы инструментов и конфигурации агентов |
| Статус | `setupAgenticToolkit("status")` | Показать текущий статус установки и конфигурации |

Все действия поддерживают `Prompt=false` для неинтерактивного использования.

```matlab
setupAgenticToolkit("install", Toolkit=["matlab", "simulink"], Prompt=false)
setupAgenticToolkit("configure", Agents="claude-code", Scope="global", Prompt=false)
```

 Если ваша организация использует CLI-обёртку, передайте `AgentCLI="claude-code=/path/to/wrapper"` при выполнении configure.

### Пользовательские команды CLI агента

Если ваша организация использует обёртку или псевдоним для бинарных файлов CLI агента, используйте параметр `AgentCLI`:

```matlab
setupAgenticToolkit("configure", AgentCLI="claude-code=/usr/local/bin/my-claude-wrapper")
```

Формат — `"agent-id=command"`. Это переопределение сохраняется в `config.json` и автоматически используется для всех последующих действий (configure, uninstall). Указать его нужно только один раз.

> **Примечание:** в настоящее время CLI во время настройки использует только Claude Code (для регистрации плагина через `claude plugin`). Все остальные агенты настраиваются через запись файлов и символические ссылки, поэтому им `AgentCLI` не требуется. Если CLI Claude не найден, настройка автоматически переходит на резервный вариант с символическими ссылками.

### Удаление конфигураций агентов

Чтобы удалить конфигурации агентов без удаления самих наборов инструментов, выполните:

```matlab
setupAgenticToolkit("uninstall")
```

Затем выберите **Agent configurations only** в интерактивном запросе. Это удаляет записи конфигурации MCP и регистрации навыков, сохраняя при этом установленные наборы инструментов и MCP-сервер нетронутыми. Полезно при смене агентов или очистке устаревших конфигураций.

### Отключение сбора данных

MATLAB MCP Server собирает полностью анонимизированную информацию об использовании вами сервера и отправляет её в MathWorks. Этот сбор данных помогает MathWorks улучшать продукты и включён по умолчанию. Чтобы отказаться от сбора данных, настройте набор инструментов с параметром `DisableTelemetry`, установленным в `true`, выполнив эту команду в MATLAB:

```matlab
setupAgenticToolkit("configure", DisableTelemetry=true)
```

Эта команда отключает сбор данных для каждого настроенного агента. Эта настройка сохраняется при обновлении до новой версии набора инструментов с помощью `setupAgenticToolkit("update")`. Если вы повторно настраиваете набор инструментов для своего(их) агента(ов), выполнив `setupAgenticToolkit("configure")`, снова укажите `DisableTelemetry=true`, чтобы сбор данных оставался отключённым.

---

## Устранение неполадок
| Проблема | Вероятная причина | Исправление |
|---------|-------------|-----|
| Add-On Manager не удаётся открыть при открытии mltbx (`ERR_CERT_AUTHORITY_INVALID` или "Unable to open the requested feature") | Проблема CEF/дисплея — часто вызвана корпоративными прокси, антивирусным ПО или headless-окружениями | Установите программно: `matlab.addons.toolbox.installToolbox("agenticToolkitInstaller.mltbx")` |
| Агент не показывает навыки Simulink | Навыки не зарегистрированы | Повторно выполните `setupAgenticToolkit("configure")` |
| Инструменты MCP завершаются с ошибкой "Undefined function" | `satk_initialize` не выполнена в текущей сессии MATLAB | Выполните `satk_initialize` в MATLAB |
| MCP-сервер не может подключиться к MATLAB | Коннектор не запущен или устаревшее соединение | Добавьте аргументы `--log-folder` и `--log-level` в конфигурацию вашего MCP-сервера (см. [аргументы MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server#arguments)), затем снова выполните `satk_initialize` (она автоматически вызывает `shareMATLABSession`). Проверьте сформированные журналы. |
| macOS блокирует бинарный файл MCP-сервера | Карантин Gatekeeper | Щёлкните правой кнопкой мыши → Открыть, либо выполните: `xattr -d com.apple.quarantine ~/.matlab/agentic-toolkits/bin/matlab-mcp-server` |
| Ошибка "rmiml.selectionLinkHelper" | Повреждение пути другими пакетами расширения | Выполните `restoredefaultpath` в MATLAB, затем повторно выполните `satk_initialize` |
| `model_test` завершается с ошибкой или недоступен | Simulink Test не установлен | Установите Simulink Test либо используйте остальные 7 инструментов, которые работают без него |
| Тайм-аут вызовов инструментов Codex | Тайм-аут инструмента по умолчанию слишком мал для MATLAB | Добавьте `tool_timeout_sec = 600` (или больше) в секцию `[mcp_servers.matlab]` файла `~/.codex/config.toml` |
| Simulink завершается с ошибкой в Codex на Windows | Отсутствует переменная окружения `WINDIR` | Добавьте `env_vars = ['WINDIR']` в секцию `[mcp_servers.matlab]` файла `~/.codex/config.toml` |


## Сообщить об ошибке

Если вы столкнулись с ошибкой, используйте навык **filing-bug-reports**, чтобы сформировать отчёт перед созданием issue на GitHub. Попросите своего агента:

```
File a bug report for this issue
```

Навык автоматически собирает данные об окружении, шаги воспроизведения и вывод ошибок. **Запускайте навык в той же сессии, где произошла ошибка**, поскольку он использует контекст беседы для восстановления произошедшего. Затем [откройте отчёт об ошибке](https://github.com/matlab/simulink-agentic-toolkit/issues/new?template=bug_report.yml) и вставьте сформированный отчёт.


Copyright 2025-2026 The MathWorks, Inc.

---
