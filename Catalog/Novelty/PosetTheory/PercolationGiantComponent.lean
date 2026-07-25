import Mathlib

/-!
# The percolation / giant-component phase transition (Poisson branching)

This file gives a fully formal, self-contained treatment of the **percolation
phase transition** underlying the emergence of a *giant connected component* in
the Erdős–Rényi random graph `G(n, λ/n)` and, equivalently, the survival of a
Poisson(λ) Galton–Watson branching process.

## Motivation

The research theme is *"mathematics as a phase transition"*, with the concrete
picture that a growing web of connections undergoes a **percolation transition**:
below a critical connectivity the connected clusters stay small (bounded), while
above it a single macroscopic cluster suddenly emerges.

For the mean-field percolation model the **order parameter** is the *survival
probability* (equivalently the asymptotic fraction of vertices in the giant
component) `ρ`, which satisfies the self-consistency / fixed-point equation

  `ρ = 1 - exp (-λ ρ)`,

where `λ` is the mean number of connections per vertex (the mean offspring of the
branching process).  We prove rigorously that this model has a phase transition
at the critical value `λ_c = 1`:

* **Subcritical (`0 < λ ≤ 1`).**  The only nonnegative solution is `ρ = 0`
  (`survivalProb_eq_zero_of_subcritical`): all clusters are finite, no giant
  component.
* **Supercritical (`λ > 1`).**  A solution `0 < ρ < 1` appears
  (`exists_pos_survivalProb_of_supercritical`): a giant component emerges.
* **Continuous onset with mean-field percolation exponent `1`.**  Every positive
  solution obeys `2 (λ − 1) / λ² ≤ ρ` (`survivalProb_ge_of_supercritical`), so as
  `λ ↓ 1` the giant component grows *linearly*, `ρ ≳ 2(λ − 1)` — the mean-field
  percolation critical exponent `β = 1`, in contrast with the exponent `1/2` of
  the Curie–Weiss ferromagnet.

All order-parameter values automatically lie in `[0, 1)` (`survivalProb_lt_one`).

## Main analytic tools

* `one_sub_exp_neg_lt_self` : `1 - exp(-x) < x` for `x > 0`.
* `one_sub_exp_neg_ge_quadratic` : `x - x²/2 ≤ 1 - exp(-x)` for `x ≥ 0`.
-/

namespace PercolationGiantComponent

open Real

/-! ### Elementary inequalities for `1 - exp(-x)` -/

/-- Strict upper bound: `1 - exp(-x) < x` for `x > 0`.  Equivalently
`1 - x < exp(-x)`, a strict form of the convexity bound `1 + t ≤ exp t`. -/
theorem one_sub_exp_neg_lt_self {x : ℝ} (hx : 0 < x) : 1 - Real.exp (-x) < x := by
  have h := Real.add_one_lt_exp (x := -x) (by linarith)
  linarith

/-- Quadratic Taylor lower bound: `x - x²/2 ≤ 1 - exp(-x)` for `x ≥ 0`.  The
difference `(1 - x + x²/2) - exp(-x)` vanishes at `0` and has nonnegative
derivative `x + exp(-x) - 1 ≥ 0`, hence is monotone; rearranging gives the claim. -/
theorem one_sub_exp_neg_ge_quadratic {x : ℝ} (hx : 0 ≤ x) :
    x - x ^ 2 / 2 ≤ 1 - Real.exp (-x) := by
  have key : MonotoneOn (fun t => (1 - t + t ^ 2 / 2) - Real.exp (-t)) (Set.Ici (0 : ℝ)) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 0)
    · fun_prop
    · apply Differentiable.differentiableOn; fun_prop
    · intro t ht
      simp only [interior_Ici, Set.mem_Ioi] at ht
      have hd : HasDerivAt (fun t => (1 - t + t ^ 2 / 2) - Real.exp (-t))
          ((-1 + 2 * t / 2) - Real.exp (-t) * (-1)) t := by
        have h1 : HasDerivAt (fun t : ℝ => 1 - t + t ^ 2 / 2) (-1 + 2 * t / 2) t := by
          have := ((hasDerivAt_const t (1 : ℝ)).sub (hasDerivAt_id t)).add
            ((hasDerivAt_pow 2 t).div_const 2)
          convert this using 1; push_cast; ring
        have h2 : HasDerivAt (fun t : ℝ => Real.exp (-t)) (Real.exp (-t) * (-1)) t :=
          (Real.hasDerivAt_exp (-t)).comp t (hasDerivAt_neg t)
        exact h1.sub h2
      rw [hd.deriv]
      have := Real.add_one_le_exp (-t)
      nlinarith [this]
  have := key Set.self_mem_Ici (Set.mem_Ici.mpr hx) hx
  simp at this; linarith

/-! ### The order parameter (survival probability / giant-component fraction) -/

/-- A real number `ρ` is a **survival probability** of the mean-field percolation
model at connectivity `λ` when it is a fixed point of `ρ ↦ 1 - exp(-λ ρ)`, i.e. it
solves the self-consistency equation `ρ = 1 - exp(-λ ρ)`. -/
def IsSurvivalProb (lam ρ : ℝ) : Prop := ρ = 1 - Real.exp (-(lam * ρ))

/-- The trivial (extinction) state `ρ = 0` is always a survival probability. -/
theorem isSurvivalProb_zero (lam : ℝ) : IsSurvivalProb lam 0 := by
  simp [IsSurvivalProb]

/-- Every survival probability is strictly below `1`, since `exp(-λρ) > 0`. -/
theorem survivalProb_lt_one {lam ρ : ℝ} (h : IsSurvivalProb lam ρ) : ρ < 1 := by
  rw [h]; have := Real.exp_pos (-(lam * ρ)); linarith

