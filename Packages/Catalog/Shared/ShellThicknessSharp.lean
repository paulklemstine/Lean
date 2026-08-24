/-
# Cycle 3: the outer-shell thickness bound is sharp, and the exponential profile

The previous cycle (`Geometry.PeelStabilityConcentration`) proved the boundary
concentration estimate

`shell_thickness_le : R - shellRadius R d N 1 ≤ R / (d (N-1))`

for the equal-volume peeling of `B(0,R) ⊆ ℝ^d` into `N` shells.  An upper bound
alone says nothing about how much of the truth it captures: a priori the true
thickness could be `0`.  This file closes that gap in four steps.

1. **Matching lower bound.**  `shell_thickness_ge`:
   `R/(d (N-1)) · (1 - 1/N) ≤ R - shellRadius R d N 1`.
   The proof is the mirror of the previous cycle's: where that one bounded the
   geometric sum `1 + s + ⋯ + s^{d-1}` *below* by `d s^{d-1}`, this one bounds
   it *above* by `d`.  Together (`shell_thickness_sandwich`) the two pin the
   thickness into a window of multiplicative width `N/(N-1)`, and
   `shell_thickness_le_sharp` states the resulting relative error of the old
   bound: at most `1/N`.  At `d = 1` the lower bound is an equality, so no
   constant factor can be removed from it.

2. **General shell.**  `shell_depth_sandwich` extends the sandwich to every
   sphere `k < N` of the decomposition: `R(k/N)/d ≤ R - shellRadius R d N k ≤
   R(k/N)/(d(1 - k/N))`.  The whole decomposition, not just its outer shell,
   lives at depth `Θ(1/d)`.

3. **Exact exponential profile and its scale.**
   `shell_thickness_exp_profile` : `R - shellRadius R d N k = R(1 - e^{-t})`
   with `t = shellDepthParam d N k = -log(1 - k/N)/d`; the profile of the
   decomposition is exponential *exactly*, and the rescaling by `d` hidden in
   `t` is the whole content of the concentration phenomenon.
   `shell_thickness_asymptotics` identifies the scale in the limit:
   `d · (R - shellRadius R d N 1) → R log(N/(N-1))`, via the general
   `tendsto_mul_one_sub_rpow_inv` : `d(1 - x^{1/d}) → -log x`.
   `peel_removed_fraction_tendsto` is the dual, volume-side statement: peeling
   a shell of thickness `R u / d` removes a fraction of the volume tending to
   `1 - e^{-u}`.

4. **A payoff going the other way.**  Because the sandwich of step 1 holds for
   *every* `d` while step 3 computes the limit of the same quantity, the
   geometry forces the analytic inequality
   `log_ratio_sandwich_of_shell : 1/N ≤ log(N/(N-1)) ≤ 1/(N-1)`.

## Lab notes

`R = 1`.  `d = 10, N = 2`: thickness `0.066967`, lower bound `1/(dN) = 0.05`,
upper bound `1/(d(N-1)) = 0.1`, ratio to upper bound `0.670`.
`d = 100, N = 2`: `0.006908` in `[0.005, 0.01]`, ratio `0.691`.
`d = 10, N = 100`: `0.0010040` in `[0.001, 0.0010101]`, ratio `0.994` — the
factor `1 - 1/N` in `shell_thickness_ge` is visibly the exact loss.
`d·thickness` for `N = 2` runs `0.5, 0.586, 0.670, 0.691, …` towards
`log 2 = 0.69315`, and stays inside `[1/N, 1/(N-1)] = [0.5, 1]`, which is the
sandwich of step 4 in action.  See `ComputationalEvidence.md`.
-/
import Mathlib
import Geometry.PeelStabilityConcentration

namespace Catalog.Shared.ShellSharp

open Finset Filter Metric MeasureTheory Topology Catalog.Geometry.Peel

/-! ## The elementary inequality behind the lower bound -/

