            ## Assignment: The Mathematics of Deja Vu: Fixed Points in Consciousness and Cognition

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

2. **At least 5 theorems that demonstrate genuine mathematical insight**:
   Your file must contain at least 5 theorems where removing any key step
   would cause the proof to fail. At least 2 of these must be results that
   a graduate student would find surprising or non-obvious. Depth is measured
   by insight, not tactic count. A result is "deep" if someone reading it
   would need to think before seeing why it's true.

3. **Novel definitions with mathematical substance**: Define at least one new
   mathematical structure or concept that does not already exist in the Catalog.
   The definition must come with at least one non-trivial theorem ABOUT the
   structure (not just "this exists"). Check the catalog references to confirm novelty.

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

5. **PROVE SOMETHING THAT MATTERS**: At least one theorem should connect two
   previously disconnected areas, generalize a classical result, or settle a
   concrete open question. "We formalized X" is not enough — we need "we
   discovered/proved/generalized X". The result should be the kind that would
   appear in a research paper, not a textbook exercise.


            ### Research Direction
            Deja vu — the feeling that you've experienced something before — is a fixed point in a dynamical system. Model cognitive state as a function f: S -> S mapping current brain state to next brain state. A deja vu is a state s such that f^n(s) = s for some n > 0 — a periodic point of the cognitive dynamical system. Conjecture: By Sharkovsky's theorem, the existence of a period-3 orbit in the cognitive dynamics (three distinct states that cycle) implies chaos in the sense of Li-Yorke, meaning there exist uncountably many cognitive trajectories that are neither periodic nor convergent. Moreover, the set of deja vu states (periodic points of f) is dense in the cognitive state space S if f is continuous and S is an interval. The frequency of deja vu (occurring in ~70% of people) corresponds to the natural density of periodic points in a typical chaotic map. Test: model cognitive dynamics as a logistic map f(x) = rx(1-x) on [0,1] with parameter r chosen to match empirical deja vu frequencies. For r = 3.83 (period-3 window), compute the density of periodic points and compare to the 70% lifetime incidence. Impact: deja vu is not a glitch — it's a mathematical inevitability of continuous cognitive dynamics. Any continuous cognitive map with a period-3 orbit MUST have deja vu.

            ### Mathematical Framing
            Deja vu — the feeling that you've experienced something before — is a fixed point in a dynamical system. Model cognitive state as a function f: S -> S mapping current brain state to next brain state. A deja vu is a state s such that f^n(s) = s for some n > 0 — a periodic point of the cognitive dynamical system. Conjecture: By Sharkovsky's theorem, the existence of a period-3 orbit in the cognitive dynamics (three distinct states that cycle) implies chaos in the sense of Li-Yorke, meaning there exist uncountably many cognitive trajectories that are neither periodic nor convergent. Moreover, the set of deja vu states (periodic points of f) is dense in the cognitive state space S if f is continuous and S is an interval. The frequency of deja vu (occurring in ~70% of people) corresponds to the natural density of periodic points in a typical chaotic map. Test: model cognitive dynamics as a logistic map f(x) = rx(1-x) on [0,1] with parameter r chosen to match empirical deja vu frequencies. F

