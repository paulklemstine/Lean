            ## Assignment: The Collatz Conjecture Is Undecidable: What If 3n+1 Can't Be Proved?

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

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

5. **Cross-connection**: At least one theorem should genuinely connect to
   or build upon an existing catalog result. Generic new math that doesn't
   talk to anything is not a breakthrough — it's a hobby. The new structure
   should illuminate something that already exists.


            ### Research Direction
            The Collatz conjecture (3n+1 problem) states that every positive integer eventually reaches 1 under the map T(n) = n/2 (n even) or 3n+1 (n odd). Despite being verified up to 2^68, a proof remains elusive. Conjecture: the Collatz conjecture is independent of Peano Arithmetic (PA). That is, PA can neither prove nor refute the statement 'for all n, the Collatz sequence starting at n eventually reaches 1'. This would mean the conjecture is TRUE (in the standard model) but UNPROVABLE in PA. The argument: the Collatz map is a Diophantine function that grows faster than any provably total computable function in PA. Specifically, the halting problem for Collatz (does the orbit of n reach 1?) is at least as hard as the consistency of PA, which by Godel's second incompleteness theorem is unprovable in PA. Conjecture: the Collatz conjecture is equivalent to Con(PA) over a weak base theory, meaning that if PA is consistent, then PA does not prove Collatz. Test: formalize the equivalence between Collatz and Con(PA) in Lean 4. Show that a counterexample to Collatz (an n whose orbit diverges or cycles) would imply not-Con(PA). Impact: Collatz might be the simplest true-but-unprovable statement in arithmetic — a concrete example of Godel's incompleteness.

            ### Mathematical Framing
            The Collatz conjecture (3n+1 problem) states that every positive integer eventually reaches 1 under the map T(n) = n/2 (n even) or 3n+1 (n odd). Despite being verified up to 2^68, a proof remains elusive. Conjecture: the Collatz conjecture is independent of Peano Arithmetic (PA). That is, PA can neither prove nor refute the statement 'for all n, the Collatz sequence starting at n eventually reaches 1'. This would mean the conjecture is TRUE (in the standard model) but UNPROVABLE in PA. The argument: the Collatz map is a Diophantine function that grows faster than any provably total computable function in PA. Specifically, the halting problem for Collatz (does the orbit of n reach 1?) is at least as hard as the consistency of PA, which by Godel's second incompleteness theorem is unprovable in PA. Conjecture: the Collatz conjecture is equivalent to Con(PA) over a weak base theory, meaning that if PA is consistent, then PA does not prove Collatz. Test: formalize the equivalence between Co

