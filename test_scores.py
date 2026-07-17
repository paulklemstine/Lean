import json
with open("Aether/.aether_workspace/cycle_analytics.json", "r") as f:
    data = json.load(f)
records = data.get("records", [])
print(json.dumps(records[-1], indent=2))
