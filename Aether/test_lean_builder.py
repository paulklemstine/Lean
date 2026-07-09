import os
from pathlib import Path
from lean_catalog_builder import LeanCatalogBuilder

if __name__ == "__main__":
    lean_src = """
import Mathlib.Topology.Basic
import Bridges.Basic
import Geometry.Manifold.Basic
"""
    catalog_root = Path("/home/raver1975/lean/Catalog")
    builder = LeanCatalogBuilder(catalog_root)
    
    project_dir = Path("/tmp/test_lean_project")
    builder.build_lean_project(project_dir, lean_source=lean_src)
    
    print("Files in project dir:")
    for f in project_dir.rglob("*"):
        if f.is_file():
            print(" -", f.relative_to(project_dir))
