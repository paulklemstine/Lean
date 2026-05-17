#!/usr/bin/env python3
"""PromptEngine: Advanced prompt optimization for Aristotle.

v3: Integrates with PromptDNA for evolving, modular prompts.
Removed tropical-only boosters. Domain boosters are now general-purpose.
"""

import textwrap
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any

from prompt_dna import PromptDNA


@dataclass
class ArtifactRequests:
    """Flags for what artifacts Aristotle should produce."""
    research_report: bool = True
    python_demo: bool = True
    svg_demo: bool = False
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
    """Optimizes prompts for Aristotle to maximize breakthrough potential.

    v3: Uses PromptDNA for evolving prompts. Domain boosters are diversified.
    """

    # Domain-specific creativity boosters — diversified, not tropical-only
    DOMAIN_BOOSTERS = {
        "numbertheory": [
            "Can you connect this to the distribution of primes via analytic methods?",
            "What does the p-adic perspective reveal? Non-Archimedean metrics often simplify.",
            "Is there a modular forms connection? Modularity has resolved deep conjectures.",
            "What does the circle method or sieve theory say about this problem?",
        ],
        "algebra": [
            "Look for a hidden group action or symmetry that simplifies the structure.",
            "Reframe using representation theory — characters often reveal hidden structure.",
            "Is there a Galois-theoretic perspective? Field extensions expose arithmetic.",
            "Consider the problem over different base rings — what's the universal property?",
        ],
        "geometry": [
            "What does the problem look like in the projective completion?",
            "Is there an intersection-theoretic formulation with computable invariants?",
            "Try tropicalization — the combinatorial shadow may reveal the essential structure.",
            "What does deformation theory say? Moduli spaces encode all variations.",
        ],
        "analysis": [
            "Consider the problem in function spaces — is there a fixed-point theorem?",
            "What does the spectral theory say? Eigenvalues encode deep structure.",
            "Is there a variational formulation? Minimizers often have regularity.",
            "Try the probabilistic method — random constructions can prove existence.",
        ],
        "computation": [
            "Is there a circuit complexity lower bound hiding here?",
            "What's the communication complexity of the problem? Information-theoretic bounds?",
            "Can you reduce to a known-hard problem to establish a barrier?",
            "Is there an efficient algorithm, or can you prove conditional lower bounds?",
        ],
        "physics": [
            "What's the Lagrangian? Symmetries yield conservation laws via Noether's theorem.",
            "Is there a path integral formulation? The saddle point is often the classical solution.",
            "Consider the thermodynamic limit — phase transitions reveal universal behavior.",
            "What does renormalization group flow tell us about the problem's scale structure?",
        ],
        "logic": [
            "What does this look like in constructive mathematics? Is excluded middle needed?",
            "Is there a proof-theoretic ordinal that measures the strength of this statement?",
            "Can you encode this as a type theory problem? Proofs as programs.",
            "Consider the model-theoretic perspective — what structures satisfy this?",
        ],
        "cryptography": [
            "Is there a worst-case to average-case reduction?",
            "What's the quantum complexity? Is this post-quantum secure?",
            "Can you build a zero-knowledge proof from this hardness assumption?",
            "What lattice problem does this reduce to?",
        ],
        "machinelearning": [
            "What generalization bounds can you prove? PAC-Bayes? Compression?",
            "Is there an information-theoretic lower bound on sample complexity?",
            "What does the neural tangent kernel perspective reveal?",
            "Can you prove an approximation theorem with explicit depth/width bounds?",
        ],
        "tropical": [
            "Tropical geometry IS algebraic geometry over the min-plus semiring.",
            "The tropicalization functor preserves many classical invariants — which ones?",
            "Tropical convexity is different from classical convexity — exploit the difference.",
            "Min-plus linear algebra has different rank theory — use it.",
        ],
        "combinatorics": [
            "Is there a probabilistic proof? The Lovász Local Lemma is surprisingly powerful.",
            "What does the algebraic method (polynomial method) reveal?",
            "Is there a topological obstruction? Borsuk-Ulam type arguments?",
            "Can you find the right extremal function? Turán-type results?",
        ],
        "topology": [
            "What do the homotopy groups tell us? Higher homotopy is often tractable.",
            "Is there a spectral sequence that computes the answer?",
            "Consider the problem in the derived category — homological algebra may help.",
            "What does surgery theory say? Can you reduce to algebra?",
        ],
    }

    # Universal creativity heuristics — diversified
    UNIVERSAL_HEURISTICS = [
        "If the obvious approach fails, take the Galois dual.",
        "Reframe the problem in the category of sheaves over a site.",
        "Look for a hidden group action or symmetry.",
        "Try to prove the contrapositive in a non-standard model.",
        "Consider the p-adic analogue — non-Archimedean metrics simplify convergence.",
        "If analysis is hard, try algebra. If algebra is hard, try geometry.",
        "What would this theorem say in homotopy type theory?",
        "Can you encode the theorem as a type and the proof as a program?",
        "Look for an adjunction: left adjoints preserve colimits, right adjoints preserve limits.",
        "If this result is true, what entirely new field does it open? Prove that first.",
        "Every deep theorem has a computational shadow. Find the algorithm.",
        "What would a 22nd-century mathematician prove about this?",
        "Every inequality has an equality case. The equality case reveals deeper structure.",
        "If this is true for dimension n, what happens in dimension infinity?",
        "What would Shannon, Turing, or Wiles do with this problem?",
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
        dna: Optional[PromptDNA] = None,
        cycle_n: int = 0,
        memory_summary: str = "",
        presearch_context: str = "",
    ) -> ResearchPrompt:
        """Assemble a full Aristotle prompt package.

        If a PromptDNA is provided, uses the evolving modular system.
        Otherwise falls back to a static prompt (backward compatible).
        """
        if artifacts is None:
            artifacts = ArtifactRequests()

        if dna:
            # v3: Use evolving DNA system
            full_prompt = dna.assemble(
                cycle_n=cycle_n,
                domain=domain,
                concept_description=concept_description,
                mathematical_framing=mathematical_framing,
                lean_guess=lean_guess,
                title=title,
                memory_summary=memory_summary,
                presearch_context=presearch_context,
            )
        else:
            # Fallback: static prompt (backward compatible)
            boosters = self.DOMAIN_BOOSTERS.get(domain.lower(), [])
            heuristic_sample = self.UNIVERSAL_HEURISTICS[:5]

            creativity_injection = "\n".join(
                [f"  - {b}" for b in boosters[:3]] +
                [f"  - {h}" for h in heuristic_sample]
            )

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

                Given the research body above, explore this space deeply.
                Answer as many important questions as you can discover.
                Formulate new theorems. Brainstorm exciting new applications.
                Write a paper of recommended future research directions.

                Core guardrails (non-negotiable):
                - Use concrete types (Nat, Real, Matrix, Finset, etc.).
                - Formalize genuine, substantive theorems in Lean 4 (mathlib4 v4.28.0).
                - Minimize sorry. Isolate hard steps as auxiliary lemmas.
                - Build on existing catalog definitions. Do not re-invent.

                Deliver ALL of the following:
                - Lean 4 formal proofs (theorem.lean)
                - A research report (RESEARCH_REPORT.md)
                - A Python demo (demo.py)
                - A public-facing article (DISCUSSION.md)
                - A FUTURE_DIRECTIONS.md

                Quality over quantity. Surprise us.
            """)

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
