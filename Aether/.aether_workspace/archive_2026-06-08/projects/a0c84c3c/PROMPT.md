            ## Assignment: The Aperiodic Monotile: One Shape to Tile Them All

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

2. **DEFINE a novel mathematical structure** (CORE REQUIREMENT): Your cycle
   must introduce at least one NEW mathematical object — a structure, a
   construction, a notion, a category, an operator — that does not already
   exist in the Catalog or in standard references. This is the seed of new
   mathematics. The definition must be substantial (not a one-liner renaming
   of a known concept) and must come with at least 3 theorems that PROVE
   non-obvious properties of the new structure.

   Think like Grothendieck defining schemes, or Rota defining matroids, or
   Voiculescu defining free probability. The structure is the contribution.
   The theorems are the evidence that the structure is useful.

   **Critical constraint**: A "novel mathematical structure" must be a
   genuine mathematical object — a formal construction with a precise
   definition, ideally with operations or axioms. **Mathematics of X** where
   X is a real-world phenomenon (memes, dreams, consciousness, art, music,
   jokes, social networks) is NOT a mathematical structure unless you
   formalize X as a precise mathematical object first and then prove
   theorems about THAT object. If you can't formalize X rigorously, pick a
   different X — choose a topic where the math comes naturally.

3. **PEGB for every major theorem** (Proof + Example + Generalization + Boundary):
   For each of your top 3-5 theorems, you MUST produce all four:
   - **P**roof: A complete, non-trivial Lean 4 proof
   - **E**xample: A concrete worked example (specific instance, computed values,
     or a small case that illustrates the theorem)
   - **G**eneralization: A one-level-up generalization (the same theorem in a
     broader or more abstract setting — what is the natural next step?)
   - **B**oundary: A counterexample or limit-case analysis (where does the
     theorem BREAK DOWN? What are the necessary conditions?)

   A theorem without PEGB is a one-off. A theorem WITH PEGB is a research
   program. We are building research programs, not collecting isolated facts.

   **Worked example of a PEGB-compliant theorem:**

   Suppose you define a "graph of divisibility": for integers n, vertices
   are positive integers, edges connect m, n iff m | n and n/m is prime.
   - **P** (Proof): "theorem graph_connected_iff : is_connected (divisibility_graph n) ↔ n > 1"
     — connect this to existing graph theory and prove it by induction on n
   - **E** (Example): "#eval (divisibility_graph 12)" produces {1,2,3,4,6,12} with edges
     showing exactly which prime-divisor chains exist; "example small_case : (divisibility_graph 6).adj 1 = [2, 3]"
   - **G** (Generalization): "theorem generalizes_to_lattice : (divisibility_graph n) is a sublattice of the divisibility lattice" — show the same structure in the broader lattice-theoretic setting
   - **B** (Boundary): "theorem fails_at_zero : ¬ is_connected (divisibility_graph 0)" and
     "theorem fails_at_one : ¬ is_connected (divisibility_graph 1)" — the theorem REQUIRES n > 1; explain why
     the structure breaks at 0 and 1

   This is a real research contribution: a new structure (divisibility_graph),
   a connect theorem to graph theory (P+E), a generalization to lattice theory
   (G), and a boundary analysis showing where the structure fails (B).

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

5. **Cross-connection**: At least one theorem should genuinely connect to
   or build upon an existing catalog result. Generic new math that doesn't
   talk to anything is not a breakthrough — it's a hobby. The new structure
   should illuminate something that already exists.


            ### Research Direction
            In 2023, Smith et al. discovered 'the hat' — a single tile shape that tiles the plane but only aperiodically (no periodic tiling exists). This solved the aperiodic monotile problem. But deeper questions remain: How many distinct aperiodic monotiles exist? Conjecture: The set of aperiodic monotiles forms a 1-parameter family (the 'hat spectrum') parameterized by a continuous parameter t in [0,1] where t=0 gives the hat, t=1 gives the turtle (a known variant), and intermediate values give intermediate shapes. The key property: each shape in the hat spectrum tiles the plane aperiodically, and no two shapes in the spectrum admit a common periodic tiling. The boundary of the hat spectrum is the curve in R^2 that separates the region of aperiodic monotiles from the region of periodic tiles. This boundary is a piecewise-smooth curve determined by the constraint that the tile must enforce a hierarchical substitution rule. Test: parameterize the hat spectrum by interpolating between the hat and turtle, compute the substitution rule for each t, and verify that the substitution rule enforces aperiodicity for all t in [0,1]. Impact: aperiodic monotiles are not isolated curiosities — they form a continuous family, and the hat is just one point on the spectrum.

            ### Mathematical Framing
            In 2023, Smith et al. discovered 'the hat' — a single tile shape that tiles the plane but only aperiodically (no periodic tiling exists). This solved the aperiodic monotile problem. But deeper questions remain: How many distinct aperiodic monotiles exist? Conjecture: The set of aperiodic monotiles forms a 1-parameter family (the 'hat spectrum') parameterized by a continuous parameter t in [0,1] where t=0 gives the hat, t=1 gives the turtle (a known variant), and intermediate values give intermediate shapes. The key property: each shape in the hat spectrum tiles the plane aperiodically, and no two shapes in the spectrum admit a common periodic tiling. The boundary of the hat spectrum is the curve in R^2 that separates the region of aperiodic monotiles from the region of periodic tiles. This boundary is a piecewise-smooth curve determined by the constraint that the tile must enforce a hierarchical substitution rule. Test: parameterize the hat spectrum by interpolating between the hat and

