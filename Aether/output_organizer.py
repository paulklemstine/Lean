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
from typing import Dict, List, Optional, Any


@dataclass
class PlacementDecision:
    """Where a file should be placed in the Catalog."""
    source_path: Path
    target_path: Path
    artifact_type: str  # "theorem" | "paper" | "demo" | "visual" | "article" | "raw" | "metadata"
    domain: str
    reason: str
    confidence: float = 0.0


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
        "names": ["DISCUSSION", "discussion", "article", "sciam", "SCIAM"],
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
        pi_agent_timeout: int = 30,
    ):
        self.catalog_root = Path(catalog_root)
        self.pi_agent = pi_agent
        self.pi_agent_timeout = pi_agent_timeout  # seconds per classification call

        # Ensure artifact directories exist
        self._ensure_directories()

    def _ensure_directories(self) -> None:
        """Create artifact directories if they don't exist."""
        dirs = [
            self.catalog_root / "Applications" / "Papers",
            self.catalog_root / "Applications" / "Demos",
            self.catalog_root / "Applications" / "Visuals",
            self.catalog_root / "Applications" / "Articles",
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
    ) -> Dict[str, List[PlacementDecision]]:
        """Organize all files from an Aristotle result directory.

        Prints progress for each file to help diagnose hangs.

        Returns a dict with keys:
        - "theorems": .lean files placed in domain directories
        - "papers": research reports placed in Applications/Papers/
        - "demos": Python demos placed in Applications/Demos/
        - "visuals": SVG diagrams placed in Applications/Visuals/
        - "articles": SciAm-style articles placed in Applications/Articles/
        - "raw": everything else in ResearchOutput/{exp_id}/
        - "rejected": files that failed validation
        """
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
            print(f"[Organizer] classifying {result_file.name} as {file_type}")

            if file_type == "theorem":
                decision = self._place_lean_file(
                    result_file, exp_id, concept, dry_run
                )
                decisions["theorems"].append(decision)

            elif file_type == "paper":
                decision = self._place_artifact(
                    result_file, "Applications/Papers", exp_id, concept, dry_run
                )
                decisions["papers"].append(decision)

            elif file_type == "demo":
                decision = self._place_artifact(
                    result_file, "Applications/Demos", exp_id, concept, dry_run
                )
                decisions["demos"].append(decision)

            elif file_type == "visual":
                decision = self._place_artifact(
                    result_file, "Applications/Visuals", exp_id, concept, dry_run
                )
                decisions["visuals"].append(decision)

            elif file_type == "article":
                decision = self._place_artifact(
                    result_file, "Applications/Articles", exp_id, concept, dry_run
                )
                decisions["articles"].append(decision)

            elif file_type == "metadata":
                # Always goes to raw
                decision = self._place_raw(result_file, exp_id, dry_run)
                decisions["raw"].append(decision)

            else:
                # Unknown type: preserve in ResearchOutput for provenance
                decision = self._place_raw(result_file, exp_id, dry_run)
                decisions["raw"].append(decision)

        return decisions

    def _classify_artifact_type(self, file_path: Path) -> str:
        """Classify a file into its artifact type.

        Priority: .lean > name patterns > extension.
        Returns: "theorem" | "paper" | "demo" | "visual" | "article" | "metadata" | "raw"
        """
        name = file_path.stem
        suffix = file_path.suffix.lower()

        # .lean files are always theorems
        if suffix == ".lean":
            return "theorem"

        # Check metadata
        if suffix == ".json" and "metadata" in name.lower():
            return "metadata"

        # Check name patterns for papers vs articles (both .md)
        if suffix == ".md":
            name_lower = name.lower()
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

    def _place_lean_file(
        self,
        source: Path,
        exp_id: str,
        concept: Any,
        dry_run: bool,
    ) -> PlacementDecision:
        """Place a .lean file into the correct domain directory.

        - If the proof has no sorries: place in {domain}/{subdir}/
        - If the proof has sorries: place in Speculative/AutoResearch/

        Pi-Agent is consulted for domain classification.
        """
        lean_source = source.read_text(encoding="utf-8", errors="replace")
        sorry_count = lean_source.count("sorry")
        is_complete = sorry_count == 0

        target_domain = getattr(concept, "domain", "Speculative")
        target_subdir = ""
        reason = "Heuristic classification"
        confidence = 0.4

        # Try Pi-Agent classification (with timeout guard)
        if self.pi_agent:
            try:
                import signal
                old_handler = None
                try:
                    def _timeout_handler(signum, frame):
                        raise TimeoutError(f"Pi-Agent classification timed out after {self.pi_agent_timeout}s")
                    old_handler = signal.signal(signal.SIGALRM, _timeout_handler)
                    signal.alarm(self.pi_agent_timeout)
                except (ValueError, OSError):
                    old_handler = None  # Not in main thread — can't use signals

                try:
                    pi_classification = self.pi_agent.classify_file_placement(
                        lean_source=lean_source,
                        file_name=source.name,
                        concept=concept,
                    )
                    if pi_classification and pi_classification.get("confidence", 0) >= 0.5:
                        target_domain = pi_classification["domain"]
                        target_subdir = pi_classification.get("subdirectory", "")
                        is_complete = pi_classification.get("is_complete_proof", is_complete)
                        reason = pi_classification.get("reason", "Pi-Agent classification")
                        confidence = pi_classification["confidence"]
                        print(f"[Organizer] {source.name} -> {target_domain}/{target_subdir or '.'} (pi-agent, conf={confidence:.2f})")
                except (TimeoutError, Exception) as e:
                    print(f"[Organizer] Pi-Agent classification failed for {source.name}: {e}")
                finally:
                    if old_handler is not None:
                        signal.alarm(0)
                        signal.signal(signal.SIGALRM, old_handler)
            except Exception as e:
                print(f"[Organizer] Pi-Agent classification error for {source.name}: {e}")

        # Determine final target path
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
    ) -> PlacementDecision:
        """Place a non-.lean artifact (paper, demo, visual, article)."""
        # Generate a descriptive filename
        concept_title = getattr(concept, "title", "untitled")
        safe_title = re.sub(r'[^a-zA-Z0-9_]', '_', concept_title)[:50]

        suffix = source.suffix
        if suffix == ".md" and target_dir_name == "Applications/Papers":
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