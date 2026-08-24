/-
# Cycle 5: quantitative rates, and the concentration dichotomy

Cycles 3–4 established, for the equal-volume peeling of `B(0,R) ⊆ ℝ^d` into `N`
shells, that the rescaled outer-shell thickness `d · (R - shellRadius R d N 1)`
increases in `d` to the optimal constant `R Λ`, `Λ = log(N/(N-1))`.  A limit
without a rate is a qualitative statement; this file supplies the rate, and
then exhibits the dichotomy that makes the whole picture geometric.

1. **Two-sided exponential estimate.**  `mul_one_sub_rpow_inv_le_neg_log` and
   `neg_log_sub_mul_one_sub_rpow_inv_le` bound `d(1 - x^{1/d})` between
   `-log x - (log x)²/(d - log x)` and `-log x`, using only `1 + u ≤ e^u` at
   `u = ±log x/d`.  The second is a rate of convergence for cycle 3's limit,
   with the exact `Θ(1/d)` shape.

2. **Geometric rate.**  `shell_thickness_rate`:
   `0 ≤ R Λ - d · thickness ≤ R Λ²/(d + Λ)`.
   Combined with `shell_thickness_le_log` this pins the thickness to
   `R Λ/d · (1 + O(1/d))`, a strictly stronger statement than the interval
   `[R/(dN), R/(d(N-1))]` of cycle 3 as soon as `d` is large.

3. **The dichotomy.**  `outer_shell_thickness_tendsto_zero` : the outermost
   shell, carrying `1/N` of the volume, has thickness `→ 0`;
   `innermost_shell_radius_tendsto` : the innermost shell, carrying the same
   `1/N` of the volume, is the complement of a ball of radius `R N^{-1/d} → R`,
   so its thickness tends to the *whole* radius `R`.
   `shell_concentration_dichotomy` states the two together: in high dimension
   an equal-volume peeling consists of `N-1` infinitesimally thin skins near
   the boundary sphere and one ball of almost full radius.

## Lab notes

`R = 1`, `N = 2`, `Λ = log 2 = 0.693147`.  Rate bound `Λ²/(d+Λ)`:
`d = 10 → 0.04496`, actual gap `Λ - d·thickness = 0.693147 - 0.669670 =
0.023477`;  `d = 100 → 0.004774`, actual `0.693147 - 0.690750 = 0.002397`.
The bound is within a factor `2` of the truth (the true constant is `Λ²/2d`),
and correctly of order `1/d`.
Dichotomy at `N = 2`: outer thickness `1 - 2^{-1/d} → 0`; innermost radius
`2^{-1/d} → 1`, e.g. `0.933` at `d = 10` and `0.993` at `d = 100`.
-/
import Mathlib
import Shared.ShellThicknessMonotone

namespace Catalog.Shared.ShellSharp

open Finset Filter Topology Catalog.Geometry.Peel

/-! ## Two-sided estimate with an explicit rate -/

/-- `d (1 - x^{1/d}) ≤ -log x` for `0 < x ≤ 1`: the rescaled deficit never
exceeds its limit.  Direct consequence of `1 + u ≤ e^u`. -/
lemma mul_one_sub_rpow_inv_le_neg_log {x : ℝ} (hx : 0 < x) (hx1 : x ≤ 1) (d : ℕ) :
    (d : ℝ) * (1 - x ^ ((d : ℝ)⁻¹)) ≤ -Real.log x := by
  rcases Nat.eq_zero_or_pos d with hd | hd
  · subst hd
    simpa using Real.log_nonpos hx.le hx1
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hu : x ^ ((d : ℝ)⁻¹) = Real.exp (Real.log x / d) := by
    rw [Real.rpow_def_of_pos hx, ← div_eq_mul_inv]
  have h1 : (1 : ℝ) + Real.log x / d ≤ Real.exp (Real.log x / d) := by
    have := Real.add_one_le_exp (Real.log x / (d : ℝ)); linarith
  rw [hu]
  have h2 : 1 - Real.exp (Real.log x / (d : ℝ)) ≤ -(Real.log x / d) := by linarith
  calc (d : ℝ) * (1 - Real.exp (Real.log x / d))
      ≤ (d : ℝ) * (-(Real.log x / d)) := mul_le_mul_of_nonneg_left h2 hdpos.le
    _ = -Real.log x := by field_simp

