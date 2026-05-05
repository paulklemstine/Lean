#!/usr/bin/env python3
"""OutputOrganizer: Professional placement of Aristotle artifacts.

Replaces SmartIntegrator with domain-aware, Pi-Agent-guided placement.

Placement rules:
- .lean theorems (no sorries) → Catalog/{Domain}/{Subdir}/
- .lean theorems (with sorries) → Catalog/Speculative/AutoResearch/
- Research papers (.md) → Catalog/Applications/Papers/
- Python demos (.py) → Catalog/Applications/Demos/
- SVG diagrams (.svg) → Catalog/Applications/Visuals/
- SciAm articles (.md discussion) → Catalog/Applications/Articles/
- Raw experiment data → Catalog/ResearchOutput/{exp_id}/
"""

import re
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple

try:
    from catalog_analyzer import DOMAIN_DIRS as _DOMAIN_DIRS
except ImportError:
    _DOMAIN_DIRS = [
        "Algebra", "Applications", "Bridges", "Computation", "Cryptography",
        "EML", "Geometry", "Logic", "MachineLearning", "Physics",
        "Pythagorean", "Shared", "Speculative", "Tropical",
    ]

DOMAIN_DIRS = _DOMAIN_DIRS


@dataclass
class PlacementDecision:
    """Where a file should be placed in the Catalog."""
    source_path: Path
    target_path: Path
    artifact_type: str  # "theorem" | "paper" | "demo" | "visual" | "article" | "future_directions" | "raw" | "metadata"
    domain: str
    reason: str
    confidence: float = 0.0


# Domain keyword mapping for heuristic classification
DOMAIN_KEYWORDS = {
    "algebra": ["ring", "field", "group", "module", "ideal", "homomorphism", "isomorphism",
                 "galois", "polynomial", "matrix", "determinant", "eigenvalue", "linear"],
    "bridges": ["bridge", "cross-domain", "unified", "interconnection", "morphism"],
    "computation": ["algorithm", "complexity", "turing", "oracle", "recursive", "decidability",
                     "computable", "finite", "automaton", "lambda", "functional"],
    "cryptography": ["cipher", "encrypt", "decrypt", "hash", "rsa", "lattice", "discrete_log",
                      "key_exchange", "signature", "zero_knowledge", "post_quantum"],
    "eml": ["eml", "self_pairing", "spb", "softplus", "logistic", "sigmoid", "neural",
             "activation", "emlv"],
    "geometry": ["manifold", "curve", "surface", "stereographic", "projection", "metric",
                  "euclidean", "hyperbolic", "sphere", "geodesic", "tangent"],
    "logic": ["proposition", "predicate", "modal", "temporal", "proof_search", "decidable",
               "independence", "consistency", "axiom", "boolean"],
    "machinelearning": ["gradient", "loss", "optimizer", "layer", "neural", "training",
                         "inference", "model", "dataset", "regularization", "dropout"],
    "physics": ["energy", "momentum", "lagrangian", "hamiltonian", "spacetime", "quantum",
                 "relativity", "gravity", "field", "particle", "wave"],
    "pythagorean": ["pythagorean", "berggren", "triplet", "quadruple", "factoring", "spb",
                     "parent", "descendant", "tree", "primitive"],
    "speculative": ["speculative", "conjecture", "open_problem", "unknown", "novel",
                     "experimental", "hypothetical", "exploratory"],
    "tropical": ["tropical", "max_plus", "semiring", "min_plus", "idempotent", "trop",
                  "minmax", "tropicalization"],
    "shared": ["shared", "common", "utility", "helper", "lemma", "basic"],
}

