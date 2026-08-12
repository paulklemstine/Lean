/-
# The Band-Spread Law (Factoring Lab, Phase A v19c — cycle 2)

Formalizing the *reduction* asserted by **Conjecture 4** of
`FUTURE_DIRECTIONS.md`: the whole empirical near-equal-`N` programme collapses
to a single analytic quantity, the **spread of the band means**.

The previous cycle proved the hypothesis-free Cauchy–Schwarz bound
`FactoringLab.cov_sq_le_variance_mul_variance_bandMean`:
`cov(g∘n, Y)² ≤ Var(g∘n) · Var(E[Y | n])`.
Here that inequality is converted into the statement the conjecture actually
uses, about the *correlation*:

* `FactoringLab.variance_nonneg` — the empirical variance is nonnegative;
* `FactoringLab.abs_corr_le_sqrt_variance_ratio` — for **every** invariant
  computable from the band label alone,
  `|corr(g∘n, Y)| ≤ √( Var(E[Y | n]) / Var Y )`,
  with no hypothesis beyond `Var Y > 0`;
* `FactoringLab.band_spread_law` — the conjecture's shape: if the band means
  have spread at most `ε · Var Y`, then every `N`-only invariant has
  `|corr| ≤ √ε`;
* `FactoringLab.corr_eq_zero_of_bandMean_variance_zero` — the degenerate case:
  zero spread forces exactly zero correlation;
* `FactoringLab.total_variance` — the law of total variance for the band
  decomposition, `Var Y = (within-band error) + Var(E[Y | n])`, which identifies
  the band spread as exactly the fraction of the variance the band label
  explains, and `FactoringLab.abs_corr_le_sqrt_explained_fraction`, the
  resulting bound on every `N`-only correlation.

So the near-equal-`N` test is not a heuristic: the measured correlations of
`N`-only invariants are bounded by an intrinsic property of the population,
uniformly over all invariants.  What remains of Conjecture 4 is purely
analytic — an estimate of `Var(E[p | N])` for semiprimes in a size band, which
is a statement about the distribution of the smaller factor and involves no
invariant at all.
-/
import Mathlib
import Probability.StructuralOrthogonality

namespace FactoringLab

variable {ι κ : Type*} [DecidableEq κ]

/-- The empirical variance as a sum of squared deviations. -/
theorem variance_eq_sum_sq (Ω : Finset ι) (X : ι → ℝ) :
    variance Ω X = (∑ i ∈ Ω, (X i - expect Ω X) ^ 2) / Ω.card := by
  rw [variance, cov_centered Ω X X]
  exact congrArg (· / (Ω.card : ℝ)) (Finset.sum_congr rfl fun i _ => by ring)

/-- The empirical variance is nonnegative. -/
theorem variance_nonneg (Ω : Finset ι) (X : ι → ℝ) : 0 ≤ variance Ω X := by
  rw [variance_eq_sum_sq]
  exact div_nonneg (Finset.sum_nonneg fun i _ => sq_nonneg _) (Nat.cast_nonneg _)

/-! ## The law of total variance -/

/-- **Law of total variance for the band decomposition.**  The variance of the
target splits exactly into the mean residual (within-band) error plus the
variance of the band means (between-band spread).  This identifies the quantity
controlling every `N`-only correlation: the band spread is precisely the part
of the variance that the band label explains. -/
theorem total_variance (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) :
    variance Ω Y
      = (∑ i ∈ Ω, (Y i - bandMean Ω n Y i) ^ 2) / Ω.card
        + variance Ω (bandMean Ω n Y) := by
  have hcross :
      ∑ i ∈ Ω, (bandMean Ω n Y i - expect Ω Y) * (Y i - bandMean Ω n Y i) = 0 := by
    have h := structural_orthogonality Ω n Y (fun k => bandMeanFn Ω n Y k - expect Ω Y)
    simpa [bandMeanFn_comp] using h
  have hsplit : ∑ i ∈ Ω, (Y i - expect Ω Y) ^ 2
      = ∑ i ∈ Ω, (Y i - bandMean Ω n Y i) ^ 2
        + ∑ i ∈ Ω, (bandMean Ω n Y i - expect Ω Y) ^ 2 := by
    have hexp : ∀ i, (Y i - expect Ω Y) ^ 2
        = (Y i - bandMean Ω n Y i) ^ 2 + (bandMean Ω n Y i - expect Ω Y) ^ 2
          + 2 * ((bandMean Ω n Y i - expect Ω Y) * (Y i - bandMean Ω n Y i)) :=
      fun i => by ring
    rw [Finset.sum_congr rfl (fun i _ => hexp i), Finset.sum_add_distrib,
      Finset.sum_add_distrib, ← Finset.mul_sum, hcross, mul_zero, add_zero]
  rw [variance_eq_sum_sq Ω Y, variance_eq_sum_sq Ω (bandMean Ω n Y),
    expect_bandMean Ω n Y, hsplit, add_div]

/-- The band spread never exceeds the total variance. -/
theorem variance_bandMean_le (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) :
    variance Ω (bandMean Ω n Y) ≤ variance Ω Y := by
  rw [total_variance Ω n Y]
  have : 0 ≤ (∑ i ∈ Ω, (Y i - bandMean Ω n Y i) ^ 2) / Ω.card :=
    div_nonneg (Finset.sum_nonneg fun i _ => sq_nonneg _) (Nat.cast_nonneg _)
  linarith

