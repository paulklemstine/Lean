import os
import re
from pathlib import Path

def get_transitive_imports(lean_source: str, catalog_root: Path) -> set:
    visited_files = set()
    queue = [lean_source]
    
    import_regex = re.compile(r'^import\s+([A-Za-z0-9_.]+)', re.MULTILINE)
    
    while queue:
        content = queue.pop(0)
        imports = import_regex.findall(content)
        for imp in imports:
            # Skip Mathlib and standard Lean imports
            if imp.startswith('Mathlib') or imp.startswith('Init') or imp.startswith('Lean'):
                continue
                
            # Convert Module.Path to Module/Path.lean
            rel_path = imp.replace('.', '/') + '.lean'
            file_path = catalog_root / rel_path
            
            if file_path.exists() and file_path not in visited_files:
                visited_files.add(file_path)
                queue.append(file_path.read_text(encoding='utf-8', errors='ignore'))
                
    return visited_files

if __name__ == "__main__":
    lean_src = """
import Mathlib.Topology.Basic
import Packages.Algebra.Basic
import Algebra.Basic
"""
    catalog_root = Path("/home/raver1975/lean/Packages")
    deps = get_transitive_imports(lean_src, catalog_root)
    print("Found dependencies:")
    for d in deps:
        print(" -", d.relative_to(catalog_root))
