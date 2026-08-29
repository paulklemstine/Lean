import Bridges.Ma1EffectivityCeiling

/-!
# The cell-gap calculus: a null `R²` bounds every pairwise cell separation

`Bridges.Ma1EffectivityCeiling` caps the margin of a *threshold* criterion.  A criterion
need not be a threshold: it may read the L-mass feature at arbitrary resolution and act on
each level set separately.  This file removes the threshold restriction.

Main results.

* `tss_eq_withinSS_add_betweenSS` — the exact ANOVA decomposition of a finite sample along
  the level sets of an arbitrary feature: `TSS = withinSS + betweenSS`.
* `rsq_measurableClass_mul_tss` — the explained energy of the class of *all* functions of a
  feature is exactly the between-cell energy.
* `two_cell_energy_le` — the elementary two-cell inequality
  `(n_a n_b/(n_a+n_b))(m_a−m_b)² ≤ n_a(m_a−m)² + n_b(m_b−m)²`.
* `cell_mean_gap_le_of_rsq` — **the cell-gap ceiling.**  If the whole class of functions of
  the feature `P` explains at most a fraction `ρ` of the variance, then *any two* level
  sets of `P`, of sizes `n_a` and `n_b`, have response means separated by at most
  `ρ·TSS·(1/n_a + 1/n_b)` in square.  No criterion reading `P` at any resolution can
  separate two groups of moduli by more than that.
* `exp566_cell_gap_ceiling` — the recorded stage-B instance, `ρ = 0.0785`.

Together with `ma1_no_criterion_dichotomy` this is the strongest honest reading of the
experiment-566 null: not "L-values are uncorrelated with deviation", but "no partition of
the moduli by L-mass separates the deviation field by more than an explicitly bounded gap".
-/

namespace Ma1Effectivity

open Finset QRResidual

open scoped Classical

variable {ι : Type*} [Fintype ι] {α : Type*}

/-! ## The ANOVA decomposition -/

/-- The between-cell energy of the response along the level sets of a feature. -/
noncomputable def betweenSS (y : ι → ℝ) (f : ι → α) : ℝ :=
  ∑ a ∈ univ.image f, ((cell f a).card : ℝ) * (cellMean y f a - mean y) ^ 2

theorem betweenSS_nonneg (y : ι → ℝ) (f : ι → α) : 0 ≤ betweenSS y f :=
  Finset.sum_nonneg fun _ _ => by positivity

/-- **ANOVA.**  The total sum of squares splits exactly into within-cell and between-cell
energy along the level sets of any feature. -/
theorem tss_eq_withinSS_add_betweenSS (y : ι → ℝ) (f : ι → α) :
    tss y = withinSS y f + betweenSS y f := by
  classical
  have hcomp : sqNorm (y - fun i => (fun _ : α => mean y) (f i))
      = ∑ a ∈ univ.image f, ∑ i ∈ cell f a, (y i - mean y) ^ 2 :=
    sqNorm_sub_comp y f (fun _ => mean y)
  have htss : tss y = ∑ a ∈ univ.image f, ∑ i ∈ cell f a, (y i - mean y) ^ 2 := by
    rw [tss]; exact hcomp
  have hcell : ∀ a ∈ univ.image f, ∑ i ∈ cell f a, (y i - mean y) ^ 2
      = (∑ i ∈ cell f a, (y i - cellMean y f a) ^ 2)
        + ((cell f a).card : ℝ) * (cellMean y f a - mean y) ^ 2 := by
    intro a ha
    have hcard := cell_card_ne_zero (f := f) (a := a) ha
    have h := sum_sub_sq_split (cell f a) y (mean y) hcard
    rw [h]
    have : (mean y - (∑ j ∈ cell f a, y j) / (cell f a).card) ^ 2
        = (cellMean y f a - mean y) ^ 2 := by
      rw [cellMean]; ring
    rw [this, cellMean]
  rw [htss, Finset.sum_congr rfl hcell, Finset.sum_add_distrib]
  rfl

/-- The explained energy of the class of all functions of a feature is exactly the
between-cell energy. -/
theorem rsq_measurableClass_mul_tss (y : ι → ℝ) (f : ι → α) (htss : 0 < tss y) :
    rsq y (measurableClass f) * tss y = betweenSS y f := by
  have hsplit := tss_eq_withinSS_add_betweenSS y f
  rw [rsq, rss_measurableClass]
  field_simp
  linarith

/-! ## The two-cell inequality and the cell-gap ceiling -/

/-- For any reference level `m`, two groups pay at least the pooled between-group energy of
their mean gap. -/
theorem two_cell_energy_le {na nb ma mb m : ℝ} (hna : 0 < na) (hnb : 0 < nb) :
    (na * nb / (na + nb)) * (ma - mb) ^ 2 ≤ na * (ma - m) ^ 2 + nb * (mb - m) ^ 2 := by
  have hsum : 0 < na + nb := by linarith
  rw [div_mul_eq_mul_div, div_le_iff₀ hsum]
  nlinarith [sq_nonneg (na * (ma - m) - nb * (m - mb)), sq_nonneg (ma - mb)]

