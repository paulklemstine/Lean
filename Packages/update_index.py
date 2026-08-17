import os
import glob
import json
import time
import base64
import re
from pathlib import Path

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

def normalize_iso_date(date_str):
    """Normalize any ISO 8601 date string to clean UTC format: YYYY-MM-DDTHH:MM:SSZ."""
    if not date_str:
        return "1970-01-01T00:00:00Z"
    try:
        from datetime import datetime, timezone
        s = str(date_str).strip()
        if s.endswith("Z"):
            s = s[:-1] + "+00:00"
        dt = datetime.fromisoformat(s)
        dt_utc = dt.astimezone(timezone.utc)
        return dt_utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    except Exception:
        return str(date_str)

def load_all_git_creation_dates(catalog_root, target_dir="Packages"):
    """Run a single git log command to extract creation ISO dates for all files."""
    dates = {}
    try:
        import subprocess
        res = subprocess.run(
            ["git", "log", "--diff-filter=A", "--name-only", "--format=COMMIT_DATE:%aI", "--", target_dir],
            capture_output=True, text=True, cwd=catalog_root
        )
        if res.returncode == 0:
            current_date = None
            for line in res.stdout.splitlines():
                line = line.strip()
                if not line:
                    continue
                if line.startswith("COMMIT_DATE:"):
                    current_date = normalize_iso_date(line[len("COMMIT_DATE:"):].strip())
                elif current_date:
                    norm = os.path.normpath(line)
                    dates[norm] = current_date
    except Exception:
        pass
    return dates

