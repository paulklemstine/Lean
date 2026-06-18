import sqlite3
import os
import shutil
import re
import json
import time
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

db_path = Path("/home/raver1975/lean/Aether/.aether_workspace/archive_db/catalog.sqlite")
blobs_dir = Path("/home/raver1975/lean/Aether/.aether_workspace/archive_db/blobs")
output_dir = Path("/home/raver1975/lean/Aether/extracted_markdown")

def sanitize_filename(name):
    # Keep only alphanumeric, dots, dashes, and underscores
    return re.sub(r'[^a-zA-Z0-9._-]', '_', name)

def get_blob_path(file_hash):
    return blobs_dir / file_hash[0:2] / file_hash[2:4] / file_hash

def copy_file(args):
    file_hash, representative_path, total_occurrences = args
    src_path = get_blob_path(file_hash)
    if not src_path.exists():
        return False, file_hash, "Blob not found"
    
    basename = os.path.basename(representative_path)
    if not basename.lower().endswith(".md"):
        basename += ".md"
    
    clean_basename = sanitize_filename(basename)
    clean_name = f"{file_hash[:12]}_{clean_basename}"
    
    subfolder = output_dir / clean_basename
    subfolder.mkdir(exist_ok=True)
    dst_path = subfolder / clean_name
    
    # Idempotent check: skip copy if file already exists with correct size
    if dst_path.exists() and dst_path.stat().st_size == src_path.stat().st_size:
        return True, file_hash, None
        
    try:
        shutil.copy2(src_path, dst_path)
        return True, file_hash, None
    except Exception as e:
        return False, file_hash, str(e)

def main():
    print("Connecting to database...")
    if not db_path.exists():
        print(f"Database not found at {db_path}")
        return

    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row

    # Query all markdown files in the system and group by file_hash
    print("Querying markdown file mappings...")
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            file_hash, 
            path_inside_archive,
            project_id,
            role
        FROM project_files
        WHERE path_inside_archive LIKE '%.md'
    """)
    
    rows = cursor.fetchall()
    print(f"Found {len(rows)} total markdown mappings in database.")

    # Group occurrences by file_hash
    md_by_hash = {}
    for r in rows:
        h = r["file_hash"]
        path = r["path_inside_archive"]
        pid = r["project_id"]
        role = r["role"]
        
        if h not in md_by_hash:
            md_by_hash[h] = {
                "hash": h,
                "representative_path": path,
                "occurrences": []
            }
        md_by_hash[h]["occurrences"].append({
            "project_id": pid,
            "path": path,
            "role": role
        })

    unique_count = len(md_by_hash)
    print(f"Identified {unique_count} unique markdown files.")

    # Calculate total size of unique markdown files
    cursor.execute("""
        SELECT hash, size FROM files 
        WHERE hash IN (SELECT DISTINCT file_hash FROM project_files WHERE path_inside_archive LIKE '%.md')
    """)
    sizes = {r["hash"]: r["size"] for r in cursor.fetchall()}
    total_size_bytes = sum(sizes.values())
    print(f"Total uncompressed size of unique markdown files: {total_size_bytes / (1024*1024):.2f} MB")

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"Output directory created/verified at: {output_dir}")

    # Prepare copy tasks
    tasks = []
    for h, info in md_by_hash.items():
        tasks.append((h, info["representative_path"], len(info["occurrences"])))

    # Copy files in parallel to speed up I/O
    print(f"Extracting {unique_count} unique markdown files using thread pool...")
    t0 = time.time()
    success_count = 0
    failures = []
    
    with ThreadPoolExecutor(max_workers=16) as executor:
        results = executor.map(copy_file, tasks)
        for success, h, err in results:
            if success:
                success_count += 1
            else:
                failures.append((h, err))

    elapsed = time.time() - t0
    print(f"Extraction complete in {elapsed:.2f}s.")
    print(f"Successfully extracted: {success_count}/{unique_count} files.")
    
    if failures:
        print(f"Failed to extract {len(failures)} files. Examples:")
        for h, err in failures[:5]:
            print(f"  - Hash {h[:8]}: {err}")

    # Write manifest file mapping hashes to project usages
    manifest_path = output_dir / "manifest.json"
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(md_by_hash, f, indent=2)
    print(f"Manifest mapping written to {manifest_path}")

if __name__ == "__main__":
    main()
