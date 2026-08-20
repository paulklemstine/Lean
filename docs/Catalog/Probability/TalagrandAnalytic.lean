import Mathlib

/-!
# Analytic ingredients for Talagrand's inequality

This file isolates the two purely analytic facts needed for the inductive proof
of Talagrand's concentration inequality on product spaces.

## Main results

* `Talagrand.weighted_holder` — Hölder's inequality for finite weighted sums:
  `∑ q i * f i ^ lam * g i ^ (1 - lam) ≤ (∑ q i * f i) ^ lam * (∑ q i * g i) ^ (1 - lam)`
  for a probability weight `q` and `lam ∈ [0,1]`.  It is derived from the
  two-point weighted AM–GM inequality.

* `Talagrand.exists_lambda_bound` — the *interpolation lemma*: for every
  `r ∈ [0,1]` there is `lam ∈ [0,1]` with
  `exp ((1 - lam) ^ 2 / 4) * r ^ (-lam) ≤ 2 - r`.
  This is the exact point where the constant `1/4` in the exponent enters, and
  `1/4` is optimal: the inequality fails for any larger constant.  The optimal
  `lam` is `1 + 2 * log r`, and the resulting scalar inequality
  `exp (u - u ^ 2) ≤ 2 - exp (-u)` for `u ∈ [0, 1/2]` is third-order tight at
  `u = 0`; it is proved from explicit quartic Taylor bounds on `exp`.
-/

namespace Talagrand

open Finset Real

/-! ### Explicit Taylor bounds for `exp` -/