# Maps lowercase domain names to the correct Catalog directory names (PascalCase)
LOWER_TO_CATALOG_DIR = {
    "algebra": "Algebra",
    "applications": "Applications",
    "bridges": "Bridges",
    "computation": "Computation",
    "cryptography": "Cryptography",
    "eml": "EML",
    "geometry": "Geometry",
    "logic": "Logic",
    "machinelearning": "MachineLearning",
    "machine_learning": "MachineLearning",
    "neural nets": "MachineLearning",
    "neural_nets": "MachineLearning",
    "physics": "Physics",
    "pythagorean": "Pythagorean",
    "shared": "Shared",
    "speculative": "Speculative",
    "tropical": "Tropical",
    # research_domains.json domain IDs -> Catalog dirs
    "factoring": "Cryptography",
    "compression": "Computation",
    "ai": "MachineLearning",
    "quantum mechanics": "Cryptography",
    "quantum_mechanics": "Cryptography",
    "computation_domain": "Computation",
    "niven_integral": "Bridges",
    "carmichael": "Pythagorean",
    "tropical_langlands_gl2": "Tropical",
    "tropical_robustness": "MachineLearning",
    "dilithium_security": "Cryptography",
    "berggren_optimized": "Pythagorean",
    "eml_approximation": "EML",
    "spb_crypto": "Cryptography",
    "idempotent_optimization_deep": "Tropical",
    "neural proof mining": "MachineLearning",
    "gravitational factoring": "Cryptography",
    "tropical compression theory": "Tropical",
    "categorical neural networks": "MachineLearning",
    "quantum pythagoras": "Cryptography",
    "temporal computation": "Computation",
    "eml cosmology": "EML",
}


def normalize_domain(domain: str) -> str:
    """Normalize any domain name to the correct Catalog directory name.

    Handles lowercase, research_domains.json IDs, and concept.domain values.
    Falls back to checking DOMAIN_DIRS directly, then title case.
    """
    if not domain:
        return "Speculative"

    # Direct match with DOMAIN_DIRS (already correct case)
    if domain in DOMAIN_DIRS:
        return domain

    # Check the mapping
    lower = domain.lower().strip()
    if lower in LOWER_TO_CATALOG_DIR:
        return LOWER_TO_CATALOG_DIR[lower]

    # Try title case as last resort
    title_cased = domain.title().replace("_", "")
    if title_cased in DOMAIN_DIRS:
        return title_cased

    return "Speculative"

# Artifact type detection patterns
ARTIFACT_PATTERNS = {
    "paper": {
        "names": ["RESEARCH_REPORT", "research_report", "paper", "PAPER"],
        "exts": [".md"],
    },
    "demo": {
        "names": ["demo", "example", "visualization_code", "DEMO"],
        "exts": [".py"],
    },
    "visual": {
        "names": ["diagram", "figure", "visual", "svg", "SVG"],
        "exts": [".svg", ".png"],
    },
    "article": {
        "names": ["DISCUSSION", "discussion", "article", "sciam", "SCIAM",
                  "scientific_american", "SCIENTIFIC_AMERICAN"],
        "exts": [".md"],
    },
    "future_directions": {
        "names": ["FUTURE_DIRECTIONS", "future_directions", "FUTURE-DIRECTIONS"],
        "exts": [".md"],
    },
    "theorem": {
        "names": ["Main", "main", "Theorem", "theorem"],
        "exts": [".lean"],
    },
    "metadata": {
        "names": ["metadata", "META"],
        "exts": [".json"],
    },
}

# Directories to skip during result extraction
SKIP_DIRS = {".lake", "lake-packages", "build", ".git", "__pycache__"}


