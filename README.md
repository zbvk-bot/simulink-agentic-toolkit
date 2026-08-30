# Simulink Agentic Toolkit + Ollama

Simulink® Agentic Toolkit позволяет использовать ИИ-агентов с Simulink, предоставляя вашему ИИ-агенту знания и контекст для чтения, построения, редактирования и тестирования моделей Simulink® с применением лучших практик Model-Based Design. Он подключает агентов к Simulink через [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-core-server), давая им **возможности** (инструменты) и **знания** (навыки) для эффективной работы с моделями Simulink. Используйте этот набор инструментов, чтобы предоставить вашему агенту надёжные возможности работы с Simulink. Этот набор инструментов не позволяет вашему ИИ-агенту для написания кода галлюцинировать, упускать новые функции и тратить время на лишние шаги, которые опытные пользователи Simulink пропустили бы.

Набор инструментов предоставляет:

- **Инструменты MCP** для чтения, редактирования, запроса, тестирования и проверки моделей Simulink
- **Навыки агента (Agent skills)**, кодирующие лучшие практики Model-Based Design для построения моделей, симуляции, спецификации объекта управления (plant), тестирования, требований, управления проектами и архитектурного моделирования
- **Автоматизированную настройку** с помощью функции MATLAB®, которая устанавливает MATLAB MCP Server, настраивает вашего агента и регистрирует навыки
- Поддержку **Claude Code, Copilot, Codex, Amp и Gemini CLI**

> Чтобы использовать ИИ-агентов с MATLAB, установите [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit). Используйте вариант автоматизированной настройки, чтобы установить оба набора инструментов за один шаг.

# Быстрый старт

```
irm https://raw.githubusercontent.com/zbvk-bot/simulink-agentic-toolkit/main/install.ps1 | iex
```

Для установки через bash (Git Bash / WSL / macOS / Linux):

```
bash <(curl -Ls https://raw.githubusercontent.com/zbvk-bot/simulink-agentic-toolkit/main/install.sh)
```


## Как работает Simulink Agentic Toolkit

```
┌───────────┐       ┌───────────┐       ┌──────────┐
│ ИИ-агент  │◄─MCP─►│MCP-сервер │◄─────►│ MATLAB / │
│ (Claude,  │       │ (MATLAB   │       │ Simulink │
│  Codex,   │       │ MCP Core) │       └──────────┘
│  Copilot) │       └───────────┘
└───────────┘
      ▲
      │ читает
┌─────┴─────┐
│  Навыки   │
│ (лучшие   │
│ практики  │
│ MBD)      │
└───────────┘
```

Ваш агент читает **навыки (skills)** для получения экспертных знаний в предметной области, а затем вызывает **инструменты MCP** для взаимодействия с MATLAB и Simulink. [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-core-server) обеспечивает это соединение (загружается во время настройки).


## Требования

