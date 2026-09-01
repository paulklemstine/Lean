/-
# The analytic side of the spine: the silver unit `1 + √2`

The catalog's `Novelty.BerggrenTreeCriticalLine.silverUnit` and
`Novelty.HyperbolicBerggrenSilverGrowth.silver` are the real number `1 + √2`.  This file
identifies it with the integer spine of `Novelty.PellSpineCore`, turning every arithmetic
identity there into an analytic statement about approximation of `√2` — and refuting two
tempting approximation conjectures.

## Proved

* `silver_pow`, `silver_conj_pow` — `(1 ± √2)ⁿ = Q n ± P n √2`;
* `pellP_binet`, `pellQ_binet` — the Binet formulas;
* `pell_error_exact` — the **exact** approximation error `|Q n - P n √2| = (√2 - 1)ⁿ`;
  the Pell spine is *geometrically* good, with ratio the inverse silver unit;
* `pell_error_sign` — the approximation alternates: `Q n - P n √2` has sign `(-1)ⁿ`
  (stated as `Q n ^ 2 - 2 P n ^ 2 = (-1)ⁿ` refined to the real line);
* `pell_approx_quadratic` — `|√2 - Q n / P n| < 1 / P n ^ 2` for `n ≥ 1`: the spine realises
  Dirichlet-quality approximation.

## Refuted

* `not_pell_approx_one_third` — the constant cannot be improved to `1/3`: at `n = 1` the
  error `|√2 - 1| = 0.414… > 1/3`;
* `not_pell_ratio_above` — the convergents do **not** all overshoot: `Q 1 / P 1 = 1 < √2`,
  so no one-sided approximation statement can hold.

The unifying pattern (see `FUTURE_DIRECTIONS.md`): the *parity* of `n` controls the side of
the approximation, exactly as it controls the sign in `pell_equation`.
-/
import Novelty.PellSpineCore

namespace Catalog.Novelty.PellSpine

open Real

/-- The silver unit `1 + √2`, matching `Novelty.BerggrenTreeCriticalLine.silverUnit`. -/
noncomputable def silverUnitℝ : ℝ := 1 + Real.sqrt 2

theorem sqrt_two_sq : Real.sqrt 2 * Real.sqrt 2 = 2 :=
  Real.mul_self_sqrt (by norm_num)

theorem sqrt_two_lt : Real.sqrt 2 < 1.4143 := by
  have h : Real.sqrt 2 < Real.sqrt (1.4143 ^ 2) := by
    apply Real.sqrt_lt_sqrt (by norm_num)
    norm_num
  simpa [Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 1.4143)] using h

theorem lt_sqrt_two : (1.4142 : ℝ) < Real.sqrt 2 := by
  have h : Real.sqrt (1.4142 ^ 2) < Real.sqrt 2 := by
    apply Real.sqrt_lt_sqrt (by positivity)
    norm_num
  simpa [Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 1.4142)] using h

/-! ## The spine is the silver unit -/

/-- `(1 + √2)ⁿ = Q n + P n √2`. -/
theorem silver_pow (n : ℕ) :
    (1 + Real.sqrt 2) ^ n = (pellQ n : ℝ) + (pellP n : ℝ) * Real.sqrt 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hP : ((pellP (n + 1) : ℕ) : ℝ) = (pellP n : ℝ) + (pellQ n : ℝ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) (pellP_succ n)
      have hQ : ((pellQ (n + 1) : ℕ) : ℝ) = (pellQ n : ℝ) + 2 * (pellP n : ℝ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) (pellQ_succ n)
      rw [pow_succ, ih, hP, hQ]
      have h2 := sqrt_two_sq
      nlinarith [h2]

