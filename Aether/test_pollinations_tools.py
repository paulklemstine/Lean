import httpx
import json

data = {
    "model": "openai-large",
    "messages": [{"role": "user", "content": "What is the weather?"}],
    "tools": [{
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get weather",
            "parameters": {"type": "object", "properties": {}}
        }
    }]
}

headers = {"Authorization": "Bearer pk_nxM10AP0L7y8AX1I"}
resp = httpx.post("https://gen.pollinations.ai/v1/chat/completions", json=data, headers=headers, timeout=30)
print(json.dumps(resp.json(), indent=2))
