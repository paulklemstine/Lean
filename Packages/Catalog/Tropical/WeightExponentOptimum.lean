import Tropical.WeightExponentTropicalLimit

/-!
# Existence of an optimal weight exponent

Exp-586 reports an *interior* maximum of `α ↦ R²(α)` at `α̂ = 1/2`.  This file proves that
such an optimum must exist whenever the dial beats its own tropical limit anywhere on the
grid — i.e. the empirical single-peaked picture is forced, not accidental.

* `OptimalExponent.continuous_dialSum` : `α ↦ S_α` is continuous.
* `OptimalExponent.continuous_R2_dial` : so is the whole selection functional `α ↦ R²(α)`,
  away from degenerate data.
* `OptimalExponent.exists_max_R2` : **existence of an optimal exponent.**  If some
  exponent `α₀ ≥ 0` beats the tropical limiting value `R²(∞)`, then the supremum of `R²`
  over `[0, ∞)` is *attained*: there is `α* ≥ 0` with `R²(α) ≤ R²(α*)` for all `α ≥ 0`.
* `OptimalExponent.exists_interior_max_R2` : if in addition the unweighted endpoint
  `α = 0` is beaten as well, the maximizer can be taken with `α* > 0` — a genuinely
  interior optimum, exactly the qualitative shape measured at `α̂ = 1/2`.

The proof combines the tropical limit `TropicalLimit.tendsto_R2_atTop` (which caps the
behaviour at large exponents) with compactness of `[0, T]`.
-/

open Filter Set Finset

namespace OptimalExponent

open FitLayer WeightDial TropicalLimit

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The dial statistic depends continuously on the weight exponent. -/
theorem continuous_dialSum {supp : Finset ℕ} (h2 : ∀ l ∈ supp, 2 ≤ l) :
    Continuous (fun α : ℝ => dialSum supp α) := by
  unfold dialSum dialWeight
  refine continuous_finset_sum supp fun l hl => ?_
  have hl0 : (0 : ℝ) < (l : ℝ) := by
    have := h2 l hl; exact_mod_cast (by omega : 0 < l)
  exact (Real.continuous_const_rpow (ne_of_gt hl0)).comp continuous_neg

omit [Nonempty ι] in
/-- The mean of a continuously varying data vector is continuous. -/
theorem continuous_mean {x : ℝ → ι → ℝ} (hx : ∀ i, Continuous fun t => x t i) :
    Continuous fun t => mean (x t) := by
  unfold mean
  exact (continuous_finset_sum Finset.univ fun i _ => hx i).div_const _

omit [Nonempty ι] in
/-- The covariance of continuously varying data vectors is continuous. -/
theorem continuous_cov {x y : ℝ → ι → ℝ} (hx : ∀ i, Continuous fun t => x t i)
    (hy : ∀ i, Continuous fun t => y t i) :
    Continuous fun t => cov (x t) (y t) := by
  unfold cov
  refine continuous_finset_sum Finset.univ fun i _ => ?_
  exact ((hx i).sub (continuous_mean hx)).mul ((hy i).sub (continuous_mean hy))

omit [Nonempty ι] in
/-- **The selection functional is continuous.** -/
theorem continuous_R2_dial (supp : ι → Finset ℕ) (h2 : ∀ i, ∀ l ∈ supp i, 2 ≤ l)
    (y : ι → ℝ)
    (hnd : ∀ α : ℝ, varr (fun i => dialSum (supp i) α) * varr y ≠ 0) :
    Continuous fun α : ℝ => R2 (fun i => dialSum (supp i) α) y := by
  have hx : ∀ i : ι, Continuous fun α : ℝ => dialSum (supp i) α :=
    fun i => continuous_dialSum (h2 i)
  have hcov : Continuous fun α : ℝ => cov (fun i => dialSum (supp i) α) y :=
    continuous_cov hx (fun _ => continuous_const)
  have hvar : Continuous fun α : ℝ =>
      varr (fun i => dialSum (supp i) α) * varr y :=
    (continuous_cov hx hx).mul continuous_const
  exact (hcov.pow 2).div hvar hnd

