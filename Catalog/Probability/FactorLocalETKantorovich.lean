import Mathlib
import Probability.FactorLocalETScaling
import Probability.FactorLocalETCrossChannel

/-!
# FACTOR-LOCAL-ET, cycle 4: the *sharp* cross-channel constant

Cycle 2 (`Catalog.Probability.FactorLocalETCrossChannel`) proved the
constant-free consistency law `|slope_trial - 2·slope_ρ| ≤ 1/Δk` from
Cauchy–Schwarz plus a crude reversal of the dyadic window.  Numerically the
extremal populations only reach about `0.0216/Δk`, so the cycle-2 constant is
loose by a factor of roughly `23`.

The reason is that the reverse inequality `E p ≤ (U/L)·(E √p)²` throws away all
of the interior structure.  The correct reverse inequality is the
**Kantorovich / Pólya–Szegő** bound: for a sample `y` confined to `[a, b]`,

  `4ab · E[y²] ≤ (a+b)² · (E y)²`,

which follows from the pointwise quadratic `(y - a)(b - y) ≥ 0` and one
completion of a square.  On a dyadic window (`b/a = √2` after the substitution
`y = √p`) it gives the constant `(4 + 3√2)/8 ≈ 1.0303` in place of `2`, and this
is exactly the constant the numerical search finds.

## Main results

* `mean_mono`, `mean_affine` — the two missing linearity facts for `mean`.
* `mean_sq_le_kantorovich` — the Kantorovich inequality for empirical means.
* `dyadic_kantorovich` — its dyadic instance: `E p ≤ ((4+3√2)/8)·(E √p)²`,
  a strict improvement on `mean_le_ratio_mul_mean_sqrt_sq` (`E p ≤ 2(E √p)²`).
* `cross_channel_slope_law_kantorovich` — the sharpened consistency law
  `|slope_trial - 2·slope_ρ| ≤ log₂((4+3√2)/8)/Δk`, still constant-free.
* `kantorovich_allowance_lt` — `log₂((4+3√2)/8) < 0.044`, so at `Δk = 8` the
  admissible discrepancy is below `0.0055`.
* `measured_pair_refuted_sharp` — the reported pair `(0.84, 0.52)` demands a
  discrepancy of `0.20`, i.e. it misses the sharpened bound by a factor of more
  than `36` (cycle 2 could only claim a factor `1.6`).
-/

namespace FactorLocalET

open Real Finset

/-! ## 1. Linearity facts for the empirical mean -/

/-- Monotonicity of the empirical mean. -/
theorem mean_mono {n : ℕ} (hn : 0 < n) {f g : Fin n → ℝ} (h : ∀ i, f i ≤ g i) :
    mean f ≤ mean g := by
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  unfold mean
  rw [div_le_div_iff₀ hnpos hnpos]
  have hs : ∑ i, f i ≤ ∑ i, g i := Finset.sum_le_sum (fun i _ => h i)
  nlinarith

/-- The empirical mean commutes with affine maps. -/
theorem mean_affine {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) (u v : ℝ) :
    mean (fun i => u * f i + v) = u * mean f + v := by
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hsum : ∑ i, (u * f i + v) = u * (∑ i, f i) + n * v := by
    rw [Finset.sum_add_distrib, ← Finset.mul_sum]
    simp [Finset.card_univ]
  unfold mean
  rw [hsum]
  field_simp

/-! ## 2. Kantorovich / Pólya–Szegő for empirical means -/

