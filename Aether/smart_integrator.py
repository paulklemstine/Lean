#!/usr/bin/env python3
"""SmartIntegrator: Pi-Agent guided catalog integration.

Uses Pi-Agent to analyze Aristotle's output and determine the correct
placement for each new/modified file within the Catalog's domain structure.

Placement rules:
- Existing files go back to their original location
- New files are classified by Pi-Agent into the appropriate domain
- Artifacts go to Aether/results/{exp_id}/
- Proofs with sorries go to Speculative/AutoResearch/PENDING_*
- Complete proofs go to their classified domain
"""

import json
import re
import shutil
import textwrap
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any

from pi_agent_client import PiAgentClient


@dataclass
class PlacementDecision:
    """Where a file should be placed in the catalog."""
    source_path: Path
    target_path: Path
    reason: str
    confidence: float = 0.0
    domain: str = ""


class CatalogClassifier:
    """Uses Pi-Agent to classify Lean files into catalog domains."""

    DOMAIN_DIRECTORIES = {
        "algebra": "Algebra",
        "geometry": "Geometry",
        "logic": "Logic",
        "physics": "Physics",
        "computation": "Computation",
        "cryptography": "Cryptography",
        "pythagorean": "Pythagorean",
        "tropical": "Tropical",
        "eml": "EML",
        "machinelearning": "MachineLearning",
        "bridges": "Bridges",
        "speculative": "Speculative",
        "shared": "Shared",
    }

    def __init__(self, pi_agent: Optional[PiAgentClient] = None):
        self.pi_agent = pi_agent

    def classify_file(self, lean_source: str, file_name: str, use_pi_agent: bool = False) -> Tuple[str, float, str]:
        """Classify a Lean file into a catalog domain.

        Returns (domain_dir, confidence, reason).
        """
        # Fast heuristic classification first
        heuristic_domain, heuristic_conf = self._heuristic_classify(lean_source)

        # Pi-Agent classification is expensive (ollama call).
        # Only use it if explicitly requested.
        if use_pi_agent and self.pi_agent:
            agent_domain, agent_conf, agent_reason = self._pi_agent_classify(
                lean_source, file_name
            )
            # Weighted blend: if both agree, high confidence
            if heuristic_domain == agent_domain:
                return agent_domain, max(heuristic_conf, agent_conf) + 0.1, \
                       f"Heuristic + Pi-Agent agree: {agent_reason}"
            # If Pi-Agent is more confident, trust it
            if agent_conf > heuristic_conf + 0.2:
                return agent_domain, agent_conf, f"Pi-Agent override: {agent_reason}"

        return heuristic_domain, heuristic_conf, "Heuristic classification"

    def _heuristic_classify(self, lean_source: str) -> Tuple[str, float]:
        """Keyword-based heuristic classification."""
        lean_lower = lean_source.lower()

        domain_scores = {
            "algebra": 0,
            "geometry": 0,
            "logic": 0,
            "physics": 0,
            "computation": 0,
            "cryptography": 0,
            "pythagorean": 0,
            "tropical": 0,
            "eml": 0,
            "machinelearning": 0,
            "bridges": 0,
            "speculative": 0,
        }

        # Algebra keywords
        if any(k in lean_lower for k in [
            "galois", "field", "ring", "module", "vector space",
            "representation", "lie algebra", "division algebra"
        ]):
            domain_scores["algebra"] += 2

        # Geometry keywords
        if any(k in lean_lower for k in [
            "manifold", "metric", "curve", "surface", "gravitational",
            "lens", "spacetime", "stereographic"
        ]):
            domain_scores["geometry"] += 2

        # Logic keywords
        if any(k in lean_lower for k in [
            "oracle", "computable", "complexity", "p vs np",
            "proof", "tautology", "formal"
        ]):
            domain_scores["logic"] += 2

        # Physics keywords
        if any(k in lean_lower for k in [
            "quantum", "entropy", "thermodynamic", "black hole",
            "cosmic", "cmb", "gravity"
        ]):
            domain_scores["physics"] += 2

        # Computation keywords
        if any(k in lean_lower for k in [
            "algorithm", "complexity class", "turing", "recursive",
            "decidable", "computable"
        ]):
            domain_scores["computation"] += 2

        # Cryptography keywords
        if any(k in lean_lower for k in [
            "rsa", "encryption", "cipher", "cryptographic",
            "factoring", "prime", "carmichael"
        ]):
            domain_scores["cryptography"] += 2

        # Pythagorean keywords
        if any(k in lean_lower for k in [
            "berggren", "pythagorean triple", "descent",
            "fibonacci", "nilpotent", "quadruple"
        ]):
            domain_scores["pythagorean"] += 2

        # Tropical keywords
        if any(k in lean_lower for k in [
            "tropical", "max-plus", "semiring", "tropicalization",
            "newton polygon"
        ]):
            domain_scores["tropical"] += 3  # Strong signal

        # EML keywords
        if any(k in lean_lower for k in [
            "eml", "self-pairing", "meta-language", "diagonal",
            "etower"
        ]):
            domain_scores["eml"] += 3

        # MachineLearning keywords
        if any(k in lean_lower for k in [
            "neural", "relu", "backprop", "gradient",
            "network", "distillation", "rsil"
        ]):
            domain_scores["machinelearning"] += 3

        # Bridges keywords
        if any(k in lean_lower for k in [
            "bridge", "unified", "cross-domain", "connection",
            "analogue"
        ]):
            domain_scores["bridges"] += 2

        # Speculative keywords
        if any(k in lean_lower for k in [
            "sci-fi", "hyperspace", "alien", "consciousness",
            "time travel", "hypothetical"
        ]):
            domain_scores["speculative"] += 2

        # Check imports for domain hints
        for line in lean_source.splitlines():
            if line.strip().startswith("import "):
                import_line = line.lower()
                for domain, score in domain_scores.items():
                    if domain in import_line.replace(".", ""):
                        domain_scores[domain] += 1

        best_domain = max(domain_scores, key=domain_scores.get)
        best_score = domain_scores[best_domain]
        confidence = min(best_score / 5.0, 1.0)

        return best_domain, confidence

    def _pi_agent_classify(
        self, lean_source: str, file_name: str
    ) -> Tuple[str, float, str]:
        """Ask Pi-Agent to classify the file."""
        if not self.pi_agent:
            return "speculative", 0.0, "No Pi-Agent available"

        system = textwrap.dedent("""\
            You are a mathematical librarian. Your job is to classify
            Lean 4 source files into the correct domain directory.
            Output ONLY structured JSON.
        """)

        # Sample the Lean source (first 100 lines)
        sample = "\n".join(lean_source.splitlines()[:100])

        user = textwrap.dedent(f"""\
            File name: {file_name}

            Sample content:
            ```lean
            {sample}
            ```

            Available domains:
            - Algebra (Galois theory, rings, modules, Lie algebras)
            - Geometry (manifolds, metrics, gravitational factoring)
            - Logic (complexity, oracles, formal systems)
            - Physics (quantum mechanics, entropy, cosmology)
            - Computation (algorithms, complexity classes, Turing)
            - Cryptography (RSA, factoring, primes, ciphers)
            - Pythagorean (Berggren trees, triples, descent)
            - Tropical (tropical geometry, max-plus, semirings)
            - EML (self-pairing, meta-language, diagonal forms)
            - MachineLearning (neural nets, ReLU, backprop)
            - Bridges (cross-domain unification)
            - Speculative (sci-fi, future research)
            - Shared (common utilities)

            Respond with ONLY this JSON:
            {{
              "domain": "one of the above",
              "confidence": 0.0-1.0,
              "reason": "brief explanation"
            }}
        """)

        raw = self.pi_agent._call_ollama(system, user)
        try:
            match = re.search(r'\{.*\}', raw, re.DOTALL)
            if match:
                data = json.loads(match.group())
                domain = data.get("domain", "speculative").lower().replace(" ", "").replace("_", "")
                confidence = float(data.get("confidence", 0.5))
                reason = data.get("reason", "Pi-Agent classification")

                # Normalize domain names
                domain_map = {
                    "machinelearning": "machinelearning",
                    "machine_learning": "machinelearning",
                    "ml": "machinelearning",
                    "neuralnets": "machinelearning",
                }
                domain = domain_map.get(domain, domain)

                return domain, confidence, reason
        except Exception:
            pass

        return "speculative", 0.3, "Pi-Agent classification failed"


