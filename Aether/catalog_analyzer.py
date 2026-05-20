#!/usr/bin/env python3
"""CatalogAnalyzer: Scans the Catalog and builds structured summaries for Pi-Agent.

Provides two key capabilities:
1. A lightweight summary of all .lean files (domain, declarations, sorries)
2. @ reference selection: given a concept, select the most relevant
   Catalog files to include as context in the Aristotle prompt.
"""

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

# Tactics considered "interesting" (non-trivial proof effort) — shared with quality_evaluator
DEEP_TACTICS = {
    "induction", "rcases", "obtain", "by_contra", "by_cases",
    "omega", "linarith", "nlinarith", "field_simp", "ring_nf",
    "push_cast", "norm_cast", "ext", "funext", "conv",
    "calc", "have", "suffices", "refine", "apply",
    "exact", "constructor", "cases", "match",
}


@dataclass
class CatalogFileSummary:
    """Summary of a single Catalog .lean file."""
    relative_path: str       # e.g., "Algebra/SpectralGraphTheory.lean"
    domain: str              # e.g., "Algebra"
    declarations: List[str] = field(default_factory=list)  # top-level names
    imports: List[str] = field(default_factory=list)       # import statements
    size_lines: int = 0
    has_sorries: bool = False
    sorry_count: int = 0


# Domain directories in the Catalog
DOMAIN_DIRS = [
    "Algebra", "Applications", "Bridges", "Computation", "Cryptography",
    "EML", "Geometry", "Logic", "MachineLearning", "Physics",
    "Pythagorean", "Shared", "Speculative", "Tropical",
]

# The FINAL subdirectory contains vetted, high-quality catalog files
FINAL_DIR = "FINAL"

# Directories to skip during scan
SKIP_DIRS = {
    "ResearchOutput", "Tools", ".lake", "lake-packages", "build",
    "__pycache__", ".git", "Aether", "output",
}

# Files to skip
SKIP_PREFIXES = ("lakefile", "lean-toolchain", "CATALOG", "DECLARATION", "FUTURE")

# Max files to @-reference in a single prompt
MAX_REFERENCES = 12

# Max lines per file when extracting content for @ references
MAX_LINES_PER_FILE = 150


