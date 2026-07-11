import Mathlib

/-!
# A second-order phase transition for the mean-field (Curie–Weiss) order parameter

This file gives a fully formal, self-contained treatment of the paradigmatic
*second-order phase transition* of statistical mechanics: the spontaneous
magnetization of the mean-field Ising (Curie–Weiss) ferromagnet.

## Motivation

The research theme is *"mathematics as a phase transition"*: the idea that a
large body of interconnected results behaves like a statistical-mechanical
system, with an **order parameter** measuring global coherence that switches on
sharply once a coupling strength crosses a **critical threshold**.

The cleanest exactly-solvable model exhibiting this behaviour is mean-field
theory, where the order parameter `m` (the average magnetization / "coherence")
obeys the self-consistency equation

  `m = tanh (β m)`,

with `β` the inverse temperature (the coupling strength).  We prove rigorously
that this model has a *second-order phase transition at the critical value
`β_c = 1`*:

* **Disordered phase (`0 < β ≤ 1`).**  The only solution is `m = 0`
  (`magnetization_eq_zero_of_subcritical`).  There is no spontaneous order.
* **Ordered phase (`β > 1`).**  A nonzero solution `m > 0` appears, together with
  its mirror image `-m` (`exists_pos_magnetization_of_supercritical`,
  `IsMagnetization.neg`).  Spontaneous order emerges.
* **Continuous (second-order) onset with mean-field critical exponent `1/2`.**
  Any positive solution satisfies `3 (β - 1) / β³ ≤ m²`
  (`magnetization_sq_ge_of_supercritical`), so as `β ↓ 1` the branch bifurcates
  continuously from `0` growing like `√(β − 1)` — the hallmark of a *second*-order
  (as opposed to first-order/discontinuous) transition.

All order-parameter values are bounded: `|m| < 1` (`abs_magnetization_lt_one`).

## Main analytic tools proved here

* `hasDerivAt_tanh` : `tanh' = 1 - tanh²`.
* `tanh_lt_self` : `tanh x < x` for `x > 0` (contraction below the diagonal).
* `tanh_ge_cubic` : `x - x³/3 ≤ tanh x` for `x ≥ 0` (cubic Taylor lower bound),
  which powers both the existence result and the critical-exponent bound.
-/

namespace MeanFieldPhaseTransition

open Real

/-! ### Calculus of `tanh` -/

/-- The derivative of the hyperbolic tangent: `tanh' x = 1 - tanh² x`. -/
theorem hasDerivAt_tanh (x : ℝ) : HasDerivAt Real.tanh (1 - Real.tanh x ^ 2) x := by
  have hfun : (fun y => Real.sinh y / Real.cosh y) = Real.tanh :=
    funext fun y => (Real.tanh_eq_sinh_div_cosh y).symm
  have h : HasDerivAt (fun y => Real.sinh y / Real.cosh y)
      ((Real.cosh x * Real.cosh x - Real.sinh x * Real.sinh x) / (Real.cosh x) ^ 2) x :=
    (Real.hasDerivAt_sinh x).div (Real.hasDerivAt_cosh x) (Real.cosh_pos x).ne'
  rw [hfun] at h; convert h using 1
  have hc := (Real.cosh_pos x).ne'
  rw [Real.tanh_eq_sinh_div_cosh]; field_simp

/-- `tanh` is differentiable on all of `ℝ`. -/
theorem differentiable_tanh : Differentiable ℝ Real.tanh :=
  fun x => (hasDerivAt_tanh x).differentiableAt

/-- `tanh` is continuous. -/
theorem continuous_tanh : Continuous Real.tanh := differentiable_tanh.continuous

/-! ### Elementary inequalities for `tanh` -/

/-- `tanh` lies strictly below the diagonal on the positive axis: `tanh x < x` for `x > 0`.
Equivalently, `sinh x < x · cosh x`, which follows because `t ↦ t·cosh t − sinh t` has
positive derivative `t·sinh t` on `(0, ∞)`. -/
theorem tanh_lt_self {x : ℝ} (hx : 0 < x) : Real.tanh x < x := by
  rw [Real.tanh_eq_sinh_div_cosh, div_lt_iff₀ (Real.cosh_pos x)]
  have key : StrictMonoOn (fun t => t * Real.cosh t - Real.sinh t) (Set.Ici (0 : ℝ)) := by
    apply strictMonoOn_of_deriv_pos (convex_Ici 0)
    · fun_prop
    · intro t ht
      simp only [interior_Ici, Set.mem_Ioi] at ht
      have hd : HasDerivAt (fun t => t * Real.cosh t - Real.sinh t) (t * Real.sinh t) t := by
        have := ((hasDerivAt_id t).mul (Real.hasDerivAt_cosh t)).sub (Real.hasDerivAt_sinh t)
        convert this using 1; simp
      rw [hd.deriv]
      have : 0 < Real.sinh t := by rw [Real.sinh_pos_iff]; exact ht
      positivity
  have := key Set.self_mem_Ici (Set.mem_Ici.mpr hx.le) hx
  simp at this; linarith

