import json
import os
from datetime import datetime, timezone

def main():
    path = ".aether_workspace/cycle_analytics.json"
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    records = data.get("records", [])
    print(f"Total records: {len(records)}")
    
    # Bucket records by 4-hour intervals
    buckets = {}
    for r in records:
        ts_str = r.get("timestamp")
        if not ts_str:
            continue
        try:
            # Parse ISO timestamp
            dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
            # Group by 4 hours
            bucket_key = dt.strftime("%Y-%m-%d %H:00")
            # Round hour to multiple of 4
            hour = (dt.hour // 4) * 4
            bucket_key = f"{dt.strftime('%Y-%m-%d')} {hour:02d}:00 UTC"
        except Exception:
            continue
            
        if bucket_key not in buckets:
            buckets[bucket_key] = {"total": 0, "complete": 0, "A_only": 0, "scores": [], "reasons": []}
        
        buckets[bucket_key]["total"] += 1
        phase = r.get("phase")
        if phase == "complete":
            buckets[bucket_key]["complete"] += 1
        else:
            buckets[bucket_key]["A_only"] += 1
        
        if r.get("quality_score"):
            buckets[bucket_key]["scores"].append(r["quality_score"])
            
        skip_reason = r.get("phase_b_skip_reason")
        if skip_reason:
            buckets[bucket_key]["reasons"].append(skip_reason)
            
    print("\n=== Timeline of cycles (grouped by 4-hour window) ===")
    print(f"{'Time Window':22} | {'Total':5} | {'Packaged (B)':12} | {'Skipped (A)':11} | {'Avg Quality':11} | {'Common Skip Reasons'}")
    print("-" * 110)
    for k in sorted(buckets.keys())[-25:]:
        b = buckets[k]
        avg_q = sum(b["scores"]) / len(b["scores"]) if b["scores"] else 0.0
        from collections import Counter
        reasons_summary = ", ".join(f"{r}:{c}" for r, c in Counter(b["reasons"]).most_common(2))
        print(f"{k:22} | {b['total']:5} | {b['complete']:12} | {b['A_only']:11} | {avg_q:.3f}       | {reasons_summary}")

if __name__ == '__main__':
    main()
