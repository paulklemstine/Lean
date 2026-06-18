# Future Directions: Simulation Morphism Algebra

## Synthesis

This cycle introduced the **Simulation Morphism Algebra** — a formal algebraic framework for studying simulation relationships between discrete dynamical systems. The central contribution is the `SimMorphism` structure in `Catalog/Algebra/SimMorphism.lean`, which captures simulation as an injective encoding intertwining dynamics up to time dilation, together with the following fully machine-verified results:

1. **Composition with multiplicative dilation** (`SimMorphism.comp`): If system A simulates B with dilation d₁ and B simulates C with dilation d₂, then A simulates C with dilation d₁ · d₂.
2. **Generalized equivariance** (`SimMorphism.equivariance_iter`): n source steps correspond to n · d target steps through any encoding of dilation d.
3. **Simulation spectrum is a submonoid** (`SimSpectrum.toSubmonoid`): The set of achievable self-simulation dilations contains 1 and is closed under multiplication.
4. **Conjugacy invariance** (`Conjugacy.simSpectrum_eq`): Conjugate dynamical systems have identical simulation spectra.

---

### Direction 1: Spectral Characterization of Computational Complexity

A dynamical system's simulation spectrum — the set of dilations at which it can simulate itself — is now a well-defined algebraic invariant. The key insight is that computationally rich systems should have richer spectra: a Turing-complete system should admit self-simulations at many different time scales, while a trivial system (like the identity) has spectrum exactly {1}. Why now? The submonoid structure is proven, so one can now rigorously state and test whether cofiniteness of the spectrum (containing all sufficiently large naturals) characterizes universality. A concrete test: compute the spectrum of elementary cellular automata (Rule 110 vs Rule 0) on small state spaces and check whether the cofinite/finite dichotomy correlates with known universality results.

### Direction 2: Spatial-Temporal Dilation Tradeoffs

The current framework captures temporal dilation but not spatial overhead. The key insight is that extending `SimMorphism` with a spatial dilation factor σ (number of target cells per source cell) should yield a space-time tradeoff inequality τ · σ^d ≥ C, where C depends on the entropy of the source system and d is the spatial dimension. Why now? The composition theorem (`comp`) already handles the temporal product structure; adding a spatial factor and proving a lower bound via cardinality arguments on the injective encoding would give a formal version of the folklore intuition that "you can't speed up and compress simultaneously." The `encode_injective` hypothesis is exactly what's needed for the cardinality argument.

### Direction 3: Categorical Structure of Simulation

The formalized composition and identity morphisms satisfy the axioms of a category. The key insight is that the dilation assignment d : Mor(SimCat) → (ℕ, ·) is a monoidal functor, and the simulation spectrum is a contravariant invariant: a morphism A → B implies SimSpectrum(A) ⊆ SimSpectrum(B) (up to dilation scaling). Why now? The `comp_dilation` and `id_dilation` simp lemmas already verify the functor laws at the level of dilations. Formalizing this as a Mathlib `Category` instance and proving the spectrum functoriality would connect simulation theory to the rich categorical machinery in Mathlib, enabling arguments via limits, adjunctions, and natural transformations.

### Direction 4: Reversible Simulation Barriers

For reversible dynamical systems (where `step` is bijective), the simulation spectrum should have additional structure — specifically, it should be closed under "division" in a suitable sense. The key insight is that irreversibility creates a fundamental barrier: simulating an irreversible system by a reversible one requires dilation ≥ 2, because the reversible system must encode the lost information somewhere, which takes at least one extra step. Why now? The `reflects_periodic` theorem already shows that injectivity of the encoding allows "reflecting" information from target to source. Adding a bijectivity hypothesis to `step` and proving that it propagates through composition would formalize Bennett's reversible computation theorem in the language of simulation morphisms.

### Direction 5: Tropical Algebra Bridge

The tropical Life automaton (using min-plus threshold functions) and classical Boolean Life should be connected by a SimMorphism with dilation 1 on binary-valued configurations. The key insight is that on {0, 1}-valued inputs, the tropical rule (using min and plus operations) computes the same function as the classical Boolean rule, and this agreement constitutes a formal simulation morphism whose encoding is the inclusion of binary configurations. Why now? The subsystem inclusion morphism (`Subsystem.inclusionMorphism`) is already proven with dilation 1. Constructing the tropical–classical bridge requires only proving pointwise agreement of the two rules on binary inputs, which is a finite case analysis.
