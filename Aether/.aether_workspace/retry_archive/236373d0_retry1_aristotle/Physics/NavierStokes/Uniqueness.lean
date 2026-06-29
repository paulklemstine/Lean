/-
# Uniqueness of Solutions via the Energy Estimate (Ladyzhenskaya mechanism)

This file extends the abstract Galerkin Navier–Stokes model of
`Physics.NavierStokes.EnergyMethod` with the **uniqueness** half of the
Ladyzhenskaya global well-posedness theory.

## Mathematical context

Given two solutions `u, w` of the abstract model

  v'(t) = −ν A v − B(v, v),

their difference `d = u − w` satisfies, since `A` is linear,

  d'(t) = −ν A d − (B(u,u) − B(w,w)).

Testing against `d` and using positivity of `A` (`⟪A d, d⟫ ≥ 0`) gives, for the
difference energy `E_d(t) = ‖d(t)‖²`,

  ½ E_d'(t) = −ν⟪A d, d⟫ − ⟪B(u,u) − B(w,w), d⟫
            ≤ −⟪B(u,u) − B(w,w), d⟫.

The decisive 2D fact is the **Ladyzhenskaya bound**: the transport difference is
controlled by the difference energy,

  −⟪B(u,u) − B(w,w), d⟫ ≤ C · ‖d‖²,

(in 2D this follows from the interpolation inequality `‖f‖₄ ≲ ‖f‖₂^{1/2}‖∇f‖₂^{1/2}`).
We take this estimate as the abstract structural hypothesis.  It yields the
differential inequality `E_d'(t) ≤ 2C·E_d(t)`, and since `E_d(t₀) = 0`,
Grönwall's lemma forces `E_d ≡ 0` for `t ≥ t₀`, i.e. `u = w`.  This is exactly
the proof of uniqueness for 2D Navier–Stokes.

## Main results

* `Model.diff_energy_hasDerivAt` — energy identity for the difference of solutions.
* `Model.diff_energy_deriv_le` — the Ladyzhenskaya differential inequality.
* `Model.eq_of_energy_estimate` — forward-in-time uniqueness.
-/

import Mathlib
import Physics.NavierStokes.EnergyMethod

namespace NavierStokes

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-
Energy identity for the difference of two solutions: the difference energy
`E_d(t) = ‖u t − w t‖²` is differentiable with derivative
`2⟪(vectorField u − vectorField w), (u − w)⟫`.
-/
theorem Model.diff_energy_hasDerivAt (M : Model V) {u w : ℝ → V}
    (hu : M.IsSolution u) (hw : M.IsSolution w) (t : ℝ) :
    HasDerivAt (energy (fun r => u r - w r))
      (2 * (inner ℝ (M.vectorField (u t) - M.vectorField (w t)) (u t - w t) : ℝ)) t := by
  have h_diff : HasDerivAt (fun r => u r - w r) (M.vectorField (u t) - M.vectorField (w t)) t := by
    exact HasDerivAt.sub ( hu t ) ( hw t );
  convert HasDerivAt.inner ℝ h_diff h_diff using 1;
  rw [ real_inner_comm ] ; ring

/-
**Ladyzhenskaya differential inequality.**  Under the abstract Ladyzhenskaya
bound (`−⟪B(u,u) − B(w,w), d⟫ ≤ C‖d‖²`), the difference energy derivative is at
most `2C` times the difference energy.
-/
theorem Model.diff_energy_deriv_le (M : Model V) {u w : ℝ → V}
    {C : ℝ}
    (hLip : ∀ t : ℝ,
      -(C * (inner ℝ (u t - w t) (u t - w t) : ℝ))
        ≤ inner ℝ (M.B (u t) (u t) - M.B (w t) (w t)) (u t - w t))
    (t : ℝ) :
    2 * (inner ℝ (M.vectorField (u t) - M.vectorField (w t)) (u t - w t) : ℝ)
      ≤ 2 * C * energy (fun r => u r - w r) t := by
  simp_all +decide [ mul_assoc, Model.vectorField ];
  simp_all +decide [ energy, inner_sub_left, inner_sub_right, inner_neg_left, inner_neg_right, real_inner_smul_left, real_inner_smul_right ];
  have := M.hA ( u t - w t ) ; simp_all +decide [ inner_sub_left, inner_sub_right, real_inner_comm ] ; nlinarith [ hLip t, M.hν, M.hA ( u t ), M.hA ( w t ) ] ;

/-
**Uniqueness (forward in time).**  Two solutions agreeing at a time `t₀` and
satisfying the abstract Ladyzhenskaya bound coincide for all `t ≥ t₀`.
-/
theorem Model.eq_of_energy_estimate (M : Model V) {u w : ℝ → V}
    (hu : M.IsSolution u) (hw : M.IsSolution w)
    {C : ℝ}
    (hLip : ∀ t : ℝ,
      -(C * (inner ℝ (u t - w t) (u t - w t) : ℝ))
        ≤ inner ℝ (M.B (u t) (u t) - M.B (w t) (w t)) (u t - w t))
    {t0 : ℝ} (hinit : u t0 = w t0)
    {t : ℝ} (ht : t0 ≤ t) : u t = w t := by
  -- By `Model.diff_energy_hasDerivAt hu hw` and `Model.diff_energy_deriv_le hLip`, for all `r`:
  have h_deriv : ∀ r, HasDerivAt (fun r => energy (fun r => u r - w r) r) (2 * (inner ℝ (M.vectorField (u r) - M.vectorField (w r)) (u r - w r) : ℝ)) r := by
    exact fun r => Model.diff_energy_hasDerivAt M hu hw r;
  have h_diff_energy : ∀ r, HasDerivAt (fun r => energy (fun r => u r - w r) r * Real.exp (-2 * C * r)) (2 * (inner ℝ (M.vectorField (u r) - M.vectorField (w r)) (u r - w r) - C * energy (fun r => u r - w r) r) * Real.exp (-2 * C * r)) r := by
    intro r; convert HasDerivAt.mul ( h_deriv r ) ( HasDerivAt.exp ( HasDerivAt.const_mul ( -2 * C ) ( hasDerivAt_id r ) ) ) using 1; ring;
    rfl;
  -- By `Model.diff_energy_deriv_le hLip`, we have `inner ℝ (M.vectorField (u r) - M.vectorField (w r)) (u r - w r) ≤ C * energy (fun r => u r - w r) r`.
  have h_bound : ∀ r, inner ℝ (M.vectorField (u r) - M.vectorField (w r)) (u r - w r) ≤ C * energy (fun r => u r - w r) r := by
    intro r
    have := Model.diff_energy_deriv_le M hLip r
    simp [energy] at this ⊢
    linarith;
  -- By `antitone_of_hasDerivAt_nonpos`, we have that `energy (fun r => u r - w r) r * Real.exp (-2 * C * r)` is antitone.
  have h_antitone : Antitone (fun r => energy (fun r => u r - w r) r * Real.exp (-2 * C * r)) := by
    apply_rules [ antitone_of_hasDerivAt_nonpos ];
    exact fun r => mul_nonpos_of_nonpos_of_nonneg ( mul_nonpos_of_nonneg_of_nonpos zero_le_two ( sub_nonpos_of_le ( h_bound r ) ) ) ( Real.exp_nonneg _ );
  have := h_antitone ht; simp_all +decide [ energy ] ;
  exact sub_eq_zero.mp ( norm_eq_zero.mp ( by contrapose! this; positivity ) )

end NavierStokes