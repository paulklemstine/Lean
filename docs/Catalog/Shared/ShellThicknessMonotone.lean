/-
# Cycle 4: monotonicity in the dimension, and a strictly better concentration bound

Cycle 3 (`Shared.ShellThicknessSharp`) trapped the outer-shell thickness of the
equal-volume peeling of `B(0,R) ⊆ ℝ^d` into
`[R/(dN), R/(d(N-1))]` and showed `d · thickness → R log(N/(N-1))`.
The two endpoints of the interval are attained in opposite regimes (`d = 1` and
`d → ∞`), which suggests the rescaled thickness is *monotone* in the dimension.
This file proves that, and harvests the consequences.

1. **The averaging lemma.**  `sum_geom_avg_antitone`: for `0 ≤ y ≤ 1` and
   `a ≤ b`, `a ∑_{i<b} y^i ≤ b ∑_{i<a} y^i` — the Cesàro averages of the
   antitone sequence `y^i` decrease.  Multiplying by `1 - y` and using
   `1 - y^n = (1-y) ∑_{i<n} y^i` gives `mul_one_sub_pow_le`:
   `a (1 - y^b) ≤ b (1 - y^a)`.

2. **Monotonicity.**  `mul_one_sub_rpow_inv_monotone`: for `0 < t ≤ 1` the map
   `d ↦ d (1 - t^{1/d})` is monotone.  The proof substitutes `y = t^{1/(ab)}`
   into (1), so that `y^b = t^{1/a}` and `y^a = t^{1/b}`: an arithmetic
   statement about geometric sums becomes a statement about fractional powers.
   Geometrically, `shell_thickness_rescaled_monotone`: `d · thickness` of the
   outer shell increases with the dimension.

3. **A strictly better bound than the catalog's.**
   `shell_thickness_le_log`: `R - shellRadius R d N 1 ≤ R log(N/(N-1))/d`.
   Monotonicity plus the cycle-3 limit says the supremum of `d · thickness` is
   the limit, so the logarithm is the *optimal* constant, attained only in the
   limit `d → ∞`.  `shell_thickness_log_lt_catalog` shows
   `R log(N/(N-1))/d < R/(d(N-1))` strictly for `R > 0`: the new bound
   strictly improves `shell_thickness_le` for every `d`, `N`, `R > 0`.
   `shell_thickness_optimal_constant` packages the optimality: the bound
   `thickness ≤ R c / d` holds for all `d` iff `c ≥ log(N/(N-1))`.

4. **Exactness at `d = 1`.**  `shell_thickness_dim_one`: in dimension one the
   thickness is exactly `R/N`, so the cycle-3 lower bound is attained and the
   monotone family starts at its lower endpoint.

## Lab notes

`R = 1`, `N = 2`: `d · thickness = 0.5, 0.5858, 0.6156, …, 0.6697 (d=10), …,
0.6908 (d=100)`, increasing towards `log 2 = 0.693147`, and always below it;
the catalog bound is the constant `1`.  So at `d = 100, N = 2` the new bound
`log 2 / d = 0.006931` beats the old `1/d = 0.01` by `30 %`, and is within
`0.3 %` of the truth `0.006908`.  For `N = 10`: `log(10/9) = 0.105361` versus
the old constant `1/9 = 0.111111`, and the `d = 1` value `1/N = 0.1`.
-/
import Mathlib
import Shared.ShellThicknessSharp

namespace Catalog.Shared.ShellSharp

open Finset Filter Topology Catalog.Geometry.Peel

/-! ## Cesàro averages of a geometric sequence -/

