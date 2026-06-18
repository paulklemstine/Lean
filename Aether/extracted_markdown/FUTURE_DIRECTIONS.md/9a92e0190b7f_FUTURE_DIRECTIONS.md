# Future Directions: Deepening Perturbation-Stable Generalization

## Synthesis

This cycle deepened the perturbation-stable Occam bound of
`Catalog/MachineLearning/PerturbedGeneralization.lean`. That earlier file showed
adversarial robustness costs exactly one additive scalar `L·ρ` on top of the
compression (Occam / MDL) generalization bound
`occamBound R C n δ = R + sqrt((C + log(1/δ))/(2n))` from
`Catalog/MachineLearning/CompressionGeneralization.lean`. We pressure-tested that
scalar from every structural angle and pinned it down as the *unique
linear-in-`(L,ρ)`, compositional* correction, with a statistically irreducible
floor.

## Results Summary

`Catalog/MachineLearning/PerturbedGeneralizationDeep.lean` adds eight fully proved
theorems (no `sorry`, only the standard `propext / Classical.choice / Quot.sound`
axioms):

1. `lipschitz_perturbation_abs_le` — two-sided per-point bound `|ℓ y − ℓ x| ≤ L·ρ`.
2. `lipschitz_perturbation_sharp` — the `L·ρ` increase is *achieved* by `t ↦ L·t`,
   so the robust empirical risk `R + L·ρ` is best possible (adversarial ground truth).
3. `perturbedOccamBound_mono_radius` / `perturbedOccamBound_mono_lip` — monotonicity
   in the attack radius and in the Lipschitz sensitivity.
4. `perturbed_radius_gap` — changing the radius moves the bound by *exactly* `L·Δρ`;
   the capacity penalty cancels identically.
5. `perturbed_certified_radius` — inversion in `ρ`: the maximal certifiable attack
   radius keeping the bound within a budget.
6. `perturbed_composition_robustness` — robustness budgets *multiply* through
   composed Lipschitz layers (`K·M·ρ`), connecting to the depth-scaling theme of
   `ResNetLipschitz` and `ReLUDepthWidth`.
7. `perturbed_irreducible_gap` — combined with the catalog's `perturbed_bound_tendsto`,
   when `L·ρ > 0` the robustness floor is strictly above the clean risk and survives
   every sample size.

We also repaired the package configuration (`srcDir = "Catalog"` in `lakefile.toml`)
so the `MachineLearning.*` module namespace resolves; without it the catalog did
not compile.

## Bold, Falsifiable Research Directions

### 1. A sharp lower-bound companion: is `R + L·ρ` the *minimax* robust risk?
We proved `L·ρ` is achievable, but achievability of an upper bound is weaker than
optimality of the certificate. Conjecture: over the class of `L`-Lipschitz losses
and `ρ`-bounded adversaries, the *minimax* perturbed empirical risk equals exactly
`R + L·ρ` — no learner can certify less, and the linear loss is the worst case.
**The key insight is** that `lipschitz_perturbation_sharp` already exhibits the
extremal loss, so the missing half is a matching lower bound quantified over all
adversaries, turning a one-sided inequality into an equality (a saddle point).
**Why now?** The achievability witness is in hand and the two-sided bound
`lipschitz_perturbation_abs_le` gives the symmetric control needed to close the
gap; the remaining work is a `⨆`/`⨅` formalization, not new analysis.
*Falsifiable:* exhibit an `L`-Lipschitz loss whose worst-case perturbed risk is
provably `< R + L·ρ` for all `ρ`.

### 2. Sub-multiplicative depth: do real networks beat `∏ Lᵢ · ρ`?
`perturbed_composition_robustness` gives `K·M·ρ` for two layers, hence `(∏ Lᵢ)·ρ`
for a depth-`d` chain — exponential in depth if each `Lᵢ > 1`. Conjecture: with a
contraction/normalization layer (spectral norm ≤ 1, as in `ResNetLipschitz`) the
product telescopes and the effective robustness constant stays *bounded in depth*.
**The key insight is** that the multiplicative blow-up is an artifact of worst-case
layerwise composition, and a single norm-constrained layer caps the product the way
residual connections cap gradient growth.
**Why now?** The composition theorem isolates exactly where depth enters (the
product of Lipschitz constants), so a normalization hypothesis can be slotted in
and the telescoping proved by induction over layers.
*Falsifiable:* a normalized network whose certified robust risk still grows
exponentially in depth would refute it.

### 3. Stochastic perturbations: does the floor drop from `L·ρ` to `L·E[‖noise‖]`?
Our radius `ρ` is a deterministic worst case. Conjecture: under *random* (e.g.
Gaussian) perturbations the irreducible floor of `perturbed_irreducible_gap`
softens from `L·ρ` to `L·𝔼‖δ‖`, strictly smaller, recovering a PAC-Bayes-style
average-case robustness bound that interpolates with the catalog's `PACBayes`
thread.
**The key insight is** that `robust_empRisk_valid` averages a *pointwise* bound, so
replacing the per-point `dist ≤ ρ` hypothesis by an expectation immediately yields
an expectation bound by linearity of `∑`/`𝔼`.
**Why now?** Mathlib's measure/integration and `MeasureTheory.lintegral` machinery
make the expectation step routine, and the deterministic skeleton is already proved.
*Falsifiable:* a distribution where average-case robust risk exceeds the worst-case
`L·ρ` floor would refute it.

### 4. Tightness of the *capacity* penalty under perturbation.
We showed the robustness term is sharp; is the `sqrt((C+log(1/δ))/(2n))` penalty
still sharp after the `R ↦ R + L·ρ` shift, or does perturbation interact with the
confidence `δ`? Conjecture: the two axes remain fully decoupled — the optimal `δ`
trade-off is *independent* of `(L,ρ)`, so `perturbed_radius_gap`'s cancellation is
not a coincidence but a structural orthogonality.
**The key insight is** that `perturbed_radius_gap` already proves the penalty is
constant in `ρ`; the conjecture upgrades this to an optimality statement over `δ`.
**Why now?** `occam_sample_complexity` and `perturbed_sample_complexity` provide the
inversion lemmas needed to compare optimal `δ` choices with and without the shift.
*Falsifiable:* a regime where the penalty-minimizing `δ` depends on `ρ`.

### 5. Beyond Lipschitz: Hölder-stable losses and a `ρ^α` robustness floor.
Lipschitz is `α = 1` Hölder. Conjecture: for an `(L,α)`-Hölder loss the robust
empirical risk becomes `R + L·ρ^α`, and all of this file's structure survives with
`ρ` replaced by `ρ^α` — monotonicity, the radius gap `L·(ρ₂^α − ρ₁^α)`, and the
irreducible floor.
**The key insight is** that every proof here used only `dist_le_mul` once; swapping
it for the Hölder inequality `dist(f x)(f y) ≤ L·dist(x,y)^α` propagates verbatim.
**Why now?** Hölder continuity is in Mathlib (`HolderWith`), so the generalization
is a controlled refactor of an already-verified template, ideal for the next cycle.
*Falsifiable:* a Hölder loss whose perturbed risk is not `O(ρ^α)`.
