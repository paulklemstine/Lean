# Future Directions — Hodge–Laplacian Message Passing, Second Cycle

## Synthesis

This cycle pushed the *spectral depth threshold* program of
`HodgeSpectralThreshold.lean` forward along two of its own conjectured axes, turning
two informal "future directions" into proven, sorry-free Lean 4 theory.

* **`HodgeFullDecomposition.lean` — the genuine Hodge Laplacian.**
  The original file modelled only the *up* Laplacian `L = Bᵀ B`. We upgraded to the full
  combinatorial Hodge Laplacian `L = ∂ₖᵀ ∂ₖ + ∂ₖ₊₁ ∂ₖ₊₁ᵀ` built from *two* boundary
  maps. The Dirichlet energy now splits into a **closed** channel `‖∂ₖ x‖²` and a
  **coclosed** channel `‖∂ₖ₊₁ᵀ x‖²` (`fullHodge_quadform`), and the discrete Hodge
  theorem (`fullHodge_kernel`) characterizes harmonic cochains as exactly the
  *closed-and-coclosed* signals — the genuine cohomological invariant
  `ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`. The chain condition `∂ₖ ∂ₖ₊₁ = 0` is isolated to a single
  orthogonality lemma (`hodge_image_orthogonal`) from which a Pythagorean energy identity
  (`hodge_energy_pythagoras`) follows.

* **`HodgeDepthLogarithmic.lean` — the explicit logarithmic depth law.**
  The original `spectral_depth_threshold` only asserted that *some* finite depth reaches a
  tolerance `ε`. We replaced that non-constructive existence with the explicit, evaluable
  witness `N(ε) = ⌈log_ρ(ε/‖x‖²)⌉` (`hodgeDepth`) and proved it suffices
  (`hodgeDepth_residual_bound`, specialized to message passing in `hodge_mp_log_depth`).
  Depth grows like `log(1/ε)`: this is the quantitative depth–accuracy trade-off.

The unifying picture sharpens: message passing is a discrete deformation retraction onto
the harmonic core, the harmonic core is now correctly the *cohomology* (not just a single
boundary kernel), and the speed of the retraction is governed by an explicit logarithmic
clock.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `fullHodge_isSymm` | FullDecomposition | full Hodge Laplacian is symmetric |
| `fullHodge_quadform` | FullDecomposition | `⟨x,Lx⟩ = ‖∂ₖx‖² + ‖∂ₖ₊₁ᵀx‖²` |
| `fullHodge_psd` | FullDecomposition | `L` positive semidefinite |
| `fullHodge_kernel` | FullDecomposition | harmonic ⇔ closed ∧ coclosed (discrete Hodge) |
| `hodge_image_orthogonal` | FullDecomposition | `∂∂=0 ⇒ im ∂ₖ₊₁ ⊥ im ∂ₖᵀ` |
| `hodge_energy_pythagoras` | FullDecomposition | Pythagoras for the Hodge splitting |
| `quadform_iterate_bound` | DepthLogarithmic | geometric energy decay `ρᵏ` |
| `pow_le_of_logb_le` | DepthLogarithmic | `N ≥ log_ρ c ⇒ ρᴺ ≤ c` |
| `hodgeDepth_residual_bound` | DepthLogarithmic | explicit `⌈log⌉` depth suffices |
| `hodge_mp_log_depth` | DepthLogarithmic | the above, for `mpStep` |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Betti numbers from the harmonic kernel dimension
Conjecture: with `fullHodge_kernel` in hand, `dim ker(∂ₖᵀ∂ₖ + ∂ₖ₊₁∂ₖ₊₁ᵀ) = dim ker ∂ₖ −
rank ∂ₖ₊₁`, i.e. the dimension of the space of harmonic `k`-cochains equals the `k`-th
Betti number. This is falsifiable: any explicit small complex whose harmonic-space
dimension disagrees with its rank-nullity prediction refutes it. **The key insight is**
that `fullHodge_kernel` already identifies harmonic cochains as `ker ∂ₖ ∩ (im ∂ₖ₊₁)ᗮ`, so
the Betti formula is precisely the rank–nullity theorem applied to `∂ₖ` restricted to that
intersection — no new geometry, only `Matrix.rank` bookkeeping. **Why now?** Mathlib's
`Matrix.rank`, `LinearMap.finrank_range_add_finrank_ker`, and the orthogonality lemma
`hodge_image_orthogonal` proven here are exactly the three ingredients required.