/-- For `0 ≤ s ≤ 1`, `1 - s^d ≤ d (1 - s)`: the geometric sum
`1 + s + ⋯ + s^{d-1}` in the factorisation `1 - s^d = (1-s)(1 + ⋯ + s^{d-1})`
has each term at most `1`.  This is the exact mirror of the previous cycle's
`one_sub_pow_ge`, which bounded the same sum below by `d s^{d-1}`. -/
lemma one_sub_pow_le_mul (d : ℕ) {s : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) :
    1 - s ^ d ≤ (d : ℝ) * (1 - s) := by
  have hgeom : (1 - s) * ∑ i ∈ range d, s ^ i = 1 - s ^ d := by
    have := geom_sum_mul s d
    nlinarith [this]
  have hup : ∑ i ∈ range d, s ^ i ≤ (d : ℝ) := by
    calc ∑ i ∈ range d, s ^ i ≤ ∑ _i ∈ range d, (1 : ℝ) :=
          Finset.sum_le_sum fun i _ => pow_le_one₀ hs0 hs1
      _ = (d : ℝ) := by simp
  nlinarith [sub_nonneg.2 hs1, hgeom, hup]

/-- The normalised lower estimate: `(1 - t)/d ≤ 1 - t^{1/d}` for `t ∈ [0,1]`.
Equality holds at `d = 1`. -/
lemma one_sub_rpow_inv_ge {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) {d : ℕ} (hd : 0 < d) :
    (1 - t) / d ≤ 1 - t ^ ((d : ℝ)⁻¹) := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set s : ℝ := t ^ ((d : ℝ)⁻¹) with hs
  have hs0 : 0 ≤ s := Real.rpow_nonneg ht0 _
  have hs1 : s ≤ 1 := Real.rpow_le_one ht0 ht1 (by positivity)
  have hsd : s ^ d = t := Real.rpow_inv_natCast_pow ht0 hd.ne'
  have hkey := one_sub_pow_le_mul d hs0 hs1
  rw [hsd] at hkey
  rw [div_le_iff₀ hdpos]
  nlinarith [hkey]

/-! ## The sandwich for the outermost shell -/

/-- Explicit form of the outermost sphere of the equal-volume peeling. -/
lemma shellRadius_one_eq {R : ℝ} {d N : ℕ} (hN : 2 ≤ N) :
    shellRadius R d N 1 = R * (1 - 1 / (N : ℝ)) ^ ((d : ℝ)⁻¹) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  have hmax : max (0 : ℝ) (1 - ((1 : ℕ) : ℝ) / (N : ℝ)) = 1 - 1 / (N : ℝ) := by
    rw [Nat.cast_one]
    refine max_eq_right ?_
    rw [sub_nonneg, div_le_one hNpos]
    linarith
  rw [shellRadius, hmax]

/-- **Sharpness of the concentration bound (lower half).**  The outermost shell
of the equal-volume peeling of `B(0,R) ⊆ ℝ^d` into `N` shells has thickness at
least `R/(d(N-1)) · (1 - 1/N) = R/(dN)`.  Together with the previous cycle's
`shell_thickness_le` this shows that bound is off by at most the factor
`1 - 1/N`; at `d = 1` the present bound is an equality. -/
theorem shell_thickness_ge (d N : ℕ) (hd : 0 < d) (hN : 2 ≤ N) {R : ℝ} (hR : 0 ≤ R) :
    R / (d * ((N : ℝ) - 1)) * (1 - 1 / (N : ℝ)) ≤ R - shellRadius R d N 1 := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set t : ℝ := 1 - 1 / (N : ℝ) with ht
  have ht0 : 0 ≤ t := by rw [ht, sub_nonneg, div_le_one hNpos]; linarith
  have ht1 : t ≤ 1 := by
    have : 0 < 1 / (N : ℝ) := by positivity
    rw [ht]; linarith
  have hbase := one_sub_rpow_inv_ge ht0 ht1 hd
  have hone_sub : 1 - t = 1 / (N : ℝ) := by rw [ht]; ring
  rw [hone_sub] at hbase
  have hN0 : (N : ℝ) ≠ 0 := ne_of_gt hNpos
  have hd0 : (d : ℝ) ≠ 0 := ne_of_gt hdpos
  have hNm : (-1 + (N : ℝ)) ≠ 0 := by intro h; linarith
  have hNm2 : ((N : ℝ) - 1) ≠ 0 := by intro h; linarith
  have hsimp : R / ((d : ℝ) * ((N : ℝ) - 1)) * (1 - 1 / (N : ℝ))
      = R * (1 / (N : ℝ) / (d : ℝ)) := by
    field_simp
  rw [shellRadius_one_eq hN, hsimp, ← ht]
  have : R - R * t ^ ((d : ℝ)⁻¹) = R * (1 - t ^ ((d : ℝ)⁻¹)) := by ring
  rw [this]
  exact mul_le_mul_of_nonneg_left hbase hR

