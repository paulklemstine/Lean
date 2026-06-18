# Future Directions — Hodge–Laplacian Message Passing as a Discrete Heat Semigroup

## Synthesis

This cycle closed the conceptual loop opened by the spectral-depth-threshold work
(`Speculative.AutoResearch.HodgeSpectralThreshold`) and the convergence theory
(`Speculative.AutoResearch.HodgeMessagePassingConvergence`). Those two files
established that depth-`k` Hodge message passing `Tᵏ = (1 − α·Δ)ᵏ` fixes the
harmonic (cohomology) subspace and geometrically suppresses everything else. The
new file `Speculative.AutoResearch.HodgeHeatSemigroup` upgrades that picture from
*decay estimates* to the full **structure of a discrete heat semigroup generated
by the Hodge Laplacian**:

* a depth-additive **semigroup law** `Tᵐ⁺ⁿ = Tᵐ∘Tⁿ` (`mpStep_semigroup`);
* **commutation with the generator** `Δ∘Tᵏ = Tᵏ∘Δ` (`mpStep_commute`,
  `mpStep_iterate_commute`);
* the literal **discrete heat equation** `Tᵏ⁺¹x − Tᵏx = −α·Δ(Tᵏx)`
  (`mpStep_discrete_heat_equation`) — message passing *is* explicit-Euler heat flow
  with time step `α`;
* the exact **Dirichlet energy balance** `⟪x,x⟫ − ⟪Tx,Tx⟫ = α(2⟪x,Δx⟫ − α⟪Δx,Δx⟫)`
  (`mpStep_energy_dissipation`), its **monotone dissipation** under a stable step
  (`mpStep_energy_monotone`), and the **telescoping total-dissipation identity**
  (`mpStep_total_dissipation`); and
* the bridge `hodge_heat_stationary`: harmonic cochains are *exactly* the stationary
  solutions of the discrete heat flow, recovering the catalog's
  `HodgeSpectralThreshold.harmonic_iff` characterisation of cohomology.

A pleasant adversarial outcome: the energy-balance and telescope theorems were
first stated with a self-adjointness hypothesis `⟪Δx,y⟫ = ⟪x,Δy⟫`, but pressure-
testing revealed the cross terms collapse through `real_inner_comm` alone — so both
hold for an *arbitrary* operator `Δ`, and the hypothesis was dropped. Only the
*monotone* inequality genuinely needs a Rayleigh (spectral) bound, not symmetry.

## Results summary

All eight headline theorems in `HodgeHeatSemigroup.lean` are proved sorry-free and
depend only on `propext`, `Classical.choice`, `Quot.sound`. The file imports and
builds directly on the two predecessor catalog files; no result is reproved.

## Research directions

### 1. The iterate converges in operator norm to the harmonic projector.
We proved that `‖Tᵏ(h+r) − h‖² ≤ ρᵏ‖r‖²`; the natural next theorem is that, on a
finite-dimensional cochain space, `Tᵏ → P`, the orthogonal projection onto
`ker Δ` (the harmonic/cohomology subspace already constructed in
`HodgeHarmonicProjector`). **The key insight is** that the semigroup law plus
monotone dissipation force every orbit to land on its harmonic part, so the limit
operator is idempotent, self-adjoint, and has range exactly `ker Δ` — i.e. it can
only be `P`. **Why now?** This cycle supplies the missing semigroup and dissipation
structure, and the catalog already contains a verified harmonic projector to
identify the limit with; the two just need to be glued by a finite-dimensional
contraction-to-fixed-point argument.

### 2. The discrete semigroup converges to the continuous one (Lie–Trotter).
Conjecture: with `α = t/k`, `(1 − (t/k)·Δ)ᵏ → e^{−tΔ}` as `k → ∞`, uniformly on
bounded spectra. **The key insight is** that `mpStep_discrete_heat_equation`
exhibits message passing as the explicit-Euler discretisation of `u′ = −Δu`, so
consistency (one-step error `O(α²)`) plus the stability already proved
(`mpStep_energy_monotone`) yield convergence by the Lax-equivalence/Trotter
template. **Why now?** The explicit discrete heat equation is in hand; the only new
ingredient is a scalar `(1 − t/k)ᵏ → e^{−t}` estimate promoted through the spectral
decomposition.

### 3. A sharp logarithmic depth threshold from the telescope.
`mpStep_total_dissipation` gives the *exact* energy lost after `k` layers as a sum
of per-step Dirichlet dissipations. Conjecture: this forces a *matching upper and
lower* bound `k = Θ(log(‖r‖²/ε) / log(1/ρ))` for reaching tolerance `ε`, sharpening
the one-sided estimate of `HodgeDepthLogarithmic`. **The key insight is** that the
telescope turns "energy remaining" into a genuine conserved bookkeeping identity,
so the depth is pinned from *both* sides rather than merely bounded above. **Why
now?** The exact (not inequality) dissipation identity proved this cycle is exactly
what a lower bound needs; prior cycles only had the decay inequality.

### 4. Dissipation survives a 1-Lipschitz nonlinearity.
Real message-passing layers interleave `T` with a pointwise nonlinearity `σ`.
Conjecture: if `σ` is 1-Lipschitz and fixes harmonic signals, then the *nonlinear*
layer `σ∘T` is still energy-non-increasing and still fixes `ker Δ`, so
`hodge_heat_stationary` and `mpStep_energy_monotone` survive verbatim. **The key
insight is** that the composition of a contraction (`T`, under a stable step) with a
1-Lipschitz map is again a contraction, so the entire linear semigroup picture is a
*lower envelope* for the nonlinear dynamics. **Why now?** The linear case is now
fully closed and isolates exactly the contraction constant `1 − αμ(2 − αλ)` that a
1-Lipschitz `σ` cannot increase.

### 5. One spectral gap, two phenomena: bridge to expander mixing.
The decay rate `(1 − tμ)^L` governing Hodge heat flow is *formally identical* to the
expander-walk mixing rate studied in `Algebra.ClassicalGroupExpanders` and
`Algebra.ExpanderWalk.Amplification`. Conjecture: the harmonic-projector limit of
Direction 1 specialises, on the `0`-cochain (graph) Laplacian, to the stationary
distribution of the lazy random walk, with the spectral gap controlling both.
**The key insight is** that "kernel of the Hodge Laplacian = constants" for graphs,
so the heat-semigroup limit *is* averaging, and the gap that drives expander mixing
is the same `μ` that drives `mpStep_energy_monotone`. **Why now?** Both the heat-
semigroup machinery (this cycle) and a verified expander-mixing toolkit already live
in the catalog; the bridge is a cross-domain identification rather than new analysis.
