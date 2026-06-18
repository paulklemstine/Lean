# Future Directions — Hodge–Laplacian Message Passing, Seventh Cycle

## Synthesis

The sixth cycle (`Speculative/AutoResearch/HodgeMessagePassingEnergy.lean`) lifted the
fifth cycle's *pointwise* convergence picture (`HodgeMessagePassingConvergence`:
`mpStep_iterate_add_harmonic`, `mpStep_iterate_contraction`,
`mpStep_dist_to_harmonic_bound`) to **global, integrated energy laws** for the whole
message-passing operator family `T = 1 - α·L`:

1. **Heterogeneous depth commutes.** Layers of *different* learning rates `1 - α·L`
   and `1 - β·L` commute (`mpStep_comm`), and so do their powers
   (`mpStep_comm_iterate`). A deep network with an arbitrary *schedule* of step sizes
   depends only on the multiset of rates, not their order. The proof is purely
   algebraic — `α•L` and `β•L` commute in `Module.End ℝ E`, so `Commute.pow_pow`
   handles every depth.
2. **Energy is antitone in depth.** Under a sub-unital contraction the residual
   Dirichlet energy never increases layer to layer (`mpStep_energy_antitone`): deep
   message passing is provably a low-pass smoother, not merely an asymptotic one.
3. **Total energy is finite.** For a strict contraction the energy summed over
   *every* depth is bounded by the geometric budget `⟪r,r⟫/(1−ρ)`, uniformly in the
   truncation (`mpStep_partial_energy_bound`, `mpStep_total_energy_bound`). This is
   the discrete shadow of finite Dirichlet action `∫₀^∞ ‖∇u‖² < ∞` for the Hodge heat
   flow, and it is instantiated for the catalog Hodge Laplacian `Δ = up + down` in
   `hodge_total_energy_bound`, where the per-layer rate `ρ = 1 − αμ(2−αλ)` is derived
   from the spectral bounds via the fifth-cycle `mpStep_contraction`.

Together with the catalog foundation (`HodgeSpectralThreshold.harmonic_iff`,
`ker_hodgeLaplacian`, `mode_decay`, `depth_threshold`) this gives a complete algebraic
+ analytic dossier for one operator family. The directions below push it toward
genuinely new mathematics.

## Results Summary

| Theorem | Statement |
| --- | --- |
| `mpStep_comm` | `(1−α·L)(1−β·L) = (1−β·L)(1−α·L)` for any `L`, `α`, `β`. |
| `mpStep_comm_iterate` | `Tα^m · Tβ^n = Tβ^n · Tα^m`. |
| `mpStep_energy_antitone` | `⟪T^{k+1}r⟫ ≤ ⟪T^k r⟫` when `ρ ≤ 1`. |
| `mpStep_partial_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ (∑_{k<n} ρ^k)·⟪r,r⟫`. |
| `mpStep_total_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)` for `0 ≤ ρ < 1`. |
| `hodge_total_energy_bound` | the budget instantiated at `Δ = up + down`. |

All six are proved with no `sorry`, depending only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research Directions

### 1. The total-energy budget is sharp, and the gap to it measures the spectral gap

`mpStep_total_energy_bound` proves `∑_k ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)`. Conjecture: when `r`
is a single eigenvector of `L` with eigenvalue `λ` and step `α`, the inequality is an
*equality* with `ρ = (1−αλ)²`, and for general `r` the deficit
`⟪r,r⟫/(1−ρ) − ∑_k ⟪T^k r⟫` is a positive-definite quadratic form whose smallest
eigenvalue is controlled by the spectral gap `μ`. The key insight is that on each
eigenline message passing is an *exact* geometric series, so the only slack in the
bound comes from *mixing* eigenvalues — making the deficit a direct, computable probe
of the spectrum. This is falsifiable: pick `L` with two distinct eigenvalues and check
the deficit numerically against the predicted quadratic form. Why now? We already have
the per-mode dynamics (`HodgeSpectralThreshold.mode_decay`) and the aggregate bound in
the same library; the equality case is a finite eigen-expansion away and needs no new
analysis — the single-eigenvector equality is essentially a `geom_series` identity that
the present `mpStep_iterate_contraction` proof already nearly contains.

### 2. Optimal *schedules* beat constant steps, and order genuinely does not matter