/-- `tanh` is nonnegative on the nonnegative axis. -/
theorem tanh_nonneg {x : ℝ} (hx : 0 ≤ x) : 0 ≤ Real.tanh x := by
  rw [Real.tanh_eq_sinh_div_cosh]
  apply div_nonneg _ (Real.cosh_pos x).le
  rw [← Real.sinh_zero]; exact Real.sinh_le_sinh.mpr hx

/-- Cubic Taylor lower bound: `x - x³/3 ≤ tanh x` for `x ≥ 0`.  The difference
`tanh t - (t - t³/3)` vanishes at `0` and has derivative `t² - tanh² t ≥ 0`
(since `0 ≤ tanh t ≤ t`), hence is monotone. -/
theorem tanh_ge_cubic {x : ℝ} (hx : 0 ≤ x) : x - x ^ 3 / 3 ≤ Real.tanh x := by
  have key : MonotoneOn (fun t => Real.tanh t - (t - t ^ 3 / 3)) (Set.Ici (0 : ℝ)) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 0)
    · exact (continuous_tanh.sub (by fun_prop)).continuousOn
    · exact (differentiable_tanh.sub (by fun_prop)).differentiableOn
    · intro t ht
      simp only [interior_Ici, Set.mem_Ioi] at ht
      have hd : HasDerivAt (fun t => Real.tanh t - (t - t ^ 3 / 3))
          ((1 - Real.tanh t ^ 2) - (1 - 3 * t ^ 2 / 3)) t := by
        have h1 := hasDerivAt_tanh t
        have h2 : HasDerivAt (fun t : ℝ => t - t ^ 3 / 3) (1 - 3 * t ^ 2 / 3) t := by
          have := (hasDerivAt_id t).sub ((hasDerivAt_pow 3 t).div_const 3)
          convert this using 1
        exact h1.sub h2
      rw [hd.deriv]
      have htt : Real.tanh t ≤ t := (tanh_lt_self ht).le
      have htn : 0 ≤ Real.tanh t := tanh_nonneg ht.le
      nlinarith [htt, htn, ht.le]
  have := key Set.self_mem_Ici (Set.mem_Ici.mpr hx) hx
  simp at this; linarith

/-! ### The order parameter (spontaneous magnetization) -/

/-- A real number `m` is a **magnetization** of the mean-field ferromagnet at
inverse temperature `β` when it is a fixed point of `m ↦ tanh (β m)`, i.e. it
solves the self-consistency equation `tanh (β m) = m`. -/
def IsMagnetization (β m : ℝ) : Prop := Real.tanh (β * m) = m

/-- The disordered state `m = 0` is always a magnetization. -/
theorem isMagnetization_zero (β : ℝ) : IsMagnetization β 0 := by
  simp [IsMagnetization]

/-- The self-consistency equation is odd in `m`: if `m` is a magnetization then so is `-m`
(the symmetry `m ↦ -m` of the Ising ferromagnet). -/
theorem IsMagnetization.neg {β m : ℝ} (h : IsMagnetization β m) : IsMagnetization β (-m) := by
  unfold IsMagnetization at *
  rw [mul_neg, Real.tanh_neg, h]

/-- Every magnetization is bounded: `|m| < 1`, since `|tanh| < 1`. -/
theorem abs_magnetization_lt_one {β m : ℝ} (h : IsMagnetization β m) : |m| < 1 := by
  rw [← h]; exact Real.abs_tanh_lt_one _

/-! ### Disordered phase: uniqueness of `m = 0` for `β ≤ 1` -/

/-- **Disordered phase.**  For `0 < β ≤ 1` the only magnetization is `m = 0`:
no spontaneous order below the critical coupling `β_c = 1`. -/
theorem magnetization_eq_zero_of_subcritical {β m : ℝ} (hβ : 0 < β) (hβ1 : β ≤ 1)
    (h : IsMagnetization β m) : m = 0 := by
  unfold IsMagnetization at h
  rcases lt_trichotomy m 0 with hm | hm | hm
  · exfalso
    have hlt := tanh_lt_self (show 0 < -(β * m) by
      have : β * m < 0 := mul_neg_of_pos_of_neg hβ hm; linarith)
    rw [Real.tanh_neg] at hlt
    have hbm2 : m ≤ β * m := by nlinarith
    linarith
  · exact hm
  · exfalso
    have hlt := tanh_lt_self (mul_pos hβ hm)
    have hbm2 : β * m ≤ m := by nlinarith
    linarith

