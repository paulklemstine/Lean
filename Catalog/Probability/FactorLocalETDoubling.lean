import Mathlib
import Probability.FactorLocalETScaling
import Probability.FactorLocalETCrossChannel
import Probability.FactorLocalETKantorovich

/-!
# FACTOR-LOCAL-ET, cycle 5: the sharp constant along the doubling ray `s = 2t`

Cycle 3 proved the generic power-mean rigidity
`|t·slope_A − s·slope_B| ≤ s·t/Δk` for pointwise costs `a·p^s`, `c·p^t`
measured on one dyadic population, and cycle 4 showed that on the pair
`(s, t) = (1, 1/2)` the true constant is *much* smaller, namely
`log₂((4+3√2)/8) ≈ 0.043` rather than `1/2`.

This cycle explains the gap on the whole *doubling ray* `s = 2t`, where the
substitution `y = p^t` turns the reverse inequality into exactly the
Kantorovich configuration of cycle 4.  The result is a one-parameter family of
sharp constants

  `K(t) = (1 + 2^t)² / (4·2^t)`,

`log₂ K(t)` replacing the generic `2t²`.  At `t = 1/2` it reproduces the
cycle-4 constant `(4+3√2)/8`, and as `t → 0` it decays like `t²·ln2/8` — the
quadratic law that the numerics of `ComputationalEvidence.md` §6 predicted.

## Main results

* `sq_mean_le_mean_sq` — Cauchy–Schwarz in the form `(E y)² ≤ E[y²]`.
* `dyadic_kantorovich_rpow` — `E[p^{2t}] ≤ K(t)·(E[p^t])²` on a dyadic window.
* `cross_channel_slope_law_doubling` — `|slope_{2t} − 2·slope_t| ≤ log₂K(t)/Δk`.
* `doubling_constant_at_half` — `K(1/2) = (4+3√2)/8`, so cycle 4 is the
  `t = 1/2` member of the family.
* `doubling_beats_power_mean` — for `0 < t ≤ 1` the new constant is genuinely
  smaller than the generic one: `log₂K(t) < 2t²`.
-/

namespace FactorLocalET

open Real Finset

