# Future Directions — Hodge Spectral Duality

## Synthesis

The discrete-Hodge program already carried a *geometric/decomposition* layer (split
Dirichlet energy, the discrete Hodge theorem, image orthogonality from `∂∂ = 0`) and an
*operator/solvability* layer (Green operator, resolution identities). This cycle contributes
the **Duality & Representation** layer in
`Catalog/Speculative/AutoResearch/HodgeSpectralDuality.lean`.

It isolates a *single* boundary matrix `D : Matrix (Fin m) (Fin n) ℝ` and exhibits its two
Gram–Laplacians — the up-Laplacian `Dᵀ D` on the source cochains and the down-Laplacian
`D Dᵀ` on the target cochains — as two representations of one spectral object. Everything
flows from one algebraic fact, the intertwining `(D Dᵀ) D = D (Dᵀ D)` (`hodge_intertwine`),
itself just associativity. From the self-dual pairing `hodge_adjunction` (`⟪Dx, y⟫ = ⟪x, Dᵀy⟫`)
and the intertwining we obtain trace duality, two mutually-dual eigenvector dictionaries, and
the capstone set-level isospectrality of the nonzero spectra. This is the discrete avatar of
the analytic fact that a boundary operator `∂` and its adjoint `∂*` share their nonzero
singular values — the representation-theoretic heart of Hodge theory as an elementary,
determinant-free statement over `ℝ`.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `hodge_adjunction` | `⟨Dx, y⟩ = ⟨x, Dᵀy⟩` | the duality pairing intertwining both Laplacians |
| `hodge_intertwine` | `(D Dᵀ) D = D (Dᵀ D)` | the single engine of every transfer |
| `hodge_trace_duality` | `tr(Dᵀ D) = tr(D Dᵀ)` | representation-level invariant (sum of squared singular values) |
| `eigvec_transfer_up_down` | nonzero `μ`-eigvec `v` of `Dᵀ D` ↦ nonzero `μ`-eigvec `Dv` of `D Dᵀ` | forward dictionary |
| `eigvec_transfer_down_up` | dual transfer via `Dᵀ` | backward dictionary |
| `hodge_spectral_duality` | `nonzeroSpectrum (Dᵀ D) = nonzeroSpectrum (D Dᵀ)` | **capstone** isospectrality |

All are proven `sorry`-free, depending only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Eigenvalue *multiplicity* duality, not just set equality

The capstone equates the nonzero spectra as sets; the sharper, falsifiable claim is that
`D` induces a linear isomorphism `ker(DᵀD − μ·1) ≅ ker(DDᵀ − μ·1)` for every `μ ≠ 0`, so the
geometric multiplicities agree exactly. The key insight is that the transfer maps `v ↦ Dv` and
`w ↦ Dᵀw` are mutually inverse up to the scalar `μ`: `Dᵀ(Dv) = (DᵀD)v = μv`, so
`(1/μ)·Dᵀ ∘ D = id` on the `μ`-eigenspace, making the two transfer maps an explicit inverse
pair after rescaling. Why now? The eigenvector dictionaries `eigvec_transfer_up_down` and
`eigvec_transfer_down_up` already supply both maps with their codomain and nonvanishing proofs;
only the scalar-inverse bookkeeping and a `Submodule.equiv`-level packaging remain — a
contained linear-algebra task with no new ideas required.

### 2. The zero eigenvalue is the *only* obstruction — a discrete index theorem

Set-level isospectrality deliberately excludes `μ = 0`, where `ker(DᵀD) = ker D` and
`ker(DDᵀ) = ker Dᵀ` genuinely differ in dimension. The key insight is that this discrepancy is
exactly the rank–nullity defect: `dim ker D − dim ker Dᵀ = n − m` while the nonzero spectra
match with multiplicity, yielding a one-line discrete index theorem
`χ = n − m = dim ker D − dim ker Dᵀ`. Why now? With Direction 1 establishing nonzero-multiplicity
equality, the alternating count of all eigenvalues telescopes, and Mathlib's `Matrix.rank` /
rank–nullity lemmas (`Matrix.rank_transpose`, `Matrix.rank_self_mul_transpose`) close the
remaining gap directly.

### 3. Functional calculus transports across the duality

Because `DᵀD` and `DDᵀ` share nonzero spectra, any spectral function should commute with the
boundary map on the orthogonal complement of the kernel: `f(DDᵀ) ∘ D = D ∘ f(DᵀD)` for
polynomials `f`, and then for the heat semigroup `exp(−t·L)` and resolvents `(L − z·1)⁻¹`. The
key insight is that the present `hodge_intertwine` (`(DDᵀ)·D = D·(DᵀD)`) lifts verbatim to any
monomial by induction — `(DDᵀ)^k · D = D · (DᵀD)^k` — since `D` slides past each factor, and
then extends linearly to all polynomials. Why now? This connects the duality to the existing
resolvent/Green-operator layer, fusing two cycles into one matrix-level functional-calculus
statement provable by `Matrix` induction.

### 4. Bipartite / singular-value bridge to the expander catalog

The pair `(DᵀD, DDᵀ)` is the adjacency-squared of the bipartite graph whose biadjacency matrix
is `D`. The key insight is that `hodge_spectral_duality` is precisely the statement that a
bipartite graph's nonzero adjacency spectrum is symmetric and determined by its singular values,
so this file is a Hodge-theoretic restatement of the spectral input used in
`Algebra/ExpanderWalk` and the classical-group expander files. Why now? A shared `singularValue`
abstraction (the common nonzero spectrum given by `hodge_spectral_duality`, with
`hodge_trace_duality` as its `ℓ²` sum) would let expander-mixing bounds consume "sum of squared
singular values" directly — a genuine cross-domain bridge requiring only a definitional adapter
between the two namespaces.

### 5. Coupled message passing converges at the *same* rate on both layers

In simplicial / higher-order message passing the up- and down-Laplacians drive diffusion on
adjacent cochain degrees. The key insight is that isospectrality forces the spectral gaps
(smallest nonzero eigenvalue) of `DᵀD` and `DDᵀ` to coincide, so a coupled scheme alternating
between the two layers inherits a single shared contraction factor `1 − μ_min`. Why now?
`HodgeMessagePassingConvergence` already has per-layer linear-rate machinery; combined with the
`nonzeroSpectrum` equality proven here it yields a falsifiable prediction — equal asymptotic
convergence rate on both layers — that can be checked numerically before being formalized into a
shared-rate convergence theorem.
