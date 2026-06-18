            ## Assignment: The Library of Babel: Combinatorics of the Universal Library

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
   - **E**xample: A concrete worked example
   - **G**eneralization: A one-level-up generalization
   - **B**oundary: A counterexample or limit-case analysis

   A theorem without PEGB is a one-off. A theorem WITH PEGB is a research
   program. We are building research programs, not collecting isolated facts.

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

5. **Cross-connection**: At least one theorem should genuinely connect to
   or build upon an existing catalog result.


            ### Research Direction
            Borges' Library of Babel contains every possible 410-page book — approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog — a single volume that encodes the location of every other volume — and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces — every possible text exists, but finding meaning requires a guide.

            ### Mathematical Framing
            Borges' Library of Babel contains every possible 410-page book — approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog — a single volume that encodes the location of every other volume — and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact 

### Lean 4 Sketch
Define B = {0,...,24}^{1312000} as the Library. Compute |B| = 25^{1312000}. Define the meaning probability P(T) = sum_{b in B: b contains proof of T} 1/|B|. Prove P(T) >= |T| * 25^{-k(T)} where k(T) is the Kolmogorov complexity of T. Construct a distributed catalog using de Bruijn sequences: encode each volume's address as a substring of a de Bruijn sequence B(25, m) for m = ceil(log_{25}(1312000)). Prove the catalog requires N >= 25^{1312000} / (1312000 * log_{25}(2)) volumes. Test: implement t


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `exists_modulus_injective_on_finite_int_matrix_set` : theorem exists_modulus_injective_on_finite_int_matrix_set
     (file: Cryptography/BerggrenBallRigidity.lean)
  2. `encode_single_component_complexity` : theorem encode_single_component_complexity {n : ℕ} (i : Fin n) (a : ℤ) :
     (file: Cryptography/CutCryptography.lean)
  3. `single_volume_addresses_library` : theorem single_volume_addresses_library (A L : ℕ) :
     (file: Cryptography/LibraryOfBabel.lean)
  4. `exists_modulus_injective_on_finite_int_matrix_set` : theorem exists_modulus_injective_on_finite_int_matrix_set
     (file: FINAL/Cryptography/BerggrenBallRigidity.lean)
  5. `encode_single_component_complexity` : theorem encode_single_component_complexity {n : ℕ} (i : Fin n) (a : ℤ) :
     (file: FINAL/Cryptography/CutCryptography.lean)
  6. `single_volume_addresses_library` : theorem single_volume_addresses_library (A L : ℕ) :
     (file: FINAL/Cryptography/LibraryOfBabel.lean)
  7. `finite_test_suite_exists` : theorem finite_test_suite_exists
     (file: Speculative/AutoResearch/ResidualFiniteness.lean)
  8. `exists_nonzero_poly_vanishing_on_finite_set_of_card_lt` : theorem exists_nonzero_poly_vanishing_on_finite_set_of_card_lt
     (file: Algebra/EvalKernel.lean)
  9. `exists_nonzero_poly_vanishing_on_finite_set_of_card_lt` : theorem exists_nonzero_poly_vanishing_on_finite_set_of_card_lt
     (file: FINAL/Algebra/EvalKernel.lean)
  10. `exists_ultrametric_radius_witness_for_every_measurement` : theorem exists_ultrametric_radius_witness_for_every_measurement
     (file: Bridges/TropicalUltrametricQuantumUncertainty.lean)
  11. `exists_ultrametric_radius_witness_for_every_measurement` : theorem exists_ultrametric_radius_witness_for_every_measurement
     (file: FINAL/Bridges/TropicalUltrametricQuantumUncertainty.lean)
  12. `tropical_proof_length_conjecture_special_case` : theorem tropical_proof_length_conjecture_special_case
     (file: FINAL/Physics/TropicalProofComplexity.lean)
  13. `tropical_proof_length_conjecture_special_case` : theorem tropical_proof_length_conjecture_special_case
     (file: Physics/TropicalProofComplexity.lean)
  14. `conjecture_iff_all_bounded` : theorem conjecture_iff_all_bounded :
     (file: Algebra/CollatzUndecidable.lean)
  15. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: Bridges/HolographicProofRenormalization.lean)
  16. `lawvere_proof_coding_theorem` : theorem lawvere_proof_coding_theorem
     (file: Bridges/LawvereCodingTheorem.lean)
  17. `tropical_profile_complete_for_bounded_architecture_congruence` : theorem tropical_profile_complete_for_bounded_architecture_congruence
     (file: Bridges/OperadicTropicalization.lean)
  18. `conjecture_test_bound` : theorem conjecture_test_bound :
     (file: Bridges/PrimewisePersistenceBarrier.lean)
  19. `finite_duality_theorem` : theorem finite_duality_theorem
     (file: Bridges/UltrametricProofAutomatonDuality.lean)
  20. `proof_length_lower_bound` : theorem proof_length_lower_bound (G : DerivationGraph V) (S : Finset V) (t : V) (k : ℕ)
     (file: Computation/SpectralRenormalization.lean)
  21. `conjecture_test_bound` : theorem conjecture_test_bound :
     (file: Cryptography/PrimewisePersistenceBarrier.lean)
  22. `conjecture_iff_all_bounded` : theorem conjecture_iff_all_bounded :
     (file: FINAL/Algebra/CollatzUndecidable.lean)
  23. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: FINAL/Bridges/HolographicProofRenormalization.lean)
  24. `lawvere_proof_coding_theorem` : theorem lawvere_proof_coding_theorem
     (file: FINAL/Bridges/LawvereCodingTheorem.lean)
  25. `tropical_profile_complete_for_bounded_architecture_congruence` : theorem tropical_profile_complete_for_bounded_architecture_congruence
     (file: FINAL/Bridges/OperadicTropicalization.lean)

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
- [Applications] Topological Quantum Compiling: Braid Groups as Uni Q=0.39
- [Applications] EML Differential Calculus: Chain Rules for exp-log Q=0.30
- [Applications] Infinite Games Against Death: Immortality Strategi Q=0.36
- [Bridges] Topological-Algebraic Bridge: Fundamental Group as Q=0.33
- [Computation] Rigorous, fully formalized mathematical framew Q=0.49
- [Cryptography] Tropical Cryptography: Min-Plus Diffie-Hellman Q=0.70
- [EML] Surreal Topology: What Topology Does the Field of  Q=0.67
- [Geometry] Fundamental algebraic-topological bridge: **th Q=0.50
- [Logic] Crystallographic Groups and Music: The 17 Wallpape Q=0.48
- [MachineLearning] PAC-Bayes Bounds: Information-Theoretic Generaliza Q=0.58
- [Novelty] Speculative: Mathematics as a Phase Transition Q=0.32
- [Physics] Gravity as Quantum Error Correction: Spacetime fro Q=0.35
- [Pythagorean] Gap Transition System — a finite-state autom Q=0.33
- [Shared] Cellular Automata as Algebraic Geometry: Wolfram's Q=0.43
- [Tropical] Tropical Optimization: Linear Programming in the M Q=0.40


            ## Known Barriers & Impossibility Results

