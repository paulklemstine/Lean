import Mathlib
import Applications.TDialU80FloorResolution

/-!
# Why rapidity, and what the bitlen-84 crossing test will cost

## Research context (FACT round-66 #1, exp 534 — second cycle)

`Applications.TDialU80FloorResolution` scored the U80 record in rapidity coordinates: it
proved the width law, the asymmetry law, the resolution law
`n ≥ 3 + (z/(artanh r - artanh f))²`, and the bitlen-84 crossing prediction.  Two
objections survive that cycle, and this file answers them.

1. **Why rapidity?**  Every quantitative claim of the first cycle is made in the
   coordinate `artanh`.  A critic may reasonably ask whether the conclusions are an
   artefact of that choice.  Section 1 shows they are not: `artanh` is the *unique*
   coordinate — up to an affine change — in which a confidence interval has a
   reading-independent half-width.  Any other coordinate makes the half-width depend on
   the very quantity being measured.

2. **What will the crossing test cost?**  The record calls bitlen 84 "the crossing test".
   Section 3 prices it: certifying that the predicted bitlen-84 reading lies *below* the
   floor needs at least `74000` paired draws, more than twenty times the `≤ 3650` the U80
   cell carries.  Run at the current budget, the crossing test cannot be decisive whatever
   it returns.

## Main results

* `hasDerivAt_artanh` — `artanh' x = 1/(1-x²)` on `(-1,1)`.
* `stabilizer_unique` — **canonicity of rapidity**: if `g' (x) = c/(1-x²)` on `(-1,1)`
  (the variance-stabilisation ODE produced by the delta method from the asymptotic
  variance `(1-ρ²)²/n` of a sample correlation), then `g = c·artanh + g 0`.
* `stabilizer_iff_affine_artanh` — the two-way form: the solutions of that ODE are exactly
  the affine images of `artanh`.
* `ceiling_certified_iff` — the mirror of the first cycle's `floor_certified_iff`: an
  interval sits strictly below a ceiling `f` iff `t ≤ d(f,r)`.  Certifying a *drop* costs
  the same rapidity margin as certifying a *clearance*.
* `reqSamples_scaling` — the **quadratic cost law** `cost(M/k) = k²·cost(M)` exactly, and
  `reqSamples_strict_anti`: cost is strictly decreasing in the margin.
* `u84_crossing_test_cost` — the bitlen-84 crossing test needs `≥ 74000` draws at the
  conservative end (`0.545`) of the predicted window, and `≥ 38000` at the optimistic end
  (`0.543`); `u84_test_infeasible_at_current_budget` compares this with the U80 budget.
* `ladder_linear_decay`, `ladder_crosses_of_uniform_step` — a rapidity ladder that fades by
  at least `δ` per rung is below any level `L` after `⌈(w₀-L)/δ⌉` rungs (induction on the
  rung index).
* `u80_one_more_rung_crosses` — quantitatively: **one further 8-bitlen rung at the observed
  fade rate already puts the dial below the floor**, which is the same conclusion the
  continuous extrapolation of cycle 1 reached (`crossing ∈ (82,83)`), obtained here without
  any continuity assumption on the bitlen.

The arithmetic core is again rational: `u80_one_more_rung_crosses` is exactly
`(313/87)² < (31/9)·(321/79)`.
-/

open Real Set

namespace Catalog.Applications.TDialU80RapidityCanonicity

open Catalog.Applications.TDialU80FloorResolution

/-! ## 1. Rapidity is the unique variance-stabilising coordinate -/