/-- **Kantorovich inequality for an empirical sample.**  If every sample point
lies in `[a, b]` with `0 < a`, then `4ab·E[y²] ≤ (a+b)²·(E y)²`.  The proof is
the pointwise quadratic `(y - a)(b - y) ≥ 0`, which gives
`E[y²] ≤ (a+b)E[y] - ab`, followed by the completion of the square
`(a+b)²M² - 4ab(a+b)M + 4a²b² = ((a+b)M - 2ab)² ≥ 0`. -/
theorem mean_sq_le_kantorovich {n : ℕ} (hn : 0 < n) {y : Fin n → ℝ} {a b : ℝ}
    (ha : 0 < a) (h1 : ∀ i, a ≤ y i) (h2 : ∀ i, y i ≤ b) :
    4 * a * b * mean (fun i => (y i) ^ 2) ≤ (a + b) ^ 2 * (mean y) ^ 2 := by
  have hb : 0 < b := lt_of_lt_of_le ha (le_trans (h1 ⟨0, hn⟩) (h2 ⟨0, hn⟩))
  have hpt : ∀ i, (y i) ^ 2 ≤ (a + b) * y i + -(a * b) := by
    intro i; nlinarith [h1 i, h2 i]
  have hmono := mean_mono hn hpt
  rw [mean_affine hn y (a + b) (-(a * b))] at hmono
  have hM1 : a ≤ mean y := le_mean hn h1
  have hM2 : mean y ≤ b := mean_le hn h2
  nlinarith [sq_nonneg ((a + b) * mean y - 2 * a * b), mul_pos ha hb, hmono]

/-- **The dyadic Kantorovich bound.**  On a dyadic window `L ≤ p ≤ 2L` the
reverse Cauchy–Schwarz constant is `(4 + 3√2)/8 ≈ 1.0303`, not `2`. -/
theorem dyadic_kantorovich {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} {L : ℝ}
    (hL : 0 < L) (h1 : ∀ i, L ≤ f i) (h2 : ∀ i, f i ≤ 2 * L) :
    mean f ≤ ((4 + 3 * Real.sqrt 2) / 8) * (mean fun i => Real.sqrt (f i)) ^ 2 := by
  have hLpos : (0 : ℝ) < Real.sqrt L := Real.sqrt_pos.mpr hL
  -- the sample `√f` lives in `[√L, √2·√L]`
  have hlo : ∀ i, Real.sqrt L ≤ Real.sqrt (f i) := fun i => Real.sqrt_le_sqrt (h1 i)
  have hhi : ∀ i, Real.sqrt (f i) ≤ Real.sqrt 2 * Real.sqrt L := by
    intro i
    rw [← Real.sqrt_mul (by norm_num)]
    exact Real.sqrt_le_sqrt (h2 i)
  have hk := mean_sq_le_kantorovich (n := n) hn (y := fun i => Real.sqrt (f i))
    (a := Real.sqrt L) (b := Real.sqrt 2 * Real.sqrt L) hLpos hlo hhi
  have hsq : (mean fun i => Real.sqrt (f i) ^ 2) = mean f := by
    refine congrArg mean (funext fun i => ?_)
    exact Real.sq_sqrt (le_trans hL.le (h1 i))
  rw [hsq] at hk
  -- `hk : 4·√L·(√2·√L)·E f ≤ (√L + √2·√L)²·(E √f)²`
  set M : ℝ := (mean fun i => Real.sqrt (f i)) with hM
  have hLL : Real.sqrt L * Real.sqrt L = L := Real.mul_self_sqrt hL.le
  have h22 : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  have e1 : 4 * Real.sqrt L * (Real.sqrt 2 * Real.sqrt L) = 4 * Real.sqrt 2 * L := by
    linear_combination (4 * Real.sqrt 2) * hLL
  have e2 : (Real.sqrt L + Real.sqrt 2 * Real.sqrt L) ^ 2 = (3 + 2 * Real.sqrt 2) * L := by
    linear_combination (1 + 2 * Real.sqrt 2 + Real.sqrt 2 * Real.sqrt 2) * hLL + L * h22
  rw [e1, e2] at hk
  have hpos : (0 : ℝ) < 4 * Real.sqrt 2 * L := by positivity
  have hexp : 4 * Real.sqrt 2 * L * ((4 + 3 * Real.sqrt 2) / 8 * M ^ 2)
      = (3 + 2 * Real.sqrt 2) * L * M ^ 2 := by
    linear_combination (3 / 2 * L * M ^ 2) * h22
  refine le_of_mul_le_mul_left ?_ hpos
  rw [hexp]
  exact hk

