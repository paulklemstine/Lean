/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quadratic Approximation Rates for Sobolev (W^{2,∞}) Functions

This file sharpens the linear universal-approximation rate `L/n` of
`MachineLearning.UniversalApproximation.QuantitativeBoundsCore`
(`quantitative_uat_core`) to a **quadratic** rate `M/n²` for functions whose
*derivative* is `M`-Lipschitz — i.e. functions in the Sobolev class `W^{2,∞}`
with second-derivative bound `M`.  The very same `2n`-neuron ramp-difference
network `reluInterpNet` is used; only the regularity of the target improves the
rate.

## Construction / idea

On the cell `[a,b] = [k/n,(k+1)/n]` (width `h = 1/n`) the network equals the
affine interpolant `p(x) = f(a) + S·(x-a)` where `S = (f b - f a)/h`
(`reluInterpNet_eq_on_cell`).  The error `e = f - p` satisfies `e(a) = 0` and
`e'(x) = f'(x) - S`.  By the mean value theorem `S = f'(c)` for some interior
`c`, so `|e'(x)| = |f'(x) - f'(c)| ≤ M·|x-c| ≤ M·h`.  Hence `e` is `(M·h)`-
Lipschitz on the cell, giving `|e(x)| = |e(x) - e(a)| ≤ M·h·(x-a) ≤ M·h² = M/n²`.

## Main results

* `sobolev_interp_error_cell` — cellwise quadratic error bound `M/n²`.
* `sobolev_quadratic_rate` — global quadratic rate on `[0,1]`.
* `sobolev_width_tradeoff` — width `2n = O(1/√ε)` suffices for accuracy `ε`,
  exponentially better than the `O(1/ε)` of the Lipschitz regime.

-- !-- Lab Notes -- !--
Hypothesis: the *same* `2n`-ramp interpolation network that achieves error `L/n`
  for `L`-Lipschitz targets should achieve `O(1/n²)` for targets with a Lipschitz
  derivative (W^{2,∞}), because piecewise-linear interpolation is second-order
  accurate on smooth functions.
Experiment: reduce to one cell, identify the network with the affine interpolant
  via `reluInterpNet_eq_on_cell`, and bound the interpolation remainder. The
  decisive step is the MVT identity `S = f'(c)` together with the Lipschitz bound
  on `f'`, which makes the remainder's derivative `O(h)` on the whole cell.
Analysis: the gain is genuinely quadratic — `M h²` versus `L h`. The proof needs
  no second derivative to *exist*; a Lipschitz first derivative (W^{2,∞}) is
  exactly the right hypothesis and is weaker than `C²`.
Critique: we record the simple constant `M` (i.e. `M h²`), not the sharp `M/8`
  (i.e. `M h²/8`); sharpness is left as a future direction. The hypothesis
  `HasDerivOn01` plus `LipOn01 f' M` is faithful to the Sobolev framing and the
  conclusion is a strict improvement over `quantitative_uat_core` for smooth `f`.
Synthesis: regularity, not architecture, drives the rate — depth/width fixed at
  `2n`, the exponent on `1/n` is governed by the smoothness class of the target.
-- !-- -- !--
-/
import Mathlib
import MachineLearning.UniversalApproximation.QuantitativeBoundsCore

namespace MachineLearning.UniversalApproximation

open Set

