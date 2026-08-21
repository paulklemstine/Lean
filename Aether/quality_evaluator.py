#!/usr/bin/env python3
"""QualityEvaluator: 8-axis quality scoring for Aristotle's output.

Replaces the binary trivial/non-trivial gate with a multi-dimensional
quality assessment covering proof depth, novelty, cross-domain bridging,
artifact richness, actionability, importance, usefulness, and applications.
"""

import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Any

try:
    from arxiv_provider import ArxivTexProvider
except ImportError:
    ArxivTexProvider = None


def _safe_float(val: Any, default: float = 0.5) -> float:
    """Safely convert val to float, handling int, float, str, dict (nested score), and None."""
    if val is None:
        return default
    if isinstance(val, (int, float)):
        return float(val)
    if isinstance(val, dict):
        for k in ("score", "value", "rating", "val", "composite", "novelty", "proof_depth"):
            if k in val:
                return _safe_float(val[k], default)
        return default
    if isinstance(val, str):
        try:
            return float(val.strip())
        except ValueError:
            return default
    try:
        return float(val)
    except (ValueError, TypeError):
        return default


# Tactics considered "interesting" (non-trivial proof effort)
DEEP_TACTICS = {
    "induction", "rcases", "obtain", "by_contra", "by_cases",
    "omega", "linarith", "nlinarith", "field_simp", "ring_nf",
    "push_cast", "norm_cast", "ext", "funext", "conv",
    "calc", "have", "suffices", "refine", "apply",
    "exact", "constructor", "cases", "match",
}

# Tactics considered "shallow" (minimal effort)
SHALLOW_TACTICS = {"trivial", "simp", "rfl", "decide", "norm_num", "tauto", "aesop"}

# Domain keywords for cross-domain detection
DOMAIN_KEYWORDS = {
    "Algebra": ["ring", "group", "field", "module", "galois", "semiring", "homomorphism", "ideal"],
    "Analysis": ["continuous", "differentiable", "limit", "integral", "measure", "metric"],
    "NumberTheory": ["prime", "divisor", "modular", "diophantine", "euler", "fermat"],
    "Topology": ["open", "closed", "compact", "connected", "homotopy", "fundamental"],
    "Geometry": ["manifold", "curve", "surface", "projective", "affine", "convex"],
    "Combinatorics": ["finset", "card", "graph", "coloring", "partition", "ramsey"],
    "Logic": ["decidable", "propositional", "constructive", "classical", "axiom"],
    "Computation": ["turing", "complexity", "circuit", "automaton", "recursive"],
    "Physics": ["quantum", "hamiltonian", "lagrangian", "energy", "momentum"],
    "Probability": ["random", "expectation", "variance", "distribution", "martingale"],
    "Tropical": ["tropical", "min_plus", "idempotent", "semiring"],
    "Cryptography": ["encryption", "signature", "hash", "lattice", "discrete_log"],
    "EML": ["eml", "exp_log", "exponential_logarithmic", "emlneuron", "emlactivation", "single_operator"],
    "MachineLearning": ["neural", "network", "perceptron", "attention", "training", "gradient", "backprop",
                         "activation", "softmax", "loss", "overfitting", "regularization", "deep_learning"],
    "Pythagorean": ["pythagorean", "berggren", "primitive_triple", "tree", "pell"],
}


@dataclass
class QualityScore:
    """9-dimensional quality assessment of Aristotle's output."""
    proof_depth: float = 0.0
    novelty: float = 0.0
    cross_domain: float = 0.0
    artifact_richness: float = 0.0
    actionability: float = 0.0
    importance: float = 0.0
    usefulness: float = 0.0
    applications: float = 0.0
    catalog_anchoring: float = 0.0
    pegb_compliance: float = 0.0  # 0-1 score for PEGB structural requirement
    phase: str = "B"  # Default to Phase B (full artifact evaluation)

    # Default weights (direction-driven weights override these)
    _BASE_WEIGHTS = {
        "proof_depth": 0.15,
        "novelty": 0.15,
        "cross_domain": 0.10,
        "artifact_richness": 0.10,
        "actionability": 0.10,
        "importance": 0.15,
        "usefulness": 0.10,
        "applications": 0.10,
        "catalog_anchoring": 0.05,
    }

    def composite_with_domains(self, domains: list = None) -> float:
        """Direction-driven weighted composite score.

        When the research direction has domain tags, adjust weights to
        reward qualities relevant to that domain:
        - NumberTheory/Analysis: boost proof_depth, novelty
        - Computation/Logic: boost actionability, applications
        - Novelty/Speculative: boost novelty
        - Physics: boost applications, cross_domain
        - Algebra/Geometry: boost proof_depth, importance
        Default (no domains): uniform weights.
        """
        w = dict(self._BASE_WEIGHTS)

        if domains:
            domain_set = set(d.lower() for d in domains)
            # Boost proof_depth for theoretical domains
            if domain_set & {"numbertheory", "analysis", "algebra", "geometry", "logic"}:
                w["proof_depth"] = w.get("proof_depth", 0.15) + 0.05
                w["novelty"] = w.get("novelty", 0.15) + 0.03
            # Boost applications for applied domains
            if domain_set & {"computation", "machinelearning", "physics", "cryptography"}:
                w["applications"] = w.get("applications", 0.10) + 0.05
                w["actionability"] = w.get("actionability", 0.10) + 0.03
            # Boost novelty for speculative/novelty domains
            if domain_set & {"novelty", "speculative"}:
                w["novelty"] = w.get("novelty", 0.15) + 0.08

        if self.phase == "A":
            # Phase A does not produce artifacts; zero out their weights
            w["artifact_richness"] = 0.0
            w["actionability"] = 0.0
            w["applications"] = 0.0

        # Normalize weights to sum to 1.0
        total = sum(w.values())
        if total == 0:
            total = 1.0
        w = {k: v / total for k, v in w.items()}

        return (
            w["proof_depth"] * self.proof_depth +
            w["novelty"] * self.novelty +
            w["cross_domain"] * self.cross_domain +
            w["artifact_richness"] * self.artifact_richness +
            w["actionability"] * self.actionability +
            w["importance"] * self.importance +
            w["usefulness"] * self.usefulness +
            w["applications"] * self.applications +
            w["catalog_anchoring"] * self.catalog_anchoring
        )

    @property
    def composite(self) -> float:
        """Weighted composite score (9 axes) using uniform default weights.

        Use composite_with_domains(domains) for direction-driven scoring.
        """
        return self.composite_with_domains(domains=None)

    @property
    def grade(self) -> str:
        c = self.composite
        if c >= 0.7:
            return "world_class"
        if c >= 0.5:
            return "substantial"
        if c >= 0.3:
            return "partial"
        if c >= 0.15:
            return "shallow"
        return "trivial"

    def to_dict(self) -> dict:
        return {
            "proof_depth": round(self.proof_depth, 4),
            "novelty": round(self.novelty, 4),
            "cross_domain": round(self.cross_domain, 4),
            "artifact_richness": round(self.artifact_richness, 4),
            "actionability": round(self.actionability, 4),
            "importance": round(self.importance, 4),
            "usefulness": round(self.usefulness, 4),
            "applications": round(self.applications, 4),
            "catalog_anchoring": round(self.catalog_anchoring, 4),
            "composite": round(self.composite, 4),
            "grade": self.grade,
        }

    @classmethod
    def from_dict(cls, d: dict) -> "QualityScore":
        """Reconstruct a QualityScore from a to_dict() snapshot (used by the
        Phase 3 eval cache to restore a cached quality_detail). Only the 9
        axis fields are read; composite/grade are derived."""
        d = d or {}
        return cls(**{k: _safe_float(d.get(k), 0.0) for k in (
            "proof_depth", "novelty", "cross_domain", "artifact_richness",
            "actionability", "importance", "usefulness", "applications",
            "catalog_anchoring")})

    def breakdown_str(self) -> str:
        """Human-readable breakdown."""
        lines = [f"Quality: {self.grade.upper()} (composite={self.composite:.3f})"]
        for dim in ["proof_depth", "novelty", "cross_domain", "artifact_richness",
                     "actionability", "importance", "usefulness", "applications",
                     "catalog_anchoring"]:
            val = getattr(self, dim)
            bar = "█" * int(val * 10) + "░" * (10 - int(val * 10))
            lines.append(f"  {dim:20s} {bar} {val:.2f}")
        return "\n".join(lines)