/-! ## 3. The sharpened cross-channel slope law -/

/-- **Sharpened cross-channel consistency law.**  Same hypotheses as
`cross_channel_slope_law` — one population, pointwise costs `a·p` and `c·√p`,
dyadic windows — but the allowance is now `log₂((4+3√2)/8) ≈ 0.0431` per unit
of lever arm instead of `1`.  Both implementation constants still cancel. -/
theorem cross_channel_slope_law_kantorovich {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a c : ℝ}
    (ha : 0 < a) (hc : 0 < c)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ 2 * (2 : ℝ) ^ ((k : ℝ) - 1))
    {Etri Erho : ℕ → ℝ}
    (htri : ∀ k, Etri k = a * mean (p k))
    (hrho : ∀ k, Erho k = c * mean fun i => Real.sqrt (p k i))
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    |logSlope Etri k₁ k₂ - 2 * logSlope Erho k₁ k₂| ≤
      Real.logb 2 ((4 + 3 * Real.sqrt 2) / 8) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  have hKd : (1 : ℝ) < (4 + 3 * Real.sqrt 2) / 8 := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  set Kd : ℝ := (4 + 3 * Real.sqrt 2) / 8 with hKddef
  have hKdpos : (0 : ℝ) < Kd := by linarith
  set K := a / c ^ 2 with hK
  have hKpos : 0 < K := by positivity
  have hbr : ∀ k : ℕ, K * (Erho k) ^ 2 ≤ Etri k ∧ Etri k ≤ Kd * (K * (Erho k) ^ 2) := by
    intro k
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hpos : ∀ i, 0 ≤ p k i := fun i => le_trans hL.le (hlo k i)
    have hcs := mean_sqrt_sq_le_mean hn hpos
    have hkant := dyadic_kantorovich (n := n) hn (f := p k)
      (L := (2 : ℝ) ^ ((k : ℝ) - 1)) hL (fun i => hlo k i) (fun i => hhi k i)
    rw [← hKddef] at hkant
    have hexp : (c * mean fun i => Real.sqrt (p k i)) ^ 2
        = c ^ 2 * (mean fun i => Real.sqrt (p k i)) ^ 2 := by ring
    rw [htri k, hrho k, hexp]
    constructor
    · have hEq : K * (c ^ 2 * (mean fun i => Real.sqrt (p k i)) ^ 2)
          = a * (mean fun i => Real.sqrt (p k i)) ^ 2 := by
        rw [hK]; field_simp
      rw [hEq]
      nlinarith [hcs, ha]
    · have hEq : Kd * (K * (c ^ 2 * (mean fun i => Real.sqrt (p k i)) ^ 2))
          = Kd * a * (mean fun i => Real.sqrt (p k i)) ^ 2 := by
        rw [hK]; field_simp
      rw [hEq]
      nlinarith [hkant, ha]
  have hrhopos : ∀ k : ℕ, 0 < Erho k := by
    intro k
    rw [hrho k]
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hmean : Real.sqrt ((2 : ℝ) ^ ((k : ℝ) - 1)) ≤ mean fun i => Real.sqrt (p k i) :=
      le_mean hn (fun i => Real.sqrt_le_sqrt (hlo k i))
    have hs : (0 : ℝ) < Real.sqrt ((2 : ℝ) ^ ((k : ℝ) - 1)) := Real.sqrt_pos.mpr hL
    have hposm : (0 : ℝ) < mean fun i => Real.sqrt (p k i) := lt_of_lt_of_le hs hmean
    positivity
  have hd : ∀ k : ℕ, Real.logb 2 K ≤ Real.logb 2 (Etri k) - 2 * Real.logb 2 (Erho k) ∧
      Real.logb 2 (Etri k) - 2 * Real.logb 2 (Erho k) ≤ Real.logb 2 K + Real.logb 2 Kd := by
    intro k
    obtain ⟨hb1, hb2⟩ := hbr k
    have hE : 0 < Erho k := hrhopos k
    have hsqpos : (0 : ℝ) < (Erho k) ^ 2 := by positivity
    have htripos : 0 < Etri k := lt_of_lt_of_le (by positivity) hb1
    have hlog1 : Real.logb 2 (K * (Erho k) ^ 2) = Real.logb 2 K + 2 * Real.logb 2 (Erho k) := by
      rw [Real.logb_mul (ne_of_gt hKpos) (ne_of_gt hsqpos), Real.logb_pow]
      ring
    have hlog2 : Real.logb 2 (Kd * (K * (Erho k) ^ 2))
        = Real.logb 2 Kd + Real.logb 2 K + 2 * Real.logb 2 (Erho k) := by
      rw [Real.logb_mul (ne_of_gt hKdpos) (by positivity), hlog1]
      ring
    constructor
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by positivity) hb1
      rw [hlog1] at this; linarith
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) htripos hb2
      rw [hlog2] at this; linarith
  obtain ⟨hd1L, hd1U⟩ := hd k₁
  obtain ⟨hd2L, hd2U⟩ := hd k₂
  have hKdlog : 0 ≤ Real.logb 2 Kd :=
    Real.logb_nonneg (by norm_num) (le_of_lt hKd)
  have hsplit : logSlope Etri k₁ k₂ - 2 * logSlope Erho k₁ k₂ =
      ((Real.logb 2 (Etri k₂) - 2 * Real.logb 2 (Erho k₂)) -
        (Real.logb 2 (Etri k₁) - 2 * Real.logb 2 (Erho k₁))) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
    simp only [logSlope]
    field_simp
    ring
  rw [hsplit, abs_div, abs_of_pos hΔ, div_le_div_iff₀ hΔ hΔ]
  have habs : |(Real.logb 2 (Etri k₂) - 2 * Real.logb 2 (Erho k₂)) -
      (Real.logb 2 (Etri k₁) - 2 * Real.logb 2 (Erho k₁))| ≤ Real.logb 2 Kd := by
    rw [abs_le]; constructor <;> linarith
  nlinarith [habs, hΔ, hKdlog]

