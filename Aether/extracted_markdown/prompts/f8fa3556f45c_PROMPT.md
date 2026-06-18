            ## Assignment: This research cycle established the foundational framework for a "chemical class

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, rcases, by_contra, field_simp,
   or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.


            ### Research Direction
            # Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established the foundational framework for a "chemical classification" of finite groups, proving nine core theorems that formalize the analogy between Mendeleev's periodic table and finite group theory. The key insight is that the derived series provides a natural "electron configuration" for groups, with the derived length serving as the primary invariant. The cross-domain Euler-Group Bridge theorem (connecting Euler's totient φ(n) to the unit group order |(ℤ/nℤ)ˣ|) demonstrates that number-theoretic properties of the group order directly determine algebraic structure — a connection with immediate applications to cryptography and coding theory.

The most promising cross-domain connection from this cycle is the bridge between group solvability and molecular spectroscopy: the chemical series of a molecule's symmetry group correlates with the complexity of its spectral selection rules. This connection, if formalized, could yield computable predictions about molecular spectra from purely algebraic data. The isotope concept (groups with equal derived length) provides a novel equivalence relation that could unify disparate classification schemes across algebra, combinatorics, and representation theory.

The highest breakthrough potential lies in Direction 1 (formalizing Burnside's theorem), which would close the last remaining sorry in our Lean development and demonstrate that deep character-theoretic results can be machine-verified. Direction 3 (the spectroscopy bridge) has the highest impact potential for cross-domain applications.

---

### Direction 1: Formalizing Burnside's p^a q^b Theorem via Transfer Theory

**Conjecture**: Every finite group of order p^a · q^b, where p and q are primes, is solvable. This is Burnside's theorem (1904), which is known to be true but has never been fully formalized in a proof assistant.

**Test**: Formalize the proof using transfer theory (Ben

            ### Mathematical Framing
            # Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established the foundational framework for a "chemical classification" of finite groups, proving nine core theorems that formalize the analogy between Mendeleev's periodic table and finite group theory. The key insight is that the derived series provides a natural "electron configuration" for groups, with the derived length serving as the primary invariant. The cross-domain Euler-Group Bridge theorem (connecting Euler's totient φ(n) to the unit group order |(ℤ/nℤ)ˣ|) demonstrates that number-theoretic properties of the group order directly determine algebraic structure — a connection with immediate applications to cryptography and coding theory.

The most promising cross-domain connection from this cycle is the bridge between group solvability and molecular spectroscopy: the chemical series of a molecule's symmetry group correlates with the complexity of its spectral selection rules. This connec


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `spectral_width_increases_with_primes` : theorem spectral_width_increases_with_primes (n p : ℕ) (hn : 1 < n)
     (file: Algebra/CausalCertification.lean)
  2. `qdf_symmetry_group_order` : theorem qdf_symmetry_group_order :
     (file: Algebra/QDF_HE_Frontiers.lean)
  3. `spectral_width_increases_with_primes` : theorem spectral_width_increases_with_primes (n p : ℕ) (hn : 1 < n)
     (file: FINAL/Algebra/CausalCertification.lean)
  4. `qdf_symmetry_group_order` : theorem qdf_symmetry_group_order :
     (file: FINAL/Algebra/QDF_HE_Frontiers.lean)
  5. `fundamental_theorem_algebraic_light'` : theorem fundamental_theorem_algebraic_light' (a b c : ℤ) :
     (file: Algebra/UnifyingTheory.lean)
  6. `fundamental_theorem_algebraic_light'` : theorem fundamental_theorem_algebraic_light' (a b c : ℤ) :
     (file: FINAL/Algebra/UnifyingTheory.lean)
  7. `spectral_transfer_iterate_bound` : theorem spectral_transfer_iterate_bound
     (file: Algebra/Apollonian/SpectralTransfer.lean)
  8. `shor_algebraic_core` : theorem shor_algebraic_core (a : ℤ) (r : ℕ) :
     (file: Algebra/ChimeraFactoring.lean)
  9. `commuting_operator_has_invariant_subspace_of_compact_eigenvalue` : theorem commuting_operator_has_invariant_subspace_of_compact_eigenvalue
     (file: Algebra/CompactOperators.lean)
  10. `dlp_order_connection` : theorem dlp_order_connection {G : Type*} [Group G] [Fintype G] (g : G) :
     (file: Algebra/Core/OpenQuestions.lean)
  11. `symmetric_group_order` : theorem symmetric_group_order (n : ℕ) :
     (file: Algebra/FutureExploration.lean)
  12. `algebraic_natural_proofs_barrier` : theorem algebraic_natural_proofs_barrier
     (file: Algebra/GCT/Foundation.lean)
  13. `mersenne_primes_are_light` : theorem mersenne_primes_are_light (p : ℕ) (hp : Nat.Prime p)
     (file: Algebra/LightDarkPrimes.lean)
  14. `singerCycle_has_no_nontrivial_invariant_subspace` : theorem singerCycle_has_no_nontrivial_invariant_subspace
     (file: Algebra/MatrixGroupGeneration.lean)
  15. `galois_connection_theory_variety` : theorem galois_connection_theory_variety {R : Type u} [Semiring R]
     (file: Algebra/ProofSpectra/Core.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


No specific files referenced. Use Mathlib and general knowledge.

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above (FINAL/ entries are vetted, high-quality — prioritize these).

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction.

            ### Anti-Triviality Rules
            Do NOT produce any of the following:
            - Commutativity/associativity proofs for standard algebraic structures
              (e.g., `a + b = b + a` for semirings, `a * b * c = a * (b * c)`)
            - Wrapper theorems that just unwrap a definition without mathematical insight
            - Proofs that are just `by simp` or `by trivial` with no depth
            - Definitions followed by trivial properties that don't advance understanding
            If a result seems obvious, prove something STRONGER — the stronger theorem
            is often easier to prove and more interesting.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md, RESEARCH_PAPER.md,
                      ARTICLE.md (Scientific American style), algorithm, demo.py
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
  `Bridges/AlgebraEMLClosureComputation.lean`: ClosureSemimoduleSystem, ProbeFamily, ClosureStableProbe
  `Bridges/AlgebraEMLReconstruction.lean`: SetClosureOperator, {α, ClosedSet
  `Bridges/AlgebraPythagoreanCryptography/BerggrenLatticeReductionDuality.lean`: PrimTriple, PrimTriple.a_lt_c, PrimTriple.b_lt_c
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
  `EML/ModularForms.lean`: T_sq, S_gen, BM₃_inv

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

            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would confirm
            or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what does
            the failure teach us?
            **Catalog References**: `Bridges.Basic.lean`, `Algebra.QuadraticForms.mordell`
            (Use backtick-enclosed file paths or theorem names from the Catalog.)
            **Proof Strategy**: Outline the key steps or approach. What mathematical
            machinery is needed? What lemmas would need to be established first?
            **Domain Bridges**: NumberTheory <-> Tropical, Algebra <-> Physics
            (List domain pairs this connects, using the <-> connector.)
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

            Soli Deo Gloria.


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

Research domain: Algebra
Research mode: prove
