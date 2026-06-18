            ## Assignment: Concrete bridge between two-cube and three-cub

            Lead a research team to maximize scientific output per cycle. ORGANIZE as: (1) Hypothesis Team — brainstorm 3-5 bold, falsifiable conjectures; (2) Experiment Team — prove or disprove each hypothesis in Lean 4; (3) Analysis Team — examine what survived, what failed, and WHY failures failed — failures teach as much as successes; (4) Writing Team — produce all deliverables (article, paper, demos, HTML widgets) from the team's findings. SCIENCE IS A LOOP: explore → identify patterns → hypothesize → validate → upgrade knowledge → repeat. Each subagent contributes its expertise; the Writing Team synthesizes everything into polished output. More minds = more compute = deeper results.

            ## Research Cycle: Explore → Pattern → Hypothesize → Validate → Upgrade → Repeat

            You are part of an autonomous research system that runs continuously.
            Each cycle's output feeds the next cycle's input in a positive feedback loop.
            Your FUTURE_DIRECTIONS.md determines what the next cycle investigates.
            The quality of your directions determines the quality of future research.

            Follow this cycle model:
            1. **Explore** — Survey what exists, find gaps, identify anomalies.
            2. **Pattern** — Detect structures, connections, and regularities.
            3. **Hypothesize** — Propose falsifiable conjectures bold enough to matter
               and specific enough to fail. "Study X further" is not a hypothesis.
            4. **Validate** — Prove or disprove. Failures teach as much as successes.
            5. **Upgrade** — Integrate what you learned into the knowledge base.
            6. **Repeat** — Your FUTURE_DIRECTIONS.md prescribes the next cycle's
               best, most fruitful research directions.

            The Aristotle prompt drives the research directions, which drive results,
            which drive the next Aristotle prompt — a positive, self-aware, intelligent
            feedback loop. Make each cycle count.

            ## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems that demonstrate genuine mathematical insight**:
   Your file must contain at least 3 theorems where removing any key step
   would cause the proof to fail. Depth is measured by insight, not tactic count.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.


            ### Research Direction
            # Future Directions: Taxicab Numbers and Cube Decomposition Theory

## Synthesis

This research cycle established a concrete bridge between two-cube and three-cube representations through the Three-Cube Inversion Principle: if c³ - n = a³ + b³, then n = (-a)³ + (-b)³ + c³. Applied to 1729, this principle explains *why* the nontrivial representation (-7)³ + (-5)³ + 13³ = 1729 exists — the overshoot 13³ - 1729 = 468 = 7³ + 5³ is itself a sum of two cubes. The prime factorization 1729 = 7 · 13 · 19 participates in all cube decompositions, with factors appearing as cube bases, algebraic components, and Korselt divisors simultaneously.

The most promising cross-domain connection is between the inversion principle and the density theory of sums of three cubes. The classical conjecture (supported by extensive computation) is that every admissible integer (not ≡ 4, 5 mod 9) has a three-cube representation. The inversion principle offers a *constructive* approach: rather than searching the full three-dimensional space of triples, one can systematically search for overshoots c³ - n that happen to be sums of two cubes. This connects the three-cube problem to the well-studied density of sums of two cubes, which is known to be Θ(N^{2/3} / √(log N)) up to N.

