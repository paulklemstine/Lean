import os
import glob
import json
import time
import base64
import re

def sanitize_filename(name, max_len=60):
    """Convert a visualization name to a safe filename."""
    base = name.lower().strip()
    base = re.sub(r'[^a-z0-9]+', '_', base)
    base = base.strip('_')
    return base[:max_len]

def extract_visualization(data, viz_name, pkg_slug, viz_index, viz_dir):
    """Extract a visualization's data into a real file. Returns the relative path."""
    if not data:
        return None

    safe_name = sanitize_filename(viz_name) or f"viz_{viz_index}"
    filename = f"{pkg_slug}_{safe_name}"

    if data.startswith('data:image/'):
        # data URI format: data:image/png;base64,<base64data>
        header, _, b64data = data.partition(',')
        mime_part = header.split(';')[0]  # e.g. "data:image/png"
        mime = mime_part.replace('data:', '')  # e.g. "image/png"
        ext_map = {
            'image/png': '.png',
            'image/jpeg': '.jpg',
            'image/jpg': '.jpg',
            'image/gif': '.gif',
            'image/webp': '.webp',
            'image/svg+xml': '.svg',
        }
        ext = ext_map.get(mime, '.png')
        filepath = os.path.join(viz_dir, filename + ext)
        if not os.path.exists(filepath):
            try:
                img_bytes = base64.b64decode(b64data)
                with open(filepath, 'wb') as f:
                    f.write(img_bytes)
            except Exception as e:
                print(f"  Warning: failed to decode base64 for {filename}: {e}")
                return None
        return f"visualizations/{filename + ext}"

    elif data.startswith('<svg'):
        # Inline SVG
        filepath = os.path.join(viz_dir, filename + '.svg')
        if not os.path.exists(filepath):
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(data)
        return f"visualizations/{filename}.svg"

    elif data.startswith('iVBOR') or data.startswith('/9j/'):
        # Raw base64 without data URI prefix
        ext = '.png' if data.startswith('iVBOR') else '.jpg'
        filepath = os.path.join(viz_dir, filename + ext)
        if not os.path.exists(filepath):
            try:
                img_bytes = base64.b64decode(data)
                with open(filepath, 'wb') as f:
                    f.write(img_bytes)
            except Exception as e:
                print(f"  Warning: failed to decode raw base64 for {filename}: {e}")
                return None
        return f"visualizations/{filename + ext}"

    return None

def get_creation_date(filename, catalog_root):
    """Get the date a file was first committed to git, falling back to mtime."""
    try:
        import subprocess
        # Path relative to git root
        rel_path = os.path.relpath(os.path.abspath(filename), catalog_root)
        result = subprocess.run(
            ["git", "log", "--diff-filter=A", "--format=%aI", "--", rel_path],
            capture_output=True, text=True, cwd=catalog_root
        )
        if result.returncode == 0 and result.stdout.strip():
            date_iso = result.stdout.strip().split('\n')[0]
            # Convert ISO 8601 to a display-friendly format
            # e.g. "2026-05-11T09:36:52-05:00" -> "2026-05-11T14:36:52Z"
            from datetime import datetime, timezone
            try:
                dt = datetime.fromisoformat(date_iso)
                dt_utc = dt.astimezone(timezone.utc)
                return dt_utc.strftime('%Y-%m-%dT%H:%M:%SZ')
            except Exception:
                return date_iso
    except Exception:
        pass
    # Fallback to file modification time
    return time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(os.path.getmtime(filename)))