/-- For `0 ≤ y ≤ 1` and `a ≤ b`, `a ∑_{i<b} y^i ≤ b ∑_{i<a} y^i`: the averages
`(1/n) ∑_{i<n} y^i` of the antitone sequence `y^i` decrease in `n`. -/
lemma sum_geom_avg_antitone {y : ℝ} (hy0 : 0 ≤ y) (hy1 : y ≤ 1) {a b : ℕ} (hab : a ≤ b) :
    (a : ℝ) * ∑ i ∈ range b, y ^ i ≤ (b : ℝ) * ∑ i ∈ range a, y ^ i := by
  have hsplit : ∑ i ∈ range a, y ^ i + ∑ i ∈ Ico a b, y ^ i = ∑ i ∈ range b, y ^ i :=
    Finset.sum_range_add_sum_Ico _ hab
  have hya : (0 : ℝ) ≤ y ^ a := pow_nonneg hy0 a
  -- the tail is small
  have htail : ∑ i ∈ Ico a b, y ^ i ≤ ((b : ℝ) - a) * y ^ a := by
    have hbnd : ∀ i ∈ Ico a b, y ^ i ≤ y ^ a := by
      intro i hi
      exact pow_le_pow_of_le_one hy0 hy1 (Finset.mem_Ico.1 hi).1
    have h := Finset.sum_le_card_nsmul (Ico a b) (fun i => y ^ i) (y ^ a) hbnd
    rw [Nat.card_Ico, nsmul_eq_mul] at h
    have hcast : ((b - a : ℕ) : ℝ) = (b : ℝ) - a := by
      have : (a : ℝ) ≤ b := by exact_mod_cast hab
      push_cast [Nat.cast_sub hab]
      ring
    rwa [hcast] at h
  -- the head is large
  have hhead : (a : ℝ) * y ^ a ≤ ∑ i ∈ range a, y ^ i := by
    have hbnd : ∀ i ∈ range a, y ^ a ≤ y ^ i := by
      intro i hi
      exact pow_le_pow_of_le_one hy0 hy1 (le_of_lt (Finset.mem_range.1 hi))
    have h := Finset.card_nsmul_le_sum (range a) (fun i => y ^ i) (y ^ a) hbnd
    rwa [Finset.card_range, nsmul_eq_mul] at h
  have hab' : (a : ℝ) ≤ b := by exact_mod_cast hab
  have hapos : (0 : ℝ) ≤ a := Nat.cast_nonneg a
  nlinarith [hsplit, htail, hhead, sub_nonneg.2 hab']

/-- `a (1 - y^b) ≤ b (1 - y^a)` for `0 ≤ y ≤ 1` and `a ≤ b`: the `n`-th root
of the "escape probability" flattens as `n` grows. -/
lemma mul_one_sub_pow_le {y : ℝ} (hy0 : 0 ≤ y) (hy1 : y ≤ 1) {a b : ℕ} (hab : a ≤ b) :
    (a : ℝ) * (1 - y ^ b) ≤ (b : ℝ) * (1 - y ^ a) := by
  have hfac : ∀ n : ℕ, (1 - y) * ∑ i ∈ range n, y ^ i = 1 - y ^ n := by
    intro n
    have := geom_sum_mul y n
    nlinarith [this]
  have hkey := sum_geom_avg_antitone hy0 hy1 hab
  have h1y : (0 : ℝ) ≤ 1 - y := by linarith
  have := mul_le_mul_of_nonneg_left hkey h1y
  calc (a : ℝ) * (1 - y ^ b) = (1 - y) * ((a : ℝ) * ∑ i ∈ range b, y ^ i) := by
        rw [← hfac b]; ring
    _ ≤ (1 - y) * ((b : ℝ) * ∑ i ∈ range a, y ^ i) := this
    _ = (b : ℝ) * (1 - y ^ a) := by rw [← hfac a]; ring

/-! ## Monotonicity in the dimension -/

/-- **Monotonicity of the rescaled deficit.**  For `0 < t ≤ 1` the sequence
`d ↦ d (1 - t^{1/d})` is monotone increasing; by cycle 3 it converges to
`-log t`, so `-log t` is its supremum. -/
theorem mul_one_sub_rpow_inv_monotone {t : ℝ} (ht0 : 0 < t) (ht1 : t ≤ 1) :
    Monotone (fun d : ℕ => (d : ℝ) * (1 - t ^ ((d : ℝ)⁻¹))) := by
  intro a b hab
  rcases Nat.eq_zero_or_pos a with ha | ha
  · subst ha
    have hb1 : t ^ ((b : ℝ)⁻¹) ≤ 1 := Real.rpow_le_one ht0.le ht1 (by positivity)
    have : (0 : ℝ) ≤ (b : ℝ) * (1 - t ^ ((b : ℝ)⁻¹)) := by
      have : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg b
      nlinarith
    simpa using this
  have hb : 0 < b := lt_of_lt_of_le ha hab
  have haR : (0 : ℝ) < a := by exact_mod_cast ha
  have hbR : (0 : ℝ) < b := by exact_mod_cast hb
  set y : ℝ := t ^ (((a : ℝ) * b)⁻¹) with hy
  have hy0 : 0 ≤ y := Real.rpow_nonneg ht0.le _
  have hy1 : y ≤ 1 := Real.rpow_le_one ht0.le ht1 (by positivity)
  have hyb : y ^ b = t ^ ((a : ℝ)⁻¹) := by
    rw [hy, ← Real.rpow_natCast (t ^ (((a : ℝ) * b)⁻¹)) b, ← Real.rpow_mul ht0.le]
    congr 1
    field_simp
  have hya : y ^ a = t ^ ((b : ℝ)⁻¹) := by
    rw [hy, ← Real.rpow_natCast (t ^ (((a : ℝ) * b)⁻¹)) a, ← Real.rpow_mul ht0.le]
    congr 1
    field_simp
  have hmain := mul_one_sub_pow_le hy0 hy1 hab
  rw [hyb, hya] at hmain
  exact hmain

/-- The geometric form: the outer shell thickness of the equal-volume peeling,
rescaled by the dimension, increases with the dimension. -/
theorem shell_thickness_rescaled_monotone (N : ℕ) (hN : 2 ≤ N) {R : ℝ} (hR : 0 ≤ R) :
    Monotone (fun d : ℕ => (d : ℝ) * (R - shellRadius R d N 1)) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  set t : ℝ := 1 - 1 / (N : ℝ) with ht
  have ht0 : 0 < t := by rw [ht, sub_pos, div_lt_one hNpos]; linarith
  have ht1 : t ≤ 1 := by
    have : 0 < 1 / (N : ℝ) := by positivity
    rw [ht]; linarith
  have hrw : ∀ d : ℕ, (d : ℝ) * (R - shellRadius R d N 1)
      = R * ((d : ℝ) * (1 - t ^ ((d : ℝ)⁻¹))) := by
    intro d
    rw [shellRadius_one_eq (R := R) (d := d) hN, ← ht]; ring
  intro a b hab
  have h := mul_one_sub_rpow_inv_monotone ht0 ht1 hab
  show (a : ℝ) * (R - shellRadius R a N 1) ≤ (b : ℝ) * (R - shellRadius R b N 1)
  rw [hrw a, hrw b]
  exact mul_le_mul_of_nonneg_left h hR

/-! ## The optimal constant -/

/-- **The improved concentration bound.**  The outer shell thickness satisfies
`R - shellRadius R d N 1 ≤ R log(N/(N-1)) / d` in every dimension.  By
`shell_thickness_asymptotics` the constant `log(N/(N-1))` is the supremum of
`d · thickness / R`, hence optimal. -/
theorem shell_thickness_le_log (d N : ℕ) (hN : 2 ≤ N) {R : ℝ} (hR : 0 ≤ R) :
    R - shellRadius R d N 1 ≤ R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) / d := by
  rcases Nat.eq_zero_or_pos d with hd | hd
  · subst hd
    have : shellRadius R 0 N 1 = R := by
      rw [shellRadius_one_eq (R := R) (d := 0) hN]
      norm_num
    rw [this]
    norm_num
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have hmono := shell_thickness_rescaled_monotone N hN hR
  have hlim := shell_thickness_asymptotics N hN R
  have hle := hmono.ge_of_tendsto hlim d
  rw [le_div_iff₀ hdR]
  calc (R - shellRadius R d N 1) * (d : ℝ)
      = (d : ℝ) * (R - shellRadius R d N 1) := by ring
    _ ≤ R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) := hle

