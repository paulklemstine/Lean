import Mathlib
import Shared.AttentionBudgetKnee
import Pythagorean.NET79GeometricRatioKnee
import Pythagorean.NET79PythagoreanInversion
import Pythagorean.NET79ScaleContextSurface

/-!
# Localising the crossover

`Pythagorean/NET79ScaleContextSurface.lean` shows that the ordering of two knee curves
can invert with context.  The NET-79 round asks the obvious follow-up question: *where*
does the crossover happen?  This file answers it with an explicit, checkable bound.

* `crossover_context_bound` — if profile `v` has a context-free budget `K` and profile
  `w` has weights confined to a band `[c, M]` with `c > 0`, then the crossover has
  already happened at every context `n ≥ (K+1)·M/(τ·c)`.  The phase transition cannot
  be postponed beyond that point; the bound involves only the gate, the band and the
  budget.
* `crossover_bound_profGap_profFloor` — the explicit instance for the two witness
  profiles: `n ≥ 5562` suffices.
* `pyth_intra_triple_budget_separation` — the Pythagorean instance: there is a single
  triple whose *own* two legs separate, the long leg needing more keys than the
  universal short-leg budget `13` of `pyth_short_leg_budget_le_thirteen`.  Inversion is
  therefore visible inside one arithmetic object, not only across a pair of them.

-- !-- Lab Notes -- !--
Hypothesizer:
 (C1) The crossover context is bounded by an explicit function of the gate, the
      spectral-gap budget and the floor-to-cap ratio.                        [BOLD]
 (C2) Inversion happens inside a single Pythagorean triple.                  [BOLD]
Experimenter: both proved below, zero sorries.  Numerically, for the pair
`(1/2)^i` versus `(1/16)^i + 1/1000` at gate `0.9` the bound reads
`(4+1)·1.001/(0.9·0.001) = 5561.1…`, so `n = 5562` is certified; the surface file
already exhibits the inversion at the smaller context `5000`, so the bound is an upper
estimate and not sharp.
Analyst: the bound scales like `M/(τ c)`, i.e. inversely with the floor.  A profile
whose tail floor is `10×` smaller postpones its phase transition `10×` further out —
which is the structural reason a phase transition can look absent at short contexts and
then arrive abruptly.
Critic: the hypothesis `∀ n, 0 < n → kstar v n τ ≤ K` is exactly what
`kstar_uniformly_bounded_of_geometric_decay` supplies, so the theorem is not vacuous;
`crossover_bound_profGap_profFloor` instantiates it with a concrete pair.
-/

namespace PythKnee

open AttentionBudget

/-- **Crossover localisation.**  A profile with a context-free budget `K` is beaten by a
band-limited profile at every context past `(K+1)·M/(τ·c)`. -/
theorem crossover_context_bound {v w : ℕ → ℝ} {τ c M : ℝ} {K n : ℕ}
    (hw : ∀ i, 0 < w i) (hc : 0 < c)
    (hlow : ∀ i, c ≤ w i) (hhigh : ∀ i, w i ≤ M) (hτ0 : 0 < τ) (hτ : τ ≤ 1)
    (hK : ∀ m : ℕ, 0 < m → kstar v m τ ≤ K)
    (hn : ((K : ℝ) + 1) * M / (τ * c) ≤ (n : ℝ)) :
    kstar v n τ < kstar w n τ := by
  have hM : 0 < M := lt_of_lt_of_le hc ((hlow 0).trans (hhigh 0))
  have hpos : (0 : ℝ) < ((K : ℝ) + 1) * M / (τ * c) := by positivity
  have hnR : (0 : ℝ) < (n : ℝ) := lt_of_lt_of_le hpos hn
  have hn0 : 0 < n := by exact_mod_cast hnR
  have hlower := kstar_ge_of_bounded_ratio hw hc hlow hhigh hn0 hτ
  have hkey : ((K : ℝ) + 1) ≤ τ * n * c / M := by
    rw [le_div_iff₀ hM]
    rw [div_le_iff₀ (by positivity)] at hn
    nlinarith
  have hbig : ((K : ℝ) + 1) ≤ (kstar w n τ : ℝ) := le_trans hkey hlower
  have hbigN : K + 1 ≤ kstar w n τ := by exact_mod_cast hbig
  have := hK n hn0
  omega

/-- The explicit crossover bound for the two witness profiles of the surface file:
past context `5562` the gapped profile is strictly cheaper. -/
theorem crossover_bound_profGap_profFloor {n : ℕ} (hn : 5562 ≤ n) :
    kstar profGap n (9 / 10) < kstar profFloor n (9 / 10) := by
  have hnR : (5562 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  refine crossover_context_bound (K := 4) (c := 1 / 1000) (M := 1 + 1 / 1000)
    profFloor_pos (by norm_num) profFloor_lower profFloor_upper (by norm_num)
    (by norm_num) (fun m hm => kstar_profGap_le_four hm) ?_
  have : ((4 : ℝ) + 1) * (1 + 1 / 1000) / (9 / 10 * (1 / 1000)) ≤ 5562 := by norm_num
  linarith

/-- **Inversion inside a single triple.**  There is a Pythagorean triple and a context
at which the long-leg profile needs more than `13` keys — strictly more than the
universal budget that its own short leg is guaranteed to meet at *every* context. -/
theorem pyth_intra_triple_budget_separation :
    ∃ a b c : ℤ, ∃ n : ℕ, IsPythTriple a b c ∧ 0 < a ∧ a ≤ b ∧ 0 < c ∧ 0 < n ∧
      kstar (geomProfile (legRatio a c)) n (985 / 1000) < kstar (geomProfile (legRatio b c)) n
        (985 / 1000) := by
  obtain ⟨a, b, c, n, htriple, ha, hab, hc, hn, hlong⟩ := pyth_long_leg_budget_unbounded 13
  refine ⟨a, b, c, n, htriple, ha, hab, hc, hn, ?_⟩
  have hshort := pyth_short_leg_budget_le_thirteen htriple ha hab hc hn
  omega

end PythKnee