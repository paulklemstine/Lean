            ## Assignment: The Mathematics of Jigsaw Puzzles: NP-Completeness and Topology

            Lead a research team to maximize scientific output per cycle. ORGANIZE as: (1) Hypothesis Team — brainstorm 5-7 bold, falsifiable conjectures (at least 2 should be surprising or counterintuitive); (2) Experiment Team — prove or disprove each hypothesis in Lean 4, prioritizing the most surprising ones; (3) Analysis Team — examine what survived, what failed, and WHY failures failed — failures teach as much as successes; (4) Writing Team — produce all deliverables (article, paper, demos, HTML widgets) from the team's findings. SCIENCE IS A LOOP: explore → identify patterns → hypothesize → validate → upgrade knowledge → repeat. Each subagent contributes its expertise; the Writing Team synthesizes everything into polished output. More minds = more compute = deeper results. The goal is not to formalize known results — it's to discover new ones.

            ## Research Cycle: Explore → Pattern → Hypothesize → Validate → Upgrade → Repeat

            You are part of an autonomous research system that runs continuously.
            Each cycle's output feeds the next cycle's input in a positive feedback loop.
            Your FUTURE_DIRECTIONS.md determines what the next cycle investigates.
            The quality of your directions determines the quality of future research.

            AMBITION STANDARD: You are not doing textbook exercises. You are extending
            the frontier of mathematical knowledge. Every theorem should be the kind of
            result that would make a mathematician say "I didn't know that." Connect
            unexpected areas. Prove things that seem surprising. Generalize beyond the
            obvious. If a result could appear in an undergraduate homework assignment, it
            is not ambitious enough.

            Follow this cycle model:
            1. **Explore** — Survey what exists, find gaps, identify anomalies and
               connections nobody has made yet.
            2. **Pattern** — Detect structures, hidden symmetries, and deep regularities.
            3. **Hypothesize** — Propose falsifiable conjectures bold enough to matter
               and specific enough to fail. "Study X further" is not a hypothesis.
               A good hypothesis would make a researcher say "that would be surprising
               if true, and informative if false."
            4. **Validate** — Prove or disprove. Failures teach as much as successes.
               A disproof can be as groundbreaking as a proof.
            5. **Upgrade** — Integrate what you learned into the knowledge base.
            6. **Repeat** — Your FUTURE_DIRECTIONS.md prescribes the next cycle's
               best, most fruitful research directions.

            The Aristotle prompt drives the research directions, which drive results,
            which drive the next Aristotle prompt — a positive, self-aware, intelligent
            feedback loop. Make each cycle count. Make each theorem matter.

            ## Depth Requirements (MANDATORY — WORLD-CLASS STANDARD)

Your output must satisfy ALL of these. This is not incremental work.
This is the frontier. Act accordingly.

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **DEEPEN an existing catalog result** (CORE REQUIREMENT): Your cycle
   must take a STRONG, WELL-ESTABLISHED theorem from the Catalog and
   EXTEND it. Choose ONE of the following:
   (a) **Generalize** the result to a more abstract or broader setting
       (e.g., real numbers → complex, finite groups → topological groups).
   (b) **Strengthen** the conclusion: drop assumptions, sharpen bounds,
       prove a stronger equality where the original was an inequality.
   (c) **Bridge** to another domain: take a result from domain A and
       prove the analog in domain B, showing the deep connection.

   You must produce at least 3 theorems that PROVE non-obvious properties
   of the generalized/strengthened/bridged result. The contribution is
   the structural insight that extends what is already known.

   Think like Cauchy generalizing Euler, or Noether extending Hilbert, or
   Grothendieck's student extending Grothendieck. The contribution is taking
   a known theorem and showing it's the shadow of a deeper truth.

