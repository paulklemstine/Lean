# Future Directions: Bisimulation Cohomology

## Synthesis

The results established in this cycle—H⁰ classification, H¹ obstruction detection, and the minimal witness theorem—open a systematic research program connecting concurrency semantics to cohomological algebra. The depth-equivalence filtration provides a natural grading that organizes behavioral distinctions by observational complexity. The five directions below form a coherent progression: Direction 1 extends the filtration to higher dimensions, Direction 2 establishes structural vanishing conditions, Direction 3 connects to the categorical infrastructure already in the catalog, Direction 4 extends to richer system models, and Direction 5 pursues the grand challenge of a full spectral sequence. Together, they would establish **cohomological concurrency** as a self-contained mathematical discipline.

---

## Direction 1: Higher Cohomological Obstructions (H² and Beyond)

**Conjecture.** For every n ≥ 0, there exists a finite LTS Pₙ and a meaningful n-th cohomological obstruction Hⁿ that detects a behavioral distinction invisible to H⁰, H¹, ..., Hⁿ⁻¹. Specifically, Hⁿ measures the failure of depth-(n+1) equivalent states to be depth-(n+2) equivalent, conditioned on agreement at all lower depths.

**Test.** Define a cochain complex C⁰ → C¹ → C² where Cⁿ consists of families of local identifications indexed by n-fold overlaps in the depth filtration. Compute H² for all 4-state unary-action LTS. A single system with nontrivial H² that has trivial H¹ would confirm the conjecture.

**Impact.** This would establish a full cohomological hierarchy for behavioral equivalence, analogous to the singular cohomology of topological spaces.

**Catalog References.**
- `Pythagorean/YonedaBisimulation/BisimCohomology.lean` — Cocycle1, LocalBisimDatum
- `Pythagorean/YonedaBisimulation/Defs.lean` — LTS, TraceAccepted

**Proof Strategy.** Define Cⁿ as the group of functions from n-tuples of overlapping depth-level patches to identification data. The coboundary map δⁿ alternates restrictions. The key lemma is that δⁿ⁺¹ ∘ δⁿ = 0.

**Domain Bridges.** Algebraic topology (singular cohomology), homological algebra (cochain complexes).

**Lineage.** Direct extension of the Cocycle1 structure in BisimCohomology.lean.

**Ambition.** 🔴 Grand Challenge — Would establish a full invariant theory for process spaces.

---

## Direction 2: Vanishing Theorems for Acyclic Experiment Covers

**Conjecture.** If the nerve of the experiment-overlap structure (for a chosen finite cover of the experiment category) is acyclic (contractible), then all 1-cocycles are coboundaries: H¹ = 0.

**Test.** Generate experiment covers for 3-, 4-, and 5-state LTS. Compute the nerve (simplicial complex of overlapping patches). For each cover with acyclic nerve, verify that H¹ vanishes. A counterexample with acyclic nerve and nontrivial H¹ would refute the conjecture.

**Impact.** This would be the concurrency analogue of the Leray acyclicity theorem and would provide a structural criterion for when local testing suffices for global equivalence.

**Catalog References.**
- `Pythagorean/YonedaBisimulation/BisimCohomology.lean` — depth filtration, cocycles
- `Pythagorean/YonedaBisimulation/Defs.lean` — reachableViaTrace (nerve construction)

**Proof Strategy.** Model the depth filtration as a simplicial set. Use the nerve lemma: if the cover is "good" (all finite intersections are contractible), the Čech cohomology agrees with the simplicial cohomology, which vanishes for contractible nerves.

**Domain Bridges.** Algebraic topology (Leray theorem, nerve lemma), combinatorics (simplicial complexes).

**Lineage.** Extends witness_nontrivial_cocycle to a structural characterization.

**Ambition.** 🟡 Solid Extension — Directly testable and builds on existing infrastructure.

---

## Direction 3: Sheaf Cohomology via the Experiment Category

