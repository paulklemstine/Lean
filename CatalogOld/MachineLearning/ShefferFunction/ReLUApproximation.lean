/-
# ReLU as a Limit of Softplus

The parametric softplus σ_β(x) = σ(βx)/β converges pointwise to ReLU(x) = max(0,x)
as β → ∞. This establishes that ReLU is in the closure of the Sheffer algebra,
even though it is not itself a Sheffer function (being non-differentiable).

## Main Results

- `softplus_div_tendsto_relu_pos`: For x > 0, σ(βx)/β → x as β → ∞
- `softplus_div_tendsto_relu_neg`: For x < 0, σ(βx)/β → 0 as β → ∞  
- `softplus_ge_relu`: σ(x) ≥ max(0, x) for all x (softplus dominates ReLU)
-/

import Mathlib

open Real Filter

namespace ShefferFunction

noncomputable def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-
Softplus dominates the ReLU function: σ(x) ≥ max(0, x) for all x.
-/
theorem softplus_ge_relu (x : ℝ) : softplus x ≥ max 0 x := by
  unfold softplus;
  cases max_cases ( 0 : ℝ ) x <;> simp +decide [ * ];
  · exact Real.log_nonneg ( by linarith [ Real.exp_pos x ] );
  · rw [ Real.le_log_iff_exp_le ] <;> linarith [ Real.exp_pos x ]

/-
For positive x, σ(βx)/β → x as β → ∞.
-/
theorem softplus_div_tendsto_relu_pos (x : ℝ) (hx : 0 < x) :
    Tendsto (fun β => softplus (β * x) / β) atTop (nhds x) := by
  unfold softplus;
  -- Rewrite $\log(1 + e^{\beta x})$ as $\beta x + \log(1 + e^{-\beta x})$.
  suffices h_rewrite : Filter.Tendsto (fun β => (β * x + Real.log (1 + Real.exp (-β * x))) / β) Filter.atTop (nhds x) by
    refine h_rewrite.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with β hβ; rw [ show 1 + Real.exp ( β * x ) = ( 1 + Real.exp ( -β * x ) ) * Real.exp ( β * x ) by rw [ add_mul, ← Real.exp_add ] ; norm_num ; ring ] ; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring );
  norm_num [ add_div ];
  simpa using Filter.Tendsto.add ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with β hβ; rw [ mul_div_cancel_left₀ _ hβ ] ) ) ( Filter.Tendsto.div_atTop ( Filter.Tendsto.log ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot.comp <| Filter.tendsto_neg_atTop_atBot.comp <| Filter.tendsto_id.atTop_mul_const hx ) ) <| by positivity ) Filter.tendsto_id )

/-
For negative x, σ(βx)/β → 0 as β → ∞.
-/
theorem softplus_div_tendsto_relu_neg (x : ℝ) (hx : x < 0) :
    Tendsto (fun β => softplus (β * x) / β) atTop (nhds 0) := by
  -- For x < 0, as β → ∞, βx → -∞, so softplus(βx) = log(1+e^{βx}) → log(1) = 0. More precisely 0 < softplus(βx) ≤ e^{βx} (since log(1+t) ≤ t for t > 0).
  have h_bound : ∀ β : ℝ, β > 0 → 0 ≤ softplus (β * x) / β ∧ softplus (β * x) / β ≤ Real.exp (β * x) / β := by
    intros β hβ_pos
    have h_softplus_le : softplus (β * x) ≤ Real.exp (β * x) := by
      exact le_trans ( Real.log_le_sub_one_of_pos ( by positivity ) ) ( by linarith );
    exact ⟨ div_nonneg ( Real.log_nonneg ( by linarith [ Real.exp_pos ( β * x ) ] ) ) hβ_pos.le, div_le_div_of_nonneg_right h_softplus_le hβ_pos.le ⟩;
  -- We need to show that the upper bound tends to 0 as β tends to infinity.
  have h_upper_bound : Filter.Tendsto (fun β => Real.exp (β * x) / β) Filter.atTop (nhds 0) := by
    simpa using Filter.Tendsto.div_atTop ( Real.tendsto_exp_atBot.comp <| Filter.tendsto_id.atTop_mul_const_of_neg hx ) Filter.tendsto_id;
  exact squeeze_zero_norm' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with β hβ using by rw [ Real.norm_of_nonneg ( h_bound β hβ |>.1 ) ] ; exact h_bound β hβ |>.2 ) h_upper_bound

/-
Softplus is bounded above by x + log 2.
-/
theorem softplus_le_add_log2 (x : ℝ) (hx : 0 ≤ x) :
    softplus x ≤ x + Real.log 2 := by
  unfold softplus;
  rw [ ← Real.log_exp ( x + Real.log 2 ), Real.log_le_log_iff ] <;> first | positivity | rw [ Real.exp_add, Real.exp_log ] <;> nlinarith [ Real.add_one_le_exp x ]

/-
Softplus minus identity tends to 0 as x → ∞.
-/
theorem softplus_sub_id_tendsto :
    Tendsto (fun x => softplus x - x) atTop (nhds 0) := by
  unfold softplus;
  -- We'll use the fact that $log(1 + e^x) - x$ simplifies to $log(1 + e^{-x})$.
  suffices h_simp : Filter.Tendsto (fun x => Real.log (1 + Real.exp (-x))) Filter.atTop (nhds 0) by
    refine h_simp.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with x hx using by rw [ show ( 1 + Real.exp x ) = ( 1 + Real.exp ( -x ) ) * Real.exp x by nlinarith [ Real.exp_pos x, Real.exp_pos ( -x ), Real.exp_neg x, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos x ) ) ], Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring );
  convert Filter.Tendsto.log ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot.comp Filter.tendsto_neg_atTop_atBot ) ) _ using 2 <;> norm_num

end ShefferFunction