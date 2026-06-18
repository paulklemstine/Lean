            ## Assignment: Gravity as Quantum Error Correction: Spacetime from Codes

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
            The key insight is that the holographic principle in physics (AdS/CFT) can be rederived from quantum error correction. If the boundary CFT is a quantum error-correcting code with parameters [[n, k, d]], then the bulk AdS geometry emerges from the code's encoding. Conjecture: The Ryu-Takayanagi formula S(A) = Area(gamma_A) / (4G) is equivalent to the quantum Singleton bound d <= n - k + 1 applied to the boundary code, where the code distance d equals the minimal geodesic length through the bulk. Why now: recent work by Pastawski, Preskill, and Harrow (2015) showed that the AdS/CFT correspondence can be modeled by tensor networks (HaPPY code), but the converse — deriving AdS geometry FROM the code — has not been proven. Test: for the [[5,1,3]] code (the smallest perfect code), show that the code's Tanner graph IS the Penrose diagram of AdS_2, and the code distance 3 equals the geodesic length through the bulk. Impact: spacetime IS a quantum error-correcting code. Gravity is not a force — it's the logical operator of a quantum code.

            ### Mathematical Framing
            The key insight is that the holographic principle in physics (AdS/CFT) can be rederived from quantum error correction. If the boundary CFT is a quantum error-correcting code with parameters [[n, k, d]], then the bulk AdS geometry emerges from the code's encoding. Conjecture: The Ryu-Takayanagi formula S(A) = Area(gamma_A) / (4G) is equivalent to the quantum Singleton bound d <= n - k + 1 applied to the boundary code, where the code distance d equals the minimal geodesic length through the bulk. Why now: recent work by Pastawski, Preskill, and Harrow (2015) showed that the AdS/CFT correspondence can be modeled by tensor networks (HaPPY code), but the converse — deriving AdS geometry FROM the code — has not been proven. Test: for the [[5,1,3]] code (the smallest perfect code), show that the code's Tanner graph IS the Penrose diagram of AdS_2, and the code distance 3 equals the geodesic length through the bulk. Impact: spacetime IS a quantum error-correcting code. Gravity is not a force —


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `quantum_code_distance_from_obstruction` : theorem quantum_code_distance_from_obstruction
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `monotone_KW_lower_bound_implies_formula_depth_lower_bound` : theorem monotone_KW_lower_bound_implies_formula_depth_lower_bound
     (file: Computation/ApproximationMethod.lean)
  3. `grav_penrose_bound` : theorem grav_penrose_bound (M_irr M : ℝ) (_h : M_irr ≤ M) (hp : 0 < M_irr) :
     (file: Computation/GravityOracle.lean)
  4. `KW_lower_bound_implies_formula_depth_lower_bound` : theorem KW_lower_bound_implies_formula_depth_lower_bound [NeZero n]
     (file: Computation/KarchmerWigderson.lean)
  5. `valueIteration_error_bound` : theorem valueIteration_error_bound (M : MDP) (V_star : ValueFn M)
     (file: Computation/OptimalPlanning.lean)
  6. `quantum_code_distance_from_obstruction` : theorem quantum_code_distance_from_obstruction
     (file: FINAL/Bridges/HomologicalDeepLearning.lean)
  7. `monotone_KW_lower_bound_implies_formula_depth_lower_bound` : theorem monotone_KW_lower_bound_implies_formula_depth_lower_bound
     (file: FINAL/Computation/ApproximationMethod.lean)
  8. `grav_penrose_bound` : theorem grav_penrose_bound (M_irr M : ℝ) (_h : M_irr ≤ M) (hp : 0 < M_irr) :
     (file: FINAL/Computation/GravityOracle.lean)
  9. `KW_lower_bound_implies_formula_depth_lower_bound` : theorem KW_lower_bound_implies_formula_depth_lower_bound [NeZero n]
     (file: FINAL/Computation/KarchmerWigderson.lean)
  10. `valueIteration_error_bound` : theorem valueIteration_error_bound (M : MDP) (V_star : ValueFn M)
     (file: FINAL/Computation/OptimalPlanning.lean)
  11. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: Computation/OracleApplicationsFrontier.lean)
  12. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: FINAL/Computation/OracleApplicationsFrontier.lean)
  13. `family_path_length_bound` : theorem family_path_length_bound
     (file: Computation/Theorems.lean)
  14. `family_path_length_bound` : theorem family_path_length_bound
     (file: FINAL/Computation/Theorems.lean)
  15. `boundary_determines_minimal_bulk` : theorem boundary_determines_minimal_bulk
     (file: Bridges/UltrametricHolographicRenormalization.lean)

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

Research domain: Computation
Research mode: prove
