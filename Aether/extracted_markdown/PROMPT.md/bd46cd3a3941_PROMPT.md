            ## Assignment: Hypergraph Ramsey Theory: Beyond Graphs

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
            Ramsey's theorem for graphs states that R(k,l) = the minimum n such that any 2-coloring of the edges of K_n contains a red K_k or a blue K_l. For hypergraphs: R_r(k,l) = the minimum n such that any 2-coloring of the r-tuples of an n-set contains a red K_k^{(r)} or a blue K_l^{(r)}. The growth rate is an open problem: R_3(4,4) = 13 (known), R_3(5,5) is between 34 and 55, and R_3(k,k) is believed to grow like a double exponential 2^{c*k^2}. Conjecture: R_3(k,k) ~ 2^{2^{ck}} for some constant c > 0. This is a tower function (height 2 exponential). More precisely: the lower bound R_3(k,k) >= 2^{ck^2} (from the probabilistic method) and the upper bound R_3(k,k) <= 2^{2^{ck}} (from the stepping-up lemma). The gap is between a single exponential and a double exponential. Conjecture: the true growth rate is double exponential, and the upper bound is tight. This would mean that 3-uniform Ramsey numbers grow much faster than graph Ramsey numbers. Test: compute R_3(k,k) for k = 3, 4, 5, 6 by exhaustive search and verify the growth rate. Impact: 3-uniform Ramsey numbers are double exponential. Combinatorics at the hypergraph level is fundamentally harder than at the graph level.

            ### Mathematical Framing
            Ramsey's theorem for graphs states that R(k,l) = the minimum n such that any 2-coloring of the edges of K_n contains a red K_k or a blue K_l. For hypergraphs: R_r(k,l) = the minimum n such that any 2-coloring of the r-tuples of an n-set contains a red K_k^{(r)} or a blue K_l^{(r)}. The growth rate is an open problem: R_3(4,4) = 13 (known), R_3(5,5) is between 34 and 55, and R_3(k,k) is believed to grow like a double exponential 2^{c*k^2}. Conjecture: R_3(k,k) ~ 2^{2^{ck}} for some constant c > 0. This is a tower function (height 2 exponential). More precisely: the lower bound R_3(k,k) >= 2^{ck^2} (from the probabilistic method) and the upper bound R_3(k,k) <= 2^{2^{ck}} (from the stepping-up lemma). The gap is between a single exponential and a double exponential. Conjecture: the true growth rate is double exponential, and the upper bound is tight. This would mean that 3-uniform Ramsey numbers grow much faster than graph Ramsey numbers. Test: compute R_3(k,k) for k = 3, 4, 5, 6 by exha


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `exponential_search_lower_bound` : theorem exponential_search_lower_bound (b d : ℕ) (_hb : 1 ≤ b) :
     (file: Bridges/NeuralProofMining.lean)
  2. `exponential_search_lower_bound` : theorem exponential_search_lower_bound (b d : ℕ) (_hb : 1 ≤ b) :
     (file: FINAL/Bridges/NeuralProofMining.lean)
  3. `height_regularization_lower_bound` : theorem height_regularization_lower_bound
     (file: Bridges/ArithmeticLearningTheory/Core.lean)
  4. `subcritical_ratio_from_upper_bound` : theorem subcritical_ratio_from_upper_bound (hn : 2 ≤ n)
     (file: Bridges/Catalog/Pythagorean/CayleyExpander/PhaseTransition.lean)
  5. `effective_gap_lower_bound` : theorem effective_gap_lower_bound
     (file: Bridges/Catalog/Pythagorean/ContinuousDiscreteTransfer.lean)
  6. `gap_bound_implies_lipschitz_from_localMax` : theorem gap_bound_implies_lipschitz_from_localMax
     (file: Bridges/Catalog/Pythagorean/ExchangeCertifiedApprox.lean)
  7. `abstract_spectral_gap_lower_bound` : theorem abstract_spectral_gap_lower_bound
     (file: Bridges/Catalog/Pythagorean/GL2SpectralDecomposition.lean)
  8. `tower_lower_bound` : theorem tower_lower_bound (d m k : ℕ) (hd : 1 ≤ d) (hk : k ≤ m)
     (file: Bridges/Catalog/Pythagorean/HigherOrderShadowTower.lean)
  9. `cert_lower_bound_from_objects` : theorem cert_lower_bound_from_objects (n : ℕ) (hn : 1 ≤ n)
     (file: Bridges/Catalog/Pythagorean/MatroidCertificatePhaseTransition.lean)
  10. `depth_lower_bound_from_obstruction` : theorem depth_lower_bound_from_obstruction
     (file: Bridges/HomologicalDeepLearning.lean)
  11. `leaf_count_exponential_lower_bound` : theorem leaf_count_exponential_lower_bound (m : ℕ) :
     (file: Bridges/LorentzianHardness.lean)
  12. `sp4_toral_gap_lower_bound` : theorem sp4_toral_gap_lower_bound
     (file: Bridges/Pythagorean/Sp4HeckeComparison.lean)
  13. `grover_search_lower_bound` : theorem grover_search_lower_bound (k : ℕ) :
     (file: Bridges/TropicalCryptographyBreakthrough.lean)
  14. `sample_lower_bound_from_shattering` : theorem sample_lower_bound_from_shattering {α : Type*}
     (file: Bridges/VCCompactness.lean)
  15. `effective_gap_lower_bound` : theorem effective_gap_lower_bound
     (file: FINAL/Bridges/ContinuousDiscreteTransfer.lean)

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

Research domain: Bridges
Research mode: prove
