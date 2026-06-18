            Soli Deo Gloria

            ## Assignment: Information Geometry of Optimization: Natural Gradient Follows Geodesics

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
            The natural gradient algorithm updates parameters theta in the direction of steepest descent on the Fisher information manifold: theta_{t+1} = theta_t - eta * G^{-1}(theta_t) * gradient L(theta_t) where G is the Fisher information matrix. This is equivalent to following the geodesic on the statistical manifold (the Riemannian manifold with metric G). Conjecture: for any optimization problem with loss function L, the natural gradient descent converges to the minimum in O(1/t) iterations, regardless of the condition number of G. This is because the natural gradient follows the geodesic, which is the shortest path on the manifold, and the path length is O(1) (bounded by the diameter of the manifold). In contrast, standard gradient descent takes O(kappa) iterations where kappa is the condition number of G. Conjecture: natural gradient descent with step size eta = 1/t achieves L(theta_t) - L(theta*) = O(1/t) for convex losses, and L(theta_t) - L(theta*) = O(exp(-t/d)) for strongly convex losses, where d is the dimension. Test: compare natural gradient descent and standard gradient descent on logistic regression with varying condition numbers, verify the convergence rates. Impact: optimization is geometry. The natural gradient is the geodesic on the Fisher manifold, and geodesics are the shortest paths.

            ### Mathematical Framing
            The natural gradient algorithm updates parameters theta in the direction of steepest descent on the Fisher information manifold: theta_{t+1} = theta_t - eta * G^{-1}(theta_t) * gradient L(theta_t) where G is the Fisher information matrix. This is equivalent to following the geodesic on the statistical manifold (the Riemannian manifold with metric G). Conjecture: for any optimization problem with loss function L, the natural gradient descent converges to the minimum in O(1/t) iterations, regardless of the condition number of G. This is because the natural gradient follows the geodesic, which is the shortest path on the manifold, and the path length is O(1) (bounded by the diameter of the manifold). In contrast, standard gradient descent takes O(kappa) iterations where kappa is the condition number of G. Conjecture: natural gradient descent with step size eta = 1/t achieves L(theta_t) - L(theta*) = O(1/t) for convex losses, and L(theta_t) - L(theta*) = O(exp(-t/d)) for strongly convex lo


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `lehmer_gap_degree_bounded_conjecture` : theorem lehmer_gap_degree_bounded_conjecture :
     (file: Speculative/AutoResearch/MahlerMeasure.lean)
  2. `gazing_pool_conjecture_bounded` : theorem gazing_pool_conjecture_bounded {W : Type*} [Fintype W] [DecidableEq W] [Nonempty W]
     (file: Speculative/Other/GazingPoolOpenQuestions.lean)
  3. `radial_gradient_step_contraction` : theorem radial_gradient_step_contraction
     (file: Speculative/RiemannianGradientFlow/Theorems.lean)
  4. `extracted_term_semantically_equivalent_with_size` : theorem extracted_term_semantically_equivalent_with_size
     (file: Bridges/HigherOrderEqSat.lean)
  5. `gradient_descent_convergence` : theorem gradient_descent_convergence (L : ℝ) (hL : 0 < L) (T : ℕ) (hT : 0 < T) :
     (file: Bridges/KTheoryNeuralAdvanced.lean)
  6. `iterations_for_eps_convergence` : theorem iterations_for_eps_convergence
     (file: Bridges/KantorovichLawvereDuality.lean)
  7. `extracted_term_semantically_equivalent_with_size` : theorem extracted_term_semantically_equivalent_with_size
     (file: FINAL/Bridges/HigherOrderEqSat.lean)
  8. `gradient_descent_convergence` : theorem gradient_descent_convergence (L : ℝ) (hL : 0 < L) (T : ℕ) (hT : 0 < T) :
     (file: FINAL/Bridges/KTheoryNeuralAdvanced.lean)
  9. `iterations_for_eps_convergence` : theorem iterations_for_eps_convergence
     (file: FINAL/Bridges/KantorovichLawvereDuality.lean)
  10. `gradient_descent_convergence_rate` : theorem gradient_descent_convergence_rate (T : ℕ) (hT : 0 < T) :
     (file: FINAL/Shared/EntropyLatticeCrypto.lean)
  11. `gradient_descent_convergence_rate` : theorem gradient_descent_convergence_rate (T : ℕ) (hT : 0 < T) :
     (file: Shared/EntropyLatticeCrypto.lean)
  12. `diameter_bound_from_growth` : theorem diameter_bound_from_growth
     (file: Speculative/AutoResearch/BGTStructure.lean)
  13. `bounded_confluence_from_joinable_cps` : theorem bounded_confluence_from_joinable_cps
     (file: Speculative/AutoResearch/BetaCompletionTheory.lean)
  14. `reduction_terminates_with_height_bound` : theorem reduction_terminates_with_height_bound
     (file: Speculative/AutoResearch/Bridges/BerggrenLatticeReduction/Lattice.lean)
  15. `feasibleChannelSet_bounded` : theorem feasibleChannelSet_bounded (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
     (file: Speculative/AutoResearch/Bridges/FiniteRateDistortion/Structural.lean)

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

            ### Anti-Triviality Rules
            Do NOT produce any of the following:
            - Commutativity/associativity proofs for standard algebraic structures
              (e.g., `a + b = b + a` for semirings, `a * b * c = a * (b * c)`)
            - Wrapper theorems that just unwrap a definition without mathematical insight
            - Proofs that are just `by simp` or `by trivial` with no depth
            - Definitions followed by trivial properties that don't advance understanding
            - "Bridge" theorems that merely transfer a property between domains without
              adding new content (e.g., "semiring X is also a Y" without a new theorem)
            If a result seems obvious, prove something STRONGER — the stronger theorem
            is often easier to prove and more interesting.

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
- MachineLearning: 10518 declarations, 1 sorries, exploration ratio 10518.0 (HIGH potential)
- EML: 5647 declarations, 0 sorries, exploration ratio 5647.0 (HIGH potential)
- Computation: 3610 declarations, 0 sorries, exploration ratio 3610.0 (HIGH potential)
- Logic: 3401 declarations, 0 sorries, exploration ratio 3401.0 (HIGH potential)

### Structural Opportunities (shared structures, no bridge)
- Algebra <-> MachineLearning: Both Algebra and MachineLearning use category, field, functor, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- Algebra <-> EML: Both Algebra and EML use category, field, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- EML <-> MachineLearning: Both EML and MachineLearning use category, field, group, hilbert, lattice, manifold, measure, metric, metricspace, module, monoid, norm, normed, normedspace, order, ring, semiring, topological, topologicalspace, topology, tropical but no bridge exists between them
- Algebra <-> Tropical: Both Algebra a

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

Research domain: Speculative
Research mode: prove
