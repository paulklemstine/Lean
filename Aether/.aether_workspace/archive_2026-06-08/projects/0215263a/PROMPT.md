            ## Assignment: Proofs as DAGs: The Directed Acyclic Graph Structure of Mathematics

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
            Every mathematical proof is a directed acyclic graph (DAG): nodes are statements, edges are implications, and the acyclicity comes from the fact that you can't prove A from B and B from A without a circular argument (which is not a valid proof). Conjecture: The DAG of all mathematical proofs has a scale-free structure: the in-degree distribution follows a power law P(k) ~ k^{-gamma} with gamma ≈ 2.5. This means most theorems are proved from a small number of foundational results (the 'hubs'), and there are exponentially many theorems that depend on these hubs. The top 10 hub theorems in mathematics are: (1) Zorn's Lemma, (2) The Intermediate Value Theorem, (3) The Fundamental Theorem of Calculus, (4) The Sylow Theorems, (5) The Baire Category Theorem, (6) Hahn-Banach Theorem, (7) Urysohn's Lemma, (8) The Pigeonhole Principle, (9) Induction, (10) The Law of Excluded Middle. Conjecture: removing any of the top 10 hubs disconnects the proof DAG into at least 2 large components, each containing more than 10% of all theorems. This means mathematics is fragile: removing one foundational theorem makes many other theorems unprovable. Test: construct the proof DAG from Lean 4's Mathlib (all proofs and their dependencies), compute the in-degree distribution, and verify the power law. Impact: mathematics is a scale-free network, and its most important theorems are its most connected nodes — the hubs that hold the entire structure together.

            ### Mathematical Framing
            Every mathematical proof is a directed acyclic graph (DAG): nodes are statements, edges are implications, and the acyclicity comes from the fact that you can't prove A from B and B from A without a circular argument (which is not a valid proof). Conjecture: The DAG of all mathematical proofs has a scale-free structure: the in-degree distribution follows a power law P(k) ~ k^{-gamma} with gamma ≈ 2.5. This means most theorems are proved from a small number of foundational results (the 'hubs'), and there are exponentially many theorems that depend on these hubs. The top 10 hub theorems in mathematics are: (1) Zorn's Lemma, (2) The Intermediate Value Theorem, (3) The Fundamental Theorem of Calculus, (4) The Sylow Theorems, (5) The Baire Category Theorem, (6) Hahn-Banach Theorem, (7) Urysohn's Lemma, (8) The Pigeonhole Principle, (9) Induction, (10) The Law of Excluded Middle. Conjecture: removing any of the top 10 hubs disconnects the proof DAG into at least 2 large components, each conta

