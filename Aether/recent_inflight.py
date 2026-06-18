import json
import os

def main():
    path = ".aether_workspace/inflight_jobs.json"
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Total inflight jobs: {len(data)}")
    print(f"{'Project ID':8} | {'Job ID':8} | {'Phase':10} | {'Status':8} | {'Title'}")
    print("-" * 80)
    for pid, j in data.items():
        job_id = j.get("job_id") or "?"
        phase = j.get("phase") or "?"
        status = j.get("status") or "?"
        title = j.get("concept", {}).get("title") or "?"
        print(f"{pid[:8]:8} | {job_id[:8]:8} | {phase:10} | {status:8} | {title[:40]}")

if __name__ == '__main__':
    main()