class CatalogAnalyzer:
    """Scans the Catalog and builds structured summaries for Pi-Agent."""

    def __init__(self, catalog_root: Path):
        self.catalog_root = Path(catalog_root)
        self._summaries: Optional[List[CatalogFileSummary]] = None
        self._domain_index: Dict[str, List[CatalogFileSummary]] = {}
        self._declaration_index: Dict[str, str] = {}  # declaration -> relative_path

    def scan(self) -> List[CatalogFileSummary]:
        """Scan all .lean files in the Catalog. Caches result."""
        if self._summaries is not None:
            return self._summaries

        summaries = []
        for src in sorted(self.catalog_root.rglob("*.lean")):
            rel = src.relative_to(self.catalog_root)
            if self._should_skip(rel):
                continue

            try:
                content = src.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue

            summary = self._parse_file(rel, content)
            summaries.append(summary)

            domain = summary.domain
            if domain not in self._domain_index:
                self._domain_index[domain] = []
            self._domain_index[domain].append(summary)

            for decl in summary.declarations:
                self._declaration_index[decl] = summary.relative_path

        self._summaries = summaries
        return summaries

    def invalidate_cache(self) -> None:
        """Force re-scan on next call to scan()."""
        self._summaries = None
        self._domain_index = {}
        self._declaration_index = {}

    def get_domain_files(self, domain: str) -> List[CatalogFileSummary]:
        """Get all file summaries for a domain."""
        if self._summaries is None:
            self.scan()
        return self._domain_index.get(domain, [])

    def get_domains(self) -> List[str]:
        """Get list of all domains found in the catalog."""
        if self._summaries is None:
            self.scan()
        return sorted(self._domain_index.keys())

    def select_references(
        self,
        concept_domain: str,
        concept_keywords: List[str],
        concept_description: str = "",
        research_mode: str = "prove",
    ) -> List[str]:
        """Select the most relevant Catalog files for @ referencing.

        Uses a scoring algorithm:
        1. Direct domain match (+5 points)
        2. Cross-domain keyword overlap in declarations (+3 per keyword)
        3. Files with sorries get a bonus if research_mode is sorry_fill (+4)
        4. Description keyword overlap (+1 per keyword found in content)
        5. Shared domain gets a small bonus (+1, always relevant)

        Returns list of relative paths, top MAX_REFERENCES.
        """
        if self._summaries is None:
            self.scan()

        scored: List[Tuple[float, str]] = []
        keywords_lower = [k.lower() for k in concept_keywords]
        desc_words = set(re.findall(r'\b[a-zA-Z]{4,}\b', concept_description.lower()))

        for summary in self._summaries:
            score = 0.0

            # Domain match
            if summary.domain.lower() == concept_domain.lower():
                score += 5.0

            # Cross-domain keyword overlap with declarations
            for kw in keywords_lower:
                for decl in summary.declarations:
                    if kw in decl.lower():
                        score += 3.0
                        break

            # Description word overlap with declarations
            for word in desc_words:
                for decl in summary.declarations:
                    if word in decl.lower():
                        score += 1.0
                        break

            # Sorry bonus for sorry_fill mode
            if research_mode == "sorry_fill" and summary.has_sorries:
                score += 4.0

            # Shared domain is always relevant
            if summary.domain == "Shared":
                score += 1.0

            # Prefer files with more declarations (richer context)
            score += min(len(summary.declarations) * 0.1, 2.0)

            if score > 0:
                scored.append((score, summary.relative_path))

        scored.sort(key=lambda x: x[0], reverse=True)
        return [path for _, path in scored[:MAX_REFERENCES]]

    def get_file_content(self, relative_path: str) -> str:
        """Read the content of a Catalog file for @ referencing.

        Returns up to MAX_LINES_PER_FILE lines.
        """
        src = self.catalog_root / relative_path
        if not src.exists():
            return ""
        try:
            content = src.read_text(encoding="utf-8", errors="replace")
        except Exception:
            return ""
        lines = content.splitlines()
        if len(lines) > MAX_LINES_PER_FILE:
            truncated = "\n".join(lines[:MAX_LINES_PER_FILE])
            return truncated + "\n-- ... (truncated, full file has {} lines)".format(len(lines))
        return content

    def build_catalog_context_string(
        self,
        references: List[str],
    ) -> str:
        """Build the @ reference context block for the Aristotle prompt.

        Format:
            @Algebra/Core/RingTheory.lean
            ```lean
            ... file content (truncated to MAX_LINES_PER_FILE) ...
            ```

            @Tropical/Core/TropicalSemiring.lean
            ```lean
            ... file content ...
            ```
        """
        if not references:
            return ""

        parts = []
        for ref in references:
            content = self.get_file_content(ref)
            if not content:
                continue
            parts.append(f"@{ref}\n```lean\n{content}\n```")

        return "\n\n".join(parts)

    def get_domain_summary_for_prompt(self) -> str:
        """Generate a compact domain summary for Pi-Agent prompts.

        Returns a string with file count, declaration count, and sorry count per domain.
        """
        if self._summaries is None:
            self.scan()

        total_files = len(self._summaries)
        total_decls = sum(len(s.declarations) for s in self._summaries)
        total_sorries = sum(s.sorry_count for s in self._summaries)

        lines = [
            f"Catalog: {len(self._domain_index)} domains, "
            f"{total_files} files, {total_decls} declarations, "
            f"{total_sorries} sorries remaining"
        ]

        for domain in sorted(self._domain_index.keys()):
            files = self._domain_index[domain]
            file_count = len(files)
            decl_count = sum(len(f.declarations) for f in files)
            sorry_count = sum(f.sorry_count for f in files)
            sorry_note = f", {sorry_count} sorries" if sorry_count > 0 else ""

            lines.append(
                f"  - {domain}: {file_count} files, {decl_count} declarations{sorry_note}"
            )

        return "\n".join(lines)

    def get_files_with_sorries(self) -> List[CatalogFileSummary]:
        """Get all files that have sorry placeholders (targets for sorry_fill mode)."""
        if self._summaries is None:
            self.scan()
        return [s for s in self._summaries if s.has_sorries]

    # Priority sorry targets from FUTURE_RESEARCH.md — these are the most
    # impactful sorries to fill because they close open problems or complete proofs.
    PRIORITY_SORRY_PATHS = {
        "Shared/CarmichaelComposite.lean": 10,
        "Speculative/CarmichaelPrimitiveDivisor.lean": 10,
        "Shared/Fib_gcd_identity.lean": 9,
        "Shared/CarmichaelComputational.lean": 9,
        "Speculative/SciFi/PadicHyperdrive.lean": 7,
        "Bridges/NivenIntegralFramework.lean": 8,
    }

    # Domain keywords that indicate high-impact sorry_fill targets
    HIGH_IMPACT_KEYWORDS = {
        "Carmichael", "primitive_divisor", "fib_primitive", "nivenI",
        "Niven", "Hecke", "langlands", "dilithium", "robustness",
        "universal_approximation", "EML_approx",
    }

    def get_priority_sorry_targets(self) -> List[CatalogFileSummary]:
        """Get sorry files prioritized by research impact.

        Files from PRIORITY_SORRY_PATHS are ranked highest, followed by files
        whose declarations contain high-impact keywords, then by sorry count.
        """
        if self._summaries is None:
            self.scan()

        sorry_files = [s for s in self._summaries if s.has_sorries]

        def priority_score(s: CatalogFileSummary) -> float:
            score = 0.0
            # Known priority paths get a big boost
            if s.relative_path in self.PRIORITY_SORRY_PATHS:
                score += self.PRIORITY_SORRY_PATHS[s.relative_path]
            # High-impact keywords in declarations
            for kw in self.HIGH_IMPACT_KEYWORDS:
                for decl in s.declarations:
                    if kw.lower() in decl.lower():
                        score += 5.0
                        break
            # More sorries = more work to fill, but also more impactful
            score += min(s.sorry_count, 10) * 0.5
            # Files with more declarations are richer context
            score += min(len(s.declarations), 30) * 0.1
            return score

        sorry_files.sort(key=priority_score, reverse=True)
        return sorry_files

    def build_focused_context(
        self,
        domain: str,
        concept_description: str,
        max_theorems: int = 15,
    ) -> str:
        """Build focused context: the N most relevant theorem signatures for a concept.

        Instead of dumping all 2,700 files into the prompt, this extracts specific
        theorem/lemma signatures that are most relevant to the concept Pi is pursuing.
        Pi uses this to write precise prompts that reference existing work.

        Prefers files with deep proof tactics (induction, rcases, etc.) and penalizes
        files dominated by native_decide/decide (computational enumeration proofs).

        Returns a structured string like:
            Existing theorems you can build on:
            1. relu_is_tropical_max : ∀ x : ℝ, max x 0 = tropMax x 0
               (file: Tropical/NeuralNetworks/TropicalDegreeRobustness.lean)
            2. certified_radius : ...
        """
        if self._summaries is None:
            self.scan()

        # Extract keywords from concept description for relevance scoring
        desc_words = set(re.findall(r'\b[a-zA-Z]{3,}\b', concept_description.lower()))

        # Score each file's declarations against the concept
        scored_theorems: list = []
        for summary in self._summaries:
            # Base score: domain match
            domain_score = 3.0 if summary.domain.lower() == domain.lower() else 0.0

            # Deep proof preference: boost files with deep tactics, penalize native_decide
            deep_bonus = 0.0
            try:
                src = self.catalog_root / summary.relative_path
                content = src.read_text(encoding="utf-8", errors="replace")
                deep_tactic_count = sum(1 for t in DEEP_TACTICS if t in content)
                shallow_tactic_count = content.count("native_decide") + content.count("\nby decide")
                if deep_tactic_count >= 3:
                    deep_bonus += 0.5 * min(deep_tactic_count / 10, 1.0)
                if shallow_tactic_count > deep_tactic_count:
                    deep_bonus -= 0.3  # penalize native_decide-heavy files
            except Exception:
                pass

            for decl in summary.declarations:
                decl_lower = decl.lower()
                # Keyword overlap between concept description and declaration name
                decl_words = set(re.findall(r'[a-z]{3,}', decl_lower))
                overlap = len(desc_words & decl_words)
                score = domain_score + overlap * 2.0 + deep_bonus

                # Bonus for theorem/lemma names (vs definitions)
                if any(kw in decl_lower for kw in ('theorem', 'lemma', 'bound', 'ineq')):
                    score += 1.0

                if score > 0:
                    scored_theorems.append((score, decl, summary))

        scored_theorems.sort(key=lambda x: x[0], reverse=True)

        if not scored_theorems:
            return "No specific existing theorems found for this concept."

        # Extract full theorem signatures from the top-scored files
        seen_files: set = set()
        results = []
        for score, decl_name, summary in scored_theorems:
            if len(results) >= max_theorems:
                break

            # Read file to get the full theorem signature
            if summary.relative_path in seen_files:
                continue
            seen_files.add(summary.relative_path)

            try:
                src = self.catalog_root / summary.relative_path
                content = src.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue

            # Extract theorem/lemma lines with their signatures
            for line in content.splitlines():
                stripped = line.strip()
                if (stripped.startswith(("theorem ", "lemma ")) and
                        decl_name in stripped):
                    # Get the full signature (may span multiple lines)
                    sig = stripped[:200]  # Cap length
                    results.append(
                        f"  {len(results)+1}. `{decl_name}` : {sig}\n"
                        f"     (file: {summary.relative_path})"
                    )
                    break

        if not results:
            return "No specific theorem signatures matched this concept."

        header = "Existing theorems you can build on:\n"
        return header + "\n".join(results)

    def is_deep_proof(self, relative_path: str) -> bool:
        """Check if a .lean file contains deep proof tactics (not just native_decide/decide).

        Used to preferentially select files with genuine mathematical depth as
        context for Aristotle's prompts.
        """
        try:
            src = self.catalog_root / relative_path
            content = src.read_text(encoding="utf-8", errors="replace")
            deep_count = sum(1 for t in DEEP_TACTICS if t in content)
            shallow_count = content.count("native_decide") + content.count("\nby decide")
            return deep_count > shallow_count and deep_count >= 2
        except Exception:
            return False

    def is_final_file(self, relative_path: str) -> bool:
        """Check if a file is in the FINAL (vetted, high-quality) catalog directory."""
        return relative_path.startswith(FINAL_DIR + "/") or relative_path.startswith(FINAL_DIR + "\\")

    def get_final_files(self, domain: str = "") -> List[CatalogFileSummary]:
        """Get all vetted FINAL catalog files, optionally filtered by domain."""
        if self._summaries is None:
            self.scan()
        results = []
        for s in self._summaries:
            if not self.is_final_file(s.relative_path):
                continue
            if domain and s.domain != domain:
                continue
            results.append(s)
        return results

    def collect_future_directions(self, limit: int = 10) -> str:
        """Collect Aristotle's FUTURE_DIRECTIONS reports from previous cycles.

        Aristotle includes a FUTURE_DIRECTIONS.md (or similar) in its output,
        containing its own research recommendations. Pi reads these to guide
        the next research cycle, creating a self-improving feedback loop.

        Sources:
        1. Catalog/ResearchOutput/*/FUTURE_DIRECTIONS.md
        2. Catalog/ResearchOutput/*/future_directions*.md
        3. Catalog/ResearchOutput/*/extracted_future_directions.md
        4. Catalog/Speculative/AutoResearch/*/(FUTURE_DIRECTIONS|future_directions|research_paper)
        5. Catalog/ResearchOutput/*/research_paper.md (for "Future Directions" sections)

        Returns the concatenated content of the largest N reports, deduplicated
        by concept similarity.
        """
        future_dirs: list = []

        # Scan directories for future directions files
        scan_dirs = [
            self.catalog_root / "ResearchOutput",
            self.catalog_root / "Speculative" / "AutoResearch",
        ]

        for scan_dir in scan_dirs:
            if not scan_dir.exists():
                continue
            for subdir in sorted(scan_dir.iterdir()):
                if not subdir.is_dir():
                    continue

                # Look for future directions files (including nested subdirs)
                candidates = []
                for pattern in [
                    "FUTURE_DIRECTIONS.md",
                    "future_directions*.md",
                    "extracted_future_directions.md",
                ]:
                    candidates.extend(subdir.glob(pattern))
                    # Also check one level deeper
                    for sub2 in sorted(subdir.iterdir()):
                        if sub2.is_dir():
                            candidates.extend(sub2.glob(pattern))

                for candidate in candidates:
                    try:
                        content = candidate.read_text(encoding="utf-8", errors="replace")
                        if len(content) > 100:
                            future_dirs.append({
                                "path": str(candidate.relative_to(self.catalog_root)),
                                "content": content,
                                "size": len(content),
                                "dedup_key": content[:200].lower().strip(),
                            })
                    except Exception:
                        continue

                # Also check research papers for "Future Directions" sections
                for paper_name in ["research_paper.md", "RESEARCH_REPORT.md",
                                   "RESEARCH_PAPER.md"]:
                    paper = subdir / paper_name
                    if not paper.exists():
                        # Check one level deeper
                        for sub2 in sorted(subdir.iterdir()):
                            if sub2.is_dir():
                                candidate = sub2 / paper_name
                                if candidate.exists():
                                    paper = candidate
                                    break
                    if paper.exists():
                        try:
                            content = paper.read_text(encoding="utf-8", errors="replace")
                            section = self._extract_section(content, [
                                "Future Directions",
                                "What We Don't Know",
                                "Open Questions",
                                "Open Problems",
                                "What Could This Be Good For",
                                "Looking Forward",
                            ])
                            if section and len(section) > 100:
                                future_dirs.append({
                                    "path": str(paper.relative_to(self.catalog_root)),
                                    "content": section,
                                    "size": len(section),
                                    "dedup_key": section[:200].lower().strip(),
                                })
                        except Exception:
                            continue

        if not future_dirs:
            return "No previous future directions reports found."

        # Deduplicate by content similarity
        seen_keys = set()
        unique_dirs = []
        for fd in future_dirs:
            key = fd["dedup_key"]
            if key not in seen_keys:
                seen_keys.add(key)
                unique_dirs.append(fd)
            # Skip duplicates with similar opening content

        # Take the largest N reports
        unique_dirs.sort(key=lambda x: x["size"], reverse=True)
        selected = unique_dirs[:limit]

        parts = []
        for fd in selected:
            # Truncate very long reports to keep prompt manageable
            content = fd["content"]
            if len(content) > 2000:
                content = content[:2000] + "\n\n[... truncated for prompt size ...]"
            parts.append(
                f"### From: {fd['path']}\n\n{content}"
            )

        return "\n\n---\n\n".join(parts)

    @staticmethod
    def _extract_section(content: str, section_names: list) -> str:
        """Extract a named section from a markdown document.

        Looks for ## or ### headings matching any of the given names,
        then returns everything until the next heading of equal or higher level.
        """
        lines = content.splitlines()
        capturing = False
        capture_level = 0
        result_lines = []

        for line in lines:
            stripped = line.strip()

            # Check for heading
            if stripped.startswith("#"):
                level = len(stripped) - len(stripped.lstrip("#"))
                heading_text = stripped.lstrip("# ").strip()

                if capturing:
                    # Stop if we hit a heading at same or higher level
                    if level <= capture_level:
                        break
                    # Otherwise keep capturing (sub-section)
                    result_lines.append(line)
                else:
                    # Check if this heading matches any target section
                    for name in section_names:
                        if name.lower() in heading_text.lower():
                            capturing = True
                            capture_level = level
                            result_lines.append(line)
                            break
            elif capturing:
                result_lines.append(line)

        return "\n".join(result_lines).strip()

    def find_declaration(self, name: str) -> Optional[str]:
        """Find which file contains a declaration by name."""
        if self._summaries is None:
            self.scan()
        return self._declaration_index.get(name)

    def _parse_file(self, rel_path: Path, content: str) -> CatalogFileSummary:
        """Parse a .lean file to extract declarations, imports, size, sorries."""
        lines = content.splitlines()
        domain = self._infer_domain(rel_path)

        # Extract imports
        imports = []
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("import "):
                imports.append(stripped)

        # Extract top-level declaration names (theorem, def, structure, class, instance)
        declarations = []
        for line in lines:
            stripped = line.strip()
            for keyword in ("theorem ", "lemma ", "def ", "structure ", "class ", "instance "):
                if stripped.startswith(keyword):
                    name = stripped[len(keyword):].split("(")[0].split(":")[0].split(" ")[0].strip()
                    if name and name not in declarations:
                        declarations.append(name)
                    break

        # Count sorries
        sorry_count = content.count("sorry")
        has_sorries = sorry_count > 0

        return CatalogFileSummary(
            relative_path=str(rel_path),
            domain=domain,
            declarations=declarations[:50],  # Cap at 50 to avoid huge summaries
            imports=imports,
            size_lines=len(lines),
            has_sorries=has_sorries,
            sorry_count=sorry_count,
        )

    def _should_skip(self, rel_path: Path) -> bool:
        """Check if a path should be skipped."""
        # Skip known directories
        parts = rel_path.parts
        for skip_dir in SKIP_DIRS:
            if skip_dir in parts:
                return True

        # Skip non-.lean files
        if rel_path.suffix != ".lean":
            return True

        # Skip files with known prefixes
        name = rel_path.name
        for prefix in SKIP_PREFIXES:
            if name.startswith(prefix):
                return True

        return False

    def _infer_domain(self, rel_path: Path) -> str:
        """Infer domain from the first directory component (skipping FINAL if present)."""
        parts = rel_path.parts
        # Skip FINAL prefix: FINAL/Domain/File.lean -> Domain
        start = 1 if parts and parts[0] == FINAL_DIR else 0
        if len(parts) > start + 1:
            domain_dir = parts[start]
            if domain_dir in DOMAIN_DIRS:
                return domain_dir
        return "Unknown"

    def detect_cross_domain_bridges(self) -> List[Dict]:
        """Detect cross-domain bridges by analyzing import patterns.

        A bridge exists when a file in domain A imports from domain B.
        This reveals which domains are already connected and which
        bridges are missing.

        Returns list of dicts: {source_domain, target_domain, count, files}
        sorted by bridge strength (count).
        """
        if self._summaries is None:
            self.scan()

        bridges: Dict[Tuple[str, str], List[str]] = {}

        for summary in self._summaries:
            source_domain = summary.domain
            for imp in summary.imports:
                # Parse import to extract domain
                # Import format: "import Domain.Subdir.FileName"
                parts = imp.replace("import ", "").strip().split(".")
                if len(parts) >= 1:
                    target_domain = parts[0]
                    if target_domain in DOMAIN_DIRS and target_domain != source_domain:
                        key = (source_domain, target_domain)
                        if key not in bridges:
                            bridges[key] = []
                        bridges[key].append(summary.relative_path)

        # Convert to list and sort
        result = []
        for (src, tgt), files in bridges.items():
            result.append({
                "source_domain": src,
                "target_domain": tgt,
                "count": len(set(files)),  # Deduplicate
                "files": list(set(files))[:5],  # Top 5 examples
            })
        result.sort(key=lambda x: -x["count"])
        return result

    def compute_domain_connectivity(self) -> Dict[str, Dict[str, int]]:
        """Compute domain connectivity matrix from import patterns.

        Returns dict: {source_domain: {target_domain: count_of_files_connecting}}
        """
        bridges = self.detect_cross_domain_bridges()
        connectivity: Dict[str, Dict[str, int]] = {
            d: {} for d in DOMAIN_DIRS
        }
        for bridge in bridges:
            src = bridge["source_domain"]
            tgt = bridge["target_domain"]
            connectivity.setdefault(src, {})[tgt] = bridge["count"]
            connectivity.setdefault(tgt, {})[src] = bridge["count"]
        return connectivity

    def find_missing_bridges(self, limit: int = 10) -> List[Tuple[str, str, float]]:
        """Find domain pairs that have no or weak connections.

        These missing bridges represent the most promising opportunities
        for novel cross-domain research.

        Returns list of (domain_a, domain_b, potential_score) sorted by potential.
        """
        if self._summaries is None:
            self.scan()

        bridges = self.detect_cross_domain_bridges()
        existing_bridges = set()
        for b in bridges:
            existing_bridges.add((b["source_domain"], b["target_domain"]))
            existing_bridges.add((b["target_domain"], b["source_domain"]))

        # Cross-domain keyword overlap = potential for bridge
        domain_keywords: Dict[str, Set[str]] = {}
        for summary in self._summaries:
            domain = summary.domain
            if domain not in domain_keywords:
                domain_keywords[domain] = set()
            for decl in summary.declarations:
                # Extract keywords from declaration name
                words = re.findall(r'[A-Z][a-z]*', decl)
                domain_keywords[domain].update(w.lower() for w in words)

        # Score missing bridges by keyword overlap
        missing = []
        for i, d_a in enumerate(DOMAIN_DIRS):
            for d_b in DOMAIN_DIRS[i+1:]:
                key = (d_a, d_b)
                key_rev = (d_b, d_a)
                if key not in existing_bridges and key_rev not in existing_bridges:
                    # No bridge exists — compute potential from keyword overlap
                    kw_a = domain_keywords.get(d_a, set())
                    kw_b = domain_keywords.get(d_b, set())
                    # Overlap in declaration keywords = shared concepts = bridge potential
                    overlap = len(kw_a & kw_b)
                    # Also consider domain sizes (larger = more theorems to bridge)
                    files_a = len(self._domain_index.get(d_a, []))
                    files_b = len(self._domain_index.get(d_b, []))
                    potential = overlap * 0.3 + min(files_a, files_b) * 0.01
                    missing.append((d_a, d_b, potential))

        missing.sort(key=lambda x: -x[2])
        return missing[:limit]

    def find_under_explored_domains(self) -> List[Dict]:
        """Find domains with many declarations but few deep theorems.

        A domain is under-explored if it has:
        - Many declarations (definitions/structures) but few theorems
        - Few or no sorry targets (meaning nobody has tried hard problems)
        - High exploration_ratio = declarations / max(sorries, 1)

        Returns list of dicts sorted by exploration_ratio (highest = most under-explored).
        """
        if self._summaries is None:
            self.scan()

        results = []
        for domain, files in self._domain_index.items():
            total_decls = sum(len(f.declarations) for f in files)
            total_sorries = sum(f.sorry_count for f in files if hasattr(f, 'sorry_count'))
            total_files = len(files)

            # Count theorems vs definitions (rough approximation)
            theorem_count = sum(
                1 for f in files for d in f.declarations
                if any(kw in d.lower() for kw in ('theorem', 'lemma'))
            )

            # Under-explored ratio: high declarations relative to sorries
            # means nobody has pushed hard into this domain
            exploration_ratio = total_decls / max(total_sorries, 1)

            # Theorem density: low ratio means many definitions but few theorems
            theorem_ratio = theorem_count / max(total_decls, 1)

            results.append({
                "domain": domain,
                "total_files": total_files,
                "total_declarations": total_decls,
                "total_sorries": total_sorries,
                "theorem_count": theorem_count,
                "theorem_ratio": theorem_ratio,
                "exploration_ratio": exploration_ratio,
                "breakthrough_potential": (
                    "HIGH" if exploration_ratio > 20 else
                    "MEDIUM" if exploration_ratio > 10 else
                    "LOW"
                ),
            })

        results.sort(key=lambda x: -x["exploration_ratio"])
        return results

    def find_structural_opportunities(self) -> List[Dict]:
        """Find pairs of domains with structural similarity but no bridge.

        Two domains have structural opportunity when they share:
        - Similar algebraic structures (rings, groups, functors) referenced
        - Import patterns suggesting shared mathematical foundations
        But NO existing bridge between them.

        Returns list of opportunity dicts sorted by number of shared structures.
        """
        if self._summaries is None:
            self.scan()

        existing = self.detect_cross_domain_bridges()
        existing_pairs = set()
        for b in existing:
            existing_pairs.add((b["source_domain"], b["target_domain"]))
            existing_pairs.add((b["target_domain"], b["source_domain"]))

        # Build structural signature per domain
        structural_keywords = {
            "Semiring", "semiring", "tropical",
            "Group", "group", "Monoid", "monoid",
            "Ring", "ring", "Field", "field",
            "TopologicalSpace", "topology", "Topological",
            "NormedSpace", "norm", "Normed",
            "Measure", "measure",
            "Category", "category", "Functor", "functor",
            "Module", "module",
            "Order", "lattice", "Lattice",
            "MetricSpace", "metric",
            "HilbertSpace", "hilbert",
            "Manifold", "manifold",
        }

        domain_structures: Dict[str, set] = {}
        for domain, files in self._domain_index.items():
            structures = set()
            for f in files:
                try:
                    content = (self.catalog_root / f.relative_path).read_text(
                        encoding="utf-8", errors="replace"
                    )
                    for kw in structural_keywords:
                        if kw in content:
                            structures.add(kw.lower())
                except Exception:
                    continue
            domain_structures[domain] = structures

        # Find pairs with structural overlap but no bridge
        opportunities = []
        domain_list = list(self._domain_index.keys())
        for i, d_a in enumerate(domain_list):
            for d_b in domain_list[i+1:]:
                if (d_a, d_b) in existing_pairs:
                    continue
                shared = domain_structures.get(d_a, set()) & domain_structures.get(d_b, set())
                if shared:
                    opportunities.append({
                        "domain_a": d_a,
                        "domain_b": d_b,
                        "shared_structures": sorted(list(shared)),
                        "existing_bridge": False,
                        "opportunity": (
                            f"Both {d_a} and {d_b} use {', '.join(sorted(shared))} "
                            f"but no bridge exists between them"
                        ),
                    })

        opportunities.sort(key=lambda x: -len(x["shared_structures"]))
        return opportunities

    def analyze_catalog_breakthrough_potential(self) -> str:
        """Generate a breakthrough potential analysis of the catalog.

        This is injected into the Pi-Agent direction selection prompt to guide
        it toward under-explored territory and structural opportunities.

        Returns a structured markdown string.
        """
        under_explored = self.find_under_explored_domains()
        structural = self.find_structural_opportunities()
        bridges = self.detect_cross_domain_bridges()
        sorries = self.get_priority_sorry_targets()

        lines = ["## Catalog Breakthrough Analysis\n"]

        lines.append("### Under-Explored Domains (many declarations, few deep results)")
        for ue in under_explored[:5]:
            lines.append(
                f"- {ue['domain']}: {ue['total_declarations']} declarations, "
                f"{ue['total_sorries']} sorries, exploration ratio {ue['exploration_ratio']:.1f} "
                f"({ue['breakthrough_potential']} potential)"
            )

        lines.append("\n### Structural Opportunities (shared structures, no bridge)")
        for so in structural[:5]:
            lines.append(f"- {so['domain_a']} <-> {so['domain_b']}: {so['opportunity']}")

        lines.append("\n### Existing Bridges (for reference, do NOT repeat)")
        for b in bridges[:8]:
            lines.append(f"- {b['source_domain']} -> {b['target_domain']}: {b['count']} files")

        if sorries:
            lines.append(f"\n### Priority Sorry Targets ({len(sorries)} files with sorries)")
            for s in sorries[:5]:
                lines.append(
                    f"- {s.relative_path}: {s.sorry_count} sorries, "
                    f"declarations: {', '.join(s.declarations[:3])}"
                )

        return "\n".join(lines)



