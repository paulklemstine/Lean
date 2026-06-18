# Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

## Synthesis

The fifth cycle (`HodgeMessagePassingConvergence.lean`) established *pointwise
convergence* of the gradient message-passing layer `T = 1 - α·L` to the harmonic
(cohomology) subspace, viewing `T` analytically: it decays residual energy
geometrically at the spectral rate while transporting the harmonic part untouched.

This sixth cycle re-reads that same operator through a **duality / representation**
lens (`HodgeMessagePassingDuality.lean`). The unifying observation is that `T` is a
*degree-one polynomial in the single operator `L`*, so it lives inside the commutative
algebra `ℝ[L]`. Every analytic fact then has an algebraic dual:

* **Spectral representation.** `T` and all of its depth iterates `Tᵏ` are *scalars*
  on each eigenspace of `L`: `T x = (1-αλ)x`, `Tᵏ x = (1-αλ)ᵏ x`
  (`mpStep_eigen`, `mpStep_iterate_eigen`). Message passing is the Laplacian seen in
  its own eigenbasis. The energy of an eigen-mode is *exactly* `(1-αλ)^{2k}` of its
  start (`mpStep_eigen_energy`) — convergence becomes an identity, not a bound.
* **Simultaneous diagonalisation.** `L∘T = T∘L` (`mpStep_comm_L`): any harmonic /
  spectral projector commutes with every layer.
* **Adjoint duality.** Symmetry of `L` lifts to `T` (`mpStep_symm`): the layer is its
  own dual under the Riesz pairing.
* **Fixed-point ↔ kernel duality** (the representation theorem). For `α ≠ 0`,
  `T x = x ↔ L x = 0` (`mpStep_fixed_iff`), and as submodules
  `ker(T-1) = ker L` (`mpStep_eigenspace_one`). Composed with the catalog's
  `harmonic_iff`, this represents Hodge cohomology as *exactly the invariants of the
  dynamics* (`hodge_cohomology_eq_fixed`).

## Results Summary

Nine sorry-free theorems, all depending only on `propext`, `Classical.choice`,
`Quot.sound`:

| Theorem | Content |
|---|---|
| `mpStep_eigen` | `T x = (1-αλ)·x` on eigenvectors |
| `mpStep_iterate_eigen` | `Tᵏ x = (1-αλ)ᵏ·x` |
| `mpStep_comm_L` | `L∘T = T∘L` (simultaneous diagonalisation) |
| `mpStep_eigen_energy` | exact eigen-mode energy `(1-αλ)^{2k}‖x‖²` |
| `mpStep_eigen_contracts` | strict contraction window `0<αλ<2` |
| `mpStep_symm` | symmetry of `L` lifts to `T` |
| `mpStep_fixed_iff` | `T x = x ↔ L x = 0` (`α≠0`) |
| `mpStep_eigenspace_one` | `ker(T-1) = ker L` |
| `hodge_cohomology_eq_fixed` | cohomology = fixed points of message passing |

These extend, rather than reprove, the convergence cycle: the analytic
`mpStep_contraction`/`mpStep_converges_to_harmonic` are now bracketed by their exact
spectral counterparts, and the bridge `hodge_harmonic_mpStep_fixed` is sharpened from
an inclusion into the biconditional `hodge_cohomology_eq_fixed`.

## Research Directions

### 1. The full spectral-mapping theorem: `spec(T) = 1 - α·spec(L)`.
We proved the *forward* eigen-correspondence (an eigenvalue `λ` of `L` produces an
eigenvalue `1-αλ` of `T`). The falsifiable claim is the *exact* set identity in finite
dimension: every eigenvalue of `T` arises this way, so `spec(T) = {1-αλ : λ ∈ spec(L)}`
with matching multiplicities, and `T` is diagonalisable iff `L` is. **The key insight
is** that `T = p(L)` for the affine `p(t)=1-αt`, an injective polynomial, so the
spectral-mapping theorem applies verbatim and multiplicities are preserved by the bijection
`λ ↦ 1-αλ`. **Why now?** The eigen-direction (`mpStep_eigen`) and commutation
(`mpStep_comm_L`) are already in place; Mathlib's `Module.End.eigenspace` and
`Polynomial.aeval` give the missing reverse inclusion without any new analysis.