/-- **The two-sided estimate.**  `R/(dN) ≤ thickness ≤ R/(d(N-1))`: the
outermost equal-volume shell has thickness of order `R/(dN)`, and the window is
of multiplicative width `N/(N-1)`. -/
theorem shell_thickness_sandwich (d N : ℕ) (hd : 0 < d) (hN : 2 ≤ N) {R : ℝ} (hR : 0 ≤ R) :
    R / (d * ((N : ℝ) - 1)) * (1 - 1 / (N : ℝ)) ≤ R - shellRadius R d N 1 ∧
      R - shellRadius R d N 1 ≤ R / (d * ((N : ℝ) - 1)) :=
  ⟨shell_thickness_ge d N hd hN hR, shell_thickness_le d N hd hN hR⟩

/-- **Relative error of the previous cycle's bound.**  The upper bound
`R/(d(N-1))` overshoots the true thickness by at most a `1/N` fraction of
itself, hence is asymptotically exact as `N → ∞`, uniformly in `d` and `R`. -/
theorem shell_thickness_le_sharp (d N : ℕ) (hd : 0 < d) (hN : 2 ≤ N) {R : ℝ} (hR : 0 ≤ R) :
    R / (d * ((N : ℝ) - 1)) - (R - shellRadius R d N 1)
      ≤ R / (d * ((N : ℝ) - 1)) * (1 / (N : ℝ)) := by
  have h := shell_thickness_ge d N hd hN hR
  nlinarith [h]

/-! ## Every shell, not just the outermost one -/

