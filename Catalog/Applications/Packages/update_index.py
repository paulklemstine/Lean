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

    json_files = [f for f in glob.glob("*.json") if f not in ("index.json", "package.json")]

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
            "date": date_str
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
    os.chdir(original_dir)

if __name__ == "__main__":
    update_index()