import os
import sys
import json
import time
import shutil
import argparse
import subprocess
import urllib.request
import urllib.error

HOME = os.path.expanduser("~")

def default_server_path():
    exe = "matlab-mcp-server.exe" if os.name == "nt" else "matlab-mcp-server"
    return os.path.join(HOME, ".matlab", "agentic-toolkits", "bin", exe)

def default_tools_path():
    return os.path.join(HOME, ".matlab", "agentic-toolkits", "simulink", "tools", "tools.json")

class MCPClient:
    def __init__(self, server_path, tools_path):
        args = [server_path, "--matlab-session-mode=existing", "--extension-file=" + tools_path]
        self.proc = subprocess.Popen(
            args,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            bufsize=1,
        )
        self._id = 0
        self._handshake()

    def _next_id(self):
        self._id += 1
        return self._id

    def _send(self, obj):
        self.proc.stdin.write(json.dumps(obj) + "\n")
        self.proc.stdin.flush()

    def _read(self):
        while True:
            line = self.proc.stdout.readline()
            if line == "":
                raise RuntimeError("MCP-сервер закрыл соединение")
            line = line.strip()
            if not line:
                continue
            try:
                return json.loads(line)
            except json.JSONDecodeError:
                continue

    def _request(self, method, params=None):
        msg = {"jsonrpc": "2.0", "id": self._next_id(), "method": method}
        if params is not None:
            msg["params"] = params
        self._send(msg)
        while True:
            resp = self._read()
            if resp.get("id") == msg["id"]:
                if "error" in resp:
                    raise RuntimeError(str(resp["error"]))
                return resp.get("result", {})

    def _notify(self, method, params=None):
        msg = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            msg["params"] = params
        self._send(msg)

    def _handshake(self):
        self._request("initialize", {
            "protocolVersion": "2025-06-18",
            "capabilities": {},
            "clientInfo": {"name": "ollama-simulink-bridge", "version": "1.0.0"},
        })
        self._notify("notifications/initialized")

    def list_tools(self):
        result = self._request("tools/list")
        return result.get("tools", [])

    def call_tool(self, name, arguments):
        result = self._request("tools/call", {"name": name, "arguments": arguments})
        content = result.get("content", [])
        parts = []
        for item in content:
            if item.get("type") == "text":
                parts.append(item.get("text", ""))
            else:
                parts.append(json.dumps(item))
        return "\n".join(parts) if parts else json.dumps(result)

    def close(self):
        try:
            self.proc.terminate()
        except Exception:
            pass

def mcp_tools_to_ollama(tools):
    converted = []
    for t in tools:
        converted.append({
            "type": "function",
            "function": {
                "name": t["name"],
                "description": t.get("description", ""),
                "parameters": t.get("inputSchema", {"type": "object", "properties": {}}),
            },
        })
    return converted

def ollama_chat(base_url, model, messages, tools):
    payload = {
        "model": model,
        "messages": messages,
        "tools": tools,
        "stream": False,
        "think": False,
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        base_url.rstrip("/") + "/api/chat",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=600) as resp:
        return json.loads(resp.read().decode("utf-8"))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--server", default=default_server_path())
    parser.add_argument("--tools", default=default_tools_path())
    parser.add_argument("--ollama-url", default="http://localhost:11434")
    parser.add_argument("--model", default="qwen3:8b")
    args = parser.parse_args()

    if not os.path.isfile(args.server):
        print("MATLAB MCP-сервер не найден: " + args.server)
        sys.exit(1)
    if not os.path.isfile(args.tools):
        print("Файл tools.json не найден: " + args.tools)
        sys.exit(1)

    try:
        urllib.request.urlopen(args.ollama_url.rstrip("/") + "/api/tags", timeout=5)
    except Exception as e:
        print("Не удалось подключиться к Ollama (" + args.ollama_url + "): " + str(e))
        sys.exit(1)

    client = MCPClient(args.server, args.tools)
    mcp_tools = client.list_tools()
    ollama_tools = mcp_tools_to_ollama(mcp_tools)

    system_prompt = (
        "You are an engineering assistant with access to Simulink models through MCP tools. "
        "Use the available tools to inspect, edit, validate, and test Simulink models. "
        "Always call model_overview or model_read before editing a model you have not inspected yet. "
        "Never guess a model filename - if the user has not named a model and none is confirmed open, ask which model to use before calling any tool. "
        "model_edit can only modify a model that already exists and is loaded; it cannot create a new model file. "
        "To create a new model from scratch, call evaluate_matlab_code to run the MATLAB commands yourself (e.g. new_system, save_system) - do not just print MATLAB code as a suggestion when you have a tool that can run it. "
        "If you are unsure about an optional tool parameter, omit it rather than guessing a value; never call the same tool multiple times in one turn with different guessed values for the same parameter - call it once, read the result, then decide the next step. "
        "Respond in the same language the user writes in."
    )
    messages = [{"role": "system", "content": system_prompt}]

    print("Подключено. Модель: " + args.model + " | MCP-инструменты: " + ", ".join(t["name"] for t in mcp_tools))
    print("Введите запрос (Ctrl+C для выхода).")

    try:
        while True:
            try:
                user_input = input("\n> ")
            except EOFError:
                break
            if not user_input.strip():
                continue
            messages.append({"role": "user", "content": user_input})

            max_tool_rounds = 8
            tool_round = 0
            while True:
                try:
                    result = ollama_chat(args.ollama_url, args.model, messages, ollama_tools)
                except urllib.error.URLError as e:
                    print("Запрос к Ollama не выполнен: " + str(e))
                    break

                message = result.get("message", {})
                tool_calls = message.get("tool_calls") or []
                messages.append(message)

                if not tool_calls:
                    print("\n" + (message.get("content") or "").strip())
                    break

                tool_round += 1
                if tool_round > max_tool_rounds:
                    print("\nОстановлено: модель сделала слишком много вызовов инструментов подряд ("
                          + str(max_tool_rounds) + ") без финального ответа. Возможно, она застряла - "
                          "уточните запрос или сформулируйте его иначе.")
                    break

                for call in tool_calls:
                    fn = call.get("function", {})
                    name = fn.get("name")
                    raw_args = fn.get("arguments", {})
                    if isinstance(raw_args, str):
                        try:
                            raw_args = json.loads(raw_args)
                        except json.JSONDecodeError:
                            raw_args = {}
                    print("\n[инструмент] " + name + " " + json.dumps(raw_args, ensure_ascii=False))
                    try:
                        tool_result = client.call_tool(name, raw_args)
                    except Exception as e:
                        tool_result = "ОШИБКА: " + str(e)
                    preview = tool_result if len(tool_result) <= 2000 else tool_result[:2000] + "... (обрезано)"
                    print("[результат] " + preview)
                    messages.append({
                        "role": "tool",
                        "name": name,
                        "content": tool_result,
                    })
    except KeyboardInterrupt:
        pass
    finally:
        client.close()

if __name__ == "__main__":
    main()
