            ## Assignment: Tropical Hodge Theory

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
            Prove a tropical analog of the Hodge decomposition. Formalize tropical (p,q)-forms, the tropical Laplacian, and harmonic theory on balanced weighted polyhedral complexes.

            ### Mathematical Framing
            Prove a tropical analog of the Hodge decomposition. Formalize tropical (p,q)-forms, the tropical Laplacian, and harmonic theory on balanced weighted polyhedral complexes.


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `tropical_convexity_entropy_bound` : theorem tropical_convexity_entropy_bound (a b : ℝ)
     (file: FINAL/Shared/EntropyLatticeCrypto.lean)
  2. `tropical_convexity_entropy_bound` : theorem tropical_convexity_entropy_bound (a b : ℝ)
     (file: Shared/EntropyLatticeCrypto.lean)
  3. `tropical_evaluation_upper_bound` : theorem tropical_evaluation_upper_bound {n : ℕ} (profile : NewtonProfile n)
     (file: Shared/NewtonTropicalBridge.lean)
  4. `hodge_bound_combinatorial` : theorem hodge_bound_combinatorial (w₁ wL p q : ℕ) :
     (file: Shared/NeuralHodge/Bounds.lean)
  5. `tropical_and_bound` : theorem tropical_and_bound (a b : ℝ) : min a b ≤ a := min_le_left a b
     (file: Bridges/TropicalArithmeticCoding.lean)
  6. `tropical_and_bound` : theorem tropical_and_bound (a b : ℝ) : min a b ≤ a := min_le_left a b
     (file: FINAL/Bridges/TropicalArithmeticCoding.lean)
  7. `tropical_entropy_add_comm` : theorem tropical_entropy_add_comm (a b : TropicalEntropyVal) :
     (file: FINAL/Shared/EntropyAlgebra.lean)
  8. `tropical_meet_comm` : theorem tropical_meet_comm (a b : TropicalEntropy) :
     (file: FINAL/Shared/EntropyAlgebraCrypto.lean)
  9. `tropical_subadditivity_maxProb` : theorem tropical_subadditivity_maxProb {β : Type*} [Fintype β] [Nonempty β]
     (file: FINAL/Shared/Theorems.lean)
  10. `tropical_stability_via_laplacian_bound` : theorem tropical_stability_via_laplacian_bound [Nonempty V]
     (file: Pythagorean/TropicalBridge/Stability.lean)
  11. `tropical_entropy_add_comm` : theorem tropical_entropy_add_comm (a b : TropicalEntropyVal) :
     (file: Shared/EntropyAlgebra.lean)
  12. `tropical_meet_comm` : theorem tropical_meet_comm (a b : TropicalEntropy) :
     (file: Shared/EntropyAlgebraCrypto.lean)
  13. `tropical_subadditivity_maxProb` : theorem tropical_subadditivity_maxProb {β : Type*} [Fintype β] [Nonempty β]
     (file: Shared/Theorems.lean)
  14. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: Computation/OracleApplicationsFrontier.lean)
  15. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: FINAL/Computation/OracleApplicationsFrontier.lean)
  16. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: FINAL/Tropical/OracleApplicationsFrontier.lean)
  17. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: Tropical/OracleApplicationsFrontier.lean)
  18. `master_tropical_hodge_theorem` : theorem master_tropical_hodge_theorem
     (file: FINAL/Tropical/TropicalCycleCorrespondence.lean)
  19. `master_tropical_hodge_theorem` : theorem master_tropical_hodge_theorem
     (file: Tropical/HodgeShadow/TropicalCycleCorrespondence.lean)
  20. `tropical_distributivity` : theorem tropical_distributivity (a b c : TropicalReal) :
     (file: Shared/TropicalEntropy/Defs.lean)
  21. `weighted_defect_eq_twice_laplacian` : theorem weighted_defect_eq_twice_laplacian (G : OverlapNerve ι) (f : ι → ℝ) :
     (file: Algebra/SheafData/Core.lean)
  22. `certified_finite_tropical_decomposition` : theorem certified_finite_tropical_decomposition
     (file: Bridges/TropicalChoquetClosureDuality.lean)
  23. `tropical_factoring_decomposition` : theorem tropical_factoring_decomposition {n a b : ℕ} {p : ℕ} (hp : Nat.Prime p)
     (file: Bridges/TropicalFactoring.lean)
  24. `certified_finite_tropical_decomposition` : theorem certified_finite_tropical_decomposition
     (file: FINAL/Bridges/TropicalChoquetClosureDuality.lean)
  25. `weighted_tropical_kernel_dim_formula` : theorem weighted_tropical_kernel_dim_formula
     (file: FINAL/Pythagorean/ExactWeightedTropicalDimension.lean)

