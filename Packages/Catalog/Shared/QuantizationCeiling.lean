import Shared.StarvedDialCeiling

/-!
# Cycle 2: sharpness of the ceiling, and the quantization ceiling (T-DIAL-56)

Cycle 1 (`Shared.TieBlockRankCeiling`, `Shared.RankSpreadLowerBound`,
`Shared.StarvedDialCeiling`) produced a ceiling and an adversarial finding: the
`194/1200` zero-hit block observed at bit length `56` caps `Spearman(T, rate)` at
`0.9979`, which is far above the reported `0.405`.  Two objections remain, and
this file settles both.

**Objection 1 — is the ceiling lossy?**  Maybe the true ceiling is much smaller
and the Cauchy–Schwarz step threw away most of it.  `cov_sq_eq_explained_of_condExp`
shows it does not: the ceiling is *attained*, by the response
`Y = E[X | b]` itself.  So `Var X - W` is exactly the achievable numerator, and
the `0.9979` figure is the true optimum, not an artefact.

**Objection 2 — maybe the whole tie *partition* is what matters, not one block.**
The rate is a count divided by a trial budget, so it is quantized: it takes only
`r` distinct values.  `quantization_ceiling` is the sharpest tie-only bound
available: with only `r` distinct response values,

`ρ² ≤ 1 - (n³/r² - n)/(n³ - n)`,

which for large `n` is `1 - 1/r²`.  `quantization_ceiling_not_binding` then shows
that this is `≥ 3/4` for every `r ≥ 2`.  So *no* tie-based mechanism — one block,
the full partition, or coarse quantization — can push the Spearman coefficient
below `0.55`.

**Conclusion of cycle 2.**  The reported `0.405` at bit length `56` is not a
rank-resolution phenomenon at all.  Ties, whether concentrated in the zero-hit
block or spread across the whole quantization grid, are provably incapable of
producing it.  The residual must be *estimator noise*: at a `0.89 %` smooth rate
the measured rate is a Monte-Carlo estimate whose ranking differs from the true
ranking, and permutation noise attenuates correlation without creating any ties.
The "practical floor near bit length 54" is therefore a statement about the
variance of the rate estimator, not about the dial.
-/

namespace TieCeiling

open Finset

/-! ## Objection 1: the ceiling is attained -/

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]

/-- The block averages have the same mean as the original variable. -/
lemma mean_condExp (X : ι → ℝ) (b : ι → κ) : mean (condExp X b) = mean X := by
  rw [mean, mean, sum_condExp]

/-- **Sharpness of the tie-block ceiling.**  Taking the response to be the block
average `E[X | b]` itself turns the Cauchy–Schwarz inequality of
`cov_sq_le_explained` into an equality.  Hence `Var X - W` is exactly the largest
covariance-squared/variance ratio achievable against any response constant on the
blocks: the ceiling is optimal, not merely an upper bound. -/
theorem cov_sq_eq_explained_of_condExp (X : ι → ℝ) (b : ι → κ) :
    cov X (condExp X b) ^ 2
      = (varOf X - ∑ i, (X i - condExp X b i) ^ 2) * varOf (condExp X b) := by
  have hmean : mean (condExp X b) = mean X := mean_condExp X b
  have hvarP : varOf (condExp X b) = varOf X - ∑ i, (X i - condExp X b i) ^ 2 := by
    have h := var_eq_explained_add_residual X b
    rw [varOf, hmean]
    linarith
  have hcov : cov X (condExp X b) = varOf (condExp X b) := by
    have horth : ∑ i, (X i - condExp X b i) * (blockAvg X b (b i) - mean X) = 0 :=
      sum_residual_mul_comp X b (fun k => blockAvg X b k - mean X)
    have hsplit : ∀ i, (X i - mean X) * (condExp X b i - mean (condExp X b))
        = (X i - condExp X b i) * (blockAvg X b (b i) - mean X)
          + (condExp X b i - mean (condExp X b)) ^ 2 := by
      intro i
      rw [hmean]
      simp only [condExp]
      ring
    rw [cov, Finset.sum_congr rfl (fun i _ => hsplit i), Finset.sum_add_distrib, horth, zero_add,
      varOf]
  rw [hcov, hvarP]
  ring

/-! ## Objection 2: the quantization ceiling -/

/-- The block sizes add up to the sample size. -/
lemma sum_card_fiber {n : ℕ} (b : Fin n → κ) :
    ∑ k : κ, (((fiber b k).card : ℝ)) = n := by
  have h := Finset.sum_fiberwise (Finset.univ : Finset (Fin n)) b (fun _ => (1 : ℝ))
  simpa only [Finset.sum_const, nsmul_eq_mul, mul_one, Finset.card_univ,
    Fintype.card_fin, fiber] using h

/-- **Power-mean bound on the tie correction.**  If the response takes at most
`r = |κ|` distinct values then the total tie correction `∑ mₖ³` is at least
`n³ / r²`; the correction is smallest when the blocks are equal. -/
lemma sum_cube_card_fiber_ge {n : ℕ} (b : Fin n → κ) :
    ((n : ℝ)) ^ 3 ≤ ((Fintype.card κ : ℝ)) ^ 2 * ∑ k : κ, (((fiber b k).card : ℝ)) ^ 3 := by
  have hnn : ∀ k ∈ (Finset.univ : Finset κ), (0 : ℝ) ≤ ((fiber b k).card : ℝ) :=
    fun k _ => Nat.cast_nonneg _
  have h := pow_sum_le_card_mul_sum_pow (s := (Finset.univ : Finset κ))
    (f := fun k => (((fiber b k).card : ℝ))) hnn 2
  rw [sum_card_fiber b] at h
  simpa [Finset.card_univ] using h

