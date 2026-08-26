/-
# The prime-ratio law of generator tilt (continuous layer)

Companion to `Novelty.GeneratorTiltWindow`.  There the winner of the scan-order contest was
reduced to a single scalar, the mean tilt `z̄` of a pool of semiprimes inside the canonical
window `(√(N/2), √N]`.  Here we compute that scalar *from the generator*: for a semiprime
`N = p q` with ratio `r = q/p`, the tilt of the small factor is

`zOfRatio r = (r^{-1/2} - 2^{-1/2}) / (1 - 2^{-1/2})`,

a strictly decreasing map with `zOfRatio 1 = 1` and `zOfRatio 2 = 0`
(`tilt_eq_zOfRatio`, `zOfRatio_strictAntiOn`, `zOfRatio_one`, `zOfRatio_two`).

Consequences proved here:

* `zOfRatio_criticalRatio` / `half_lt_zOfRatio_iff` — the **critical ratio** at which the two
  scan orders tie is exactly `r★ = 24 - 16√2 ≈ 1.3726`, and a pool is top-heavy (so
  sqrt-descending wins, by `GeneratorTilt.descending_wins_iff_top_heavy`) iff its ratio is
  *below* `r★`.  Since `1 < r★ < 2` (`criticalRatio_mem_balance_band`), the sign of the
  effect flips strictly *inside* the balance band: enforcing `q < 2p` is not enough.
* `integral_zOfRatio` — the hard-balance control value: a ratio-uniform pool on `[1,2]` has
  mean tilt exactly `√2 - 1 = 0.41421…`, matching the analytic control `0.414` and the
  measured `0.4114 [0.3887, 0.4341]`; its tilt-only speedup is exactly `√2`
  (`predictor_at_uniform_balance`), against a measured `1.5896 ± 0.0538`.
* `zOfRatio_five_quarters_bracket` — a deployed-style pool with effective ratio `5/4` has
  tilt in `(0.63, 0.64)`, i.e. top-heavy, reproducing the measured `0.6356
  [0.6150, 0.6562]`; window-ascending then *loses*.

So the Λ-channel (window-ascending) advantage is confined to generator classes whose ratio
mass sits above `r★`, and it is *not* implied by balance.
-/
import Mathlib

namespace GeneratorTilt

open Real

/-- The tilt of the small factor of a semiprime of prime ratio `r = q/p`, i.e. its
normalised height in the canonical window `(√(N/2), √N]`. -/
noncomputable def zOfRatio (r : ℝ) : ℝ :=
  (1 / Real.sqrt r - 1 / Real.sqrt 2) / (1 - 1 / Real.sqrt 2)

/-- The tie point of the two scan orders, `24 - 16√2 ≈ 1.37258`. -/
noncomputable def criticalRatio : ℝ := 24 - 16 * Real.sqrt 2

/-! ## Numeric facts about `√2` -/

theorem sqrt_two_lb : (1.41421 : ℝ) < Real.sqrt 2 := by
  nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]

theorem sqrt_two_ub : Real.sqrt 2 < 1.41422 := by
  nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]

theorem sqrt_two_pos' : (0:ℝ) < Real.sqrt 2 := by linarith [sqrt_two_lb]

theorem sqrt_two_sq : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)