class SmartIntegrator:
    """Intelligent integration of Aristotle results into the Catalog."""

    def __init__(
        self,
        catalog_root: Path,
        pi_agent: Optional[PiAgentClient] = None,
        workspace: Optional[Path] = None,
    ):
        self.catalog_root = Path(catalog_root)
        self.classifier = CatalogClassifier(pi_agent)
        self.workspace = workspace or Path("../workspace")

    def integrate_result_directory(
        self,
        result_dir: Path,
        exp_id: str,
        dry_run: bool = False,
    ) -> Dict[str, List[PlacementDecision]]:
        """Integrate all files from a result directory.

        v2: Uses Pi-Agent diff analysis when available, with heuristic fallback.
        Returns a dict of:
        - placed: files that were integrated into the catalog
        - artifacts: research artifacts (reports, demos, SVGs)
        - unchanged: files that didn't change
        - rejected: files that failed validation
        """
        # Try Pi-Agent diff analysis first (v2)
        if self.classifier.pi_agent:
            try:
                return self._integrate_with_pi_agent(result_dir, exp_id, dry_run)
            except Exception as e:
                print(f"[SmartIntegrator] Pi-Agent analysis failed: {e}. Falling back to heuristic.")

        return self._integrate_heuristic(result_dir, exp_id, dry_run)

    def _integrate_with_pi_agent(
        self,
        result_dir: Path,
        exp_id: str,
        dry_run: bool = False,
    ) -> Dict[str, List[PlacementDecision]]:
        """v2: Pi-Agent guided file-by-file integration."""
        decisions = {
            "placed": [],
            "artifacts": [],
            "unchanged": [],
            "rejected": [],
        }

        # Build file analysis list for Pi-Agent
        result_files = []
        for result_file in result_dir.rglob("*"):
            if not result_file.is_file():
                continue
            rel = result_file.relative_to(result_dir)

            # Skip build artifacts
            if self._is_build_artifact(rel):
                continue

            original = self.catalog_root / rel
            if original.exists():
                orig_text = original.read_text(encoding="utf-8")
                new_text = result_file.read_text(encoding="utf-8")
                if orig_text == new_text:
                    status = "unchanged"
                else:
                    status = "modified"
            else:
                status = "new"

            preview = ""
            if result_file.suffix == ".lean":
                preview = result_file.read_text(encoding="utf-8")[:200]
            elif result_file.suffix in {".md", ".py"}:
                preview = result_file.read_text(encoding="utf-8")[:100]

            result_files.append({
                "path": str(rel),
                "status": status,
                "content_preview": preview,
            })

        # Call Pi-Agent for decisions. The method does not exist on the agent
        # (audit 2026-08-21) — degrade to empty decisions (rule-based paths
        # below) instead of crashing the whole integration run.
        try:
            pi_decisions = self.classifier.pi_agent.analyze_diff_for_integration(
                result_files, self.catalog_root
            )
        except AttributeError:
            print("[SmartIntegrate] pi_agent.analyze_diff_for_integration is not "
                  "available; falling back to rule-based placement")
            pi_decisions = []

        # Apply Pi-Agent decisions
        for pd in pi_decisions:
            src_path = result_dir / pd.get("source", "")
            if not src_path.exists():
                continue
            action = pd.get("action", "reject")
            target_str = pd.get("target", "")
            reason = pd.get("reason", "Pi-Agent decision")

            if action == "artifact":
                artifact_dir = self.workspace / "artifacts" / exp_id
                if not dry_run:
                    artifact_dir.mkdir(parents=True, exist_ok=True)
                    dest = artifact_dir / src_path.name
                    shutil.copy2(src_path, dest)
                decisions["artifacts"].append(PlacementDecision(
                    source_path=src_path,
                    target_path=artifact_dir / src_path.name,
                    reason=reason,
                    confidence=0.9,
                    domain="artifacts",
                ))
            elif action == "place":
                target = self.catalog_root / target_str
                if src_path.suffix == ".lean":
                    lean_source = src_path.read_text(encoding="utf-8")
                    validation = self._validate_lean_file(lean_source)
                    if not validation["ok"]:
                        decisions["rejected"].append(PlacementDecision(
                            source_path=src_path,
                            target_path=target,
                            reason=f"Validation failed: {validation['error']}",
                            confidence=0.0,
                            domain="",
                        ))
                        continue
                if not dry_run:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src_path, target)
                domain = self._guess_domain_from_path(Path(target_str))
                decisions["placed"].append(PlacementDecision(
                    source_path=src_path,
                    target_path=target,
                    reason=reason,
                    confidence=0.9,
                    domain=domain,
                ))
            else:
                decisions["rejected"].append(PlacementDecision(
                    source_path=src_path,
                    target_path=self.catalog_root / target_str if target_str else src_path,
                    reason=reason,
                    confidence=0.9,
                    domain="",
                ))

        return decisions

    def _integrate_heuristic(
        self,
        result_dir: Path,
        exp_id: str,
        dry_run: bool = False,
    ) -> Dict[str, List[PlacementDecision]]:
        """Fallback heuristic integration (v1 behavior)."""
        decisions = {
            "placed": [],
            "artifacts": [],
            "unchanged": [],
            "rejected": [],
        }

        for result_file in result_dir.rglob("*"):
            if not result_file.is_file():
                continue

            rel = result_file.relative_to(result_dir)
            original = self.catalog_root / rel

            # Skip lake/build artifacts
            if self._is_build_artifact(rel):
                continue

            # Handle artifacts separately
            if self._is_artifact(result_file):
                artifact_dir = self.workspace / "artifacts" / exp_id
                if not dry_run:
                    artifact_dir.mkdir(parents=True, exist_ok=True)
                    dest = artifact_dir / result_file.name
                    shutil.copy2(result_file, dest)
                decisions["artifacts"].append(PlacementDecision(
                    source_path=result_file,
                    target_path=artifact_dir / result_file.name,
                    reason="Artifact extracted",
                    confidence=1.0,
                    domain="artifacts",
                ))
                continue

            # Check if it's a .lean file
            if result_file.suffix != ".lean":
                continue

            # Read the file content
            lean_source = result_file.read_text(encoding="utf-8")

            # Skip unchanged files
            if original.exists():
                original_text = original.read_text(encoding="utf-8")
                if original_text == lean_source:
                    decisions["unchanged"].append(PlacementDecision(
                        source_path=result_file,
                        target_path=original,
                        reason="Unchanged",
                        confidence=1.0,
                    ))
                    continue

            # SAFETY: Never overwrite existing catalog files with Aristotle results.
            if original.exists():
                if result_file.name == "Main.lean":
                    domain, confidence, reason = self.classifier.classify_file(
                        lean_source, result_file.name
                    )
                    target = self.catalog_root / "Speculative" / "AutoResearch" / f"{exp_id}_{result_file.name}"
                    reason = f"Target theorem (preserved original {rel})"
                else:
                    decisions["rejected"].append(PlacementDecision(
                        source_path=result_file,
                        target_path=original,
                        reason=f"Unexpected modification of existing file {rel} — manual review required",
                        confidence=1.0,
                        domain=self._guess_domain_from_path(rel),
                    ))
                    continue
            else:
                # New file: classify with heuristic
                domain, confidence, reason = self.classifier.classify_file(
                    lean_source, result_file.name
                )
                target = self._choose_target_path(
                    result_file, domain, lean_source, exp_id
                )

            # Validate before placing
            validation = self._validate_lean_file(lean_source)
            if not validation["ok"]:
                decisions["rejected"].append(PlacementDecision(
                    source_path=result_file,
                    target_path=target,
                    reason=f"Validation failed: {validation['error']}",
                    confidence=confidence,
                    domain=domain,
                ))
                continue

            # Place the file
            if not dry_run:
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(result_file, target)

            decisions["placed"].append(PlacementDecision(
                source_path=result_file,
                target_path=target,
                reason=reason,
                confidence=confidence,
                domain=domain,
            ))

        return decisions

    def _is_build_artifact(self, rel_path: Path) -> bool:
        """Check if a path is a build artifact."""
        parts = rel_path.parts
        build_dirs = {".lake", "build", "lake-packages", "ir", "lib"}
        return any(p in build_dirs for p in parts)

    def _is_artifact(self, file_path: Path) -> bool:
        """Check if a file is an artifact."""
        name = file_path.name.lower()
        artifact_exts = {".md", ".py", ".svg", ".png", ".txt", ".json"}
        artifact_names = {"demo", "diagram", "report", "discussion", "readme"}
        return (
            file_path.suffix.lower() in artifact_exts
            or any(a in name for a in artifact_names)
        )

    def _guess_domain_from_path(self, rel_path: Path) -> str:
        """Infer domain from file path."""
        path_str = str(rel_path).lower()
        for domain, dirname in self.classifier.DOMAIN_DIRECTORIES.items():
            if dirname.lower() in path_str:
                return domain
        return "speculative"

    def _choose_target_path(
        self,
        result_file: Path,
        domain: str,
        lean_source: str,
        exp_id: str,
    ) -> Path:
        """Choose the final target path for a new file."""
        # Get the domain directory
        domain_dir = self.classifier.DOMAIN_DIRECTORIES.get(
            domain, "Speculative"
        )

        # Check if the file has sorrys (incomplete proofs)
        sorry_count = lean_source.lower().count("sorry")

        if sorry_count > 0:
            # Incomplete proof: place in Speculative/AutoResearch
            target_dir = self.catalog_root / "Speculative" / "AutoResearch"
            target = target_dir / f"PENDING_{domain}_{exp_id}_{result_file.name}"
        else:
            # Complete proof: place in the appropriate domain
            target_dir = self.catalog_root / domain_dir
            # Try to find an appropriate subdirectory
            subdirs = [d for d in target_dir.iterdir() if d.is_dir()]
            if subdirs:
                # Use heuristic to pick best subdir
                best_subdir = self._pick_subdirectory(
                    subdirs, lean_source
                )
                target = best_subdir / result_file.name
            else:
                target = target_dir / result_file.name

        return target

    def _pick_subdirectory(
        self, subdirs: List[Path], lean_source: str
    ) -> Path:
        """Pick the best subdirectory based on content."""
        lean_lower = lean_source.lower()
        best_dir = subdirs[0]
        best_score = 0

        for subdir in subdirs:
            name = subdir.name.lower()
            score = 0

            # Check if any keywords in the lean source match the dir name
            if name.replace("_", " ") in lean_lower:
                score += 3
            # Check for partial matches
            for part in name.split("_"):
                if len(part) > 3 and part in lean_lower:
                    score += 1

            if score > best_score:
                best_score = score
                best_dir = subdir

        return best_dir

    def _validate_lean_file(self, lean_source: str) -> Dict[str, Any]:
        """Validate Lean source for basic structural correctness."""
        # Check for balanced braces
        open_count = lean_source.count("{") + lean_source.count("(") + lean_source.count("[")
        close_count = lean_source.count("}") + lean_source.count(")") + lean_source.count("]")

        if open_count != close_count:
            return {"ok": False, "error": "Unbalanced braces"}

        # Check for non-ASCII garbage (common with LLM outputs)
        replacement_char = "\ufffd"
        if "\x00" in lean_source or replacement_char in lean_source:
            return {"ok": False, "error": "Contains null/replacement characters"}

        # Must have at least one declaration
        has_decl = any(
            kw in lean_source for kw in
            ["theorem ", "lemma ", "def ", "structure ", "class ", "instance "]
        )
        if not has_decl:
            return {"ok": False, "error": "No Lean declarations found"}

        return {"ok": True, "error": ""}

    def generate_manifest(
        self,
        decisions: Dict[str, List[PlacementDecision]],
        exp_id: str,
    ) -> Path:
        """Generate a JSON manifest of integration decisions."""
        manifest = {
            "experiment_id": exp_id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "summary": {
                "placed": len(decisions["placed"]),
                "artifacts": len(decisions["artifacts"]),
                "unchanged": len(decisions["unchanged"]),
                "rejected": len(decisions["rejected"]),
            },
            "placed_files": [
                {
                    "source": str(d.source_path),
                    "target": str(d.target_path),
                    "domain": d.domain,
                    "confidence": d.confidence,
                    "reason": d.reason,
                }
                for d in decisions["placed"]
            ],
            "artifacts": [
                {
                    "source": str(d.source_path),
                    "target": str(d.target_path),
                }
                for d in decisions["artifacts"]
            ],
            "rejected_files": [
                {
                    "source": str(d.source_path),
                    "reason": d.reason,
                }
                for d in decisions["rejected"]
            ],
        }

        manifest_path = self.workspace / "changes" / f"manifest_{exp_id}.json"
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        return manifest_path


# Import for type hints
from datetime import datetime, timezone