/-- **The quantization ceiling.**  A dial is scored against a response that takes
at most `r` distinct values.  Then, for every dial whatsoever,

`Cov(rank T, rate)² ≤ ((n³ - n)/12 - (n³/r² - n)/12) · Var(rate)`.

Normalised this is `ρ² ≤ 1 - (n³/r² - n)/(n³ - n) → 1 - 1/r²`.  Coarse
quantization of the measured rate is therefore a hard cap on rank agreement — but
a mild one. -/
theorem quantization_ceiling {n : ℕ} (σ : Equiv.Perm (Fin n)) (b : Fin n → κ) (g : κ → ℝ)
    (hr : 0 < Fintype.card κ) :
    cov (rankVec σ) (fun i => g (b i)) ^ 2
      ≤ (((n : ℝ) ^ 3 - n) / 12
          - ((n : ℝ) ^ 3 / ((Fintype.card κ : ℝ)) ^ 2 - n) / 12)
        * varOf (fun i => g (b i)) := by
  have hbase := spearman_ceiling_of_tie_partition σ b g
  refine hbase.trans (mul_le_mul_of_nonneg_right ?_ (varOf_nonneg _))
  have hcube := sum_cube_card_fiber_ge b
  have hrR : (0 : ℝ) < ((Fintype.card κ : ℝ)) ^ 2 := by
    have : (0 : ℝ) < (Fintype.card κ : ℝ) := by exact_mod_cast hr
    positivity
  have hdiv : (n : ℝ) ^ 3 / ((Fintype.card κ : ℝ)) ^ 2
      ≤ ∑ k : κ, (((fiber b k).card : ℝ)) ^ 3 := by
    rw [div_le_iff₀ hrR]
    linarith [hcube]
  have hsum : ∑ k : κ, ((((fiber b k).card : ℝ)) ^ 3 - ((fiber b k).card : ℝ)) / 12
      = (∑ k : κ, (((fiber b k).card : ℝ)) ^ 3) / 12 - (n : ℝ) / 12 := by
    rw [← sum_card_fiber b, Finset.sum_div, Finset.sum_div, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun k _ => by ring
  rw [hsum]
  linarith [hdiv]

/-- **The quantization ceiling is never binding.**  For any quantization level
`r ≥ 2` and any sample size `n ≥ 2`, the ceiling exceeds `3/4`, hence exceeds
`0.55² = 0.3025`.  No amount of coarseness in the measured rate can, by itself,
drag the Spearman coefficient out of the `[0.55, 0.85]` band. -/
theorem quantization_ceiling_not_binding (n r : ℕ) (hn : 2 ≤ n) (hr : 2 ≤ r) :
    (0.55 : ℝ) ^ 2 < 1 - ((n : ℝ) ^ 3 / (r : ℝ) ^ 2 - n) / ((n : ℝ) ^ 3 - n) := by
  have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hrR : (2 : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr
  have hn2 : (4 : ℝ) ≤ (n : ℝ) ^ 2 := by nlinarith
  have hprod : (n : ℝ) * 4 ≤ (n : ℝ) * (n : ℝ) ^ 2 := by nlinarith
  have hn3 : 0 < (n : ℝ) ^ 3 - n := by nlinarith
  have hr2 : (0 : ℝ) < (r : ℝ) ^ 2 := by nlinarith
  -- `n³/r² - n ≤ (n³ - n)/4`
  have hkey : (n : ℝ) ^ 3 / (r : ℝ) ^ 2 - n ≤ ((n : ℝ) ^ 3 - n) / 4 := by
    have h1 : (n : ℝ) ^ 3 / (r : ℝ) ^ 2 ≤ (n : ℝ) ^ 3 / 4 := by
      apply div_le_div_of_nonneg_left (by positivity) (by norm_num) (by nlinarith)
    linarith
  have hquot : ((n : ℝ) ^ 3 / (r : ℝ) ^ 2 - n) / ((n : ℝ) ^ 3 - n) ≤ 1 / 4 := by
    rw [div_le_div_iff₀ hn3 (by norm_num)]
    linarith
  nlinarith [hquot]

/-- **The synthesis of both cycles.**  The three tie-based ceilings available —
one zero-hit block, the full tie partition, coarse quantization — all leave the
Spearman coefficient free to sit inside the band `[0.55, 0.85]`.  Hence the
observed `0.405` at bit length `56` is *not* explained by loss of rank
resolution.  Formally: the single-block ceiling at the reported `(m, n) =
(194, 1200)` and the quantization ceiling at any `r ≥ 2, n ≥ 2` both strictly
exceed `0.55²`. -/
theorem no_tie_mechanism_explains_405 (n r : ℕ) (hn : 2 ≤ n) (hr : 2 ≤ r) :
    (0.405 : ℝ) ^ 2 < 1 - (((194 : ℝ)) ^ 3 - 194) / (((1200 : ℝ)) ^ 3 - 1200) ∧
    (0.405 : ℝ) ^ 2 < 1 - ((n : ℝ) ^ 3 / (r : ℝ) ^ 2 - n) / ((n : ℝ) ^ 3 - n) := by
  refine ⟨observed_405_below_tie_ceiling, ?_⟩
  have h := quantization_ceiling_not_binding n r hn hr
  nlinarith [h]

end TieCeiling