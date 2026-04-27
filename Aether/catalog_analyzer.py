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

        Returns a string like:
            Catalog: 13 domains, 1446 files, 28797 declarations
            - Algebra: 100 files, 1365 declarations, 0 sorries
            - Physics: 114 files, 2830 declarations, 1 sorry
            ...
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
        """Infer domain from the first directory component."""
        parts = rel_path.parts
        if len(parts) > 1:
            first_dir = parts[0]
            if first_dir in DOMAIN_DIRS:
                return first_dir
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