/-- Quadratic upper bound for `exp` on `[0,1]`. -/
lemma exp_le_quadratic {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Real.exp t ≤ 1 + t + (3 / 4) * t ^ 2 := by
  have h := Real.exp_bound' ht0 ht1 (n := 2) (by norm_num)
  have hsum : (∑ m ∈ Finset.range 2, t ^ m / (Nat.factorial m)) = 1 + t := by
    simp [Finset.sum_range_succ]
  rw [hsum] at h
  refine h.trans_eq ?_
  norm_num [Nat.factorial]
  ring

/-- Cubic upper bound for `exp (-u)`, `u ∈ [0,1]`. -/
lemma exp_neg_le_cubic {u : ℝ} (hu0 : 0 ≤ u) (hu1 : u ≤ 1) :
    Real.exp (-u) ≤ 1 - u + u ^ 2 / 2 + (2 / 9) * u ^ 3 := by
  have habs : |(-u)| ≤ 1 := by
    rw [abs_neg, abs_of_nonneg hu0]; exact hu1
  have h := Real.exp_bound habs (n := 3) (by norm_num)
  have hsum : (∑ m ∈ Finset.range 3, (-u) ^ m / (Nat.factorial m)) = 1 - u + u ^ 2 / 2 := by
    simp [Finset.sum_range_succ, Nat.factorial]
    ring
  rw [hsum] at h
  have h2 : Real.exp (-u) - (1 - u + u ^ 2 / 2) ≤ |(-u)| ^ 3 * (4 / ((Nat.factorial 3) * 3)) :=
    (abs_le.mp h).2
  have h3 : |(-u)| ^ 3 * ((4 : ℝ) / ((Nat.factorial 3) * 3)) = (2 / 9) * u ^ 3 := by
    rw [abs_neg, abs_of_nonneg hu0]
    norm_num [Nat.factorial]
    ring
  rw [h3] at h2
  linarith

/-- Quartic upper bound for `exp` on `[0,1]`. -/
lemma exp_le_quartic {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Real.exp t ≤ 1 + t + t ^ 2 / 2 + t ^ 3 / 6 + (5 / 96) * t ^ 4 := by
  have h := Real.exp_bound' ht0 ht1 (n := 4) (by norm_num)
  have hsum : (∑ m ∈ Finset.range 4, t ^ m / (Nat.factorial m))
      = 1 + t + t ^ 2 / 2 + t ^ 3 / 6 := by
    simp [Finset.sum_range_succ, Nat.factorial]
  rw [hsum] at h
  refine h.trans_eq ?_
  norm_num [Nat.factorial]
  ring

/-- Quartic upper bound for `exp (-u)`, `u ∈ [0,1]`. -/
lemma exp_neg_le_quartic {u : ℝ} (hu0 : 0 ≤ u) (hu1 : u ≤ 1) :
    Real.exp (-u) ≤ 1 - u + u ^ 2 / 2 - u ^ 3 / 6 + (5 / 96) * u ^ 4 := by
  have habs : |(-u)| ≤ 1 := by rw [abs_neg, abs_of_nonneg hu0]; exact hu1
  have h := Real.exp_bound habs (n := 4) (by norm_num)
  have hsum : (∑ m ∈ Finset.range 4, (-u) ^ m / (Nat.factorial m))
      = 1 - u + u ^ 2 / 2 - u ^ 3 / 6 := by
    simp [Finset.sum_range_succ, Nat.factorial]
    ring
  rw [hsum] at h
  have h2 := (abs_le.mp h).2
  have h3 : |(-u)| ^ 4 * ((Nat.succ 4 : ℝ) / ((Nat.factorial 4) * (4:ℕ))) = (5 / 96) * u ^ 4 := by
    rw [abs_neg, abs_of_nonneg hu0]
    norm_num [Nat.factorial]
    ring
  rw [h3] at h2
  linarith

/-- The scalar heart of the interpolation lemma, at the optimal constant. -/
lemma exp_sub_sq_le {u : ℝ} (hu0 : 0 ≤ u) (hu1 : u ≤ 1 / 2) :
    Real.exp (u - u ^ 2) ≤ 2 - Real.exp (-u) := by
  have ht0 : 0 ≤ u - u ^ 2 := by nlinarith
  have ht1 : u - u ^ 2 ≤ 1 := by nlinarith
  have h1 := exp_le_quartic ht0 ht1
  have h2 := exp_neg_le_quartic hu0 (by linarith)
  nlinarith [pow_nonneg hu0 3, pow_nonneg hu0 4, pow_nonneg hu0 5, pow_nonneg hu0 6, sq_nonneg u]

/-! ### The interpolation lemma -/

/-- **Interpolation lemma.**  For every `r ∈ [0,1]` there is a mixing parameter
`lam ∈ [0,1]` with `exp ((1 - lam) ^ 2 / 4) * r ^ (-lam) ≤ 2 - r`. -/
lemma exists_lambda_bound {r : ℝ} (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    ∃ lam : ℝ, 0 ≤ lam ∧ lam ≤ 1 ∧
      Real.exp ((1 - lam) ^ 2 / 4) * r ^ (-lam) ≤ 2 - r := by
  by_cases hsmall : r < Real.exp (-(1/2))
  · -- crude bound with `lam = 0`
    refine ⟨0, le_rfl, zero_le_one, ?_⟩
    rw [neg_zero, Real.rpow_zero, mul_one]
    have hexp : Real.exp ((1 - 0) ^ 2 / 4) ≤ 1 + (1/4 : ℝ) + (3/4) * (1/4 : ℝ) ^ 2 := by
      have := exp_le_quadratic (t := (1/4 : ℝ)) (by norm_num) (by norm_num)
      simpa using this
    have hrsmall : r ≤ 1 - (1/2 : ℝ) + (1/2 : ℝ) ^ 2 / 2 + (2/9) * (1/2 : ℝ) ^ 3 := by
      have := exp_neg_le_cubic (u := (1/2 : ℝ)) (by norm_num) (by norm_num)
      linarith [hsmall.le]
    norm_num at hexp hrsmall ⊢
    linarith
  · push_neg at hsmall
    have hrpos : 0 < r := lt_of_lt_of_le (Real.exp_pos _) hsmall
    set u : ℝ := -Real.log r with hu
    have hu0 : 0 ≤ u := by
      have : Real.log r ≤ 0 := Real.log_nonpos hr0 hr1
      simpa [hu] using this
    have hu1 : u ≤ 1 / 2 := by
      have hlog : -(1/2 : ℝ) ≤ Real.log r := by
        have := Real.log_le_log (Real.exp_pos _) hsmall
        simpa [Real.log_exp] using this
      have hue : u = -Real.log r := rfl
      rw [hue]; linarith
    refine ⟨1 - 2 * u, by linarith, by linarith [hu0], ?_⟩
    have hrp : r ^ (-(1 - 2 * u)) = Real.exp (Real.log r * -(1 - 2 * u)) :=
      Real.rpow_def_of_pos hrpos _
    have hlogr : Real.log r = -u := by simp [hu]
    have hre : r = Real.exp (-u) := by
      rw [← hlogr, Real.exp_log hrpos]
    rw [hrp, ← Real.exp_add]
    have harg : (1 - (1 - 2 * u)) ^ 2 / 4 + Real.log r * -(1 - 2 * u) = u - u ^ 2 := by
      rw [hlogr]; ring
    rw [harg, hre]
    exact exp_sub_sq_le hu0 hu1

/-! ### Hölder's inequality for finite weighted sums -/

/-- **Weighted Hölder inequality** for finite sums, with exponents `1/lam` and
`1/(1-lam)`. -/
lemma weighted_holder {ι : Type*} (s : Finset ι) (q f g : ι → ℝ) {lam : ℝ}
    (hlam0 : 0 ≤ lam) (hlam1 : lam ≤ 1)
    (hq : ∀ i ∈ s, 0 ≤ q i)
    (hf : ∀ i ∈ s, 0 ≤ f i) (hg : ∀ i ∈ s, 0 ≤ g i)
    (hF : 0 < ∑ i ∈ s, q i * f i) (hG : 0 < ∑ i ∈ s, q i * g i) :
    ∑ i ∈ s, q i * (f i ^ lam * g i ^ (1 - lam)) ≤
      (∑ i ∈ s, q i * f i) ^ lam * (∑ i ∈ s, q i * g i) ^ (1 - lam) := by
  set F := ∑ i ∈ s, q i * f i with hFdef
  set G := ∑ i ∈ s, q i * g i with hGdef
  have hFpow : 0 < F ^ lam := Real.rpow_pos_of_pos hF _
  have hGpow : 0 < G ^ (1 - lam) := Real.rpow_pos_of_pos hG _
  have key : ∀ i ∈ s, q i * (f i ^ lam * g i ^ (1 - lam)) ≤
      F ^ lam * G ^ (1 - lam) * (q i * (lam * (f i / F) + (1 - lam) * (g i / G))) := by
    intro i hi
    have hfi := hf i hi
    have hgi := hg i hi
    have hAM : (f i / F) ^ lam * (g i / G) ^ (1 - lam) ≤
        lam * (f i / F) + (1 - lam) * (g i / G) :=
      Real.geom_mean_le_arith_mean2_weighted hlam0 (by linarith)
        (div_nonneg hfi hF.le) (div_nonneg hgi hG.le) (by ring)
    have hsplit : f i ^ lam * g i ^ (1 - lam)
        = F ^ lam * G ^ (1 - lam) * ((f i / F) ^ lam * (g i / G) ^ (1 - lam)) := by
      rw [Real.div_rpow hfi hF.le, Real.div_rpow hgi hG.le]
      field_simp
    rw [hsplit]
    have hqi := hq i hi
    have hpos : 0 ≤ F ^ lam * G ^ (1 - lam) := (mul_pos hFpow hGpow).le
    calc q i * (F ^ lam * G ^ (1 - lam) * ((f i / F) ^ lam * (g i / G) ^ (1 - lam)))
        = F ^ lam * G ^ (1 - lam) * (q i * ((f i / F) ^ lam * (g i / G) ^ (1 - lam))) := by ring
      _ ≤ F ^ lam * G ^ (1 - lam) * (q i * (lam * (f i / F) + (1 - lam) * (g i / G))) := by
          exact mul_le_mul_of_nonneg_left
            (mul_le_mul_of_nonneg_left hAM hqi) hpos
  refine (Finset.sum_le_sum key).trans_eq ?_
  rw [← Finset.mul_sum]
  have hsum : ∑ i ∈ s, q i * (lam * (f i / F) + (1 - lam) * (g i / G)) = 1 := by
    have h1 : ∑ i ∈ s, q i * (lam * (f i / F) + (1 - lam) * (g i / G))
        = (lam / F) * (∑ i ∈ s, q i * f i) + ((1 - lam) / G) * (∑ i ∈ s, q i * g i) := by
      rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
      refine Finset.sum_congr rfl fun i _ => ?_
      field_simp
    rw [h1, ← hFdef, ← hGdef]
    field_simp
    ring
  rw [hsum, mul_one]

end Talagrand