### Lean 4 Sketch
Model cognitive state space as S = [0,1] and cognitive dynamics as f: S -> S continuous. Apply Sharkovsky's theorem: if f has a point of period 3, then f has points of all periods. A deja vu state is a periodic point: s such that f^n(s) = s. Prove: the set of periodic points is dense in S for the logistic map at r = 3.83. Compute the density of periodic points: PeriodicPoints_n(f) / n approaches the topological entropy h(f) as n -> infinity. For the logistic map at r = 3.83, h(f) ~ 0.38. The lif


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: Bridges/HolographicProofRenormalization.lean)
  2. `logistic_trivial_fixed_point` : theorem logistic_trivial_fixed_point (mu : ℝ) : logisticMap mu 0 = 0 := by
     (file: EML/SocialCreditDynamics.lean)
  3. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: FINAL/Bridges/HolographicProofRenormalization.lean)
  4. `logistic_trivial_fixed_point` : theorem logistic_trivial_fixed_point (mu : ℝ) : logisticMap mu 0 = 0 := by
     (file: FINAL/EML/SocialCreditDynamics.lean)
  5. `distinct_cycle_count_bound` : theorem distinct_cycle_count_bound {α : Type*} [Fintype α] [DecidableEq α]
     (file: EML/AdelicSynchronization.lean)
  6. `point_hypersurface_incidence_bound` : theorem point_hypersurface_incidence_bound
     (file: EML/PolynomialMethod/SchwartzZippel.lean)
  7. `distinct_cycle_count_bound` : theorem distinct_cycle_count_bound {α : Type*} [Fintype α] [DecidableEq α]
     (file: FINAL/EML/AdelicSynchronization.lean)
  8. `period3_implies_fixed_point` : theorem period3_implies_fixed_point (f : ℝ → ℝ) (hf : Continuous f)
     (file: MachineLearning/DejaVu/Advanced.lean)
  9. `logistic_map_fixed_point` : theorem logistic_map_fixed_point :
     (file: FINAL/Physics/ShadowingLemma.lean)
  10. `logistic_map_fixed_point` : theorem logistic_map_fixed_point :
     (file: Physics/ShadowingLemma.lean)
  11. `period3_implies_fixed_point_ivt` : theorem period3_implies_fixed_point_ivt
     (file: FINAL/MachineLearning/CognitiveDynamics.lean)
  12. `period3_implies_fixed_point_ivt` : theorem period3_implies_fixed_point_ivt
     (file: MachineLearning/DejaVu/CognitiveDynamics.lean)
  13. `emlGmap_at_most_one_fixed_point` : theorem emlGmap_at_most_one_fixed_point (a b : ℝ) (ha : 0 < a) (hb : 0 < b)
     (file: EML/EMLv17Advanced.lean)
  14. `gmap_fixed_point_lambert` : theorem gmap_fixed_point_lambert (z : ℝ) (hz : 0 < z) (hfix : emlGmap z = z) :
     (file: EML/EMLv18Core.lean)
  15. `oml_unique_fixed_point` : theorem oml_unique_fixed_point (x : ℝ) (hx : 0 < x) (hfx : oml x = x) : x = 1 := by
     (file: EML/FutureResearch.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ## Known Barriers & Impossibility Results

The following theorems from Aether's Catalog constrain what proof approaches are possible. Consider these as strong warnings — they do not make the task impossible, but any approach must account for them.

- **iterImageCard_antitone** (EML): Contains 'cannot' — and the fact that applying f to a set cannot increase its size. -/
- **diagSubcriticalAnalyticFailure_iff_hasCriticalPoint** (EML): Contains 'barrier' — /-- The diagonal entropy barrier holds if and only if every infinite family
- **critical_point_yields_infinite_diagonal_irreducibles** (EML): Contains 'irreducible' — theorem critical_point_yields_infinite_diagonal_irreducibles
- **critical_point_yields_partial_barrier** (EML): Contains 'barrier' — theorem critical_point_yields_partial_barrier
- **critical_point_yields_partial_barrier** (EML): Contains 'incompleteness' — diagonal_phase_transition_incompleteness
- **eml_uniformClosure_eq_top_of_separatesPoints_lattice_mul** (EML): Contains 'cannot' — Addition cannot be derived from `const`, `mul`, `max`, `min` alone at the set le
- **assembly_count_grows_with_alphabet** (EML): Contains 'lower bound' — Structural test: The trivial lower bound on assemblies grows with alphabet size.
- **nullity_add_self** (EML): Contains 'cannot' — cannot be reached by repeated self-addition of a finite quantity. -/
            ## Recommended Proof Strategies

The following proof techniques have been effective in this domain. Consider using them if applicable:

- **diagonal**: 
- **fixed point**: 
- **contradiction**: 
- **embedding**: 

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

Research domain: EML
Research mode: team
