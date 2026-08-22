# Миграция с предыдущей установки

Если вы настроили Simulink® Agentic Toolkit с помощью более ранней версии (рабочий процесс на основе агента "Set up the Simulink Agentic Toolkit"), перед использованием `setupAgenticToolkit` следует удалить старую установку. Старый рабочий процесс устанавливал файлы в другие места, которыми новый скрипт настройки не управляет.

### Что нужно удалить

1. **Старая папка данных набора инструментов** — удалите `~/.simulink-agentic-toolkit/` (macOS/Linux) или `%USERPROFILE%\.simulink-agentic-toolkit\` (Windows). Это был каталог данных, использовавшийся старой настройкой на основе агента.

2. **Бинарный файл MCP-сервера** — удалите `~/.matlab/agentic-toolkits/bin/matlab-mcp-server` (macOS/Linux) или `%USERPROFILE%\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe` (Windows). Некоторые более ранние версии устанавливали бинарный файл как `matlab-mcp-core-server` или в `~/.local/bin/` либо `%USERPROFILE%\.local\bin\` — проверьте оба расположения и оба имени.

3. **MCP Add-On** — удалите `~/.local/share/MATLABMCPCoreServerToolbox.mltbx` (macOS/Linux) или `%USERPROFILE%\.local\share\MATLABMCPCoreServerToolbox.mltbx` (Windows). Если вы уже установили этот пакет в MATLAB, вы можете удалить его через `matlab.addons.uninstall` или вручную через Add-On Manager — новая настройка автоматически удаляет любую предыдущую копию перед установкой последней версии `.mltbx`. (Пакет ранее назывался "MATLAB MCP Core Server Toolbox", а теперь называется "MATLAB MCP Server Toolbox".)

4. **Конфигурация MCP агента** — удалите старую запись MCP-сервера `matlab` или `simulink` из файла конфигурации вашего агента. Ваша конфигурация **не должна** ссылаться ни на один из указанных выше путей. Расположение зависит от платформы:
   - Claude Code: `~/.claude.json` (`%USERPROFILE%\.claude.json` на Windows) — удалите запись из `mcpServers`
   - GitHub Copilot: пользовательский `mcp.json` VS Code (удалите сервер `matlab` или `simulink`). Расположение файла: `~/Library/Application Support/Code/User/mcp.json` (macOS), `~/.config/Code/User/mcp.json` (Linux), `%APPDATA%\Code\User\mcp.json` (Windows)
   - OpenAI Codex: `~/.codex/config.toml` (удалите `[mcp_servers.matlab]` или `[mcp_servers.simulink]`)
   - Gemini CLI: `~/.gemini/settings.json` (удалите запись `mcpServers`)
   - Sourcegraph Amp: `~/.config/amp/settings.json` (удалите `amp.mcpServers.matlab` или `amp.mcpServers.simulink` **и** `amp.skills.path`)

5. **Регистрации навыков (skills)** — удалите старые символические ссылки из `~/.agents/skills/` и `~/.claude/skills/`, указывающие на ваш старый клон набора инструментов. Для Amp также удалите запись `amp.skills.path` в `~/.config/amp/settings.json`, если она ссылается на путь к старому набору инструментов.

6. **Старый клон набора инструментов** — если вы клонировали репозиторий только для настройки и он вам больше не нужен как справочный материал, вы можете удалить его. Новый скрипт настройки загружает файлы набора инструментов в `~/.matlab/agentic-toolkits/`.

> **Совет:** после удаления перечисленных элементов вы можете попросить своего агента для написания кода поискать в домашнем каталоге оставшиеся упоминания старого набора инструментов (например, "matlab-mcp", "simulink-agentic-toolkit" или старые пути вроде `.local/bin`), чтобы не пропустить что-то важное.

После очистки следуйте инструкциям [автоматизированной настройки](README.md#install-simulink-agentic-toolkit-automated-setup) в README.

---
