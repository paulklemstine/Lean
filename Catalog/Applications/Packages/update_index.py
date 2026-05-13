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
        rel_path = os.path.join("Catalog", "Applications", "Packages", filename)
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

def update_index():
    original_dir = os.getcwd()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # Find the Catalog root (grandparent of Packages dir) for git commands
    catalog_root = os.path.abspath(os.path.join(script_dir, "..", ".."))

    json_files = [f for f in glob.glob("*.json") if f not in ("index.json", "package.json", "lineage.json")]

    viz_dir = os.path.join(script_dir, "visualizations")
    os.makedirs(viz_dir, exist_ok=True)

    package_index = []
    package_db = {}
    total_viz_extracted = 0

    for f in json_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                data = json.load(file)
        except Exception as e:
            print(f"Error processing {f}: {e}")
            continue

        # Use date from JSON package (populated during AETHER integration)
        # Fall back to git creation date, then file mtime
        date_str = data.get("date") or get_creation_date(f, catalog_root)

        pkg_slug = f.replace('.json', '')

        # Extract visualizations into real files, replace data with file paths
        if data.get("visualizations"):
            for i, viz in enumerate(data["visualizations"]):
                viz_data = viz.get("data", "")
                if viz_data:
                    rel_path = extract_visualization(
                        viz_data, viz.get("name", ""), pkg_slug, i, viz_dir
                    )
                    if rel_path:
                        viz["file"] = rel_path
                        # Remove the bulky data from the in-memory copy
                        # that goes into packages_db.js
                        del viz["data"]
                        total_viz_extracted += 1

        # Also extract algorithms code into separate files if present
        if data.get("algorithms"):
            for i, alg in enumerate(data["algorithms"]):
                alg_code = alg.get("code", "")
                if alg_code:
                    safe_name = sanitize_filename(alg.get("name", ""), 40) or f"algo_{i}"
                    alg_filename = f"{pkg_slug}_{safe_name}.py"
                    alg_path = os.path.join(viz_dir, alg_filename)
                    with open(alg_path, 'w', encoding='utf-8') as af:
                        af.write(alg_code)
                    alg["code_file"] = f"visualizations/{alg_filename}"
                    # Keep code inline in the JSON for Pyodide — it needs it
                    # at runtime. But we've also saved it as a file.

        package_index.append({
            "filename": f,
            "title": data.get("title", "Untitled Research"),
            "domain": data.get("domain", "General"),
            "date": date_str,
            "exp_id": data.get("exp_id", ""),
        })

        package_db[f] = data

    package_index.sort(key=lambda x: x["date"], reverse=True)

    js_content = f"""// AUTO-GENERATED FILE. DO NOT EDIT.
// This file bundles all JSON packages so they can be loaded from file:// without CORS issues.
// Visualizations have been extracted to the visualizations/ directory as real files.
// Each visualization entry has a "file" field pointing to the extracted image.

window.PACKAGE_INDEX = {json.dumps(package_index, indent=2)};

window.PACKAGE_DB = {json.dumps(package_db, indent=2)};
"""

    with open("packages_db.js", "w", encoding="utf-8") as out:
        out.write(js_content)

    # Calculate sizes
    db_size = os.path.getsize("packages_db.js")
    viz_size = sum(
        os.path.getsize(os.path.join(viz_dir, f))
        for f in os.listdir(viz_dir)
        if os.path.isfile(os.path.join(viz_dir, f))
    )

    print(f"Successfully bundled {len(json_files)} packages into packages_db.js ({db_size/1024:.0f} KB)")
    print(f"Extracted {total_viz_extracted} visualizations into visualizations/ ({viz_size/1024:.0f} KB)")

    # Generate knowledge graph data
    generate_graph_data(script_dir)

    # Append future research directions
    append_future_directions(script_dir, os.path.join(script_dir, "packages_db.js"))

    os.chdir(original_dir)


def generate_graph_data(script_dir):
    """Read lineage.json and append window.PACKAGE_GRAPH to packages_db.js."""
    lineage_path = os.path.join(script_dir, "lineage.json")
    db_path = os.path.join(script_dir, "packages_db.js")

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
            print(f"Loaded lineage.json: {len(graph_data.get('nodes', []))} nodes, {len(graph_data.get('edges', []))} edges")
        except Exception as e:
            print(f"Warning: failed to load lineage.json: {e}")

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
            nodes.append({
                "id": slug,
                "title": pkg.get("title", slug),
                "domain": domain_str,
                "primary_domain": pd,
                "shape": DOMAIN_SHAPES.get(pd, "icosahedron"),
                "date": pkg.get("date", ""),
                "hue": slug_to_hue(slug),
            })
        graph_data = {"nodes": nodes, "edges": []}
    else:
        # Enrich nodes with shape and hue if missing
        for node in graph_data.get("nodes", []):
            if "shape" not in node:
                pd = node.get("primary_domain", primary_domain(node.get("domain", "")))
                node["shape"] = DOMAIN_SHAPES.get(pd, "icosahedron")
            if "hue" not in node:
                node["hue"] = slug_to_hue(node.get("id", ""))

    # Append to packages_db.js
    graph_js = f"""

// Knowledge Graph Data (auto-generated from lineage.json)
window.PACKAGE_GRAPH = {json.dumps(graph_data, indent=2)};
"""
    with open(db_path, 'a', encoding='utf-8') as f:
        f.write(graph_js)

    print(f"Appended PACKAGE_GRAPH to packages_db.js ({len(graph_data.get('nodes', []))} nodes, {len(graph_data.get('edges', []))} edges)")


def append_future_directions(script_dir, db_path):
    """Read future_directions.json and append window.FUTURE_DIRECTIONS to packages_db.js."""
    fd_path = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "Aether", ".aether_workspace", "future_directions.json"))
    if not os.path.exists(fd_path):
        print(f"No future_directions.json found at {fd_path}, skipping")
        return

    try:
        with open(fd_path, 'r', encoding='utf-8') as f:
            directions = json.load(f)
    except Exception as e:
        print(f"Warning: failed to load future_directions.json: {e}")
        return

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

    display_dirs.sort(key=lambda x: x["priority_score"], reverse=True)

    fd_js = f"""

// Future Research Directions (auto-generated from future_directions.json)
window.FUTURE_DIRECTIONS = {json.dumps(display_dirs, indent=2)};
"""
    with open(db_path, 'a', encoding='utf-8') as f:
        f.write(fd_js)

    print(f"Appended FUTURE_DIRECTIONS to packages_db.js ({len(display_dirs)} directions)")


if __name__ == "__main__":
    update_index()