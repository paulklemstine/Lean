            ## Assignment: Inverse Stereographic Neural Field Theory

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

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.


            ### Research Direction
            Neural field equations model macroscopic brain dynamics as PDEs on cortical surfaces. The cortical surface is topologically a sphere with cortical folds. Use inverse stereographic projection to transform neural field PDEs on S^2 into PDEs on R^2 with a conformal weight. Define a stereographic neural field as a function u: S^n to R satisfying Delta_{S^n} u = f(u) where Delta_{S^n} is the Laplace-Beltrami operator on the sphere. Under inverse stereographic projection, this becomes a PDE on R^n with a conformally modified Laplacian. Conjecture: The neural field equation on S^2 with Mexican-hat connectivity has exactly 2N+1 stable pattern solutions for interaction radius r, where N = floor(1/r). Under inverse stereographic projection, these correspond to N-fold symmetric patterns on R^2 that decay at infinity. The 2N+1 count comes from the representation theory of SO(3): each pattern of degree l has 2l+1 rotational variants, and the Mexican-hat kernel selects l = N. Test: prove the existence of 2N+1 patterns for r = 1/k (k=1,2,3) by constructing them as stereographic projections of spherical harmonics. Impact: a geometric theory of neural pattern formation with provable pattern counts, enabling predictions about visual hallucination patterns.

            ### Mathematical Framing
            Neural field equations model macroscopic brain dynamics as PDEs on cortical surfaces. The cortical surface is topologically a sphere with cortical folds. Use inverse stereographic projection to transform neural field PDEs on S^2 into PDEs on R^2 with a conformal weight. Define a stereographic neural field as a function u: S^n to R satisfying Delta_{S^n} u = f(u) where Delta_{S^n} is the Laplace-Beltrami operator on the sphere. Under inverse stereographic projection, this becomes a PDE on R^n with a conformally modified Laplacian. Conjecture: The neural field equation on S^2 with Mexican-hat connectivity has exactly 2N+1 stable pattern solutions for interaction radius r, where N = floor(1/r). Under inverse stereographic projection, these correspond to N-fold symmetric patterns on R^2 that decay at infinity. The 2N+1 count comes from the representation theory of SO(3): each pattern of degree l has 2l+1 rotational variants, and the Mexican-hat kernel selects l = N. Test: prove the existen


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `mexican_hat_mode_selection_conjecture` : theorem mexican_hat_mode_selection_conjecture
     (file: Geometry/StereographicNeuralField/Theorems.lean)
  2. `stereo_kernel_symmetric` : theorem stereo_kernel_symmetric (t s : ℝ) :
     (file: FINAL/Geometry/AdvancedTheory.lean)
  3. `null_sphere_has_measure_zero` : theorem null_sphere_has_measure_zero :
     (file: FINAL/Geometry/GapMatterResearch.lean)
  4. `stereo_kernel_symmetric` : theorem stereo_kernel_symmetric (t s : ℝ) :
     (file: Geometry/AdvancedTheory.lean)
  5. `null_sphere_has_measure_zero` : theorem null_sphere_has_measure_zero :
     (file: Geometry/GapMatterResearch.lean)
  6. `degree1_exact_from_cover_and_local_positivity` : theorem degree1_exact_from_cover_and_local_positivity
     (file: Bridges/MarginCosheaf.lean)
  7. `degree1_exact_from_cover_and_local_positivity` : theorem degree1_exact_from_cover_and_local_positivity
     (file: FINAL/Bridges/MarginCosheaf.lean)
  8. `conformal_factor_bounded'` : theorem conformal_factor_bounded' (t : ℝ) :
     (file: FINAL/Geometry/InverseStereoUniverse.lean)
  9. `conformal_factor_bounded'` : theorem conformal_factor_bounded' (t : ℝ) :
     (file: Geometry/InverseStereoUniverse.lean)
  10. `depth_lower_bound_from_degree` : theorem depth_lower_bound_from_degree (C : AlgCircuit R n) (d : ℕ)
     (file: Algebra/AlgebraicCircuitComplexity.lean)
  11. `geometric_decay_bound` : theorem geometric_decay_bound (k d₀ : ℝ) (hk_nn : 0 ≤ k) (hk_lt : k < 1)
     (file: Algebra/SpectralContractionAlgebra.lean)
  12. `irrep_count_from_dim_bound` : theorem irrep_count_from_dim_bound
     (file: Bridges/Catalog/Pythagorean/Sp4SpectralGap.lean)
  13. `activation_pattern_count_bound` : theorem activation_pattern_count_bound (k w : ℕ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  14. `depth_lower_bound_from_degree` : theorem depth_lower_bound_from_degree (C : AlgCircuit R n) (d : ℕ)
     (file: FINAL/Algebra/AlgebraicCircuitComplexity.lean)
  15. `geometric_decay_bound` : theorem geometric_decay_bound (k d₀ : ℝ) (hk_nn : 0 ≤ k) (hk_lt : k < 1)
     (file: FINAL/Algebra/SpectralContractionAlgebra.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


No specific files referenced. Use Mathlib and general knowledge.

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above (FINAL/ entries are vetted, high-quality — prioritize these).

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction.

            ### Anti-Triviality Rules
            Do NOT produce any of the following:
            - Commutativity/associativity proofs for standard algebraic structures
              (e.g., `a + b = b + a` for semirings, `a * b * c = a * (b * c)`)
            - Wrapper theorems that just unwrap a definition without mathematical insight
            - Proofs that are just `by simp` or `by trivial` with no depth
            - Definitions followed by trivial properties that don't advance understanding
            If a result seems obvious, prove something STRONGER — the stronger theorem
            is often easier to prove and more interesting.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md, RESEARCH_PAPER.md,
                      ARTICLE.md (Scientific American style), algorithm, demo.py,
                      at least 1 interactive HTML demo in PACKAGE.json
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
            Below are key theorems from the Catalog for lineage references.
            Use the **Catalog References** field to cite the exact file paths.

            ### Key Theorems Available
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


### Deliverables

You are a world-class mathematician, software engineer, and science writer.
We need ALL of the following:

1. **Lean 4 proofs** — Non-trivial theorems with complete proofs (no `sorry`).
   Organize as makes sense. Use doc comments for key results.

2. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or proof assistants.
   Vivid prose, narrative arc, real-world connections. Must make sense standalone.

3. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results with proof sketches, algorithms, applications,
   discussion, future work, references.

4. **Python code** — demo.py (numerical examples), algorithms.py (type-hinted implementations),
   and up to 3 self-contained visualization scripts (matplotlib/plotly, each a single file
   with all functions inlined — no local imports).

5. **FUTURE_DIRECTIONS.md** (MOST IMPORTANT — drives next cycle).
   Begin with ## Synthesis tying all directions together. Then 3-5 directions using:
   **Conjecture**, **Test**, **Impact**, **Catalog References**, **Proof Strategy**,
   **Domain Bridges**, **Lineage**, **Ambition** (grand_challenge or extension).
   Each direction must be self-contained and specific enough to fail.

6. **PACKAGE.json** — Single JSON bundling all artifacts:
   title, domain, article, research_paper, future_directions, demos, algorithms,
   visualizations, interactive_demos, lean_proofs. JSON-escape all content.

   **interactive_demos** (MANDATORY — include at least 1): Array of objects, each with:
   - `name`: short title
   - `html`: self-contained HTML+CSS+JS snippet (inline styles, no external JS files,
     no local imports, CDN links OK for d3/plotly). Must render an interactive widget
     (slider, button, animation, etc.) that demonstrates a key result visually.
     Wrap in a `<div>` with inline styles. Use vanilla JS — no frameworks.
   - `description`: one-sentence summary

   **visualizations**: Array of objects with `name`, `code` (standalone Python script
   using matplotlib or plotly, all functions inlined), `description`.

   **algorithms**: Array of objects with `name`, `pseudocode` (brief), `code` (Python).

Research domain: Geometry
Research mode: prove
