            Soli Deo Gloria

            ## Assignment: The rank-parametrized certificate framework for symplectic expanders opens five 

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, rcases, by_contra, field_simp,
   or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain (e.g., number theory + tropical
   geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.


            ### Research Direction
            # Future Directions: Uniform Symplectic Expansion

## Synthesis

The rank-parametrized certificate framework for symplectic expanders opens five interconnected research directions, unified by a single architectural insight: *the right formal abstraction for expansion is not a spectral bound but a certificate type*. The torus witness object separates representation-theoretic content from spectral machinery, creating a modular interface that different mathematical domains can independently plug into.

The directions below form a progression: Direction 1 (optimal constants) improves the engine's efficiency; Direction 2 (other classical groups) expands its scope; Direction 3 (coding theory) applies it to a concrete engineering domain; Direction 4 (automorphic forms) connects it to deep number theory; and Direction 5 (quantum dynamics) bridges to physics. Each direction strengthens the others — better constants improve applications, other groups provide new test cases, and quantum connections motivate the whole program.

---

## Direction 1: Optimal Character-Ratio Constants via Coxeter Torus Analysis

**Conjecture:** For the Coxeter torus in Sp₂ₙ(𝔽_q), the character-ratio constant C_n is bounded by a universal constant C independent of the rank n. Specifically, for all nontrivial irreducible representations ρ and regular Coxeter toral elements s:

$$\left|\frac{\chi_\rho(s)}{\chi_\rho(1)}\right| \leq \frac{C}{q}$$

where C depends only on the Dynkin type (C_n), not on n.

**Test:** Compute character ratios for Sp₆(𝔽_q), Sp₈(𝔽_q), Sp₁₀(𝔽_q) at q = 7, 11, 13 using GAP or MAGMA. If the fitted constants C₃, C₄, C₅ stabilize (rather than growing linearly), the conjecture is supported. If C_n grows linearly with n, it is falsified.

**Impact:** An O(1) constant would mean the spectral gap approaches 1 uniformly across *both* rank and field size — a dramatically stronger result than our current linear growth. This would make the expansion machine essentially rank-free.

**Cata

            ### Mathematical Framing
            # Future Directions: Uniform Symplectic Expansion

## Synthesis

The rank-parametrized certificate framework for symplectic expanders opens five interconnected research directions, unified by a single architectural insight: *the right formal abstraction for expansion is not a spectral bound but a certificate type*. The torus witness object separates representation-theoretic content from spectral machinery, creating a modular interface that different mathematical domains can independently plug into.

The directions below form a progression: Direction 1 (optimal constants) improves the engine's efficiency; Direction 2 (other classical groups) expands its scope; Direction 3 (coding theory) applies it to a concrete engineering domain; Direction 4 (automorphic forms) connects it to deep number theory; and Direction 5 (quantum dynamics) bridges to physics. Each direction strengthens the others — better constants improve applications, other groups provide new test cases, and quantum connectio


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `uniform_expansion_from_rank_certificate` : theorem uniform_expansion_from_rank_certificate
     (file: FINAL/Pythagorean/Sp2nExpansion.lean)
  2. `uniform_expansion_from_rank_certificate` : theorem uniform_expansion_from_rank_certificate
     (file: Pythagorean/Sp2nExpansion.lean)
  3. `conjecture_uniform_spectral_gap` : theorem conjecture_uniform_spectral_gap : True := trivial
     (file: FINAL/Pythagorean/CertificateExpanders.lean)
  4. `conjecture_uniform_spectral_gap` : theorem conjecture_uniform_spectral_gap : True := trivial
     (file: Pythagorean/CertificateExpanders.lean)
  5. `gap_improves_with_better_constant` : theorem gap_improves_with_better_constant
     (file: Bridges/Catalog/Pythagorean/SymplecticRankExpansion.lean)
  6. `gap_improves_with_better_constant` : theorem gap_improves_with_better_constant
     (file: FINAL/Bridges/SymplecticRankExpansion.lean)
  7. `spectral_gap_correlation_bound` : theorem spectral_gap_correlation_bound (k : ℕ)
     (file: FINAL/Pythagorean/BerggrenProductGrowth.lean)
  8. `spectral_gap_log_concave_lower_bound` : theorem spectral_gap_log_concave_lower_bound (n : ℕ) (π : ProbDist n)
     (file: FINAL/Pythagorean/CertificateSampling.lean)
  9. `bounded_by_envelope_of_uniform_bound` : theorem bounded_by_envelope_of_uniform_bound {α : Type*} {ι : Type*}
     (file: FINAL/Pythagorean/MaxEnvelopeStability.lean)
  10. `linear_sieve_for_bounded_entries` : theorem linear_sieve_for_bounded_entries (ds : List ℕ) (B : ℕ) (_hB : B > 0)
     (file: FINAL/Pythagorean/TorsionProfileTheorems.lean)
  11. `spectral_gap_correlation_bound` : theorem spectral_gap_correlation_bound (k : ℕ)
     (file: Pythagorean/BerggrenProductGrowth.lean)
  12. `spectral_gap_log_concave_lower_bound` : theorem spectral_gap_log_concave_lower_bound (n : ℕ) (π : ProbDist n)
     (file: Pythagorean/CertificateSampling.lean)
  13. `bounded_by_envelope_of_uniform_bound` : theorem bounded_by_envelope_of_uniform_bound {α : Type*} {ι : Type*}
     (file: Pythagorean/MaxEnvelopeStability.lean)
  14. `linear_sieve_for_bounded_entries` : theorem linear_sieve_for_bounded_entries (ds : List ℕ) (B : ℕ) (_hB : B > 0)
     (file: Pythagorean/TorsionProfileTheorems.lean)
  15. `spectral_gap_correlation_bound` : theorem spectral_gap_correlation_bound
     (file: Pythagorean/ArithmeticPRG/Core.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


No specific files referenced. Use Mathlib and general knowledge.

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above (FINAL/ entries are vetted, high-quality — prioritize these).

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            ### Team Directive
            You are not a lone researcher — you are LEADING a research science team.
            Organize your team into roles:

            1. **Hypothesis Team**: Brainstorm 3-5 bold, falsifiable hypotheses.
               Each must be a precise conjecture that can be proved or disproved.
            2. **Experiment Team**: Design and run Lean 4 experiments to test each
               hypothesis. Prove theorems, find counterexamples, compute examples.
            3. **Analysis Team**: Examine results. Which hypotheses survived? Which
               failed? What does each failure teach? Update the knowledge base.
            4. **Iteration Lead**: Based on analysis, propose the NEXT round of
               hypotheses. Science is a loop: hypothesize → experiment → analyze →
               repeat. Each cycle must advance the frontier.

            The team operates as a self-improving science engine. Each round builds
            on the last. Failed hypotheses are as valuable as successful ones — they
            constrain the search space and reveal structure.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md, RESEARCH_PAPER.md,
                      ARTICLE.md (Scientific American style), algorithm, demo.py
            Optional: (none — all key deliverables are mandatory)

            ## Taboo Topics for ARTICLE.md

            The Scientific American-style article MUST NOT focus on formal verification
            or machine verification. Do not write about proof assistants, type theory
            as verification, or mechanized checking — those topics are technical niche
            and alienate a broad audience. Instead, write about the IDEAS: what was
            discovered, why it matters, and what it means for mathematics and science.
            The article should read like a Scientific American feature, not a software
            demo or verification report.

            ## Catalog Context for Future Directions
            Below is information about the current state of the Catalog. Reference
            specific theorems by their Catalog file paths when writing FUTURE_DIRECTIONS.md.
            Use the **Catalog References** field to cite the exact file paths.

            ### Catalog Breakthrough Analysis
            ## Catalog Breakthrough Analysis

### Under-Explored Domains (many declarations, few deep results)
- Algebra: 13064 declarations, 0 sorries, exploration ratio 13064.0 (HIGH potential)
- MachineLearning: 9232 declarations, 1 sorries, exploration ratio 9232.0 (HIGH potential)
- EML: 5561 declarations, 0 sorries, exploration ratio 5561.0 (HIGH potential)
- Computation: 3610 declarations, 0 sorries, exploration ratio 3610.0 (HIGH potential)
- Logic: 3401 declarations, 0 sorries, exploration ratio 3401.0 (HIGH potential)

### Structural Opportunities (shared structures, no bridge)
- Algebra <-> MachineLearning: Both Algebra and MachineLearning use category, field, functor, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- Algebra <-> EML: Both Algebra and EML use category, field, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- EML <-> MachineLearning: Both EML and MachineLearning use category, field, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- Algebra <-> Tropical: Both Algebra and

            ### Key Theorems Available (for lineage references)
            **Algebra**:
  `Algebra/Advanced.lean`: iterateB, iterateB_one, iterateB_two
  `Algebra/Agent.lean`: euclid_inradius_num, euclid_perimeter, euclid_twice_area
  `Algebra/Berggren.lean`: applyB₁, A_iter, A_closed
**Bridges**:
  `Bridges/AlgebraEMLClosureComputation.lean`: ClosureSemimoduleSystem, ProbeFamily, ClosureStableProbe
  `Bridges/AlgebraEMLReconstruction.lean`: SetClosureOperator, {α, ClosedSet
  `Bridges/AlgebraPythagoreanCryptography/BerggrenLatticeReductionDuality.lean`: PrimTriple, PrimTriple.a_lt_c, PrimTriple.b_lt_c
**Computation**:
  `Computation/GravityOracle.lean`: IsGravOracle, GravTruthSet, geodesic_oracle_idempotent
  `Computation/InfoEfficientAlgorithms.lean`: InfoEfficientAlgorithm, InfoEfficientAlgorithm.terminates_within_potential, BSState
  `Computation/PadicValuationDepth.lean`: ValuationDepthMeasure, vdepth_const_eq_zero, vdepth_sum_le
**Cryptography**:
  `Cryptography/BerggrenDiophantineLattice.lean`: lorentzForm, euclidNormSq, IsPythagoreanVec
  `Cryptography/BerggrenFingerprintRigidity.lean`: berggrenGen, evalWord, rootTriple
  `Cryptography/BerggrenGroupoidOrbit.lean`: berggrenA, berggrenB, berggrenC
**EML**:
  `EML/AdvancedTheory.lean`: ensembleComplexity, ensemble_complexity_additive, uniform_ensemble_complexity
  `EML/EMLv17Core.lean`: eml, emlDiag, sigmaEml
  `EML/ModularForms.lean`: T_sq, S_gen, BM₃_inv

            FUTURE_DIRECTIONS.md MUST be a standalone research roadmap. It will be
            used to steer future research rounds WITHOUT access to this cycle's code.
            Each direction must be self-contained: include enough mathematical context,
            definitions, and motivation that a fresh researcher can pick up any
            direction and start working on it immediately. Do NOT assume the reader
            has seen your Lean code.

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Begin with a ## Synthesis section tying all directions together and
            identifying the most promising cross-domain connections from this cycle.
            Then list 3-5 directions (1-2 grand_challenge + 2-3 extension) using:

            ## Synthesis

            [2-3 paragraphs tying all directions together. Identify the most promising
            cross-domain connection from this cycle's discoveries. Explain how the
            cycle's results relate to the broader Catalog. Highlight which direction
            has the highest breakthrough potential and why.]

            ---

            ### Direction 1: [Title]

            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would confirm
            or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what does
            the failure teach us?
            **Catalog References**: `Bridges.Basic.lean`, `Algebra.QuadraticForms.mordell`
            (Use backtick-enclosed file paths or theorem names from the Catalog.)
            **Proof Strategy**: Outline the key steps or approach. What mathematical
            machinery is needed? What lemmas would need to be established first?
            **Domain Bridges**: NumberTheory <-> Tropical, Algebra <-> Physics
            (List domain pairs this connects, using the <-> connector.)
            **Lineage**: Builds on fd_XXXX and discoveries from exp_XXXXXXXX_XXX
            (Reference specific prior direction IDs or experiment IDs if known, or
            describe which prior results this extends.)
            **Ambition**: grand_challenge  (or: extension)

            ---

            [repeat for each direction]

            Do real science. Propose hypotheses that are bold enough to matter and
            specific enough to fail. Vague explorations like "study X further" or
            "extend Y" are not hypotheses — they are homework. Give us ideas that
            could change how we think about the problem.

            Soli Deo Gloria.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
