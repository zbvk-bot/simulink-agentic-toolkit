<!-- Copyright 2026 The MathWorks, Inc. -->

# Simulink Agentic Toolkit — инструкции для агента

## Настройка

Если пользователь просит настроить Simulink Agentic Toolkit, направьте его выполнить в MATLAB следующее:

```matlab
addpath('<path-to-setup-folder>')
setupAgenticToolkit("install")
```

Это обрабатывает определение платформы, загрузку MCP-сервера, установку набора инструментов, настройку агента и регистрацию навыков (skills). Не пытайтесь выполнять команды настройки от имени пользователя.

## Доменные навыки (Domain Skills)

Доменные навыки Simulink находятся в `skills-catalog/model-based-design-core/`. У каждого навыка есть файл `SKILL.md` с инструкциями и `manifest.yaml` с метаданными.

## Инструменты MCP

При подключённом MCP-сервере доступно семь инструментов MCP (см. `tools/registry.json`):
- `model_overview` — иерархическая визуализация модели
- `model_read` — топология блоков и нотация выражений
- `model_edit` — структурные изменения
- `model_check` — структурная проверка (неподключённые порты, оборванные линии, проверки времени редактирования (Edit-Time Checks) на состояниях и подграфах)
- `model_query_params` — произвольный доступ к параметрам
- `model_resolve_params` — разрешение переменных рабочего пространства
- `model_test` — поведенческое тестирование на основе Gherkin (требует Simulink Test)

## Обязательное условие: MATLAB

MCP-сервер использует `--matlab-session-mode=existing`. Прежде чем инструменты MCP заработают, MATLAB должен быть запущен с выполненной командой `satk_initialize` (которая вызывает `shareMATLABSession`). Пакет MATLAB MCP Server Toolbox должен быть установлен один раз для каждой версии MATLAB. Если инструменты не подключаются, попросите пользователя выполнить в MATLAB `addpath('<toolkit_root>'); satk_initialize`.
