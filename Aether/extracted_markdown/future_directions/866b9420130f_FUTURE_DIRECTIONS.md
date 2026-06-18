# Future Directions — Hodge Spectral Duality, Seventh Cycle

## Synthesis

The discrete-Hodge program has, over its earlier cycles, built the *geometric/decomposition*
layer (`HodgeFullDecomposition`: the split Dirichlet energy `⟨x,Lx⟩ = ‖Dx‖² + ‖Eᵀx‖²`, the
discrete Hodge theorem `harmonic ⇔ closed ∧ coclosed`, and image orthogonality from `∂∂=0`)
and the *operator/solvability* layer (`HodgeGreenOperator`, `HodgeResolutionIdentity`).

This cycle adds the **Duality & Representation** layer. The new file `HodgeSpectralDuality.lean`
isolates a *single* boundary matrix `D` and exhibits its two Gram-Laplacians — the up-Laplacian
`Dᵀ D` on the source cochains and the down-Laplacian `D Dᵀ` on the target cochains — as two
representations of *one* spectral object. The boundary map is shown to be a self-dual pairing
(`hodge_adjunction`: `⟨Dx,y⟩ = ⟨x,Dᵀy⟩`), and from this single adjunction we derive:

* **trace duality** (`hodge_trace_duality`): equal sum of squared singular values;
* **explicit eigenvector dictionaries** (`eigvec_transfer_up_down`, `eigvec_transfer_down_up`):
  `D` and `Dᵀ` carry nonzero-eigenvalue eigenvectors back and forth;
* the **capstone isospectrality** (`hodge_spectral_duality`): `Dᵀ D` and `D Dᵀ` have *identical
  nonzero spectra*.

This is the discrete avatar of the analytic fact that `∂` and its adjoint `∂*` share their
nonzero singular values — the representation-theoretic heart of Hodge theory, now available as
an elementary, determinant-free statement about matrices over `ℝ`.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `hodge_adjunction` | `⟨Dx, y⟩ = ⟨x, Dᵀy⟩` | the duality pairing intertwining both Laplacians |
| `hodge_trace_duality` | `tr(Dᵀ D) = tr(D Dᵀ)` | representation-level invariant |
| `eigvec_transfer_up_down` | nonzero `μ`-eigvec `v` of `Dᵀ D` ↦ nonzero `μ`-eigvec `Dv` of `D Dᵀ` | forward dictionary |
| `eigvec_transfer_down_up` | dual transfer via `Dᵀ` | backward dictionary |
| `hodge_spectral_duality` | `nonzeroSpectrum (Dᵀ D) = nonzeroSpectrum (D Dᵀ)` | **capstone** isospectrality |

All five are proven `sorry`-free, depending only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Eigenvalue *multiplicity* duality, not just set equality

The current capstone equates the nonzero spectra *as sets*. The sharper, falsifiable claim is
that `D` induces a **linear isomorphism** `ker(DᵀD − μ) ≅ ker(DDᵀ − μ)` for every `μ ≠ 0`, so the
geometric multiplicities agree exactly. The key insight is that the transfer maps `v ↦ Dv` and
`w ↦ Dᵀw` are *mutually inverse up to the scalar `μ`* on the nonzero eigenspaces:
`Dᵀ(Dv) = (DᵀD)v = μv`, so `(1/μ)Dᵀ ∘ D = id` on the `μ`-eigenspace. Why now? The eigenvector
dictionaries `eigvec_transfer_up_down`/`_down_up` already supply both maps; only the scalar-inverse
bookkeeping and a `Submodule`-level packaging remain, which is a contained linear-algebra task.

### 2. The zero eigenvalue is the *only* obstruction — a discrete index theorem

Set-level isospectrality deliberately excludes `μ = 0`, where the kernels `ker(DᵀD) = ker D` and
`ker(DDᵀ) = ker Dᵀ` genuinely differ in dimension. The key insight is that this discrepancy is
*exactly* the rank-nullity defect: `dim ker D − dim ker Dᵀ = n − m` while the nonzero spectra match
with multiplicity, giving a one-line **discrete index theorem** `χ = n − m = dim ker D − dim ker Dᵀ`.
Why now? With Direction 1 establishing nonzero-multiplicity equality, the alternating count of all
eigenvalues telescopes, and Mathlib's `Matrix.rank` / rank-nullity lemmas close the remaining gap.

### 3. Functional calculus transports across the duality

Because `DᵀD` and `DDᵀ` share nonzero spectra, *any* spectral function should commute with the
boundary map on the orthogonal complement of the kernel: `f(DDᵀ) ∘ D = D ∘ f(DᵀD)` for polynomials
`f`, and then for the heat semigroup `exp(−t·L)` and resolvents `(L − z)⁻¹`. The key insight is that
the intertwining `DDᵀ ∘ D = D ∘ DᵀD` (already the engine of `eigvec_transfer_up_down`) lifts verbatim
to any polynomial by induction, since `D` commutes with the recursion. Why now? This connects the
present duality to the existing `HodgeResolutionIdentity` and `HodgeGreenOperator` resolvent layer,
turning two separate cycles into one functional-calculus statement.

### 4. Bipartite/singular-value bridge to the expander catalog

The pair `(DᵀD, DDᵀ)` is the adjacency-squared of the bipartite graph whose biadjacency matrix is
`D`. The key insight is that `hodge_spectral_duality` is precisely the statement that a bipartite
graph's nonzero adjacency spectrum is symmetric and determined by its singular values, so the
present file is a Hodge-theoretic restatement of the spectral input used in
`Algebra/ClassicalGroupExpanders` and `Algebra/ExpanderWalk`. Why now? A shared `singularValue`
abstraction would let the expander-mixing results consume `hodge_trace_duality` directly as the
"sum of squared singular values" bound, a genuine cross-domain bridge.

### 5. Coupled message passing converges at the *same* rate on both layers

In simplicial/higher-order message passing the up- and down-Laplacians drive diffusion on adjacent
cochain degrees. The key insight is that isospectrality forces the *spectral gaps* (smallest nonzero
eigenvalue) of `DᵀD` and `DDᵀ` to coincide, so a coupled scheme alternating between the two layers
inherits a single, shared contraction factor `1 − μ_min`. Why now? `HodgeMessagePassingConvergence`
already has the per-layer linear-rate machinery; combining it with the present `nonzeroSpectrum`
equality yields a falsifiable prediction — equal asymptotic convergence rate on both layers — that
can be checked numerically before being formalized.
