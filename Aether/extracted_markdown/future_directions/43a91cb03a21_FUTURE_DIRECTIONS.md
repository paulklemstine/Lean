# Future Directions — Spectral Depth Dynamics of Hodge Neural Tangent Kernels

## Synthesis

This cycle formalized the *depth dynamics* of a linearized message-passing neural
tangent kernel (NTK) on a finite weighted simplicial complex, built directly on
the catalog's `TropicalHodge.WeightedCoboundary` theory
(`Catalog/Tropical/HodgeDecomposition/Defs.lean`). The new file
`Catalog/Tropical/HodgeNTK/Threshold.lean` models one message-passing layer as
the propagation operator `P = I − t·Δ^up`, where `Δ^up` is the weighted upper
Hodge Laplacian, and the depth-`L` kernel as `P^L`.

The central finding is a clean spectral dichotomy. In the Hodge eigenbasis the
whole depth story collapses to scalar dynamics: an eigenvector with Hodge
eigenvalue `μ` is rescaled by exactly `(1 − t·μ)^L` at depth `L`
(`ntk_eigen_propagation`, via the reusable `mulVec_pow_eigen`). Consequently:

* **Harmonic (topological) signal is a permanent invariant of depth.** Because
  the catalog's `ker_laplacianUp_eq_ker_d` forces `μ = 0` on `ker d`, every
  harmonic cochain is an *exact fixed point at every depth*
  (`ntk_harmonic_invariant`).
* **Only non-harmonic signal decays**, and it decays geometrically precisely in
  the contraction window `|1 − t·μ| < 1` (`ntk_nonharmonic_tendsto_zero`).
* **The threshold is a *takeover*, not a *blindness*, depth.** There is a sharp
  `L_c`, governed by the Hodge spectral gap through `ρ = |1 − t·μ|`, beyond which
  harmonic signal strictly dominates the leading non-harmonic mode
  (`spectral_threshold_exists`, `ntk_crossover`).

This is a precise, falsifiable *refinement* of the originating conjecture: in the
exact infinite-width linear regime, the conjectured "topology-blind above
threshold" phase does not exist — instead topology becomes asymptotically
*dominant*, with `L_c` marking the crossover.

## Results Summary

| Theorem | Statement |
|---|---|
| `mulVec_pow_eigen` | `M *ᵥ u = c • u ⟹ Mᴸ *ᵥ u = cᴸ • u` (reusable spectral power lemma) |
| `propagator_eigen` | one layer scales a `μ`-eigenvector by `1 − t·μ` |
| `ntk_eigen_propagation` | depth-`L` kernel scales a `μ`-eigenvector by `(1 − t·μ)ᴸ` |
| `ntk_harmonic_invariant` | harmonic cochains are fixed points at all depths |
| `ntk_nonharmonic_tendsto_zero` | non-harmonic modes decay geometrically when `|1 − t·μ| < 1` |
| `spectral_threshold_exists` | explicit crossover depth `L_c` from the spectral gap |
| `ntk_crossover` | harmonic scaling strictly dominates non-harmonic scaling past `L_c` |

All main results are proved with `sorry = 0` and use only standard axioms.

## Research Directions

### 1. Quantitative crossover law `L_c ≍ log(A/B) / log(1/ρ)`
The current `spectral_threshold_exists` proves *existence* of a crossover depth.
Conjecture: the minimal such `L_c` equals `⌈log(A/B) / log(1/ρ)⌉` with
`ρ = |1 − t·μ_min|` the slowest contractive mode, and this bound is tight up to
`±1`. **The key insight is** that the crossover is purely the first-passage time
of a single geometric sequence below a fixed level, so the threshold must be a
logarithm of the amplitude ratio divided by the spectral log-rate — nothing
about the complex enters except `μ_min`. **Why now?** The eigen-propagation
identity already isolates the scalar `(1−t·μ)^L`; turning the qualitative
`Tendsto` into the explicit `⌈·⌉` formula is a self-contained real-analysis
exercise that upgrades the result from "a threshold exists" to "here is the
threshold", which is exactly what an architecture designer needs.

### 2. Spectral-gap stability window `0 < t·μ_max < 2`
Conjecture: the depth-`L` kernel is uniformly bounded in operator norm on the
non-harmonic subspace if and only if `0 < t·μ_max < 2`, where `μ_max` is the
largest Hodge eigenvalue; outside this window some mode diverges as `L → ∞`.
**The key insight is** that `|1 − t·μ| < 1 ⇔ 0 < t·μ < 2`, so the global
stability of arbitrarily deep message passing reduces to a *single* scalar
condition on the top of the Hodge spectrum — the discrete heat-flow CFL
condition. **Why now?** `ntk_nonharmonic_tendsto_zero` already pins the
per-mode contraction condition; promoting it to a uniform operator-norm
statement needs only a finite max over the (finite) spectrum plus the existing
`laplacianUp` self-adjointness machinery in the catalog.

### 3. Topology-detection separation between matched-degree complexes
Conjecture: two `WeightedCoboundary`s with identical face-degree statistics but
different `dim ker d` (Betti numbers) become *distinguishable* by the depth-`L`
kernel's rank for all `L ≥ L_c`, and *only* through their harmonic dimension —
the non-harmonic spectra are asymptotically irrelevant. **The key insight is**
that `ntk_harmonic_invariant` makes `rank(P^L) → dim ker d` as the non-harmonic
part contracts, so the deep kernel literally *computes a Betti number*. **Why
now?** With harmonic invariance and non-harmonic decay both formalized, the
limiting rank is already determined; the remaining step is a rank/limit argument
connecting `P^L` to the orthogonal projector onto `ker Δ^up`, which Mathlib's
spectral theorem for symmetric matrices supports.

### 4. Convergence of `P^L` to the harmonic projector
Conjecture: under the stability window of Direction 2, `P^L` converges entrywise
(indeed in operator norm) to the orthogonal projection `Π_harm` onto
`ker Δ^up = ker d` with respect to the weighted inner product. **The key insight
is** that `P` is self-adjoint for the weighted inner product (the catalog's
`adjunction` gives the adjointness of `d`/`δ`), so it diagonalizes with
eigenvalue `1` exactly on harmonics and `|·| < 1` elsewhere, forcing the power
limit to be the spectral projector at eigenvalue `1`. **Why now?** Every
ingredient — eigen-propagation, harmonic fixity, non-harmonic decay,
self-adjointness — is now formal; assembling them into a projector limit is the
natural capstone and would make "the deep Hodge-NTK is topology" a theorem
rather than a slogan.

### 5. Multi-degree (full Hodge chain) and the role of `Δ^down`
Conjecture: extending from a single `WeightedCoboundary` to a full cochain
complex with both `Δ^up` and `Δ^down`, a layer using the *full* Hodge Laplacian
`Δ = Δ^up + Δ^down` has the same harmonic fixed space (`ker Δ = ker d ∩ ker δ`),
and its depth threshold is governed by the *smaller* of the two spectral gaps.
**The key insight is** that harmonic cochains are simultaneously closed and
coclosed, so they sit in the kernel of the combined operator and are still
fixed, while the crossover rate is set by whichever of the up/down spectra is
slowest. **Why now?** `Defs.lean` already provides `laplacianDown` and the
adjunction needed for `δ`; lifting the present single-operator results to the
combined Laplacian is the most direct route to genuine higher-order
(multi-degree) simplicial learning theory.