/-- The window is nondegenerate: `1 - 2^{-1/2} > 0`. -/
theorem one_sub_inv_sqrt_two_pos : 0 < 1 - 1 / Real.sqrt 2 := by
  have h := sqrt_two_lb
  rw [sub_pos, div_lt_one sqrt_two_pos']
  linarith

theorem one_sub_inv_sqrt_two_ne : (1 : ℝ) - 1 / Real.sqrt 2 ≠ 0 :=
  ne_of_gt one_sub_inv_sqrt_two_pos

/-! ## Values and monotonicity -/

@[simp] theorem zOfRatio_one : zOfRatio 1 = 1 := by
  unfold zOfRatio
  rw [Real.sqrt_one]
  have hne : Real.sqrt 2 - 1 ≠ 0 := by nlinarith [sqrt_two_lb]
  field_simp

@[simp] theorem zOfRatio_two : zOfRatio 2 = 0 := by
  unfold zOfRatio
  simp

/-- The tilt is a strictly decreasing function of the prime ratio: the more balanced the
key, the *higher* its small factor sits inside the window. -/
theorem zOfRatio_strictAntiOn : StrictAntiOn zOfRatio (Set.Ioi (0:ℝ)) := by
  intro x hx y _ hxy
  have hx0 : (0:ℝ) < x := hx
  have hsx : 0 < Real.sqrt x := Real.sqrt_pos.mpr hx0
  have hlt : Real.sqrt x < Real.sqrt y := Real.sqrt_lt_sqrt hx0.le hxy
  have hinv : 1 / Real.sqrt y < 1 / Real.sqrt x := one_div_lt_one_div_of_lt hsx hlt
  unfold zOfRatio
  rw [div_lt_div_iff₀ one_sub_inv_sqrt_two_pos one_sub_inv_sqrt_two_pos]
  nlinarith [one_sub_inv_sqrt_two_pos]

/-! ## The bridge: geometric tilt equals the ratio law -/

/-- **Bridge theorem.**  For real `p, q > 0` the normalised height of `p` inside the window
`(√(pq/2), √(pq)]` depends on `p` and `q` only through the ratio `q/p`, and equals
`zOfRatio (q/p)`.  This is what makes the tilt a property of the *generator* rather than of
the individual key. -/
theorem tilt_eq_zOfRatio {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    (p - Real.sqrt (p * q / 2)) / (Real.sqrt (p * q) - Real.sqrt (p * q / 2))
      = zOfRatio (q / p) := by
  unfold zOfRatio
  obtain ⟨u, hu0, rfl⟩ : ∃ u, 0 < u ∧ p = u * u :=
    ⟨Real.sqrt p, Real.sqrt_pos.mpr hp, (Real.mul_self_sqrt hp.le).symm⟩
  obtain ⟨v, hv0, rfl⟩ : ∃ v, 0 < v ∧ q = v * v :=
    ⟨Real.sqrt q, Real.sqrt_pos.mpr hq, (Real.mul_self_sqrt hq.le).symm⟩
  have h1 : Real.sqrt (u * u * (v * v)) = u * v := by
    rw [show u * u * (v * v) = (u * v) * (u * v) by ring, Real.sqrt_mul_self (by positivity)]
  have h2 : Real.sqrt (u * u * (v * v) / 2) = u * v / Real.sqrt 2 := by
    rw [Real.sqrt_div (by positivity) 2, h1]
  have h3 : Real.sqrt (v * v / (u * u)) = v / u := by
    rw [Real.sqrt_div (by positivity) (u * u), Real.sqrt_mul_self hv0.le,
      Real.sqrt_mul_self hu0.le]
  rw [h1, h2, h3]
  have hw1 : (1:ℝ) < Real.sqrt 2 := by linarith [sqrt_two_lb]
  have hw0 : (0:ℝ) < Real.sqrt 2 := sqrt_two_pos'
  have huv : 0 < u * v := mul_pos hu0 hv0
  have hd1 : u * v - u * v / Real.sqrt 2 ≠ 0 := by
    have : u * v / Real.sqrt 2 < u * v := by
      rw [div_lt_iff₀ hw0]; nlinarith
    nlinarith
  have hd2 : (1:ℝ) - 1 / Real.sqrt 2 ≠ 0 := one_sub_inv_sqrt_two_ne
  field_simp

/-! ## The critical ratio -/

theorem sqrt_criticalRatio : Real.sqrt criticalRatio = 4 - 2 * Real.sqrt 2 := by
  unfold criticalRatio
  rw [show (24:ℝ) - 16 * Real.sqrt 2 = (4 - 2 * Real.sqrt 2) ^ 2 by
        have := sqrt_two_sq; nlinarith]
  exact Real.sqrt_sq (by nlinarith [sqrt_two_ub])

theorem criticalRatio_pos : 0 < criticalRatio := by
  unfold criticalRatio; nlinarith [sqrt_two_ub]

/-- The tie point really is a tie: the tilt at `r★ = 24 - 16√2` is exactly `1/2`. -/
theorem zOfRatio_criticalRatio : zOfRatio criticalRatio = 1 / 2 := by
  unfold zOfRatio
  rw [sqrt_criticalRatio]
  have h2 := sqrt_two_sq
  have hw0 : (0:ℝ) < Real.sqrt 2 := sqrt_two_pos'
  have hne : (4:ℝ) - 2 * Real.sqrt 2 ≠ 0 := by nlinarith [sqrt_two_ub]
  have hne1 : Real.sqrt 2 - 1 ≠ 0 := by nlinarith [sqrt_two_lb]
  have hd2 : (1:ℝ) - 1 / Real.sqrt 2 ≠ 0 := one_sub_inv_sqrt_two_ne
  field_simp
  nlinarith [h2, hw0]

/-- **The critical ratio lies strictly inside the balance band.**  Enforcing `q < 2p` (the
band `r ∈ [1,2]`) does *not* determine the winner: the sign of the scan-order effect flips
at `r★ ≈ 1.3726`, strictly between `1` and `2`. -/
theorem criticalRatio_mem_balance_band : 1 < criticalRatio ∧ criticalRatio < 2 := by
  constructor
  · unfold criticalRatio; nlinarith [sqrt_two_ub]
  · unfold criticalRatio; nlinarith [sqrt_two_lb]

/-- **Scope theorem.**  A population with prime ratio `r > 0` is top-heavy — equivalently, by
`GeneratorTilt.descending_wins_iff_top_heavy`, sqrt-descending beats window-ascending —
exactly when `r` is below the critical ratio `24 - 16√2`. -/
theorem half_lt_zOfRatio_iff {r : ℝ} (hr : 0 < r) : 1 / 2 < zOfRatio r ↔ r < criticalRatio := by
  rw [← zOfRatio_criticalRatio]
  exact StrictAntiOn.lt_iff_gt zOfRatio_strictAntiOn (Set.mem_Ioi.mpr criticalRatio_pos)
    (Set.mem_Ioi.mpr hr)

/-! ## The two measured pools -/

/-- Closed form of the tilt at ratio `5/4`. -/
theorem zOfRatio_five_quarters :
    zOfRatio (5/4) =
      (2 * Real.sqrt 2 - Real.sqrt 5) / (Real.sqrt 5 * (Real.sqrt 2 - 1)) := by
  have h5 : Real.sqrt (5/4) = Real.sqrt 5 / 2 := by
    rw [Real.sqrt_div (by norm_num) 4, show (4:ℝ) = 2 ^ 2 by norm_num,
      Real.sqrt_sq (by norm_num)]
  have hs5 : (0:ℝ) < Real.sqrt 5 := Real.sqrt_pos.mpr (by norm_num)
  have hw0 : (0:ℝ) < Real.sqrt 2 := sqrt_two_pos'
  have hw1 : (1:ℝ) < Real.sqrt 2 := by linarith [sqrt_two_lb]
  have hd2 : (1:ℝ) - 1 / Real.sqrt 2 ≠ 0 := one_sub_inv_sqrt_two_ne
  unfold zOfRatio
  rw [h5]
  have hne : Real.sqrt 2 - 1 ≠ 0 := by linarith
  field_simp

theorem sqrt_five_lb : (2.23606 : ℝ) < Real.sqrt 5 := by
  nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 5), Real.sqrt_nonneg 5]