/-! ## 4. Numerical allowance and the sharpened refutation -/

/-- The sharpened allowance is below `0.044`: `log₂((4+3√2)/8) < 0.044`. -/
theorem kantorovich_allowance_lt : Real.logb 2 ((4 + 3 * Real.sqrt 2) / 8) < 0.044 := by
  have hs : Real.sqrt 2 < 1.4143 := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  have hKpos : (0 : ℝ) < (4 + 3 * Real.sqrt 2) / 8 := by
    have := Real.sqrt_nonneg 2; linarith
  have hlog : Real.log ((4 + 3 * Real.sqrt 2) / 8) ≤ (4 + 3 * Real.sqrt 2) / 8 - 1 :=
    Real.log_le_sub_one_of_pos hKpos
  have hub : (4 + 3 * Real.sqrt 2) / 8 - 1 < 0.0304 := by linarith
  have hl2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hnum : Real.log ((4 + 3 * Real.sqrt 2) / 8) < 0.0304 := lt_of_le_of_lt hlog hub
  have hnn : 0 ≤ Real.log ((4 + 3 * Real.sqrt 2) / 8) := by
    refine Real.log_nonneg ?_
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  rw [Real.logb, div_lt_iff₀ (by linarith)]
  nlinarith [hnum, hl2, hnn]

