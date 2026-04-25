#!/usr/bin/env python3
"""PromptEngine: Advanced prompt optimization for Aristotle.

Transforms raw research concepts into richly-structured Aristotle prompts
engineered to maximize:
- Inventiveness and creative proof strategies
- Cross-domain insight
- Artifact generation (reports, demos, SVGs)
- Scientific American style exposition
"""

import textwrap
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any


@dataclass
class ArtifactRequests:
    """Flags for what artifacts Aristotle should produce."""
    research_report: bool = True
    python_demo: bool = True
    svg_demo: bool = True
    sciam_discussion: bool = True
    lean_proof: bool = True


@dataclass
class ResearchPrompt:
    """Fully assembled research prompt for Aristotle."""
    prompt_text: str
    artifact_requests: ArtifactRequests
    expected_artifacts: List[str] = field(default_factory=list)
    creativity_score_target: float = 0.9


class PromptEngine:
    """Optimizes prompts for Aristotle to maximize breakthrough potential."""

    # Domain-specific creativity boosters
    DOMAIN_BOOSTERS = {
        "factoring": [
            "Consider p-adic, tropical, or quaternionic number systems.",
            "What if factorization is a fixed-point of a dynamical system?",
            "Can Berggren-tree descent be adapted to factor semiprimes?",
        ],
        "compression": [
            "Use tropical matrix rank as a proxy for Kolmogorov complexity.",
            "What is the max-plus entropy of a language?",
            "Can sheaf cohomology measure information redundancy?",
        ],
        "AI": [
            "Model neural networks as tropical rational functions.",
            "Use p-adic metrics to measure generalization gaps.",
            "Can EML self-pairing explain attention mechanisms?",
        ],
        "neural nets": [
            "Backpropagation is a cotangent functor — prove functoriality.",
            "ReLU activation is tropical max-plus — exploit semiring structure.",
            "Use sheaf theory to formalize feature maps as local sections.",
        ],
        "quantum mechanics": [
            "Encode superpositions as Pythagorean triples over ℂ.",
            "Use Dirichlet characters as quantum error-correcting codes.",
            "Model measurement as tropical projection onto a hypersurface.",
        ],
        "computation": [
            "Prove complexity separations using p-adic oracle hierarchies.",
            "Reversible computing is a group action — use representation theory.",
            "Temporal logic fixed-points characterize P vs NP relativizations.",
        ],
        "physics": [
            "Gravitational lensing angles come from nilpotent EML residues.",
            "Black hole firewalls are tropical varieties — prove determinism.",
            "Cosmic microwave background is a sheaf over spacetime topology.",
        ],
    }

    # Universal creativity heuristics
    UNIVERSAL_HEURISTICS = [
        "If the obvious approach fails, take the Galois dual.",
        "Reframe the problem in the category of sheaves over a site.",
        "Look for a hidden group action or symmetry.",
        "Try to prove the contrapositive in a non-standard model.",
        "Use tropicalization to degenerate the problem to a combinatorial one.",
        "Consider the p-adic analogue — non-Archimedean metrics often simplify convergence.",
        "If analysis is hard, try algebra. If algebra is hard, try geometry.",
        "What would this theorem say in homotopy type theory?",
        "Can you encode the theorem as a type and the proof as a program?",
        "Look for an adjunction: left adjoints preserve colimits, right adjoints preserve limits.",
    ]

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        self.config = config or {}
        self.max_context = self.config.get("max_context_theorems", 8)

    def build_prompt(
        self,
        title: str,
        domain: str,
        concept_description: str,
        mathematical_framing: str,
        lean_guess: str,
        difficulty: str = "phd",
        artifacts: Optional[ArtifactRequests] = None,
    ) -> ResearchPrompt:
        """Assemble a full Aristotle prompt package (v2 system prompt)."""

        if artifacts is None:
            artifacts = ArtifactRequests()

        # 1. Inject domain-specific creativity boosters
        boosters = self.DOMAIN_BOOSTERS.get(domain.lower(), [])
        heuristic_sample = self.UNIVERSAL_HEURISTICS[:5]

        creativity_injection = "\n".join(
            [f"  - {b}" for b in boosters[:3]] +
            [f"  - {h}" for h in heuristic_sample]
        )

        # 2. v2.2 Research-Body Prompt — rich context, open-ended instructions
        full_prompt = textwrap.dedent(f"""\
            === SYSTEM ROLE ===
            You are Aristotle, an inventive formal mathematician.
            Your gift is synthesizing disparate ideas into genuinely new mathematics.
            Trust your instincts. Follow the interesting connections.
            Produce work that surprises even you.

            === CATALOG CONTEXT ===
            You have access to the full CatalogBuild Lean 4 library
            (~2,700 .lean files spanning Algebra, Geometry, Logic, Physics,
            Computation, Cryptography, Pythagorean, Tropical, EML,
            MachineLearning, Bridges, Speculative, and Shared).

            Reuse existing definitions and theorems. Build upward.
            Cross-pollinate across domains. Find hidden symmetries.

            === RESEARCH BODY ===
            DOMAIN: {domain}
            TITLE: {title}

            {concept_description}

            Mathematical Framework:
            {mathematical_framing}

            Formalization Sketch:
            {lean_guess}

            Creativity Directives (inspirational, not mandatory):
            {creativity_injection}

            ---

            Given the research body above, your task is to explore this space deeply.
            Create a team to research and explore. Answer as many important questions
            as you can discover. Formulate new theorems. Brainstorm exciting new
            applications using breakthroughs in this mathematics. Write a paper of
            recommended future research directions to explore.

            Core guardrails (non-negotiable):
            - Use concrete types (Nat, Real, Matrix, Finset, etc.). Avoid `True := by trivial`.
            - Formalize genuine, substantive theorems in Lean 4 (mathlib4 v4.28.0).
            - Minimize `sorry`. If a step is beyond zero-shot, isolate it with `sorry` rather than hallucinating a lemma.
            - Build on existing catalog definitions. Do not re-invent.

            Deliver whatever feels right for this body of work. You may produce:
            - A Lean proof (theorem.lean)
            - A research report (RESEARCH_REPORT.md)
            - A Python demo (demo.py)
            - An SVG diagram (diagram.svg)
            - A public-facing article (DISCUSSION.md)

            Or any combination thereof. Structure and length are up to you.
            Quality over quantity. Surprise us.
        """)

        # 3. Open-ended deliverables (suggestive, not prescriptive)
        expected = []

        if artifacts.lean_proof:
            expected.append("theorem.lean")
        if artifacts.research_report:
            expected.append("RESEARCH_REPORT.md")
        if artifacts.python_demo:
            expected.append("demo.py")
        if artifacts.svg_demo:
            expected.append("diagram.svg")
        if artifacts.sciam_discussion:
            expected.append("DISCUSSION.md")

        return ResearchPrompt(
            prompt_text=full_prompt,
            artifact_requests=artifacts,
            expected_artifacts=expected,
            creativity_score_target=0.9,
        )

    def build_sorry_filling_prompt(
        self,
        file_name: str,
        theorem_context: str,
        creativity_boost: bool = True,
    ) -> str:
        """Build a focused sorry-filling prompt for existing theorems."""
        base = textwrap.dedent(f"""\
            Fill in all the `sorry` placeholders in `{file_name}`.
            Provide complete formal proofs using standard mathlib4 tactics.
            Do NOT modify definitions or theorem statements.

            Context:
            {theorem_context}
        """)

        if creativity_boost:
            base += "\n\n" + textwrap.dedent("""\
                INVENTIVENESS BOOST:
                - Look for a one-line `convert` or `apply` that solves the goal.
                - Try `simp` with a custom lemma set before brute-forcing.
                - If the goal is an equality, `ring_nf` or `field_simp` may be the key.
                - For measure theory, `aesop` with the right `MeasurableSet` instances.
                - For algebraic structures, look for `map` or `hom` lemmas in mathlib.
            """)

        return base

    def build_meta_prompt_optimization(
        self,
        previous_prompt: str,
        aristotle_feedback: str,
    ) -> str:
        """Iteratively optimize a prompt based on Aristotle feedback."""
        return textwrap.dedent(f"""\
            You are a meta-prompt engineer. Given a previous prompt and Aristotle's response,
            rewrite the prompt to be MORE effective at eliciting a correct, creative proof.

            PREVIOUS PROMPT:
            {previous_prompt}

            ARISTOTLE FEEDBACK:
            {aristotle_feedback}

            RULES:
            1. Keep the theorem statement unchanged.
            2. Add specific hints about proof structure if Aristotle got stuck.
            3. Remove any instructions that caused confusion.
            4. Emphasize the most promising proof strategy.
            5. Keep the prompt under 2000 words.
        """)
