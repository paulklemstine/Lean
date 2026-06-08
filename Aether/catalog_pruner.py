#!/usr/bin/env python3
"""CatalogPruner: unified catalog pruning module.

Groups Lean 4 files by semantic similarity, round-robins through similarity
groups, and queries Pi-Agent to select the canonical file and prune duplicate,
trivial, or redundant theorems.
"""

import json
import os
import re
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Set, Tuple, Any, Optional
import sys

# Ensure parent directory is in path for imports
sys.path.insert(0, str(Path(__file__).parent))

from catalog_analyzer import CatalogAnalyzer
from pi_agent_client import PiAgentClient


class CatalogPruner:
    def __init__(self, catalog_root: Path, pi_agent: PiAgentClient, workspace: Path):
        self.catalog_root = Path(catalog_root)
        self.pi_agent = pi_agent
        self.workspace = Path(workspace)
        self.state_file = self.workspace / "prune_state.json"
        self.analyzer = CatalogAnalyzer(self.catalog_root)

    def get_prune_candidates(self) -> List[Dict[str, Any]]:
        """Scan catalog for prune candidates, including Speculative, but excluding FINAL/lake."""
        self.analyzer.invalidate_cache()
        summaries = self.analyzer.scan()
        
        candidates = []
        skip_dirs = {"FINAL", ".lake", "ResearchOutput", "Applications"}
        
        for s in summaries:
            # Check if any path component is skipped
            parts = Path(s.relative_path).parts
            if any(p in skip_dirs for p in parts):
                continue
                
            abs_path = self.catalog_root / s.relative_path
            if not abs_path.exists():
                continue
                
            # Read content to check tactics and triviality
            try:
                content = abs_path.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue
                
            lines = content.split("\n")
            line_count = len([l for l in lines if l.strip() and not l.strip().startswith("--")])
            has_sorry = "sorry" in content
            
            # Count theorems/lemmas
            theorem_count = len(re.findall(r"^\s*(theorem|lemma)\s", content, re.MULTILINE))
            
            # Check for deep proofs
            has_deep_proof = bool(re.search(r"\b(induction|rcases|by_contra|omega|linarith|field_simp|ring_nf)\b", content))
            is_trivial_only = not has_deep_proof and bool(re.search(r"\b(trivial|simp|rfl|decide|native_decide)\b", content))
            
            candidates.append({
                "path": s.relative_path,
                "name": abs_path.name,
                "domain": s.domain,
                "lines": line_count,
                "sorries": has_sorry,
                "theorems": theorem_count,
                "declarations": s.declarations,
                "deep_proof": has_deep_proof,
                "trivial_only": is_trivial_only,
                "abs_path": abs_path,
                "content_preview": content[:1500],
            })
            
        return candidates

    def group_by_similarity(self, candidates: List[Dict[str, Any]]) -> List[List[Dict[str, Any]]]:
        """Group candidates into small disjoint clusters of semantically similar files (max size 5)."""
        # 1. Initialize components (each file in its own list)
        path_to_candidate = {c["path"]: c for c in candidates}
        # Parent pointer for Union-Find with size tracking
        parent = {p: p for p in path_to_candidate}
        size = {p: 1 for p in path_to_candidate}
        
        def find(p):
            root = p
            while root != parent[root]:
                root = parent[root]
            # path compression
            curr = p
            while curr != root:
                nxt = parent[curr]
                parent[curr] = root
                curr = nxt
            return root
            
        def union(p1, p2):
            r1 = find(p1)
            r2 = find(p2)
            if r1 != r2:
                # Constrain component size to max 5
                if size[r1] + size[r2] <= 5:
                    parent[r2] = r1
                    size[r1] += size[r2]
                    return True
            return False

        # 2. Build candidate edges with weights
        edges = []
        
        # declaration mapping
        decl_to_files = {}
        for c in candidates:
            for decl in c["declarations"]:
                if len(decl) < 5 or decl.lower() in ("intro", "elim", "step", "helper", "proof", "init", "cond"):
                    continue
                decl_to_files.setdefault(decl.lower(), []).append(c["path"])
                
        # Shared declarations edges (weight = number of shared declarations)
        from collections import Counter
        pair_counts = Counter()
        for decl, files in decl_to_files.items():
            # If the declaration is too common (> 8 files), ignore it as it's likely a generic helper name
            if len(files) < 2 or len(files) > 8:
                continue
            for i in range(len(files)):
                for j in range(i + 1, len(files)):
                    p1, p2 = sorted([files[i], files[j]])
                    pair_counts[(p1, p2)] += 1
                    
        for (p1, p2), count in pair_counts.items():
            edges.append((count * 10, p1, p2))
            
        # Filename similarity edges (weight = length of shared token)
        def get_tokens(name: str) -> Set[str]:
            words = re.sub(r'([A-Z])', r' \1', name.replace('.lean', '')).lower()
            words = re.split(r'[^a-zA-Z0-9]', words)
            return {w for w in words if len(w) >= 5}
            
        for i in range(len(candidates)):
            tokens_i = get_tokens(candidates[i]["name"])
            if not tokens_i:
                continue
            for j in range(i + 1, len(candidates)):
                if candidates[i]["domain"] != candidates[j]["domain"]:
                    continue
                tokens_j = get_tokens(candidates[j]["name"])
                shared = tokens_i & tokens_j
                specific_shared = {t for t in shared if t not in ("basic", "core", "test", "main", "spec", "math")}
                if specific_shared:
                    max_len = max(len(t) for t in specific_shared)
                    p1, p2 = sorted([candidates[i]["path"], candidates[j]["path"]])
                    edges.append((max_len, p1, p2))

        # 3. Sort edges by weight descending and merge
        edges.sort(key=lambda x: x[0], reverse=True)
        for weight, p1, p2 in edges:
            union(p1, p2)
            
        # 4. Extract components (groups)
        from collections import defaultdict
        components = defaultdict(list)
        for p in path_to_candidate:
            root = find(p)
            components[root].append(path_to_candidate[p])
            
        # Convert to list of lists
        groups = list(components.values())
        return groups


    def sort_groups_deterministically(self, groups: List[List[Dict[str, Any]]]) -> List[List[Dict[str, Any]]]:
        """Sort groups and files inside groups deterministically to ensure stable indexing."""
        for g in groups:
            g.sort(key=lambda c: c["path"])
        # Sort groups by size desc, then by first file path alphabetically
        groups.sort(key=lambda g: (-len(g), g[0]["path"]))
        return groups

    def load_prune_state(self) -> int:
        """Load the last processed group index from state file."""
        if self.state_file.exists():
            try:
                data = json.loads(self.state_file.read_text(encoding="utf-8"))
                return data.get("last_group_idx", 0)
            except Exception:
                pass
        return 0

    def save_prune_state(self, last_group_idx: int) -> None:
        """Save the last processed group index to state file."""
        try:
            self.state_file.parent.mkdir(parents=True, exist_ok=True)
            self.state_file.write_text(json.dumps({
                "last_group_idx": last_group_idx,
                "updated_at": datetime.now().isoformat()
            }, indent=2), encoding="utf-8")
        except Exception as e:
            print(f"[Prune] Warning: failed to save state: {e}")

    def select_batch(self, groups: List[List[Dict[str, Any]]], target_file_count: int = 15) -> Tuple[List[List[Dict[str, Any]]], int]:
        """Select a set of groups starting from the last index to reach target_file_count."""
        if not groups:
            return [], 0
            
        start_idx = self.load_prune_state()
        if start_idx >= len(groups):
            start_idx = 0
            
        selected_groups = []
        collected_files = 0
        curr_idx = start_idx
        
        while collected_files < target_file_count:
            group = groups[curr_idx]
            selected_groups.append(group)
            collected_files += len(group)
            curr_idx = (curr_idx + 1) % len(groups)
            if curr_idx == start_idx:
                break # Wrapped around completely
                
        return selected_groups, curr_idx

    def clean_broken_symlinks(self) -> int:
        """Find and remove broken symlinks in the FINAL/ directory."""
        final_dir = self.catalog_root / "FINAL"
        if not final_dir.exists():
            return 0
        removed = 0
        for f in list(final_dir.rglob("*")):
            if f.is_symlink():
                try:
                    target = f.readlink()
                    abs_target = (f.parent / target).resolve()
                    if not abs_target.exists():
                        f.unlink()
                        removed += 1
                except Exception:
                    pass
        return removed

    def rebuild_final_main(self) -> None:
        """Rebuild Catalog/Main.lean from all files in FINAL/."""
        final_dir = self.catalog_root / "FINAL"
        imports = []
        for f in sorted(final_dir.rglob("*.lean")):
            if f.name == "Main.lean":
                continue
            # Double check that if it's a symlink, it isn't broken
            if f.is_symlink():
                try:
                    target = f.readlink()
                    if not (f.parent / target).resolve().exists():
                        continue
                except Exception:
                    continue
            rel = f.relative_to(self.catalog_root)
            import_path = str(rel.with_suffix("")).replace("/", ".")
            imports.append(f"import {import_path}")

        main_path = self.catalog_root / "Main.lean"
        if imports:
            header = (
                "/- Aether FINAL Catalog\n"
                f"A curated collection of {len(imports)} of the highest-quality\n"
                "formally verified mathematical results from the Aether engine.\n"
                "Sorry-free. No placeholders. Auto-maintained.\n"
                f"Total files: {len(imports)}\n"
                "-/\n"
            )
            main_path.write_text(header + "\n".join(imports) + "\n", encoding="utf-8")
        else:
            # Write empty Main.lean
            main_path.write_text("/- Empty Catalog -/\n", encoding="utf-8")

    def cleanup_empty_dirs(self) -> int:
        """Remove empty directories in the catalog tree."""
        cleaned = 0
        for d in sorted(self.catalog_root.rglob("*"), reverse=True):
            if d.is_dir() and not any(d.iterdir()):
                try:
                    d.rmdir()
                    cleaned += 1
                except Exception:
                    pass
        return cleaned

    def immortalize_file(self, candidate: Dict[str, Any]) -> None:
        """Symlink a .lean file into the FINAL directory (no duplicate bytes)."""
        src = Path(candidate["abs_path"])
        domain = candidate["domain"]
        dest_dir = self.catalog_root / "FINAL" / domain
        dest_dir.mkdir(parents=True, exist_ok=True)
        dest = dest_dir / src.name
        if not dest.exists():
            try:
                # Create a relative symlink from FINAL back to the canonical file
                rel_src = os.path.relpath(str(src), str(dest_dir))
                dest.symlink_to(rel_src)
                print(f"[Prune] Immortalized {candidate['path']} -> FINAL/{domain}/{src.name}")
            except Exception as e:
                print(f"[Prune] Failed to immortalize {candidate['path']}: {e}")

    def prune(self, target_remove_count: int = 10, dry_run: bool = False) -> Dict[str, Any]:
        """Run the pruning workflow."""
        candidates = self.get_prune_candidates()
        print(f"[Prune] Scanned {len(candidates)} total candidate .lean files")
        
        # 1. Clear obvious junk immediately to save LLM budget
        # We define stubs: < 15 lines AND 0 theorems
        # Or stubs: < 10 lines AND trivial-only
        auto_removed = []
        retained_candidates = []
        for c in candidates:
            is_empty_stub = c["lines"] < 15 and c["theorems"] == 0
            is_tiny_trivial = c["lines"] < 10 and c["trivial_only"]
            
            if is_empty_stub or is_tiny_trivial:
                if not dry_run:
                    try:
                        c["abs_path"].unlink(missing_ok=True)
                        auto_removed.append(c["path"])
                    except Exception as e:
                        print(f"[Prune] Failed to auto-remove {c['path']}: {e}")
                else:
                    auto_removed.append(c["path"])
            else:
                retained_candidates.append(c)
                
        if auto_removed:
            print(f"[Prune] Auto-removed {len(auto_removed)} trivial/empty stubs: {auto_removed[:5]}")
            
        if not retained_candidates:
            self.clean_broken_symlinks()
            self.rebuild_final_main()
            self.cleanup_empty_dirs()
            return {"removed": auto_removed, "kept": [], "next_group_idx": 0}
            
        # 2. Group by semantic similarity and sort
        groups = self.group_by_similarity(retained_candidates)
        groups = self.sort_groups_deterministically(groups)
        
        # 3. Select a batch of groups (target 15 files to review)
        selected_groups, next_group_idx = self.select_batch(groups, target_file_count=15)
        
        # Count total files in the selected groups
        selected_files_count = sum(len(g) for g in selected_groups)
        print(f"[Prune] Selected {len(selected_groups)} group(s) ({selected_files_count} files) for Pi-Agent curation")
        
        # 4. Ask Pi-Agent to curate
        curator_removed = []
        curator_kept = []
        
        if selected_groups:
            result = self.pi_agent.curate_similar_groups(selected_groups)
            if result:
                keep_paths = set(result.get("keep", []))
                remove_paths = set(result.get("remove", []))
                notes = result.get("notes", "")
                print(f"[Prune] Pi-Agent curation notes: {notes}")
                
                # Process decisions for the selected files
                for group in selected_groups:
                    for f in group:
                        path = f["path"]
                        if path in remove_paths:
                            if not dry_run:
                                try:
                                    f["abs_path"].unlink(missing_ok=True)
                                    curator_removed.append(path)
                                except Exception as e:
                                    print(f"[Prune] Failed to prune {path}: {e}")
                            else:
                                curator_removed.append(path)
                        elif path in keep_paths or len(group) == 1:
                            curator_kept.append(path)
                        else:
                            # Default if not mentioned: keep
                            curator_kept.append(path)
            else:
                print("[Prune] Pi-Agent curation failed or returned invalid response, keeping all files in batch")
                for group in selected_groups:
                    for f in group:
                        curator_kept.append(f["path"])
                        
        # 5. Save state
        if not dry_run:
            self.save_prune_state(next_group_idx)
            
        total_removed = auto_removed + curator_removed

        # 6. Immortalize kept sorry-free files with theorems
        if not dry_run:
            for c in candidates:
                if c["path"] not in total_removed:
                    if not c["sorries"] and c["theorems"] > 0:
                        self.immortalize_file(c)

        # 7. Post-prune cleaning
        symlinks_removed = 0
        dirs_cleaned = 0
        if not dry_run:
            symlinks_removed = self.clean_broken_symlinks()
            self.rebuild_final_main()
            dirs_cleaned = self.cleanup_empty_dirs()
            
        print(f"[Prune] Complete. Removed {len(total_removed)} files ({len(auto_removed)} auto, {len(curator_removed)} LLM, {symlinks_removed} broken symlinks)")
        
        return {
            "removed": total_removed,
            "kept": curator_kept,
            "broken_symlinks_removed": symlinks_removed,
            "dirs_cleaned": dirs_cleaned,
            "next_group_idx": next_group_idx
        }