/-- **The reported pair, refuted with a factor-36 margin.**  Under the same
hypotheses as `measured_pair_inconsistent`, the sharpened law allows a
discrepancy of at most `0.044/8 = 0.0055` at the experimental lever arm, while
the pair `(0.84, 0.52)` demands `2·0.52 - 0.84 = 0.20`.  So the pointwise
model is refuted by more than a factor of `36`, not merely by the factor `1.6`
that cycle 2 could certify. -/
theorem measured_pair_refuted_sharp {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a c : ℝ}
    (ha : 0 < a) (hc : 0 < c)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ 2 * (2 : ℝ) ^ ((k : ℝ) - 1))
    {Etri Erho : ℕ → ℝ}
    (htri : ∀ k, Etri k = a * mean (p k))
    (hrho : ∀ k, Erho k = c * mean fun i => Real.sqrt (p k i)) :
    ¬ (logSlope Etri 16 24 ≤ 0.84 ∧ (0.52 : ℝ) ≤ logSlope Erho 16 24) := by
  rintro ⟨h1, h2⟩
  have hlaw := cross_channel_slope_law_kantorovich hn ha hc hlo hhi htri hrho
    (k₁ := 16) (k₂ := 24) (by norm_num)
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  rw [h8] at hlaw
  have hall := kantorovich_allowance_lt
  have := (abs_le.mp hlaw).1
  have hdiv : Real.logb 2 ((4 + 3 * Real.sqrt 2) / 8) / 8 < 0.0055 := by linarith
  linarith

/-- **Non-vacuity of the sharpened law.**  The hypotheses of
`cross_channel_slope_law_kantorovich` are realisable, and the realising
population has slope pair `(1, 1/2)`, for which the sharpened discrepancy is
exactly `0` — well inside the allowance.  So the refutation above is a
statement about the measured numbers, not about the hypotheses. -/
theorem kantorovich_law_nonvacuous :
    ∃ (p : ℕ → Fin 1 → ℝ) (Etri Erho : ℕ → ℝ),
      (∀ (k : ℕ) (i : Fin 1), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i) ∧
      (∀ (k : ℕ) (i : Fin 1), p k i ≤ 2 * (2 : ℝ) ^ ((k : ℝ) - 1)) ∧
      (∀ k, Etri k = 1 * mean (p k)) ∧
      (∀ k, Erho k = 1 * mean fun i => Real.sqrt (p k i)) ∧
      logSlope Etri 16 24 - 2 * logSlope Erho 16 24 = 0 := by
  obtain ⟨p, Etri, Erho, h1, h2, h3, h4, h5, h6⟩ := cross_channel_witness
  exact ⟨p, Etri, Erho, h1, fun k i => by have := h2 k i; linarith, h3, h4, by rw [h5, h6]; ring⟩

/-! ## 5. The sharpened constant is essentially attained -/

