import Mathlib

/-!
# Navier–Stokes Regularity: Lower Bound on the 3D Blow-Up Rate

This file complements `enstrophy_3d_apriori_bound` of `NavierStokes.Core`. There,
the supercritical inequality `Z'(t) ≤ C Z(t)³` was shown to yield an *upper*
comparison bound that blows up no earlier than `T* = 1/(2 C Z₀²)`. Here we prove
the dual statement: *if* a solution does blow up at a finite time `T*` (its
enstrophy tends to `+∞` as `t → T*⁻`), then it must blow up *at least* as fast as

`Z(t)² ≥ 1 / (2 C (T* - t))`,    i.e.  `‖ω(t)‖₂ ≳ (T* - t)^{-1/2}`,

for every `t < T*`. This is the classical **lower bound on the blow-up rate** of
the enstrophy, the scalar shadow of the Leray / Beale–Kato–Majda lower bounds: a
singularity cannot form unless the enstrophy already diverges at this universal
rate. Equivalently, no blow-up can occur while the enstrophy stays
`o((T*-t)^{-1/2})`.

## Mathematical background

With `w(t) = 1/Z(t)²` the supercritical inequality `Z' ≤ C Z³` linearises to the
*lower* bound `w'(t) ≥ -2C` (the same substitution that powers the upper bound in
`Core`). Integrating this Lipschitz-type estimate from `t` to `s`,
`w(s) ≥ w(t) - 2C (s - t)`. Blow-up `Z(s) → +∞` means `w(s) → 0` as `s → T*⁻`;
passing to the limit gives `0 ≥ w(t) - 2C(T* - t)`, i.e. `w(t) ≤ 2C(T* - t)`,
which is exactly `Z(t)² ≥ 1/(2C(T* - t))`.

## Main results

* `recip_sq_lower_lipschitz` — the reciprocal-square `w = 1/Z²` obeys
  `w(s) ≥ w(t) - 2C (s - t)` for `t ≤ s` (linearised supercritical inequality).
* `recip_sq_tendsto_zero_of_blowup` — blow-up `Z → +∞` forces `w = 1/Z² → 0`.
* `enstrophy_3d_blowup_lower_rate` — the lower blow-up-rate bound
  `Z(t)² ≥ 1/(2 C (T* - t))`.

-- !-- Lab Notes -- !--
-- Hypothesis H6 (lower rate): the reciprocal substitution `w = 1/Z²` that
--   linearises blow-up into the positivity threshold for the *upper* bound should,
--   read the other way, give the *lower* rate by taking the limit `s → T*⁻`.
--   Experiment confirmed `w' ≥ -2C` is identical to the inequality used in Core's
--   `enstrophy_3d_apriori_bound`; only the integration endpoints differ.
-- Insight: the MVT lower bound `w(s) - w(t) ≥ -2C(s-t)` is cleanest via
--   `exists_deriv_eq_slope` on `[t,s]`, mirroring Core's `hw_ftc`.
-- Insight: the limit step needs `𝓝[<] T*` to be `NeBot` (automatic in ℝ) so that
--   `le_of_tendsto`-style passage preserves the inequality `w t - 2C(s-t) ≤ w s`.
-- Failure analysis: trying to integrate `Z' ≤ C Z³` directly (Grönwall) gives only
--   the upper, never the lower, rate — the comparison ODE is solved *backward* from
--   the singularity, which the reciprocal `w` makes into a forward-in-time bound.
-/

open scoped Topology
open Filter

namespace NavierStokes

/-! ## Linearised supercritical inequality for `w = 1/Z²` -/

