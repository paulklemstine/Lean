import os
import re
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

def check_sorry(content: str) -> bool:
    clean_lines = []
    for line in content.splitlines():
        if "--" in line:
            line = line.split("--")[0]
        clean_lines.append(line)
    cleaned = "\n".join(clean_lines)
    if re.search(r'\bsorry\b', cleaned) or re.search(r'\bsorryAx\b', cleaned):
        return True
    return False

def check_truncated(content: str) -> bool:
    if not content.strip():
        return True
    
    open_comments = len(re.findall(r'/\-', content))
    close_comments = len(re.findall(r'\-/', content))
    if open_comments > close_comments:
        return True

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

    if (ns_count + section_count) > end_count:
        return True

    last_line = ""
    for l in reversed(lines):
        if l.strip() and not l.strip().startswith("--"):
            last_line = l.strip()
            break
    
    if last_line.endswith((":=", "by", "with", "+", "*", ",", "(", "{", "[")):
        return True
    
    return False

lean_files = []
for root, dirs, files in os.walk(catalog_dir):
    rel_root = Path(root).relative_to(catalog_dir)
    if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
        continue
    for f in files:
        if f.endswith(".lean"):
            lean_files.append(Path(root) / f)

print(f"Total Lean files to scan: {len(lean_files)}")

sorry_count = 0
trunc_count = 0
kept_count = 0

for p in lean_files:
    try:
        content = p.read_text(encoding="utf-8", errors="replace")
        if check_sorry(content):
            p.unlink()
            sorry_count += 1
        elif check_truncated(content):
            p.unlink()
            trunc_count += 1
        else:
            kept_count += 1
    except Exception:
        try:
            p.unlink()
            trunc_count += 1
        except Exception:
            pass

print(f"Removed {sorry_count} Lean files containing sorries.")
print(f"Removed {trunc_count} truncated Lean files.")
print(f"Remaining Lean files after static cleaning: {kept_count}")