⚠️ **Domain Focus**: This domain has historically produced lower-quality results. Prioritize DEEP, GENUINELY NOVEL theorems over breadth. Avoid trivial wrappers, definition-only results, or repackaging known facts. Every theorem must represent real mathematical progress.


### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## Aether Research Journal

### Recent Activity
- Q=0.40 [Novelty] Non-Archimedean Probability via Surreal Numbers
- Q=0.37 [Novelty] The Category Theory of Jokes: Universal Properties
- Q=0.40 [Novelty] Sonic Mathematics: Counterpoint as Category Theory
- Q=0.43 [Novelty] Tangled Hierarchies: Proof Systems That Reference 
- Q=0.65 [Novelty] Sonic Mathematics: Counterpoint as Category Theory

### Active Research Threads
- [Shared] Bridge: Quantum Groups as Deformations of Classica Q=0.34
- [Shared] Cellular Automata as Algebraic Geometry: Wolfram's Q=0.43
- [Shared] Surreal Topology: What Topology Does the Field of  Q=0.35
- [Algebra] Non-Well-Founded Proofs: Proofs That Reference The Q=0.36
- [Applications] EML Universal Approximation: Density of EML Functi Q=0.45
- [Bridges] The Mathematics of Jigsaw Puzzles: NP-Completeness Q=0.47
- [Computation] Rigorous, fully formalized mathematical framew Q=0.49
- [Cryptography] Speculative: Mathematics as an Evolving Ecosystem Q=0.36
- [EML] Surreal Topology: What Topology Does the Field of  Q=0.67
- [Geometry] Fundamental algebraic-topological bridge: **th Q=0.50
- [Logic] Transreal Arithmetic: Computing Beyond Plus-Minus  Q=0.50
- [MachineLearning] Speculative: Consciousness as Fixed Points of Recu Q=0.32
- [Novelty] Non-Archimedean Probability via Surreal Numbers Q=0.40
- [Physics] Diophantine Approximation on Neural Networks: How  Q=0.33
- [Pythagorean] **cyclotomic bridge**: the Alexander polynom Q=0.57
- [Tropical] Tropical Satake Isomorphism for GL_n Q=0.51


            ## Known Barriers & Impossibility Results

The following theorems from Aether's Catalog constrain what proof approaches are possible. Consider these as strong warnings — they do not make the task impossible, but any approach must account for them.

- **tropical_godel_incompleteness** (Logic): Contains 'Gödel' — This is the tropical analogue of the liar/Gödel paradox. -/
- **qkd_rate_bound** (Shared): Contains 'cannot' — quantum information cannot be duplicated. If total input entropy h_in
- **thermodynamic_computing_energy** (Shared): Contains 'lower bound' — Application: hamiltonian computing energy lower bounds. -/
- **lipschitz_robustness_radius_positive** (Shared): Contains 'cannot' — γ/L > 0. Perturbations within this radius cannot change the prediction.
- **fano_inequality_binary** (Shared): Contains 'lower bound' — Application: certified_robustness error lower bounds in ML classification. -/
- **exists_div_three_in_triple** (Shared): Contains 'cannot' — **No Prime Triplet Theorem**: For p > 3, the numbers p, p+2, p+4 cannot
- **dec_undec_partition** (Shared): Contains 'undecidable' — Decidable and undecidable counts partition the total.
- **entropy_profit_duality** (Shared): Contains 'incompleteness' — What incompleteness takes away is exactly what decidability gives.
            ## Recommended Proof Strategies

The following proof techniques have been effective in this domain. Consider using them if applicable:

- **homomorphism**: 
- **fixed point**: 
- **induction**: 
- **construction**: 

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
**Applications**:
  `Applications/DreamtimeAlgebra/Defs.lean`: DreamtimeAlgebra, marriageMap, descentMap
  `Applications/PoincareData/SimplicialComplex.lean`: AbstractSimplicialComplex, euler_char_sphere, sphere_detection_stable
  `Applications/DreamtimeAlgebra/Theorems.lean`: marriageCompatible_iff_diff
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