def get_creation_date(filename, catalog_root):
    """Get file modification time fallback without running individual git subprocesses."""
    try:
        return time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(os.path.getmtime(filename)))
    except Exception:
        return "1970-01-01T00:00:00Z"

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
        # Not inside a git/Aether repo (e.g. a bare copy of Packages/ or a test
        # temp dir). Index the packages in this directory itself. The previous
        # fallback of script_dir/../.. collapsed to "/" for a shallow path and
        # made the .lean scan below walk the entire filesystem (hang).
        catalog_root = script_dir

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

    # Load all git creation dates in batch for 100% stability and speed
    git_creation_dates = load_all_git_creation_dates(catalog_root, "Packages")

    # Pre-build lean file cache once to avoid O(N) repository traversals inside loop
    lean_file_cache = {}
    for root, dirs, files in os.walk(catalog_root):
        dirs[:] = [d for d in dirs if d not in ('.git', '.lake', 'node_modules', '.aether_workspace', 'build', 'dist', 'visualizations')]
        for fname in files:
            if fname.endswith('.lean') and fname not in lean_file_cache:
                lean_file_cache[fname] = os.path.join(root, fname)

    total_files = len(json_files)
    print(f"Updating index for {total_files} package JSON files...")
    start_time = time.time()

    for idx, f in enumerate(json_files, 1):
        if idx % 25 == 0 or idx == total_files or idx == 1:
            elapsed = time.time() - start_time
            rate = idx / elapsed if elapsed > 0 else 0
            print(f"  [{idx}/{total_files}] Processing package files ({idx*100//total_files}% complete | {rate:.1f} pkgs/sec)...")

        try:
            with open(f, 'r', encoding='utf-8-sig') as file:
                data = json.load(file)
        except Exception as e:
            print(f"Error processing {f}: {e}")
            continue

        # Skip non-package JSON files (e.g. lists, primitives)
        if not isinstance(data, dict):
            print(f"Skipping {f}: not a package object (got {type(data).__name__})")
            continue

        # Determine publish date: prefer the per-package JSON "date" field
        # (when the research was actually done), then git creation date,
        # then filesystem mtime as last resort.
        rel_f = os.path.normpath(os.path.relpath(os.path.abspath(f), catalog_root))
        date_str = normalize_iso_date(data.get("date") or git_creation_dates.get(rel_f) or get_creation_date(f, catalog_root))

        pkg_slug = f.replace('.json', '')

        # Look up quality score by exp_id
        exp_id = data.get("exp_id", "")
        qs_entry = quality_scores.get(exp_id, None) if exp_id else None
        quality_score = (qs_entry["quality_score"] if qs_entry else None) or data.get("quality_score", None)
        quality_label = qs_entry["quality"] if qs_entry else "unrated"
        # Compute quality tier: gold (Q>=0.9), silver (Q>=0.7), bronze (Q<0.7)
        if quality_score is None:
            quality_tier = "unrated"
        elif quality_score >= 0.90:
            quality_tier = "gold"
        elif quality_score >= 0.70:
            quality_tier = "silver"
        else:
            quality_tier = "bronze"

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

        # Embed actual Lean 4 code into lean_proofs entries that only have file paths or strings
        if data.get("lean_proofs"):
            lp = data["lean_proofs"]
            normalized_lp = []
            if isinstance(lp, list):
                for idx_lp, entry in enumerate(lp):
                    if isinstance(entry, str):
                        if entry.endswith('.lean') or '/' in entry:
                            fpath = entry
                            code = ""
                        else:
                            fpath = f"Proof_{idx_lp+1}.lean"
                            code = entry
                        entry = {"file": fpath, "name": fpath, "code": code}
                    if isinstance(entry, dict):
                        if not entry.get("code"):
                            fpath = entry.get("file", "") or entry.get("name", "")
                            if fpath and (fpath.endswith('.lean') or '/' in fpath):
                                candidates = [fpath]
                                if fpath.startswith("Catalog/"):
                                    candidates.append(fpath[len("Catalog/"):])
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
                                if not entry.get("code") and basename in lean_file_cache:
                                    full_path = lean_file_cache[basename]
                                    if os.path.isfile(full_path):
                                        with open(full_path, 'r', encoding='utf-8', errors='ignore') as lf:
                                            entry["code"] = lf.read()
                        normalized_lp.append(entry)
                data["lean_proofs"] = normalized_lp
            elif isinstance(lp, str):
                if lp.endswith('.lean') or '/' in lp:
                    entry = {"file": lp, "name": lp, "code": ""}
                    basename = os.path.basename(lp)
                    if basename in lean_file_cache:
                        full_path = lean_file_cache[basename]
                        if os.path.isfile(full_path):
                            with open(full_path, 'r', encoding='utf-8', errors='ignore') as lf:
                                entry["code"] = lf.read()
                    data["lean_proofs"] = [entry]

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
            "quality_tier": quality_tier,
        })

        # Lightweight index for lineage links (no big text fields)
        package_db_index[f] = {
            "title": data.get("title", "Untitled Research"),
            "exp_id": data.get("exp_id", ""),
            "source_exp_ids": data.get("source_exp_ids", []),
            "domain": data.get("domain", "General"),
        }

    # Assign package numbers based on deterministic date-ascending order (oldest = 1, newest = N)
    # Primary key: ISO creation date, Secondary key: filename (ensures 100% stable sorting)
    package_index.sort(key=lambda x: (x["date"], x["filename"]))
    for i, pkg in enumerate(package_index):
        pkg["pkg_num"] = i + 1
    # Then sort descending for display (newest first), with filename secondary key
    package_index.sort(key=lambda x: (x["date"], x["filename"]), reverse=True)

    js_content = f"""// AUTO-GENERATED FILE. DO NOT EDIT.
// Lightweight index for sidebar, graph, and lineage links.
// Full package data is loaded on-demand from individual .json files.

window.PACKAGE_INDEX = {json.dumps(package_index, indent=2, sort_keys=True)};

window.PACKAGE_DB_INDEX = {json.dumps(package_db_index, indent=2, sort_keys=True)};
"""

    with open("package_index.js", "w", encoding="utf-8") as out:
        out.write(js_content)

    # Cache-bust the package_index.js <script> tag in index.html so browsers
    # fetch the fresh index (with newly-added packages) instead of a stale
    # cached copy. Version on package count + a timestamp so any rebuild busts.
    import time as _t
    _idx_version = f"{len(json_files)}.{int(_t.time())}"
    _idx_html = os.path.join(script_dir, "index.html")
    if os.path.exists(_idx_html):
        try:
            import re as _re
            _h = open(_idx_html, "r", encoding="utf-8").read()
            _h_new = _re.sub(
                r'<script src="package_index\.js(\?v=[^"]*)?">',
                f'<script src="package_index.js?v={_idx_version}">',
                _h,
            )
            if _h_new != _h:
                open(_idx_html, "w", encoding="utf-8").write(_h_new)
                print(f"Bumped package_index.js cache-bust in index.html -> v={_idx_version}")
        except Exception as _e:
            print(f"Warning: failed to bump index.html cache-bust: {_e}")

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
    append_future_directions(script_dir, os.path.join(script_dir, "future_directions.js"), catalog_root)

    # Generate Catalog tree and sync .lean files for direct linking
    generate_catalog_tree(script_dir, catalog_root)

    # Ensure .nojekyll exists for GitHub Pages
    nojekyll_path = os.path.join(script_dir, ".nojekyll")
    if not os.path.exists(nojekyll_path):
        open(nojekyll_path, 'w').close()
        print("Created .nojekyll for GitHub Pages")

    os.chdir(original_dir)


