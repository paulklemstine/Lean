# Future Directions: Spectral Universality of Neural Tangent Kernels on Arithmetic Expanders

The file `Catalog/MachineLearning/ArithmeticExpanderNTKUniversality.lean` formalizes the
rigorous algebraic core of the *spectral universality* conjecture for graph neural
tangent kernels (NTKs). It establishes, with fully machine-checked proofs (zero `sorry`,
only the standard `propext / Classical.choice / Quot.sound` axioms):

* a lazy-regime graph NTK is an analytic function of the degree-normalized graph
  operator, `K = Σ_k c_k (A/d)^k` (`graphNTK`);
* `K` is diagonalized by the adjacency eigenbasis and acts on a mode of normalized
  eigenvalue `ρ` by the *universal symbol* `ntkSymbol c N ρ = Σ_k c_k ρ^k`
  (`graphNTK_mulVec_eigen`);
* therefore two non-isomorphic graphs sharing a nontrivial eigenvalue produce identical
  NTK eigenvalues — *construction independence* (`graphNTK_eigenvalue_universal`);
* the degree-normalized trivial (constant) mode is pinned to eigenvalue `1`
  (`regular_const_eigen`);
* gradient-descent residuals along a mode decay *exactly* like `(1 - η·symbol)^t`
  (`expander_ntk_training_decay`), and the worst-case bound `(1 - gap)^t` is monotone in
  the spectral gap (`spectral_gap_scaling`).

These bridge `MachineLearning.NTKCore`/`NTKSpectral` (learning dynamics) to the
arithmetic-graph-theory picture of expander spectra (`Algebra.ClassicalGroupExpanders`,
`Algebra.ExpanderWalk`). Below are the most promising falsifiable extensions.

## Direction 1 — Quantitative spectral-perturbation universality

So far universality is stated for an *exactly* shared eigenvalue `ρ`. Real expander
families only *match asymptotically*: their spectra converge to a common limiting
measure (e.g. Kesten–McKay for random `d`-regular graphs). The conjecture to formalize is
a Lipschitz bound: if `‖A₁/d - A₂/d‖ ≤ δ` on the nontrivial subspace, then the NTK
eigenvalues differ by at most `L(c,N)·δ`, with `L` the Lipschitz constant of the symbol
polynomial on `[-1,1]`.

The key insight is that `ntkSymbol c N` is a *fixed polynomial* independent of the graph,
so its modulus of continuity transfers spectral closeness directly into NTK closeness —
universality is just continuity of a single scalar function applied to a converging
spectrum. Why now? `graphNTK_mulVec_eigen` already reduces the operator question to the
scalar symbol, so the remaining work is a clean real-analysis estimate (polynomial
Lipschitz bounds are in Mathlib), making this immediately attackable by the prover.

## Direction 2 — The spectral-gap scaling law as a genuine generalization bound

`spectral_gap_scaling` currently bounds a single nontrivial mode. The full conjecture is a
*test-error* scaling law: for a bandlimited target supported on modes with `|ρ| ≤ 1-gap`,
the kernel-regression generalization error after `t` steps is `Θ((1-gap)^{2t})·‖signal‖²`,
summed over the nontrivial spectrum using an orthonormal eigenbasis.

The key insight is that, given an orthonormal adjacency eigenbasis, the residual decomposes
into independent per-mode geometric decays controlled by the *same* symbol, so the global
error is a spectrally-weighted sum of `spectral_gap_scaling` terms — no cross-mode
interaction survives in the lazy regime. Why now? Mathlib's `Matrix.IsHermitian` spectral
theorem and `NTKSpectral.gdResidual_eigenvector` give exactly the per-mode decomposition
needed; the missing piece is Parseval summation over the eigenbasis, which is standard.

## Direction 3 — Architecture independence across symbol families

The symbol `ntkSymbol c N ρ` depends on the coefficients `c` (depth, activation, residual
structure). Conjecture: for two architectures whose symbols agree on the limiting spectral
support, *all* downstream NTK predictions coincide — i.e. only the restriction of the symbol
to `supp(spectral measure)` is observable.

The key insight is that the NTK operator is determined by the pair (spectrum, symbol)
*only through their composition*; distinct `(c,N)` that induce the same function on the
support are operationally identical, turning "architecture choice" into an equivalence class
of symbols. Why now? The decomposition `graphNTK = Σ c_k (A/d)^k` plus
`graphNTK_mulVec_eigen` already exhibit the kernel as `symbol ∘ spectrum`, so the
equivalence is a quotient statement provable by congruence of the symbol on the support.

## Direction 4 — Ramanujan optimality of the scaling constant

Among `d`-regular graphs the Alon–Boppana bound forces the nontrivial spectral radius to be
`≥ 2√(d-1)/d - o(1)`; Ramanujan graphs saturate it. Conjecture: Ramanujan expanders minimize
the lazy-training worst-case NTK error bound `(1-gap)^t` within the `d`-regular family, and
the optimum value is `(1 - (1 - 2√(d-1)/d))^t = (2√(d-1)/d)^t` asymptotically.

The key insight is that `spectral_gap_scaling`'s monotonicity means *maximizing the gap* is
exactly *minimizing the error bound*, so the extremal-graph (Ramanujan) optimum for the gap
transfers verbatim to a learning-theoretic optimum — connecting an arithmetic extremal
property to an architecture-independent training guarantee. Why now? The monotonicity is
already proved; combining it with an Alon–Boppana statement (a natural next catalog target in
`Algebra.ClassicalGroupExpanders`) yields the optimality corollary with little extra work.

## Direction 5 — Beyond lazy training: feature-learning corrections

The universality proved here is exact only in the lazy/linearized regime where the kernel is
a fixed function of `A/d`. Conjecture: the leading finite-width correction breaks universality
by a term proportional to the *graph-construction-dependent* fourth spectral moment (a
discrepancy invisible to the limiting measure), giving a falsifiable `O(1/width)` deviation
between matched families.

The key insight is that the first place graph identity can re-enter is through higher moments
not fixed by the limiting spectral density, so universality should fail at precisely the order
where the empirical NTK stops being a polynomial in `A/d` alone. Why now? The present results
isolate the exact-universality regime cleanly, making it possible to define the correction as
the *defect* from `graphNTK_mulVec_eigen` and to state its scaling as a sharp, testable
inequality.
