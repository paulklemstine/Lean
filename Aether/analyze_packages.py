import json
import glob
import os
from collections import Counter

def main():
    packages_dir = "Packages"
    json_files = glob.glob(os.path.join(packages_dir, "*.json"))
    excluded = {"index.json", "package.json", "lineage.json", "future_directions.json", "statement.json", "future_directions_snapshot.json"}
    json_files = [f for f in json_files if os.path.basename(f) not in excluded]

    domains = []
    keywords = []
    records = []

    # Common mathematical stop words
    stop_words = {
        "prove", "proved", "theorems", "cycle", "formalized", "formalizing", "established", "closed", "sorry", "zero",
        "about", "theory", "structural", "results", "added", "added_catalog", "built", "built_from_scratch",
        "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth",
        "between", "framework", "formalization", "files", "delivers", "delivered", "closes", "closing",
        "system", "study", "proof", "proofs", "analysis", "result", "using", "under", "where", "which"
    }

    for f in json_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                data = json.load(file)
                if not isinstance(data, dict):
                    continue
                dom = data.get("domain", "Unknown")
                title = data.get("title", "")
                
                domains.append(dom)
                records.append({
                    "file": os.path.basename(f),
                    "domain": dom,
                    "title": title
                })
                # Extract clean keywords
                words = [w.lower().strip(",.():\"'[];{}*") for w in title.split()]
                for w in words:
                    if len(w) > 3 and w not in stop_words:
                        keywords.append(w)
        except Exception as e:
            print(f"Error reading {f}: {e}")

    total = len(records)
    print(f"Total packages parsed from JSON files: {total}")
    
    # Calculate directory counts
    catalog_path = "Catalog"
    dir_counts = {}
    if os.path.exists(catalog_path):
        for d in os.listdir(catalog_path):
            full_d = os.path.join(catalog_path, d)
            if os.path.isdir(full_d) and d not in (".lake", "Catalog"):
                # Count folders inside this domain directory
                try:
                    subdirs = [sub for sub in os.listdir(full_d) if os.path.isdir(os.path.join(full_d, sub)) and sub not in ("Packages", "visualizations")]
                    dir_counts[d] = len(subdirs)
                except Exception:
                    pass

    print("\n=== Comparison: JSON metadata vs Actual Catalog Subdirs ===")
    json_counter = Counter(domains)
    all_domains = set(json_counter.keys()) | set(dir_counts.keys())
    
    print(f"  {'Domain Name':20} | {'JSON Count':10} | {'Subdirs Count':13}")
    print(f"  {'-'*20} | {'-'*10} | {'-'*13}")
    for dom in sorted(all_domains):
        json_c = json_counter.get(dom, 0)
        dir_c = dir_counts.get(dom, 0)
        print(f"  {dom:20} | {json_c:10} | {dir_c:13}")

    print("\n=== Top Keywords in Titles ===")
    for word, count in Counter(keywords).most_common(20):
        pct = (count / total) * 100
        print(f"  {word:20} : {count:3} ({pct:5.1f}%)")

if __name__ == "__main__":
    main()