The following theorems from Aether's Catalog constrain what proof approaches are possible. Consider these as strong warnings — they do not make the task impossible, but any approach must account for them.

- **not_solvable_of_mem_all_derivedSeries** (Algebra): Contains 'not solvable' — in every term of the derived series and is not the identity, the group is not so
- **PillaiDiophantine** (Algebra): Contains 'impossible' — For k = 1: `x^2 - y^2 = 1` with `x, y ≥ 2` is impossible.
- **no_sq_diff_one** (Algebra): Contains 'impossible' — For k = 2: `x^2 - y^2 = 2` with `x, y ≥ 2` is impossible.
- **no_sq_diff_two** (Algebra): Contains 'impossible' — Same factorization argument: (x-y)(x+y) = 2 needs x+y ≤ 2, impossible.
- **monodromy_curvature_duality** (Bridges): Contains 'impossible' — (fig : GenImpossibleFigure n hn) :
- **penrose_polygon_impossible** (Bridges): Contains 'impossible' — theorem penrose_polygon_impossible (k : ℕ) (hk : 0 < k) (δ : ℝ) (hδ : δ ≠ 0) :
- **ascending_staircase_impossible** (Bridges): Contains 'impossible' — positive weights is an impossible figure (ascending staircase).
- **T_preserves_bot** (Bridges): Contains 'impossible' — The temporal propagation of impossibility is impossible.


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

Research domain: Applications
Research mode: team
