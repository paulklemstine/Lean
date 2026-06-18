            ## Assignment: Foundational algebraic framework for the GL₁

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
            # Future Directions

## Synthesis

This research cycle established the foundational algebraic framework for the GL₁ Langlands correspondence, formalizing the "shape-color" dictionary between quadratic fields and Dirichlet characters. The key discovery is that the correspondence has a natural *bilinear* structure: the Jacobi symbol is simultaneously multiplicative in both arguments, making it a bilinear pairing on ℤ × ℕ. Combined with quadratic reciprocity (reformulated as shape-color duality), this reveals the Jacobi symbol as a self-dual bilinear form with a computable correction sign.

The most promising cross-domain connection is between the `ShapeColorPairing` abstraction and the existing algebraic structures in the Catalog. The `berggren_quadratic_form_invariant` (from `Cryptography/DiophantineCryptoCore.lean`) preserves a Lorentzian quadratic form — and the Jacobi symbol is itself a quadratic form on ℤ/pℤ. This suggests a bridge between Pythagorean triple enumeration (Berggren trees) and the splitting behavior of primes in quadratic fields: both are governed by quadratic forms over ℤ. The `prime_one_mod_four_has_sum_two_squares` theorem (from `Pythagorean/TropicalBerggrenZeta.lean`) is directly related — primes p ≡ 1 (mod 4) split in ℤ[i], and this splitting is detected by χ₋₄(p) = +1.

The highest-breakthrough-potential direction is **Direction 1** (GL₂ Shape-Color), because formalizing even a fragment of the modularity theorem would connect the Catalog's algebraic infrastructure to deep number theory. Direction 3 (Quadratic Form Duality Bridge) has the best near-term payoff by unifying existing Catalog results.

---

### Direction 1: GL₂ Shape-Color Correspondence via Modular Arithmetic

**Conjecture**: For every elliptic curve E over ℚ with conductor N ≤ 100, the number of points |E(𝔽_p)| = p + 1 - a_p satisfies a_p = a_p(f) where f is the unique normalized weight-2 newform of level N. Specifically, a_p can be recovered from the q-expansion coefficients of 

            ### Mathematical Framing
            # Future Directions

## Synthesis

This research cycle established the foundational algebraic framework for the GL₁ Langlands correspondence, formalizing the "shape-color" dictionary between quadratic fields and Dirichlet characters. The key discovery is that the correspondence has a natural *bilinear* structure: the Jacobi symbol is simultaneously multiplicative in both arguments, making it a bilinear pairing on ℤ × ℕ. Combined with quadratic reciprocity (reformulated as shape-color duality), this reveals the Jacobi symbol as a self-dual bilinear form with a computable correction sign.

The most promising cross-domain connection is between the `ShapeColorPairing` abstraction and the existing algebraic structures in the Catalog. The `berggren_quadratic_form_invariant` (from `Cryptography/DiophantineCryptoCore.lean`) preserves a Lorentzian quadratic form — and the Jacobi symbol is itself a quadratic form on ℤ/pℤ. This suggests a bridge between Pythagorean triple enumeration (Berggren tr


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `berggren_gen_preserves_pythagorean` : theorem berggren_gen_preserves_pythagorean (g : Fin 3) (t : Fin 3 → ℤ)
     (file: Cryptography/BerggrenFingerprintRigidity.lean)
  2. `berggren_preserves_primitive_triple` : theorem berggren_preserves_primitive_triple
     (file: Cryptography/BerggrenPostQuantumLattices.lean)
  3. `berggren_key_security_from_minEntropy` : theorem berggren_key_security_from_minEntropy
     (file: Cryptography/BerggrenPythagoreanLattices.lean)
  4. `berggren_gen_preserves_pythagorean` : theorem berggren_gen_preserves_pythagorean (g : Fin 3) (t : Fin 3 → ℤ)
     (file: Cryptography/BerggrenSpectralHash.lean)
  5. `berggren_quadratic_form_invariant` : theorem berggren_quadratic_form_invariant (i : Fin 3) (v : Fin 3 → ℤ) :
     (file: Cryptography/DiophantineCryptoCore.lean)
  6. `berggren_normal_form_exists_unique` : theorem berggren_normal_form_exists_unique (t : ℤ × ℤ × ℤ) :
     (file: Cryptography/Freeness.lean)
  7. `berggren_gen_preserves_pythagorean` : theorem berggren_gen_preserves_pythagorean (g : Fin 3) (t : Fin 3 → ℤ)
     (file: FINAL/Cryptography/BerggrenFingerprintRigidity.lean)
  8. `berggren_preserves_primitive_triple` : theorem berggren_preserves_primitive_triple
     (file: FINAL/Cryptography/BerggrenPostQuantumLattices.lean)
  9. `berggren_key_security_from_minEntropy` : theorem berggren_key_security_from_minEntropy
     (file: FINAL/Cryptography/BerggrenPythagoreanLattices.lean)
  10. `berggren_gen_preserves_pythagorean` : theorem berggren_gen_preserves_pythagorean (g : Fin 3) (t : Fin 3 → ℤ)
     (file: FINAL/Cryptography/BerggrenSpectralHash.lean)
  11. `berggren_quadratic_form_invariant` : theorem berggren_quadratic_form_invariant (i : Fin 3) (v : Fin 3 → ℤ) :
     (file: FINAL/Cryptography/DiophantineCryptoCore.lean)
  12. `berggren_normal_form_exists_unique` : theorem berggren_normal_form_exists_unique (t : ℤ × ℤ × ℤ) :
     (file: FINAL/Cryptography/Freeness.lean)
  13. `berggren_preserves_bilinear` : theorem berggren_preserves_bilinear (j : Fin 3) (u v : Fin 3 → ℤ) :
     (file: Cryptography/BerggrenSymplecticCodes.lean)
  14. `berggren_preserves_bilinear` : theorem berggren_preserves_bilinear (j : Fin 3) (u v : Fin 3 → ℤ) :
     (file: FINAL/Cryptography/BerggrenSymplecticCodes.lean)
  15. `berggren_preserves_pythagorean_mod` : theorem berggren_preserves_pythagorean_mod (m : ℕ) [NeZero m]
     (file: FINAL/Pythagorean/BerggrenDynamicsArithmetic.lean)

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

Research domain: Cryptography
Research mode: team
