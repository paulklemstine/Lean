#!/usr/bin/env python3
"""ConceptMiner: Introspect the Catalog database to discover research opportunities.

Scans Lean source files and the catalog database to identify:
- Cross-domain bridge gaps
- Hotspot declarations (high fan-in / fan-out)
- Ranked sorry targets
- Axiom dependency load-bearing analysis
- Thematic clusters
"""

import json
import re
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional, Any


@dataclass
class ResearchLandscape:
    """Snapshot of the catalog frontier."""
    total_files: int = 0
    total_declarations: int = 0
    total_sorry: int = 0
    sorry_ranking: List[Dict[str, Any]] = field(default_factory=list)
    bridge_gaps: List[Dict[str, Any]] = field(default_factory=list)
    hotspots: List[Dict[str, Any]] = field(default_factory=list)
    thematic_clusters: Dict[str, List[str]] = field(default_factory=dict)
    axiom_load_bearers: List[Dict[str, Any]] = field(default_factory=list)
    domain_summary: Dict[str, int] = field(default_factory=dict)


class ConceptMiner:
    """Mine the catalog for research opportunities."""

    # Regex patterns for scanning Lean source
    DECL_PATTERNS = [
        (re.compile(r'^(\s*)(noncomputable\s+)?def\s+(\S+)', re.MULTILINE), 'def'),
        (re.compile(r'^(\s*)(noncomputable\s+)?theorem\s+(\S+)', re.MULTILINE), 'theorem'),
        (re.compile(r'^(\s*)lemma\s+(\S+)', re.MULTILINE), 'lemma'),
        (re.compile(r'^(\s*)structure\s+(\S+)', re.MULTILINE), 'structure'),
        (re.compile(r'^(\s*)class\s+(\S+)', re.MULTILINE), 'class'),
        (re.compile(r'^(\s*)inductive\s+(\S+)', re.MULTILINE), 'inductive'),
        (re.compile(r'^(\s*)instance\s+(\S+?)\s*:', re.MULTILINE), 'instance'),
        (re.compile(r'^(\s*)axiom\s+(\S+)', re.MULTILINE), 'axiom'),
        (re.compile(r'^(\s*)abbrev\s+(\S+)', re.MULTILINE), 'abbrev'),
    ]
    SORRY_PATTERN = re.compile(r'\bsorry\b')
    AXIOM_PATTERN = re.compile(r'\baxiom\b')
    IMPORT_PATTERN = re.compile(r'^import\s+(\S+)')
    COMMENT_PATTERN = re.compile(r'/-.*?-/|/--.*?-/' , re.DOTALL)

    def __init__(self, catalog_root: Path, db_path: Optional[Path] = None):
        self.catalog_root = Path(catalog_root)
        self.db_path = Path(db_path) if db_path else None
        self._db: Optional[Dict] = None
        self._file_cache: Dict[str, str] = {}

    def _load_db(self) -> Optional[Dict]:
        if self._db is not None:
            return self._db
        if self.db_path and self.db_path.exists():
            with open(self.db_path, "r", encoding="utf-8") as f:
                self._db = json.load(f)
                return self._db
        return None

    def _get_file_text(self, rel_path: str) -> str:
        if rel_path in self._file_cache:
            return self._file_cache[rel_path]
        full = self.catalog_root / rel_path
        if full.exists():
            text = full.read_text(encoding="utf-8")
            self._file_cache[rel_path] = text
            return text
        return ""

    def scan_all_lean_files(self) -> List[Path]:
        """Return all .lean files under catalog root."""
        return list(self.catalog_root.rglob("*.lean"))

    def extract_declarations_from_file(self, rel_path: str) -> List[Dict[str, Any]]:
        """Extract declarations and their metadata from a single file."""
        text = self._get_file_text(rel_path)
        decls = []

        for pattern, kind in self.DECL_PATTERNS:
            for match in pattern.finditer(text):
                name = match.group(3) if len(match.groups()) >= 3 else ""
                line = text[:match.start()].count('\n') + 1
                decls.append({
                    "name": name,
                    "kind": kind,
                    "line_number": line,
                    "source_file": rel_path,
                })
        return decls

    def count_sorry_in_file(self, rel_path: str) -> int:
        """Count sorry occurrences in a file."""
        text = self._get_file_text(rel_path)
        return len(self.SORRY_PATTERN.findall(text))

    def count_axiom_in_file(self, rel_path: str) -> int:
        """Count axiom occurrences in a file."""
        text = self._get_file_text(rel_path)
        return len(self.AXIOM_PATTERN.findall(text))

    def extract_imports(self, rel_path: str) -> List[str]:
        """Extract import lines from a file."""
        text = self._get_file_text(rel_path)
        return [m.group(1) for m in self.IMPORT_PATTERN.finditer(text)]

    def build_reverse_dependency_graph(self) -> Dict[str, Set[str]]:
        """Build a map: module -> set of files that import it."""
        files = self.scan_all_lean_files()
        module_map: Dict[str, str] = {}
        imports_map: Dict[str, List[str]] = {}

        for fp in files:
            rel = str(fp.relative_to(self.catalog_root))
            # Convert path to module name (e.g., Algebra/Foundations/Algebra.lean -> Algebra.Foundations.Algebra)
            module = rel.replace('/', '.').replace('.lean', '')
            module_map[module] = rel
            imports_map[rel] = self.extract_imports(rel)

        reverse_deps: Dict[str, Set[str]] = defaultdict(set)
        for rel, imports in imports_map.items():
            for imp in imports:
                # imp might be CatalogBuild.Something or Mathlib.Something
                # Find which file it maps to
                for mod, file_rel in module_map.items():
                    if mod.endswith(imp.split('.')[-1]) or imp == mod:
                        reverse_deps[file_rel].add(rel)

        return dict(reverse_deps)

    def mine_sorry_ranking(self, top_n: int = 50) -> List[Dict[str, Any]]:
        """Rank files by strategic sorry impact."""
        files = self.scan_all_lean_files()
        reverse_deps = self.build_reverse_dependency_graph()

        candidates = []
        for fp in files:
            rel = str(fp.relative_to(self.catalog_root))
            sorry_count = self.count_sorry_in_file(rel)
            if sorry_count == 0:
                continue

            downstream = len(reverse_deps.get(rel, set()))
            # Strategic score: sorry_count × downstream dependents
            score = sorry_count * max(1, downstream)
            domain = rel.split('/')[0] if '/' in rel else "Unknown"

            candidates.append({
                "file": rel,
                "domain": domain,
                "sorry_count": sorry_count,
                "downstream_dependents": downstream,
                "strategic_score": score,
            })

        candidates.sort(key=lambda x: x["strategic_score"], reverse=True)
        return candidates[:top_n]

    def mine_bridge_gaps(self, min_cross_domain_refs: int = 2) -> List[Dict[str, Any]]:
        """Find concepts that appear across multiple domains but lack formal bridges."""
        db = self._load_db()
        if not db:
            return []

        # Build concept -> domains map
        concept_domains: Dict[str, Set[str]] = defaultdict(set)
        for entry in db.get("entries", []):
            name = entry.get("name", "")
            domain = entry.get("domain", "")
            if name and domain:
                concept_domains[name].add(domain)

        bridges = []
        for concept, domains in concept_domains.items():
            if len(domains) >= min_cross_domain_refs:
                # Check if there's already a bridge file
                has_bridge = False
                for entry in db.get("entries", []):
                    if entry.get("name") == concept and "Bridge" in entry.get("source_file", ""):
                        has_bridge = True
                        break

                if not has_bridge:
                    bridges.append({
                        "concept": concept,
                        "domains": sorted(domains),
                        "domain_count": len(domains),
                        "potential_value": len(domains) * 10,  # Heuristic
                    })

        bridges.sort(key=lambda x: x["potential_value"], reverse=True)
        return bridges[:50]

    def mine_hotspots(self, top_n: int = 30) -> List[Dict[str, Any]]:
        """Find declarations with highest fan-in and fan-out."""
        db = self._load_db()
        if not db:
            return []

        # Count references (simplified: count times name appears in other files)
        name_counts: Dict[str, int] = defaultdict(int)
        all_files = self.scan_all_lean_files()
        all_text = ""
        for fp in all_files:
            all_text += self._get_file_text(str(fp.relative_to(self.catalog_root)))

        entries = db.get("entries", [])
        for entry in entries:
            name = entry.get("name", "")
            if name:
                name_counts[name] = all_text.count(name)

        hotspots = []
        for entry in entries:
            name = entry.get("name", "")
            if name_counts.get(name, 0) > 5:
                hotspots.append({
                    "name": name,
                    "kind": entry.get("kind"),
                    "domain": entry.get("domain"),
                    "source_file": entry.get("source_file"),
                    "reference_count": name_counts[name],
                })

        hotspots.sort(key=lambda x: x["reference_count"], reverse=True)
        return hotspots[:top_n]

    def mine_thematic_clusters(self) -> Dict[str, List[str]]:
        """Group files by thematic keywords in comments and docstrings."""
        files = self.scan_all_lean_files()
        clusters: Dict[str, Set[str]] = defaultdict(set)

        keywords = {
            "gravity": {"gravit", "spacetime", "metric", "curvature", "einstein"},
            "quantum": {"quantum", "qubit", "entangl", "superposition", "measurement"},
            "tropical": {"tropical", "min-plus", "trop"},
            "cryptographic": {"crypto", "rsa", "ecdsa", "schnorr", "post-quantum"},
            "neural": {"neural", "network", "deep", "machine learning", "activation"},
            "temporal": {"time", "temporal", "clock", "causal", "future"},
            "eml": {"eml", "emergent", "meta-language", "self-pairing"},
            "pythagorean": {"pythagorean", "berggren", "triple", "quadruple", "diophantine"},
            "factoring": {"factor", "prime", "gcd", "divisibility", "composite"},
            "infinity": {"infinite", "transfinite", "limit", "continuum", "aleph"},
        }

        for fp in files:
            rel = str(fp.relative_to(self.catalog_root))
            text = self._get_file_text(rel).lower()
            for theme, terms in keywords.items():
                if any(term in text for term in terms):
                    clusters[theme].add(rel)

        return {k: sorted(v) for k, v in clusters.items()}

    def mine_axiom_load_bearers(self) -> List[Dict[str, Any]]:
        """Identify files that introduce axioms and are heavily depended upon."""
        files = self.scan_all_lean_files()
        reverse_deps = self.build_reverse_dependency_graph()

        bearers = []
        for fp in files:
            rel = str(fp.relative_to(self.catalog_root))
            axiom_count = self.count_axiom_in_file(rel)
            if axiom_count == 0:
                continue
            downstream = len(reverse_deps.get(rel, set()))
            bearers.append({
                "file": rel,
                "axiom_count": axiom_count,
                "downstream_dependents": downstream,
                "risk_score": axiom_count * downstream,
            })

        bearers.sort(key=lambda x: x["risk_score"], reverse=True)
        return bearers[:20]

    def build_landscape(self) -> ResearchLandscape:
        """Build a comprehensive research landscape snapshot."""
        files = self.scan_all_lean_files()
        total_sorry = sum(self.count_sorry_in_file(str(f.relative_to(self.catalog_root))) for f in files)

        db = self._load_db()
        domain_summary = {}
        if db:
            for entry in db.get("entries", []):
                domain = entry.get("domain", "Unknown")
                domain_summary[domain] = domain_summary.get(domain, 0) + 1

        return ResearchLandscape(
            total_files=len(files),
            total_declarations=len(db.get("entries", [])) if db else 0,
            total_sorry=total_sorry,
            sorry_ranking=self.mine_sorry_ranking(),
            bridge_gaps=self.mine_bridge_gaps(),
            hotspots=self.mine_hotspots(),
            thematic_clusters=self.mine_thematic_clusters(),
            axiom_load_bearers=self.mine_axiom_load_bearers(),
            domain_summary=domain_summary,
        )

    def to_json(self) -> str:
        """Serialize landscape to JSON."""
        landscape = self.build_landscape()
        # Convert ResearchLandscape to dict
        return json.dumps({
            "total_files": landscape.total_files,
            "total_declarations": landscape.total_declarations,
            "total_sorry": landscape.total_sorry,
            "sorry_ranking": landscape.sorry_ranking,
            "bridge_gaps": landscape.bridge_gaps,
            "hotspots": landscape.hotspots,
            "thematic_clusters": landscape.thematic_clusters,
            "axiom_load_bearers": landscape.axiom_load_bearers,
            "domain_summary": landscape.domain_summary,
        }, indent=2, ensure_ascii=False)
