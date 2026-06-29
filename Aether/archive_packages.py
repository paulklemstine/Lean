import os
import glob
import shutil
import json
import subprocess
from pathlib import Path

def main():
    aether_dir = Path(__file__).parent.resolve()
    repo_root = aether_dir.parent
    
    packages_dir = repo_root / "Packages"
    docs_dir = repo_root / "docs"
    archive_dir = repo_root / "Packages_Archive"
    
    print(f"Repo root: {repo_root}")
    print(f"Packages dir: {packages_dir}")
    print(f"Docs dir: {docs_dir}")
    print(f"Archive dir: {archive_dir}")
    
    # Create archive folders
    archive_packages = archive_dir / "Packages"
    archive_packages.mkdir(parents=True, exist_ok=True)
    archive_viz = archive_dir / "visualizations"
    archive_viz.mkdir(parents=True, exist_ok=True)
    
    archive_docs = archive_dir / "docs"
    archive_docs.mkdir(parents=True, exist_ok=True)
    archive_docs_viz = archive_dir / "docs_visualizations"
    archive_docs_viz.mkdir(parents=True, exist_ok=True)
    
    excluded_files = {"index.json", "package.json", "lineage.json", "future_directions.json", "statement.json", "future_directions_snapshot.json", "catalog_tree.json"}
    
    # 1. Archive from Packages/
    json_files = glob.glob(str(packages_dir / "*.json"))
    for fpath in json_files:
        fname = os.path.basename(fpath)
        if fname not in excluded_files:
            dest = archive_packages / fname
            print(f"Moving {fname} to archive/Packages/")
            shutil.move(fpath, dest)
            
    # Move visualizations
    viz_src = packages_dir / "visualizations"
    if viz_src.exists():
        for item in viz_src.iterdir():
            if item.is_file():
                dest = archive_viz / item.name
                shutil.move(str(item), str(dest))
        print("Archived visualizations from Packages/visualizations/")
        
    # 2. Archive from docs/
    docs_json = glob.glob(str(docs_dir / "*.json"))
    for fpath in docs_json:
        fname = os.path.basename(fpath)
        if fname not in excluded_files:
            dest = archive_docs / fname
            print(f"Moving {fname} to archive/docs/")
            shutil.move(fpath, dest)
            
    # Move docs visualizations
    docs_viz_src = docs_dir / "visualizations"
    if docs_viz_src.exists():
        for item in docs_viz_src.iterdir():
            if item.is_file():
                dest = archive_docs_viz / item.name
                shutil.move(str(item), str(dest))
        print("Archived visualizations from docs/visualizations/")
        
    # 3. Reset lineage.json in both places
    empty_lineage = {"nodes": [], "edges": [], "domain_bridges": []}
    for l_path in [packages_dir / "lineage.json", docs_dir / "lineage.json"]:
        if l_path.exists():
            with open(l_path, "w", encoding="utf-8") as f:
                json.dump(empty_lineage, f, indent=2)
            print(f"Reset lineage.json in {l_path.parent.name}")
        
    # 4. Run update_index.py to rebuild index and reset count to 0
    print("Rebuilding index for Packages...")
    subprocess.run(["python3", "update_index.py"], cwd=str(packages_dir), check=True)
    
    print("Rebuilding index for docs...")
    subprocess.run(["python3", "update_index.py"], cwd=str(docs_dir), check=True)
    
    print("Archiving and reset complete! Package count is now 0.")

if __name__ == "__main__":
    main()
