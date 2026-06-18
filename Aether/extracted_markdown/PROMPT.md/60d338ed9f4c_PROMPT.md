
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
- NO `ARTICLE.md`
- NO `RESEARCH_PAPER.md`
- NO `demo.py` / `algorithms.py`
- NO HTML widgets
- NO `PACKAGE.json`
- NO prose for human readers (except FUTURE_DIRECTIONS.md)

### WHY THIS NARROW:
The Lean 4 file IS the deliverable. A self-contained Lean file with
3-5 world-class theorems is worth more than 30K characters of prose
about trivial results. Focus 100% of your compute on the math.
If your work is genuinely world-class, the packaging step is dispatched
automatically and cheaply.


## Concept

**Title**: **Simulation Morphism Algebra** — a formal algebraic f
**Domain**: Algebra
**Mathematical framing**: # Future Directions

## Synthesis

This cycle introduced the **Simulation Morphism Algebra** — a formal algebraic framework for studying simulation relationships between discrete dynamical systems. The central contribution is the `SimMorphism` structure, which captures simulation as an injective encoding intertwining dynamics up to time dilation, together with the proof that these morphisms compose with multiplicative overhead. The **simulation spectrum** (set of achievable self-simulation dilations) was shown to form a multiplicative submonoid of ℕ, providing a novel algebraic invariant of dynamical systems.

The most promising cross-domain connection is between this simulation algebra and the existing tropical Game of Life formalization in `Computation/TropicalLife/Basic.lean`. The tropical Life automaton is defined on finite tori with threshold-based update rules expressed through min-plus primitives. A natural next step is to construct explicit `SimMorphism` instances between the tropical Life automaton and classical Boolean Life, and between different torus sizes, yielding concrete dilation bounds. The existing `turing_simulation_width_bound` in `Tropical/TropicalDeepResearch.lean` provides width bounds that could be connected to spatial overhead in our framework.

The highest breakthrough potential lies in **Direction 1**: proving that the simulation spectrum characterizes computational universality. If the spectrum of a Turing-complete system is provably cofinite, this would give a purely algebraic criterion for universality — avoiding the traditional construction-heavy proofs entirely. The existing `berggren_orbit_turing_complete` result in `Pythagorean/BerggrenCA.lean` provides a starting point for testing this conjecture on specific systems.

---

### Direction 1: Spectral Characterization of Turing Completeness

**Conjecture**: A dynamical system D (with decidable equality on finite-state projections) is Turing complete if and only if its simulation spectrum SimSpectrum(D) is cofinite (i.e., contains all sufficiently large natural numbers). More precisely: if D can simulate every 2-tag system via some SimMorphism, then for all sufficiently large n ∈ ℕ, there exists a self-simulation morphism with dilation n.

**Test**: Compute the simulation spectrum (restricted to block-code encodings) for Rule 110 on grids of size N = 10, 20, 50, 100. Check whether the fraction of {1,...,N} contained in the spectrum approaches 1 as N grows. As a negative control, compute the spectrum for Rule 0 (trivial dynamics) and verify it equals {1}.

**Impact**: If true, this gives a purely algebraic characterization of Turing completeness that avoids explicit Turing machine constructions. It would connect universality to the multiplicative number theory of simulation spectra. If false, the failure mode reveals what additional structure (beyond spectral richness) is needed for universality.

**Catalog References**: `Novelty/GameOfLife/SimSpectrum.lean` (SimSpectrum definition, multiplicative monoid structure), `FINAL/Pythagorean/BerggrenCA.lean` (berggren_orbit_turing_complete)

**Proof Strategy**: (1) Prove the forward direction first: if D is universal, construct self-simulations for all sufficiently large d by composing the universal simulation with systems of varying complexity. (2) For the converse, show that cofinite spectrum implies the ability to simulate arbitrary tag systems by using the dense set of dilations to "tune" the simulation rate. Key lemma needed: for a universal system, the encoding of any finite-state machine into D has bounded dilation, and self-simulations at nearby dilations can be composed to cover any target.

**Domain Bridges**: Novelty (simulation algebra) ↔ Computation (Turing completeness) ↔ Algebra (multiplicative number theory of spectra)

**Lineage**: Builds on SimSpectrum theory from this cycle and existing universality results.

**Ambition**: grand_challenge

---

### Direction 2: Spatial Overhead Morphisms and the Space-Time Tradeoff Theorem

