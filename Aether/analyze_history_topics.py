import json
import glob
import os
from collections import Counter, defaultdict

def main():
    packages_dir = "Packages"
    json_files = glob.glob(os.path.join(packages_dir, "*.json"))
    excluded = {"index.json", "package.json", "lineage.json", "future_directions.json", "statement.json", "future_directions_snapshot.json", "catalog_tree.json"}
    json_files = [f for f in json_files if os.path.basename(f) not in excluded]

    # Cluster definitions by keywords in title or description
    topic_rules = {
        "Boltzmann Bridge & Topological Stability": [
            "boltzmann", "bridge", "interleaving", "persistence", "bottleneck", "cohen-steiner", "rips", "filtrations", "stability"
        ],
        "Fibonacci & Rank of Apparition (Carmichael's Theorem)": [
            "fibonacci", "apparition", "carmichael", "divisibility", "primitivity", "divisor", "zsigmondy", "strong divisibility"
        ],
        "Tropical Geometry & ReLU Networks": [
            "tropical", "max-plus", "semiring", "relu", "dequantization", "maslov", "hecke", "langlands"
        ],
        "Pythagorean Trees & Berggren Triples": [
            "pythagorean", "berggren", "triplet", "quadruple", "carmichael composite", "carmichael's theorem"
        ],
        "EML (Emergent Meta-Language) & Applied Super-Domain": [
            "eml", "emergent meta-language", "self-pairing", "spb", "softplus"
        ],
        "Logic & Proof Complexity (Cook-Reckhow, Gödel-Löb)": [
            "cook-reckhow", "gödel", "goedel", "kripke", "logic", "provability", "decidability", "truth", "modal", "betti"
        ],
        "Machine Learning Theory & VC Dimension": [
            "machine learning", "neural", "deep learning", "generalization", "pac-bayes", "lipschitz bound", "clique-complex", "margin"
        ],
        "Physics & Thermodynamics (Landauer's Principle)": [
            "landauer", "thermodynamic", "entropy", "spacetime", "physics", "cosmology", "reversible computing"
        ],
        "Bridges (Trans-Domain Connections)": [
            "bridge between", "stone duality", "isometry", "duality"
        ]
    }

    categorized_counts = defaultdict(int)
    uncategorized = []
    
    # We will record the actual json details for analysis
    all_packages = []

    for f in json_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                data = json.load(file)
                if not isinstance(data, dict):
                    continue
                title = data.get("title", "").lower()
                desc = data.get("description", "").lower()
                keywords = [k.lower() for k in data.get("keywords", [])]
                
                combined_text = f"{title} {desc} {' '.join(keywords)}"
                
                matched_topics = []
                for topic, keywords_list in topic_rules.items():
                    if any(kw in combined_text for kw in keywords_list):
                        matched_topics.append(topic)
                
                if not matched_topics:
                    # Try to fall back to general categories
                    uncategorized.append((data.get("title", ""), data.get("domain", "")))
                else:
                    for t in matched_topics:
                        categorized_counts[t] += 1
                        
                all_packages.append({
                    "title": data.get("title", ""),
                    "domain": data.get("domain", ""),
                    "matched_topics": matched_topics
                })
        except Exception as e:
            print(f"Error reading {f}: {e}")

    total = len(all_packages)
    print(f"Total packages categorized: {total}")
    print("\n=== Topic Cluster Counts ===")
    # Sort by count descending
    sorted_topics = sorted(categorized_counts.items(), key=lambda x: x[1], reverse=True)
    for topic, count in sorted_topics:
        pct = (count / total) * 100
        print(f"  {topic:60} : {count:3} ({pct:5.1f}%)")

    print(f"\nUncategorized packages count: {len(uncategorized)}")
    print("=== Sample Uncategorized Packages ===")
    for title, dom in uncategorized[:10]:
        print(f"  - {title} (Domain: {dom})")

    # Let's also look at how "close_proofs" matches these clusters
    close_proofs_count = 0
    close_proofs_topics = defaultdict(int)
    for p in all_packages:
        if p["title"].lower().startswith("close proofs") or p["title"].lower().startswith("closing proofs") or "close" in p["title"].lower():
            close_proofs_count += 1
            for t in p["matched_topics"]:
                close_proofs_topics[t] += 1
                
    print(f"\nTotal 'Close Proofs' packages: {close_proofs_count} ({(close_proofs_count/total)*100:.1f}%)")
    print("=== Topics of 'Close Proofs' ===")
    for topic, count in sorted(close_proofs_topics.items(), key=lambda x: x[1], reverse=True):
        print(f"  {topic:60} : {count:3}")

if __name__ == "__main__":
    main()