/-- **Rate of convergence.**  For `0 < x ≤ 1` and `d ≥ 1`,
`-log x - d(1 - x^{1/d}) ≤ (log x)²/(d - log x)`: the limit of cycle 3 is
approached at speed `Θ(1/d)`, with an explicit constant. -/
lemma neg_log_sub_mul_one_sub_rpow_inv_le {x : ℝ} (hx : 0 < x) (hx1 : x ≤ 1) {d : ℕ}
    (hd : 0 < d) :
    -Real.log x - (d : ℝ) * (1 - x ^ ((d : ℝ)⁻¹))
      ≤ (Real.log x) ^ 2 / ((d : ℝ) - Real.log x) := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set L : ℝ := Real.log x with hL
  have hLle : L ≤ 0 := Real.log_nonpos hx.le hx1
  have hden : (0 : ℝ) < (d : ℝ) - L := by linarith
  have hu : x ^ ((d : ℝ)⁻¹) = Real.exp (L / d) := by
    rw [Real.rpow_def_of_pos hx, ← hL, ← div_eq_mul_inv]
  have hpos : (0 : ℝ) < 1 - L / d := by
    have : L / (d : ℝ) ≤ 0 := div_nonpos_of_nonpos_of_nonneg hLle hdpos.le
    linarith
  -- `e^{L/d} ≤ 1/(1 - L/d)`
  have hle : Real.exp (L / (d : ℝ)) ≤ 1 / (1 - L / (d : ℝ)) := by
    have h1 : (1 : ℝ) - L / d ≤ Real.exp (-(L / d)) := by
      have := Real.add_one_le_exp (-(L / (d : ℝ))); linarith
    rw [le_div_iff₀ hpos]
    calc Real.exp (L / (d : ℝ)) * (1 - L / d)
        ≤ Real.exp (L / (d : ℝ)) * Real.exp (-(L / d)) :=
          mul_le_mul_of_nonneg_left h1 (Real.exp_pos _).le
      _ = 1 := by rw [← Real.exp_add]; simp
  have hlow : -L * ((d : ℝ) / ((d : ℝ) - L)) ≤ (d : ℝ) * (1 - Real.exp (L / d)) := by
    have h2 : 1 - 1 / (1 - L / (d : ℝ)) ≤ 1 - Real.exp (L / d) := by linarith
    have h3 : -L * ((d : ℝ) / ((d : ℝ) - L)) = (d : ℝ) * (1 - 1 / (1 - L / (d : ℝ))) := by
      field_simp
      ring
    rw [h3]
    exact mul_le_mul_of_nonneg_left h2 hdpos.le
  have hgap : -L - (-L * ((d : ℝ) / ((d : ℝ) - L))) = L ^ 2 / ((d : ℝ) - L) := by
    field_simp
    ring
  rw [hu]
  linarith [hlow, hgap.ge, hgap.le]

/-! ## The geometric rate -/