3. **PEGB for every major theorem** (Proof + Example + Generalization + Boundary):
   For each of your top 3-5 theorems, you MUST produce all four:
   - **P**roof: A complete, non-trivial Lean 4 proof
   - **E**xample: A concrete worked example showing the extension
   - **G**eneralization: Why this extension is natural (what's the next level up?)
   - **B**oundary: Where does the extension break down?

4. **Cite your sources**: Your ARTICLE.md and RESEARCH_PAPER.md MUST
   reference the specific catalog results you built upon. Use the
   references provided in the prompt below.

5. **Cross-connection**: At least one theorem should build a BRIDGE
   between the original catalog result and a different mathematical area.
   The deepening should illuminate something broader, not just be an
   isolated exercise.


            ### Research Direction
            A jigsaw puzzle has N pieces, each with 4 edges. The 'signature' of a piece is the tuple (top, right, bottom, left) of edge types (flat, tab, blank). Two pieces fit together if their adjacent edges are complementary (tab meets blank). Conjecture: Solving a jigsaw puzzle is NP-complete. The reduction: given a 3-SAT formula with n variables and m clauses, construct a jigsaw puzzle with N = 2n + m + 2 pieces where the only valid assembly corresponds to a satisfying assignment. Variable pieces: each variable x_i has two pieces (TRUE and FALSE), one with a tab and one with a blank on the assignment edge. Only one can be placed (mutual exclusion via complementary edges). Clause pieces: each clause C_j is a piece that has three input edges (one per literal) and one output edge. The piece fits only if at least one input edge is connected to a TRUE literal piece. The top-left corner and bottom-right corner enforce the boundary. Test: construct the reduction explicitly for a small 3-SAT instance (e.g., (x1 OR x2 OR NOT x3) AND (NOT x1 OR x3)) and verify the puzzle has a solution iff the formula is satisfiable. Impact: jigsaw puzzles are NP-complete, so the satisfying snap you feel when completing a puzzle is literally the same as solving a hard computational problem.

            ### Mathematical Framing
            A jigsaw puzzle has N pieces, each with 4 edges. The 'signature' of a piece is the tuple (top, right, bottom, left) of edge types (flat, tab, blank). Two pieces fit together if their adjacent edges are complementary (tab meets blank). Conjecture: Solving a jigsaw puzzle is NP-complete. The reduction: given a 3-SAT formula with n variables and m clauses, construct a jigsaw puzzle with N = 2n + m + 2 pieces where the only valid assembly corresponds to a satisfying assignment. Variable pieces: each variable x_i has two pieces (TRUE and FALSE), one with a tab and one with a blank on the assignment edge. Only one can be placed (mutual exclusion via complementary edges). Clause pieces: each clause C_j is a piece that has three input edges (one per literal) and one output edge. The piece fits only if at least one input edge is connected to a TRUE literal piece. The top-left corner and bottom-right corner enforce the boundary. Test: construct the reduction explicitly for a small 3-SAT instance

### Lean 4 Sketch
Define jigsaw puzzle instance: N pieces, each with 4 edges from alphabet {tab, blank, flat}. Two pieces P and Q fit together on edge e if P.e and Q.e are complementary (tab meets blank). Assembly: a placement of all N pieces in a rectangular grid such that all adjacent edges are complementary. Reduction from 3-SAT: given phi = (l_11 OR l_12 OR l_13) AND ... AND (l_m1 OR l_m2 OR l_m3), construct puzzle with 2n + m + 2 pieces. For variable x_i: create piece V_i^T (TRUE, with tab on the assignment 


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `clause_sat_iff_tab` : theorem clause_sat_iff_tab (vals : Fin 3 → Bool) :
     (file: EML/JigsawAlgebra.lean)
  2. `clause_sat_iff_tab` : theorem clause_sat_iff_tab (vals : Fin 3 → Bool) :
     (file: FINAL/EML/JigsawAlgebra.lean)
  3. `clause_sat_iff_tab_exists` : theorem clause_sat_iff_tab_exists (vals : Fin 3 → Bool) :
     (file: FINAL/Pythagorean/JigsawNPComplete.lean)
  4. `conjecture_iff_all_bounded` : theorem conjecture_iff_all_bounded :
     (file: Novelty/CollatzUndecidability.lean)
  5. `clause_sat_iff_tab_exists` : theorem clause_sat_iff_tab_exists (vals : Fin 3 → Bool) :
     (file: Pythagorean/JigsawNPComplete.lean)
  6. `one_by_two_valid_iff` : theorem one_by_two_valid_iff (p q : JigsawPiece) :
     (file: Bridges/JigsawNPComplete.lean)
  7. `reciprocal_sum_eq_one_iff_three_three_three` : theorem reciprocal_sum_eq_one_iff_three_three_three
     (file: Algebra/ExponentBounds.lean)
  8. `sidon_iff_one_flat` : theorem sidon_iff_one_flat (S : Finset ℤ) :
     (file: Algebra/MontgomeryPairCorrelation.lean)
  9. `isTree_iff_connected_and_edgecount` : theorem isTree_iff_connected_and_edgecount [Nonempty V]
     (file: Bridges/LocalCyclePressure.lean)
  10. `two_block_leaf_has_one_positive_eigenvalue` : theorem two_block_leaf_has_one_positive_eigenvalue (n₁ n₂ : ℕ) :
     (file: Bridges/PartitionMatroidStability.lean)
  11. `unique_top2Set_iff_exists_unique_bottom` : theorem unique_top2Set_iff_exists_unique_bottom (x : Fin 3 → ℝ) :
     (file: Bridges/TropicalSatakeTop2Margin.lean)
  12. `two_block_leaf_has_one_positive_eigenvalue` : theorem two_block_leaf_has_one_positive_eigenvalue (n₁ n₂ : ℕ) :
     (file: Catalog/Bridges/Pythagorean/PartitionMatroidStability.lean)
  13. `reciprocal_sum_eq_one_iff_three_three_three` : theorem reciprocal_sum_eq_one_iff_three_three_three
     (file: FINAL/Algebra/ExponentBounds.lean)
  14. `sidon_iff_one_flat` : theorem sidon_iff_one_flat (S : Finset ℤ) :
     (file: FINAL/Algebra/MontgomeryPairCorrelation.lean)
  15. `isTree_iff_connected_and_edgecount` : theorem isTree_iff_connected_and_edgecount [Nonempty V]
     (file: FINAL/Bridges/LocalCyclePressure.lean)
  16. `unique_top2Set_iff_exists_unique_bottom` : theorem unique_top2Set_iff_exists_unique_bottom (x : Fin 3 → ℝ) :
     (file: FINAL/Bridges/TropicalSatakeTop2Margin.lean)
  17. `true_not_false` : theorem true_not_false : isFalse T = false := rfl
     (file: FINAL/Logic/ParaconsistentParadox.lean)
  18. `not_connected_has_nontrivial_clopen` : theorem not_connected_has_nontrivial_clopen [LinearOrder α] [TopologicalSpace α]
     (file: FINAL/MachineLearning/OrderGap.lean)
  19. `two_dvd_three_pow_sub_one` : theorem two_dvd_three_pow_sub_one (n : ℕ) : 2 ∣ (3 ^ (n + 1) - 1) := by
     (file: FINAL/Pythagorean/BerggrenHolographicDuality.lean)
  20. `not_isAcyclic_of_connected_many_edges` : theorem not_isAcyclic_of_connected_many_edges
     (file: FINAL/Pythagorean/HardnessLocalization.lean)
  21. `original_conjecture_false_for_d_ge_2` : theorem original_conjecture_false_for_d_ge_2 (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 2 ≤ d)
     (file: FINAL/Pythagorean/TorusSpectralAnatomy.lean)
  22. `prime_one_mod_four_has_sum_two_squares` : theorem prime_one_mod_four_has_sum_two_squares
     (file: FINAL/Pythagorean/TropicalBerggrenZeta.lean)
  23. `tropical_formula_iff_recognizable_and_deriv_closed` : theorem tropical_formula_iff_recognizable_and_deriv_closed [DecidableEq σ] [Fintype σ]
     (file: FINAL/Tropical/FormulaDefinability.lean)
  24. `tropicalMorseIndex_eq_one_two_piece` : theorem tropicalMorseIndex_eq_one_two_piece {n : ℕ}
     (file: FINAL/Tropical/TropicalMorseTheory.lean)
  25. `true_not_false` : theorem true_not_false : isFalse T = false := rfl
     (file: Logic/ParaconsistentParadox.lean)

⚠️ **Domain Focus**: This domain has historically produced lower-quality results. Prioritize DEEP, GENUINELY NOVEL theorems over breadth. Avoid trivial wrappers, definition-only results, or repackaging known facts. Every theorem must represent real mathematical progress.


### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## Aether Research Journal

### Recent Activity
- Q=0.33 [Pythagorean] Gap Transition System — a finite-state autom
- Q=0.33 [Pythagorean] Infinite Games Against Death: Immortality Strategi
- Q=0.33 [Bridges] Topological-Algebraic Bridge: Fundamental Group as
- Q=0.35 [Physics] Gravity as Quantum Error Correction: Spacetime fro
- Q=0.48 [Logic] Crystallographic Groups and Music: The 17 Wallpape

### Active Research Threads
- [Novelty] Speculative: Mathematics as a Phase Transition Q=0.32
- [Applications] Infinite Games Against Death: Immortality Strategi Q=0.36
- [Bridges] Topological-Algebraic Bridge: Fundamental Group as Q=0.33
- [Computation] Rigorous, fully formalized mathematical framew Q=0.49
- [Cryptography] Tropical Cryptography: Min-Plus Diffie-Hellman Q=0.70
- [EML] Surreal Topology: What Topology Does the Field of  Q=0.67
- [Geometry] Fundamental algebraic-topological bridge: **th Q=0.50
- [Logic] Crystallographic Groups and Music: The 17 Wallpape Q=0.48
- [MachineLearning] PAC-Bayes Bounds: Information-Theoretic Generaliza Q=0.58
- [Physics] Gravity as Quantum Error Correction: Spacetime fro Q=0.35
- [Pythagorean] Gap Transition System — a finite-state autom Q=0.33
- [Shared] Cellular Automata as Algebraic Geometry: Wolfram's Q=0.43
- [Tropical] Tropical Optimization: Linear Programming in the M Q=0.40


            ## Known Barriers & Impossibility Results

The following theorems from Aether's Catalog constrain what proof approaches are possible. Consider these as strong warnings — they do not make the task impossible, but any approach must account for them.

- **odd_two_step_le** (Novelty): Contains 'lower bound' — /-! ## Theorem 11: Stopping time lower bound -/
- **deriv_iterExp_one** (Algebra): Contains 'lower bound' — /-! ## Derivative lower bounds — the analytic signature of depth -/
- **PillaiDiophantine** (Algebra): Contains 'impossible' — For k = 1: `x^2 - y^2 = 1` with `x, y ≥ 2` is impossible.
- **no_sq_diff_one** (Algebra): Contains 'impossible' — For k = 2: `x^2 - y^2 = 2` with `x, y ≥ 2` is impossible.
- **expectedPrimeLikes_interval_lower** (Algebra): Contains 'lower bound' — Lower bound: each weight is at least `1/log(N+H)`, and there are `H+1` terms.
- **minLeafGap_le** (Bridges): Contains 'lower bound' — MinLeafGap is a lower bound on each individual leaf gap.
- **wedge_realizable_iff** (Bridges): Contains 'obstruction' — each independent cycle contributes one dimension to the obstruction space.
- **penrose_polygon_monodromy** (Bridges): Contains 'impossibility' — **Penrose Polygon Impossibility**: Any Penrose k-gon with k ≥ 1 and
            ## Recommended Proof Strategies

The following proof techniques have been effective in this domain. Consider using them if applicable:

- **induction**: 
- **contradiction**: 
- **embedding**: 
- **isomorphism**: 

No specific files referenced. Use Mathlib and general knowledge.

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above (FINAL/ entries are vetted, high-quality — prioritize these).

            Choose types appropriate to the problem — abstract where it clarifies,
            concrete where it grounds. Avoid trivial tautologies.
            If a direct proof fails, explore alternative approaches: contrapositive,
            constructive witnesses, categorical arguments, coinduction, computational
            reflection, or structural induction.

            ### Anti-Triviality Rules
            Do NOT produce any of the following:
            - Commutativity/associativity proofs for standard algebraic structures
              UNLESS the result is surprising in context (e.g., proving commutativity
              in a non-obvious setting like tropical semirings or quantum groups)
            - Wrapper theorems that just unwrap a definition without mathematical insight
            - Proofs that are just `by simp` or `by trivial` with no depth
            - Definitions followed by trivial properties that don't advance understanding

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md, RESEARCH_PAPER.md,
                      ARTICLE.md (Scientific American style), algorithm, demo.py,
                      1–3 interactive HTML widgets in PACKAGE.json interactive_demos (each: name, html, description)
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
  `Bridges/Agent.lean`: euclid_inradius_num, euclid_perimeter, euclid_twice_area
  `Bridges/AlgebraEMLClosureComputation.lean`: ClosureSemimoduleSystem, ProbeFamily, ClosureStableProbe
  `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean`: FilteredClosureSystem, scaleDefect, absorption_yields_monotone_profile
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
  `EML/KolmogorovArnoldEMLDeep.lean`: EMLChainOp.eval, evalChain, chainDepth

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

            Titles MUST be concise research topics (e.g. "Tropical Fermat
            Last Theorem", "Oracle Hierarchy in Computability"), NOT cycle
            summaries (NOT "This research cycle established...").

            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would confirm
            or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what does
            the failure teach us?
            **Catalog References**: `Bridges.Basic.lean`, `Algebra.QuadraticForms.mordell`
            (Use backtick-enclosed file paths or theorem names from the Catalog.)
            **Proof Strategy**: Outline the key steps or approach. What mathematical
            machinery is needed? What lemmas would need to be established first?
            **Domain Bridges**: (identify genuine cross-domain connections from
            this cycle's results, using the <-> connector.)
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

            Pursue truth relentlessly. Soli Deo Gloria.


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

Research domain: Novelty
Research mode: team