class OutputOrganizer:
    """v3: Professional placement of Aristotle artifacts.

    Routes each artifact type to its proper directory and uses
    Pi-Agent for intelligent .lean file classification.
    """

    def __init__(
        self,
        catalog_root: Path,
        pi_agent: Optional[Any] = None,
    ):
        self.catalog_root = Path(catalog_root)
        self.pi_agent = pi_agent  # kept for interface compat, not used for classification

        # Ensure artifact directories exist
        self._ensure_directories()

    def _ensure_directories(self) -> None:
        """Create artifact directories if they don't exist."""
        dirs = [
            self.catalog_root / "Applications" / "Papers",
            self.catalog_root / "Applications" / "Demos",
            self.catalog_root / "Applications" / "Visuals",
            self.catalog_root / "Applications" / "Articles",
            self.catalog_root / "Applications" / "Web",
            self.catalog_root / "ResearchOutput",
        ]
        for d in dirs:
            d.mkdir(parents=True, exist_ok=True)

    def organize_results(
        self,
        result_dir: Path,
        exp_id: str,
        concept: Any,  # ResearchConcept
        dry_run: bool = False,
    ) -> Tuple[Dict[str, List[PlacementDecision]], Optional[Dict[str, Any]]]:
        """Organize all files from an Aristotle result directory.

        Uses ARISTOTLE_SUMMARY.md (if present) to understand what Aristotle did,
        then classifies and places each file accordingly.

        Returns a tuple of:
        - decisions dict with keys:
          - "theorems": .lean files placed in domain directories
          - "papers": research reports placed in Applications/Papers/
          - "demos": Python demos placed in Applications/Demos/
          - "visuals": SVG diagrams placed in Applications/Visuals/
          - "articles": SciAm-style articles placed in Applications/Articles/
          - "raw": everything else in ResearchOutput/{exp_id}/
          - "rejected": files that failed validation
        - parsed ARISTOTLE_SUMMARY dict (or None), for feeding back into
          the next research cycle via ResearchContext
        """
        # Parse ARISTOTLE_SUMMARY.md for context about what Aristotle did
        summary = self._parse_aristotle_summary(result_dir)
        if summary:
            print(f"[Organizer] Parsed ARISTOTLE_SUMMARY.md: {summary.get('domains_touched', [])} "
                  f"domains, {summary.get('sorries_remaining', '?')} sorries remaining")

        decisions: Dict[str, List[PlacementDecision]] = {
            "theorems": [],
            "papers": [],
            "demos": [],
            "visuals": [],
            "articles": [],
            "raw": [],
            "rejected": [],
        }

        for result_file in sorted(result_dir.rglob("*")):
            if not result_file.is_file():
                continue

            rel_path = result_file.relative_to(result_dir)
            if self._is_build_artifact(rel_path):
                continue

            file_type = self._classify_artifact_type(result_file)

            if file_type == "theorem":
                decision = self._place_lean_file(
                    result_file, exp_id, concept, dry_run, summary=summary
                )
                decisions["theorems"].append(decision)
                print(f"[Organizer] {result_file.name} -> {decision.target_path} ({decision.artifact_type}, {decision.reason})")

            elif file_type == "paper":
                decision = self._place_artifact(
                    result_file, "Applications/Papers", exp_id, concept, dry_run
                )
                decisions["papers"].append(decision)
                print(f"[Organizer] {result_file.name} -> {decision.target_path} (paper)")

            elif file_type == "demo":
                decision = self._place_artifact(
                    result_file, "Applications/Demos", exp_id, concept, dry_run
                )
                decisions["demos"].append(decision)
                print(f"[Organizer] {result_file.name} -> {decision.target_path} (demo)")

            elif file_type == "visual":
                decision = self._place_artifact(
                    result_file, "Applications/Visuals", exp_id, concept, dry_run
                )
                decisions["visuals"].append(decision)
                print(f"[Organizer] {result_file.name} -> {decision.target_path} (visual)")

            elif file_type == "article":
                decision = self._place_artifact(
                    result_file, "Applications/Articles", exp_id, concept, dry_run
                )
                decisions["articles"].append(decision)
                print(f"[Organizer] {result_file.name} -> {decision.target_path} (article)")

            elif file_type == "future_directions":
                decision = self._place_artifact(
                    result_file, "Applications/Papers", exp_id, concept, dry_run,
                    suffix_override="_future_directions.md"
                )
                decisions["papers"].append(decision)
                print(f"[Organizer] {result_file.name} -> {decision.target_path} (future_directions)")

            elif file_type == "metadata":
                decision = self._place_raw(result_file, exp_id, dry_run)
                decisions["raw"].append(decision)

            else:
                decision = self._place_raw(result_file, exp_id, dry_run)
                decisions["raw"].append(decision)

        return decisions, summary

    def _classify_artifact_type(self, file_path: Path) -> str:
        """Classify a file into its artifact type.

        Priority: .lean > name patterns > extension.
        Returns: "theorem" | "paper" | "demo" | "visual" | "article" |
                 "future_directions" | "metadata" | "raw"
        """
        name = file_path.stem
        suffix = file_path.suffix.lower()

        # .lean files are always theorems
        if suffix == ".lean":
            return "theorem"

        # Check metadata
        if suffix == ".json" and "metadata" in name.lower():
            return "metadata"

        # Check name patterns for .md files
        if suffix == ".md":
            name_lower = name.lower()
            # Future directions: highest priority for .md
            for pattern in ARTIFACT_PATTERNS["future_directions"]["names"]:
                if pattern.lower() in name_lower:
                    return "future_directions"
            # Papers: research reports
            for pattern in ARTIFACT_PATTERNS["paper"]["names"]:
                if pattern.lower() in name_lower:
                    return "paper"
            # Articles: discussions, sciam-style
            for pattern in ARTIFACT_PATTERNS["article"]["names"]:
                if pattern.lower() in name_lower:
                    return "article"
            # Check content for classification hints
            try:
                content = file_path.read_text(encoding="utf-8", errors="replace")[:2000]
                content_lower = content.lower()
                if "future directions" in content_lower or "breakthrough opportunities" in content_lower:
                    return "future_directions"
                if "scientific american" in content_lower or "discussion" in content_lower:
                    return "article"
                if "abstract" in content_lower or "research report" in content_lower:
                    return "paper"
            except Exception:
                pass
            # Default .md to article
            return "article"

        # Check demos
        if suffix == ".py":
            return "demo"

        # Check visuals
        if suffix in (".svg", ".png", ".jpg", ".gif"):
            return "visual"

        return "raw"

    def _parse_aristotle_summary(self, result_dir: Path) -> Optional[Dict[str, Any]]:
        """Parse ARISTOTLE_SUMMARY.md to understand what Aristotle did.

        Returns a dict with:
        - domains_touched: list of domain names Aristotle worked on
        - files_created: list of file descriptions from the summary
        - sorries_remaining: number of remaining sorries (if mentioned)
        - key_theorems: list of theorem names mentioned
        - raw_text: the full summary text (first 2000 chars)
        """
        summary_path = result_dir / "ARISTOTLE_SUMMARY.md"
        if not summary_path.exists():
            # Check subdirectories too
            for sub in result_dir.iterdir():
                if sub.is_dir():
                    candidate = sub / "ARISTOTLE_SUMMARY.md"
                    if candidate.exists():
                        summary_path = candidate
                        break

        if not summary_path.exists():
            return None

        try:
            raw_text = summary_path.read_text(encoding="utf-8", errors="replace")
        except Exception:
            return None

        domains_touched = set()
        files_created = []
        sorries_remaining = 0
        key_theorems = []

        # Extract domains from directory structure in the result
        for sub in result_dir.iterdir():
            if sub.is_dir() and sub.name in DOMAIN_DIRS:
                domains_touched.add(sub.name)

        # Extract from summary text
        text_lower = raw_text.lower()

        # Look for domain mentions
        for domain in DOMAIN_DIRS:
            if domain.lower() in text_lower:
                domains_touched.add(domain)

        # Count remaining sorries
        sorry_matches = re.findall(r'(\d+)\s+sorr(?:y|ies)', text_lower)
        if sorry_matches:
            sorries_remaining = int(sorry_matches[-1])

        # Extract theorem names (theorem/lemma declarations mentioned in summary)
        theorem_matches = re.findall(r'(?:theorem|lemma)\s+([a-zA-Z_]\w*)', raw_text)
        key_theorems = theorem_matches[:20]

        # Extract file descriptions (lines like "- **File.lean**" or "Created X.lean")
        file_matches = re.findall(r'\*\*(\w+\.lean)\*\*', raw_text)
        file_matches.extend(re.findall(r'(\w+\.lean)', raw_text))
        files_created = list(dict.fromkeys(file_matches))[:30]  # dedupe, limit

        return {
            "domains_touched": sorted(domains_touched),
            "files_created": files_created,
            "sorries_remaining": sorries_remaining,
            "key_theorems": key_theorems,
            "raw_text": raw_text[:2000],
        }

    def _place_lean_file(
        self,
        source: Path,
        exp_id: str,
        concept: Any,
        dry_run: bool,
        summary: Optional[Dict[str, Any]] = None,
    ) -> PlacementDecision:
        """Place a .lean file into the correct domain directory.

        Classification strategy (in priority order):
        1. Directory path from Aristotle's output (if file is in Algebra/X.lean,
           it goes to Algebra/)
        2. ARISTOTLE_SUMMARY.md context (domains mentioned)
        3. Concept domain (from Pi-Agent concept generation)
        4. Fallback: Speculative/AutoResearch

        No ollama calls — instant classification.
        """
        lean_source = source.read_text(encoding="utf-8", errors="replace")
        sorry_count = lean_source.count("sorry")
        is_complete = sorry_count == 0

        # Strategy 1: Use the directory path from Aristotle's output
        # Aristotle puts files in Domain/Subdir/File.lean — use that directly
        target_domain = ""
        target_subdir = ""
        reason = "Path-based classification"
        confidence = 0.9

        # Walk up from source to find domain directory
        # E.g., result_dir/Pythagorean/NewDiscoveries.lean -> domain=Pythagorean
        # Or: result_dir/Algebra/Core/RingTheory.lean -> domain=Algebra, subdir=Core
        try:
            rel_to_result = source.relative_to(source.parent.parent)  # go up from file to result_dir
            parts = list(source.parent.relative_to(source.parent.parent.parent).parts)
            if parts and normalize_domain(parts[0]) in DOMAIN_DIRS:
                target_domain = normalize_domain(parts[0])
                if len(parts) > 1:
                    target_subdir = "/".join(parts[1:])
                reason = f"Path-based: {source.parent.relative_to(source.parent.parent.parent)}"
                confidence = 0.95
        except (ValueError, IndexError):
            pass

        # If we couldn't determine domain from path, try direct parent
        if not target_domain:
            parent_name = source.parent.name
            normalized_parent = normalize_domain(parent_name)
            if normalized_parent in DOMAIN_DIRS:
                target_domain = normalized_parent
                reason = f"Parent-dir classification: {parent_name} -> {normalized_parent}"
                confidence = 0.85

        # Strategy 2: Use ARISTOTLE_SUMMARY.md context
        if not target_domain and summary:
            domains = summary.get("domains_touched", [])
            if len(domains) == 1:
                target_domain = normalize_domain(domains[0])
                reason = f"Summary-based: only domain mentioned"
                confidence = 0.7
            elif len(domains) > 1:
                # Multiple domains — check which one this file's content matches
                file_content_lower = lean_source[:2000].lower()
                best_domain = ""
                best_score = 0
                for d in domains:
                    score = sum(1 for kw in DOMAIN_KEYWORDS.get(d.lower(), []) if kw.lower() in file_content_lower)
                    if score > best_score:
                        best_score = score
                        best_domain = d
                if best_domain:
                    target_domain = normalize_domain(best_domain)
                    reason = f"Summary+keyword classification (score={best_score})"
                    confidence = 0.6

        # Strategy 3: Use concept domain (normalize from research_domains.json ID)
        if not target_domain:
            raw_domain = getattr(concept, "domain", "Speculative")
            target_domain = normalize_domain(raw_domain)
            reason = f"Concept-domain fallback: {raw_domain} -> {target_domain}"
            confidence = 0.4

        # Strategy 4: Keyword heuristic as last resort
        if target_domain in ("Speculative", "Unknown"):
            heuristic_domain, heuristic_conf = self._heuristic_classify(lean_source)
            normalized_heuristic = normalize_domain(heuristic_domain)
            if heuristic_conf > 0.5:
                target_domain = normalized_heuristic
                reason = "Keyword-heuristic classification"
                confidence = heuristic_conf
        if is_complete:
            # Complete proofs go to their domain directory
            if target_subdir:
                target_dir = self.catalog_root / target_domain / target_subdir
            else:
                target_dir = self.catalog_root / target_domain
            target_path = target_dir / source.name
        else:
            # Proofs with sorries go to Speculative/AutoResearch
            target_dir = self.catalog_root / "Speculative" / "AutoResearch"
            target_path = target_dir / source.name
            reason += f" (has {sorry_count} sorries)"

        # Copy the file
        if not dry_run:
            target_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target_path)

        return PlacementDecision(
            source_path=source,
            target_path=target_path,
            artifact_type="theorem",
            domain=target_domain,
            reason=reason,
            confidence=confidence,
        )

    def _place_artifact(
        self,
        source: Path,
        target_dir_name: str,
        exp_id: str,
        concept: Any,
        dry_run: bool,
        suffix_override: str = "",
    ) -> PlacementDecision:
        """Place a non-.lean artifact (paper, demo, visual, article, etc.)."""
        # Generate a descriptive filename
        concept_title = getattr(concept, "title", "untitled")
        safe_title = re.sub(r'[^a-zA-Z0-9_]', '_', concept_title)[:50]

        suffix = source.suffix
        if suffix_override:
            new_name = f"{safe_title}{suffix_override}"
        elif suffix == ".md" and target_dir_name == "Applications/Papers":
            new_name = f"{safe_title}_paper.md"
        elif suffix == ".md" and target_dir_name == "Applications/Articles":
            new_name = f"{safe_title}_article.md"
        elif suffix == ".py":
            new_name = f"{safe_title}_demo.py"
        elif suffix == ".svg":
            new_name = f"{safe_title}_diagram.svg"
        else:
            new_name = source.name

        target_dir = self.catalog_root / target_dir_name
        target_path = target_dir / new_name

        if not dry_run:
            target_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target_path)

        domain = getattr(concept, "domain", "unknown")

        return PlacementDecision(
            source_path=source,
            target_path=target_path,
            artifact_type=target_dir_name.split("/")[-1].lower().rstrip("s"),
            domain=domain,
            reason=f"Placed in {target_dir_name}",
            confidence=0.8,
        )

    def _place_raw(self, source: Path, exp_id: str, dry_run: bool) -> PlacementDecision:
        """Place raw experiment data in ResearchOutput/{exp_id}/."""
        target_dir = self.catalog_root / "ResearchOutput" / exp_id
        target_path = target_dir / source.name

        if not dry_run:
            target_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target_path)

        return PlacementDecision(
            source_path=source,
            target_path=target_path,
            artifact_type="raw",
            domain="ResearchOutput",
            reason="Raw experiment data for provenance",
            confidence=1.0,
        )

    def _is_build_artifact(self, rel_path: Path) -> bool:
        """Check if a path is a build artifact."""
        parts = rel_path.parts
        for skip_dir in SKIP_DIRS:
            if skip_dir in parts:
                return True
        # Skip lake-manifest.json, lakefile, etc.
        name = rel_path.name
        if name.startswith("lake-manifest") or name.startswith("lakefile"):
            return True
        return False

    def _heuristic_classify(self, lean_source: str) -> tuple:
        """Classify a .lean file by keyword matching. Returns (domain, confidence)."""
        content_lower = lean_source[:3000].lower()
        best_domain_key = "speculative"
        best_score = 0
        for domain, keywords in DOMAIN_KEYWORDS.items():
            score = sum(1 for kw in keywords if kw in content_lower)
            if score > best_score:
                best_score = score
                best_domain_key = domain
        confidence = min(best_score / 3.0, 0.9)
        return normalize_domain(best_domain_key), confidence

    def generate_manifest(
        self,
        decisions: Dict[str, List[PlacementDecision]],
        exp_id: str,
    ) -> Dict[str, Any]:
        """Generate a manifest of all placement decisions for a cycle."""
        manifest = {
            "experiment_id": exp_id,
            "theorems": [],
            "papers": [],
            "demos": [],
            "visuals": [],
            "articles": [],
            "raw": [],
            "rejected": [],
        }

        for category, decision_list in decisions.items():
            for d in decision_list:
                manifest[category].append({
                    "source": str(d.source_path),
                    "target": str(d.target_path),
                    "type": d.artifact_type,
                    "domain": d.domain,
                    "reason": d.reason,
                    "confidence": d.confidence,
                })

        return manifest