**Conjecture.** The nervePresheaf construction (from the catalog's experiment-category framework) supports a derived-functor cohomology theory whose H⁰ recovers bisimulation classes for image-finite LTS, and whose H¹ recovers the depth-filtration obstruction.

**Test.** Formalize the experiment category as a site (with a Grothendieck topology given by trace-extension covers). Compute the Čech cohomology of the nervePresheaf for the witness system. Verify that it matches the depth-filtration H¹.

**Impact.** This would unify the ad hoc depth-filtration construction with the categorical framework, connecting bisimulation cohomology to mainstream sheaf theory.

**Catalog References.**
- `Pythagorean/YonedaBisimulation/Defs.lean` — nervePresheaf-adjacent constructions (reachableViaTrace)
- `Pythagorean/YonedaBisimulation/Correspondence.lean` — yoneda_bisim_det_iff
- `Pythagorean/YonedaBisimulation/BisimCohomology.lean` — canonicalDatum, all_depth_equiv_iff_trace_equiv

**Proof Strategy.** Define the experiment site using Mathlib's `CategoryTheory.Sites` machinery. The key is the topology: a sieve S on experiment U is covering if every trace extending U factors through some member of S. Then sections of the nervePresheaf are observation-compatible families, and H⁰ = global sections = trace equivalence classes.

**Domain Bridges.** Category theory (Grothendieck topologies, sites), algebraic geometry (sheaf cohomology).

**Lineage.** Connects BisimCohomology to the Yoneda-Bisimulation Correspondence.

**Ambition.** 🟡 Solid Extension — Requires significant Mathlib infrastructure but is conceptually clear.

---

## Direction 4: Probabilistic and Weighted Bisimulation Cohomology

**Conjecture.** The depth-filtration framework extends to probabilistic LTS (Markov chains) with a real-valued cohomology: H¹ takes values in ℝ≥0 and measures the maximum total-variation distance between local identification distributions and their global extensions.

**Test.** Define probabilistic depth-equivalence (agreement on trace *probabilities* up to depth n). Compute the filtration for random 3-state Markov chains. Verify that the real-valued H¹ is zero iff probabilistic bisimulation holds.

**Impact.** This would extend cohomological concurrency to the probabilistic setting, with immediate applications to randomized protocol verification and stochastic model checking.

**Catalog References.**
- `Pythagorean/YonedaBisimulation/BisimCohomology.lean` — DepthEquiv (to be generalized)
- `Pythagorean/YonedaBisimulation/Defs.lean` — LTS (to be extended with probability)

**Proof Strategy.** Replace the Boolean-valued depth equivalence with a metric: d_n(s, t) = sup_{|σ|≤n} |Pr[s accepts σ] - Pr[t accepts σ]|. The cohomological obstruction becomes the infimum of d_∞ over all couplings that agree with the depth-n marginals.

**Domain Bridges.** Probability theory (coupling, total variation), optimal transport, stochastic processes.

**Lineage.** New direction branching from the discrete framework.

**Ambition.** 🟡 Solid Extension — Well-motivated by applications, mathematically tractable.

---

## Direction 5: Spectral Sequence from Depth Filtration to Bisimulation

**Conjecture.** The depth-equivalence filtration gives rise to a convergent spectral sequence E_r^{p,q} whose E_∞ page computes the graded pieces of a filtration on the bisimulation quotient. The d₁ differential is the depth-refinement map, and nontrivial H¹ classes appear as surviving elements on the E₂ page.

**Test.** Compute E₁ and E₂ pages for the witness system and for larger (4-5 state) systems. Verify convergence. Check that the E₂ page correctly predicts bisimulation classes.

**Impact.** This would be the crown jewel of cohomological concurrency: a spectral sequence that systematically computes behavioral equivalence from local data, with each page providing successively finer approximations.

**Catalog References.**
- `Pythagorean/YonedaBisimulation/BisimCohomology.lean` — full depth filtration
- `Pythagorean/YonedaBisimulation/Properties.lean` — bisimUnion_is_bisimulation

**Proof Strategy.** The filtration F^n = ker(bisim quotient → depth-n quotient) defines a decreasing filtration on the space of identifications. The spectral sequence of a filtered complex [Wei94, Ch. 5] applies directly. The main content is proving convergence for finite systems (which should follow from stabilization of the depth filtration).

**Domain Bridges.** Homological algebra (spectral sequences), algebraic topology (Serre spectral sequence), algebraic geometry (Grothendieck spectral sequence).

**Lineage.** Culmination of Directions 1-3.

**Ambition.** 🔴 Grand Challenge — Would place cohomological concurrency on the same footing as sheaf cohomology in algebraic geometry.