### 2. Eigenspace-resolved convergence: per-mode optimal step and the second gap.
Conjecture: on a fixed eigen-mode, the depth needed to reach tolerance `ε` is exactly
`k ≥ log ε / (2 log|1-αλ|)`, and the *global* optimal step `α=1/λ_max` is dominated, for
deep networks, by the mode with eigenvalue closest to the harmonic gap — i.e. the
asymptotic rate is governed by `max(|1-αμ|, |1-αλ_max|)` and is minimised at
`α = 2/(μ+λ_max)`, giving rate `(λ_max-μ)/(λ_max+μ)`. **The key insight is** that
`mpStep_eigen_energy` turns convergence into the scalar recursion `(1-αλ)^{2k}`, so the
worst mode is a finite `max` over the spectrum rather than a Rayleigh-quotient estimate.
**Why now?** `mpStep_eigen_energy` provides the exact per-mode rate; only the elementary
optimisation `min_α max(|1-αμ|,|1-αλ|)` remains, a one-variable convex problem.

### 3. Functional-calculus message passing: replacing `1-αt` by general filters.
Graph/Hodge neural networks use polynomial (Chebyshev) and rational filters `g(L)`, not
just `1-αL`. Conjecture: every result here generalises to any `g` with `g(0)=1`: `g(L)`
fixes cohomology, commutes with `L`, is symmetric when `L` is, and acts as `g(λ)` on
eigen-modes; convergence to harmonics holds iff `|g(λ)|<1` for all nonzero `λ ∈ spec(L)`.
**The key insight is** that *all* of the dualities used only that `T ∈ ℝ[L]` with constant
term `1`, never the degree — so the proofs are filter-agnostic. **Why now?** The current
file is literally the `g(t)=1-αt` instance; abstracting `mpStep` to `Polynomial.aeval g L`
reuses `mpStep_eigen`/`mpStep_comm_L`/`mpStep_fixed_iff` mutatis mutandis and connects to
Mathlib's `Polynomial.aeval` algebra-hom machinery.

### 4. Three-way (gradient + curl) duality and the Hodge decomposition as a direct sum.
The catalog's `HodgeThreeWayDecomposition` splits cochains into image(d) ⊕ image(δ) ⊕
harmonic. Conjecture: separate up/down message passing `T_↑ = 1-αL_↑`, `T_↓ = 1-βL_↓`
*commute* (`L_↑ L_↓ = 0` on the relevant complex), act diagonally on the three summands,
and their composite converges to the harmonic summand with rate `max(ρ_↑, ρ_↓)`. **The
key insight is** that the two Laplacians share the harmonic kernel but have orthogonal
non-harmonic ranges, so the duality `ker(T-1)=ker L` refines into a *simultaneous*
fixed-point decomposition. **Why now?** `mpStep_comm_L` and `hodge_cohomology_eq_fixed`
already isolate the kernel; the remaining input is the catalog's orthogonality
`HodgeThreeWayDecomposition`, making this a pure assembly of existing pieces.

### 5. Pontryagin/Fourier-style dual on a circulant (translation-invariant) complex.
On a vertex set with a cyclic symmetry, `L` is circulant and diagonalised by the discrete
Fourier transform; message passing becomes pointwise multiplication by `1-α·L̂(ξ)` on the
character group. Conjecture: `T` is conjugate, via the DFT, to multiplication by the
*symbol* `ξ ↦ 1-αL̂(ξ)`, so the fixed-point/kernel duality of this cycle is the spatial
shadow of a Pontryagin duality between the cycle group and its dual. **The key insight is**
that `mpStep_comm_L` (commutation with `L`) plus translation-invariance forces `T` into the
maximal commutative algebra generated by the shift, which the DFT represents as functions on
the dual group. **Why now?** With the spectral representation (#1) in hand, specialising to a
finite abelian symmetry group turns the abstract eigen-duality into a concrete transform,
linking this thread to the catalog's Fourier/representation material.
