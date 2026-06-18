            ## Assignment: Formal mathematical foundations for analyzin

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
            # Future Directions: Quantum Walks on Cayley Graphs

## Synthesis

This research cycle established the formal mathematical foundations for analyzing random walks on Cayley graphs, proving the connection between spectral gaps and mixing times, and quantifying the quadratic speedup of quantum walks over classical walks. The central result — that the quantum-to-classical mixing time ratio is universally √|G| — provides a clean, formally verified characterization of quantum advantage for structured random walks on finite groups.

The most promising cross-domain connection emerging from this cycle is the bridge between **group theory** (Cayley graph structure), **spectral theory** (eigenvalue analysis of transition matrices), and **quantum computation** (unitary evolution and interference). The entropy production rate definition (γ·log(d)) connects these algebraic results to information theory and thermodynamics, suggesting that the spectral gap controls not just mixing speed but also the rate of information generation in random processes.

The highest breakthrough potential lies in Direction 1 (Representation-Theoretic Decomposition), because formalizing how non-abelian group representations decompose the quantum walk into independent channels would unlock the full power of harmonic analysis on groups — the mathematical framework that unifies Fourier analysis, quantum mechanics, and random walks. This would also enable formalizing the Diaconis-Shahshahani upper bound lemma, one of the most powerful tools in the analysis of random walks on groups.

---

### Direction 1: Representation-Theoretic Decomposition of Quantum Walks on Non-Abelian Groups

**Conjecture**: For a finite group G with irreducible representations ρ₁, ..., ρ_k of dimensions d₁, ..., d_k, the quantum walk on Cay(G, S) decomposes into k independent quantum walks on spaces of dimension d_i², and the mixing time is controlled by the representation with the smallest spectral gap: τ_Q = max_i (d_i / gap_i) ·

            ### Mathematical Framing
            # Future Directions: Quantum Walks on Cayley Graphs

## Synthesis

This research cycle established the formal mathematical foundations for analyzing random walks on Cayley graphs, proving the connection between spectral gaps and mixing times, and quantifying the quadratic speedup of quantum walks over classical walks. The central result — that the quantum-to-classical mixing time ratio is universally √|G| — provides a clean, formally verified characterization of quantum advantage for structured random walks on finite groups.

The most promising cross-domain connection emerging from this cycle is the bridge between **group theory** (Cayley graph structure), **spectral theory** (eigenvalue analysis of transition matrices), and **quantum computation** (unitary evolution and interference). The entropy production rate definition (γ·log(d)) connects these algebraic results to information theory and thermodynamics, suggesting that the spectral gap controls not just mixing speed but also the r


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `power_gap_upper_bound` : theorem power_gap_upper_bound (c : ℕ) (n : ℕ) (hn : 1 ≤ n) :
     (file: Bridges/FermatNearMiss.lean)
  2. `quantum_spectral_entropy_bound` : theorem quantum_spectral_entropy_bound (d : ℕ) :
     (file: Bridges/SpectralApplications.lean)
  3. `quantum_spectral_entropy_bound` : theorem quantum_spectral_entropy_bound (d : ℕ) :
     (file: FINAL/Bridges/SpectralApplications.lean)
  4. `mixing_time_from_gap` : theorem mixing_time_from_gap (γ N ε : ℝ) (hγ : 0 < γ) (hN : 2 ≤ N)
     (file: Bridges/StrongRayleighSpectralGap.lean)
  5. `quantum_to_classical_gap_bridge` : theorem quantum_to_classical_gap_bridge
     (file: Bridges/QuantumLorentzianBridge.lean)
  6. `pointwise_log_ratio_bound` : theorem pointwise_log_ratio_bound (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
     (file: Bridges/ContinuousDiscreteTransfer.lean)
  7. `quantum_classical_bound` : theorem quantum_classical_bound (a b : ℝ) :
     (file: Bridges/EMLTropicalSemiring.lean)
  8. `gap_bound_implies_lipschitz_from_localMax` : theorem gap_bound_implies_lipschitz_from_localMax
     (file: Bridges/ExchangeCertifiedApprox.lean)
  9. `abstract_spectral_gap_lower_bound` : theorem abstract_spectral_gap_lower_bound
     (file: Bridges/GL2SpectralDecomposition.lean)
  10. `spectral_bound_quadratic_in_width` : theorem spectral_bound_quadratic_in_width (d w : ℕ) (hd : d ≥ 1) (hw : w ≥ 1) :
     (file: Bridges/GaloisNeuralCorrespondence.lean)
  11. `generalization_gap_dimension_bound` : theorem generalization_gap_dimension_bound
     (file: Bridges/HomologicalDeepLearning.lean)
  12. `regular_graph_eigenvalue_bound` : theorem regular_graph_eigenvalue_bound {n : ℕ} (G : IharaGraph n) (q : ℕ)
     (file: Bridges/IharaZeta.lean)
  13. `size_lower_bound_from_log` : theorem size_lower_bound_from_log (n : ℕ)
     (file: Bridges/MatroidCertificatePhaseTransition.lean)
  14. `quantum_entropy_style_valuation_growth_bound` : theorem quantum_entropy_style_valuation_growth_bound (net : PadicOperadicNetwork K) :
     (file: Bridges/PadicOperadicNetworks.lean)
  15. `post_quantum_security_collision_upper_bound` : theorem post_quantum_security_collision_upper_bound
     (file: Bridges/QuotientOrbitCompression/Core.lean)

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

Research domain: Bridges
Research mode: team