### Lean 4 Sketch
Construct the proof DAG: nodes = theorems in Mathlib, edges = (A, B) if theorem A is used in the proof of theorem B. Compute in-degree distribution P(k) = #{theorems with k dependents}/N. Fit power law P(k) ~ k^{-gamma} using maximum likelihood estimation (Clauset-Shalizi-Newman method). Compute hub scores: theorems with highest in-degree are the hubs. Identify the top 10 hubs by in-degree. Test robustness: for each of the top 10 hubs, remove the hub and all its outgoing edges, and compute the s


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `not_isAcyclic_of_connected_many_edges` : theorem not_isAcyclic_of_connected_many_edges
     (file: FINAL/Pythagorean/HardnessLocalization.lean)
  2. `conjecture_iff_all_bounded` : theorem conjecture_iff_all_bounded :
     (file: Novelty/CollatzUndecidability.lean)
  3. `not_isAcyclic_of_connected_many_edges` : theorem not_isAcyclic_of_connected_many_edges
     (file: Pythagorean/HardnessLocalization.lean)
  4. `graphCycleRankZ_pos_of_connected_many_edges` : theorem graphCycleRankZ_pos_of_connected_many_edges
     (file: Bridges/LocalCyclePressure.lean)
  5. `rank_free_expansion_from_conjecture` : theorem rank_free_expansion_from_conjecture
     (file: Bridges/SymplecticCertificateAlgebra.lean)
  6. `rank_free_expansion_from_conjecture` : theorem rank_free_expansion_from_conjecture
     (file: Catalog/Bridges/Pythagorean/SymplecticCertificateAlgebra.lean)
  7. `directed_cheeger_conjecture_test` : theorem directed_cheeger_conjecture_test : True := trivial
     (file: Computation/SpectralProofComplexity.lean)
  8. `graphCycleRankZ_pos_of_connected_many_edges` : theorem graphCycleRankZ_pos_of_connected_many_edges
     (file: FINAL/Bridges/LocalCyclePressure.lean)
  9. `directed_cheeger_conjecture_test` : theorem directed_cheeger_conjecture_test : True := trivial
     (file: FINAL/Computation/SpectralProofComplexity.lean)
  10. `excluded_middle_not_tautology` : theorem excluded_middle_not_tautology :
     (file: FINAL/Logic/ParaconsistentParadox.lean)
  11. `unprovable_not_in_any_class` : theorem unprovable_not_in_any_class {V : Type*} [ProofSystem V]
     (file: FINAL/MachineLearning/CertificationBarrier.lean)
  12. `not_connected_has_nontrivial_clopen` : theorem not_connected_has_nontrivial_clopen [LinearOrder α] [TopologicalSpace α]
     (file: FINAL/MachineLearning/OrderGap.lean)
  13. `empty_graph_not_connected` : theorem empty_graph_not_connected {n : ℕ} (hn : 2 ≤ n) :
     (file: FINAL/MachineLearning/ViralInformationTopology.lean)
  14. `conjecture_follows_from_hierarchy` : theorem conjecture_follows_from_hierarchy :
     (file: FINAL/Pythagorean/LorentzianBivariateSpecialization.lean)
  15. `excluded_middle_not_tautology` : theorem excluded_middle_not_tautology :
     (file: Logic/ParaconsistentParadox.lean)
  16. `unprovable_not_in_any_class` : theorem unprovable_not_in_any_class {V : Type*} [ProofSystem V]
     (file: MachineLearning/CertificationBarrier.lean)
  17. `not_connected_has_nontrivial_clopen` : theorem not_connected_has_nontrivial_clopen [LinearOrder α] [TopologicalSpace α]
     (file: MachineLearning/SurrealTopology/OrderGap.lean)
  18. `empty_graph_not_connected` : theorem empty_graph_not_connected {n : ℕ} (hn : 2 ≤ n) :
     (file: MachineLearning/ViralInformationTopology.lean)
  19. `conjecture_follows_from_hierarchy` : theorem conjecture_follows_from_hierarchy :
     (file: Pythagorean/LorentzianBivariateSpecialization.lean)
  20. `degree1_exact_from_cover_and_local_positivity` : theorem degree1_exact_from_cover_and_local_positivity
     (file: Bridges/MarginCosheaf.lean)
  21. `degree1_exact_from_cover_and_local_positivity` : theorem degree1_exact_from_cover_and_local_positivity
     (file: FINAL/Bridges/MarginCosheaf.lean)
  22. `all_k_product_free_not_implies_ufd` : theorem all_k_product_free_not_implies_ufd :
     (file: MachineLearning/CounterfactualHierarchy/Basic.lean)
  23. `graphCycleRank_pos_of_connected_many_edges` : theorem graphCycleRank_pos_of_connected_many_edges
     (file: MachineLearning/ProofTheoreticTopology/Theorems.lean)
  24. `not_all_space_filling_are_dragon_limits` : theorem not_all_space_filling_are_dragon_limits :
     (file: Algebra/TropicalDragon.lean)
  25. `not_all_space_filling_are_dragon_limits` : theorem not_all_space_filling_are_dragon_limits :
     (file: FINAL/Algebra/TropicalDragon.lean)

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
- **proof_density_vanishes** (Physics): Contains 'unprovable' — /-- **Unprovable statement density**: If T ≤ b^(n-1) statements are provable,
- **SpectralGraphTheory** (Algebra): Contains 'independent of' — converge under coarse-graining to a universal distribution independent of the
- **not_solvable_of_mem_all_derivedSeries** (Algebra): Contains 'not solvable' — in every term of the derived series and is not the identity, the group is not so
- **tv_lower_bound_of_observable_bias** (Bridges): Contains 'lower bound' — combinatorial lower bounds to cryptographic security lower bounds.
- **proof_length_counting_bound** (Bridges): Contains 'cannot' — discrete version: if b^n < T then proofs of length n cannot cover all T theorems
- **proof_length_counting_bound** (Bridges): Contains 'lower bound' — **Proof length lower bound by induction**: For b ≥ 2, the function b^n
- **random_theorem_unprovability** (Bridges): Contains 'unprovable' — We prove: if P < b^n then there exist unprovable statements.
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
