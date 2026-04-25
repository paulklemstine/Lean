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
        """Assemble a full Aristotle prompt package."""

        if artifacts is None:
            artifacts = ArtifactRequests()

        # 1. Inject domain-specific creativity boosters
        boosters = self.DOMAIN_BOOSTERS.get(domain.lower(), [])
        heuristic_sample = self.UNIVERSAL_HEURISTICS[:5]

        creativity_injection = "\n".join(
            [f"  - {b}" for b in boosters[:3]] +
            [f"  - {h}" for h in heuristic_sample]
        )

        # 2. Main research brainstorm prompt
        theorem_section = textwrap.dedent(f"""\
            === RESEARCH BRAINSTORM ===

            You are Aristotle, the world's most inventive formal mathematician.
            You have been given the FULL CONTEXT of a large mathematical research catalog
            containing theorems and definitions across algebra, geometry, computation,
            cryptography, machine learning, physics, tropical geometry, and more.

            Your task is NOT to prove a pre-selected theorem. Instead:

            1. EXPLORE the catalog ideas below.
            2. BRAINSTORM novel connections and research avenues.
            3. IDENTIFY a genuinely new theorem or algorithm that emerges from mixing these ideas.
            4. FORMALIZE it as a rigorous Lean 4 proof (mathlib4 v4.28.0).

            ---

            RESEARCH SEED:
            {concept_description}

            POTENTIAL CONNECTIONS:
            {mathematical_framing}

            CREATIVITY DIRECTIVES:
            {creativity_injection}

            ---

            RESEARCH AVENUES TO EXPLORE (pick one or invent your own):

            Avenue A — Structural Bridge:
            Can a theorem from one domain be reinterpreted in another?
            Example: What if a cryptographic hardness assumption becomes a topological invariant?

            Avenue B — Algorithmic Extraction:
            Is there an algorithm hidden inside a proof? Can you make it explicit,
            bound its complexity, and prove correctness?

            Avenue C — Duality / Symmetry:
            Does a known theorem have an unexpected dual? A contrapositive in a
            non-standard model? A Galois correspondence nobody noticed?

            Avenue D — Compositional Explosion:
            Take two catalog concepts. Compose them. Does the composition yield
            a new algebraic structure, a new complexity class, or a new physical law?

            Avenue E — Counter-Intuitive Limit:
            Push a theorem to an extreme case. Does it break? Does it reveal a
            new universal property? Does it connect to a different branch of math?

            ---

            OUTPUT INSTRUCTIONS:

            Step 1 — OVERVIEW (1 paragraph):
            Explain the high-level idea. Why is it new? What does it connect?

            Step 2 — THEOREM STATEMENT:
            State the theorem precisely in Lean 4. Use CONCRETE types (Nat, Real, Matrix, Finset)
            when possible, not just {{X : Type*}}. Make a real claim:
            an inequality, an equivalence, a complexity bound, an algorithmic correctness.

            Step 3 — PROOF:
            Provide a complete, rigorous proof. At least 3 non-trivial steps.
            Use tactics like `have`, `calc`, `convert`, `apply`, `nlinarith`.
            DO NOT end with `trivial` or `sorry` unless the theorem truly requires it.

            RULES:
            - Do NOT prove "True" — that is vacuous and useless.
            - Prefer unexpected, elegant strategies over brute force.
            - Use advanced mathlib4 lemmas where possible.
            - The theorem name should be snake_case and genuinely novel.
        """)

        # 3. Artifact generation prompts
        artifact_sections = []
        expected = []

        if artifacts.lean_proof:
            expected.append("Main.lean (completed proof)")

        if artifacts.research_report:
            report_section = textwrap.dedent("""\
                === RESEARCH REPORT ===
                Create a file named `RESEARCH_REPORT.md` with:
                1. ABSTRACT (~150 words, accessible but precise)
                2. MOTIVATION (why this theorem matters for science/engineering)
                3. MATHEMATICAL FRAMEWORK (definitions, notation, preliminaries)
                4. PROOF OVERVIEW (high-level strategy, key lemmas, intuitive sketches)
                5. NOVELTY ANALYSIS (what makes this result new and surprising)
                6. OPEN PROBLEMS (3 concrete follow-up questions)
                7. REFERENCES (real or plausible citations in standard format)
            """)
            artifact_sections.append(report_section)
            expected.append("RESEARCH_REPORT.md")

        if artifacts.python_demo:
            demo_section = textwrap.dedent("""\
                === PYTHON DEMO ===
                Create a file named `demo.py` that:
                1. Illustrates the theorem numerically or visually.
                2. Uses standard libraries (numpy, matplotlib, sympy if needed).
                3. Is self-contained: `python3 demo.py` runs without errors.
                4. Prints the key insight in the `main()` function.
                5. Includes rich comments linking code to the formal proof.
                6. If visualization is natural, save a PNG or generate an inline plot.
            """)
            artifact_sections.append(demo_section)
            expected.append("demo.py")

        if artifacts.svg_demo:
            svg_section = textwrap.dedent("""\
                === SVG DIAGRAM ===
                Create a file named `diagram.svg` that:
                1. Visualizes the theorem's key structure geometrically or algebraically.
                2. Uses pure SVG (no external libraries, self-contained).
                3. Is renderable in any modern browser.
                4. Labels important points, regions, morphisms, or mappings.
                5. Includes a caption at the bottom.
                6. Use color to distinguish different mathematical objects.
            """)
            artifact_sections.append(svg_section)
            expected.append("diagram.svg")

        if artifacts.sciam_discussion:
            sciam_section = textwrap.dedent(f"""\
                === SCIENTIFIC AMERICAN ARTICLE ===
                Create a file named `DISCUSSION.md`:
                Title: "{title}: When {domain} Meets the Future"

                Tone: Accessible to scientifically literate general readers.
                Avoid excessive notation. Use analogies, metaphors, and vivid imagery.

                Structure:
                - LEDE (hook): A surprising scenario, historical anecdote, or futuristic vignette.
                - THE MATHEMATICAL HEART: Explain the theorem without equations, using visual and physical metaphors.
                - WHY IT MATTERS: Real or imagined applications in AI, physics, cryptography, or space exploration.
                - THE BEAUTY: What makes this elegant? What symmetry or unexpected connection does it reveal?
                - LOOKING AHEAD: What doors does this open? What might the next century of math look like?
                - CLOSING: A philosophical reflection on mathematical truth and human curiosity.

                Length: ~1200 words.
            """)
            artifact_sections.append(sciam_section)
            expected.append("DISCUSSION.md")

        # 4. Final assembly
        full_prompt = theorem_section + "\n\n"
        for section in artifact_sections:
            full_prompt += section + "\n\n"

        full_prompt += textwrap.dedent("""\
            === DELIVERABLES CHECKLIST ===
            Ensure ALL requested files are present in the project directory.
            Each file should be complete, well-formatted, and ready for publication.
        """)

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