/-- **Quantitative boundary concentration.**  With `Λ = log(N/(N-1))`, the
outer shell thickness of the equal-volume peeling satisfies
`0 ≤ R Λ - d · thickness ≤ R Λ²/(d + Λ)`, i.e.
`thickness = R Λ/d · (1 + O(1/d))`. -/
theorem shell_thickness_rate (d N : ℕ) (hd : 0 < d) (hN : 2 ≤ N) {R : ℝ} (hR : 0 ≤ R) :
    0 ≤ R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) - (d : ℝ) * (R - shellRadius R d N 1) ∧
      R * Real.log ((N : ℝ) / ((N : ℝ) - 1)) - (d : ℝ) * (R - shellRadius R d N 1)
        ≤ R * (Real.log ((N : ℝ) / ((N : ℝ) - 1))) ^ 2
            / ((d : ℝ) + Real.log ((N : ℝ) / ((N : ℝ) - 1))) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  have hN1 : (0 : ℝ) < (N : ℝ) - 1 := by linarith
  set t : ℝ := 1 - 1 / (N : ℝ) with ht
  have ht0 : 0 < t := by rw [ht, sub_pos, div_lt_one hNpos]; linarith
  have ht1 : t ≤ 1 := by
    have : 0 < 1 / (N : ℝ) := by positivity
    rw [ht]; linarith
  have hteq : t = ((N : ℝ) - 1) / N := by rw [ht]; field_simp
  have hlog : Real.log t = -Real.log ((N : ℝ) / ((N : ℝ) - 1)) := by
    rw [hteq, ← Real.log_inv]
    congr 1
    rw [inv_div]
  set L : ℝ := Real.log ((N : ℝ) / ((N : ℝ) - 1)) with hLdef
  have hrw : (d : ℝ) * (R - shellRadius R d N 1)
      = R * ((d : ℝ) * (1 - t ^ ((d : ℝ)⁻¹))) := by
    rw [shellRadius_one_eq (R := R) (d := d) hN, ← ht]; ring
  have hupper := mul_one_sub_rpow_inv_le_neg_log ht0 ht1 d
  have hrate := neg_log_sub_mul_one_sub_rpow_inv_le ht0 ht1 hd
  rw [hlog] at hupper hrate
  simp only [neg_neg] at hupper hrate
  constructor
  · rw [hrw]
    nlinarith [mul_le_mul_of_nonneg_left hupper hR]
  · have hL0 : 0 ≤ L := by
      rw [hLdef]
      refine Real.log_nonneg ?_
      rw [le_div_iff₀ hN1]; linarith
    have hden : (0 : ℝ) < (d : ℝ) + L := by
      have : (0 : ℝ) < d := by exact_mod_cast hd
      linarith
    have hsq : (-L) ^ 2 = L ^ 2 := by ring
    rw [hsq] at hrate
    have hden' : (d : ℝ) - -L = (d : ℝ) + L := by ring
    rw [hden'] at hrate
    have := mul_le_mul_of_nonneg_left hrate hR
    rw [hrw]
    calc R * L - R * ((d : ℝ) * (1 - t ^ ((d : ℝ)⁻¹)))
        = R * (L - (d : ℝ) * (1 - t ^ ((d : ℝ)⁻¹))) := by ring
      _ ≤ R * (L ^ 2 / ((d : ℝ) + L)) := this
      _ = R * L ^ 2 / ((d : ℝ) + L) := by ring

/-! ## The dichotomy -/

/-- The outermost equal-volume shell becomes infinitely thin. -/
theorem outer_shell_thickness_tendsto_zero (N : ℕ) (hN : 2 ≤ N) (R : ℝ) :
    Tendsto (fun d : ℕ => R - shellRadius R d N 1) atTop (𝓝 0) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  set t : ℝ := 1 - 1 / (N : ℝ) with ht
  have ht0 : 0 < t := by rw [ht, sub_pos, div_lt_one hNpos]; linarith
  have hlim : Tendsto (fun d : ℕ => t ^ ((d : ℝ)⁻¹)) atTop (𝓝 1) := by
    have hlog : Tendsto (fun d : ℕ => Real.log t / (d : ℝ)) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    have hexp : Tendsto (fun d : ℕ => Real.exp (Real.log t / (d : ℝ))) atTop (𝓝 1) := by
      have h := (Real.continuous_exp.tendsto 0).comp hlog
      simpa [Function.comp_def] using h
    refine hexp.congr ?_
    intro d
    rw [Real.rpow_def_of_pos ht0, ← div_eq_mul_inv]
  have : Tendsto (fun d : ℕ => R - R * t ^ ((d : ℝ)⁻¹)) atTop (𝓝 (R - R * 1)) :=
    tendsto_const_nhds.sub (tendsto_const_nhds.mul hlim)
  rw [mul_one, sub_self] at this
  refine this.congr ?_
  intro d
  rw [shellRadius_one_eq (R := R) (d := d) hN, ← ht]

/-- The innermost equal-volume shell fills the ball: the sphere bounding it has
radius `R N^{-1/d} → R`, so that shell — carrying the same `1/N` of the volume
as the outermost one — has thickness tending to the full radius `R`. -/
theorem innermost_shell_radius_tendsto (N : ℕ) (hN : 2 ≤ N) (R : ℝ) :
    Tendsto (fun d : ℕ => shellRadius R d N (N - 1)) atTop (𝓝 R) := by
  have hNR : (2 : ℝ) ≤ N := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < N := by linarith
  have hcast : ((N - 1 : ℕ) : ℝ) = (N : ℝ) - 1 := by
    have h1 : 1 ≤ N := by omega
    push_cast [Nat.cast_sub h1]
    ring
  have hval : (1 : ℝ) - ((N - 1 : ℕ) : ℝ) / N = 1 / N := by
    rw [hcast]; field_simp; ring
  have hpos : (0 : ℝ) < 1 / (N : ℝ) := by positivity
  have hlim : Tendsto (fun d : ℕ => (1 / (N : ℝ)) ^ ((d : ℝ)⁻¹)) atTop (𝓝 1) := by
    have hlog : Tendsto (fun d : ℕ => Real.log (1 / (N : ℝ)) / (d : ℝ)) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    have hexp : Tendsto (fun d : ℕ => Real.exp (Real.log (1 / (N : ℝ)) / (d : ℝ))) atTop
        (𝓝 1) := by
      have h := (Real.continuous_exp.tendsto 0).comp hlog
      simpa [Function.comp_def] using h
    refine hexp.congr ?_
    intro d
    rw [Real.rpow_def_of_pos hpos, ← div_eq_mul_inv]
  have hmul : Tendsto (fun d : ℕ => R * (1 / (N : ℝ)) ^ ((d : ℝ)⁻¹)) atTop (𝓝 (R * 1)) :=
    tendsto_const_nhds.mul hlim
  rw [mul_one] at hmul
  refine hmul.congr ?_
  intro d
  rw [shellRadius, max_eq_right (by rw [hval]; positivity), hval]

/-- **The concentration dichotomy.**  In high dimension an equal-volume peeling
of a ball degenerates: the outermost shell (volume fraction `1/N`) collapses to
the boundary sphere, while the innermost shell (the same volume fraction `1/N`)
swells to fill the whole ball. -/
theorem shell_concentration_dichotomy (N : ℕ) (hN : 2 ≤ N) (R : ℝ) :
    Tendsto (fun d : ℕ => R - shellRadius R d N 1) atTop (𝓝 0) ∧
      Tendsto (fun d : ℕ => shellRadius R d N (N - 1)) atTop (𝓝 R) :=
  ⟨outer_shell_thickness_tendsto_zero N hN R, innermost_shell_radius_tendsto N hN R⟩

/-! ## The limiting profile of the whole decomposition -/

/-- **The limit profile.**  For every `k < N` the rescaled depth of the `k`-th
sphere converges: `d · (R - shellRadius R d N k) → R log(N/(N-k))`.  The limit
profile `k ↦ R log(N/(N-k))` is exactly the inverse of the exponential profile
(see `volume_fraction_of_limit_depth`). -/
theorem shell_depth_asymptotics (N k : ℕ) (hk : k < N) (R : ℝ) :
    Tendsto (fun d : ℕ => (d : ℝ) * (R - shellRadius R d N k)) atTop
      (𝓝 (R * Real.log ((N : ℝ) / ((N : ℝ) - k)))) := by
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
    exact_mod_cast this
  have hkN : (k : ℝ) < N := by exact_mod_cast hk
  set t : ℝ := 1 - (k : ℝ) / N with ht
  have ht0 : 0 < t := by rw [ht, sub_pos, div_lt_one hNpos]; exact hkN
  have ht1 : t ≤ 1 := by
    have : 0 ≤ (k : ℝ) / N := by positivity
    rw [ht]; linarith
  have hteq : t = ((N : ℝ) - k) / N := by rw [ht]; field_simp
  have hlog : -Real.log t = Real.log ((N : ℝ) / ((N : ℝ) - k)) := by
    rw [hteq, ← Real.log_inv]
    congr 1
    rw [inv_div]
  have hbase := (tendsto_mul_one_sub_rpow_inv ht0 ht1).const_mul R
  rw [hlog] at hbase
  refine hbase.congr ?_
  intro d
  have hrad : shellRadius R d N k = R * t ^ ((d : ℝ)⁻¹) := by
    rw [shellRadius, ← ht, max_eq_right ht0.le]
  rw [hrad]; ring

/-- **Closing the loop with the exponential profile.**  The limiting rescaled
depth `t = log(N/(N-k))` of the `k`-th sphere and its volume fraction `k/N`
are related by `k/N = 1 - e^{-t}`: after rescaling by the dimension, the
equal-volume shell decomposition is the exponential profile `R(1 - e^{-t})`. -/
theorem volume_fraction_of_limit_depth (N k : ℕ) (hk : k < N) :
    1 - Real.exp (-Real.log ((N : ℝ) / ((N : ℝ) - k))) = (k : ℝ) / N := by
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
    exact_mod_cast this
  have hkN : (k : ℝ) < N := by exact_mod_cast hk
  have hpos : (0 : ℝ) < (N : ℝ) / ((N : ℝ) - k) := by
    have : (0 : ℝ) < (N : ℝ) - k := by linarith
    positivity
  have hNk : (0 : ℝ) < (N : ℝ) - k := by linarith
  have hinv : ((N : ℝ) / ((N : ℝ) - k))⁻¹ = ((N : ℝ) - k) / N := inv_div _ _
  rw [← Real.log_inv, hinv, Real.exp_log (by positivity)]
  field_simp
  ring

/-- The boundary-layer form of the exponential profile, stated directly with
Euclidean balls: the fraction of `B(0,R) ⊆ ℝ^d` left after removing the
boundary layer of thickness `R u/d` tends to `e^{-u}`. -/
theorem ball_boundary_layer_fraction_tendsto {R : ℝ} (hR : 0 < R) (u : ℝ) :
    Tendsto (fun d : ℕ =>
        (MeasureTheory.volume
            (Metric.ball (0 : EuclideanSpace ℝ (Fin d)) (R * (1 - u / d)))).toReal /
          (MeasureTheory.volume (Metric.ball (0 : EuclideanSpace ℝ (Fin d)) R)).toReal)
      atTop (𝓝 (Real.exp (-u))) :=
  peel_volume_fraction_tendsto hR u

end Catalog.Shared.ShellSharp