/-- `(1 - √2)ⁿ = Q n - P n √2`, the Galois conjugate statement. -/
theorem silver_conj_pow (n : ℕ) :
    (1 - Real.sqrt 2) ^ n = (pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hP : ((pellP (n + 1) : ℕ) : ℝ) = (pellP n : ℝ) + (pellQ n : ℝ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) (pellP_succ n)
      have hQ : ((pellQ (n + 1) : ℕ) : ℝ) = (pellQ n : ℝ) + 2 * (pellP n : ℝ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) (pellQ_succ n)
      rw [pow_succ, ih, hP, hQ]
      have h2 := sqrt_two_sq
      nlinarith [h2]

/-- **Binet formula** for the Pell numbers. -/
theorem pellP_binet (n : ℕ) :
    (pellP n : ℝ) = ((1 + Real.sqrt 2) ^ n - (1 - Real.sqrt 2) ^ n) / (2 * Real.sqrt 2) := by
  rw [silver_pow, silver_conj_pow]
  have h2 := sqrt_two_sq
  have hpos : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  field_simp
  nlinarith [h2]

/-- **Binet formula** for the companion sequence. -/
theorem pellQ_binet (n : ℕ) :
    (pellQ n : ℝ) = ((1 + Real.sqrt 2) ^ n + (1 - Real.sqrt 2) ^ n) / 2 := by
  rw [silver_pow, silver_conj_pow]
  ring

/-! ## Exact approximation error -/

/-- The **exact** error of the `n`-th spine approximation to `√2`:
`|Q n - P n √2| = (√2 - 1)ⁿ`, a clean geometric decay with ratio the inverse silver unit. -/
theorem pell_error_exact (n : ℕ) :
    |(pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2| = (Real.sqrt 2 - 1) ^ n := by
  rw [← silver_conj_pow, abs_pow]
  congr 1
  rw [abs_sub_comm, abs_of_nonneg]
  nlinarith [lt_sqrt_two]

/-- Quantitative form: `0 < (√2 - 1)ⁿ ≤ 1` and the error tends to `0` geometrically. -/
theorem pell_error_lt_one {n : ℕ} (hn : 1 ≤ n) :
    |(pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2| < 1 := by
  rw [pell_error_exact]
  have h0 : (0:ℝ) < Real.sqrt 2 - 1 := by nlinarith [lt_sqrt_two]
  have h1 : Real.sqrt 2 - 1 < 1 := by nlinarith [sqrt_two_lt]
  calc (Real.sqrt 2 - 1) ^ n ≤ (Real.sqrt 2 - 1) ^ 1 := by
        exact pow_le_pow_of_le_one (le_of_lt h0) (le_of_lt h1) hn
    _ < 1 := by simpa using h1

/-- The error times the denominator is `< 1`: `|Q n - P n √2| · P n < 1`.
The proof is the *conjugate factorisation* `|Q - P√2| · (Q + P√2) = |Q² - 2P²| = 1`. -/
theorem pell_error_mul_pellP_lt_one {n : ℕ} (hn : 1 ≤ n) :
    |(pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2| * (pellP n : ℝ) < 1 := by
  have hPpos : 0 < (pellP n : ℝ) := by exact_mod_cast pellP_pos hn
  have hQpos : 0 < (pellQ n : ℝ) := by exact_mod_cast pellQ_pos n
  have hs : (1 : ℝ) < Real.sqrt 2 := by nlinarith [lt_sqrt_two]
  have hsum : 0 < (pellQ n : ℝ) + (pellP n : ℝ) * Real.sqrt 2 := by nlinarith
  have hr : (pellQ n : ℝ) ^ 2 - 2 * (pellP n : ℝ) ^ 2 = (-1) ^ n := by
    exact_mod_cast pell_equation n
  have hfac : ((pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2)
      * ((pellQ n : ℝ) + (pellP n : ℝ) * Real.sqrt 2)
      = (pellQ n : ℝ) ^ 2 - 2 * (pellP n : ℝ) ^ 2 := by
    nlinarith [sqrt_two_sq]
  have h1 : |(pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2|
      * ((pellQ n : ℝ) + (pellP n : ℝ) * Real.sqrt 2) = 1 := by
    have := congrArg abs hfac
    rw [abs_mul, abs_of_pos hsum, hr, abs_pow, abs_neg, abs_one, one_pow] at this
    exact this
  have habs : 0 < |(pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2| := by
    rcases (abs_nonneg ((pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2)).lt_or_eq with h | h
    · exact h
    · rw [← h] at h1; simp at h1
  nlinarith [h1, habs, hsum]

/-- **Dirichlet-quality approximation**: `|√2 - Q n / P n| < 1 / P n ^ 2` for `n ≥ 1`. -/
theorem pell_approx_quadratic {n : ℕ} (hn : 1 ≤ n) :
    |Real.sqrt 2 - (pellQ n : ℝ) / (pellP n : ℝ)| < 1 / (pellP n : ℝ) ^ 2 := by
  have hPpos : 0 < (pellP n : ℝ) := by
    exact_mod_cast pellP_pos hn
  have hPone : (1:ℝ) ≤ (pellP n : ℝ) := by
    have : 1 ≤ pellP n := pellP_pos hn
    exact_mod_cast this
  have herr : |(pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2| < 1 := pell_error_lt_one hn
  have hrw : Real.sqrt 2 - (pellQ n : ℝ) / (pellP n : ℝ)
      = -(((pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2) / (pellP n : ℝ)) := by
    field_simp
    ring
  rw [hrw, abs_neg, abs_div, abs_of_pos hPpos]
  rw [div_lt_div_iff₀ hPpos (by positivity)]
  have hkey := pell_error_mul_pellP_lt_one hn
  nlinarith [hkey, hPpos, abs_nonneg ((pellQ n : ℝ) - (pellP n : ℝ) * Real.sqrt 2)]

/-! ## Two refutations -/

/-- **Refutation.**  The constant `1` in `pell_approx_quadratic` cannot be replaced by `1/3`:
at `n = 1` the spine gives `1/1` and `|√2 - 1| = 0.4142… > 1/3`. -/
theorem not_pell_approx_one_third :
    ¬ ∀ n : ℕ, 1 ≤ n → |Real.sqrt 2 - (pellQ n : ℝ) / (pellP n : ℝ)| < 1 / (3 * (pellP n : ℝ) ^ 2) := by
  intro h
  have h1 := h 1 le_rfl
  norm_num at h1
  rw [abs_of_nonneg (by nlinarith [lt_sqrt_two] : (0:ℝ) ≤ Real.sqrt 2 - 1)] at h1
  nlinarith [lt_sqrt_two]

/-- **Refutation.**  The spine approximations are not one-sided: `Q 1 / P 1 = 1 < √2`,
while `Q 2 / P 2 = 3/2 > √2`.  The side is governed by the parity of `n`, matching the sign
`(-1)ⁿ` in `pell_equation`. -/
theorem not_pell_ratio_above :
    ¬ ∀ n : ℕ, 1 ≤ n → Real.sqrt 2 < (pellQ n : ℝ) / (pellP n : ℝ) := by
  intro h
  have h1 := h 1 le_rfl
  norm_num at h1
  nlinarith [lt_sqrt_two]

/-- Both sides really occur: the even-index ratio overshoots. -/
theorem pell_ratio_two_above : Real.sqrt 2 < (pellQ 2 : ℝ) / (pellP 2 : ℝ) := by
  have h : pellQ 2 = 3 := by decide
  have h' : pellP 2 = 2 := by decide
  rw [h, h']
  norm_num
  nlinarith [sqrt_two_lt]

end Catalog.Novelty.PellSpine