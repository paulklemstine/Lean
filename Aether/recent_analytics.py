import json
import os
from datetime import datetime

def main():
    path = ".aether_workspace/cycle_analytics.json"
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    records = data.get("records", [])
    print(f"Total records in analytics: {len(records)}")
    
    print(f"\nLast 30 cycles detail:")
    print(f"{'Index':5} | {'Job ID':8} | {'Quality':7} | {'Phase':8} | {'Skip Reason':22} | {'Title'}")
    print("-" * 100)
    for idx, r in enumerate(records[-30:]):
        real_idx = len(records) - 30 + idx
        job_id = r.get("job_id") or r.get("experiment_id") or r.get("id") or "?"
        q = r.get("quality_score", 0.0)
        phase = r.get("phase") or "?"
        skip_reason = r.get("phase_b_skipped_reason") or "None"
        title = r.get("concept_title") or r.get("title") or r.get("concept", {}).get("title") or "?"
        print(f"{real_idx:5} | {job_id[:8]:8} | {q:.3f}   | {phase:8} | {skip_reason:22} | {title}")

if __name__ == '__main__':
    main()