/-- **Cauchy–Schwarz for the empirical mean, squared form.**  `(E y)² ≤ E[y²]`. -/
theorem sq_mean_le_mean_sq {n : ℕ} (hn : 0 < n) (y : Fin n → ℝ) :
    (mean y) ^ 2 ≤ mean fun i => (y i) ^ 2 := by
  have hcs : (∑ i, y i) ^ 2
      ≤ ((Finset.univ : Finset (Fin n)).card : ℝ) * ∑ i, (y i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hcard : ((Finset.univ : Finset (Fin n)).card : ℝ) = n := by simp
  rw [hcard] at hcs
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  rw [mean, mean, div_pow, div_le_div_iff₀ (by positivity) hnpos]
  nlinarith [hcs, hnpos]

/-- The doubling-ray constant `K(t) = (1 + 2^t)²/(4·2^t)`. -/
noncomputable def doublingConst (t : ℝ) : ℝ := (1 + (2 : ℝ) ^ t) ^ 2 / (4 * (2 : ℝ) ^ t)

theorem one_le_doublingConst (t : ℝ) : 1 ≤ doublingConst t := by
  have h2 : (0 : ℝ) < (2 : ℝ) ^ t := Real.rpow_pos_of_pos (by norm_num) t
  rw [doublingConst, le_div_iff₀ (by positivity)]
  nlinarith [sq_nonneg (1 - (2 : ℝ) ^ t)]

theorem doublingConst_pos (t : ℝ) : 0 < doublingConst t :=
  lt_of_lt_of_le zero_lt_one (one_le_doublingConst t)

/-- **Kantorovich along the doubling ray.**  On a dyadic window `L ≤ p ≤ 2L`
the `2t`-th mean is controlled by the square of the `t`-th mean with the
constant `K(t)`, uniformly in `L`. -/
theorem dyadic_kantorovich_rpow {n : ℕ} (hn : 0 < n) {f : Fin n → ℝ} {L t : ℝ}
    (hL : 0 < L) (ht : 0 < t) (h1 : ∀ i, L ≤ f i) (h2 : ∀ i, f i ≤ 2 * L) :
    (mean fun i => (f i) ^ (2 * t)) ≤ doublingConst t * (mean fun i => (f i) ^ t) ^ 2 := by
  have hfpos : ∀ i, 0 < f i := fun i => lt_of_lt_of_le hL (h1 i)
  have hLt : (0 : ℝ) < L ^ t := Real.rpow_pos_of_pos hL t
  have h2t : (0 : ℝ) < (2 : ℝ) ^ t := Real.rpow_pos_of_pos (by norm_num) t
  -- the transformed sample lives in `[L^t, 2^t·L^t]`
  have hlo : ∀ i, L ^ t ≤ (f i) ^ t := fun i => Real.rpow_le_rpow hL.le (h1 i) ht.le
  have hhi : ∀ i, (f i) ^ t ≤ (2 : ℝ) ^ t * L ^ t := by
    intro i
    rw [← Real.mul_rpow (by norm_num) hL.le]
    exact Real.rpow_le_rpow (hfpos i).le (h2 i) ht.le
  have hk := mean_sq_le_kantorovich (n := n) hn (y := fun i => (f i) ^ t)
    (a := L ^ t) (b := (2 : ℝ) ^ t * L ^ t) hLt hlo hhi
  -- `(p^t)² = p^{2t}`
  have hsq : (mean fun i => ((f i) ^ t) ^ 2) = mean fun i => (f i) ^ (2 * t) := by
    refine congrArg mean (funext fun i => ?_)
    rw [← Real.rpow_natCast ((f i) ^ t) 2, ← Real.rpow_mul (hfpos i).le]
    congr 1
    push_cast
    ring
  rw [hsq] at hk
  set M : ℝ := (mean fun i => (f i) ^ t) with hM
  have hLt2 : L ^ t * L ^ t = L ^ (2 * t) := by
    rw [← Real.rpow_add hL]; ring_nf
  have hlhs : 4 * L ^ t * ((2 : ℝ) ^ t * L ^ t) = 4 * (2 : ℝ) ^ t * L ^ (2 * t) := by
    rw [← hLt2]; ring
  have hrhs : (L ^ t + (2 : ℝ) ^ t * L ^ t) ^ 2 = (1 + (2 : ℝ) ^ t) ^ 2 * L ^ (2 * t) := by
    rw [← hLt2]; ring
  rw [hlhs, hrhs] at hk
  have hLpow : (0 : ℝ) < L ^ (2 * t) := Real.rpow_pos_of_pos hL (2 * t)
  have hc : (0 : ℝ) < 4 * (2 : ℝ) ^ t * L ^ (2 * t) := by positivity
  refine le_of_mul_le_mul_left ?_ hc
  have hexp : 4 * (2 : ℝ) ^ t * L ^ (2 * t) * (doublingConst t * M ^ 2)
      = (1 + (2 : ℝ) ^ t) ^ 2 * L ^ (2 * t) * M ^ 2 := by
    rw [doublingConst]
    field_simp
  rw [hexp]
  exact hk

/-- **The doubling-ray consistency law.**  For pointwise costs `a·p^{2t}` and
`c·p^t` on one dyadic population, the measured slopes satisfy
`|slope_{2t} − 2·slope_t| ≤ log₂K(t)/Δk` — a constant-free law that is strictly
stronger than the generic power-mean bound `2t²/Δk` for every `0 < t ≤ 1`. -/
theorem cross_channel_slope_law_doubling {n : ℕ} (hn : 0 < n) {p : ℕ → Fin n → ℝ} {a c t : ℝ}
    (ha : 0 < a) (hc : 0 < c) (ht : 0 < t)
    (hlo : ∀ (k : ℕ) (i : Fin n), (2 : ℝ) ^ ((k : ℝ) - 1) ≤ p k i)
    (hhi : ∀ (k : ℕ) (i : Fin n), p k i ≤ 2 * (2 : ℝ) ^ ((k : ℝ) - 1))
    {EA EB : ℕ → ℝ}
    (hA : ∀ k, EA k = a * mean fun i => (p k i) ^ (2 * t))
    (hB : ∀ k, EB k = c * mean fun i => (p k i) ^ t)
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    |logSlope EA k₁ k₂ - 2 * logSlope EB k₁ k₂| ≤
      Real.logb 2 (doublingConst t) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  set Kd : ℝ := doublingConst t with hKddef
  have hKdpos : (0 : ℝ) < Kd := doublingConst_pos t
  set K := a / c ^ 2 with hK
  have hKpos : 0 < K := by positivity
  have hBpos : ∀ k : ℕ, 0 < EB k := by
    intro k
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hpos : ∀ i, (0 : ℝ) < (p k i) ^ t :=
      fun i => Real.rpow_pos_of_pos (lt_of_lt_of_le hL (hlo k i)) t
    have hmean : (0 : ℝ) < mean fun i => (p k i) ^ t := by
      have hlow : ∀ i, ((2 : ℝ) ^ ((k : ℝ) - 1)) ^ t ≤ (p k i) ^ t :=
        fun i => Real.rpow_le_rpow hL.le (hlo k i) ht.le
      exact lt_of_lt_of_le (Real.rpow_pos_of_pos hL t) (le_mean hn hlow)
    rw [hB k]; positivity
  have hbr : ∀ k : ℕ, K * (EB k) ^ 2 ≤ EA k ∧ EA k ≤ Kd * (K * (EB k) ^ 2) := by
    intro k
    have hL : (0 : ℝ) < (2 : ℝ) ^ ((k : ℝ) - 1) := by positivity
    have hcs := sq_mean_le_mean_sq hn (fun i => (p k i) ^ t)
    have hsq : (mean fun i => ((p k i) ^ t) ^ 2) = mean fun i => (p k i) ^ (2 * t) := by
      refine congrArg mean (funext fun i => ?_)
      have hp : (0 : ℝ) ≤ p k i := le_trans hL.le (hlo k i)
      rw [← Real.rpow_natCast ((p k i) ^ t) 2, ← Real.rpow_mul hp]
      congr 1
      push_cast
      ring
    rw [hsq] at hcs
    have hkant := dyadic_kantorovich_rpow (n := n) hn (f := p k)
      (L := (2 : ℝ) ^ ((k : ℝ) - 1)) hL ht (fun i => hlo k i) (fun i => hhi k i)
    rw [← hKddef] at hkant
    have hexp : (c * mean fun i => (p k i) ^ t) ^ 2
        = c ^ 2 * (mean fun i => (p k i) ^ t) ^ 2 := by ring
    rw [hA k, hB k, hexp]
    constructor
    · have hEq : K * (c ^ 2 * (mean fun i => (p k i) ^ t) ^ 2)
          = a * (mean fun i => (p k i) ^ t) ^ 2 := by rw [hK]; field_simp
      rw [hEq]
      nlinarith [hcs, ha]
    · have hEq : Kd * (K * (c ^ 2 * (mean fun i => (p k i) ^ t) ^ 2))
          = Kd * a * (mean fun i => (p k i) ^ t) ^ 2 := by rw [hK]; field_simp
      rw [hEq]
      nlinarith [hkant, ha]
  have hd : ∀ k : ℕ, Real.logb 2 K ≤ Real.logb 2 (EA k) - 2 * Real.logb 2 (EB k) ∧
      Real.logb 2 (EA k) - 2 * Real.logb 2 (EB k) ≤ Real.logb 2 K + Real.logb 2 Kd := by
    intro k
    obtain ⟨hb1, hb2⟩ := hbr k
    have hE : 0 < EB k := hBpos k
    have hsqpos : (0 : ℝ) < (EB k) ^ 2 := by positivity
    have hApos : 0 < EA k := lt_of_lt_of_le (by positivity) hb1
    have hlog1 : Real.logb 2 (K * (EB k) ^ 2) = Real.logb 2 K + 2 * Real.logb 2 (EB k) := by
      rw [Real.logb_mul (ne_of_gt hKpos) (ne_of_gt hsqpos), Real.logb_pow]
      ring
    have hlog2 : Real.logb 2 (Kd * (K * (EB k) ^ 2))
        = Real.logb 2 Kd + Real.logb 2 K + 2 * Real.logb 2 (EB k) := by
      rw [Real.logb_mul (ne_of_gt hKdpos) (by positivity), hlog1]
      ring
    constructor
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by positivity) hb1
      rw [hlog1] at this; linarith
    · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) hApos hb2
      rw [hlog2] at this; linarith
  obtain ⟨hd1L, hd1U⟩ := hd k₁
  obtain ⟨hd2L, hd2U⟩ := hd k₂
  have hKdlog : 0 ≤ Real.logb 2 Kd :=
    Real.logb_nonneg (by norm_num) (one_le_doublingConst t)
  have hsplit : logSlope EA k₁ k₂ - 2 * logSlope EB k₁ k₂ =
      ((Real.logb 2 (EA k₂) - 2 * Real.logb 2 (EB k₂)) -
        (Real.logb 2 (EA k₁) - 2 * Real.logb 2 (EB k₁))) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
    simp only [logSlope]
    field_simp
    ring
  rw [hsplit, abs_div, abs_of_pos hΔ, div_le_div_iff₀ hΔ hΔ]
  have habs : |(Real.logb 2 (EA k₂) - 2 * Real.logb 2 (EB k₂)) -
      (Real.logb 2 (EA k₁) - 2 * Real.logb 2 (EB k₁))| ≤ Real.logb 2 Kd := by
    rw [abs_le]; constructor <;> linarith
  nlinarith [habs, hΔ, hKdlog]