def generate_catalog_tree(script_dir, catalog_root):
    """
    Scans catalog_root/Catalog for all .lean files, copies them into script_dir/Catalog,
    and writes catalog_tree.json with metadata and declaration lists for direct individual file fetching.
    """
    catalog_source = os.path.join(catalog_root, "Catalog")
    if not os.path.exists(catalog_source):
        print(f"Catalog directory not found at {catalog_source}")
        return

    catalog_dest = os.path.join(script_dir, "Catalog")
    os.makedirs(catalog_dest, exist_ok=True)

    tree = []
    copied = 0
    decl_regex = re.compile(r'^(?:theorem|lemma|def|example)\s+([a-zA-Z0-9_\']+)', re.MULTILINE)

    stop_words = {"of", "in", "is", "to", "and", "or", "if", "as", "at", "by", "on", "it", "be", "so", "we", "do", "no", "my", "an", "me", "us", "up", "the", "a"}
    for root, dirs, files in os.walk(catalog_source):
        dirs[:] = [d for d in dirs if not d.startswith(".") and d != ".lake"]
        for f in files:
            if f.endswith(".lean") and not f.startswith("."):
                abs_src = os.path.join(root, f)
                rel_p = os.path.relpath(abs_src, catalog_source).replace("\\", "/")
                sz = os.path.getsize(abs_src)
                
                try:
                    with open(abs_src, 'r', encoding='utf-8', errors='ignore') as lf:
                        code = lf.read()
                    raw_decls = decl_regex.findall(code)
                    decls = [d for d in raw_decls if len(d) > 2 and d.lower() not in stop_words]
                except Exception:
                    decls = []

                tree.append({
                    "path": rel_p,
                    "name": f,
                    "size": sz,
                    "decls": decls
                })

                abs_dest = os.path.join(catalog_dest, rel_p)
                os.makedirs(os.path.dirname(abs_dest), exist_ok=True)
                if not os.path.exists(abs_dest) or os.path.getmtime(abs_src) > os.path.getmtime(abs_dest):
                    import shutil
                    shutil.copy2(abs_src, abs_dest)
                    copied += 1

    tree.sort(key=lambda x: x["path"])

    tree_json_path = os.path.join(script_dir, "catalog_tree.json")
    with open(tree_json_path, 'w', encoding='utf-8') as tf:
        json.dump(tree, tf, separators=(',', ':'))

    tree_js_path = os.path.join(script_dir, "catalog_tree.js")
    with open(tree_js_path, 'w', encoding='utf-8') as jsf:
        jsf.write(f"window.CATALOG_TREE = {json.dumps(tree, separators=(',', ':'))};")

    print(f"Generated catalog_tree.json ({os.path.getsize(tree_json_path)/1024:.0f} KB) with {len(tree)} files from Catalog/ (copied/synced {copied} files)")


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


def append_future_directions(script_dir, fd_js_path, catalog_root=None):
    """Read future_directions.json and write window.FUTURE_DIRECTIONS to a separate
    future_directions.js file (lazy-loaded on demand, not in the initial page load).
    """
    # Try Aether workspace (local dev)
    repo_root = catalog_root if catalog_root else os.path.abspath(os.path.join(script_dir, ".."))
    fd_path = os.path.join(repo_root, "Aether", ".aether_workspace", "future_directions.json")
    if not os.path.exists(fd_path):
        # fallback: older relative depth (Catalog/Applications/Packages/) — keep for safety
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

    # Load inflight jobs mapping to lookup phase for in_progress directions
    inflight_phases = {}
    inflight_paths = [
        os.path.join(repo_root, "Aether", ".aether_workspace", "inflight_jobs.json"),
        os.path.join(script_dir, "aether_status", "inflight_jobs.json"),
        os.path.abspath(os.path.join(script_dir, "..", "docs", "aether_status", "inflight_jobs.json")),
    ]
    for ip in inflight_paths:
        if os.path.exists(ip):
            try:
                with open(ip, 'r', encoding='utf-8') as f:
                    ij_data = json.load(f)
                items = []
                if isinstance(ij_data, list):
                    items = ij_data
                elif isinstance(ij_data, dict):
                    items = [j for j in ij_data.values() if isinstance(j, dict)]
                for j in items:
                    if isinstance(j, dict):
                        ph = j.get("phase") or "A"
                        if j.get("direction_id"):
                            inflight_phases[j["direction_id"]] = ph
                        if j.get("exp_id"):
                            inflight_phases[j["exp_id"]] = ph
                        if j.get("job_id"):
                            inflight_phases[j["job_id"]] = ph
            except Exception:
                pass

    # Filter out completed/pruned directions (no need to ship stale data)
    directions = [d for d in directions if d.get("status") not in ("completed", "pruned")]

    # Transform to display-friendly format, sorted by priority descending
    display_dirs = []
    for d in directions:
        d_status = d.get("status", "available")
        d_id = d.get("id", "")
        d_exp = d.get("consumed_by_exp_id", "")
        phase = d.get("phase")
        if not phase and d_status == "in_progress":
            phase = inflight_phases.get(d_id) or inflight_phases.get(d_exp) or "A"

        item = {
            "id": d_id,
            "title": d.get("title", ""),
            "description": d.get("description", ""),
            "domains": d.get("domains", []),
            "priority_score": d.get("priority_score", 0),
            "status": d_status,
            "research_mode": d.get("research_mode", ""),
            "source_exp_id": d.get("source_exp_id", ""),
            "consumed_by_exp_id": d_exp,
            "timestamp": d.get("timestamp", ""),
        }
        if phase:
            item["phase"] = phase
        display_dirs.append(item)

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