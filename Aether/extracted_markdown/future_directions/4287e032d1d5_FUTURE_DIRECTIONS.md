# Future Directions — Hodge–Laplacian Message Passing as a Discrete Heat Semigroup

## Synthesis

This cycle assembles the full **discrete-heat-semigroup dictionary** for the
gradient message-passing layer `T = 1 − α·Δ` on a real inner-product space. Where
the prior message-passing files (`HodgeMessagePassingConvergence`,
`HodgeMessagePassingEnergy`) supply *decay estimates* — the residual energy
contracts geometrically at the spectral rate — the new file
`Speculative.AutoResearch.HodgeHeatSemigroup` shows that the *same operator* is the
explicit-Euler discretisation of a heat flow `u′ = −Δu` and carries the complete
algebraic and energetic structure of a one-parameter semigroup:

* a depth-additive **semigroup law** `Tᵐ⁺ⁿ = Tᵐ ∘ Tⁿ` (`mpStep_semigroup`, literally
  `pow_add` in `Module.End ℝ E`);
* **commutation with the generator** `Δ ∘ Tᵏ = Tᵏ ∘ Δ` (`mpStep_commute`,
  `mpStep_iterate_commute`);
* the literal **discrete heat equation** `Tᵏ⁺¹x − Tᵏx = −α·Δ(Tᵏx)`
  (`mpStep_discrete_heat_equation`);
* the exact **Dirichlet energy balance**
  `⟪x,x⟫ − ⟪Tx,Tx⟫ = α(2⟪x,Δx⟫ − α⟪Δx,Δx⟫)` (`mpStep_energy_dissipation`), its
  **monotone dissipation** under a stable step (`mpStep_energy_monotone`), and the
  **telescoping total-dissipation identity** (`mpStep_total_dissipation`); and
* the bridge `hodge_heat_stationary`: for a nonzero step, harmonic cochains
  (`Δ x = 0`) are *exactly* the stationary points of the discrete flow — the
  cohomology / fixed-point characterisation, recovered dynamically.

A pleasant adversarial outcome confirmed during this cycle: the energy-balance and
telescope identities were first conceived with a self-adjointness hypothesis
`⟪Δx,y⟫ = ⟪x,Δy⟫`, but the two cross terms collapse through `real_inner_comm`
alone, so both hold for an **arbitrary** operator `Δ`. Only the *monotone*
inequality genuinely needs a Rayleigh (spectral) bound — and not symmetry.

## Results summary

All eight headline theorems in `HodgeHeatSemigroup.lean` are proved sorry-free and
depend only on `propext`, `Classical.choice`, `Quot.sound`. The development is
self-contained over Mathlib (the predecessor catalog file
`HodgeMessagePassingConvergence` currently fails to build because it imports a
missing `HodgeSpectralThreshold`, so `mpStep` is redeveloped here directly), and no
result is reproved.

## Research directions

### 1. The iterate converges in operator norm to the harmonic projector.
We have `‖Tᵏ(h+r) − h‖² ≤ ρᵏ‖r‖²` (in the predecessor file) and now the exact
dissipation telescope. The natural next theorem is that, on a finite-dimensional
cochain space, `Tᵏ → P`, the orthogonal projection onto `ker Δ`. **The key insight
is** that the semigroup law `Tᵐ⁺ⁿ = Tᵐ∘Tⁿ` plus monotone dissipation force every
orbit onto its harmonic part, so the limit operator is idempotent, self-adjoint, and
has range exactly `ker Δ` — it can only be `P`. **Why now?** This cycle supplies the
semigroup and dissipation structure; a verified harmonic projector already exists in
the catalog (`HodgeHarmonicProjector`) to identify the limit with, so the two need
only be glued by a finite-dimensional contraction-to-fixed-point argument.

### 2. The discrete semigroup converges to the continuous one (Lie–Trotter).
Conjecture: with `α = t/k`, `(1 − (t/k)·Δ)ᵏ → e^{−tΔ}` as `k → ∞`, uniformly on
bounded spectra. **The key insight is** that `mpStep_discrete_heat_equation`
exhibits `T` as the explicit-Euler discretisation of `u′ = −Δu`, so consistency
(one-step error `O(α²)`) plus the stability already proved (`mpStep_energy_monotone`)
yield convergence via the Lax-equivalence / Trotter template. **Why now?** The
explicit discrete heat equation is in hand; the only new scalar ingredient is the
limit `(1 − t/k)ᵏ → e^{−t}` promoted through a spectral decomposition.

### 3. A sharp logarithmic depth threshold from the telescope.
`mpStep_total_dissipation` gives the *exact* energy lost after `k` layers as a sum of
per-step Dirichlet dissipations. Conjecture: this forces a *matching* upper and lower
bound `k = Θ(log(‖r‖²/ε) / log(1/ρ))` for reaching tolerance `ε`, sharpening any
one-sided decay estimate. **The key insight is** that the telescope turns "energy
remaining" into a genuine conserved bookkeeping identity, so depth is pinned from
*both* sides rather than merely bounded above. **Why now?** The exact (equality, not
inequality) dissipation identity proved this cycle is precisely what a lower bound
needs; prior cycles only had the decay inequality.

### 4. Dissipation survives a 1-Lipschitz nonlinearity.
Real message-passing layers interleave `T` with a pointwise nonlinearity `σ`.
Conjecture: if `σ` is 1-Lipschitz and fixes harmonic signals, then the *nonlinear*
layer `σ∘T` is still energy-non-increasing and still fixes `ker Δ`, so
`hodge_heat_stationary` and `mpStep_energy_monotone` survive verbatim. **The key
insight is** that the composition of a contraction (`T`, under a stable step) with a
1-Lipschitz map is again a contraction, so the linear semigroup picture is a *lower
envelope* for the nonlinear dynamics. **Why now?** The linear case is now fully
closed and isolates exactly the contraction constant `1 − αμ(2 − αλ)` that a
1-Lipschitz `σ` cannot increase.

### 5. One spectral gap, two phenomena: bridge to expander mixing.
The decay rate `(1 − αμ)^L` governing Hodge heat flow is *formally identical* to the
expander-walk mixing rate studied in the catalog's expander files. Conjecture: the
harmonic-projector limit of Direction 1 specialises, on the `0`-cochain (graph)
Laplacian, to the stationary distribution of the lazy random walk, with the spectral
gap controlling both. **The key insight is** that "kernel of the graph Laplacian =
constants", so the heat-semigroup limit *is* averaging, and the gap that drives
expander mixing is the same `μ` that drives `mpStep_energy_monotone`. **Why now?**
Both the heat-semigroup machinery (this cycle) and a verified expander-mixing toolkit
already live in the catalog; the bridge is a cross-domain identification rather than
new analysis.