/-- Cycle 4 is the `t = 1/2` member of the family: `K(1/2) = (4+3√2)/8`. -/
theorem doubling_constant_at_half : doublingConst (1 / 2) = (4 + 3 * Real.sqrt 2) / 8 := by
  have hs : (2 : ℝ) ^ ((1 : ℝ) / 2) = Real.sqrt 2 := by
    rw [Real.sqrt_eq_rpow]
  have h22 : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  rw [doublingConst, hs, div_eq_div_iff (by positivity) (by norm_num)]
  linear_combination (-4 : ℝ) * h22

/-- **The doubling-ray constant beats the generic power-mean constant.**  For
`0 < t ≤ 1`, `log₂K(t) < 2t²`, i.e. the specialised law is strictly stronger
than `general_cross_channel_slope_law` on the ray `s = 2t`; at `t = 1/2` the
improvement is a factor of about `12`. -/
theorem doubling_beats_power_mean {t : ℝ} (ht : 0 < t) (ht1 : t ≤ 1) :
    Real.logb 2 (doublingConst t) < 2 * t ^ 2 := by
  have hl2u : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hl2l : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hl2pos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  set x : ℝ := t * Real.log 2 with hxdef
  have hxpos : 0 < x := mul_pos ht hl2pos
  have hxlt : x < 0.694 := by nlinarith [hl2u, ht1, ht]
  have hrw : (2 : ℝ) ^ t = Real.exp x := by
    rw [Real.rpow_def_of_pos (by norm_num), hxdef]; ring_nf
  have h2t : (0 : ℝ) < (2 : ℝ) ^ t := Real.rpow_pos_of_pos (by norm_num) t
  have hge : (1 : ℝ) ≤ (2 : ℝ) ^ t := by
    rw [hrw]; exact Real.one_le_exp hxpos.le
  -- `e^x (1 - x) ≤ 1` from `1 - x ≤ e^{-x}`
  have hexp : Real.exp x * (1 - x) ≤ 1 := by
    have h := Real.add_one_le_exp (-x)
    rw [Real.exp_neg] at h
    have hepos : 0 < Real.exp x := Real.exp_pos x
    calc Real.exp x * (1 - x) ≤ Real.exp x * (Real.exp x)⁻¹ := by nlinarith [h, hepos]
      _ = 1 := by field_simp
  have hE : Real.exp x ≤ 3.268 := by
    nlinarith [hexp, hxlt, Real.exp_pos x]
  have hb : (2 : ℝ) ^ t - 1 ≤ 2.2652 * t := by
    rw [hrw]
    nlinarith [hexp, hE, hxpos, hl2u, ht, Real.exp_pos x]
  -- `K(t) - 1 = (2^t - 1)²/(4·2^t)`
  have hK : doublingConst t = 1 + ((2 : ℝ) ^ t - 1) ^ 2 / (4 * (2 : ℝ) ^ t) := by
    rw [doublingConst]
    field_simp
    ring
  have hnum : ((2 : ℝ) ^ t - 1) ^ 2 / (4 * (2 : ℝ) ^ t) ≤ 1.2828 * t ^ 2 := by
    have hsq : ((2 : ℝ) ^ t - 1) ^ 2 ≤ 5.1312 * t ^ 2 := by nlinarith [hb, hge, ht]
    rw [div_le_iff₀ (by positivity)]
    nlinarith [hsq, hge, sq_nonneg t, ht]
  have hlogle : Real.log (doublingConst t) ≤ 1.2828 * t ^ 2 := by
    have hle : Real.log (doublingConst t) ≤ doublingConst t - 1 :=
      Real.log_le_sub_one_of_pos (doublingConst_pos t)
    rw [hK] at hle ⊢
    linarith [hnum]
  rw [Real.logb, div_lt_iff₀ hl2pos]
  nlinarith [hlogle, hl2l, ht]

end FactorLocalET