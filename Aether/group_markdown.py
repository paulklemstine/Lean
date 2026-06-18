import os
import json
import re
from pathlib import Path

output_dir = Path("/home/raver1975/lean/Aether/extracted_markdown")
manifest_path = output_dir / "manifest.json"

# Target bucket folders
buckets = {
    "aristotle_summaries": output_dir / "aristotle_summaries",
    "readmes": output_dir / "readmes",
    "articles": output_dir / "articles",
    "research_papers": output_dir / "research_papers",
    "future_directions": output_dir / "future_directions",
    "discussions": output_dir / "discussions",
    "prompts": output_dir / "prompts",
    "other": output_dir / "other"
}

def classify_file(basename, path):
    name_lower = basename.lower()
    path_lower = path.lower()
    
    # 1. Aristotle Summaries
    if "aristotle_summary" in name_lower or "aristotle_summary" in path_lower:
        return "aristotle_summaries"
    # 2. Prompts
    elif "prompt" in name_lower:
        return "prompts"
    # 3. READMEs
    elif "readme" in name_lower:
        return "readmes"
    # 4. Future Research & Directions
    elif (
        "future_directions" in name_lower or 
        "future_research" in name_lower or
        "research_directions" in name_lower or 
        "direction_" in name_lower or 
        "short_term" in name_lower or 
        "long_term" in name_lower
    ):
        return "future_directions"
    # 5. Articles (Scientific American, ARTICLE.md, etc.)
    elif (
        "article" in name_lower or 
        "scientific_american" in name_lower or 
        "scientificamerican" in name_lower or 
        "sciam" in name_lower
    ):
        return "articles"
    # 6. Research Papers, Notes & Reports
    elif (
        "research" in name_lower or 
        "paper" in name_lower or 
        "report" in name_lower or 
        "notes" in name_lower
    ):
        return "research_papers"
    # 7. Discussions
    elif "discussion" in name_lower:
        return "discussions"
    # 8. Other
    else:
        return "other"

def sanitize_filename(name):
    return re.sub(r'[^a-zA-Z0-9._-]', '_', name)

def main():
    if not manifest_path.exists():
        print(f"Manifest not found at {manifest_path}. Cannot classify.")
        return

    print("Loading manifest...")
    with open(manifest_path, "r", encoding="utf-8") as f:
        md_by_hash = json.load(f)

    # Ensure all bucket directories exist
    for b_path in buckets.values():
        b_path.mkdir(exist_ok=True)

    print("Re-organizing files into refined category buckets...")
    bucket_counts = {k: 0 for k in buckets.keys()}
    moved_count = 0
    skipped_count = 0
    errors = 0

    # Possible directories where files could currently reside
    possible_source_dirs = [
        output_dir,
        output_dir / "aristotle_summaries",
        output_dir / "readmes",
        output_dir / "scientific_american_articles", # Old folder name
        output_dir / "research_papers",
        output_dir / "future_directions",
        output_dir / "discussions",
        output_dir / "prompts",
        output_dir / "other"
    ]

    for file_hash, info in md_by_hash.items():
        representative_path = info["representative_path"]
        basename = os.path.basename(representative_path)
        if not basename.lower().endswith(".md"):
            basename += ".md"
        
        clean_basename = sanitize_filename(basename)
        clean_name = f"{file_hash[:12]}_{clean_basename}"
        
        # Classify the file
        bucket_name = classify_file(clean_basename, representative_path)
        dst_dir = buckets[bucket_name]
        dst_path = dst_dir / clean_name

        # Find file in possible source folders
        src_path = None
        for d in possible_source_dirs:
            p = d / clean_name
            if p.exists():
                src_path = p
                break

        if src_path:
            # If it's already in the correct location, skip
            if src_path == dst_path:
                bucket_counts[bucket_name] += 1
                skipped_count += 1
                continue
            
            try:
                os.rename(src_path, dst_path)
                bucket_counts[bucket_name] += 1
                moved_count += 1
            except Exception as e:
                print(f"Error moving {clean_name} to {bucket_name}: {e}")
                errors += 1
        elif dst_path.exists():
            bucket_counts[bucket_name] += 1
            skipped_count += 1
        else:
            print(f"Warning: File {clean_name} not found in any folder.")
            errors += 1

    # Clean up old empty subfolders in output_dir
    print("Cleaning up old empty subfolders...")
    for p in output_dir.iterdir():
        if p.is_dir() and p.name not in buckets.keys():
            try:
                # Remove if empty
                if not any(p.iterdir()):
                    p.rmdir()
            except Exception as e:
                print(f"Could not remove old folder {p.name}: {e}")

    print("\nCategorization complete!")
    print(f"Moved files: {moved_count}")
    print(f"Already in correct folders: {skipped_count}")
    print("\nFiles per Category:")
    for k, count in bucket_counts.items():
        print(f"  - {k:<30}: {count} files")
    if errors:
        print(f"Errors encountered: {errors}")

if __name__ == "__main__":
    main()