class QualityEvaluator:
    """Multi-dimensional quality evaluator for Aristotle's research output."""

    def __init__(self, pi_agent=None, catalog_root: Optional[Path] = None):
        """
        Args:
            pi_agent: Optional PiAgentClient for LLM-based evaluations
                      (importance, usefulness, applications).
            catalog_root: Path to Catalog for novelty comparison.
        """
        self.pi_agent = pi_agent
        self.catalog_root = catalog_root

    def extract_self_evaluation(
        self,
        result_dir: Optional[Path] = None,
        result_fields: Optional[Dict[str, str]] = None,
        lean_source: str = "",
    ) -> Optional[Dict[str, Any]]:
        """Extract Aristotle's self-evaluation from result_dir, result_fields, or lean_source."""
        # 1. Try reading self-evaluation files from result_dir (case-insensitive)
        if result_dir and Path(result_dir).exists():
            for fname in ("SELF_EVALUATION.json", "self_evaluation.json", "self_eval.json", "self_score.json", "quality_score.json", "aristotle_score.json"):
                eval_path = Path(result_dir) / fname
                if eval_path.exists():
                    try:
                        content = eval_path.read_text(encoding="utf-8")
                        data = json.loads(content)
                        if isinstance(data, dict):
                            qs = data.get("quality_score") or data.get("self_score") or data.get("score") or data.get("overall_score")
                            if qs is not None:
                                return {
                                    "quality_score": _safe_float(qs, 0.5),
                                    "proof_depth": _safe_float(data.get("proof_depth") or data.get("proof_quality"), 0.5),
                                    "novelty": _safe_float(data.get("novelty"), 0.5),
                                    "grade": str(data.get("grade", "partial")),
                                    "rationale": str(data.get("rationale", "")),
                                    "source": fname,
                                }
                    except Exception as e:
                        print(f"[QualityEvaluator] Error parsing {fname}: {e}")

        # 2. Try result_fields
        if result_fields:
            for k, v in result_fields.items():
                if v and any(sub in k.lower() for sub in ("self_eval", "self-eval", "self_score", "self-score", "quality_score")):
                    try:
                        data = json.loads(v)
                        if isinstance(data, dict):
                            qs = data.get("quality_score") or data.get("self_score") or data.get("score") or data.get("overall_score")
                            if qs is not None:
                                return {
                                    "quality_score": _safe_float(qs, 0.5),
                                    "proof_depth": _safe_float(data.get("proof_depth") or data.get("proof_quality"), 0.5),
                                    "novelty": _safe_float(data.get("novelty"), 0.5),
                                    "grade": str(data.get("grade", "partial")),
                                    "rationale": str(data.get("rationale", "")),
                                    "source": "result_fields",
                                }
                    except Exception:
                        pass

        # 3. Check for embedded json block in lean_source
        if lean_source and any(k in lean_source for k in ("quality_score", "self_score", "self_evaluation", "SELF_EVALUATION")):
            match = re.search(r'\{[^{}]*"(?:quality_score|self_score|proof_depth)"[^{}]*\}', lean_source, re.DOTALL)
            if match:
                try:
                    data = json.loads(match.group(0))
                    if isinstance(data, dict):
                        qs = data.get("quality_score") or data.get("self_score") or data.get("score")
                        if qs is not None:
                            return {
                                "quality_score": _safe_float(qs, 0.5),
                                "proof_depth": _safe_float(data.get("proof_depth"), 0.5),
                                "novelty": _safe_float(data.get("novelty"), 0.5),
                                "grade": str(data.get("grade", "partial")),
                                "rationale": str(data.get("rationale", "")),
                                "source": "embedded_lean",
                            }
                except Exception:
                    pass

        return None

    def evaluate(
        self,
        lean_source: str,
        result_dir: Optional[Path] = None,
        concept_title: str = "",
        concept_description: str = "",
        existing_titles: Optional[set] = None,
        catalog_references: Optional[list] = None,
        result_fields: Optional[Dict[str, str]] = None,
        phase: str = "A",
    ) -> QualityScore:
        """Evaluate Aristotle's output across all 9 dimensions.

        The first 6 dimensions are computed locally (no API cost).
        The last 3 use a single Pi-Agent call if available.

        result_fields: dict mapping artifact names to their content strings,
            e.g. {"result_paper": "...", "result_demo": "...", ...}.
            Used for artifact richness when result_dir doesn't contain the files.

        phase: "A" for Phase A (Lean-only), "B" for Phase B (packaging).
            Phase A intentionally omits articles, demos, and papers — those
            are Phase B's responsibility. So for Phase A, artifact_richness
            and actionability are set to neutral (0.5) to avoid penalizing
            the math-only output for missing deliverables it shouldn't produce.
        """
        score = QualityScore()
        score.phase = phase

        # For Phase A, check if Aristotle provided a self-evaluation first
        self_eval = self.extract_self_evaluation(result_dir, result_fields, lean_source) if phase == "A" else None

        # Local evaluations (free)
        score.proof_depth = self_eval["proof_depth"] if self_eval else self._eval_proof_depth(lean_source)

        # PEGB compliance check: if a cycle claims 5+ theorems but lacks
        # explicit examples/generalizations/boundaries, penalize proof_depth
        # (forces compliance with the structural requirement)
        theorem_count = lean_source.count("theorem ") + lean_source.count("lemma ")
        if theorem_count >= 5:
            pegb_score = self._eval_pegb_compliance(lean_source)
            if pegb_score < 0.5:
                # Less than 2 of 4 PEGB elements present — mild penalty
                score.proof_depth = score.proof_depth * 0.85
            elif pegb_score < 0.75:
                # Some elements missing — very mild penalty
                score.proof_depth = score.proof_depth * 0.95
            # pegb_score >= 0.75: full credit
            score.pegb_compliance = pegb_score
        else:
            score.pegb_compliance = self._eval_pegb_compliance(lean_source)

        score.novelty = self_eval["novelty"] if self_eval else self._eval_novelty(lean_source, concept_title, concept_description, phase, existing_titles)
        score.cross_domain = self._eval_cross_domain(lean_source)
        score.artifact_richness = self._eval_artifacts(result_dir, result_fields)
        score.actionability = self._eval_actionability(result_dir, result_fields)

        # Artifacts and Actionability are inherently 0 for Phase A, but we leave them at 0
        # because the composite_with_domains will zero out their weights anyway.
        if phase == "A":
            score.artifact_richness = 0.0
            score.actionability = 0.0

        score.catalog_anchoring = self._eval_catalog_anchoring(
            concept_title, catalog_references or [], existing_titles
        )

        # Heuristic/Self-eval evaluation for importance, usefulness, applications
        if self_eval:
            qs = self_eval["quality_score"]
            score.importance = qs
            score.usefulness = qs
            score.applications = qs
        else:
            score.importance = min(1.0, score.proof_depth * 0.7 + score.novelty * 0.3)
            score.usefulness = min(1.0, score.cross_domain * 0.5 + score.proof_depth * 0.5)
            score.applications = min(1.0, score.cross_domain * 0.6 + score.artifact_richness * 0.4)

        # Safety floor: penalize unresolved sorries in Lean code
        sorry_count = lean_source.count("sorry")
        if sorry_count > 0:
            penalty = max(0.0, 1.0 - 0.2 * sorry_count)
            score.proof_depth *= penalty
            score.importance *= penalty

        # Jargon penalty: penalize excessive use of narrow jargon without substance
        if lean_source:
            all_words = set(re.findall(r'[a-zA-Z_]\w{4,}', lean_source.lower()))
            jargon_clusters = {
                'tropical_lorentzian': {'tropical', 'lorentzian', 'hessian', 'certificate', 'shadow'},
                'matroid_dpp': {'matroid', 'exchange', 'dpp', 'determinantal', 'partition'},
                'spectral_expander': {'spectral', 'expander', 'eigenvalue', 'gap', 'ramanujan'},
            }
            jargon_overlap = 0
            for cluster_words in jargon_clusters.values():
                overlap = len(all_words & cluster_words)
                if overlap >= 3:
                    jargon_overlap += 1
            if jargon_overlap >= 2 and score.proof_depth < 0.4:
                # Soften jargon penalty for Phase A exploration
                penalty = 0.90 if phase == "A" else 0.80
                score.novelty *= penalty
                score.importance *= penalty

        return score

    # ── Local Evaluators ──

    def _eval_catalog_anchoring(self, concept_title: str, catalog_references: list,
                                 existing_titles: Optional[set] = None) -> float:
        """Evaluate how well the concept is anchored in existing Catalog theorems.

        0.3 base + 0.3 if has catalog_references + 0.2 if refs exist in FINAL/
        + 0.2 if concept title matches a Catalog declaration.
        """
        score = 0.3

        # Bonus for having catalog references
        if catalog_references:
            score += 0.3

            # Bonus if references point to FINAL/ files
            final_refs = [r for r in catalog_references if "FINAL" in r or "final" in r.lower()]
            if final_refs:
                score += 0.2

            # Verify files exist if catalog_root is available
            if self.catalog_root and not final_refs:
                for ref in catalog_references[:3]:
                    ref_path = self.catalog_root / ref
                    if ref_path.exists():
                        if "FINAL" in str(ref_path):
                            score += 0.2
                            break

        # Bonus if concept title matches a declaration in existing Catalog
        if existing_titles and concept_title:
            title_words = set(concept_title.lower().replace("-", " ").replace("_", " ").split())
            for decl in existing_titles:
                decl_words = set(decl.lower().replace("_", " ").split())
                if title_words & decl_words:
                    score += 0.2
                    break

        return min(1.0, score)

    def _eval_proof_depth(self, lean_source: str) -> float:
        """Score proof depth based on tactics, structure, and non-triviality."""
        if not lean_source or len(lean_source) < 50:
            return 0.0

        lines = lean_source.splitlines()
        total_lines = len(lines)

        # Check for trivial patterns
        trivial_patterns = [
            r"theorem\s+\w+.*:=\s*by\s+trivial",
            r"theorem\s+\w+.*:\s*True\s*:=",
            r"theorem\s+\w+.*:=\s*by\s+simp\s*$",
            r"theorem\s+\w+.*:=\s*by\s+rfl\s*$",
            r"theorem\s+\w+.*:=\s*by\s+decide\s*$",
        ]
        trivial_count = sum(
            1 for pat in trivial_patterns
            for _ in re.finditer(pat, lean_source, re.MULTILINE)
        )

        # Detect hypothesis-only proofs: "exact h_something" or "exact this_hypothesis"
        hypothesis_proof_patterns = [
            r":=\s*exact\s+h\w+",          # exact h_foo
            r":=\s*exact\s+this_\w+",       # exact this_hypothesis
            r":=\s*exact\s+\w+_hyp\b",      # exact some_hyp
        ]
        hypothesis_proof_count = sum(
            1 for pat in hypothesis_proof_patterns
            for _ in re.finditer(pat, lean_source, re.MULTILINE)
        )

        # Count theorems/lemmas
        theorem_count = len(re.findall(r'\b(?:theorem|lemma)\s+\w+', lean_source))
        if theorem_count == 0:
            return 0.1  # Definitions only

        # If ALL theorems are trivial
        if trivial_count >= theorem_count and theorem_count > 0:
            return 0.10

        # Count sorry
        sorry_count = lean_source.count("sorry")
        sorry_penalty = sorry_count * 0.15
        sorry_ratio = sorry_count / max(theorem_count, 1)

        # Count deep tactics
        deep_count = 0
        shallow_count = 0
        for line in lines:
            line_stripped = line.strip().lower()
            for tactic in DEEP_TACTICS:
                if tactic in line_stripped:
                    deep_count += 1
                    break
            for tactic in SHALLOW_TACTICS:
                if tactic in line_stripped:
                    shallow_count += 1
                    break

        # Count definitions
        def_count = len(re.findall(r'\b(?:def|structure|class|instance|inductive)\s+\w+', lean_source))

        # Count nesting depth (by blocks)
        max_nesting = 0
        current_nesting = 0
        for line in lines:
            if "by" in line or "where" in line or "do" in line:
                current_nesting += 1
                max_nesting = max(max_nesting, current_nesting)
            if line.strip() == "" or line.strip().startswith("theorem") or line.strip().startswith("lemma"):
                current_nesting = max(0, current_nesting - 1)

        # Detect hypothesis reuse: extract hypothesis names from theorem signatures
        # If >50% of theorems share the same hypothesis name, penalize
        hypothesis_names = re.findall(r'\(h(\w+)\s*:', lean_source)
        hypothesis_names += re.findall(r'\(h(\w+)\s+:', lean_source)
        hypothesis_reuse_penalty = 0.0
        if hypothesis_names:
            from collections import Counter
            name_counts = Counter(hypothesis_names)
            most_common_count = name_counts.most_common(1)[0][1]
            if most_common_count > 2 and most_common_count / max(theorem_count, 1) > 0.5:
                hypothesis_reuse_penalty = 0.3  # >50% of theorems reuse the same hypothesis

        # Hypothesis-only proof penalty: if most proofs just invoke assumed hypotheses
        hypothesis_proof_ratio = hypothesis_proof_count / max(theorem_count, 1)
        hypothesis_proof_penalty = 0.0
        if hypothesis_proof_ratio > 0.5:
            hypothesis_proof_penalty = 0.3  # >50% of theorems proved by exact h_*

        # Composite depth score
        tactic_ratio = deep_count / max(deep_count + shallow_count, 1)
        line_score = min(1.0, total_lines / 300)
        theorem_score = min(1.0, theorem_count / 10)
        def_score = min(1.0, def_count / 5)
        nesting_score = min(1.0, max_nesting / 5)
        sorry_penalty = min(0.5, sorry_ratio * 0.5)

        depth = (
            0.30 * tactic_ratio +
            0.20 * line_score +
            0.15 * theorem_score +
            0.15 * def_score +
            0.10 * nesting_score +
            0.10 * (1.0 - trivial_count / max(theorem_count, 1))
        ) - sorry_penalty - hypothesis_proof_penalty - hypothesis_reuse_penalty

        return max(0.0, min(1.0, depth))

    def _eval_pegb_compliance(self, lean_source: str) -> float:
        """Check if the cycle satisfies PEGB structural requirements.

        PEGB = Proof + Example + Generalization + Boundary for each major theorem.
        This is a heuristic check (not perfect) that detects whether the cycle
        includes examples, generalizations, and boundary/limit-case analysis.

        Returns a 0-1 compliance score:
        - 0.0: no PEGB elements detected
        - 0.3-0.5: only some elements (e.g. P+E but no G+B)
        - 0.7-0.9: most elements present
        - 1.0: all four elements clearly present

        Patterns detected:
        - P (proof): actual proof tactics (always present in non-empty source)
        - E (example): "example", "instance", "specific", "concrete", numerical values
        - G (generalization): "generaliz", "extension", "broader", "one-level-up"
        - B (boundary): "counterexample", "boundary", "limit", "where X fails", "necessary"
        """
        if not lean_source or len(lean_source) < 100:
            return 0.0

        score = 0.0

        # E: example detection
        example_patterns = [
            r'\bexample\s*[:=]',
            r'\binstance\s*[:(]',
            r'#check\s+',  # Lean 4 #check command verifies examples
            r'#eval\s+',   # Lean 4 #eval command
            r'#reduce\s+',
            r'\bfor\s+\w+\s*:=',  # "for x := ..." example instantiation
        ]
        example_count = sum(
            1 for pat in example_patterns
            for _ in re.finditer(pat, lean_source, re.IGNORECASE)
        )
        if example_count >= 1:
            score += 0.25

        # G: generalization detection
        generalization_patterns = [
            r'\bgeneraliz',
            r'\bextension\b',
            r'\bgeneraliz\w*\b',
            r'\bbroader\b',
            r'\bmore general\b',
            r'\bone-level-up\b',
            r'\babstract\b',
        ]
        generalization_count = sum(
            1 for pat in generalization_patterns
            for _ in re.finditer(pat, lean_source, re.IGNORECASE)
        )
        if generalization_count >= 1:
            score += 0.25

        # B: boundary / counterexample detection
        boundary_patterns = [
            r'\bcounterexample\b',
            r'\bcounter-example\b',
            r'\bboundary\b',
            r'\bwhere\s+\w+\s+(fails|breaks|doesn\'t hold)',
            r'\bnecessary condition',
            r'\blimiting case',
            r'\blimit case',
            r'\bedge case',
            r'\bnot\s+\w+\s+(commute|hold|generalize)',  # negation
        ]
        boundary_count = sum(
            1 for pat in boundary_patterns
            for _ in re.finditer(pat, lean_source, re.IGNORECASE)
        )
        if boundary_count >= 1:
            score += 0.25

        # P: proof is always present (non-empty source) — give baseline 0.25
        # but require non-trivial proof tactics
        if re.search(r'\b(?:theorem|lemma|def)\s+\w+', lean_source):
            score += 0.25

        return min(1.0, score)

    def _eval_novelty(self, lean_source: str, title: str,
                      concept_description: str = "",
                      phase: str = "A",
                      existing_titles: Optional[set] = None) -> float:
        """Score novelty based on distance from existing work."""
        if not lean_source:
            return 0.0

        score = 0.5  # Base

        # Penalty for exact title match
        if existing_titles and title.lower() in existing_titles:
            score -= 0.3

        # Reward for new definitions
        new_defs = re.findall(r'\b(?:def|structure|class)\s+(\w+)', lean_source)
        if new_defs:
            score += min(0.3, len(new_defs) * 0.06)

        # Reward for doc comments (shows explanation effort)
        doc_comments = re.findall(r'/--.*?-/', lean_source, re.DOTALL)
        if doc_comments:
            score += min(0.15, len(doc_comments) * 0.03)

        # Penalty for very common theorem names
        common_names = {"test", "example", "demo", "trivial", "obvious", "simple"}
        theorem_names = re.findall(r'\btheorem\s+(\w+)', lean_source)
        common_count = sum(1 for n in theorem_names if any(c in n.lower() for c in common_names))
        if theorem_names:
            score -= common_count / len(theorem_names) * 0.2

        heuristic_score = max(0.0, min(1.0, score))
        
        return heuristic_score

    def _eval_cross_domain(self, lean_source: str) -> float:
        """Score cross-domain bridging."""
        if not lean_source:
            return 0.0

        source_lower = lean_source.lower()
        domains_found = set()
        for domain, keywords in DOMAIN_KEYWORDS.items():
            if any(kw in source_lower for kw in keywords):
                domains_found.add(domain)

        n = len(domains_found)
        if n <= 1:
            return 0.1
        elif n == 2:
            return 0.5
        elif n == 3:
            return 0.7
        elif n == 4:
            return 0.85
        else:
            return min(1.0, 0.85 + (n - 4) * 0.05)

    def _eval_artifacts(self, result_dir: Optional[Path],
                        result_fields: Optional[Dict[str, str]] = None) -> float:
        """Score artifact richness.

        Checks both filesystem (result_dir) and in-memory result fields,
        since Aristotle's artifacts may only exist in the job's result_*
        fields rather than as files on disk.
        """
        expected = {
            "RESEARCH_REPORT.md": (0.30, ["result_paper", "result_research_paper"]),
            "demo.py": (0.25, ["result_demo", "result_algorithms"]),
            "DISCUSSION.md": (0.20, ["result_discussion"]),
            "FUTURE_DIRECTIONS.md": (0.25, ["result_future_directions"]),
        }

        score = 0.0
        for filename, (weight, field_names) in expected.items():
            found = False

            # Try filesystem first
            if result_dir and result_dir.exists():
                matches = list(result_dir.rglob(filename))
                if matches:
                    content = matches[0].read_text(encoding="utf-8", errors="replace")
                    if len(content) > 100:
                        score += weight
                        found = True
                    elif len(content) > 20:
                        score += weight * 0.5
                        found = True

            # Fall back to in-memory result fields
            if not found and result_fields:
                for field_name in field_names:
                    content = result_fields.get(field_name, "")
                    if content and len(content) > 100:
                        score += weight
                        found = True
                        break
                    elif content and len(content) > 20:
                        score += weight * 0.5
                        found = True
                        break

        return max(0.1, min(1.0, score))

    def _eval_actionability(self, result_dir: Optional[Path],
                            result_fields: Optional[Dict[str, str]] = None) -> float:
        """Score actionability of future directions."""
        content = ""

        # Try filesystem first
        if result_dir and result_dir.exists():
            fd_files = list(result_dir.rglob("FUTURE_DIRECTIONS*.md"))
            if fd_files:
                content = fd_files[0].read_text(encoding="utf-8", errors="replace")

        # Fall back to in-memory field
        if not content and result_fields:
            content = result_fields.get("result_future_directions", "")

        if len(content) < 100:
            return 0.1

        score = 0.3  # Has a FUTURE_DIRECTIONS.md

        # Count specific theorem statements
        theorem_refs = len(re.findall(r'(?:prove|show|establish|formalize)\s+that', content, re.IGNORECASE))
        score += min(0.3, theorem_refs * 0.06)

        # Count numbered/bulleted items
        items = len(re.findall(r'(?:^\d+\.|^[-•])\s+', content, re.MULTILINE))
        score += min(0.2, items * 0.04)

        # Reward mathematical specificity
        math_terms = len(re.findall(r'(?:theorem|lemma|conjecture|proposition|corollary)', content, re.IGNORECASE))
        score += min(0.2, math_terms * 0.04)

        return min(1.0, score)

    # ── LLM Evaluator ──

    def _eval_llm_dimensions(
        self,
        lean_source: str,
        concept_title: str,
        concept_description: str,
        result_dir: Optional[Path],
        result_fields: Optional[Dict[str, str]] = None,
    ) -> Dict[str, float]:
        """Use Pi-Agent for importance, usefulness, and applications scoring."""
        # Get research report if available
        report_text = ""
        if result_dir and result_dir.exists():
            report_files = list(result_dir.rglob("RESEARCH_REPORT*.md"))
            if report_files:
                report_text = report_files[0].read_text(encoding="utf-8", errors="replace")[:1500]
        # Fall back to in-memory field
        if not report_text and result_fields:
            report_text = (result_fields.get("result_paper", "") or
                           result_fields.get("result_research_paper", ""))[:1500]

        system_prompt = (
            "You are a mathematical research evaluator scoring output on three axes. "
            "Respond with ONLY JSON, no other text: "
            '{"importance": 0.0-1.0, "usefulness": 0.0-1.0, "applications": 0.0-1.0}\n\n'
            "Scoring guide:\n"
            "IMPORTANCE: 0.0=trivial, 0.2=minor lemma, 0.4=noteworthy, 0.6=significant, 0.8=field-advancing, 1.0=breakthrough\n"
            "  Would this appear in a top math journal? Does it change how mathematicians think?\n"
            "USEFULNESS: 0.0=none, 0.2=theoretical only, 0.4=some applicability, 0.6=practical, 0.8=broadly useful, 1.0=essential\n"
            "  Does this solve a practical problem or produce an algorithm others can use?\n"
            "APPLICATIONS: 0.0=none, 0.2=narrow, 0.4=moderate, 0.6=diverse, 0.8=widespread, 1.0=transformative\n"
            "  How many real-world domains benefit? (crypto, ML, physics, engineering, etc.)"
        )

        user_prompt = (
            f"TITLE: {concept_title}\n"
            f"DESCRIPTION: {concept_description[:500]}\n\n"
            f"LEAN SOURCE (first 1000 chars):\n{lean_source[:1000]}\n\n"
        )
        if report_text:
            user_prompt += f"RESEARCH REPORT (first 1000 chars):\n{report_text[:1000]}"

        try:
            raw = self.pi_agent._call_ollama(system_prompt, user_prompt, timeout=120)
            data = self.pi_agent._parse_json_response(raw)
            if data:
                imp = _safe_float(data.get("importance"), 0.5)
                use = _safe_float(data.get("usefulness"), 0.5)
                app = _safe_float(data.get("applications"), 0.5)
                # Reject degenerate responses (all identical or all near-floor)
                if imp < 0.05 and use < 0.05 and app < 0.05:
                    raise ValueError("Degenerate LLM scores (all near-zero)")
                return {
                    "importance": max(0.0, min(1.0, imp)),
                    "usefulness": max(0.0, min(1.0, use)),
                    "applications": max(0.0, min(1.0, app)),
                }
        except Exception:
            pass

        # Heuristic fallback based on structural scores
        return {"importance": 0.5, "usefulness": 0.5, "applications": 0.5}

    # ── Convenience ──

    def _eval_so_what(self, concept_title: str, concept_description: str, lean_source: str) -> float:
        """Ask the LLM 'so what?' — does this matter to a mathematician outside the subfield?

        Returns an adjustment to importance: -0.15 for generic answers, +0.1 for compelling ones.
        """
        if not self.pi_agent:
            return 0.0

        # Truncate for prompt
        desc_preview = (concept_description or "")[:500]
        title_preview = (concept_title or "Untitled")[:120]

        # Count key proof elements for context
        theorem_count = len(re.findall(r'\b(?:theorem|lemma)\s+\w+', lean_source or ""))
        sorry_count = (lean_source or "").count("sorry")

        prompt = (
            f"Research: \"{title_preview}\"\n"
            f"Description: {desc_preview}\n"
            f"Theorems: {theorem_count}, Sorry: {sorry_count}\n\n"
            "In ONE sentence, why does this result matter to a mathematician "
            "who does NOT work in this subfield? Be honest — if the result is "
            "a minor extension of known techniques or only interesting to specialists, say so.\n\n"
            "Respond in this exact JSON format:\n"
            '{"significance": "generic"|"noteworthy"|"compelling", "reason": "one sentence"}\n\n'
            '"generic" = minor extension, specialist-only, or restates known results\n'
            '"noteworthy" = meaningful contribution with some broader interest\n'
            '"compelling" = resolves a long-standing question, opens a new area, or bridges disconnected fields'
        )

        try:
            raw = self.pi_agent._call_ollama(
                "You are a blunt mathematical significance assessor. Be skeptical.",
                prompt, timeout=30
            )
            result = self.pi_agent._parse_json_response(raw)
            if not result:
                return 0.0

            sig = result.get("significance", "generic")
            if sig == "compelling":
                return 0.1
            elif sig == "noteworthy":
                return 0.0
            else:  # generic
                return -0.15

        except Exception as e:
            print(f"[QualityEval] So-What gate failed: {e}")
            return 0.0

    def is_worth_integrating(self, score: QualityScore, threshold: float = 0.25) -> bool:
        """Should this result be integrated into the catalog?"""
        return score.composite >= threshold and score.grade != "trivial"

    def should_move_on(self, score: QualityScore) -> bool:
        """Should we skip this topic and move to something else?"""
        return score.composite < 0.25

    # ── Adversarial Quality Judging ─────────────────────────────────

    def adversarial_evaluate(
        self,
        lean_source: str,
        concept_title: str = "",
        concept_description: str = "",
        primary_score: Optional[QualityScore] = None,
        disagreement_threshold: float = 0.2,
        domains: Optional[list] = None,
    ) -> Dict[str, Any]:
        """Run an adversarial second opinion on quality, with tiebreaker if needed.

        A second LLM is prompted as a skeptical critic to independently grade
        the output. If the two judges disagree by more than `disagreement_threshold`,
        a third tiebreaker LLM is called.

        Returns dict with:
          - adjudicated_score: float (0-1) — the final quality score
          - primary_composite: float — the primary evaluator's composite
          - adversarial_composite: float — the critic's composite
          - tiebreaker_composite: float or None — tiebreaker's composite (if called)
          - agreement: str — "agree", "disagree", or "tiebreak"
          - delta: float — absolute difference between primary and adversarial
        """
        if not self.pi_agent:
            p_comp = primary_score.composite_with_domains(domains) if primary_score else 0.5
            return {
                "adjudicated_score": p_comp,
                "primary_composite": p_comp,
                "adversarial_composite": None,
                "tiebreaker_composite": None,
                "agreement": "no_pi_agent",
                "delta": 0.0,
            }

        # Step 1: Run adversarial critic
        adversarial_result = self._run_adversarial_critic(
            lean_source, concept_title, concept_description, domains=domains
        )
        adversarial_composite = adversarial_result.get("composite")
        primary_composite = primary_score.composite_with_domains(domains) if primary_score else 0.5

        # Critic LLM failed — adjudicate on the primary alone rather than
        # averaging in a fabricated neutral vote (audit 2026-08-21).
        if adversarial_composite is None:
            return {
                "adjudicated_score": round(primary_composite, 4),
                "primary_composite": round(primary_composite, 4),
                "adversarial_composite": None,
                "tiebreaker_composite": None,
                "agreement": "critic_failed",
                "delta": 0.0,
            }

        delta = abs(primary_composite - adversarial_composite)

        # Step 2: Check disagreement
        if delta <= disagreement_threshold:
            # Judges agree — average them
            adjudicated = (primary_composite + adversarial_composite) / 2
            return {
                "adjudicated_score": round(adjudicated, 4),
                "primary_composite": round(primary_composite, 4),
                "adversarial_composite": round(adversarial_composite, 4),
                "tiebreaker_composite": None,
                "agreement": "agree",
                "delta": round(delta, 4),
            }

        # Step 3: Disagreement — call tiebreaker
        tiebreaker_result = self._run_tiebreaker(
            lean_source, concept_title, concept_description,
            primary_composite, adversarial_composite, domains=domains
        )
        tiebreaker_composite = tiebreaker_result.get("composite")
        if tiebreaker_composite is None:
            # Tiebreaker failed: fall back to the two-judge average instead of
            # letting a fabricated 0.5 decide the majority (audit 2026-08-21).
            adjudicated = (primary_composite + adversarial_composite) / 2
            return {
                "adjudicated_score": round(adjudicated, 4),
                "primary_composite": round(primary_composite, 4),
                "adversarial_composite": round(adversarial_composite, 4),
                "tiebreaker_composite": None,
                "agreement": "tiebreaker_failed",
                "delta": round(delta, 4),
            }

        # Two-of-three voting: whichever side 2 of 3 judges agree with wins.
        # Compare tiebreaker distance to each judge to determine majority.
        dist_primary = abs(tiebreaker_composite - primary_composite)
        dist_adversarial = abs(tiebreaker_composite - adversarial_composite)

        if dist_primary <= dist_adversarial:
            # Tiebreaker agrees more with primary → primary + tiebreaker majority
            adjudicated = (primary_composite + tiebreaker_composite) / 2
            winner = "primary"
        else:
            # Tiebreaker agrees more with adversarial → adversarial + tiebreaker majority
            adjudicated = (adversarial_composite + tiebreaker_composite) / 2
            winner = "adversarial"

        print(f"[Adversarial] VOTE: primary={primary_composite:.3f} critic={adversarial_composite:.3f} "
              f"tiebreak={tiebreaker_composite:.3f} → winner={winner} adjudicated={adjudicated:.3f}")

        return {
            "adjudicated_score": round(adjudicated, 4),
            "primary_composite": round(primary_composite, 4),
            "adversarial_composite": round(adversarial_composite, 4),
            "tiebreaker_composite": round(tiebreaker_composite, 4),
            "agreement": "tiebreak",
            "winner": winner,
            "delta": round(delta, 4),
        }

    def _run_adversarial_critic(
        self, lean_source: str, concept_title: str, concept_description: str, domains: Optional[list] = None
    ) -> Dict[str, Any]:
        """Run a skeptical second LLM evaluation as an adversarial judge.

        The critic is prompted to find flaws, overstatements, and triviality.
        Returns a quality assessment dict with 'composite' and per-axis scores.
        """
        system_prompt = (
            "You are a FAIR mathematical quality critic. Your job is to identify both "
            "genuine value and genuine flaws. Be neither a fan nor a hater.\n\n"
            "Score the value of WHAT IS THERE, not what's missing. Reward genuine insight "
            "even in partial results. Apply these calibration principles:\n\n"
            "- 0.0-0.2: Trivial, wrapper, or repackaged standard results\n"
            "- 0.3-0.4: A partial result with at least 1 genuinely novel theorem. "
            "Don't punish incomplete coverage of the original goal — value what was achieved.\n"
            "- 0.5-0.6: Solid mathematical work with multiple non-trivial results\n"
            "- 0.7-0.85: Substantial contribution that advances a research area\n"
            "- 0.85-1.0: Breakthrough-level — would impress research mathematicians\n\n"
            "Apply these checks:\n"
            "- If a proof is a standard exercise: 0.1-0.2\n"
            "- If a 'theorem' is just a definition wrapper: 0.1-0.2\n"
            "- If there's at least 1 novel non-trivial theorem, MINIMUM is 0.35 even "
            "if other parts are weak\n"
            "- Cross-domain connection should be evaluated on substance, not naming\n"
            "- Importance: ask 'would a math researcher in a different subfield care?'\n\n"
            "Score on 9 axes, all 0.0-1.0. Respond with ONLY JSON:\n"
            '{"proof_depth": 0.0, "novelty": 0.0, "cross_domain": 0.0, '
            '"artifact_richness": 0.0, "actionability": 0.0, "importance": 0.0, '
            '"usefulness": 0.0, "applications": 0.0, "catalog_anchoring": 0.0}'
        )

        user_prompt = (
            f"Critically evaluate: \"{concept_title}\"\n"
            f"Description: {concept_description[:500]}\n\n"
            f"Lean source (first 1500 chars):\n{lean_source[:1500]}\n\n"
            "Identify what is genuinely new here. Identify what is repackaged known "
            "material. Score the value of what was actually achieved."
        )

        try:
            raw = self.pi_agent._call_ollama(system_prompt, user_prompt, timeout=120,
                                             category="critic")
            data = self.pi_agent._parse_json_response(raw)
            if data:
                # Build a QualityScore from the critic's assessment
                qs = QualityScore(
                    proof_depth=max(0.0, min(1.0, _safe_float(data.get("proof_depth"), 0.5))),
                    novelty=max(0.0, min(1.0, _safe_float(data.get("novelty"), 0.5))),
                    cross_domain=max(0.0, min(1.0, _safe_float(data.get("cross_domain"), 0.5))),
                    artifact_richness=max(0.0, min(1.0, _safe_float(data.get("artifact_richness"), 0.5))),
                    actionability=max(0.0, min(1.0, _safe_float(data.get("actionability"), 0.5))),
                    importance=max(0.0, min(1.0, _safe_float(data.get("importance"), 0.5))),
                    usefulness=max(0.0, min(1.0, _safe_float(data.get("usefulness"), 0.5))),
                    applications=max(0.0, min(1.0, _safe_float(data.get("applications"), 0.5))),
                    catalog_anchoring=max(0.0, min(1.0, _safe_float(data.get("catalog_anchoring"), 0.5))),
                )
                return {"composite": qs.composite_with_domains(domains), "breakdown": qs.to_dict()}
        except Exception as e:
            print(f"[Adversarial] Critic evaluation failed: {e}")

        # A failed critic must NOT vote: a fabricated neutral 0.5 silently
        # averaged into the adjudicated score (audit 2026-08-21). The caller
        # detects composite=None and adjudicates on the primary alone.
        return {"composite": None, "failed": True}

    def _run_tiebreaker(
        self, lean_source: str, concept_title: str, concept_description: str,
        primary_score: float, adversarial_score: float, domains: Optional[list] = None,
    ) -> Dict[str, Any]:
        """Run a third LLM as a tiebreaker when primary and adversarial judges disagree.

        The tiebreaker sees both scores and is asked to independently evaluate
        without being influenced by either.
        """
        system_prompt = (
            "You are a neutral mathematical quality arbiter. Two evaluators disagreed on a "
            "research output's quality. One gave it a score of "
            f"{primary_score:.2f}, the other gave it {adversarial_score:.2f}.\n\n"
            "You must independently assess the quality. Do NOT simply split the difference. "
            "Apply your own honest judgment.\n\n"
            "Score on 9 axes, all 0.0-1.0. Respond with ONLY JSON:\n"
            '{"proof_depth": 0.0, "novelty": 0.0, "cross_domain": 0.0, '
            '"artifact_richness": 0.0, "actionability": 0.0, "importance": 0.0, '
            '"usefulness": 0.0, "applications": 0.0, "catalog_anchoring": 0.0}'
        )

        user_prompt = (
            f"Research: \"{concept_title}\"\n"
            f"Description: {concept_description[:500]}\n\n"
            f"Lean source (first 1500 chars):\n{lean_source[:1500]}"
        )

        try:
            raw = self.pi_agent._call_ollama(system_prompt, user_prompt, timeout=120,
                                             category="critic_tiebreak")
            data = self.pi_agent._parse_json_response(raw)
            if data:
                qs = QualityScore(
                    proof_depth=max(0.0, min(1.0, _safe_float(data.get("proof_depth"), 0.5))),
                    novelty=max(0.0, min(1.0, _safe_float(data.get("novelty"), 0.5))),
                    cross_domain=max(0.0, min(1.0, _safe_float(data.get("cross_domain"), 0.5))),
                    artifact_richness=max(0.0, min(1.0, _safe_float(data.get("artifact_richness"), 0.5))),
                    actionability=max(0.0, min(1.0, _safe_float(data.get("actionability"), 0.5))),
                    importance=max(0.0, min(1.0, _safe_float(data.get("importance"), 0.5))),
                    usefulness=max(0.0, min(1.0, _safe_float(data.get("usefulness"), 0.5))),
                    applications=max(0.0, min(1.0, _safe_float(data.get("applications"), 0.5))),
                    catalog_anchoring=max(0.0, min(1.0, _safe_float(data.get("catalog_anchoring"), 0.5))),
                )
                return {"composite": qs.composite_with_domains(domains), "breakdown": qs.to_dict()}
        except Exception as e:
            print(f"[Adversarial] Tiebreaker failed: {e}")

        return {"composite": (primary_score + adversarial_score) / 2}
