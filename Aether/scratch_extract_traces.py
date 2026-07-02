import os
import json
from pathlib import Path
import textwrap

packages_dir = Path("/home/raver1975/lean/Packages")
json_files = []
for f in packages_dir.glob("*.json"):
    if f.name in ["lineage.json", "future_directions.json", "statement.json", "index.json", "package.json"]:
        continue
    json_files.append(f)

# Sort by modification time (most recent first)
json_files.sort(key=lambda x: x.stat().st_mtime, reverse=True)

print(f"Found {len(json_files)} packages. Analyzing the last 10...")

for f in json_files[:10]:
    try:
        data = json.loads(f.read_text(encoding='utf-8'))
        title = data.get('title', f.name)
        traces = data.get('reasoning_traces', [])
        
        print(f"\n{'='*80}")
        print(f"Project: {title}")
        print(f"Traces: {len(traces)}")
        if traces:
            # Show the last trace (usually the final resolution/thinking)
            last_trace = traces[-1]
            print(f"Final trace snippet ({len(last_trace)} chars):")
            print(textwrap.indent(last_trace[:1500] + ("..." if len(last_trace) > 1500 else ""), "    "))
        else:
            print("No reasoning_traces found in this package.")
            # Let's see if there is any other log
            if 'result_summary' in data:
                print("Result summary snippet:")
                print(textwrap.indent(data['result_summary'][:1500], "    "))
    except Exception as e:
        print(f"Error reading {f.name}: {e}")