/-- **Sandwich for the `k`-th sphere.**  For `k < N` the depth of the `k`-th
sphere of the equal-volume peeling satisfies
`R (k/N)/d ≤ R - shellRadius R d N k ≤ R (k/N)/(d(1 - k/N))`.
For `k = 1` this is `shell_thickness_sandwich`. -/
theorem shell_depth_sandwich (d N k : ℕ) (hd : 0 < d) (hk : k < N) {R : ℝ} (hR : 0 ≤ R) :
    R * ((k : ℝ) / N) / d ≤ R - shellRadius R d N k ∧
      R - shellRadius R d N k ≤ R * ((k : ℝ) / N) / (d * (1 - (k : ℝ) / N)) := by
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
    exact_mod_cast this
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hkN : (k : ℝ) < N := by exact_mod_cast hk
  set t : ℝ := 1 - (k : ℝ) / N with ht
  have ht0 : 0 < t := by
    rw [ht, sub_pos, div_lt_one hNpos]; exact hkN
  have ht1 : t ≤ 1 := by
    have : 0 ≤ (k : ℝ) / N := by positivity
    rw [ht]; linarith
  have hone_sub : 1 - t = (k : ℝ) / N := by rw [ht]; ring
  have hrad : shellRadius R d N k = R * t ^ ((d : ℝ)⁻¹) := by
    rw [shellRadius, ← ht, max_eq_right ht0.le]
  have hdepth : R - shellRadius R d N k = R * (1 - t ^ ((d : ℝ)⁻¹)) := by
    rw [hrad]; ring
  constructor
  · have hbase := one_sub_rpow_inv_ge ht0.le ht1 hd
    rw [hone_sub] at hbase
    rw [hdepth]
    calc R * ((k : ℝ) / N) / d = R * (((k : ℝ) / N) / d) := by ring
      _ ≤ R * (1 - t ^ ((d : ℝ)⁻¹)) := mul_le_mul_of_nonneg_left hbase hR
  · -- upper bound: `1 - t^{1/d} ≤ (1-t)/(d t)` from `1 - s^d ≥ d s^{d-1}(1-s)`
    set s : ℝ := t ^ ((d : ℝ)⁻¹) with hs
    have hs0 : 0 ≤ s := Real.rpow_nonneg ht0.le _
    have hs1 : s ≤ 1 := Real.rpow_le_one ht0.le ht1 (by positivity)
    have hsd : s ^ d = t := Real.rpow_inv_natCast_pow ht0.le hd.ne'
    have hkey := one_sub_pow_ge d hs0 hs1
    have hpow : s ^ d ≤ s ^ (d - 1) := pow_le_pow_of_le_one hs0 hs1 (by omega)
    rw [hsd] at hkey hpow
    have hs' : (0 : ℝ) ≤ 1 - s := by
      have : s ≤ 1 := hs1
      linarith
    have h1 : (1 - s) * ((d : ℝ) * t) ≤ 1 - t :=
      le_trans (mul_le_mul_of_nonneg_left
        (mul_le_mul_of_nonneg_left hpow (by positivity)) hs') hkey
    rw [hone_sub] at h1
    have hbound : 1 - s ≤ ((k : ℝ) / N) / ((d : ℝ) * t) := by
      rw [le_div_iff₀ (by positivity : (0 : ℝ) < (d : ℝ) * t)]
      linarith [h1]
    rw [hdepth]
    calc R * (1 - s) ≤ R * (((k : ℝ) / N) / ((d : ℝ) * t)) :=
          mul_le_mul_of_nonneg_left hbound hR
      _ = R * ((k : ℝ) / N) / (d * (1 - (k : ℝ) / N)) := by rw [ht]; ring

/-! ## The exponential profile -/

/-- The rescaled depth parameter of the `k`-th sphere: `t = -log(1 - k/N)/d`.
The factor `1/d` is the rescaling under which the shell decomposition has a
nondegenerate limit. -/
noncomputable def shellDepthParam (d N k : ℕ) : ℝ :=
  -Real.log (1 - (k : ℝ) / N) / d

/-- **The profile is exactly exponential.**  For every `d ≥ 1` and `k < N`,
`R - shellRadius R d N k = R (1 - e^{-t})` with `t = shellDepthParam d N k`.
No limit is involved: the exponential profile `R(1 - e^{-t})` *is* the shell
decomposition, read in the rescaled depth variable. -/
theorem shell_thickness_exp_profile (d N k : ℕ) (hd : 0 < d) (hk : k < N) (R : ℝ) :
    R - shellRadius R d N k = R * (1 - Real.exp (-shellDepthParam d N k)) := by
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
    exact_mod_cast this
  have hkN : (k : ℝ) < N := by exact_mod_cast hk
  have ht0 : (0 : ℝ) < 1 - (k : ℝ) / N := by rw [sub_pos, div_lt_one hNpos]; exact hkN
  have hrad : shellRadius R d N k = R * (1 - (k : ℝ) / N) ^ ((d : ℝ)⁻¹) := by
    rw [shellRadius, max_eq_right ht0.le]
  have hexp : (1 - (k : ℝ) / N) ^ ((d : ℝ)⁻¹)
      = Real.exp (-shellDepthParam d N k) := by
    rw [Real.rpow_def_of_pos ht0, shellDepthParam]
    congr 1
    field_simp
  rw [hrad, hexp]; ring

/-! ## Identifying the scale: `d ·` thickness converges -/

/-- The key limit: `d (1 - x^{1/d}) → -log x` for `0 < x ≤ 1`.  Proof by
squeezing between `-L/(1 - L/d)` and `-L` where `L = log x ≤ 0`, using
`1 + u ≤ e^u` on both sides. -/
theorem tendsto_mul_one_sub_rpow_inv {x : ℝ} (hx : 0 < x) (hx1 : x ≤ 1) :
    Tendsto (fun d : ℕ => (d : ℝ) * (1 - x ^ ((d : ℝ)⁻¹))) atTop
      (𝓝 (-Real.log x)) := by
  set L : ℝ := Real.log x with hL
  have hLle : L ≤ 0 := Real.log_nonpos hx.le hx1
  -- the lower squeeze function
  have hlow : Tendsto (fun d : ℕ => -L * ((d : ℝ) / ((d : ℝ) - L))) atTop (𝓝 (-L)) := by
    have h1 : Tendsto (fun d : ℕ => L / (d : ℝ)) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat L
    have h2 : Tendsto (fun d : ℕ => 1 - L / (d : ℝ)) atTop (𝓝 1) := by
      simpa using (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub h1
    have h3 : Tendsto (fun d : ℕ => -L / (1 - L / (d : ℝ))) atTop (𝓝 (-L / 1)) :=
      (tendsto_const_nhds (x := -L) (f := atTop (α := ℕ))).div h2 one_ne_zero
    rw [div_one] at h3
    refine h3.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with d hd
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have hne : (d : ℝ) - L ≠ 0 := by nlinarith
    field_simp
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with d hd
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have hu : x ^ ((d : ℝ)⁻¹) = Real.exp (L / d) := by
      rw [Real.rpow_def_of_pos hx, ← hL, ← div_eq_mul_inv]
    -- `e^u ≤ 1/(1-u)` for `u ≤ 0`
    have hle : Real.exp (L / (d : ℝ)) ≤ 1 / (1 - L / (d : ℝ)) := by
      have h1 : (1 : ℝ) - L / d ≤ Real.exp (-(L / d)) := by
        have := Real.add_one_le_exp (-(L / (d : ℝ)))
        linarith
      have hpos : (0 : ℝ) < 1 - L / d := by
        have : L / (d : ℝ) ≤ 0 := div_nonpos_of_nonpos_of_nonneg hLle hdpos.le
        linarith
      rw [le_div_iff₀ hpos]
      calc Real.exp (L / (d : ℝ)) * (1 - L / d)
          ≤ Real.exp (L / (d : ℝ)) * Real.exp (-(L / d)) := by
            exact mul_le_mul_of_nonneg_left h1 (Real.exp_pos _).le
        _ = 1 := by rw [← Real.exp_add]; simp
    have hpos : (0 : ℝ) < 1 - L / d := by
      have : L / (d : ℝ) ≤ 0 := div_nonpos_of_nonpos_of_nonneg hLle hdpos.le
      linarith
    have hgoal : -L * ((d : ℝ) / ((d : ℝ) - L)) ≤ (d : ℝ) * (1 - Real.exp (L / d)) := by
      have h2 : 1 - 1 / (1 - L / (d : ℝ)) ≤ 1 - Real.exp (L / d) := by linarith
      have h3 : -L * ((d : ℝ) / ((d : ℝ) - L)) = (d : ℝ) * (1 - 1 / (1 - L / (d : ℝ))) := by
        have hne : (d : ℝ) - L ≠ 0 := by nlinarith
        field_simp
        ring
      rw [h3]
      exact mul_le_mul_of_nonneg_left h2 hdpos.le
    rw [hu]
    exact hgoal
  · filter_upwards [eventually_gt_atTop 0] with d hd
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have hu : x ^ ((d : ℝ)⁻¹) = Real.exp (L / d) := by
      rw [Real.rpow_def_of_pos hx, ← hL, ← div_eq_mul_inv]
    have h1 : (1 : ℝ) + L / d ≤ Real.exp (L / d) := by
      have := Real.add_one_le_exp (L / (d : ℝ)); linarith
    have : (d : ℝ) * (1 - Real.exp (L / d)) ≤ -L := by
      have h2 : 1 - Real.exp (L / (d : ℝ)) ≤ -(L / d) := by linarith
      have := mul_le_mul_of_nonneg_left h2 hdpos.le
      calc (d : ℝ) * (1 - Real.exp (L / d)) ≤ (d : ℝ) * (-(L / d)) := this
        _ = -L := by field_simp
    rw [hu]; exact this

/-- **Asymptotics of the outer shell thickness.**  After rescaling by the
dimension, the thickness of the outermost equal-volume shell converges:
`d · (R - shellRadius R d N 1) → R log(N/(N-1))`.
Combined with `shell_thickness_sandwich` this shows the rescaled thickness is
trapped in `[R/N, R/(N-1)]` for every `d` and converges to a point of that
interval. -/
theorem shell_thickness_asymptotics (N : ℕ) (hN : 2 ≤ N) (R : ℝ) :
    Tendsto (fun d : ℕ => (d : ℝ) * (R - shellRadius R d N 1)) atTop
      (𝓝 (R * Real.log ((N : ℝ) / ((N : ℝ) - 1)))) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  set t : ℝ := 1 - 1 / (N : ℝ) with ht
  have ht0 : 0 < t := by
    rw [ht, sub_pos, div_lt_one hNpos]; linarith
  have ht1 : t ≤ 1 := by
    have : 0 < 1 / (N : ℝ) := by positivity
    rw [ht]; linarith
  have hlog : -Real.log t = Real.log ((N : ℝ) / ((N : ℝ) - 1)) := by
    have hteq : t = ((N : ℝ) - 1) / N := by rw [ht]; field_simp
    rw [hteq, ← Real.log_inv]
    congr 1
    rw [inv_div]
  have hbase := (tendsto_mul_one_sub_rpow_inv ht0 ht1).const_mul R
  rw [hlog] at hbase
  refine (hbase.congr ?_)
  intro d
  rw [shellRadius_one_eq (R := R) (d := d) hN, ← ht]
  ring

/-! ## The dual, volume-side statement: `1 - e^{-t}` -/

/-- **Exponential volume profile.**  Peeling off a shell of thickness `R u/d`
from `B(0,R) ⊆ ℝ^d` leaves the volume fraction `(1 - u/d)^d → e^{-u}`.
This is the sense in which the equal-volume decomposition, rescaled by `d`,
converges to the exponential profile. -/
theorem peel_volume_fraction_tendsto {R : ℝ} (hR : 0 < R) (u : ℝ) :
    Tendsto (fun d : ℕ => ballVol d (R * (1 - u / d)) / ballVol d R) atTop
      (𝓝 (Real.exp (-u))) := by
  have hbase : Tendsto (fun d : ℕ => (1 + (-u) / (d : ℝ)) ^ d) atTop
      (𝓝 (Real.exp (-u))) := Real.tendsto_one_add_div_pow_exp (-u)
  refine hbase.congr' ?_
  filter_upwards [eventually_gt_atTop 0, eventually_ge_atTop ⌈u⌉₊] with d hd hdu
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hud : u / (d : ℝ) ≤ 1 := by
    rw [div_le_one hdpos]
    calc u ≤ (⌈u⌉₊ : ℝ) := Nat.le_ceil u
      _ ≤ (d : ℝ) := by exact_mod_cast hdu
  have hfac : (0 : ℝ) ≤ 1 - u / d := by linarith
  have hr : (0 : ℝ) ≤ R * (1 - u / d) := mul_nonneg hR.le hfac
  have hvol1 : ballVol d (R * (1 - u / d)) = (R * (1 - u / d)) ^ d * ballVol d 1 :=
    ballVol_eq d hd hr
  have hvol2 : ballVol d R = R ^ d * ballVol d 1 := ballVol_eq d hd hR.le
  have hv1 : (0 : ℝ) < ballVol d 1 := ballVol_one_pos d
  have hRd : (0 : ℝ) < R ^ d := pow_pos hR d
  rw [hvol1, hvol2, mul_pow]
  have : (1 : ℝ) + (-u) / d = 1 - u / d := by ring
  rw [this]
  field_simp

/-- The removed fraction converges to the exponential profile `1 - e^{-u}`. -/
theorem peel_removed_fraction_tendsto {R : ℝ} (hR : 0 < R) (u : ℝ) :
    Tendsto (fun d : ℕ => (ballVol d R - ballVol d (R * (1 - u / d))) / ballVol d R)
      atTop (𝓝 (1 - Real.exp (-u))) := by
  have h := peel_volume_fraction_tendsto hR u
  have hconst : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
  refine (hconst.sub h).congr' ?_
  filter_upwards [eventually_gt_atTop 0] with d hd
  have hv1 : (0 : ℝ) < ballVol d 1 := ballVol_one_pos d
  have hvol2 : ballVol d R = R ^ d * ballVol d 1 := ballVol_eq d hd hR.le
  have hRd : (0 : ℝ) < R ^ d := pow_pos hR d
  have hpos : (0 : ℝ) < ballVol d R := by rw [hvol2]; positivity
  field_simp

/-! ## Feedback: the geometry proves an analytic inequality -/

/-- **A payoff of the sandwich.**  Since `d · thickness ∈ [R/N, R/(N-1)]` for
every dimension `d`, while `d · thickness → R log(N/(N-1))`, the geometry of
equal-volume shell peelings forces the classical logarithm sandwich
`1/N ≤ log(N/(N-1)) ≤ 1/(N-1)`. -/
theorem log_ratio_sandwich_of_shell (N : ℕ) (hN : 2 ≤ N) :
    1 / (N : ℝ) ≤ Real.log ((N : ℝ) / ((N : ℝ) - 1)) ∧
      Real.log ((N : ℝ) / ((N : ℝ) - 1)) ≤ 1 / ((N : ℝ) - 1) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  have hlim := shell_thickness_asymptotics N hN 1
  rw [one_mul] at hlim
  constructor
  · refine ge_of_tendsto hlim ?_
    filter_upwards [eventually_gt_atTop 0] with d hd
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have h' := shell_thickness_ge d N hd hN (zero_le_one (α := ℝ))
    have hkey : 1 / ((d : ℝ) * N) ≤ 1 - shellRadius 1 d N 1 := by
      have hN0 : (N : ℝ) ≠ 0 := ne_of_gt hNpos
      have hd0 : (d : ℝ) ≠ 0 := ne_of_gt hdpos
      have hNm : (-1 + (N : ℝ)) ≠ 0 := by intro h; linarith
      have hNm2 : ((N : ℝ) - 1) ≠ 0 := by intro h; linarith
      have hsimp : (1 : ℝ) / ((d : ℝ) * ((N : ℝ) - 1)) * (1 - 1 / (N : ℝ))
          = 1 / ((d : ℝ) * N) := by
        field_simp
      rw [hsimp] at h'
      exact h'
    have : 1 / (N : ℝ) ≤ (d : ℝ) * (1 - shellRadius 1 d N 1) := by
      have := mul_le_mul_of_nonneg_left hkey hdpos.le
      calc 1 / (N : ℝ) = (d : ℝ) * (1 / ((d : ℝ) * N)) := by field_simp
        _ ≤ (d : ℝ) * (1 - shellRadius 1 d N 1) := this
    exact this
  · refine le_of_tendsto hlim ?_
    filter_upwards [eventually_gt_atTop 0] with d hd
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have h := shell_thickness_le d N hd hN (zero_le_one (α := ℝ))
    have : (d : ℝ) * (1 - shellRadius 1 d N 1) ≤ 1 / ((N : ℝ) - 1) := by
      have hmul := mul_le_mul_of_nonneg_left h hdpos.le
      calc (d : ℝ) * (1 - shellRadius 1 d N 1)
          ≤ (d : ℝ) * (1 / ((d : ℝ) * ((N : ℝ) - 1))) := hmul
        _ = 1 / ((N : ℝ) - 1) := by field_simp
    exact this

end Catalog.Shared.ShellSharp