/-- **The band-spread bound on correlations.**  For every invariant `g ∘ n`
computable from the band label alone, the Pearson correlation with the target
is controlled by the ratio of the *variance of the band means* to the variance
of the target — uniformly in `g`. -/
theorem abs_corr_le_sqrt_variance_ratio (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (g : κ → ℝ) (hY : 0 < variance Ω Y) :
    |corr Ω (fun i => g (n i)) Y|
      ≤ Real.sqrt (variance Ω (bandMean Ω n Y) / variance Ω Y) := by
  set X : ι → ℝ := fun i => g (n i) with hX
  set vX := variance Ω X with hvX
  set vB := variance Ω (bandMean Ω n Y) with hvB
  have hvX0 : 0 ≤ vX := variance_nonneg Ω X
  have hvB0 : 0 ≤ vB := variance_nonneg Ω _
  have hkey : (cov Ω X Y) ^ 2 ≤ vX * vB :=
    cov_sq_le_variance_mul_variance_bandMean Ω n Y g
  have habs : |cov Ω X Y| ≤ Real.sqrt vX * Real.sqrt vB := by
    have h1 : |cov Ω X Y| = Real.sqrt ((cov Ω X Y) ^ 2) := (Real.sqrt_sq_eq_abs _).symm
    rw [h1, ← Real.sqrt_mul hvX0]
    exact Real.sqrt_le_sqrt hkey
  rcases eq_or_lt_of_le hvX0 with hzero | hpos
  · -- a constant invariant has zero variance, hence zero correlation
    have : corr Ω X Y = 0 := by
      unfold corr
      rw [← hvX, ← hzero, Real.sqrt_zero, zero_mul, div_zero]
    rw [this, abs_zero]
    exact Real.sqrt_nonneg _
  · have hsX : 0 < Real.sqrt vX := Real.sqrt_pos.2 hpos
    have hsY : 0 < Real.sqrt (variance Ω Y) := Real.sqrt_pos.2 hY
    have hcorr : |corr Ω X Y| = |cov Ω X Y| / (Real.sqrt vX * Real.sqrt (variance Ω Y)) := by
      unfold corr
      rw [abs_div, abs_of_pos (mul_pos hsX hsY)]
    rw [hcorr, Real.sqrt_div' _ (le_of_lt hY)]
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    calc |cov Ω X Y| * Real.sqrt (variance Ω Y)
        ≤ (Real.sqrt vX * Real.sqrt vB) * Real.sqrt (variance Ω Y) := by
          exact mul_le_mul_of_nonneg_right habs (Real.sqrt_nonneg _)
      _ = Real.sqrt vB * (Real.sqrt vX * Real.sqrt (variance Ω Y)) := by ring

/-- **The band-spread law (reduction form).**  If, on the population under
study, the band means have spread at most `ε` times the spread of the target,
then *every* `N`-only invariant — linear or not, single or aggregated — has
correlation at most `√ε` with the hidden factor. -/
theorem band_spread_law (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (ε : ℝ)
    (hY : 0 < variance Ω Y) (hspread : variance Ω (bandMean Ω n Y) ≤ ε * variance Ω Y)
    (g : κ → ℝ) : |corr Ω (fun i => g (n i)) Y| ≤ Real.sqrt ε := by
  refine le_trans (abs_corr_le_sqrt_variance_ratio Ω n Y g hY) ?_
  apply Real.sqrt_le_sqrt
  rw [div_le_iff₀ hY]
  exact hspread

/-- **Explained-variance form.**  The correlation of any `N`-only invariant with
the target is at most the square root of the *fraction of the variance explained
by the band label*; equivalently, the larger the irreducible within-band error,
the smaller every `N`-only correlation must be. -/
theorem abs_corr_le_sqrt_explained_fraction (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (g : κ → ℝ) (hY : 0 < variance Ω Y) :
    |corr Ω (fun i => g (n i)) Y|
      ≤ Real.sqrt (1 - ((∑ i ∈ Ω, (Y i - bandMean Ω n Y i) ^ 2) / Ω.card)
          / variance Ω Y) := by
  have hratio : variance Ω (bandMean Ω n Y) / variance Ω Y
      = 1 - ((∑ i ∈ Ω, (Y i - bandMean Ω n Y i) ^ 2) / Ω.card) / variance Ω Y := by
    field_simp
    linarith [total_variance Ω n Y]
  rw [← hratio]
  exact abs_corr_le_sqrt_variance_ratio Ω n Y g hY

/-- Zero spread of the band means forces exactly zero correlation, for every
`N`-only invariant. -/
theorem corr_eq_zero_of_bandMean_variance_zero (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (hY : 0 < variance Ω Y) (hzero : variance Ω (bandMean Ω n Y) = 0) (g : κ → ℝ) :
    corr Ω (fun i => g (n i)) Y = 0 := by
  have h := abs_corr_le_sqrt_variance_ratio Ω n Y g hY
  rw [hzero, zero_div, Real.sqrt_zero] at h
  exact abs_eq_zero.1 (le_antisymm h (abs_nonneg _))

end FactoringLab