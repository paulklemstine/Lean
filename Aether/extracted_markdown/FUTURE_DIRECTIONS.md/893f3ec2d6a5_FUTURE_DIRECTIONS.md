# Future Directions: Spectral Chain Framework

## What Was Established

This cycle produced a formally verified framework (`Computation/SpectralChain/`) connecting spectral gaps, conductance, mixing times, and phase transitions in finite reversible Markov chains. All 17 theorems compile without `sorry` and use only standard axioms. The framework spans four mathematical domains:

- **Spectral graph theory**: Dirichlet forms, variance, spectral gaps (Poincaré inequality)
- **Probability**: Total variation distance, mixing time bounds, variance contraction
- **Geometry**: Conductance (Cheeger constant), flow symmetry, weight complement identity
- **Combinatorics**: Phase classification (fast/critical/frozen), monotonicity

The key structural result is the **mixing-divergence bridge** (`mixing_diverges_at_zero_gap`): as the spectral gap approaches zero, the mixing time can be made arbitrarily large. Combined with the mixing time monotonicity theorems and phase classification, this gives a rigorous foundation for studying phase transitions through spectral gaps.

---

## Direction 1: Cheeger's Inequality from First Principles

The discrete Cheeger inequality—`h²/2 ≤ γ ≤ 2h` where h is the conductance and γ the spectral gap—is the most important missing result in the framework. The key insight is that the proof requires constructing a specific "level set" test function from the optimal Cheeger cut, then bounding its Rayleigh quotient. This is fundamentally different from the abstract certification approach used here. Why now? The framework already has `flowOut`, `weight`, `DirichletForm`, `Var`, and the Poincaré inequality structure. The missing piece is the "co-area formula" for finite graphs that relates the Dirichlet form of a function to the flows across its level sets. Formalizing this inequality would complete the conductance → spectral gap link in the chain.

## Direction 2: Geometric Convergence of Markov Chains

The variance contraction theorem—`Var(P^t f) ≤ (1-γ)^{2t} · Var(f)`—quantifies how the spectral gap controls the rate of convergence. The key insight is that this follows from the spectral decomposition of the transition operator in L²(π): the Poincaré inequality implies `‖Pf - E[f]‖² ≤ (1-γ)² ‖f - E[f]‖²`, and iterating gives geometric decay. Why now? The current framework has `applyP`, `Var`, `DirichletForm`, and `poincare_weakening`. Formalizing the L²(π) inner product space structure for reversible chains would unlock the contraction theorem and, more broadly, the full spectral theory of self-adjoint operators on finite-dimensional Hilbert spaces.

## Direction 3: Log-Sobolev Strengthening of Mixing Bounds

The log-Sobolev constant α gives the improved bound `t_mix(ε) ≤ (1/2α) · log log(1/ε)` versus the spectral gap bound `t_mix(ε) ≤ (1/γ) · log(n/ε)`. The key insight is that the relationship α ≤ γ ≤ 2α (for product chains) means the log-Sobolev constant interpolates between spectral and entropic mixing. Why now? The `mixingBound` function and `mixing_bound_scaling` theorem provide the infrastructure for comparing mixing time formulas. A `LogSobolevBound` structure parallel to `SpectralGapCert` could encode the modified log-Sobolev inequality `Ent(f² dμ) ≤ (2/α) E(f,f)`, and the analog of `mixing_diverges_at_zero_gap` for the log-Sobolev constant would quantify the improvement.

## Direction 4: Spectral Gap of Explicit CSP Chains

Computing the spectral gap of the swap Markov chain on small grid puzzles (3×3 Latin squares, 4×4 Shidoku) would provide the first concrete numerical values in the framework. The key insight is that for n ≤ 4, the state space is small enough (≤ 288 solutions for Shidoku) that the transition matrix can be explicitly constructed and its eigenvalues computed via `native_decide` or rational arithmetic. Why now? The `ReversibleChain` and `SpectralGapCert` structures are ready to receive concrete instances. Formalizing even one explicit chain (e.g., the 2-state chain with known gap) would test the framework's usability and provide a template for larger computations.

## Direction 5: Tropical Spectral Gap Bounds

The tropical (min-plus) spectral radius of a non-negative matrix provides combinatorial lower bounds on the classical spectral gap that bypass the worst-case nature of Cheeger's inequality. The key insight is that for structured matrices arising from CSP transition graphs, the tropical eigenvalue (= minimum cycle mean) can be computed in polynomial time via Howard's algorithm, while Cheeger's inequality requires optimizing over exponentially many cuts. Why now? The project already has tropical algebra infrastructure in `Tropical/`. Connecting the `ReversibleChain` type to tropical matrix representations would bridge two existing parts of the codebase and could yield tighter spectral gap lower bounds for specific CSP instances.