**Conjecture**: Extend SimMorphism to include a spatial dilation factor σ (measuring how many cells of the target represent one cell of the source). Then for any simulation of a d-dimensional CA by a d-dimensional CA: the product τ · σ^d ≥ C for some constant C depending only on the source system's entropy. In other words, there is a fundamental space-time tradeoff: reducing time overhead requires increasing spatial overhead, and vice versa, with a lower bound governed by information-theoretic quantities.

**Test**: Construct explicit SimMorphisms between Game of Life (2D) variants at different resolutions (e.g., 2×2 block encoding vs. 4×4 block encoding) and measure the τ · σ² product. Compare with the topological entropy of the source system computed via orbit counting on small tori.

**Impact**: This would establish a formal space-time tradeoff theorem for cellular automata simulation, analogous to time-space tradeoffs in Turing machine complexity theory but stated in the language of simulation morphisms. It connects simulation algebra to information theory and ergodic theory.

**Catalog References**: `Novelty/GameOfLife/Defs.lean` (SimMorphism), `Computation/TropicalLife/Basic.lean` (tropical Life on tori), `FINAL/Tropical/TropicalDeepResearch.lean` (turing_simulation_width_bound)

**Proof Strategy**: (1) Extend SimMorphism with a `spatialDilation : ℕ` field and adjust equivariance to account for spatial rescaling. (2) Define topological entropy for finite-state CAs via orbit growth rates. (3) Prove that encode_injective implies σ^d ≥ |source states| / |target states| per cell, giving a lower bound on σ. (4) Combine with the multiplicative dilation theorem to get the space-time tradeoff.

