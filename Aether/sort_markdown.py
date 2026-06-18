import os
import json
import re
from pathlib import Path

output_dir = Path("/home/raver1975/lean/Aether/extracted_markdown")
manifest_path = output_dir / "manifest.json"

def sanitize_filename(name):
    return re.sub(r'[^a-zA-Z0-9._-]', '_', name)

def main():
    if not manifest_path.exists():
        print(f"Manifest not found at {manifest_path}. Cannot sort.")
        return

    print("Loading manifest...")
    with open(manifest_path, "r", encoding="utf-8") as f:
        md_by_hash = json.load(f)

    print(f"Sorting {len(md_by_hash)} unique files into subdirectories...")
    moved_count = 0
    skipped_count = 0
    errors = 0

    for file_hash, info in md_by_hash.items():
        representative_path = info["representative_path"]
        basename = os.path.basename(representative_path)
        if not basename.lower().endswith(".md"):
            basename += ".md"
        
        clean_basename = sanitize_filename(basename)
        clean_name = f"{file_hash[:12]}_{clean_basename}"
        
        # Determine paths
        subfolder = output_dir / clean_basename
        src_path = output_dir / clean_name
        dst_path = subfolder / clean_name

        # Create subfolder if it doesn't exist
        subfolder.mkdir(exist_ok=True)

        # Move the file if it exists in the root directory
        if src_path.exists():
            try:
                os.rename(src_path, dst_path)
                moved_count += 1
            except Exception as e:
                print(f"Error moving {clean_name}: {e}")
                errors += 1
        elif dst_path.exists():
            skipped_count += 1
        else:
            # File might be in another folder or not extracted
            errors += 1

    print("Sorting complete.")
    print(f"Moved to subfolders: {moved_count}")
    print(f"Already sorted: {skipped_count}")
    if errors:
        print(f"Errors or missing files: {errors}")

if __name__ == "__main__":
    main()