theorem sqrt_five_ub : Real.sqrt 5 < 2.23607 := by
  nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 5), Real.sqrt_nonneg 5]

/-- **The measured RSA-style pool is top-heavy.**  At the effective median ratio `r = 5/4`
the tilt lies in `(0.63, 0.64)`, bracketing the measured `0.6356 [0.6150, 0.6562]`.  In
particular it exceeds `1/2`, so window-ascending *loses* on such a pool. -/
theorem zOfRatio_five_quarters_bracket : 0.63 < zOfRatio (5/4) ∧ zOfRatio (5/4) < 0.64 := by
  rw [zOfRatio_five_quarters]
  have h2l := sqrt_two_lb
  have h2u := sqrt_two_ub
  have h5l := sqrt_five_lb
  have h5u := sqrt_five_ub
  have hden : 0 < Real.sqrt 5 * (Real.sqrt 2 - 1) := by nlinarith
  constructor
  · rw [lt_div_iff₀ hden]; nlinarith
  · rw [div_lt_iff₀ hden]; nlinarith

/-- Corollary of the scope theorem: `5/4` is below the critical ratio. -/
theorem five_quarters_lt_criticalRatio : (5/4 : ℝ) < criticalRatio :=
  (half_lt_zOfRatio_iff (by norm_num)).mp (by linarith [zOfRatio_five_quarters_bracket.1])

/-! ## The hard-balance control: exact mean tilt `√2 - 1` -/

theorem integral_one_div_sqrt : ∫ r in (1:ℝ)..2, 1 / Real.sqrt r = 2 * Real.sqrt 2 - 2 := by
  have h : ∀ r ∈ Set.uIcc (1:ℝ) 2, 1 / Real.sqrt r = r ^ (-(1:ℝ)/2) := by
    intro r hr
    rw [Set.uIcc_of_le (by norm_num)] at hr
    have hr0 : (0:ℝ) ≤ r := le_trans (by norm_num) hr.1
    rw [show -(1:ℝ)/2 = -(1/2) by ring, Real.rpow_neg hr0, ← Real.sqrt_eq_rpow, one_div]
  rw [intervalIntegral.integral_congr h, integral_rpow (by left; norm_num),
    show -(1:ℝ)/2 + 1 = 1/2 by ring, ← Real.sqrt_eq_rpow, ← Real.sqrt_eq_rpow, Real.sqrt_one]
  ring