/-- The improved bound is a *strict* improvement of the catalog bound
`shell_thickness_le` for every dimension `d ≥ 1`, every `N ≥ 2` and every
`R > 0`, because `log x < x - 1` at `x = N/(N-1) ≠ 1`. -/
theorem shell_thickness_log_lt_catalog (d N : ℕ) (hd : 0 < d) (hN : 2 ≤ N) {R : ℝ}
    (hR : 0 < R) :
    R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) / d < R / (d * ((N : ℝ) - 1)) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have hN1 : (0 : ℝ) < (N : ℝ) - 1 := by linarith
  have hx : (0 : ℝ) < (N : ℝ) / ((N : ℝ) - 1) := by positivity
  have hxne : (N : ℝ) / ((N : ℝ) - 1) ≠ 1 := by
    intro h
    rw [div_eq_one_iff_eq (ne_of_gt hN1)] at h
    linarith
  have hlog := Real.log_lt_sub_one_of_pos hx hxne
  have hsub : (N : ℝ) / ((N : ℝ) - 1) - 1 = 1 / ((N : ℝ) - 1) := by
    field_simp
    ring
  rw [hsub] at hlog
  have hkey : R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) < R * (1 / ((N : ℝ) - 1)) :=
    mul_lt_mul_of_pos_left hlog hR
  rw [div_lt_div_iff₀ hdR (by positivity)]
  have hrw : R * (d : ℝ) = (R * (1 / ((N : ℝ) - 1))) * ((d : ℝ) * ((N : ℝ) - 1)) := by
    field_simp
  rw [hrw]
  exact mul_lt_mul_of_pos_right hkey (by positivity)