The connection to Carmichael numbers (1729 - 1 = 12³ satisfies Korselt's criterion) suggests a deeper investigation of when n - 1 being a perfect cube interacts with the cube decomposition structure of n itself.

---

### Direction 1: Inversion-Accessible Density

**Conjecture**: The density of integers n ≤ N that have at least one "inversion-accessible" three-cube representation (i.e., there exists c with c³ - n = a³ + b³ for positive a, b) is Ω(N^{2/3} / √(log N)). Specifically, the set of n that are inversion-accessible should have positive lower density within the admissible integers (those not ≡ 4, 5 mod 9).

**Test**: For N = 10⁶, compute the number of n ≤ N such that there exists c ≤ N^{1/3} + N^{1/3} with c³ - n a su

            ### Mathematical Framing
            # Future Directions: Taxicab Numbers and Cube Decomposition Theory

## Synthesis

This research cycle established a concrete bridge between two-cube and three-cube representations through the Three-Cube Inversion Principle: if c³ - n = a³ + b³, then n = (-a)³ + (-b)³ + c³. Applied to 1729, this principle explains *why* the nontrivial representation (-7)³ + (-5)³ + 13³ = 1729 exists — the overshoot 13³ - 1729 = 468 = 7³ + 5³ is itself a sum of two cubes. The prime factorization 1729 = 7 · 13 · 19 participates in all cube decompositions, with factors appearing as cube bases, algebraic components, and Korselt divisors simultaneously.

The most promising cross-domain connection is between the inversion principle and the density theory of sums of three cubes. The classical conjecture (supported by extensive computation) is that every admissible integer (not ≡ 4, 5 mod 9) has a three-cube representation. The inversion principle offers a *constructive* approach: rather than searching the full


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `exists_prime_between_sq_and_two_mul_sq` : theorem exists_prime_between_sq_and_two_mul_sq
     (file: FINAL/MachineLearning/LegendreGapReduction.lean)
  2. `exists_prime_between_sq_and_two_mul_sq` : theorem exists_prime_between_sq_and_two_mul_sq
     (file: MachineLearning/LegendreGapReduction.lean)
  3. `prime_one_mod_four_has_sum_two_squares` : theorem prime_one_mod_four_has_sum_two_squares
     (file: FINAL/Pythagorean/TropicalBerggrenZeta.lean)
  4. `prime_one_mod_four_has_sum_two_squares` : theorem prime_one_mod_four_has_sum_two_squares
     (file: Pythagorean/TropicalBerggrenZeta.lean)
  5. `prime_triple_odd_not_all_two` : theorem prime_triple_odd_not_all_two
     (file: FINAL/MachineLearning/Advanced.lean)
  6. `prime_triple_odd_not_all_two` : theorem prime_triple_odd_not_all_two
     (file: MachineLearning/Goldbach/Advanced.lean)
  7. `cube_is_sum_of_three_cubes` : theorem cube_is_sum_of_three_cubes (m : ℤ) :
     (file: MachineLearning/NumberTheory/SumThreeCubes/Basic.lean)
  8. `sum_three_cubes_not_four_five_mod_nine` : theorem sum_three_cubes_not_four_five_mod_nine
     (file: Algebra/CubeResidues.lean)
  9. `sum_three_cubes_not_four_five_mod_nine` : theorem sum_three_cubes_not_four_five_mod_nine
     (file: FINAL/Algebra/CubeResidues.lean)
  10. `not_admissible_iff_full_cover` : theorem not_admissible_iff_full_cover (H : Finset ℕ) :
     (file: FINAL/MachineLearning/Admissible.lean)
  11. `density_does_not_determine_structure` : theorem density_does_not_determine_structure :
     (file: FINAL/MachineLearning/CounterfactualPrimes.lean)
  12. `sum_three_cube_residues_avoid_4_5` : theorem sum_three_cube_residues_avoid_4_5
     (file: FINAL/MachineLearning/LocalGlobalGeometry.lean)
  13. `every_nat_sum_two_sq` : theorem every_nat_sum_two_sq (n : ℕ) : IsSumOfTwoSquares (n ^ 2 : ℤ) :=
     (file: FINAL/MachineLearning/PhotonNetworks.lean)
  14. `not_admissible_iff_full_cover` : theorem not_admissible_iff_full_cover (H : Finset ℕ) :
     (file: MachineLearning/Admissible.lean)
  15. `density_does_not_determine_structure` : theorem density_does_not_determine_structure :
     (file: MachineLearning/CounterfactualPrimes.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


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
