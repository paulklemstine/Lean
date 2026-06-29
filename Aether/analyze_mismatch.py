import json
import glob
import os
from collections import defaultdict
from pathlib import Path

def main():
    packages_dir = "Packages"
    json_files = glob.glob(os.path.join(packages_dir, "*.json"))
    excluded = {"index.json", "package.json", "lineage.json", "future_directions.json", "statement.json", "future_directions_snapshot.json"}
    json_files = [f for f in json_files if os.path.basename(f) not in excluded]

    # Map from actual folder domain to JSON declared domains
    actual_to_json = defaultdict(list)
    json_to_actual = defaultdict(list)
    mismatches = []

    for f in json_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                data = json.load(file)
                if not isinstance(data, dict):
                    continue
                
                json_domain = data.get("domain", "Unknown")
                title = data.get("title", "")
                
                # Locate actual lean files
                lean_files = data.get("lean_files", [])
                if isinstance(lean_files, str):
                    lean_files = [lean_files]
                
                actual_domains = set()
                for fpath in lean_files:
                    if not isinstance(fpath, str) or not fpath.endswith('.lean'):
                        continue
                    
                    # Try to resolve where this file exists in Catalog
                    # e.g., Catalog/Algebra/Foo/Bar.lean -> "Algebra"
                    # fpath might be e.g. "Catalog/Applications/BoltzmannBridge/InterleavingIsometry.lean"
                    parts = fpath.replace("\\", "/").split("/")
                    if len(parts) > 1 and parts[0] == "Catalog":
                        actual_domains.add(parts[1])
                    else:
                        # Fallback: search Catalog for the filename if path isn't clear
                        basename = os.path.basename(fpath)
                        found_path = None
                        for root, dirs, files in os.walk("Catalog"):
                            if basename in files:
                                found_path = os.path.join(root, basename)
                                break
                        if found_path:
                            p_parts = found_path.replace("\\", "/").split("/")
                            if len(p_parts) > 1 and p_parts[0] == "Catalog":
                                actual_domains.add(p_parts[1])
                
                if actual_domains:
                    for ad in actual_domains:
                        actual_to_json[ad].append((json_domain, title))
                        json_to_actual[json_domain].append((ad, title))
                        if ad != json_domain:
                            mismatches.append({
                                "title": title,
                                "json_domain": json_domain,
                                "actual_domain": ad,
                                "file": os.path.basename(f)
                            })
                else:
                    # No lean files found in Catalog
                    actual_to_json["No_Lean_Files"].append((json_domain, title))
                    
        except Exception as e:
            print(f"Error reading {f}: {e}")

    print(f"Total package JSONs checked: {len(json_files)}")
    print(f"Total mismatches found: {len(mismatches)}")
    
    print("\n=== Mismatch Details (First 30) ===")
    for m in mismatches[:30]:
        print(f"  - '{m['title'][:50]}...'")
        print(f"    JSON Domain  : {m['json_domain']}")
        print(f"    Actual Folder: {m['actual_domain']}")
        print(f"    Package File : {m['file']}")
        
    print("\n=== Actual Folders and their corresponding JSON domains ===")
    for act_dom, items in sorted(actual_to_json.items()):
        counts = defaultdict(int)
        for jd, _ in items:
            counts[jd] += 1
        counts_str = ", ".join(f"{jd}: {cnt}" for jd, cnt in counts.items())
        print(f"  {act_dom:20} -> {counts_str}")

if __name__ == "__main__":
    main()
