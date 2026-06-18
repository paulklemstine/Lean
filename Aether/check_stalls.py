import json
import os
import time
from datetime import datetime, timezone

def main():
    path = ".aether_workspace/inflight_jobs.json"
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Total inflight: {len(data)}")
    now = time.time()
    for pid, j in data.items():
        job_id = j.get("job_id") or "?"
        phase = j.get("phase") or "?"
        status = j.get("status") or "?"
        dispatch_time = j.get("dispatch_time") or 0.0
        elapsed_min = (now - dispatch_time) / 60.0 if dispatch_time else 0.0
        title = j.get("concept", {}).get("title") or "?"
        dt_str = datetime.fromtimestamp(dispatch_time, tz=timezone.utc).isoformat() if dispatch_time else "unknown"
        print(f"Project: {pid[:8]} | Job: {job_id[:8]} | Phase: {phase:10} | Status: {status:10} | Elapsed: {elapsed_min:6.1f} min (Dispatched: {dt_str}) | Title: {title[:40]}")

if __name__ == '__main__':
    main()
