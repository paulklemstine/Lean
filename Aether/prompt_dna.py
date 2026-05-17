#!/usr/bin/env python3
"""PromptDNA: Modular, versioned, self-mutating prompt system for Aristotle.

Each module evolves independently based on quality feedback.
Versioned and checkpointed every cycle via git.
Supports drift protection and revert-to-best.
"""

import copy
import json
import subprocess
import textwrap
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Any


# Original identity — used for drift protection
_ORIGINAL_IDENTITY = textwrap.dedent("""\
    You are Aristotle, an inventive formal mathematician.
    Your gift is synthesizing disparate ideas into genuinely new mathematics.
    You have complete freedom to choose your approach.
    Trust your instincts. Follow the interesting connections.
    Produce work that surprises even you.""")

_ORIGINAL_INSTRUCTIONS = textwrap.dedent("""\
    Given the research body above, explore this space deeply.
    Answer as many important questions as you can discover.
    Formulate new theorems. Brainstorm exciting new applications.
    Write a paper of recommended future research directions to explore.

    Core guardrails (non-negotiable):
    - Use concrete types (Nat, Real, Matrix, Finset, etc.). Avoid `True := by trivial`.
    - Formalize genuine, substantive theorems in Lean 4 (mathlib4 v4.28.0).
    - Minimize sorry. If a step is beyond zero-shot, isolate it as a clearly marked auxiliary lemma.
    - Build on existing catalog definitions. Do not re-invent.""")

_DEFAULT_CREATIVITY_BOOSTERS = [
    "If the obvious approach fails, take the Galois dual.",
    "Reframe the problem in the category of sheaves over a site.",
    "Look for a hidden group action or symmetry.",
    "Try to prove the contrapositive in a non-standard model.",
    "Consider the p-adic analogue — non-Archimedean metrics often simplify convergence.",
    "If analysis is hard, try algebra. If algebra is hard, try geometry.",
    "What would this theorem say in homotopy type theory?",
    "Can you encode the theorem as a type and the proof as a program?",
    "Look for an adjunction: left adjoints preserve colimits, right adjoints preserve limits.",
    "If this result is true, what entirely new field does it open? Prove that first.",
    "Every deep theorem has a computational shadow. Find the algorithm that computes it.",
    "What would a 22nd-century mathematician prove about this?",
    "Every inequality has an equality case. What does equality imply?",
    "If this is true for dimension n, what happens in dimension infinity?",
    "What would Shannon, Turing, or Wiles do?",
]