def main():
    """CLI for standalone testing of catalog_analyzer."""
    import argparse
    import json

    parser = argparse.ArgumentParser(description="CatalogAnalyzer: Scan and analyze the theorem catalog")
    parser.add_argument("--catalog", default="../Catalog", help="Path to Catalog root")
    parser.add_argument("--domain", help="Show files for a specific domain")
    parser.add_argument("--references", nargs="+", help="Select @ references for a concept (domain keyword1 keyword2...)")
    parser.add_argument("--summary", action="store_true", help="Print domain summary")
    parser.add_argument("--sorries", action="store_true", help="Show files with sorries")

    args = parser.parse_args()

    analyzer = CatalogAnalyzer(Path(args.catalog))
    analyzer.scan()

    if args.summary:
        print(analyzer.get_domain_summary_for_prompt())

    if args.domain:
        files = analyzer.get_domain_files(args.domain)
        print(f"\n{args.domain}: {len(files)} files")
        for f in files[:20]:
            sorry_note = f" ({f.sorry_count} sorries)" if f.has_sorries else ""
            print(f"  {f.relative_path}: {len(f.declarations)} declarations{sorry_note}")
        if len(files) > 20:
            print(f"  ... and {len(files) - 20} more")

    if args.sorries:
        files_with_sorries = analyzer.get_files_with_sorries()
        print(f"\nFiles with sorries: {len(files_with_sorries)}")
        for f in sorted(files_with_sorries, key=lambda x: x.sorry_count, reverse=True)[:20]:
            print(f"  {f.relative_path}: {f.sorry_count} sorries")

    if args.references:
        domain = args.references[0]
        keywords = args.references[1:]
        refs = analyzer.select_references(domain, keywords)
        print(f"\nSelected {len(refs)} @ references for '{domain}' with keywords {keywords}:")
        for ref in refs:
            print(f"  @{ref}")

        context = analyzer.build_catalog_context_string(refs[:3])  # Limit for display
        print(f"\nContext preview ({len(context)} chars):")
        print(context[:2000] + "..." if len(context) > 2000 else context)


if __name__ == "__main__":
    main()