**Domain Bridges**: Novelty (simulation algebra) ↔ Computation (space-time complexity) ↔ Physics (thermodynamic cost of simulation, Landauer's principle)

**Lineage**: Direct extension of SimMorphism framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Simulation Morphisms

**Conjecture**: The tropical Life automaton (defined in `Computation/TropicalLife/Basic.lean` using min-plus threshold functions) and the classical Boolean Game of Life on the same torus are connected by a SimMorphism with dilation 1 when restricted to binary-valued configurations. That is, on binary inputs, the tropical rule and the classical rule agree, and this agreement constitutes a formal simulation morphism.

**Test**: Construct the SimMorphism explicitly in Lean by showing that for binary-valued configurations, `tropicalLocalRule` coincides with the classical Life rule. Verify equivariance by checking that `tropicalLifeStep` on binary configs produces binary configs (already proved as `tropicalLifeStep_binary`) and that the values match.

**Impact**: This would bridge the tropical algebra approach to Life with the simulation morphism framework, enabling tropical algebraic tools (min-plus convolution, tropical spectral theory) to be applied to questions about Life's computational universality. It would also validate the tropical threshold encoding as faithful.

**Catalog References**: `Computation/TropicalLife/Basic.lean` (tropicalLifeStep, tropicalLocalRule, tropicalLifeStep_binary), `Computation/StillLife.lean` (block_is_still_life), `Novelty/GameOfLife/Defs.lean` (SimMorphism)

**Proof Strategy**: (1) Define the classical Boolean Life rule on the same Cell/Config types. (2) Prove pointwise agreement with tropicalLocalRule on binary configs by case analysis on the neighborhood sum (values 0-8) and alive/dead status. (3) Package the inclusion of binary configs as a subsystem and construct SimMorphism using `subsystemSimMorphism` with the agreement lemma.

**Domain Bridges**: Novelty (simulation algebra) ↔ Tropical (min-plus algebra) ↔ Computation (Game of Life dynamics)

**Lineage**: Builds on tropical Life formalization in Computation/TropicalLife and SimMorphism framework from this cycle.

**Ambition**: extension

---

### Direction 4: Simulation Morphism Category and Functorial Invariants

**Conjecture**: The collection of all discrete dynamical systems with simulation morphisms forms a category (SimCat) where the dilation function d : Mor(SimCat) → (ℕ, ·) is a faithful functor to the multiplicative monoid of natural numbers. Furthermore, the simulation spectrum functor SimSpectrum : Ob(SimCat) → SubMonoid(ℕ) is a contravariant invariant: if there exists a SimMorphism from A to B, then SimSpectrum(A) ⊆ SimSpectrum(B) (up to multiplication by the dilation).

**Test**: Formalize SimCat as a Lean 4 Category instance (using Mathlib's category theory library). Verify the functor laws. Test the containment conjecture on explicit examples: compute SimSpectrum for the identity system, shift systems, and Rule 110 on small grids.

**Impact**: Embedding simulation theory into category theory unlocks powerful abstract machinery: limits, colimits, adjunctions, and natural transformations all become available for reasoning about simulation. The spectrum functor would be a computable invariant that distinguishes dynamical systems up to simulation equivalence.

**Catalog References**: `Novelty/GameOfLife/Defs.lean` (SimMorphism, SimMorphism.comp, SimMorphism.id), `Novelty/GameOfLife/SimSpectrum.lean` (SimSpectrum, multiplicative monoid structure)

**Proof Strategy**: (1) Define SimCat using Mathlib's `CategoryStruct` and `Category` typeclasses. (2) Verify identity and associativity laws (identity is proved; associativity of composition needs a short proof). (3) Define the dilation functor and verify functoriality. (4) Prove the spectrum containment result by composing self-simulations with the inter-system morphism.

**Domain Bridges**: Novelty (simulation algebra) ↔ Algebra (category theory) ↔ Computation (complexity invariants)

**Lineage**: Direct categorical upgrade of the SimMorphism framework from this cycle.

**Ambition**: extension

---

### Direction 5: Reversible Simulation and Thermodynamic Cost

**Conjecture**: For reversible cellular automata (where the step function is bijective), the simulation spectrum is always a group (closed under division when it divides). Moreover, simulating an irreversible CA by a reversible CA requires a strict dilation overhead of at least 2 — there is no dilation-1 reversible simulation of any irreversible CA.

**Test**: (1) Construct the reversible Critters rule (a known reversible 2D CA) and compute its simulation spectrum. Verify group closure. (2) Attempt to construct a SimMorphism from Game of Life to Critters with dilation 1 and verify it fails. (3) Prove the dilation ≥ 2 lower bound using information-theoretic arguments about surjectivity of the step function.

**Impact**: This connects simulation algebra to the thermodynamics of computation (Landauer's principle). The dilation lower bound for irreversible → reversible simulation has implications for the energy cost of universal computation in physical implementations.

**Catalog References**: `Computation/ReversibleSortingBennett.lean`, `Computation/ReversibleTropicalMachine.lean`, `Novelty/GameOfLife/Defs.lean` (SimMorphism)

**Proof Strategy**: (1) Add a `Bijective` hypothesis to the step function and show that SimMorphism.comp preserves bijectivity of the step function restricted to the image. (2) For the irreversibility barrier: if src.step is not injective (two states map to the same), then any SimMorphism must map these to distinct target states, imposing constraints on the dilation. (3) Formalize the cardinality argument: on finite grids, |im(step)| < |State| for irreversible CAs, which forces the encoding to "spread" information, requiring dilation ≥ 2.

**Domain Bridges**: Novelty (simulation algebra) ↔ Physics (thermodynamic computation) ↔ Computation (reversible computing)

**Lineage**: Extends SimMorphism to the reversible setting, building on existing reversible computation formalizations.

**Ambition**: extension

**Concept description**: # Future Directions

## Synthesis

This cycle introduced the **Simulation Morphism Algebra** — a formal algebraic framework for studying simulation relationships between discrete dynamical systems. The central contribution is the `SimMorphism` structure, which captures simulation as an injective encoding intertwining dynamics up to time dilation, together with the proof that these morphisms compose with multiplicative overhead. The **simulation spectrum** (set of achievable self-simulation dilations) was shown to form a multiplicative submonoid of ℕ, providing a novel algebraic invariant of dynamical systems.

The most promising cross-domain connection is between this simulation algebra and the existing tropical Game of Life formalization in `Computation/TropicalLife/Basic.lean`. The tropical Life automaton is defined on finite tori with threshold-based update rules expressed through min-plus primitives. A natural next step is to construct explicit `SimMorphism` instances between the tropical Life automaton and classical Boolean Life, and between different torus sizes, yielding concrete dilation bounds. The existing `turing_simulation_width_bound` in `Tropical/TropicalDeepResearch.lean` provides width bounds that could be connected to spatial overhead in our framework.

The highest breakthrough potential lies in **Direction 1**: proving that the simulation spectrum characterizes computational universality. If the spectrum of a Turing-complete system is provably cofinite, this would give a purely algebraic criterion for universality — avoiding the traditional construction-heavy proofs entirely. The existing `berggren_orbit_turing_complete` result in `Pythagorean/BerggrenCA.lean` provides a starting point for testing this conjecture on specific systems.

---

### Direction 1: Spectral Characterization of Turing Completeness

**Conjecture**: A dynamical system D (with decidable equality on finite-state projections) is Turing complete if and only if its simulation spectrum SimSpectrum(D) is cofinite (i.e., contains all sufficiently large natural numbers). More precisely: if D can simulate every 2-tag system via some SimMorphism, then for all sufficiently large n ∈ ℕ, there exists a self-simulation morphism with dilation n.

**Test**: Compute the simulation spectrum (restricted to block-code encodings) for Rule 110 on grids of size N = 10, 20, 50, 100. Check whether the fraction of {1,...,N} contained in the spectrum approaches 1 as N grows. As a negative control, compute the spectrum for Rule 0 (trivial dynamics) and verify it equals {1}.

**Impact**: If true, this gives a purely algebraic characterization of Turing completeness that avoids explicit Turing machine constructions. It would connect universality to the multiplicative number theory of simulation spectra. If false, the failure mode reveals what additional structure (beyond spectral richness) is needed for universality.

**Catalog References**: `Novelty/GameOfLife/SimSpectrum.lean` (SimSpectrum definition, multiplicative monoid structure), `FINAL/Pythagorean/BerggrenCA.lean` (berggren_orbit_turing_complete)

**Proof Strategy**: (1) Prove the forward direction first: if D is universal, construct self-simulations for all sufficiently large d by composing the universal simulation with systems of varying complexity. (2) For the converse, show that cofinite spectrum implies the ability to simulate arbitrary tag systems by using the dense set of dilations to "tune" the simulation rate. Key lemma needed: for a universal system, the encoding of any finite-state machine into D has bounded dilation, and self-simulations at nearby dilations can be composed to cover any target.

**Domain Bridges**: Novelty (simulation algebra) ↔ Computation (Turing completeness) ↔ Algebra (multiplicative number theory of spectra)

**Lineage**: Builds on SimSpectrum theory from this cycle and existing universality results.

**Ambition**: grand_challenge

---

### Direction 2: Spatial Overhead Morphisms and the Space-Time Tradeoff Theorem

**Conjecture**: Extend SimMorphism to include a spatial dilation factor σ (measuring how many cells of the target represent one cell of the source). Then for any simulation of a d-dimensional CA by a d-dimensional CA: the product τ · σ^d ≥ C for some constant C depending only on the source system's entropy. In other words, there is a fundamental space-time tradeoff: reducing time overhead requires increasing spatial overhead, and vice versa, with a lower bound governed by information-theoretic quantities.

**Test**: Construct explicit SimMorphisms between Game of Life (2D) variants at different resolutions (e.g., 2×2 block encoding vs. 4×4 block encoding) and measure the τ · σ² product. Compare with the topological entropy of the source system computed via orbit counting on small tori.

**Impact**: This would establish a formal space-time tradeoff theorem for cellular automata simulation, analogous to time-space tradeoffs in Turing machine complexity theory but stated in the language of simulation morphisms. It connects simulation algebra to information theory and ergodic theory.

**Catalog References**: `Novelty/GameOfLife/Defs.lean` (SimMorphism), `Computation/TropicalLife/Basic.lean` (tropical Life on tori), `FINAL/Tropical/TropicalDeepResearch.lean` (turing_simulation_width_bound)

**Proof Strategy**: (1) Extend SimMorphism with a `spatialDilation : ℕ` field and adjust equivariance to account for spatial rescaling. (2) Define topological entropy for finite-state CAs via orbit growth rates. (3) Prove that encode_injective implies σ^d ≥ |source states| / |target states| per cell, giving a lower bound on σ. (4) Combine with the multiplicative dilation theorem to get the space-time tradeoff.

**Domain Bridges**: Novelty (simulation algebra) ↔ Computation (space-time complexity) ↔ Physics (thermodynamic cost of simulation, Landauer's principle)

**Lineage**: Direct extension of SimMorphism framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Simulation Morphisms

**Conjecture**: The tropical Life automaton (defined in `Computation/TropicalLife/Basic.lean` using min-plus threshold functions) and the classical Boolean Game of Life on the same torus are connected by a SimMorphism with dilation 1 when restricted to binary-valued configurations. That is, on binary inputs, the tropical rule and the classical rule agree, and this agreement constitutes a formal simulation morphism.

**Test**: Construct the SimMorphism explicitly in Lean by showing that for binary-valued configurations, `tropicalLocalRule` coincides with the classical Life rule. Verify equivariance by checking that `tropicalLifeStep` on binary configs produces binary configs (already proved as `tropicalLifeStep_binary`) and that the values match.

**Impact**: This would bridge the tropical algebra approach to Life with the simulation morphism framework, enabling tropical algebraic tools (min-plus convolution, tropical spectral theory) to be applied to questions about Life's computational universality. It would also validate the tropical threshold encoding as faithful.

**Catalog References**: `Computation/TropicalLife/Basic.lean` (tropicalLifeStep, tropicalLocalRule, tropicalLifeStep_binary), `Computation/StillLife.lean` (block_is_still_life), `Novelty/GameOfLife/Defs.lean` (SimMorphism)

**Proof Strategy**: (1) Define the classical Boolean Life rule on the same Cell/Config types. (2) Prove pointwise agreement with tropicalLocalRule on binary configs by case analysis on the neighborhood sum (values 0-8) and alive/dead status. (3) Package the inclusion of binary configs as a subsystem and construct SimMorphism using `subsystemSimMorphism` with the agreement lemma.

**Domain Bridges**: Novelty (simulation algebra) ↔ Tropical (min-plus algebra) ↔ Computation (Game of Life dynamics)

**Lineage**: Builds on tropical Life formalization in Computation/TropicalLife and SimMorphism framework from this cycle.

**Ambition**: extension

---

### Direction 4: Simulation Morphism Category and Functorial Invariants

**Conjecture**: The collection of all discrete dynamical systems with simulation morphisms forms a category (SimCat) where the dilation function d : Mor(SimCat) → (ℕ, ·) is a faithful functor to the multiplicative monoid of natural numbers. Furthermore, the simulation spectrum functor SimSpectrum : Ob(SimCat) → SubMonoid(ℕ) is a contravariant invariant: if there exists a SimMorphism from A to B, then SimSpectrum(A) ⊆ SimSpectrum(B) (up to multiplication by the dilation).

**Test**: Formalize SimCat as a Lean 4 Category instance (using Mathlib's category theory library). Verify the functor laws. Test the containment conjecture on explicit examples: compute SimSpectrum for the identity system, shift systems, and Rule 110 on small grids.

**Impact**: Embedding simulation theory into category theory unlocks powerful abstract machinery: limits, colimits, adjunctions, and natural transformations all become available for reasoning about simulation. The spectrum functor would be a computable invariant that distinguishes dynamical systems up to simulation equivalence.

**Catalog References**: `Novelty/GameOfLife/Defs.lean` (SimMorphism, SimMorphism.comp, SimMorphism.id), `Novelty/GameOfLife/SimSpectrum.lean` (SimSpectrum, multiplicative monoid structure)

**Proof Strategy**: (1) Define SimCat using Mathlib's `CategoryStruct` and `Category` typeclasses. (2) Verify identity and associativity laws (identity is proved; associativity of composition needs a short proof). (3) Define the dilation functor and verify functoriality. (4) Prove the spectrum containment result by composing self-simulations with the inter-system morphism.

**Domain Bridges**: Novelty (simulation algebra) ↔ Algebra (category theory) ↔ Computation (complexity invariants)

**Lineage**: Direct categorical upgrade of the SimMorphism framework from this cycle.

**Ambition**: extension

---

### Direction 5: Reversible Simulation and Thermodynamic Cost

**Conjecture**: For reversible cellular automata (where the step function is bijective), the simulation spectrum is always a group (closed under division when it divides). Moreover, simulating an irreversible CA by a reversible CA requires a strict dilation overhead of at least 2 — there is no dilation-1 reversible simulation of any irreversible CA.

**Test**: (1) Construct the reversible Critters rule (a known reversible 2D CA) and compute its simulation spectrum. Verify group closure. (2) Attempt to construct a SimMorphism from Game of Life to Critters with dilation 1 and verify it fails. (3) Prove the dilation ≥ 2 lower bound using information-theoretic arguments about surjectivity of the step function.

**Impact**: This connects simulation algebra to the thermodynamics of computation (Landauer's principle). The dilation lower bound for irreversible → reversible simulation has implications for the energy cost of universal computation in physical implementations.

**Catalog References**: `Computation/ReversibleSortingBennett.lean`, `Computation/ReversibleTropicalMachine.lean`, `Novelty/GameOfLife/Defs.lean` (SimMorphism)

**Proof Strategy**: (1) Add a `Bijective` hypothesis to the step function and show that SimMorphism.comp preserves bijectivity of the step function restricted to the image. (2) For the irreversibility barrier: if src.step is not injective (two states map to the same), then any SimMorphism must map these to distinct target states, imposing constraints on the dilation. (3) Formalize the cardinality argument: on finite grids, |im(step)| < |State| for irreversible CAs, which forces the encoding to "spread" information, requiring dilation ≥ 2.

**Domain Bridges**: Novelty (simulation algebra) ↔ Physics (thermodynamic computation) ↔ Computation (reversible computing)

**Lineage**: Extends SimMorphism to the reversible setting, building on existing reversible computation formalizations.

**Ambition**: extension

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Algebra
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