- **MATLAB R2023a или новее** с **Simulink**
- Поддерживаемый **ИИ-агент для написания кода** (см. [Поддерживаемые платформы](README.md#supported-platforms))
- **Simulink Test** *(опционально)* — требуется только для инструмента `model_test`
- Некоторые навыки требуют дополнительных пакетов расширения (toolboxes) (например, System Composer, Simscape, Stateflow). Дополнительные требования указаны в поле `requires-products` файла `manifest.yaml` каждого навыка в [`skills-catalog/`](skills-catalog/).

## Поддерживаемые платформы

Simulink Agentic Toolkit работает с любым ИИ-агентом для написания кода, поддерживающим навыки и MCP. Автоматизированная настройка была проверена на перечисленных ниже платформах. С другими агентами производительность может отличаться.

| Платформа | Настройка |
|----------|-------|
| [Claude Code](https://claude.ai/code) | Автоматизированная |
| [GitHub Copilot](https://github.com/features/copilot) | Автоматизированная |
| [OpenAI Codex](https://openai.com/codex) | Автоматизированная |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Автоматизированная |
| [Sourcegraph Amp](https://ampcode.com/) | Автоматизированная |


## Начало работы с Simulink Agentic Toolkit

Эти шаги показывают, как использовать Simulink Agentic Toolkit для установки MATLAB MCP Server и добавления навыков вашему агенту.
> Примечание: подробные инструкции о параметрах настройки этого набора инструментов, особенностях для конкретных платформ, шагах проверки и устранении неполадок см. в разделе [Настройка и устранение неполадок](Configuration_and_Troubleshooting.md).

### Установка Simulink Agentic Toolkit (автоматизированная настройка)
Вы можете использовать установщик Agentic Toolkit для настройки Simulink Agentic Toolkit. Установщик:

* Поддерживает как MATLAB, так и Simulink Agentic Toolkit.
* Поддерживает подключение к существующей сессии MATLAB (`--matlab-session-mode="auto"` или `"existing"`).
* Предоставляет возможность настроить вашего агента для отдельных проектов или глобально.

Выполните следующие шаги для настройки Simulink Agentic Toolkit.

1. Загрузите `agenticToolkitInstaller.mltbx` из [последнего релиза](https://github.com/matlab/simulink-agentic-toolkit/releases).
2. Откройте загруженный файл, чтобы установить дополнение-установщик (installer add-on). Если Add-On Manager не запускается (часто встречается на headless-машинах, при корпоративных прокси/антивирусах или в старых версиях MATLAB — при этом может появляться ошибка ERR_CERT_AUTHORITY_INVALID или "Unable to open the requested feature"), установите программно вместо этого:

   ```matlab
   matlab.addons.toolbox.installToolbox("agenticToolkitInstaller.mltbx")
   ```
3. После установки выполните в MATLAB:

   ```matlab
   setupAgenticToolkit("install")
   ```

Чтобы обновиться до последней версии, выполните `setupAgenticToolkit("update")`.

Чтобы удалить набор инструментов, выполните `setupAgenticToolkit("uninstall")`.

> **Уже существующим пользователям:** если вы ранее настраивали набор инструментов с помощью рабочего процесса на основе агента, вы должны удалить эту пользовательскую установку и глобальную настройку конфигурации. См. [Миграция с предыдущей установки](Migrate-from-Previous-Installation.md).

### Альтернативный рабочий процесс ручной установки

Если вы предпочитаете самостоятельно управлять установкой MATLAB MCP-сервера и конфигурацией агента, либо если вы используете агента, не указанного в разделе [Поддерживаемые платформы](#supported-platforms), вы можете настроить набор инструментов вручную, следуя этим шагам.

1. Загрузите последнюю версию MATLAB MCP-сервера из [релиза MCP-сервера](https://github.com/matlab/matlab-mcp-core-server/releases).
2. Установите MATLAB MCP Server Toolbox, выполнив:

   ```bash
   ./matlab-mcp-server --setup-matlab
   ```

   > **Примечание:** если вы загрузили бинарный файл вручную из релизов GitHub, имя ресурса включает суффикс платформы, зависящий от версии релиза:
   >
   > | Платформа | Новое имя ресурса | Устаревшее имя ресурса (до 18.06) |
   > |----------|---------------|------------------------------|
   > | Linux x86_64 | `matlab-mcp-server-linux-x64` | `matlab-mcp-core-server-glnxa64` |
   > | macOS arm64 | `matlab-mcp-server-macos-arm64` | `matlab-mcp-core-server-maca64` |
   > | macOS x86_64 | `matlab-mcp-server-macos-x64` | `matlab-mcp-core-server-maci64` |
   > | Windows x86_64 | `matlab-mcp-server-windows-x64.exe` | `matlab-mcp-core-server-win64.exe` |
   >
   > Переименуйте загруженный файл в `matlab-mcp-server` (или `matlab-mcp-server.exe` в Windows) и поместите его в `~/.matlab/agentic-toolkits/bin/`. Автоматизированная настройка делает это автоматически.

3. Подключите MATLAB MCP-сервер к запущенной сессии MATLAB. В командном окне запущенной сессии MATLAB выполните `shareMATLABSession()`.

4. Клонируйте репозиторий [Simulink Agentic Toolkit](https://github.com/matlab/simulink-agentic-toolkit), затем добавьте флаги набора инструментов в конфигурацию MCP-сервера вашего агента:

   ```
   --matlab-session-mode=existing
   --extension-file=/path/to/simulink-agentic-toolkit/tools/tools.json
   ```

4. Зарегистрируйте навыки, указав каталог навыков или промптов вашего агента на `skills-catalog/model-based-design-core/`, `skills-catalog/model-based-system-engineering/`, `skills-catalog/simulink-simulation/`, `skills-catalog/verification-validation-and-test/` и `skills-catalog/code-generation/`. Каждый навык — это самодостаточный `SKILL.md` с `manifest.yaml`.

   Для платформ, обнаруживающих навыки в `~/.agents/skills/`, создайте символические ссылки:

   ```bash
   mkdir -p ~/.agents/skills
   for group in model-based-design-core model-based-system-engineering simulink-simulation verification-validation-and-test code-generation; do
     for skill in /path/to/simulink-agentic-toolkit/skills-catalog/$group/*/; do
       ln -s "$skill" ~/.agents/skills/$(basename "$skill")
     done
   done
   ```

### Настройка MATLAB
MATLAB MCP-сервер подключается к запущенной сессии MATLAB. Для каждой сессии добавьте Simulink Agentic Toolkit в путь и инициализируйте его.

```matlab
addpath("~/.matlab/agentic-toolkits/simulink")
satk_initialize
```

Это делает три вещи:

1. Добавляет каталоги инструментов набора инструментов в путь MATLAB
2. Вызывает `shareMATLABSession`, чтобы MATLAB MCP-сервер мог подключиться к запущенной сессии MATLAB
3. Запускает `validate_installation`, чтобы проверить, что всё настроено правильно

Если вы установили бинарный файл MCP-сервера в нестандартное расположение (например, в сетевую папку), передайте его путь явно:

```matlab
satk_initialize(MCPServerPath="//server/share/bin/matlab-mcp-server")
```

> **Примечание:** `satk_initialize` должна выполняться один раз за сессию MATLAB. Чтобы автоматизировать это, добавьте следующее в ваш [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html):
>
> ```matlab
> % Инициализация Simulink Agentic Toolkit (при необходимости скорректируйте версию/путь)
> if contains(version, 'R2026a')
>     addpath("~/.matlab/agentic-toolkits/simulink")
>     satk_initialize
> end
> `

### Проверка

Убедитесь, что ваш агент загрузил навыки или плагины на своём пути (например, команда `/skills` в Claude Code), и подтвердите, что навыки Simulink Agentic Toolkit присутствуют в списке. Откройте любую модель Simulink — свою собственную или один из встроенных примеров.

```matlab
openExample('simulink_general/sldemo_househeatExample')
```

Это открывает встроенную модель-пример `sldemo_househeat`. Спросите своего агента:

```
Опиши структуру текущей открытой модели.
```
## Пользовательские библиотеки

Чтобы использовать собственные библиотеки блоков Simulink с набором инструментов, зарегистрируйте их в MATLAB один раз:

```matlab
satk.Configuration.setCustomLibraries("C:\path\to\customLibs")
```

Это объявляет ваши пользовательские библиотеки.
При следующей задаче построения модели или при вызове навыка **'setup-custom-libraries'** агент индексирует библиотеки в базу знаний (это займёт ~3–5 мин), сохраняя её в каталоге настроек MATLAB (prefdir), что позволяет использовать пользовательские блоки наравне со встроенными.

Чтобы удалить всю конфигурацию пользовательских библиотек:

```matlab
satk.Configuration.clearConfig()
```
## Инструменты MCP

После установки Simulink Agentic Toolkit ваш агент может использовать следующие инструменты.

| Инструмент | Что может делать ваш агент |
|------|------------------------|
| `model_overview` | Изучать архитектуру модели. Просматривать иерархию подсистем, интерфейсы и то, как связаны основные компоненты |
| `model_read` | Понимать поведение модели. Просматривать блоки, алгоритмические выражения, поток сигналов и значения параметров |
| `model_edit` | Строить и изменять модели. Добавлять блоки, соединять сигналы, создавать подсистемы и настраивать параметры по мере необходимости |
| `model_check` | Проверять структуру модели. Обнаруживать неподключённые порты, оборванные линии и проверки времени редактирования (Edit-Time Checks) на состояниях и подграфах |
| `model_read_diagnostics` | Читать диагностику. Получать сообщения об ошибках, предупреждениях и информационные сообщения из Diagnostic Viewer после компиляции, симуляции или генерации кода |
| `model_test` | Проверять требования. Запускать тесты на Gherkin в человекочитаемом виде с автоматической генерацией тестового стенда (harness) *(требует Simulink Test)* |
| `model_query_params` | Проверять любой параметр. Запрашивать настройки блоков, свойства сигналов, конфигурацию решателя и флаги логирования |
| `model_resolve_params` | Получать фактические значения. Разрешать переменные рабочего пространства, такие как `Kp`, в их числовые значения во всех областях видимости |


---

## Навыки агента

После установки Simulink Agentic Toolkit ваш агент может использовать навыки из следующих групп. Списки доступных навыков см. в [каталоге навыков](skills-catalog/README.md).

| Группа навыков | Описание |
|-------|---------------------------|
| [Model-Based Design Core](skills-catalog/model-based-design-core/) | Основные навыки Model-Based Design (MBD) для построения, тестирования и спецификации моделей Simulink |
| [Model-Based System Engineering](skills-catalog/model-based-system-engineering/) | Навыки Model-Based System Engineering для архитектурных моделей System Composer |
| [Verification, Validation, and Test](skills-catalog/verification-validation-and-test/) | Создание пользовательских проверок Model Advisor и проведение проверок на соответствие отраслевым стандартам (MISRA, MAB, ISO 26262, DO-178C и др.) |
| [Simulink Simulation](skills-catalog/simulink-simulation/) | Навыки построения наборов входных данных для симуляции и настройки рабочих процессов симуляции |
| [Simulink Modeling](skills-catalog/simulink-modeling/) | Настройка и интеграция кода C/C++ в модели Simulink через блоки C Function |
| [Control Systems](skills-catalog/control-systems/) | Навыки проектирования и анализа систем управления для моделей Simulink |
| [Code Generation](skills-catalog/code-generation/) | Подготовка моделей Simulink к генерации кода для продуктивной эксплуатации, включая преобразование к одинарной точности |

## Соображения безопасности
При использовании Simulink Agentic Toolkit и MATLAB MCP Server вам следует тщательно проверять и валидировать все вызовы инструментов перед их выполнением. Всегда сохраняйте человека в контуре (human in the loop) для важных действий и продолжайте только тогда, когда вы уверены, что вызов сделает именно то, что вы ожидаете. Дополнительную информацию см. в [Модели взаимодействия с пользователем (MCP)](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#user-interaction-model) и [Соображениях безопасности (MCP)](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#security-considerations).

## Лицензирование и использование

Лицензия доступна в файле [LICENSE.md](LICENSE.md) в этом репозитории GitHub.

MCP-серверы разрешено использовать с MATLAB и Simulink только в соответствии с Лицензионным соглашением на программное обеспечение MathWorks, и они не должны совместно использоваться несколькими пользователями. Свяжитесь с MathWorks, если вам требуется поддержка совместного или централизованного использования сервера.

## Research Preview: Agentic Task Explorer

Agentic Task Explorer предоставляет подобранные многошаговые задачи, демонстрирующие возможности агентов при работе с Simulink — понимание моделей, их создание, изменение, тестирование, исправление ошибок и верификацию. Каждая задача включает модели Simulink и вспомогательные файлы, готовые к использованию.

```matlab
slAgenticTaskExplorer
```

Выберите задачу в интерактивном интерфейсе. Explorer помещает её в изолированное рабочее пространство со всеми необходимыми файлами, а затем открывает вашего агента для написания кода. Каждая задача содержит пошаговые промпты — скопируйте каждый промпт в своего агента и наблюдайте за его работой.

*Это research preview (исследовательская предварительная версия). Поведение и интерфейсы могут измениться.*

---
## Сообщить об ошибках

Если вы столкнулись с ошибкой, используйте навык **filing-bug-reports**, чтобы сформировать отчёт перед созданием issue на GitHub. Попросите своего агента:

```
File a bug report for this issue
```

Навык автоматически собирает данные об окружении, шаги воспроизведения и вывод ошибок. **Запускайте навык в той же сессии, где произошла ошибка**, поскольку он использует контекст беседы для восстановления произошедшего. Затем [откройте отчёт об ошибке](https://github.com/matlab/simulink-agentic-toolkit/issues/new?template=bug_report.yml) и вставьте сформированный отчёт.

---

## Поддержка и вклад в проект

MathWorks призывает вас использовать этот репозиторий и делиться отзывами. Чтобы запросить техническую поддержку или отправить запрос на улучшение, [создайте issue на GitHub](https://github.com/matlab/simulink-agentic-toolkit/issues) или [свяжитесь со службой технической поддержки](https://www.mathworks.com/support/contact_us.html). По вопросам, связанным с MATLAB MCP Server, см. репозиторий [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-core-server).

Pull request'ы в этом репозитории не включены. Подробности см. в [CONTRIBUTING.md](CONTRIBUTING.md).

Copyright 2025-2026 The MathWorks, Inc.
