            ## Assignment: Complete formalized algebraic theory of quasif

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
            # Future Directions: Non-Desarguesian Geometry and Beyond

## Synthesis

This research cycle established a complete formalized algebraic theory of quasifield nuclei and their connection to the failure of Desargues' theorem. The key insight is that the nucleus — the subset of elements that associate with all others — provides a quantitative bridge between algebra and geometry: its size controls how many symmetries a projective plane has, and whether Desargues' theorem holds. We proved nucleus closure (the left nucleus is a sub-division-ring), the associativity characterization (three equivalent conditions for Desargues), and a quantitative collineation group bound showing that symmetry loss scales as q⁴ for Hall planes.

The most promising cross-domain connection is between **quasifield defect theory** and **coding theory**. The defect δ(Q) = |Q| - |N_ℓ(Q)| controls both the geometric failure of Desargues and the algebraic distance from a field structure. This same "distance from linearity" appears in the theory of MDS codes, where codes constructed from non-Desarguesian planes have different minimum distance properties. The Catalog's `Cryptography/BerggrenDiophantineLattice.lean` formalization of lattice structures could potentially be extended to capture the lattice of subplanes in a non-Desarguesian plane, where the nucleus chain N_ℓ ⊂ Q provides a natural filtration.

The direction with highest breakthrough potential is **Direction 1** (Artin-Zorn formalization), because proving that prime-order quasifields must be fields would close a major gap in the formal theory and connect directly to Wedderburn's little theorem on finite division rings.

---

### Direction 1: Formalized Artin-Zorn Theorem for Prime-Order Quasifields

**Conjecture**: Every quasifield of prime order p is a field. Equivalently, if Q is a finite quasifield with |Q| = p for p prime, then Q is associative and commutative.

**Test**: Attempt to prove in Lean that for a Quasifield Q with Fintype.ca

            ### Mathematical Framing
            # Future Directions: Non-Desarguesian Geometry and Beyond

## Synthesis

This research cycle established a complete formalized algebraic theory of quasifield nuclei and their connection to the failure of Desargues' theorem. The key insight is that the nucleus — the subset of elements that associate with all others — provides a quantitative bridge between algebra and geometry: its size controls how many symmetries a projective plane has, and whether Desargues' theorem holds. We proved nucleus closure (the left nucleus is a sub-division-ring), the associativity characterization (three equivalent conditions for Desargues), and a quantitative collineation group bound showing that symmetry loss scales as q⁴ for Hall planes.

The most promising cross-domain connection is between **quasifield defect theory** and **coding theory**. The defect δ(Q) = |Q| - |N_ℓ(Q)| controls both the geometric failure of Desargues and the algebraic distance from a field structure. This same "distance from linear


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `finite_filtration_has_bounded_torsion` : theorem finite_filtration_has_bounded_torsion {n : ℕ}
     (file: FINAL/Pythagorean/AdelicPersistentHomology.lean)
  2. `finite_filtration_has_bounded_torsion` : theorem finite_filtration_has_bounded_torsion {n : ℕ}
     (file: Pythagorean/AdelicPersistentHomology.lean)
  3. `root_triple_has_perfect_fourth_and_major_third` : theorem root_triple_has_perfect_fourth_and_major_third :
     (file: FINAL/Pythagorean/HarmonicMusicTheory.lean)
  4. `failure_event_subset_gap_event` : theorem failure_event_subset_gap_event
     (file: FINAL/Pythagorean/SharpGOEConstants.lean)
  5. `hall_plane_order_bound` : theorem hall_plane_order_bound (p : ℕ) (_hp : Nat.Prime p) (k : ℕ) (_hk : 1 ≤ k)
     (file: MachineLearning/NonDesarguesian/Core.lean)
  6. `root_triple_has_perfect_fourth_and_major_third` : theorem root_triple_has_perfect_fourth_and_major_third :
     (file: Pythagorean/HarmonicMusicTheory.lean)
  7. `failure_event_subset_gap_event` : theorem failure_event_subset_gap_event
     (file: Pythagorean/SharpGOEConstants.lean)
  8. `latticeInner_sub_bound_of_coordwise` : theorem latticeInner_sub_bound_of_coordwise
     (file: FINAL/Pythagorean/AlgorithmicLatticeDiophantine.lean)
  9. `triangle_lower_bound_from_sandwich` : theorem triangle_lower_bound_from_sandwich (n : ℕ)
     (file: FINAL/Pythagorean/AsymptoticCompactness.lean)
  10. `spectral_gap_correlation_bound` : theorem spectral_gap_correlation_bound (k : ℕ)
     (file: FINAL/Pythagorean/BerggrenProductGrowth.lean)
  11. `spectral_gap_log_concave_lower_bound` : theorem spectral_gap_log_concave_lower_bound (n : ℕ) (π : ProbDist n)
     (file: FINAL/Pythagorean/CertificateSampling.lean)
  12. `fermion_neg_dep_defect_bound` : theorem fermion_neg_dep_defect_bound {n : ℕ}
     (file: FINAL/Pythagorean/CertifiedFermionSampling.lean)
  13. `linear_defect_growth_bound` : theorem linear_defect_growth_bound
     (file: FINAL/Pythagorean/DoubleScalingWhenDoesmMatter.lean)
  14. `triple_gen_bound_conjecture_statement` : theorem triple_gen_bound_conjecture_statement :
     (file: FINAL/Pythagorean/KTupleMoebiusInversion.lean)
  15. `failure_bound_below_edge` : theorem failure_bound_below_edge {C σ ε n : ℝ} (h : ε ≤ 2 * σ) :
     (file: FINAL/Pythagorean/LorentzianComplexityTransition.lean)

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

Research domain: Pythagorean
Research mode: team
