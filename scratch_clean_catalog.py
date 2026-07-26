#!/usr/bin/env python3
import os
import re
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

ALLOWED_NON_LEAN_EXACT = {
    "lakefile.toml",
    "lean-toolchain",
    "lake-manifest.json",
    "lakefile.lean"
}

def is_allowed_non_lean(rel_path: Path) -> bool:
    parts = rel_path.parts
    # Allow .lake directory
    if len(parts) > 0 and parts[0] == ".lake":
        return True
    # Allow any Packages or packages directory
    if any(p.lower() == "packages" for p in parts):
        return True
    # Allow top-level exact allowed files
    if len(parts) == 1 and parts[0] in ALLOWED_NON_LEAN_EXACT:
        return True
    return False

def check_sorry(content: str) -> bool:
    # Remove single line comments --
    clean_lines = []
    for line in content.splitlines():
        if "--" in line:
            line = line.split("--")[0]
        clean_lines.append(line)
    cleaned = "\n".join(clean_lines)
    # Match sorry or sorryAx as word token
    if re.search(r'\bsorry\b', cleaned) or re.search(r'\bsorryAx\b', cleaned):
        return True
    return False

def check_truncated(content: str) -> bool:
    if not content.strip():
        return True
    
    # 1. Check for unclosed block comment /- ... -/
    # Count occurrences of /- and -/
    open_comments = len(re.findall(r'/\-', content))
    close_comments = len(re.findall(r'\-/', content))
    if open_comments > close_comments:
        return True

    # 2. Check namespace/section vs end balance
    lines = content.splitlines()
    ns_count = 0
    section_count = 0
    end_count = 0
    
    for l in lines:
        s = l.strip()
        if s.startswith("--") or s.startswith("/-"):
            continue
        if s.startswith("namespace ") or re.match(r'^namespace\b', s):
            ns_count += 1
        elif s.startswith("section ") or s == "section":
            section_count += 1
        elif s.startswith("end ") or s == "end":
            end_count += 1

    # In Lean 4, total (ns + section) should be closed by end blocks
    # If end_count < ns_count + section_count, it's unclosed/truncated
    if (ns_count + section_count) > end_count:
        return True

    # 3. Check trailing line for abrupt truncation
    last_line = ""
    for l in reversed(lines):
        if l.strip() and not l.strip().startswith("--"):
            last_line = l.strip()
            break
    
    # Common trailing operators/keywords indicating incomplete definition
    if last_line.endswith((":=", "by", "with", "+", "*", ",", "(", "{", "[")):
        return True
    
    return False

def main():
    print("[1] Phase 1: Scanning non-Lean files...")
    non_lean_to_remove = []
    lean_files = []

    for root, dirs, files in os.walk(catalog_dir):
        rel_root = Path(root).relative_to(catalog_dir)
        # Skip walking into .lake or Packages for deletion scanning
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue

        for f in files:
            full_path = Path(root) / f
            rel_path = full_path.relative_to(catalog_dir)

            if f.endswith(".lean"):
                lean_files.append(full_path)
            else:
                if not is_allowed_non_lean(rel_path):
                    non_lean_to_remove.append(full_path)

    print(f"Non-Lean files to remove: {len(non_lean_to_remove)}")
    print(f"Lean files to check: {len(lean_files)}")

    # Remove non-lean files
    for p in non_lean_to_remove:
        try:
            p.unlink()
        except Exception as e:
            print(f"Failed to delete {p}: {e}")

    print("[Phase 1 Complete] Deleted non-Lean files.")

    print("\n[2] Phase 2: Static Lean file inspection (sorries & truncation)...")
    sorry_files = []
    truncated_files = []
    clean_lean_files = []

    for p in lean_files:
        try:
            content = p.read_text(encoding="utf-8", errors="replace")
            if check_sorry(content):
                sorry_files.append(p)
            elif check_truncated(content):
                truncated_files.append(p)
            else:
                clean_lean_files.append(p)
        except Exception as e:
            truncated_files.append(p)

    print(f"Lean files containing sorry: {len(sorry_files)}")
    print(f"Lean files truncated: {len(truncated_files)}")
    print(f"Lean files passing static check: {len(clean_lean_files)}")

    # Remove sorry and truncated Lean files
    for p in sorry_files + truncated_files:
        try:
            p.unlink()
        except Exception as e:
            print(f"Failed to delete {p}: {e}")

    print("[Phase 2 Complete] Removed sorry & truncated Lean files.")

if __name__ == "__main__":
    main()
