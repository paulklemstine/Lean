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
            "The Berggren tree is a spectral decomposition of the factoring problem — each branch corresponds to an eigenvalue.",
            "Can factoring be reduced to a tropical shortest-path problem on the Berggren graph?",
            "What if semiprime factoring has a phase transition at some critical digit length?",
            "Prove that Berggren tree descent finds a factor in O(n^{1/3}) steps for semiprimes with special structure.",
        ],
        "compression": [
            "Tropical matrix rank IS Kolmogorov complexity for tropical polynomials. Prove it.",
            "The min-plus entropy of a language measures its incompressibility under tropical coding.",
            "Sheaf cohomology measures information redundancy. Prove that H^1(X, F) bounds the compression ratio.",
            "Can tropical coding theory achieve the Singleton bound for codes over the tropical semiring?",
        ],
        "AI": [
            "Neural networks ARE tropical rational functions. What does backpropagation look like in the tropical world?",
            "The universal approximation theorem is a tropical Stone-Weierstrass theorem. Prove the tropical version.",
            "Can tropical geometry explain why overparametrized networks generalize?",
            "Prove that adversarial examples correspond to tropical boundary crossings.",
        ],
        "neural nets": [
            "Backpropagation is a cotangent functor. Prove functoriality and show gradient descent is a natural transformation.",
            "ReLU activation is tropical max-plus. The entire ResNet architecture is a tropical polynomial composition.",
            "Prove that dropout regularization is a tropical perturbation and certified robustness bounds the dropout radius.",
            "Attention mechanisms are tropical weighted averages. Prove a tropical attention theorem connecting softmax to min-plus.",
        ],
        "quantum mechanics": [
            "The Maslov dequantization parameter epsilon is a thermodynamic temperature. The tropical limit is a phase transition.",
            "Tropical quantum mechanics: path integrals over the min-plus semiring select the classical path. Prove this is a contraction.",
            "Can quantum entanglement be formalized as a tropical tensor network? Prove tropical entanglement monogamy.",
            "Prove that the tropical Hamiltonian H_trop = min_i E_i has spectral gap equal to the Maslov gap.",
        ],
        "computation": [
            "Tropical circuits compute min-plus polynomials. Prove a tropical circuit lower bound separating tropical P from tropical NP.",
            "Reversible computing is a group action. Prove that reversible circuits are a group representation of the symmetric group.",
            "P vs NP in the tropical world: prove that tropical 3-SAT is NP-complete but tropical 2-SAT is polynomial.",
            "Prove that tropical Turing machines have strictly different complexity than classical Turing machines for certain problems.",
        ],
        "physics": [
            "Gravitational lensing is a tropical projection: the shortest path through curved spacetime is a min-plus operation.",
            "The AdS/CFT correspondence has a tropical limit where the bulk becomes a min-plus geodesic network on the boundary.",
            "Prove that black hole entropy is the tropical entropy of the horizon microstates.",
            "Cosmic microwave background fluctuations follow a tropical Gaussian distribution. Prove the tropical central limit theorem.",
        ],
        "tropical": [
            "Tropical geometry IS algebraic geometry over the min-plus semiring. Every classical AG theorem has a tropical analogue.",
            "The tropical Satake isomorphism connects representation theory to min-plus polynomial algebra. Extend from GL_2 to GL_n.",
            "Prove the tropical Riemann-Roch: the tropical divisor class group satisfies Riemann-Roch over the tropical semiring.",
            "Tropical Brill-Noether: prove that a tropical curve of genus g has a divisor of degree d and rank r iff rho >= 0.",
        ],
        "eml": [
            "EML (Exponential-Multiplicative-Logarithmic) closures are the algebraic skeleton of universal approximation.",
            "Prove that EML depth equals Kolmogorov complexity up to constants: the shortest EML network computing f has depth Theta(K(f)).",
            "EML thermodynamics: the EML closure of a dataset satisfies a free energy inequality. Prove it.",
            "Prove that EML networks can implement any finite automaton, making them computationally universal.",
        ],
        "pythagorean": [
            "Pythagorean triples are the integer points on a quadric surface. The Berggren tree is a Cayley graph of the integer points.",
            "Prove the Pythagorean zeta function has an Euler product over Pythagorean primes and satisfies a functional equation.",
            "Berggren matrices form a group under matrix multiplication. Prove this group is a subgroup of SL(2,Z).",
            "Pythagorean triples correspond to rational points on the unit circle. Prove the rational parametrization is a group homomorphism.",
        ],
        "cryptography": [
            "Tropical one-way functions: tropical matrix multiplication is easy, tropical matrix inversion is hard. Prove it.",
            "SPB operations on Pythagorean triples generate a group suitable for Diffie-Hellman. Prove discrete log hardness.",
            "Prove that CRYSTALS-Dilithium security reduces to module-SIS in the tropical semiring.",
            "Lattice-based cryptography over tropical semirings: prove that the tropical SVP is NP-hard.",
        ],
        "geometry": [
            "Tropical varieties are piecewise-linear shadows of algebraic varieties. Prove that the tropicalization functor preserves intersection numbers.",
            "Pythagorean triples form integer points on a quadric. Their tropicalization is a tropical curve with genus determined by prime factors.",
            "Prove that tropical convexity satisfies a Helly-type theorem: if every n+1 intersect then all intersect.",
            "The Berggren tree is a tropical rational curve. Prove its tropical genus equals the number of Pythagorean primes less than N.",
        ],
        "logic": [
            "Tropical logic: conjunction is min, disjunction is max, implication is subtraction. Prove soundness and completeness.",
            "Prove that tropical propositional logic is decidable in polynomial time, unlike classical propositional logic.",
            "Non-Archimedean probability: define probability measures over the tropical semiring and prove a tropical law of large numbers.",
            "Constructive type theory over the tropical semiring: prove that tropical HoTT satisfies the univalence axiom.",
        ],
        "bridges": [
            "The deepest results connect fields that seemed unrelated. Find the bridge no one expected.",
            "Every bridge theorem creates a new field. Tropical geometry + machine learning = tropical robustness. What's next?",
            "Prove that the EML closure is a bridge from analysis to algebra: it's both a subalgebra of C(K) and a tropical polynomial ring.",
            "The Langlands program connects number theory and representation theory. What is the tropical Langlands program?",
        ],
    }

    # Universal creativity heuristics
    UNIVERSAL_HEURISTICS = [
        # Mathematical trick heuristics
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
        # Visionary heuristics
        "If this result is true, what entirely new field does it open? Prove that first.",
        "Every deep theorem has a computational shadow. Find the algorithm that computes it.",
        "What is the tropical limit? If you dequantize (epsilon -> 0), does the structure simplify or undergo a phase transition?",
        "What does this look like in the min-plus world? Invert addition and multiplication and see if beauty emerges.",
        "Connect to physics: if this were an energy landscape, what would the ground state be? The critical temperature?",
        "What would a 22nd-century mathematician prove about this? Skip the incremental step and aim for the paradigm shift.",
        "Every inequality has an equality case. What does equality imply? That's usually the deeper structure.",
        "Replace the real numbers with the tropical semiring. If the theorem fails, the failure point reveals the real content.",
        "If this is true for dimension n, what happens in dimension infinity? Compactness arguments often reveal hidden structure.",
        "What would Shannon, Turing, or Wiles do? Shannon would find the information content. Turing would find the algorithm. Wiles would find the Galois representation.",
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

            === CURRENT CATALOG WEAKNESSES (target for improvement) ===
            The weakest domain-pillar combinations that need improvement:
            - Shared Originality (O=4.3/10): Needs genuinely novel definitions and structures
            - Logic Impact (I=5.1/10): Needs connections to cryptography, ML, and physics
            - Physics Utility (U=5.2/10): Needs SPECIFIC computational bounds (O(n), Omega(2^n))
            - Pythagorean Impact (I=4.9/10): Needs connections to physics and cryptography
            - MachineLearning Impact (I=5.4/10): Needs SPECIFIC ML terms (lipschitz, certified_robust)
            Target these weak areas to maximize your AEM Impact score.

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

            === AEM QUALITY SCORING (your output will be scored on these 5 pillars) ===

            RIGOR (0-10): Formal verification quality.
              - ZERO `sorry` in core logic. Every proof is complete.
              - Use diverse tactics: induction, rcases, ext, simp, linarith, omega, field_simp, exact, refine, constructor, by_contra, etc.
              - Proper abstraction: generalize from R to CommRing or Semiring where natural, without over-abstracting into triviality.
              - Semantic coherence: lemmas build on each other logically toward the main theorem.
              Target: 10+ theorems with ZERO sorries and 6+ distinct tactics.

            AESTHETIC (0-10): Mathematical beauty and surprise.
              - Bridge at least 2 seemingly disparate domains (e.g., Tropical + Cryptography, Algebra + Quantum Mechanics).
              - Achieve non-trivial/unintuitive results that challenge expectations.
              - Minimize axiomatic footprint: big results from few assumptions.
              - Exhibit natural symmetries: commutativity, duality, adjointness.
              Target: 2+ cross-domain bridges with non-trivial results.

            UTILITY (0-10): Structural usefulness for further work.
              - Establish computational/complexity bounds (e.g., convergence rates, O() bounds).
              - Define extensible structures: clean APIs with `def`, `structure`, `class`, `instance` for reuse.
              - Advance open problems or significantly narrow search spaces.
              - Provide simplification frameworks.
              Target: 5+ reusable structures/functions with computational bounds (struct, class, def, instance).
              NOTE: Generic terms like "bound", "rate", "convergence" alone do NOT score utility.
              Only SPECIFIC bounds (O(n log n), Omega(2^n), Theta(n^2)) count.

            ORIGINALITY (0-10): Truly novel mathematics.
              - Invent genuinely NEW mathematical objects, operators, or invariants — not parameter tweaks on Mathlib.
              - Apply known theory to completely new domains yielding structurally unfamiliar results.
              - Follow divergent reasoning paths that human intuition would not naturally take.
              - EXPLICITLY mention cross-domain bridges in doc comments: "Bridge: connects X to Y".
              Target: 5+ genuinely new definitions/structures (def, structure, class, instance) that don't exist in Mathlib. High-Originality files average 10+ new definitions.
              NOTE: Generic names (main, test, aux, helper) do NOT count as genuinely new.

            IMPACT (0-10): Wonderful real-world applications.
              - Map directly to Physics (quantum mechanics, thermodynamics, general relativity).
              - Map to Cryptography (post-quantum, lattice-based, zero-knowledge proofs).
              - Map to Machine Learning (certified robustness, Lipschitz bounds, convergence guarantees).
              - Enable systemic optimization (more efficient algorithms, compilers, architectures).
              Target: Explicit connections to 2+ of: physics, cryptography, machine learning.
              NOTE: Impact requires SPECIFIC application terms (e.g., "lipschitz_certified_robustness",
              not just "convergence"). Generic keywords alone do NOT score Impact.

            === AEM QUALITY MANDATE ===
            Your output MUST satisfy ALL five AEM pillars above.
            - RIGOR: Prove every theorem completely. ZERO sorries in core results.
            - AESTHETIC: Include at least 2 cross-domain bridges with surprising connections.
            - UTILITY: Define reusable structures with documented computational bounds.
            - ORIGINALITY: Invent at least 3 genuinely new mathematical objects.
            - IMPACT: Explicitly connect to physics, cryptography, or machine learning.

            Core guardrails (non-negotiable):
            - Use concrete types (Nat, Real, Matrix, Finset, etc.). Avoid `True := by trivial`.
            - Formalize genuine, substantive theorems in Lean 4 (mathlib4 v4.28.0).
            - ZERO sorry in core theorems. If a step is beyond zero-shot, isolate it as a clearly marked auxiliary lemma rather than using sorry.
            - Build on existing catalog definitions. Do not re-invent.
            - Every new definition must serve a purpose and be USED in at least one theorem.
            - Cross-reference domains explicitly in doc comments: e.g., "Bridge: connects Tropical Geometry to Post-Quantum Cryptography via min-plus matrix rank."
            - PRODUCE RICH, SUBSTANTIAL FILES: The highest-AEM files in the catalog average 2000+ lines with 150+ theorems and 60+ definitions. Produce comprehensive files, not stubs. Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected. Target 500+ lines with 20+ theorems and 10+ definitions per file.
            - EXPAND MULTIPLE DOMAINS: When producing a catalog-wide response, create files in multiple domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics, etc.), not just a single domain. The highest-AEM files bridge 2+ domains.

            Deliver whatever feels right for this body of work. You may produce:
            - A Lean proof (theorem.lean)
            - A research report (RESEARCH_REPORT.md)
            - A Python demo (demo.py)
            - An SVG diagram (diagram.svg)
            - A public-facing article (DISCUSSION.md)

            Or any combination thereof. Structure and length are up to you.
            Quality over quantity. Surprise us. Produce work that scores 35+/50 on the AEM rubric.
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