@dataclass
class PromptDNA:
    """The evolving 'genome' of Aristotle's system prompt.

    Each module evolves independently based on quality feedback.
    """
    version: int = 1

    # Module 1: Identity (rarely changes)
    identity: str = ""

    # Module 2: Instructions (evolves based on what produces good results)
    instructions: str = ""

    # Module 3: Creativity boosters (domain-agnostic, evolves)
    creativity_boosters: List[str] = field(default_factory=list)

    # Module 4: Success patterns (extracted from best results)
    success_patterns: List[str] = field(default_factory=list)

    # Module 5: Failure patterns (what to avoid)
    failure_patterns: List[str] = field(default_factory=list)

    # Tracking
    quality_history: List[float] = field(default_factory=list)
    best_version: int = 1
    best_quality: float = 0.0
    consecutive_drops: int = 0
    mutation_log: List[str] = field(default_factory=list)

    def __post_init__(self):
        if not self.identity:
            self.identity = _ORIGINAL_IDENTITY
        if not self.instructions:
            self.instructions = _ORIGINAL_INSTRUCTIONS
        if not self.creativity_boosters:
            self.creativity_boosters = list(_DEFAULT_CREATIVITY_BOOSTERS)

    def assemble(
        self,
        cycle_n: int,
        domain: str,
        concept_description: str,
        mathematical_framing: str,
        lean_guess: str,
        title: str,
        memory_summary: str = "",
        presearch_context: str = "",
    ) -> str:
        """Assemble the full Aristotle prompt from all modules."""

        # Creativity injection (sample up to 5 boosters)
        booster_sample = self.creativity_boosters[:5]
        creativity_text = "\n".join(f"  - {b}" for b in booster_sample)

        # Meta-awareness: loop context
        meta_context = self._build_meta_context(cycle_n, memory_summary)

        # Success/failure patterns
        patterns_text = ""
        if self.success_patterns:
            patterns_text += "\n\nPatterns that produced excellent results:\n"
            patterns_text += "\n".join(f"  ✓ {p}" for p in self.success_patterns[-5:])
        if self.failure_patterns:
            patterns_text += "\n\nPatterns to AVOID (these failed):\n"
            patterns_text += "\n".join(f"  ✗ {p}" for p in self.failure_patterns[-5:])

        prompt = textwrap.dedent(f"""\
            === SYSTEM ROLE ===
            {self.identity}

            === META-RESEARCH CONTEXT ===
            {meta_context}
            {patterns_text}

            === CATALOG CONTEXT ===
            You have access to the full CatalogBuild Lean 4 library
            (~2,700 .lean files spanning Algebra, Geometry, Logic, Physics,
            Computation, Cryptography, Pythagorean, Tropical, EML,
            MachineLearning, Bridges, Speculative, and Shared).

            Reuse existing definitions and theorems. Build upward.
            Cross-pollinate across domains. Find hidden symmetries.
            {presearch_context}

            === RESEARCH BODY ===
            DOMAIN: {domain}
            TITLE: {title}

            {concept_description}

            Mathematical Framework:
            {mathematical_framing}

            Formalization Sketch:
            {lean_guess}

            Creativity Directives (inspirational, not mandatory):
            {creativity_text}

            ---

            {self.instructions}

            Deliver ALL of the following:
            - Lean 4 formal proofs (theorem.lean)
            - A research report (RESEARCH_REPORT.md)
            - A Python demo (demo.py)
            - An SVG diagram (diagram.svg)
            - A public-facing article (DISCUSSION.md)
            - A FUTURE_DIRECTIONS.md with 3-5 specific breakthrough-level next steps

            Quality over quantity. Surprise us.
        """)
        return prompt

    def assemble_free_exploration(
        self,
        cycle_n: int,
        catalog_summary: str,
        memory_summary: str,
        frontier_summary: str,
    ) -> str:
        """Assemble a free exploration prompt — no topic constraints."""
        meta_context = self._build_meta_context(cycle_n, memory_summary)

        return textwrap.dedent(f"""\
            === SYSTEM ROLE ===
            {self.identity}

            === META-RESEARCH CONTEXT ===
            {meta_context}

            === YOUR RESEARCH CATALOG ===
            {catalog_summary[:2000]}

            === INTERESTING OPEN PROBLEMS IN MATHEMATICS ===
            {frontier_summary[:2000]}

            === WHAT YOU'VE DISCOVERED SO FAR ===
            {memory_summary[:1000]}

            === YOUR MISSION ===
            You have COMPLETE FREEDOM. Choose a direction that excites you.
            Explore deeply. Produce whatever you find most valuable.
            The only requirement: surprise us with something genuinely new.

            Deliver ALL of the following:
            1. Lean 4 formal proofs (theorem.lean)
            2. RESEARCH_REPORT.md
            3. FUTURE_DIRECTIONS.md with 3-5 specific next steps
            4. demo.py with concrete numerical examples
            5. diagram.svg visualization

            The mathematics comes FIRST. Excellent proofs trump everything.
            But excellent proofs that OPEN NEW FIELDS trump everything.
        """)

    def _build_meta_context(self, cycle_n: int, memory_summary: str) -> str:
        """Build the meta-awareness section — Aristotle knows it's in a loop."""
        history_text = ""
        if self.quality_history:
            recent = self.quality_history[-5:]
            history_lines = [f"  Cycle {cycle_n - len(recent) + i + 1}: {q:.2f}" for i, q in enumerate(recent)]
            history_text = "Performance history (last 5 cycles):\n" + "\n".join(history_lines)
            avg = sum(recent) / len(recent)
            history_text += f"\n  Average: {avg:.2f}"

        best_text = ""
        if self.best_quality > 0:
            best_text = f"Your best composite score so far: {self.best_quality:.2f} (prompt v{self.best_version})"

        return textwrap.dedent(f"""\
            You are in iteration {cycle_n} of a self-improving research loop.
            Your prompt evolves based on the quality of your output.
            {history_text}
            {best_text}

            Your mission: beat your previous best. Produce work that scores
            higher on proof depth, novelty, importance, and real-world applications.
        """)

    # ── Mutation ──

    def mutate(self, quality_score: float, feedback: Dict[str, float],
               pi_agent=None) -> "PromptDNA":
        """Create a mutated version based on quality feedback.

        Args:
            quality_score: Composite quality score (0-1)
            feedback: Per-dimension scores {dimension_name: score}
            pi_agent: Optional PiAgentClient for LLM-assisted mutation

        Returns:
            New PromptDNA with version incremented.
        """
        new_dna = copy.deepcopy(self)
        new_dna.version += 1
        new_dna.quality_history.append(quality_score)

        # Track best
        if quality_score > self.best_quality:
            new_dna.best_quality = quality_score
            new_dna.best_version = new_dna.version
            new_dna.consecutive_drops = 0
            new_dna.mutation_log.append(
                f"v{new_dna.version}: NEW BEST {quality_score:.3f}"
            )
        else:
            new_dna.consecutive_drops += 1
            new_dna.mutation_log.append(
                f"v{new_dna.version}: score={quality_score:.3f} (drop #{new_dna.consecutive_drops})"
            )

        # REVERT TO BEST if 3 consecutive drops
        if new_dna.consecutive_drops >= 3:
            reverted = self._load_best_version_from_disk()
            if reverted:
                reverted.quality_history = new_dna.quality_history
                reverted.mutation_log = new_dna.mutation_log
                reverted.mutation_log.append(
                    f"v{new_dna.version}: REVERTED to v{reverted.best_version} after 3 drops"
                )
                reverted.consecutive_drops = 0
                return reverted
            # Fallback: just reset instructions
            new_dna.instructions = _ORIGINAL_INSTRUCTIONS
            new_dna.consecutive_drops = 0
            new_dna.mutation_log.append(
                f"v{new_dna.version}: RESET instructions after 3 drops (no saved best)"
            )

        # MODERATE MUTATION: focus on the weakest dimension
        if feedback:
            weakest_dim = min(feedback, key=feedback.get)
            weakest_score = feedback[weakest_dim]

            mutation_hints = {
                "proof_depth": "Focus on DEEP proofs with multiple lemmas and non-trivial tactic chains. Avoid one-liner proofs.",
                "novelty": "Seek genuinely NEW connections. Avoid rephrasing known results. Combine ideas from different fields.",
                "cross_domain": "Bridge at least 2 distinct mathematical areas. Find unexpected structural similarities.",
                "importance": "Aim for results that would appear in top journals. Ask: would this change how mathematicians think?",
                "usefulness": "Seek results with practical applications. Algorithms are more useful than pure existence proofs.",
                "applications": "Consider real-world domains: cryptography, ML, physics, engineering. What problems does this solve?",
                "artifact_richness": "Produce rich artifacts: detailed research reports, working demos, clear diagrams.",
                "actionability": "Produce specific, falsifiable future directions. Not 'explore X' but 'prove Y using technique Z'.",
            }

            hint = mutation_hints.get(weakest_dim, "")
            if hint and hint not in new_dna.instructions:
                new_dna.instructions += f"\n\nPRIORITY IMPROVEMENT AREA ({weakest_dim}, score={weakest_score:.2f}):\n{hint}"

            # Extract success pattern if score was good
            if quality_score >= 0.6:
                best_dim = max(feedback, key=feedback.get)
                new_dna.success_patterns.append(
                    f"High {best_dim} ({feedback[best_dim]:.2f}) in v{new_dna.version}"
                )
                # Keep only last 10
                new_dna.success_patterns = new_dna.success_patterns[-10:]

            # Extract failure pattern if score was bad
            if quality_score < 0.3:
                new_dna.failure_patterns.append(
                    f"Low {weakest_dim} ({weakest_score:.2f}) in v{new_dna.version}"
                )
                new_dna.failure_patterns = new_dna.failure_patterns[-10:]

        # DRIFT PROTECTION: check instruction length hasn't exploded
        if len(new_dna.instructions) > len(_ORIGINAL_INSTRUCTIONS) * 3:
            # Trim accumulated hints, keep only the 2 most recent
            lines = new_dna.instructions.split("\n\nPRIORITY IMPROVEMENT AREA")
            base = lines[0]
            extras = lines[1:] if len(lines) > 1 else []
            new_dna.instructions = base
            for extra in extras[-2:]:
                new_dna.instructions += "\n\nPRIORITY IMPROVEMENT AREA" + extra
            new_dna.mutation_log.append(f"v{new_dna.version}: TRIMMED instructions (drift protection)")

        # Keep mutation log bounded
        new_dna.mutation_log = new_dna.mutation_log[-50:]

        return new_dna

    def _load_best_version_from_disk(self) -> Optional["PromptDNA"]:
        """Try to load the best version from the checkpoint directory."""
        # This is set by checkpoint(); we store a reference
        if hasattr(self, '_checkpoint_dir') and self._checkpoint_dir:
            best_file = Path(self._checkpoint_dir) / f"prompt_dna_v{self.best_version}.json"
            if best_file.exists():
                return PromptDNA.load(best_file)
        return None

    # ── Persistence ──

    def to_dict(self) -> dict:
        return {
            "version": self.version,
            "identity": self.identity,
            "instructions": self.instructions,
            "creativity_boosters": self.creativity_boosters,
            "success_patterns": self.success_patterns,
            "failure_patterns": self.failure_patterns,
            "quality_history": self.quality_history,
            "best_version": self.best_version,
            "best_quality": self.best_quality,
            "consecutive_drops": self.consecutive_drops,
            "mutation_log": self.mutation_log,
        }

    @classmethod
    def from_dict(cls, d: dict) -> "PromptDNA":
        dna = cls()
        for k, v in d.items():
            if hasattr(dna, k):
                setattr(dna, k, v)
        return dna

    def save(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            json.dumps(self.to_dict(), indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    @classmethod
    def load(cls, path: Path) -> "PromptDNA":
        if not path.exists():
            return cls()
        data = json.loads(path.read_text(encoding="utf-8"))
        return cls.from_dict(data)

    def checkpoint(self, workspace: Path) -> None:
        """Save current version to disk and attempt git commit."""
        dna_dir = workspace / "prompt_dna"
        dna_dir.mkdir(parents=True, exist_ok=True)
        self._checkpoint_dir = str(dna_dir)

        # Save current version
        current_file = dna_dir / "prompt_dna_current.json"
        self.save(current_file)

        # Save versioned copy
        versioned_file = dna_dir / f"prompt_dna_v{self.version}.json"
        self.save(versioned_file)

        # Git commit
        try:
            repo_root = workspace.parent
            subprocess.run(
                ["git", "add", str(dna_dir.relative_to(repo_root))],
                cwd=str(repo_root), capture_output=True, timeout=10,
            )
            subprocess.run(
                ["git", "commit", "-m",
                 f"[PromptDNA] Checkpoint v{self.version} (quality={self.quality_history[-1]:.3f})" if self.quality_history else f"[PromptDNA] Checkpoint v{self.version}"],
                cwd=str(repo_root), capture_output=True, timeout=10,
            )
        except Exception:
            pass  # Git failures are non-fatal

    @classmethod
    def load_or_create(cls, workspace: Path) -> "PromptDNA":
        """Load existing DNA from workspace or create fresh."""
        dna_file = workspace / "prompt_dna" / "prompt_dna_current.json"
        if dna_file.exists():
            dna = cls.load(dna_file)
            dna._checkpoint_dir = str(dna_file.parent)
            return dna
        return cls()