theorem intervalIntegrable_one_div_sqrt :
    IntervalIntegrable (fun r : ℝ => 1 / Real.sqrt r) MeasureTheory.volume 1 2 := by
  apply ContinuousOn.intervalIntegrable
  apply ContinuousOn.div continuousOn_const Real.continuous_sqrt.continuousOn
  intro x hx
  rw [Set.uIcc_of_le (by norm_num)] at hx
  exact ne_of_gt (Real.sqrt_pos.mpr (by linarith [hx.1]))

/-- **Hard-balance control value.**  A pool whose prime ratio is uniform on the balance band
`[1,2]` has mean tilt exactly `√2 - 1 = 0.41421…`.  This is the analytic control `0.414`
against which the simulation's `HARD_BAL` reading `0.4114 [0.3887, 0.4341]` was checked. -/
theorem integral_zOfRatio : (∫ r in (1:ℝ)..2, zOfRatio r) = Real.sqrt 2 - 1 := by
  have hw0 : (0:ℝ) < Real.sqrt 2 := sqrt_two_pos'
  have hd2 : (1:ℝ) - 1 / Real.sqrt 2 ≠ 0 := one_sub_inv_sqrt_two_ne
  have hfun : ∀ r ∈ Set.uIcc (1:ℝ) 2, zOfRatio r
      = (1 - 1 / Real.sqrt 2)⁻¹ * (1 / Real.sqrt r)
        - (1 / Real.sqrt 2) / (1 - 1 / Real.sqrt 2) := by
    intro r _
    unfold zOfRatio
    field_simp
  rw [intervalIntegral.integral_congr hfun,
    intervalIntegral.integral_sub (intervalIntegrable_one_div_sqrt.const_mul _)
      intervalIntegrable_const,
    intervalIntegral.integral_const_mul, integral_one_div_sqrt, intervalIntegral.integral_const]
  have h2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sqrt_two_sq
  have hne1 : Real.sqrt 2 - 1 ≠ 0 := by nlinarith [sqrt_two_lb]
  simp only [smul_eq_mul]
  field_simp
  nlinarith [h2, hw0]

/-- The hard-balance control pool is **bottom-heavy**: `√2 - 1 < 1/2`.  By
`GeneratorTilt.descending_wins_iff_top_heavy` this is exactly the regime where the
window-ascending (Λ) order wins — and it is an *enforced-balance* regime. -/
theorem uniform_balance_bottom_heavy : Real.sqrt 2 - 1 < 1 / 2 := by
  linarith [sqrt_two_ub]

/-- At the hard-balance control tilt `z̄ = √2 - 1` the tilt-only speedup predictor
`(1 - z̄)/z̄` is exactly `√2 ≈ 1.4142`; the simulation measured `1.5896 ± 0.0538`. -/
theorem predictor_at_uniform_balance :
    (1 - (Real.sqrt 2 - 1)) / (Real.sqrt 2 - 1) = Real.sqrt 2 := by
  have h2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sqrt_two_sq
  have hne : Real.sqrt 2 - 1 ≠ 0 := by nlinarith [sqrt_two_lb]
  field_simp
  nlinarith [h2]

/-! ## Synthesis: the scope boundary -/

/-- **Scope boundary, both signs.**  Within the enforced-balance band `r ∈ (1,2)` the
window-ascending order wins for ratios above `r★ = 24 - 16√2` and loses for ratios below it.
Hence "balanced generator" is *not* a sufficient condition for a Λ-channel gain: the
deployed-style ratio concentration near `1` sits on the losing side. -/
theorem scan_order_scope_boundary {r : ℝ} (hr : 0 < r) :
    (r < criticalRatio → 1 / 2 < zOfRatio r) ∧
    (criticalRatio < r → zOfRatio r < 1 / 2) := by
  refine ⟨fun h => (half_lt_zOfRatio_iff hr).mpr h, fun h => ?_⟩
  have := zOfRatio_strictAntiOn (Set.mem_Ioi.mpr criticalRatio_pos) (Set.mem_Ioi.mpr hr) h
  rw [zOfRatio_criticalRatio] at this
  exact this

end GeneratorTilt