def load_quality_scores():
    """Load quality scores from autoresearch.jsonl, keyed by exp_id.
    Returns dict: exp_id -> {quality_score: float, quality: str}
    Keeps the highest quality_score per experiment (re-runs may differ).
    """
    scores = {}
    # Try Aether workspace (local dev) then relative path
    candidates = [
        # From Catalog/Applications/Packages/
        os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "Aether", ".aether_workspace", "autoresearch", "autoresearch.jsonl")),
        # From docs/
        os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "Aether", ".aether_workspace", "autoresearch", "autoresearch.jsonl")),
        os.path.abspath(os.path.join(os.path.dirname(__file__), "autoresearch.jsonl")),
    ]
    path = None
    for c in candidates:
        if os.path.exists(c):
            path = c
            break
    if not path:
        print("No autoresearch.jsonl found, quality scores will be null")
        return scores

    try:
        with open(path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    d = json.loads(line)
                except json.JSONDecodeError:
                    continue
                eid = d.get("experiment_id", "")
                qs = d.get("quality_score", 0)
                if not eid:
                    continue
                if eid not in scores or qs > scores[eid]["quality_score"]:
                    scores[eid] = {
                        "quality_score": qs,
                        "quality": d.get("quality", "unrated"),
                    }
        print(f"Loaded quality scores for {len(scores)} experiments")
    except Exception as e:
        print(f"Warning: failed to load autoresearch.jsonl: {e}")
    return scores


def update_index():
    original_dir = os.getcwd()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # Find the Catalog root or git root dynamically by walking up
    catalog_root = script_dir
    while catalog_root and catalog_root != os.path.dirname(catalog_root):
        if os.path.exists(os.path.join(catalog_root, ".git")) or os.path.exists(os.path.join(catalog_root, "Aether")):
            break
        catalog_root = os.path.dirname(catalog_root)
    else:
        # Fallback if not found
        catalog_root = os.path.abspath(os.path.join(script_dir, "..", ".."))

    json_files = sorted(f for f in glob.glob("*.json") if f not in ("index.json", "package.json", "lineage.json", "future_directions.json", "statement.json", "future_directions_snapshot.json", "catalog_tree.json"))

    # IMPORTANT: The website displays every Phase B package that exists in this
    # directory. Do NOT filter by quality_score, grade, or any other quality
    # metric here. Quality gating happens upstream at the Phase A -> Phase B
    # dispatch decision; once a package is created it must be discoverable.

    viz_dir = os.path.join(script_dir, "visualizations")
    os.makedirs(viz_dir, exist_ok=True)

    package_index = []
    package_db_index = {}  # lightweight: {filename: {title, exp_id, source_exp_ids, domain}}
    total_viz_extracted = 0

    # Load quality scores from autoresearch data
    quality_scores = load_quality_scores()

    for f in json_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                data = json.load(file)
        except Exception as e:
            print(f"Error processing {f}: {e}")
            continue

        # Skip non-package JSON files (e.g. lists, primitives)
        if not isinstance(data, dict):
            print(f"Skipping {f}: not a package object (got {type(data).__name__})")
            continue

        # Use date from JSON package (populated during AETHER integration)
        # Fall back to git creation date, then file mtime
        date_str = data.get("date") or get_creation_date(f, catalog_root)

        pkg_slug = f.replace('.json', '')

        # Look up quality score by exp_id
        exp_id = data.get("exp_id", "")
        qs_entry = quality_scores.get(exp_id, None) if exp_id else None
        quality_score = qs_entry["quality_score"] if qs_entry else None
        quality_label = qs_entry["quality"] if qs_entry else "unrated"

        # Extract visualizations into real files, replace data with file paths
        if data.get("visualizations"):
            # Convert string entries to dicts — LLM sometimes returns filenames instead of objects
            data["visualizations"] = [
                {"name": v.replace(".py", "").replace("_", " ").title(), "code": "", "description": ""}
                if isinstance(v, str) else v
                for v in data["visualizations"]
            ]
            for i, viz in enumerate(data["visualizations"]):
                # Handle inline image data (base64/SVG)
                viz_data = viz.get("data", "")
                if viz_data:
                    rel_path = extract_visualization(
                        viz_data, viz.get("name", ""), pkg_slug, i, viz_dir
                    )
                    if rel_path:
                        viz["file"] = rel_path
                        del viz["data"]
                        total_viz_extracted += 1

                # Handle Python visualization scripts (code field)
                viz_code = viz.get("code", "")
                # Skip if code is just a filename placeholder (not actual Python)
                is_filename = viz_code and len(viz_code) < 80 and (viz_code.endswith('.py') or viz_code.startswith('viz_') or viz_code.startswith('visualize_'))
                if viz_code and not is_filename and not viz.get("code_file"):
                    safe_name = sanitize_filename(viz.get("name", ""), 30) or f"viz_{i}"
                    viz_filename = f"{pkg_slug}_{safe_name}.py"
                    viz_path = os.path.join(viz_dir, viz_filename)
                    with open(viz_path, 'w', encoding='utf-8') as vf:
                        vf.write(viz_code)
                    viz["code_file"] = f"visualizations/{viz_filename}"

        # Also extract algorithms code into separate files if present
        if data.get("algorithms"):
            # Convert string entries to dicts
            data["algorithms"] = [
                {"name": a.replace(".py", "").replace("_", " ").title(), "code": ""}
                if isinstance(a, str) else a
                for a in data["algorithms"]
            ]
            for i, alg in enumerate(data["algorithms"]):
                alg_code = alg.get("code", "")
                if alg_code:
                    safe_name = sanitize_filename(alg.get("name", ""), 40) or f"algo_{i}"
                    alg_filename = f"{pkg_slug}_{safe_name}.py"
                    alg_path = os.path.join(viz_dir, alg_filename)
                    with open(alg_path, 'w', encoding='utf-8') as af:
                        af.write(alg_code)
                    alg["code_file"] = f"visualizations/{alg_filename}"

        # Embed actual Lean 4 code into lean_proofs entries that only have file paths
        if data.get("lean_proofs"):
            lp = data["lean_proofs"]
            if isinstance(lp, list):
                for entry in lp:
                    if not isinstance(entry, dict):
                        continue
                    if entry.get("code"):
                        continue
                    fpath = entry.get("file", "") or entry.get("name", "")
                    if not fpath or not fpath.endswith('.lean'):
                        continue
                    # Try to find the .lean file with various path prefixes
                    # fpath may be "Catalog/Algebra/Foo.lean" or "Algebra/Foo.lean"
                    candidates = [fpath]
                    if fpath.startswith("Catalog/"):
                        candidates.append(fpath[len("Catalog/"):])
                    # Also try finding by basename in all subdirectories
                    basename = os.path.basename(fpath)
                    for candidate in candidates:
                        for prefix in [catalog_root, os.path.join(catalog_root, "Catalog"), os.path.join(catalog_root, "Catalog", "Applications")]:
                            full_path = os.path.join(prefix, candidate)
                            if os.path.isfile(full_path):
                                with open(full_path, 'r', encoding='utf-8', errors='ignore') as lf:
                                    entry["code"] = lf.read()
                                break
                        if entry.get("code"):
                            break
                    # Fallback: search by basename
                    if not entry.get("code"):
                        for root, dirs, files in os.walk(catalog_root):
                            if basename in files:
                                full_path = os.path.join(root, basename)
                                with open(full_path, 'r', encoding='utf-8', errors='ignore') as lf:
                                    entry["code"] = lf.read()
                                break

        # Rewrite the individual JSON file with extracted viz paths
        with open(f, 'w', encoding='utf-8') as out_f:
            json.dump(data, out_f, indent=2, ensure_ascii=False)

        package_index.append({
            "filename": f,
            "title": data.get("title", "Untitled Research"),
            "domain": data.get("domain", "General"),
            "date": date_str,
            "exp_id": data.get("exp_id", ""),
            "quality_score": quality_score,
            "quality": quality_label,
        })

        # Lightweight index for lineage links (no big text fields)
        package_db_index[f] = {
            "title": data.get("title", "Untitled Research"),
            "exp_id": data.get("exp_id", ""),
            "source_exp_ids": data.get("source_exp_ids", []),
            "domain": data.get("domain", "General"),
        }

    # Assign stable package numbers based on date-ascending order (oldest = 1)
    package_index.sort(key=lambda x: x["date"])
    for i, pkg in enumerate(package_index):
        pkg["pkg_num"] = i + 1
    # Then sort descending for display (newest first)
    package_index.sort(key=lambda x: x["date"], reverse=True)

    js_content = f"""// AUTO-GENERATED FILE. DO NOT EDIT.
// Lightweight index for sidebar, graph, and lineage links.
// Full package data is loaded on-demand from individual .json files.

window.PACKAGE_INDEX = {json.dumps(package_index, indent=2, sort_keys=True)};

window.PACKAGE_DB_INDEX = {json.dumps(package_db_index, indent=2, sort_keys=True)};
"""

    with open("package_index.js", "w", encoding="utf-8") as out:
        out.write(js_content)

    # Calculate sizes
    idx_size = os.path.getsize("package_index.js")
    viz_size = sum(
        os.path.getsize(os.path.join(viz_dir, f))
        for f in os.listdir(viz_dir)
        if os.path.isfile(os.path.join(viz_dir, f))
    )

    print(f"Generated package_index.js ({idx_size/1024:.0f} KB) with {len(json_files)} packages")
    print(f"Extracted {total_viz_extracted} visualizations into visualizations/ ({viz_size/1024:.0f} KB)")

    # Generate knowledge graph data
    generate_graph_data(script_dir, package_index)

    # Write future research directions to separate file (lazy-loaded)
    append_future_directions(script_dir, os.path.join(script_dir, "future_directions.js"))

    # Ensure .nojekyll exists for GitHub Pages
    nojekyll_path = os.path.join(script_dir, ".nojekyll")
    if not os.path.exists(nojekyll_path):
        open(nojekyll_path, 'w').close()
        print("Created .nojekyll for GitHub Pages")

    os.chdir(original_dir)


def generate_graph_data(script_dir, package_index):
    """Read lineage.json and append window.PACKAGE_GRAPH to package_index.js."""
    lineage_path = os.path.join(script_dir, "lineage.json")
    db_path = os.path.join(script_dir, "package_index.js")

    # Domain → shape mapping for the Knowledge Graph
    DOMAIN_SHAPES = {
        "Algebra": "tetrahedron",
        "Bridges": "icosahedron",
        "Computation": "cube",
        "Cryptography": "dodecahedron",
        "EML": "octahedron",
        "Geometry": "hexagonal_prism",
        "Logic": "star_of_david",
        "MachineLearning": "sphere_rings",
        "Physics": "diamond",
        "Pythagorean": "triangular_prism",
        "Speculative": "pentagonal_prism",
        "Tropical": "star",
    }

    def mulberry32(seed):
        """Seeded PRNG for deterministic hue generation (JS-compatible)."""
        seed = seed & 0xFFFFFFFF
        def inner():
            nonlocal seed
            seed = (seed + 0x6D2B79F5) & 0xFFFFFFFF
            t = seed ^ (seed >> 15)
            t = (t * (t | 1)) & 0xFFFFFFFF
            t = (t ^ (t + 0x3FB52453)) & 0xFFFFFFFF
            t = (t ^ (t >> 13)) & 0xFFFFFFFF
            return t / 4294967296
        return inner

    def slug_to_hue(slug):
        rng = mulberry32(hash(slug))
        return int(rng() * 360)

    def canonicalize_domain(domain_str):
        """Extract all canonical domain labels from a freeform domain string."""
        if not domain_str:
            return ["Bridges"]
        text = domain_str.replace("×", "x").replace("(", " ").replace(")", " ")
        text = text.replace("/", " ").replace("-", " ").replace("x", " ").replace(",", " ")
        text_lower = text.lower()
        found = []
        for domain in DOMAIN_SHAPES:
            if domain == "EML":
                if "eml" in text_lower:
                    found.append(domain)
            elif domain == "MachineLearning":
                if "machine learning" in text_lower or "machinelearning" in text_lower:
                    found.append(domain)
            else:
                if domain.lower() in text_lower:
                    found.append(domain)
        return found if found else ["Bridges"]

    def primary_domain(domain_str):
        """Pick the least-common domain for visual variety."""
        domains = canonicalize_domain(domain_str)
        if not domains:
            return "Bridges"
        if hasattr(primary_domain, 'domain_counts'):
            return min(domains, key=lambda d: primary_domain.domain_counts.get(d, 0))
        return domains[0]

    # Try to read lineage.json
    graph_data = None
    if os.path.exists(lineage_path):
        try:
            with open(lineage_path, 'r', encoding='utf-8') as f:
                graph_data = json.load(f)
            print(f"Loaded lineage.json: {len(graph_data.get('nodes', []))} nodes, {len(graph_data.get('edges', []))} edges, {len(graph_data.get('domain_bridges', []))} bridges")
        except Exception as e:
            print(f"Warning: failed to load lineage.json: {e}")

    # Build exp_id -> quality lookup for graph node enrichment
    exp_quality = {}
    for pkg in package_index:
        eid = pkg.get("exp_id", "")
        if eid:
            exp_quality[eid] = {
                "priority_score": pkg.get("quality_score"),
                "quality": pkg.get("quality", "unrated"),
            }

    # If no lineage data, build nodes from package_index (already computed above)
    if graph_data is None:
        # Compute domain frequency for variety
        from collections import Counter
        domain_counts = Counter()
        for pkg in package_index:
            for d in canonicalize_domain(pkg.get("domain", "")):
                domain_counts[d] += 1
        primary_domain.domain_counts = dict(domain_counts)

        nodes = []
        for pkg in package_index:
            slug = pkg["filename"].replace('.json', '')
            domain_str = pkg.get("domain", "Bridges")
            pd = primary_domain(domain_str)
            qs = exp_quality.get(pkg.get("exp_id", ""), {})
            nodes.append({
                "id": slug,
                "title": pkg.get("title", slug),
                "domain": domain_str,
                "primary_domain": pd,
                "shape": DOMAIN_SHAPES.get(pd, "icosahedron"),
                "date": pkg.get("date", ""),
                "hue": slug_to_hue(slug),
                "priority_score": qs.get("priority_score"),
                "quality": qs.get("quality", "unrated"),
            })
        graph_data = {"nodes": nodes, "edges": [], "domain_bridges": []}
    else:
        # Enrich nodes with shape, hue, and quality if missing
        for node in graph_data.get("nodes", []):
            if "shape" not in node:
                pd = node.get("primary_domain", primary_domain(node.get("domain", "")))
                node["shape"] = DOMAIN_SHAPES.get(pd, "icosahedron")
            if "hue" not in node:
                node["hue"] = slug_to_hue(node.get("id", ""))
            # Add quality from exp_id lookup
            if "priority_score" not in node:
                # Find matching package by node id (slug) -> exp_id
                node_id = node.get("id", "")
                matching_pkg = next((p for p in package_index if p["filename"].replace(".json", "") == node_id), None)
                if matching_pkg and matching_pkg.get("exp_id"):
                    qs = exp_quality.get(matching_pkg["exp_id"], {})
                    node["priority_score"] = qs.get("priority_score")
                    node["quality"] = qs.get("quality", "unrated")
                else:
                    node["priority_score"] = None
                    node["quality"] = "unrated"

    # Append to package_index.js
    graph_js = f"""

// Knowledge Graph Data (auto-generated from lineage.json)
window.PACKAGE_GRAPH = {json.dumps(graph_data, indent=2, sort_keys=True)};
"""
    with open(db_path, 'a', encoding='utf-8') as f:
        f.write(graph_js)

    print(f"Appended PACKAGE_GRAPH to package_index.js ({len(graph_data.get('nodes', []))} nodes, {len(graph_data.get('edges', []))} edges, {len(graph_data.get('domain_bridges', []))} bridges)")


def append_future_directions(script_dir, fd_js_path):
    """Read future_directions.json and write window.FUTURE_DIRECTIONS to a separate
    future_directions.js file (lazy-loaded on demand, not in the initial page load).
    """
    # Try Aether workspace (local dev)
    fd_path = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "Aether", ".aether_workspace", "future_directions.json"))
    # Fallback: committed copy in Packages directory (CI/GitHub Pages)
    local_copy_path = os.path.join(script_dir, "future_directions.json")

    if os.path.exists(fd_path):
        source = fd_path
    elif os.path.exists(local_copy_path):
        source = local_copy_path
        print(f"Aether workspace not found, using local future_directions.json")
    else:
        print(f"No future_directions.json found, skipping")
        return

    try:
        with open(source, 'r', encoding='utf-8') as f:
            data = json.load(f)
        # Handle both old format (flat list) and new format (dict with "directions" key)
        if isinstance(data, list):
            directions = data
        elif isinstance(data, dict):
            directions = data.get("directions", [])
        else:
            directions = []
    except Exception as e:
        print(f"Warning: failed to load future_directions.json: {e}")
        return

    # If loaded from workspace, also copy to Packages dir for GitHub Pages
    if source == fd_path:
        try:
            import shutil
            shutil.copy2(fd_path, local_copy_path)
            print(f"Copied future_directions.json to Packages/ ({len(directions)} directions)")
        except Exception as e:
            print(f"Warning: failed to copy future_directions.json: {e}")

    # Filter out completed/pruned directions (no need to ship stale data)
    directions = [d for d in directions if d.get("status") not in ("completed", "pruned")]

    # Transform to display-friendly format, sorted by priority descending
    display_dirs = []
    for d in directions:
        display_dirs.append({
            "id": d.get("id", ""),
            "title": d.get("title", ""),
            "description": d.get("description", ""),
            "domains": d.get("domains", []),
            "priority_score": d.get("priority_score", 0),
            "status": d.get("status", "available"),
            "research_mode": d.get("research_mode", ""),
            "source_exp_id": d.get("source_exp_id", ""),
            "consumed_by_exp_id": d.get("consumed_by_exp_id", ""),
            "timestamp": d.get("timestamp", ""),
        })

    display_dirs.sort(key=lambda x: (-x["priority_score"], x.get("id", "")))

    fd_js = f"""

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = {json.dumps(display_dirs, indent=2, sort_keys=True)};
"""
    with open(fd_js_path, 'w', encoding='utf-8') as f:
        f.write(fd_js)

    print(f"Wrote FUTURE_DIRECTIONS to future_directions.js ({len(display_dirs)} directions)")


if __name__ == "__main__":
    update_index()