Because `mpStep_comm_iterate` makes a heterogeneous schedule order-independent, the
depth-`k` operator is `∏_{i<k}(1 − α_i·L)`, a degree-`k` polynomial in `L` vanishing
nowhere on `ker L`. Conjecture: choosing `{α_i}` to be reciprocals of Chebyshev nodes
on `[μ, λ_max]` minimises the worst-case residual energy over the spectrum, strictly
beating any constant step for `k ≥ 2`, with explicit rate
`1/T_k((λ_max+μ)/(λ_max−μ))`. The key insight is that order-independence turns schedule
design into *polynomial approximation on the spectrum* — exactly where Chebyshev
polynomials are extremal. This is falsifiable: a two-layer schedule with the predicted
Chebyshev steps must strictly out-contract any single repeated step on a two-mode
spectrum. Why now? `mpStep_comm` / `mpStep_comm_iterate` are the precise algebraic fact
(commuting layers ⇒ a single product polynomial) that legitimises importing Chebyshev
acceleration theory; the polynomial framing is now formally available.

### 3. The discrete Dirichlet action Γ-converges to the continuous Hodge flow

`mpStep_total_energy_bound` is the discrete analogue of `∫₀^∞ ‖∇u(t)‖² dt < ∞`.
Conjecture: as the step `α → 0` with depth `k ≈ t/α`, the discrete total energy
`α·∑_{k<t/α} ⟪T^k r⟫` converges to the continuous Dirichlet action
`∫₀^t ⟪e^{−sL} r, L e^{−sL} r⟫ ds` of the Hodge heat semigroup, and the harmonic limit
of `T^k` coincides with the orthogonal projector onto `ker L`. The key insight is that
the geometric budget `⟪r,r⟫/(1−ρ)` is the Riemann sum of the exponential integral, so
the discrete law is not an analogy but a *quadrature* of the continuous one. This is
falsifiable: the `α → 0` limit of `α·∑ ⟪T^k r⟫` must equal `⟪r,r⟫/(2L)`-type closed
forms on each eigenline. Why now? The uniform-in-`n` bound proved here is exactly the
equi-coercivity hypothesis a Γ-convergence / semigroup-limit argument needs, and
Mathlib now carries enough one-parameter semigroup theory to state the limit.

### 4. A cross-domain bridge: integrated energy bounds expander mixing on the up-Laplacian

The catalog has an expander program (`Algebra/ExpanderWalk/Amplification`,
`Algebra/ClassicalGroupExpanders`). Conjecture: instantiating `L` as the *normalised
up-Hodge Laplacian* of an expander complex, the finite total-energy budget
`⟪r,r⟫/(1−ρ)` with `ρ = 1 − gap` reproduces and quantitatively sharpens the
expander-mixing lemma for `k`-dimensional simplicial walks, with the spectral gap of
`Δ` replacing the second graph eigenvalue. The key insight is that message-passing
energy decay and random-walk mixing are the *same* operator inequality read in two
languages — Dirichlet-energy contraction versus L²-mixing. This is falsifiable:
feeding the up-Laplacian spectral gap into `hodge_total_energy_bound` must yield a
mixing constant matching (or beating) the classical bound on a concrete expander. Why
now? Both halves now live in this catalog with compatible self-adjoint-PSD interfaces
(`HodgeSpectralThreshold` PSD lemmas, the expander spectral data), so the bridge is a
matter of matching hypotheses rather than building new spectral theory.

### 5. Antitonicity characterises admissible (stable) learning rates exactly

`mpStep_energy_antitone` assumes a sub-unital contraction (`ρ ≤ 1`). Conjecture: for a
self-adjoint PSD `L` with top eigenvalue `λ_max`, per-layer energy antitonicity for
*all* inputs holds **iff** `0 ≤ α ≤ 2/λ_max`, and the boundary `α = 2/λ_max` is the
unique step where some mode is merely preserved (energy constant) rather than strictly
decreased. The key insight is that antitonicity is equivalent to the operator
inequality `0 ≼ T ≼ 1`, i.e. `‖1 − αL‖ ≤ 1`, a clean spectral condition on `α`. This
is falsifiable: at `α slightly above 2/λ_max` the top eigenvector must show *increasing*
energy, breaking antitonicity. Why now? The forward direction is one short step from the
proved `mpStep_contraction` / `mpStep_energy_antitone`; the converse needs only a single
extremal eigenvector, giving a falsifiable iff that pins down the stability region.