### Lean 4 Sketch
The argument proceeds in three steps. Step 1: Show that the Collatz halting problem (given n, does T^k(n) = 1 for some k?) is Pi^0_2-complete. This means it is at least as hard as any Pi^0_2 statement, including Con(PA). Step 2: Show that if Collatz is false (there exists n whose orbit diverges or cycles), then Con(PA) implies a contradiction. This would mean not-Collatz implies not-Con(PA), i.e., Collatz follows from Con(PA). Step 3: Show that if Collatz is true, then PA cannot prove it, becaus


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `boundary_faster_than_bulk` : theorem boundary_faster_than_bulk (cert_size proof_size : ℕ)
     (file: FINAL/Logic/HolographicSearch.lean)
  2. `boundary_faster_than_bulk` : theorem boundary_faster_than_bulk (cert_size proof_size : ℕ)
     (file: Logic/HolographicSearch.lean)
  3. `eval_not_and` : theorem eval_not_and {n : ℕ} (C₁ C₂ : BoolCircuit n) (x : Fin n → Bool) :
     (file: FINAL/Logic/CircuitComplexityBarriers.lean)
  4. `entangled_harder_than_independent` : theorem entangled_harder_than_independent {k : ℕ} (hk : 0 < k)
     (file: FINAL/Logic/EntanglementDifficulty.lean)
  5. `not_mem_of_positive_novelty` : theorem not_mem_of_positive_novelty
     (file: FINAL/Logic/NoveltyCertification.lean)
  6. `OracleHierarchy.con_unprovable_le` : theorem OracleHierarchy.con_unprovable_le (H : OracleHierarchy) (k m : ℕ) (hm : m ≤ k) :
     (file: FINAL/Logic/OracleClosureAlgebra.lean)
  7. `true_not_false` : theorem true_not_false : isFalse T = false := rfl
     (file: FINAL/Logic/ParaconsistentParadox.lean)
  8. `explosion_iff_all_true` : theorem explosion_iff_all_true {S : Type*} (T : ParaconsistentTheory S)
     (file: FINAL/Logic/ParadoxAlgebra.lean)
  9. `godel_like_con_iff` : theorem godel_like_con_iff (T : LevelTheory) (_G : GodelLike T) :
     (file: FINAL/Logic/StratifiedSelfReference.lean)
  10. `eval_not_and` : theorem eval_not_and {n : ℕ} (C₁ C₂ : BoolCircuit n) (x : Fin n → Bool) :
     (file: Logic/CircuitComplexityBarriers.lean)
  11. `entangled_harder_than_independent` : theorem entangled_harder_than_independent {k : ℕ} (hk : 0 < k)
     (file: Logic/EntanglementDifficulty.lean)
  12. `transfinite_chess_conjecture_true` : theorem transfinite_chess_conjecture_true : transfinite_chess_conjecture := by
     (file: Logic/InfiniteChess.lean)
  13. `not_mem_of_positive_novelty` : theorem not_mem_of_positive_novelty
     (file: Logic/NoveltyCertification.lean)
  14. `OracleHierarchy.con_unprovable_le` : theorem OracleHierarchy.con_unprovable_le (H : OracleHierarchy) (k m : ℕ) (hm : m ≤ k) :
     (file: Logic/OracleClosureAlgebra.lean)
  15. `true_not_false` : theorem true_not_false : isFalse T = false := rfl
     (file: Logic/ParaconsistentParadox.lean)


### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## Aether Research Journal

### Recent Activity
- Q=0.36 [Shared] EML Information Geometry: Fisher Information of ex
- Q=0.67 [EML] Surreal Topology: What Topology Does the Field of 
- Q=0.69 [Bridges] Bridge: Noncommutative Geometry as a Generalizatio

### Active Research Threads
- [Bridges] Bridge: Noncommutative Geometry as a Generalizatio Q=0.69
- [EML] Surreal Topology: What Topology Does the Field of  Q=0.67
- [Shared] EML Information Geometry: Fisher Information of ex Q=0.36


            ## Known Barriers & Impossibility Results

The following theorems from Aether's Catalog constrain what proof approaches are possible. Consider these as strong warnings — they do not make the task impossible, but any approach must account for them.

- **OracleClosureAlgebra** (Logic): Contains 'unprovable' — - `IncompletenessKernel` — The set of sentences that remain unprovable at each l
- **OracleClosureAlgebra** (Logic): Contains 'unreachable' — sentences are permanently unreachable, the conjecture fails. -/
- **barrier_gap_positive** (Logic): Contains 'barrier' — /-- If a barrier is tight and blocks a target, then the gap between
- **strict_optimizer_reaches_fixed_point** (Logic): Contains 'cannot' — and ordinals cannot have an infinite strictly decreasing sequence.
- **int_countable** (Logic): Contains 'impossibility' — theorem clock_impossibility : ¬ ∃ f : ℤ → ℝ, Surjective f := by
- **second_incompleteness** (Logic): Contains 'incompleteness' — theorem second_incompleteness {α : Type*} (M : GLFrame) (V : α → M.W → Prop)
- **tangling_inevitable** (Logic): Contains 'incompleteness' — -- Apply the second incompleteness theorem to the standard world.
- **tangling_dichotomy** (Logic): Contains 'cannot' — soundness it cannot prove — the system is necessarily incomplete.
            ## Recommended Proof Strategies

The following proof techniques have been effective in this domain. Consider using them if applicable:

- **construction**: 
- **induction**: 
- **completeness**: 
- **bijection**: 

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

Research domain: Logic
Research mode: team