/-- The derivative of `artanh` on `(-1,1)`. -/
lemma hasDerivAt_artanh {x : ℝ} (hx : x ∈ Ioo (-1:ℝ) 1) :
    HasDerivAt artanh (1 / (1 - x ^ 2)) x := by
  have hp : (0:ℝ) < 1 + x := by linarith [hx.1]
  have hn : (0:ℝ) < 1 - x := by linarith [hx.2]
  have d1 : HasDerivAt (fun s : ℝ => Real.log (1 + s)) (1 / (1 + x)) x := by
    have h := (Real.hasDerivAt_log hp.ne').comp x ((hasDerivAt_id x).const_add 1)
    simpa [one_div] using h
  have d2 : HasDerivAt (fun s : ℝ => Real.log (1 - s)) (-(1 / (1 - x))) x := by
    have h := (Real.hasDerivAt_log hn.ne').comp x ((hasDerivAt_id x).const_sub 1)
    simpa [one_div, mul_comm] using h
  have hne : (1:ℝ) - x ^ 2 ≠ 0 := by nlinarith
  have key : HasDerivAt (fun s : ℝ => (Real.log (1 + s) - Real.log (1 - s)) / 2)
      (1 / (1 - x ^ 2)) x := by
    have h := (d1.sub d2).div_const 2
    have heq : (1 / (1 + x) - -(1 / (1 - x))) / 2 = 1 / (1 - x ^ 2) := by
      rw [div_eq_div_iff (by norm_num) hne]; field_simp; ring
    rwa [heq] at h
  apply key.congr_of_eventuallyEq
  filter_upwards [isOpen_Ioo.mem_nhds hx] with y hy
  exact artanh_eq_half_log hy.1 hy.2

/-- **Canonicity of rapidity.**  The delta method turns the asymptotic variance
`(1-ρ²)²/n` of a sample correlation into the variance-stabilisation ODE
`g'(x)·(1-x²) = c`.  Every solution is `c·artanh` up to an additive constant: rapidity is
the only coordinate in which an interval has a reading-independent half-width. -/
theorem stabilizer_unique {g : ℝ → ℝ} {c : ℝ}
    (hg : ∀ x ∈ Ioo (-1:ℝ) 1, HasDerivAt g (c / (1 - x ^ 2)) x) {x : ℝ}
    (hx : x ∈ Ioo (-1:ℝ) 1) : g x = c * artanh x + g 0 := by
  set h : ℝ → ℝ := fun t => g t - c * artanh t with hh
  have hd : ∀ y ∈ Ioo (-1:ℝ) 1, HasDerivAt h 0 y := by
    intro y hy
    have h1 := hg y hy
    have h2 := (hasDerivAt_artanh hy).const_mul c
    have hsub := h1.sub h2
    have hz : c / (1 - y ^ 2) - c * (1 / (1 - y ^ 2)) = 0 := by ring
    rwa [hz] at hsub
  have hzero : ∀ y ∈ Ioo (-1:ℝ) 1, fderivWithin ℝ h (Ioo (-1:ℝ) 1) y = 0 := by
    intro y hy
    rw [fderivWithin_of_isOpen isOpen_Ioo hy]
    simpa using (hd y hy).hasFDerivAt.fderiv
  have hdiff : DifferentiableOn ℝ h (Ioo (-1:ℝ) 1) := fun y hy =>
    ((hd y hy).differentiableAt).differentiableWithinAt
  have h0 : (0:ℝ) ∈ Ioo (-1:ℝ) 1 := by constructor <;> norm_num
  have hconst := (convex_Ioo (-1:ℝ) 1).is_const_of_fderivWithin_eq_zero hdiff hzero hx h0
  simp only [hh] at hconst
  rw [Real.artanh_zero] at hconst
  linarith

/-- The two-way form: the solutions of the stabilisation ODE on `(-1,1)` are exactly the
affine images of `artanh`. -/
theorem stabilizer_iff_affine_artanh {g : ℝ → ℝ} {c : ℝ} :
    (∀ x ∈ Ioo (-1:ℝ) 1, HasDerivAt g (c / (1 - x ^ 2)) x) ↔
      ∃ b : ℝ, ∀ x ∈ Ioo (-1:ℝ) 1, g x = c * artanh x + b := by
  constructor
  · intro hg
    exact ⟨g 0, fun x hx => stabilizer_unique hg hx⟩
  · rintro ⟨b, hb⟩ x hx
    have hmain : HasDerivAt (fun t => c * artanh t + b) (c / (1 - x ^ 2)) x := by
      have h := ((hasDerivAt_artanh hx).const_mul c).add_const b
      have hz : c * (1 / (1 - x ^ 2)) = c / (1 - x ^ 2) := by ring
      rwa [hz] at h
    apply hmain.congr_of_eventuallyEq
    filter_upwards [isOpen_Ioo.mem_nhds hx] with y hy
    exact hb y hy

/-! ## 2. The cost calculus -/

/-- **The quadratic cost law.**  Halving a margin quadruples the number of draws needed
above the baseline `3`; in general the cost above baseline scales by `k²`. -/
theorem reqSamples_scaling {z M k : ℝ} (hM : M ≠ 0) :
    reqSamples z (M / k) - 3 = k ^ 2 * (reqSamples z M - 3) := by
  simp only [reqSamples]
  field_simp
  ring

/-- Cost is strictly decreasing in the rapidity margin. -/
theorem reqSamples_strict_anti {z M N : ℝ} (hz : 0 < z) (hM : 0 < M) (hMN : M < N) :
    reqSamples z N < reqSamples z M := by
  have hN : 0 < N := hM.trans hMN
  have h1 : z / N < z / M := by
    apply div_lt_div_of_pos_left hz hM hMN
  have h2 : (z / N) ^ 2 < (z / M) ^ 2 := by
    nlinarith [div_pos hz hN, div_pos hz hM]
  simp only [reqSamples]
  linarith

/-- **The mirror criterion.**  An interval sits below a ceiling `f` exactly when the
rapidity half-width parameter is at most the relativistic gap `d(f,r)`.  Certifying a drop
below a level costs precisely as much as certifying a clearance above it. -/
theorem ceiling_certified_iff {r t f : ℝ} (hr1 : -1 < r) (hr2 : r < 1) (ht0 : 0 ≤ t)
    (ht2 : t < 1) (hf1 : -1 < f) (hf2 : f < 1) :
    ciHi r t ≤ f ↔ t ≤ rapidityDiff f r := by
  have h1 : 0 < 1 + r * t := by nlinarith
  have h2 : 0 < 1 - f * r := one_sub_mul_pos hf1 hf2 hr1 hr2
  rw [ciHi_eq, div_le_iff₀ h1, rapidityDiff, le_div_iff₀ h2]
  constructor <;> intro h <;> nlinarith

/-! ## 3. Pricing the bitlen-84 crossing test -/

/-- **The crossing test is out of reach at the U80 budget.**  Certifying that the reading
has dropped below the floor costs at least `74000` draws at the conservative end `0.545`
of the predicted bitlen-84 window, and at least `38000` at the optimistic end `0.543`. -/
theorem u84_crossing_test_cost :
    38000 ≤ reqSamples zMult (artanh bandFloor - artanh (543 / 1000 : ℝ)) ∧
    74000 ≤ reqSamples zMult (artanh bandFloor - artanh (545 / 1000 : ℝ)) := by
  have hz : (0:ℝ) < zMult := by simp only [zMult]; norm_num
  have hbf : bandFloor < 1 := by simp only [bandFloor]; norm_num
  constructor
  · have hfr : (543 / 1000 : ℝ) < bandFloor := by simp only [bandFloor]; norm_num
    have h := reqSamples_ge_of_le hz (margin_pos (by norm_num) hfr hbf)
      (margin_upper (by norm_num) hfr hbf)
    refine le_trans ?_ h
    simp only [zMult, rapidityDiff, bandFloor]
    norm_num
  · have hfr : (545 / 1000 : ℝ) < bandFloor := by simp only [bandFloor]; norm_num
    have h := reqSamples_ge_of_le hz (margin_pos (by norm_num) hfr hbf)
      (margin_upper (by norm_num) hfr hbf)
    refine le_trans ?_ h
    simp only [zMult, rapidityDiff, bandFloor]
    norm_num

/-- The crossing test needs more than twenty times the U80 budget. -/
theorem u84_test_infeasible_at_current_budget :
    20 * effSamples < reqSamples zMult (artanh bandFloor - artanh (545 / 1000 : ℝ)) := by
  have h1 := u80_effective_sample_size.2
  have h2 := u84_crossing_test_cost.2
  linarith

/-! ## 4. A discrete fade ladder -/

/-- A rapidity ladder falling by at least `δ` per rung falls linearly. -/
theorem ladder_linear_decay {w : ℕ → ℝ} {delta : ℝ}
    (hstep : ∀ k, w (k + 1) ≤ w k - delta) (k : ℕ) : w k ≤ w 0 - k * delta := by
  induction k with
  | zero => simp
  | succ n ih =>
      have := hstep n
      push_cast
      push_cast at ih
      linarith

/-- Hence such a ladder is below any level `L` once `(w 0 - L)/δ` rungs have passed. -/
theorem ladder_crosses_of_uniform_step {w : ℕ → ℝ} {delta L : ℝ} (hd : 0 < delta)
    (hstep : ∀ k, w (k + 1) ≤ w k - delta) {k : ℕ} (hk : (w 0 - L) / delta ≤ k) :
    w k ≤ L := by
  have h := ladder_linear_decay hstep k
  have : w 0 - L ≤ k * delta := by
    rw [div_le_iff₀ hd] at hk
    linarith
  linarith

/-- **One further rung at the observed fade rate already crosses the floor.**  Taking the
rapidity step observed between bitlen 72 and bitlen 80 as a lower bound on subsequent
8-bitlen steps, the very next rung reads below `0.55`.  This is the discrete counterpart of
the continuous prediction `crossing ∈ (82,83)`, and needs no continuity in the bitlen. -/
theorem u80_one_more_rung_crosses {w : ℕ → ℝ}
    (hstep : ∀ k, w (k + 1) ≤ w k - (artanh rho72 - artanh rhoPooled))
    (hw0 : w 0 = artanh rhoPooled) : w 1 < artanh bandFloor := by
  have hA : (2:ℝ) * artanh rhoPooled = Real.log (313 / 87) := by
    have h := two_artanh_eq_log (x := rhoPooled)
      (by simp only [rhoPooled]; norm_num) (by simp only [rhoPooled]; norm_num)
    have e : (1 + rhoPooled) / (1 - rhoPooled) = 313 / 87 := by simp only [rhoPooled]; norm_num
    rwa [e] at h
  have hB : (2:ℝ) * artanh rho72 = Real.log (321 / 79) := by
    have h := two_artanh_eq_log (x := rho72)
      (by simp only [rho72]; norm_num) (by simp only [rho72]; norm_num)
    have e : (1 + rho72) / (1 - rho72) = 321 / 79 := by simp only [rho72]; norm_num
    rwa [e] at h
  have hC : (2:ℝ) * artanh bandFloor = Real.log (31 / 9) := by
    have h := two_artanh_eq_log (x := bandFloor)
      (by simp only [bandFloor]; norm_num) (by simp only [bandFloor]; norm_num)
    have e : (1 + bandFloor) / (1 - bandFloor) = 31 / 9 := by simp only [bandFloor]; norm_num
    rwa [e] at h
  -- the arithmetic core: `(313/87)² < (31/9)·(321/79)`
  have hkey : 2 * artanh rhoPooled - artanh rho72 < artanh bandFloor := by
    have h := log_prod_lt (A := (313 / 87 : ℝ)) (B := (1 : ℝ)) (C := (31 / 9 : ℝ))
      (D := (321 / 79 : ℝ)) (m := 2) (k := 0) (p := 1) (q := 1) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
    push_cast at h
    rw [Real.log_one] at h
    linarith
  have h1 := hstep 0
  rw [hw0] at h1
  linarith

end Catalog.Applications.TDialU80RapidityCanonicity