/-- `f'` is the derivative of `f` at every point of `[0,1]`. -/
def HasDerivOn01 (f f' : ℝ → ℝ) : Prop :=
  ∀ x ∈ Set.Icc (0 : ℝ) 1, HasDerivAt f (f' x) x

/-
**Cellwise quadratic error bound.** If `f` has derivative `f'` on `[0,1]`
and `f'` is `M`-Lipschitz there (the Sobolev `W^{2,∞}` condition), then on the
cell `[k/n,(k+1)/n]` the `2n`-ramp network approximates `f` with error at most
`M/n²`.
-/
lemma sobolev_interp_error_cell (f f' : ℝ → ℝ) (n k : ℕ) (M : ℝ)
    (hn : 0 < n) (hk : k < n) (hM : 0 ≤ M)
    (hderiv : HasDerivOn01 f f') (hlip : LipOn01 f' M)
    (x : ℝ) (hx : x ∈ Set.Icc (grid n k) (grid n (k + 1))) :
    |reluInterpNet f n x - f x| ≤ M / (n : ℝ) ^ 2 := by
  -- Step 1: Identify network with affine interpolant.
  set a := grid n k
  set b := grid n (k + 1)
  set h := b - a with hh
  set S := (f b - f a) / h with hS;
  -- Step 2: MVT.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo a b, f' c = (f b - f a) / (b - a) := by
    apply exists_hasDerivAt_eq_slope;
    · exact div_lt_div_iff_of_pos_right ( by positivity ) |>.2 ( by norm_num );
    · refine' continuousOn_of_forall_continuousAt fun x hx => _;
      refine' HasDerivAt.continuousAt ( hderiv x _ );
      simp +zetaDelta at *;
      exact ⟨ hx.1.trans' ( by exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ), hx.2.trans ( by rw [ grid ] ; rw [ div_le_iff₀ ( Nat.cast_pos.mpr hn ) ] ; norm_cast; linarith ) ⟩;
    · simp +zetaDelta at *;
      exact fun x hx₁ hx₂ => hderiv x ⟨ by linarith [ show 0 ≤ grid n k from by exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ], by linarith [ show grid n ( k + 1 ) ≤ 1 from by rw [ grid ] ; rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ] ⟩;
  -- Step 4: Lipschitz bound on error.
  have h_lip : ∀ y ∈ Set.Icc a b, |f y - (f a + S * (y - a)) - (f a - (f a + S * (a - a)))| ≤ M * h * |y - a| := by
    intros y hy
    have h_deriv : ∀ y ∈ Set.Icc a b, HasDerivWithinAt (fun y => f y - (f a + S * (y - a))) (f' y - S) (Set.Icc a b) y := by
      intro y hy;
      have := hderiv y ⟨ by
        exact le_trans ( by exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) hy.1, by
        exact hy.2.trans ( show grid n ( k + 1 ) ≤ 1 from by rw [ grid ] ; rw [ div_le_iff₀ ] <;> norm_cast ; linarith ) ⟩;
      convert HasDerivAt.hasDerivWithinAt ( this.sub ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id y |> HasDerivAt.sub <| hasDerivAt_const _ _ ) ) ) ) using 1 ; ring;
    have h_lip : ∀ y ∈ Set.Icc a b, |f' y - S| ≤ M * h := by
      intros y hy
      have h_lip : |f' y - f' c| ≤ M * |y - c| := by
        apply hlip;
        · simp +zetaDelta at *;
          exact ⟨ by linarith [ show 0 ≤ grid n k from by exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ], by linarith [ show grid n ( k + 1 ) ≤ 1 from by rw [ grid ] ; rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ] ⟩;
        · simp +zetaDelta at *;
          exact ⟨ by linarith [ show 0 ≤ grid n k from by exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ], by linarith [ show grid n ( k + 1 ) ≤ 1 from by rw [ grid ] ; rw [ div_le_iff₀ ( by positivity ) ] ; norm_cast; linarith ] ⟩;
      simp_all +decide;
      exact h_lip.trans ( mul_le_mul_of_nonneg_left ( abs_le.mpr ⟨ by linarith, by linarith ⟩ ) hM );
    have := @Convex.norm_image_sub_le_of_norm_hasDerivWithin_le;
    convert this ( fun x hx => h_deriv x hx ) ( fun x hx => h_lip x hx ) ( convex_Icc a b ) ( show a ∈ Set.Icc a b from ⟨ le_rfl, by linarith [ hy.1, hy.2 ] ⟩ ) ( show y ∈ Set.Icc a b from hy ) using 1;
  -- Step 5: Conclude.
  have h_final : |f x - (f a + S * (x - a))| ≤ M * h ^ 2 := by
    convert h_lip x hx |> le_trans <| mul_le_mul_of_nonneg_left ( show |x - a| ≤ h by rw [ abs_of_nonneg ] <;> linarith [ hx.1, hx.2 ] ) ( show 0 ≤ M * h by exact mul_nonneg hM <| sub_nonneg.mpr <| grid_mono n <| by linarith ) using 1 ; ring;
    ring;
  -- By definition of `reluInterpNet`, we have `reluInterpNet f n x = f a + S * (x - a)`.
  have h_reluInterpNet : reluInterpNet f n x = f a + S * (x - a) := by
    convert reluInterpNet_eq_on_cell f n k hn hk x hx using 1;
    simp +zetaDelta at *;
    unfold cellSlope; rw [ grid_succ_sub ] ; ring; norm_num [ hn.ne' ] ;
  convert h_final using 1 <;> norm_num [ h_reluInterpNet ];
  · rw [ abs_sub_comm ];
  · simp +zetaDelta at *;
    unfold grid; ring;
    push_cast; ring;

/-- **Quadratic universal approximation rate (global form) for `W^{2,∞}`
targets.** If `f` has derivative `f'` on `[0,1]` and `f'` is `M`-Lipschitz, the
`2n`-ramp ReLU network approximates `f` uniformly on `[0,1]` with error `M/n²`. -/
theorem sobolev_quadratic_rate (f f' : ℝ → ℝ) (n : ℕ) (M : ℝ)
    (hn : 0 < n) (hM : 0 ≤ M)
    (hderiv : HasDerivOn01 f f') (hlip : LipOn01 f' M)
    (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    |reluInterpNet f n x - f x| ≤ M / (n : ℝ) ^ 2 := by
  obtain ⟨k, hk, hxk⟩ := exists_cell n hn x hx
  exact sobolev_interp_error_cell f f' n k M hn hk hM hderiv hlip x hxk

/-- **Width/accuracy tradeoff for smooth targets.** To reach uniform error `ε`
on a `W^{2,∞}` target it suffices that `M ≤ ε·n²`, i.e. `n ≥ √(M/ε)` and width
`2n = O(1/√ε)` — exponentially fewer neurons than the `O(1/ε)` required in the
merely-Lipschitz regime. -/
theorem sobolev_width_tradeoff (f f' : ℝ → ℝ) (n : ℕ) (M ε : ℝ)
    (hn : 0 < n) (hM : 0 ≤ M) (hMε : M ≤ ε * (n : ℝ) ^ 2)
    (hderiv : HasDerivOn01 f f') (hlip : LipOn01 f' M)
    (x : ℝ) (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    |reluInterpNet f n x - f x| ≤ ε := by
  have hbound := sobolev_quadratic_rate f f' n M hn hM hderiv hlip x hx
  have hnpos : (0 : ℝ) < (n : ℝ) ^ 2 := by positivity
  have hle : M / (n : ℝ) ^ 2 ≤ ε := by
    rw [div_le_iff₀ hnpos]; linarith [hMε]
  linarith [hbound, hle]

end MachineLearning.UniversalApproximation