/-! ### Subcritical regime: only the trivial solution for `λ ≤ 1` -/

/-- **Subcritical / no giant component.**  For `0 < λ ≤ 1` the only nonnegative
survival probability is `ρ = 0`: below the critical connectivity all clusters are
finite. -/
theorem survivalProb_eq_zero_of_subcritical {lam ρ : ℝ} (hlam : 0 < lam) (hlam1 : lam ≤ 1)
    (hρ : 0 ≤ ρ) (h : IsSurvivalProb lam ρ) : ρ = 0 := by
  unfold IsSurvivalProb at h
  rcases eq_or_lt_of_le hρ with hρ0 | hρ0
  · exact hρ0.symm
  · exfalso
    have hlr : 0 < lam * ρ := mul_pos hlam hρ0
    have hlt := one_sub_exp_neg_lt_self hlr
    -- ρ = 1 - exp(-λρ) < λρ ≤ ρ, contradiction.
    have hle : lam * ρ ≤ ρ := by nlinarith
    linarith [h, hlt, hle]

/-! ### Supercritical regime: emergence of a giant component for `λ > 1` -/

/-- **Supercritical / giant component.**  For supercritical connectivity `λ > 1`
there exists a survival probability `0 < ρ < 1`: a macroscopic connected cluster
emerges.  The proof finds `a > 0` with `1 - exp(-λ a) > a` via the quadratic lower
bound, notes the value at `1` is `< 1`, and applies the intermediate value theorem
to the continuous residual `ρ ↦ (1 - exp(-λ ρ)) - ρ`. -/
theorem exists_pos_survivalProb_of_supercritical {lam : ℝ} (hlam : 1 < lam) :
    ∃ ρ : ℝ, 0 < ρ ∧ ρ < 1 ∧ IsSurvivalProb lam ρ := by
  have hlam0 : 0 < lam := by linarith
  -- Continuous residual function.
  have hcont : Continuous (fun ρ => (1 - Real.exp (-(lam * ρ))) - ρ) := by fun_prop
  -- Test point `a = (λ - 1) / λ²`, which satisfies `a < 2(λ-1)/λ²`.
  set a : ℝ := (lam - 1) / lam ^ 2 with ha_def
  have ha_pos : 0 < a := by rw [ha_def]; exact div_pos (by linarith) (by positivity)
  have ha_lt1 : a < 1 := by
    rw [ha_def, div_lt_one (by positivity)]
    nlinarith [hlam0]
  -- Lower bound at `a`: `1 - exp(-λ a) > a`.
  have hfa : 0 < (1 - Real.exp (-(lam * a))) - a := by
    have hla : 0 ≤ lam * a := by positivity
    have hquad := one_sub_exp_neg_ge_quadratic hla
    -- 1 - exp(-λ a) ≥ λ a - (λ a)²/2, and this exceeds a since a = (λ-1)/λ².
    have hlt : a < lam * a - (lam * a) ^ 2 / 2 := by
      have hla_eq : lam * a = (lam - 1) / lam := by rw [ha_def]; field_simp
      rw [hla_eq, ha_def, div_lt_iff₀ (by positivity : (0:ℝ) < lam ^ 2)]
      have hrw : ((lam - 1) / lam - ((lam - 1) / lam) ^ 2 / 2) * lam ^ 2
          = (lam - 1) * lam - (lam - 1) ^ 2 / 2 := by field_simp
      rw [hrw]
      nlinarith [mul_pos (show (0:ℝ) < lam - 1 by linarith) (show (0:ℝ) < lam - 1 by linarith)]
    linarith
  -- Value at `1`: `(1 - exp(-λ)) - 1 < 0`.
  have hfb : (1 - Real.exp (-(lam * 1))) - 1 < 0 := by
    have := Real.exp_pos (-(lam * 1)); linarith
  -- Intermediate value theorem on `[a, 1]`.
  have hmem : (0 : ℝ) ∈
      Set.Ioo ((1 - Real.exp (-(lam * 1))) - 1) ((1 - Real.exp (-(lam * a))) - a) := ⟨hfb, hfa⟩
  obtain ⟨ρ, hρ_mem, hρ_eq⟩ :=
    intermediate_value_Ioo' ha_lt1.le hcont.continuousOn hmem
  refine ⟨ρ, lt_of_lt_of_le ha_pos hρ_mem.1.le, hρ_mem.2, ?_⟩
  unfold IsSurvivalProb; linarith [hρ_eq]

/-! ### Continuous onset with mean-field percolation exponent `1` -/

/-- **Continuous onset / critical exponent.**  For `λ > 1`, every positive survival
probability obeys `2 (λ - 1) / λ² ≤ ρ`.  Hence the giant component grows
*continuously and linearly* out of `0` as `λ ↓ 1` (`ρ ≳ 2(λ − 1)`): the mean-field
percolation critical exponent is `β = 1`. -/
theorem survivalProb_ge_of_supercritical {lam ρ : ℝ} (hlam : 1 < lam) (hρ : 0 < ρ)
    (h : IsSurvivalProb lam ρ) : 2 * (lam - 1) / lam ^ 2 ≤ ρ := by
  unfold IsSurvivalProb at h
  have hlam0 : 0 < lam := by linarith
  have hlr : 0 ≤ lam * ρ := by positivity
  have hquad := one_sub_exp_neg_ge_quadratic hlr
  rw [← h] at hquad
  -- ρ ≥ λρ - (λρ)²/2  ⟹  ρ ≥ 2(λ-1)/λ².
  rw [div_le_iff₀ (by positivity : (0:ℝ) < lam ^ 2)]
  nlinarith [hquad, hρ, mul_pos hρ hρ, hlam0]

end PercolationGiantComponent