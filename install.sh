set -e

REPO_RAW="https://raw.githubusercontent.com/zbvk-bot/simulink-agentic-toolkit/main"
TARGET_DIR="$HOME/simulink-ollama-agent"
SUGGESTED_MODEL="qwen3:8b"

mkdir -p "$TARGET_DIR/tools"

echo "Скачивание файлов агента..."
curl -Ls "$REPO_RAW/start.py" -o "$TARGET_DIR/start.py"
curl -Ls "$REPO_RAW/tools/tools.json" -o "$TARGET_DIR/tools/tools.json"

PYTHON_CMD=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1; then
        PYTHON_CMD="$candidate"
        break
    fi
done
if [ -z "$PYTHON_CMD" ]; then
    echo "Python не найден."
    echo "Установите Python 3 с https://www.python.org/downloads/ и запустите установщик ещё раз."
    exit 1
fi

if ! command -v ollama >/dev/null 2>&1; then
    echo "Ollama не найдена."
    echo "Установите её с https://ollama.com/download и запустите установщик ещё раз."
    exit 1
fi

if ! curl -s -m 5 http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "Похоже, Ollama не запущена."
    echo "Запустите Ollama и повторите установку."
    exit 1
fi

TAGS_JSON=$(curl -s http://localhost:11434/api/tags)
MODEL_LIST=$("$PYTHON_CMD" -c "
import json, sys
data = json.loads(sys.argv[1])
for m in data.get('models', []):
    print(m.get('name', ''))
" "$TAGS_JSON")

MODEL_NAME=""
if [ -n "$MODEL_LIST" ]; then
    echo ""
    echo "Установленные модели Ollama:"
    i=1
    OLD_IFS="$IFS"
    IFS='
'
    for m in $MODEL_LIST; do
        echo "  $i) $m"
        i=$((i + 1))
    done
    IFS="$OLD_IFS"
    echo "  0) Скачать предложенную модель ($SUGGESTED_MODEL)"
    printf "Введите номер модели: "
    read CHOICE
    if [ "$CHOICE" != "0" ] && [ -n "$CHOICE" ]; then
        i=1
        IFS='
'
        for m in $MODEL_LIST; do
            if [ "$i" = "$CHOICE" ]; then
                MODEL_NAME="$m"
            fi
            i=$((i + 1))
        done
        IFS="$OLD_IFS"
    fi
fi

if [ -z "$MODEL_NAME" ]; then
    MODEL_NAME="$SUGGESTED_MODEL"
    if ! echo "$MODEL_LIST" | grep -q "^$SUGGESTED_MODEL"; then
        ollama pull "$MODEL_NAME"
    fi
fi

DEFAULT_SERVER="$HOME/.matlab/agentic-toolkits/bin/matlab-mcp-server"
if [ ! -f "$DEFAULT_SERVER" ]; then
    echo "MATLAB MCP-сервер не найден по стандартному пути:"
    echo "$DEFAULT_SERVER"
    echo "Убедитесь, что MATLAB установлен и вы выполнили setupAgenticToolkit(\"install\") в MATLAB."
    printf "Если сервер установлен в другом месте, вставьте полный путь (или нажмите Enter, чтобы пропустить): "
    read CUSTOM_SERVER
    if [ -n "$CUSTOM_SERVER" ] && [ -f "$CUSTOM_SERVER" ]; then
        DEFAULT_SERVER="$CUSTOM_SERVER"
    else
        echo "Продолжаем без сервера - агент не запустится, пока MATLAB MCP-сервер не будет доступен."
    fi
fi

echo "Установка завершена. Запуск агента..."
"$PYTHON_CMD" "$TARGET_DIR/start.py" --server "$DEFAULT_SERVER" --tools "$TARGET_DIR/tools/tools.json" --model "$MODEL_NAME"