### 2. Convergence to the harmonic projector
Conjecture: for the admissible step `0 < α < 2/λ_max`, the iterate `(mpStep L α)^[k]`
converges entrywise to the orthogonal projector `P` onto `ker L`, with
`‖(mpStep L α)^[k] x − P x‖² ≤ ρᵏ ‖x − P x‖²` where `ρ = 1 − αμ(2 − αλ)`. Falsifiable by a
complex with an eigenvalue outside `(0, 2/α)` exhibiting non-contraction. **The key insight
is** that `quadform_iterate_bound` already gives the geometric rate on the invariant
complement `(ker L)ᗮ`; the only missing step is invariance `mpStep L α '' (ker L)ᗮ ⊆
(ker L)ᗮ`, a one-line consequence of self-adjointness (`fullHodge_isSymm`). **Why now?**
With harmonic signals fixed (`mpStep_iterate_fixes_harmonic`) and the contraction on the
complement quantified, the splitting `id = P + (id − P)` assembles the limit directly from
Mathlib's `Submodule.orthogonalProjection`.

### 3. Tightness of the logarithmic depth
Conjecture: the depth `hodgeDepth ρ ‖x‖² ε = ⌈log_ρ(ε/‖x‖²)⌉` is not merely sufficient but
**tight**: for the bottom non-harmonic eigenvector `v` (energy contracted by *exactly* `ρ`
each layer) every layer below `hodgeDepth − 1` leaves residual `> ε`. Falsifiable by a
complex where strictly fewer layers already reach `ε` on every input. **The key insight is**
that the worst-case input saturates `quadform_iterate_bound` with equality
(`‖Tᵏv‖² = ρᵏ‖v‖²`), so the sufficient bound becomes exact and the ceiling becomes a
genuine minimum. **Why now?** `pow_le_of_logb_le` proven here has an immediate converse
`ρᴺ > c` for `N < log_ρ c` via the same `div_lt_iff_of_neg` lemma, so tightness is a
mechanical mirror of the existing proof.

### 4. Heat-flow continuum limit of the depth clock
Conjecture: the discrete flow `x_{k+1} = x_k − α L x_k` is the explicit Euler scheme of the
Hodge heat equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep L α)^[k] x →
e^{−tL} x`, and the continuum decay constant equals the spectral gap `μ`. Falsifiable by a
complex whose empirical decay rate differs from its second-smallest Hodge eigenvalue.
**The key insight is** that the contraction factor `1 − αμ(2 − αλ) ≈ 1 − 2αμ` is the
first-order expansion of `e^{−2αμ}`, identifying the discrete logarithmic depth clock
`hodgeDepth` with the continuous heat-kernel half-life `t = log(1/ε)/(2μ)`. **Why now?**
Mathlib's `Matrix.exp` and its derivative API make the Euler-to-exponential limit a
concrete analysis target, and `hodgeDepth` provides the discrete side of the comparison.

### 5. Multi-tolerance depth schedules and adaptive smoothing
Conjecture: for a decreasing tolerance schedule `ε_1 > ε_2 > …`, the *incremental* depths
`hodgeDepth ρ E ε_{j+1} − hodgeDepth ρ E ε_j = ⌈log_ρ(ε_{j+1}/ε_j)⌉` are governed only by
the *ratio* of consecutive tolerances, independent of the signal energy `E`. This predicts
that adaptive smoothing networks should add layers in batches sized by geometric tolerance
ratios. Falsifiable by a regime where required incremental depth depends on `E`. **The key
insight is** that `hodgeDepth` is `⌈log_ρ⌉` of a *quotient*, so energy cancels in
differences, making the depth schedule a pure function of the accuracy ratio. **Why now?**
`hodgeDepth` and `pow_le_of_logb_le` give the closed form; the increment law is a direct
`Real.logb` arithmetic corollary requiring no new analysis.