/-- **Existence of an optimal weight exponent.**  If some exponent beats the tropical
limiting value, the best exponent exists (the supremum over `[0, ∞)` is attained). -/
theorem exists_max_R2 (supp : ι → Finset ℕ) {M : ℕ} (hM : 2 ≤ M)
    (h2 : ∀ i, ∀ l ∈ supp i, 2 ≤ l) (hmin : ∀ i, ∀ l ∈ supp i, M ≤ l) (y : ι → ℝ)
    (hnd : ∀ α : ℝ, varr (fun i => dialSum (supp i) α) * varr y ≠ 0)
    (hden : varr (tropDial supp M) * varr y ≠ 0)
    {α₀ : ℝ} (hα₀ : 0 ≤ α₀)
    (hbeat : R2 (tropDial supp M) y < R2 (fun i => dialSum (supp i) α₀) y) :
    ∃ αstar : ℝ, 0 ≤ αstar ∧
      ∀ α : ℝ, 0 ≤ α → R2 (fun i => dialSum (supp i) α) y
        ≤ R2 (fun i => dialSum (supp i) αstar) y := by
  set f : ℝ → ℝ := fun α => R2 (fun i => dialSum (supp i) α) y with hf
  have hcont : Continuous f := continuous_R2_dial supp h2 y hnd
  have hlim := tendsto_R2_atTop supp hM h2 hmin y hden
  -- beyond some `T`, the tail of the curve is below the value at `α₀`
  have hev : ∀ᶠ α in atTop, f α < f α₀ := by
    have := hlim.eventually (eventually_lt_nhds hbeat)
    exact this
  obtain ⟨T₀, hT₀⟩ := eventually_atTop.1 hev
  set T := max T₀ α₀ with hT
  have hα₀T : α₀ ≤ T := le_max_right _ _
  have hcompact : IsCompact (Icc (0 : ℝ) T) := isCompact_Icc
  have hne : (Icc (0 : ℝ) T).Nonempty := ⟨α₀, hα₀, hα₀T⟩
  obtain ⟨αstar, hmem, hmax⟩ := hcompact.exists_isMaxOn hne hcont.continuousOn
  refine ⟨αstar, hmem.1, fun α hα => ?_⟩
  rcases le_or_gt α T with h | h
  · exact hmax ⟨hα, h⟩
  · have hαT₀ : T₀ ≤ α := le_trans (le_max_left T₀ α₀) (le_of_lt h)
    have h1 : f α < f α₀ := hT₀ α hαT₀
    have h2' : f α₀ ≤ f αstar := hmax ⟨hα₀, hα₀T⟩
    exact le_of_lt (lt_of_lt_of_le h1 h2')

/-- **Existence of a strictly interior optimum.**  If, in addition, the unweighted
statistic `α = 0` is strictly beaten, the optimal exponent is positive: weighting is
necessary, and unbounded sharpening of the weight is harmful. -/
theorem exists_interior_max_R2 (supp : ι → Finset ℕ) {M : ℕ} (hM : 2 ≤ M)
    (h2 : ∀ i, ∀ l ∈ supp i, 2 ≤ l) (hmin : ∀ i, ∀ l ∈ supp i, M ≤ l) (y : ι → ℝ)
    (hnd : ∀ α : ℝ, varr (fun i => dialSum (supp i) α) * varr y ≠ 0)
    (hden : varr (tropDial supp M) * varr y ≠ 0)
    {α₀ : ℝ} (hα₀ : 0 < α₀)
    (hbeat : R2 (tropDial supp M) y < R2 (fun i => dialSum (supp i) α₀) y)
    (hbeat0 : R2 (fun i => dialSum (supp i) 0) y
      < R2 (fun i => dialSum (supp i) α₀) y) :
    ∃ αstar : ℝ, 0 < αstar ∧
      ∀ α : ℝ, 0 ≤ α → R2 (fun i => dialSum (supp i) α) y
        ≤ R2 (fun i => dialSum (supp i) αstar) y := by
  obtain ⟨αstar, hpos, hmax⟩ :=
    exists_max_R2 supp hM h2 hmin y hnd hden (le_of_lt hα₀) hbeat
  refine ⟨αstar, ?_, hmax⟩
  rcases lt_or_eq_of_le hpos with h | h
  · exact h
  · exfalso
    have := hmax α₀ (le_of_lt hα₀)
    rw [← h] at this
    exact absurd this (not_le.2 hbeat0)

end OptimalExponent