### Lean 4 Sketch
Define the hat spectrum: for t in [0,1], the tile H_t is the convex hull of the 14 vertices of the hat tile with one edge parameterized by t. At t=0, H_0 is the hat. At t=1, H_1 is the turtle. For intermediate t, H_t is the interpolated shape. The substitution rule for H_t is a function of t: the tile H_t admits a substitution rule with expansion factor lambda(t) where lambda(0) = sqrt(3) + 2 (the hat expansion factor) and lambda(1) = sqrt(3) + 2 (the turtle expansion factor, same as the hat). A


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `exists_prime_between_sq_and_two_mul_sq` : theorem exists_prime_between_sq_and_two_mul_sq
     (file: FINAL/MachineLearning/LegendreGapReduction.lean)
  2. `exists_prime_between_sq_and_two_mul_sq` : theorem exists_prime_between_sq_and_two_mul_sq
     (file: MachineLearning/LegendreGapReduction.lean)
  3. `exists_not_mem_discovered_of_lt_criticalPath` : theorem exists_not_mem_discovered_of_lt_criticalPath (G : DepGraph V) [Nonempty V]
     (file: FINAL/MachineLearning/ConceptualDependencyCriticalPath.lean)
  4. `exists_not_mem_discovered_of_lt_criticalPath` : theorem exists_not_mem_discovered_of_lt_criticalPath (G : DepGraph V) [Nonempty V]
     (file: MachineLearning/ConceptualDependencyCriticalPath.lean)
  5. `prime_triple_odd_not_all_two` : theorem prime_triple_odd_not_all_two
     (file: FINAL/MachineLearning/Advanced.lean)
  6. `prime_triple_odd_not_all_two` : theorem prime_triple_odd_not_all_two
     (file: MachineLearning/Goldbach/Advanced.lean)
  7. `frankl_set_family_iff_lattice_form` : theorem frankl_set_family_iff_lattice_form
     (file: MachineLearning/Frankl/Duality.lean)
  8. `boundary_pair_gives_witness` : theorem boundary_pair_gives_witness {n t : ℕ} (ht : 1 ≤ t) (_htn : t ≤ n)
     (file: FINAL/MachineLearning/SymmetricWitness.lean)
  9. `boundary_pair_gives_witness` : theorem boundary_pair_gives_witness {n t : ℕ} (ht : 1 ≤ t) (_htn : t ≤ n)
     (file: MachineLearning/MetaComplexity/Theorems.lean)
  10. `single_layer_region_bound` : theorem single_layer_region_bound (w : ℕ) (net : SingleLayerNet w) :
     (file: MachineLearning/NeuralDecisionBoundary/Core.lean)
  11. `boundary_pair_gives_witness` : theorem boundary_pair_gives_witness {n t : ℕ} (ht : 1 ≤ t) (_htn : t ≤ n)
     (file: MachineLearning/SymmetricWitness.lean)
  12. `exists_uncompressible_family_of_not_all_compressible` : theorem exists_uncompressible_family_of_not_all_compressible
     (file: EML/DiagonalPhaseTransition.lean)
  13. `exists_uncompressible_family_of_not_all_compressible` : theorem exists_uncompressible_family_of_not_all_compressible
     (file: FINAL/EML/DiagonalPhaseTransition.lean)
  14. `frontier_all_known_iff` : theorem frontier_all_known_iff (S : DepSystem T) (frontier : Finset T) (n : ℕ) :
     (file: FINAL/MachineLearning/CurriculumTheory.lean)
  15. `popcount_two_pow_sub_one` : theorem popcount_two_pow_sub_one (k : ℕ) : popcount (2 ^ k - 1) = k := by
     (file: FINAL/MachineLearning/FiniteStateTranscendence.lean)
  16. `gcd_Xpow_sub_one_eventually_periodic` : theorem gcd_Xpow_sub_one_eventually_periodic
     (file: FINAL/MachineLearning/GCDPeriodicity.lean)
  17. `not_irrationality_certificate_of_O_one_over_q` : theorem not_irrationality_certificate_of_O_one_over_q
     (file: FINAL/MachineLearning/IrrationalityCriteria.lean)
  18. `integral_point_gives_modn_point` : theorem integral_point_gives_modn_point {k : ℤ} {n : ℕ} (_hn : 0 < n)
     (file: FINAL/MachineLearning/LocalGlobalGeometry.lean)
  19. `two_not_norm` : theorem two_not_norm : ¬ ∃ z : M, z.norm = 2 := by
     (file: FINAL/MachineLearning/MobiusRing.lean)
  20. `common_fixed_point_trivial` : theorem common_fixed_point_trivial :
     (file: FINAL/MachineLearning/ObstructionFramework.lean)
  21. `exists_between_in_Ioo` : theorem exists_between_in_Ioo [LinearOrder α] [DenselyOrdered α] {a b : α}
     (file: FINAL/MachineLearning/OrderGap.lean)
  22. `tropical_ctc_fixed_point_exists` : theorem tropical_ctc_fixed_point_exists
     (file: FINAL/MachineLearning/TropicalCTC.lean)
  23. `one_vs_all_robust_of_margin` : theorem one_vs_all_robust_of_margin
     (file: FINAL/MachineLearning/TropicalDAGRobustness.lean)
  24. `periodic_point_card_le` : theorem periodic_point_card_le {α : Type*} [Fintype α] [DecidableEq α]
     (file: MachineLearning/AdelicSync/Core.lean)
  25. `frontier_all_known_iff` : theorem frontier_all_known_iff (S : DepSystem T) (frontier : Finset T) (n : ℕ) :
     (file: MachineLearning/CurriculumTheory.lean)

