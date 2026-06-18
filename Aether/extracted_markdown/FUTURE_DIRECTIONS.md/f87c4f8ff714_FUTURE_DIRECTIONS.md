# Future Directions: Closure Kramers–Wannier Duality

## 1. Non-Planar Generalized Kramers–Wannier Duality via Closure Cocircuit Geometries

The classical Kramers–Wannier duality is restricted to planar lattice models. Our closure-based framework naturally extends beyond planarity: the cocircuit separation condition replaces topological planarity with a purely order-theoretic criterion. A concrete next step is to formalize duality for closure interaction structures arising from non-planar hypergraphs, factor graphs on expander-like topologies, and general matroid cocircuit families. This would yield the first rigorous non-planar Kramers–Wannier-type duality theorems, applicable to random graph Ising models, hierarchical lattice models, and mean-field spin systems that lack any planar embedding.

**Concrete milestone:** Formalize duality for the complete graph K_n closure interaction structure and verify that the dual model recovers mean-field Curie–Weiss partition data.

## 2. Functorial Duality for Morphisms of Closure Interaction Systems

The current duality is proved for individual closure interaction structures. A natural categorical extension asks: do structure-preserving morphisms between closure interaction structures induce compatible morphisms between their dual partition semimodules? Specifically, if φ : C → C' is a closure-compatible embedding, does it induce a dual morphism φ* : P*(C') → P*(C) such that the Legendre transform commutes with φ and φ*? Proving naturality would establish the duality as a contravariant functor on the category of finite closure interaction structures, opening the door to sheaf-theoretic and descent methods for gluing local dualities into global ones.

**Concrete milestone:** Define the category of closure interaction structures with energy-preserving morphisms and prove that the tropical Legendre transform is a contravariant endofunctor up to gauge.

## 3. Tropical Free-Energy Variational Principle for Closure Partition Semimodules

In classical statistical mechanics, the free energy is computed as a Legendre transform of the entropy function. Our tropical Legendre transform provides a finite, exact analogue. The next step is to formalize a tropical variational principle: the "tropical free energy" should be the value of the Legendre transform at the equilibrium dual section, and admissible partition sections should minimize this functional subject to closure compatibility constraints. This would connect the bidual recovery theorem to a genuine optimization principle, making the duality operationally useful for computing ground states and phase boundaries in finite interaction models.

**Concrete milestone:** State and prove a tropical minimax theorem for closure partition semimodules, showing that the primal minimum and dual maximum coincide on admissible sections.

## 4. Quantum/Interference Extension via Phase-Enriched Idempotent Partition Objects

The current framework uses ℤ-valued energies and min-plus algebra. A natural extension replaces scalar energies with phase-valued coefficients (elements of a suitable semiring encoding both magnitude and phase), modeling quantum interference rather than classical thermal competition. The appropriate algebraic structure is a "phase-tropical semiring" where addition captures interference (not just minimization) and the Legendre transform generalizes to a finite Fourier-like duality. Success here would yield exact finite dualities for quantum partition functions on closure-structured interaction graphs, connecting to quantum error correction, tensor network contraction, and finite quantum field theories.

**Concrete milestone:** Define a phase-tropical semiring over ℤ[i] (Gaussian integers) and prove that the generalized Legendre transform still satisfies bidual recovery on admissible sections.

## 5. Certified Inverse Factor-Graph Compilation from Semantic Boundary Data

The certified Gibbs reconstruction theorem (Theorem C) shows existence of dual couplings from boundary data. The natural application is a verified compiler: given observed boundary statistics (marginals, correlations, partition function ratios) of a finite system, automatically produce a factor graph with provably correct coupling constants. This turns the mathematical duality into a software tool for inverse problems in machine learning (learning energy-based models), signal processing (Markov random field estimation), and materials science (reconstructing interaction Hamiltonians from scattering data). The key technical challenge is implementing the reconstruction algorithm efficiently and proving its output correct by construction.

**Concrete milestone:** Implement a Lean-verified algorithm that takes a finite table of boundary partition values and outputs a factor graph specification, together with a machine-checked certificate that the factor graph's partition function matches the input data up to gauge.