/-- **Optimality of the constant.**  For `R > 0` the uniform-in-dimension bound
`thickness ≤ R c / d` holds for every `d` if and only if
`c ≥ log(N/(N-1))`. -/
theorem shell_thickness_optimal_constant (N : ℕ) (hN : 2 ≤ N) {R : ℝ} (hR : 0 < R) (c : ℝ) :
    (∀ d : ℕ, 0 < d → R - shellRadius R d N 1 ≤ R * c / d) ↔
      Real.log ((N : ℝ) / ((N : ℝ) - 1)) ≤ c := by
  constructor
  · intro h
    -- pass to the limit in `d · thickness ≤ R c`
    have hlim := shell_thickness_asymptotics N hN R
    have hev : ∀ᶠ d : ℕ in atTop, (d : ℝ) * (R - shellRadius R d N 1) ≤ R * c := by
      filter_upwards [eventually_gt_atTop 0] with d hd
      have hdR : (0 : ℝ) < d := by exact_mod_cast hd
      have := h d hd
      rw [le_div_iff₀ hdR] at this
      linarith [this]
    have hle : R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) ≤ R * c := le_of_tendsto hlim hev
    exact le_of_mul_le_mul_left hle hR
  · intro hc d hd
    have hdR : (0 : ℝ) < d := by exact_mod_cast hd
    have h1 := shell_thickness_le_log d N hN hR.le
    have hnum : R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) ≤ R * c :=
      mul_le_mul_of_nonneg_left hc hR.le
    have h2 : R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) / d ≤ R * c / d := by
      gcongr
    linarith

/-- In dimension one the outer shell thickness is exactly `R/N`, so the
cycle-3 lower bound `R/(dN)` is attained and the monotone family
`d ↦ d · thickness` starts at its lower endpoint. -/
theorem shell_thickness_dim_one (N : ℕ) (hN : 2 ≤ N) (R : ℝ) :
    R - shellRadius R 1 N 1 = R / N := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  rw [shellRadius_one_eq (R := R) (d := 1) hN]
  norm_num
  field_simp
  ring

end Catalog.Shared.ShellSharp