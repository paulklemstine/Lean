            ## Assignment: Diophantine Approximation on Neural Networks: How Well Can ReLU Approximate Pi?

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
            A ReLU network f: R -> R with L layers of width w is a piecewise linear function with at most w^L pieces. By the universal approximation theorem, such networks can approximate any continuous function. But HOW WELL can they approximate specific constants? Conjecture: a ReLU network with L layers of width w can approximate pi to within epsilon using O(w * L * log(1/epsilon)) parameters. More precisely, there exists a ReLU network f with L = O(log(log(1/epsilon))) layers and w = O(log(1/epsilon)) width such that |f(1) - pi| < epsilon. This is because pi can be computed by the Leibniz formula pi/4 = 1 - 1/3 + 1/5 - ..., and a ReLU network can implement the partial sums. The number of terms needed is O(1/epsilon), and each term can be computed by a constant-depth ReLU subnetwork. The depth needed is O(log(1/epsilon)) for the sum and O(log(log(1/epsilon))) for the individual terms. Conjecture: the approximation rate for rational numbers by ReLU networks is O(1/(w^L)), matching the piecewise linear structure. For irrational numbers like pi, the rate is O(1/(w * L * 2^L)), which is slower but still exponential in depth. Test: construct ReLU networks that approximate pi, e, and sqrt(2) and measure the approximation error as a function of network size. Impact: ReLU networks approximate constants at a rate determined by their depth and width. Pi requires O(log(log(1/epsilon))) depth.

            ### Mathematical Framing
            A ReLU network f: R -> R with L layers of width w is a piecewise linear function with at most w^L pieces. By the universal approximation theorem, such networks can approximate any continuous function. But HOW WELL can they approximate specific constants? Conjecture: a ReLU network with L layers of width w can approximate pi to within epsilon using O(w * L * log(1/epsilon)) parameters. More precisely, there exists a ReLU network f with L = O(log(log(1/epsilon))) layers and w = O(log(1/epsilon)) width such that |f(1) - pi| < epsilon. This is because pi can be computed by the Leibniz formula pi/4 = 1 - 1/3 + 1/5 - ..., and a ReLU network can implement the partial sums. The number of terms needed is O(1/epsilon), and each term can be computed by a constant-depth ReLU subnetwork. The depth needed is O(log(1/epsilon)) for the sum and O(log(log(1/epsilon))) for the individual terms. Conjecture: the approximation rate for rational numbers by ReLU networks is O(1/(w^L)), matching the piecewise 

### Lean 4 Sketch
Leibniz formula: pi/4 = sum_{k=0}^{infinity} (-1)^k / (2k+1). The partial sum S_n = sum_{k=0}^{n-1} (-1)^k / (2k+1) approximates pi/4 with error O(1/n). To achieve |f(1) - pi| < epsilon, we need n = O(1/epsilon) terms. ReLU implementation: each term t_k = (-1)^k / (2k+1) can be computed as t_k = ReLU(1/(2k+1)) - 2*ReLU(1/(2k+1) - 1/2) (alternating sign). The division 1/(2k+1) requires a ReLU network with O(log(k)) depth (using binary long division). The sum of n terms requires O(log(n)) depth (t


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `network_size_for_epsilon` : theorem network_size_for_epsilon (ε : ℝ) (hε : 0 < ε) :
     (file: MachineLearning/DiophantineReLU/Basic.lean)
  2. `information_lattice_depth_linear` : theorem information_lattice_depth_linear {α : Type*} [Fintype α]
     (file: FINAL/Shared/Foundations.lean)
  3. `information_lattice_depth_linear` : theorem information_lattice_depth_linear {α : Type*} [Fintype α]
     (file: Shared/Foundations.lean)
  4. `extracted_term_semantically_equivalent_with_size` : theorem extracted_term_semantically_equivalent_with_size
     (file: Bridges/HigherOrderEqSat.lean)
  5. `relu_network_has_canonical_tropical_rational` : theorem relu_network_has_canonical_tropical_rational (N : UnivReluNet) :
     (file: Catalog/Bridges/old/Tropical/Canonical/Basic.lean)
  6. `relu_network_lipschitz_depth` : theorem relu_network_lipschitz_depth (W : ℝ) (hW : 0 ≤ W) (d : ℕ) :
     (file: Cryptography/TropicalCryptoRobustnessBridge.lean)
  7. `extracted_term_semantically_equivalent_with_size` : theorem extracted_term_semantically_equivalent_with_size
     (file: FINAL/Bridges/HigherOrderEqSat.lean)
  8. `relu_network_lipschitz_depth` : theorem relu_network_lipschitz_depth (W : ℝ) (hW : 0 ≤ W) (d : ℕ) :
     (file: FINAL/Cryptography/TropicalCryptoRobustnessBridge.lean)
  9. `exists_depth_d_triple_with_hyp_le_iff` : theorem exists_depth_d_triple_with_hyp_le_iff (N : ℤ) (d : ℕ) :
     (file: FINAL/Pythagorean/BerggrenExtremal.lean)
  10. `descent_depth_at_most_log` : theorem descent_depth_at_most_log (c : ℕ) : Nat.log 2 c ≤ c := Nat.log_le_self 2 c
     (file: FINAL/Pythagorean/BerggrenGaussian.lean)
  11. `sum_ne_zero_of_same_sign_and_exists_ne_zero` : theorem sum_ne_zero_of_same_sign_and_exists_ne_zero
     (file: FINAL/Pythagorean/LorentzianAggregateAntiCancel.lean)
  12. `qkd_rate_bound` : theorem qkd_rate_bound (e : ℝ) (_he : 0 ≤ e) (he1 : e ≤ 1/2) :
     (file: FINAL/Shared/EntropyLatticeCrypto.lean)
  13. `partition_function_upper_bound` : theorem partition_function_upper_bound (sys : ThermodynamicSystem α) :
     (file: FINAL/Shared/Theorems.lean)
  14. `depth_width_pieces` : theorem depth_width_pieces (w L : ℕ) (hw : 1 ≤ w) :
     (file: FINAL/Tropical/TropicalOracleResearch.lean)
  15. `exists_depth_d_triple_with_hyp_le_iff` : theorem exists_depth_d_triple_with_hyp_le_iff (N : ℤ) (d : ℕ) :
     (file: Pythagorean/BerggrenExtremal.lean)

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

Research domain: Shared
Research mode: team
