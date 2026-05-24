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

    @property
    def composite(self) -> float:
        """Weighted composite score (9 axes)."""
        return (
            0.15 * self.proof_depth +
            0.12 * self.novelty +
            0.10 * self.cross_domain +
            0.05 * self.artifact_richness +
            0.06 * self.actionability +
            0.18 * self.importance +
            0.12 * self.usefulness +
            0.14 * self.applications +
            0.08 * self.catalog_anchoring
        )

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

    def evaluate(
        self,
        lean_source: str,
        result_dir: Optional[Path] = None,
        concept_title: str = "",
        concept_description: str = "",
        existing_titles: Optional[set] = None,
        catalog_references: Optional[list] = None,
        result_fields: Optional[Dict[str, str]] = None,
    ) -> QualityScore:
        """Evaluate Aristotle's output across all 9 dimensions.

        The first 6 dimensions are computed locally (no API cost).
        The last 3 use a single Pi-Agent call if available.

        result_fields: dict mapping artifact names to their content strings,
            e.g. {"result_paper": "...", "result_demo": "...", ...}.
            Used for artifact richness when result_dir doesn't contain the files.
        """
        score = QualityScore()

        # Local evaluations (free)
        score.proof_depth = self._eval_proof_depth(lean_source)
        score.novelty = self._eval_novelty(lean_source, concept_title, existing_titles)
        score.cross_domain = self._eval_cross_domain(lean_source)
        score.artifact_richness = self._eval_artifacts(result_dir, result_fields)
        score.actionability = self._eval_actionability(result_dir, result_fields)
        score.catalog_anchoring = self._eval_catalog_anchoring(
            concept_title, catalog_references or [], existing_titles
        )

        # LLM evaluations (single call for all 3)
        if self.pi_agent:
            llm_scores = self._eval_llm_dimensions(
                lean_source, concept_title, concept_description, result_dir
            )
            score.importance = llm_scores.get("importance", 0.5)
            score.usefulness = llm_scores.get("usefulness", 0.5)
            score.applications = llm_scores.get("applications", 0.5)
        else:
            # Heuristic fallback
            score.importance = min(1.0, score.proof_depth * 0.7 + score.novelty * 0.3)
            score.usefulness = min(1.0, score.cross_domain * 0.5 + score.proof_depth * 0.5)
            score.applications = min(1.0, score.cross_domain * 0.6 + score.artifact_richness * 0.4)

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
            return 0.05

        # Count sorry
        sorry_count = lean_source.count("sorry")
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

    def _eval_novelty(self, lean_source: str, title: str,
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

        return max(0.0, min(1.0, score))

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
            raw = self.pi_agent._call_ollama(system_prompt, user_prompt, timeout=60)
            # Parse JSON — try nested braces first for complete objects
            json_match = re.search(r'\{.*\}', raw, re.DOTALL)
            if not json_match:
                json_match = re.search(r'\{[^{}]*\}', raw, re.DOTALL)
            if json_match:
                data = json.loads(json_match.group())
                imp = float(data.get("importance", 0.5))
                use = float(data.get("usefulness", 0.5))
                app = float(data.get("applications", 0.5))
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

    def is_worth_integrating(self, score: QualityScore, threshold: float = 0.25) -> bool:
        """Should this result be integrated into the catalog?"""
        return score.composite >= threshold and score.grade != "trivial"

    def should_move_on(self, score: QualityScore) -> bool:
        """Should we skip this topic and move to something else?"""
        return score.composite < 0.25