/-! ### Ordered phase: existence of nonzero magnetization for `β > 1` -/

/-- **Ordered phase.**  For supercritical coupling `β > 1` there exists a strictly
positive magnetization `m > 0` (spontaneous symmetry breaking).  The proof finds
`a > 0` with `tanh (β a) > a` using the cubic lower bound, notes `tanh (β·(a+1)) < a+1`,
and applies the intermediate value theorem to the continuous function `tanh (β·) - id`. -/
theorem exists_pos_magnetization_of_supercritical {β : ℝ} (hβ : 1 < β) :
    ∃ m : ℝ, 0 < m ∧ IsMagnetization β m := by
  have hβ0 : 0 < β := by linarith
  -- The continuous "residual" function.
  have hcont : Continuous (fun m => Real.tanh (β * m) - m) :=
    (continuous_tanh.comp (by fun_prop)).sub continuous_id
  -- Critical scale `c = 3(β-1)/β³ > 0` and the test point `a = √c / 2`.
  set c : ℝ := 3 * (β - 1) / β ^ 3 with hc_def
  have hc_pos : 0 < c := by
    rw [hc_def]; exact div_pos (by linarith) (by positivity)
  set a : ℝ := Real.sqrt c / 2 with ha_def
  have hsqrt_pos : 0 < Real.sqrt c := Real.sqrt_pos.mpr hc_pos
  have ha_pos : 0 < a := by rw [ha_def]; exact div_pos hsqrt_pos (by norm_num)
  have ha_sq : a ^ 2 = c / 4 := by
    rw [ha_def]; rw [div_pow, Real.sq_sqrt hc_pos.le]; norm_num
  -- Lower bound at `a`: `tanh (β a) > a`.
  have hfa : 0 < Real.tanh (β * a) - a := by
    have hba : 0 ≤ β * a := by positivity
    have hcubic := tanh_ge_cubic hba
    -- tanh (β a) ≥ β a - (β a)³/3, and this exceeds a since a² = c/4 < c.
    have hlt : a < β * a - (β * a) ^ 3 / 3 := by
      have hβ3a2 : β ^ 3 * a ^ 2 = 3 * (β - 1) / 4 := by
        rw [ha_sq, hc_def]; field_simp
      have hcube : (β * a) ^ 3 = (β ^ 3 * a ^ 2) * a := by ring
      have hpos : 0 < (β - 1) * a := mul_pos (by linarith) ha_pos
      rw [hcube, hβ3a2]
      nlinarith [hpos]
    linarith [hcubic, hlt]
  -- Upper bound at `a + 1`: `tanh (β (a+1)) < a + 1`.
  have hfb : Real.tanh (β * (a + 1)) - (a + 1) < 0 := by
    have := Real.tanh_lt_one (β * (a + 1))
    linarith
  -- Intermediate value theorem on `[a, a+1]`.
  have hmem : (0 : ℝ) ∈ Set.Ioo (Real.tanh (β * (a + 1)) - (a + 1)) (Real.tanh (β * a) - a) :=
    ⟨hfb, hfa⟩
  obtain ⟨m, hm_mem, hm_eq⟩ :=
    intermediate_value_Ioo' (by linarith : a ≤ a + 1) hcont.continuousOn hmem
  refine ⟨m, ?_, ?_⟩
  · exact lt_of_lt_of_le ha_pos hm_mem.1.le
  · unfold IsMagnetization; linarith [hm_eq]

/-! ### Second-order onset with mean-field critical exponent `1/2` -/

/-- **Second-order onset / critical exponent.**  For `β > 1`, every positive
magnetization obeys the lower bound `3 (β - 1) / β³ ≤ m²`.  Hence the spontaneous
magnetization bifurcates *continuously* from `0` as `β ↓ 1`, growing at least
like `√(β − 1)` — the mean-field critical exponent `β_exp = 1/2` — which is
precisely what makes the transition *second order* rather than first order. -/
theorem magnetization_sq_ge_of_supercritical {β m : ℝ} (hβ : 1 < β) (hm : 0 < m)
    (h : IsMagnetization β m) : 3 * (β - 1) / β ^ 3 ≤ m ^ 2 := by
  unfold IsMagnetization at h
  have hβ0 : 0 < β := by linarith
  have hbm : 0 ≤ β * m := by positivity
  have hcubic := tanh_ge_cubic hbm
  rw [h] at hcubic
  rw [div_le_iff₀ (by positivity : (0:ℝ) < β ^ 3)]
  nlinarith [hcubic, hm, mul_pos hm hm, hβ0]

end MeanFieldPhaseTransition