/-
**Lower Lipschitz bound for the reciprocal square.** Under the supercritical
inequality `Z'(t) ≤ C Z(t)³` with `Z > 0`, the function `w(t) = 1/Z(t)²`
satisfies `w(s) ≥ w(t) - 2 C (s - t)` for all `t ≤ s`.
-/
theorem recip_sq_lower_lipschitz
    (Z D : ℝ → ℝ) (C : ℝ)
    (hpos : ∀ t, 0 < Z t)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hineq : ∀ t, D t ≤ C * (Z t) ^ 3) :
    ∀ t s, t ≤ s → 1 / (Z s) ^ 2 ≥ 1 / (Z t) ^ 2 - 2 * C * (s - t) := by
  intros t s hts
  have h_deriv_w : ∀ t, deriv (fun t => 1 / (Z t)^2) t ≥ -2 * C := by
    intro t; norm_num [ hZ t |> HasDerivAt.differentiableAt, ne_of_gt ( hpos t ) ];
    rw [ le_div_iff₀ ] <;> nlinarith [ hpos t, hZ t |> HasDerivAt.deriv, hineq t, pow_pos ( hpos t ) 3, pow_pos ( hpos t ) 4, pow_pos ( hpos t ) 5, pow_pos ( hpos t ) 6, pow_pos ( hpos t ) 7, pow_pos ( hpos t ) 8, pow_pos ( hpos t ) 9, pow_pos ( hpos t ) 10 ];
  by_contra h_contra;
  have := exists_deriv_eq_slope ( f := fun t => 1 / Z t ^ 2 ) ( show t < s from hts.lt_of_ne ( by rintro rfl; linarith ) );
  exact absurd ( this ( continuousOn_of_forall_continuousAt fun x hx => DifferentiableAt.continuousAt ( by exact DifferentiableAt.div ( differentiableAt_const _ ) ( DifferentiableAt.pow ( hZ x |> HasDerivAt.differentiableAt ) _ ) ( ne_of_gt ( sq_pos_of_pos ( hpos x ) ) ) ) ) ( fun x hx => DifferentiableAt.differentiableWithinAt ( by exact DifferentiableAt.div ( differentiableAt_const _ ) ( DifferentiableAt.pow ( hZ x |> HasDerivAt.differentiableAt ) _ ) ( ne_of_gt ( sq_pos_of_pos ( hpos x ) ) ) ) ) ) ( by rintro ⟨ c, ⟨ htc, hcs ⟩, hcd ⟩ ; have := h_deriv_w c; rw [ eq_div_iff ] at hcd <;> nlinarith )

/-! ## Blow-up forces the reciprocal square to vanish -/

/-
**Reciprocal square vanishes at blow-up.** If the enstrophy blows up as
`t → T*⁻` (`Z → +∞`), then `w = 1/Z² → 0` along `𝓝[<] T*`.
-/
theorem recip_sq_tendsto_zero_of_blowup
    (Z : ℝ → ℝ) (Tstar : ℝ)
    (hblow : Tendsto Z (𝓝[<] Tstar) atTop) :
    Tendsto (fun t => 1 / (Z t) ^ 2) (𝓝[<] Tstar) (𝓝 0) := by
  convert Tendsto.const_mul ( 1 : ℝ ) ( tendsto_inv_atTop_zero.comp ( hblow.atTop_mul_atTop₀ hblow ) ) using 2 ; ring!;
  · norm_num;
  · grind

/-! ## The lower blow-up-rate bound -/

/-
**Lower bound on the 3D blow-up rate.** Suppose the enstrophy `Z > 0` satisfies
the supercritical inequality `Z'(t) ≤ C Z(t)³` and blows up at a finite time
`T*` (`Z → +∞` as `t → T*⁻`). Then for every `t < T*`,
`Z(t)² ≥ 1 / (2 C (T* - t))`: blow-up cannot occur slower than the universal rate
`(T*-t)^{-1/2}`.
-/
theorem enstrophy_3d_blowup_lower_rate
    (Z D : ℝ → ℝ) (C Tstar : ℝ) (hC : 0 < C)
    (hpos : ∀ t, 0 < Z t)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hineq : ∀ t, D t ≤ C * (Z t) ^ 3)
    (hblow : Tendsto Z (𝓝[<] Tstar) atTop) :
    ∀ t, t < Tstar → (Z t) ^ 2 ≥ 1 / (2 * C * (Tstar - t)) := by
  intro t ht; rw [ ge_iff_le, div_le_iff₀ ] <;> try nlinarith;
  -- Apply the inequality `w s ≥ w t - 2 * C * (s - t)` to `s` approaching `Tstar`.
  have h_ineq : ∀ᶠ s in 𝓝[<] Tstar, 1 / (Z s) ^ 2 ≥ 1 / (Z t) ^ 2 - 2 * C * (s - t) := by
    filter_upwards [ Ioo_mem_nhdsLT ht ] with s hs using recip_sq_lower_lipschitz Z D C hpos hZ hineq t s hs.1.le;
  -- Pass to the limit with `le_of_tendsto_of_tendsto'` (or `le_of_tendsto`/`ge_of_tendsto`).
  have h_lim : 1 / (Z t) ^ 2 - 2 * C * (Tstar - t) ≤ 0 := by
    convert le_of_tendsto_of_tendsto ( Filter.Tendsto.sub ( tendsto_const_nhds ) ( tendsto_const_nhds.mul ( Filter.Tendsto.sub_const ( Filter.tendsto_id.mono_left inf_le_left ) t ) ) ) ( recip_sq_tendsto_zero_of_blowup Z Tstar hblow ) h_ineq using 1;
    exact mem_closure_iff_clusterPt.mp ( show Tstar ∈ closure ( Set.Iio Tstar ) by simp +decide [ closure_Iio ] );
  rw [ sub_nonpos, div_le_iff₀ ] at h_lim <;> nlinarith [ hpos t ]

end NavierStokes