/-- **The cell-gap ceiling.**  Suppose the class of all functions of the feature `P`
explains at most a fraction `ρ` of the variance.  Then for any two level sets of `P`, of
sizes `n_a` and `n_b`, the response means differ by at most
`ρ·TSS·(1/n_a + 1/n_b)` in square.

With the recorded stage-B ceiling `ρ = 0.0785` this bounds the separation achievable by
*any* criterion that reads the L-mass, at any resolution and with any decision rule. -/
theorem cell_mean_gap_le_of_rsq {y P : ι → ℝ} {ρ : ℝ} {a b : ℝ}
    (ha : a ∈ univ.image P) (hb : b ∈ univ.image P) (hab : a ≠ b)
    (htss : 0 < tss y) (hrsq : rsq y (measurableClass P) ≤ ρ) :
    (cellMean y P a - cellMean y P b) ^ 2
      ≤ ρ * tss y * (1 / ((cell P a).card : ℝ) + 1 / ((cell P b).card : ℝ)) := by
  classical
  set na : ℝ := ((cell P a).card : ℝ) with hna'
  set nb : ℝ := ((cell P b).card : ℝ) with hnb'
  have hna : 0 < na := by
    rw [hna']
    have := cell_card_ne_zero (f := P) (a := a) ha
    have hpos : 0 < (cell P a).card := Nat.pos_of_ne_zero (by exact_mod_cast this)
    exact_mod_cast hpos
  have hnb : 0 < nb := by
    rw [hnb']
    have := cell_card_ne_zero (f := P) (a := b) hb
    have hpos : 0 < (cell P b).card := Nat.pos_of_ne_zero (by exact_mod_cast this)
    exact_mod_cast hpos
  -- the two cells contribute at most the whole between-cell energy
  have hsub : ({a, b} : Finset ℝ) ⊆ univ.image P := by
    intro c hc
    rcases Finset.mem_insert.1 hc with rfl | hc'
    · exact ha
    · rw [Finset.mem_singleton.1 hc']; exact hb
  have hpair : na * (cellMean y P a - mean y) ^ 2 + nb * (cellMean y P b - mean y) ^ 2
      ≤ betweenSS y P := by
    have hnn : ∀ c ∈ univ.image P, c ∉ ({a, b} : Finset ℝ) →
        0 ≤ ((cell P c).card : ℝ) * (cellMean y P c - mean y) ^ 2 := by
      intro c _ _; positivity
    have hle := Finset.sum_le_sum_of_subset_of_nonneg hsub hnn
    have hpairsum : ∑ c ∈ ({a, b} : Finset ℝ), ((cell P c).card : ℝ) * (cellMean y P c - mean y) ^ 2
        = na * (cellMean y P a - mean y) ^ 2 + nb * (cellMean y P b - mean y) ^ 2 := by
      rw [Finset.sum_pair hab]
    rw [hpairsum] at hle
    exact hle
  -- the between-cell energy is the explained energy, which is at most `ρ·TSS`
  have hexp : betweenSS y P ≤ ρ * tss y := by
    rw [← rsq_measurableClass_mul_tss y P htss]
    exact mul_le_mul_of_nonneg_right hrsq (le_of_lt htss)
  have hgap := two_cell_energy_le (ma := cellMean y P a) (mb := cellMean y P b)
    (m := mean y) hna hnb
  have hkey : (na * nb / (na + nb)) * (cellMean y P a - cellMean y P b) ^ 2 ≤ ρ * tss y := by
    linarith
  have hsum : 0 < na + nb := by linarith
  have hcoef : 0 < na * nb / (na + nb) := by positivity
  have hfinal : (cellMean y P a - cellMean y P b) ^ 2 ≤ ρ * tss y / (na * nb / (na + nb)) := by
    rw [le_div_iff₀ hcoef]
    linarith
  calc (cellMean y P a - cellMean y P b) ^ 2
      ≤ ρ * tss y / (na * nb / (na + nb)) := hfinal
    _ = ρ * tss y * (1 / na + 1 / nb) := by field_simp; ring

/-- **Experiment 566, stage B: the cell-gap certificate.**  With the recorded ceiling
`R² ≤ 0.0785` for every function of the L-mass, two L-mass cells of sizes `n_a`, `n_b`
have deviation means separated by at most `0.0785·TSS·(1/n_a + 1/n_b)` in square. -/
theorem exp566_cell_gap_ceiling {y P : ι → ℝ} {a b : ℝ}
    (ha : a ∈ univ.image P) (hb : b ∈ univ.image P) (hab : a ≠ b)
    (htss : 0 < tss y) (hrsq : rsq y (measurableClass P) ≤ 0.0785) :
    (cellMean y P a - cellMean y P b) ^ 2
      ≤ 0.0785 * tss y * (1 / ((cell P a).card : ℝ) + 1 / ((cell P b).card : ℝ)) :=
  cell_mean_gap_le_of_rsq ha hb hab htss hrsq

end Ma1Effectivity