⚠️ **Domain Focus**: This domain has historically produced lower-quality results. Prioritize DEEP, GENUINELY NOVEL theorems over breadth. Avoid trivial wrappers, definition-only results, or repackaging known facts. Every theorem must represent real mathematical progress.


### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## Aether Research Journal

### Recent Activity
- Q=0.39 [Applications] Topological Quantum Compiling: Braid Groups as Uni
- Q=0.48 [Applications] The Anti-Fibonacci Sequence: Numbers That Avoid th
- Q=0.32 [Applications] Sperner's Lemma Implies Nash Equilibria: Combinato
- Q=0.30 [Applications] The Fermi Paradox as a Pigeonhole Principle: Why W
- Q=0.32 [Applications] EML Neural Network Expressiveness: Depth vs Width

### Active Research Threads
- [MachineLearning] PAC-Bayes Bounds: Information-Theoretic Generaliza Q=0.58
- [Applications] Topological Quantum Compiling: Braid Groups as Uni Q=0.39
- [Bridges] Gravity from Information: Spacetime as a Quantum E Q=0.47
- [Computation] Rigorous, fully formalized mathematical framew Q=0.49
- [Cryptography] Tropical Cryptography: Min-Plus Diffie-Hellman Q=0.70
- [EML] Surreal Topology: What Topology Does the Field of  Q=0.67
- [Geometry] Fundamental algebraic-topological bridge: **th Q=0.50
- [Logic] The Collatz Conjecture Is Undecidable: What If 3n+ Q=0.34
- [Physics] Proofs as DAGs: The Directed Acyclic Graph Structu Q=0.31
- [Pythagorean] Speculative: Tropical Mathematics of Social Choice Q=0.37
- [Shared] Cellular Automata as Algebraic Geometry: Wolfram's Q=0.43
- [Tropical] Tropical Optimization: Linear Programming in the M Q=0.40


            ## Known Barriers & Impossibility Results

The following theorems from Aether's Catalog constrain what proof approaches are possible. Consider these as strong warnings — they do not make the task impossible, but any approach must account for them.

- **trefoil_irreducible** (MachineLearning): Contains 'irreducible' — theorem trefoil_irreducible : Irreducible alexanderT23 := by
- **tropicalCausalStrength_self_le** (MachineLearning): Contains 'no finite' — /-- Infinite strength means no finite-cost path exists in the Kleene window. -/
- **certification_soundness** (MachineLearning): Contains 'barrier' — Impact: lob_generalization_criterion, certified_robustness_barrier -/
- **unprovable_true_generalization** (MachineLearning): Contains 'incompleteness' — Impact: lob_generalization_criterion, godel_incompleteness_network -/
- **unprovable_true_generalization** (MachineLearning): Contains 'unprovable' — theorem unprovable_true_generalization {V : Type*} [ProofSystem V]
- **barriers_from_diagonalization** (MachineLearning): Contains 'barrier' — /-- In a sound system, barriers exist from diagonalization.
- **barriers_from_diagonalization** (MachineLearning): Contains 'incompleteness' — Impact: godel_incompleteness_network -/
- **landauer_proof_erasure_cost** (MachineLearning): Contains 'barrier' — Impact: entropy, certified_robustness_barrier -/
            ## Recommended Proof Strategies

The following proof techniques have been effective in this domain. Consider using them if applicable:

- **fixed point**: 
- **induction**: 
- **diagonal**: 
- **completeness**: 

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

Research domain: MachineLearning
Research mode: team