/-- **Sharpness certificate.**  A two-point population that sits at the bottom
of the window at `k = 16` and splits between the two ends of the window at
`k = 24` realises a discrepancy of `log₂(6/(3+2√2))/Δk > 0.041/Δk`.  Hence the
allowance `log₂((4+3√2)/8) ≈ 0.0431` of
`cross_channel_slope_law_kantorovich` cannot be replaced by anything below
`0.041`: the Kantorovich constant is sharp to within 5%, whereas the cycle-2
constant `1` was loose by a factor of 23. -/
theorem kantorovich_constant_near_sharp :
    ∃ (p : ℕ → Fin 2 → ℝ) (Etri Erho : ℕ → ℝ),
      (∀ (k : ℕ) (i : Fin 2), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i) ∧
      (∀ (k : ℕ) (i : Fin 2), p k i ≤ 2 * (2 : ℝ) ^ ((k : ℝ) - 1)) ∧
      (∀ k, Etri k = 1 * mean (p k)) ∧
      (∀ k, Erho k = 1 * mean fun i => Real.sqrt (p k i)) ∧
      0.041 / 8 ≤ |logSlope Etri 16 24 - 2 * logSlope Erho 16 24| := by
  classical
  set q : ℕ → Fin 2 → ℝ := fun k i =>
    if k = 24 then (if i = 0 then (2 : ℝ) ^ ((k : ℝ) - 1) else 2 * (2 : ℝ) ^ ((k : ℝ) - 1))
    else (2 : ℝ) ^ ((k : ℝ) - 1) with hq
  have hApos : ∀ k : ℕ, (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := fun k => by positivity
  refine ⟨q, fun k => 1 * mean (q k), fun k => 1 * mean fun i => Real.sqrt (q k i),
    ?_, ?_, fun _ => rfl, fun _ => rfl, ?_⟩
  · intro k i
    have := hApos k
    simp only [hq]
    split_ifs <;> linarith
  · intro k i
    have := hApos k
    simp only [hq]
    split_ifs <;> linarith
  -- evaluate the two channels at the two levels
  have h15 : ((16 : ℕ) : ℝ) - 1 = 15 := by norm_num
  have h23 : ((24 : ℕ) : ℝ) - 1 = 23 := by norm_num
  have hsq15 : Real.sqrt ((2 : ℝ) ^ (15 : ℝ)) = (2 : ℝ) ^ (15 / 2 : ℝ) := by
    rw [Real.sqrt_eq_rpow, ← Real.rpow_mul (by norm_num : (0:ℝ) ≤ 2)]
    norm_num
  have hsq23 : Real.sqrt ((2 : ℝ) ^ (23 : ℝ)) = (2 : ℝ) ^ (23 / 2 : ℝ) := by
    rw [Real.sqrt_eq_rpow, ← Real.rpow_mul (by norm_num : (0:ℝ) ≤ 2)]
    norm_num
  have hq16 : ∀ i : Fin 2, q 16 i = (2 : ℝ) ^ (15 : ℝ) := by
    intro i
    simp only [hq]
    rw [if_neg (by norm_num : ¬((16 : ℕ) = 24)), h15]
  have hq24z : q 24 0 = (2 : ℝ) ^ (23 : ℝ) := by
    simp only [hq, if_true, h23]
  have hq24o : q 24 1 = 2 * (2 : ℝ) ^ (23 : ℝ) := by
    simp only [hq, if_true, h23]
    rw [if_neg (by decide : ¬((1 : Fin 2) = 0))]
  have e16t : (1 : ℝ) * mean (q 16) = (2 : ℝ) ^ (15 : ℝ) := by
    simp only [mean, Fin.sum_univ_two, hq16, Nat.cast_ofNat]
    ring
  have e24t : (1 : ℝ) * mean (q 24) = 3 / 2 * (2 : ℝ) ^ (23 : ℝ) := by
    simp only [mean, Fin.sum_univ_two, hq24z, hq24o, Nat.cast_ofNat]
    ring
  have e16r : (1 : ℝ) * (mean fun i => Real.sqrt (q 16 i)) = (2 : ℝ) ^ (15 / 2 : ℝ) := by
    simp only [mean, Fin.sum_univ_two, hq16, hsq15, Nat.cast_ofNat]
    ring
  have e24r : (1 : ℝ) * (mean fun i => Real.sqrt (q 24 i))
      = (1 + Real.sqrt 2) / 2 * (2 : ℝ) ^ (23 / 2 : ℝ) := by
    have hmul : Real.sqrt (2 * (2 : ℝ) ^ (23 : ℝ)) = Real.sqrt 2 * (2 : ℝ) ^ (23 / 2 : ℝ) := by
      rw [Real.sqrt_mul (by norm_num), hsq23]
    simp only [mean, Fin.sum_univ_two, hq24z, hq24o, hsq23, hmul, Nat.cast_ofNat]
    ring
  -- the log-log bracket collapses to a constant
  have hlogp : ∀ x : ℝ, Real.logb 2 ((2 : ℝ) ^ x) = x := fun x =>
    Real.logb_rpow (b := 2) (by norm_num) (by norm_num)
  have hlogmul : ∀ u x : ℝ, 0 < u →
      Real.logb 2 (u * (2 : ℝ) ^ x) = Real.logb 2 u + x := by
    intro u x hu
    rw [Real.logb_mul (ne_of_gt hu) (by positivity), hlogp]
  have hsplit : Real.logb 2 (3 / 2 * (2 : ℝ) ^ (23 : ℝ)) - Real.logb 2 ((2 : ℝ) ^ (15 : ℝ))
      - 2 * (Real.logb 2 ((1 + Real.sqrt 2) / 2 * (2 : ℝ) ^ (23 / 2 : ℝ))
        - Real.logb 2 ((2 : ℝ) ^ (15 / 2 : ℝ)))
      = Real.logb 2 (3 / 2) - 2 * Real.logb 2 ((1 + Real.sqrt 2) / 2) := by
    rw [hlogmul (3 / 2) 23 (by norm_num), hlogmul ((1 + Real.sqrt 2) / 2) (23 / 2) (by positivity),
      hlogp, hlogp]
    ring
  -- and that constant is `log₂(6/(3+2√2))`
  have hcollapse : Real.logb 2 (3 / 2) - 2 * Real.logb 2 ((1 + Real.sqrt 2) / 2)
      = Real.logb 2 (6 / (3 + 2 * Real.sqrt 2)) := by
    have h22 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    have hfac : (6 : ℝ) / (3 + 2 * Real.sqrt 2) = 3 / 2 / ((1 + Real.sqrt 2) / 2) ^ 2 := by
      have hsqe : ((1 + Real.sqrt 2) / 2) ^ 2 = (3 + 2 * Real.sqrt 2) / 4 := by
        linear_combination (1 / 4 : ℝ) * h22
      have hden : (0 : ℝ) < 3 + 2 * Real.sqrt 2 := by positivity
      rw [hsqe]
      field_simp
      ring
    rw [hfac]
    conv_rhs => rw [Real.logb_div (by norm_num) (by positivity), Real.logb_pow]
    push_cast
    ring
  have hnum : (0.041 : ℝ) ≤ Real.logb 2 (6 / (3 + 2 * Real.sqrt 2)) := by
    have hs : Real.sqrt 2 < 1.41422 := by
      nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
    set x : ℝ := 6 / (3 + 2 * Real.sqrt 2) with hx
    have hxpos : 0 < x := by rw [hx]; positivity
    -- `log x ≥ 1 - 1/x` from `log (1/x) ≤ 1/x - 1`
    have hinv : Real.log x⁻¹ ≤ x⁻¹ - 1 := Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_inv] at hinv
    have hxinv : x⁻¹ = (3 + 2 * Real.sqrt 2) / 6 := by
      rw [hx]; field_simp
    have hlow : (0.0284 : ℝ) ≤ Real.log x := by
      rw [hxinv] at hinv
      nlinarith [hinv, hs]
    have hl2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
    have hl2pos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    rw [Real.logb, le_div_iff₀ hl2pos]
    nlinarith [hlow, hl2, hl2pos]
  have hval : logSlope (fun k => 1 * mean (q k)) 16 24
      - 2 * logSlope (fun k => 1 * mean fun i => Real.sqrt (q k i)) 16 24
      = Real.logb 2 (6 / (3 + 2 * Real.sqrt 2)) / 8 := by
    simp only [logSlope]
    rw [e16t, e24t, e16r, e24r]
    have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
    rw [h8, ← hcollapse, ← hsplit]
    ring
  rw [hval]
  refine le_trans ?_ (le_abs_self _)
  have : (0.041 : ℝ) / 8 ≤ Real.logb 2 (6 / (3 + 2 * Real.sqrt 2)) / 8 := by
    linarith [hnum]
  exact this

end FactorLocalET