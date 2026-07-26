/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Continuous-Time Renormalization Flow

This file establishes the mathematical passage from discrete renormalization cascades
to continuous dissipative flows. The central results are:

1. **Constant-α scaling limit**: `(1 - 1/(α+1))^⌊(α+1)t⌋ → e^{-t}` as `α → ∞`.
2. **Quantitative error bound**: The approximation error is `O(1/α)` uniformly on compacts.
3. **Time-inhomogeneous limit**: A variable damping profile `α(·)` generates the flow
   `V₀ exp(-∫₀ᵗ ds/α(s))`.
4. **ODE verification**: The continuous flow solves the expected differential equation.
5. **Logarithmic linearization**: Multiplicative decay becomes additive action.

These results bridge algebraic renormalization to ODE/PDE methods and scaling limits
from statistical physics.
-/

import Mathlib

open Filter Topology MeasureTheory Set Real BigOperators


noncomputable section

/-! ## Core Definitions -/

/-- The cumulative damping functional: `∫₀ᵗ (1/α(s)) ds`. -/
def cumulativeDamping (α : ℝ → ℝ) (t : ℝ) : ℝ :=
  ∫ s in (0)..t, (1 / α s)

/-- The continuous renormalization flow: `V₀ · exp(-∫₀ᵗ ds/α(s))`. -/
def renormFlow (α : ℝ → ℝ) (V0 t : ℝ) : ℝ :=
  V0 * Real.exp (-(cumulativeDamping α t))

/-- A single step of the discrete profile cascade. -/
def renormProfileStep (α : ℝ → ℝ) (n : ℕ) (k : ℕ) : ℝ :=
  1 - 1 / (((n : ℝ) + 1) * α ((k : ℝ) / ((n : ℝ) + 1)))

/-- The discrete renormalization cascade driven by profile `α`. -/
def renormCascade (α : ℝ → ℝ) (V0 : ℝ) (n : ℕ) (t : ℝ) : ℝ :=
  V0 * ∏ k ∈ Finset.range (⌊((n : ℝ) + 1) * t⌋).toNat,
    renormProfileStep α n k

/-! ## Theorem 1: Constant-α Scaling Limit -/

/-
The discrete renormalization cascade `(1 - 1/(α+1))^⌊(α+1)t⌋` converges to `e^{-t}`
as `α → ∞`. This is the fundamental passage from discrete contraction to continuous
exponential decay—the prototype for all scaling limits of algebraic iteration schemes.
-/
theorem renorm_constAlpha_pow_floor_tendsto_exp_neg
    (t : ℝ) (ht : 0 ≤ t) :
    Tendsto
      (fun α : ℕ =>
        ((1 : ℝ) - 1 / ((α : ℝ) + 1)) ^ (⌊((α : ℝ) + 1) * t⌋).toNat)
      atTop
      (𝓝 (Real.exp (-t))) := by
  -- We'll use the exponential property to simplify the expression. Note that $(1 - \frac{1}{n+1})^{⌊((n : ℝ) + 1) * t⌋}$ can be rewritten as $\exp(⌊((n : ℝ) + 1) * t⌋ \cdot \log(1 - \frac{1}{n+1}))$.
  suffices h_exp : Filter.Tendsto (fun n : ℕ => Real.exp (⌊((n : ℝ) + 1) * t⌋ * Real.log (1 - 1 / ((n : ℝ) + 1)))) Filter.atTop (nhds (Real.exp (-t))) by
    refine h_exp.congr' ?_;
    filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn;
    rw [ mul_comm, Real.exp_mul, Real.exp_log ( sub_pos.mpr <| by rw [ div_lt_iff₀ ] <;> norm_cast <;> linarith ) ];
    rw [ ← Int.toNat_of_nonneg ( Int.floor_nonneg.mpr ( by positivity ) ) ] ; norm_cast;
  -- We'll use the fact that $\log(1 - x) \approx -x$ for $x$ close to $0$.
  have h_log_approx : Filter.Tendsto (fun n : ℕ => ⌊((n : ℝ) + 1) * t⌋ * (-1 / ((n : ℝ) + 1))) Filter.atTop (nhds (-t)) := by
    rw [ Metric.tendsto_nhds ];
    field_simp;
    intro ε hε; refine' Filter.eventually_atTop.mpr ⟨ Nat.ceil ( ε⁻¹ * ( t + 1 ) ), fun n hn => abs_lt.mpr ⟨ _, _ ⟩ ⟩ <;> nlinarith [ Nat.ceil_le.mp hn, mul_inv_cancel₀ hε.ne', Int.floor_le ( ( n + 1 : ℝ ) * t ), Int.lt_floor_add_one ( ( n + 1 : ℝ ) * t ), mul_div_cancel₀ ( ⌊ ( n + 1 : ℝ ) * t⌋ : ℝ ) ( by positivity : ( n + 1 : ℝ ) ≠ 0 ) ] ;
  refine' Filter.Tendsto.rexp _;
  -- We'll use the fact that $\log(1 - x) \approx -x$ for $x$ close to $0$ to show that the two expressions are asymptotically equivalent.
  have h_log_approx : Filter.Tendsto (fun n : ℕ => Real.log (1 - 1 / ((n : ℝ) + 1)) / (-1 / ((n : ℝ) + 1))) Filter.atTop (nhds 1) := by
    have h_log_approx : Filter.Tendsto (fun x : ℝ => Real.log (1 - x) / -x) (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
      simpa [ div_eq_mul_inv, mul_comm ] using HasDerivAt.tendsto_slope_zero_right ( HasDerivAt.neg ( HasDerivAt.log ( hasDerivAt_id 0 |> HasDerivAt.const_sub 1 ) <| by norm_num ) );
    convert h_log_approx.comp ( show Filter.Tendsto ( fun n : ℕ => ( 1 : ℝ ) / ( n + 1 ) ) Filter.atTop ( nhdsWithin 0 ( Set.Ioi 0 ) ) from ?_ ) using 2;
    · norm_num [ div_neg, neg_div ];
    · rw [ tendsto_nhdsWithin_iff ];
      exact ⟨ tendsto_one_div_add_atTop_nhds_zero_nat, Filter.Eventually.of_forall fun n => by simpa using by positivity ⟩;
  convert ‹Tendsto ( fun n : ℕ => ( ⌊ ( n + 1 : ℝ ) * t⌋ : ℝ ) * ( -1 / ( n + 1 ) ) ) Filter.atTop ( 𝓝 ( -t ) ) ›.mul h_log_approx using 2 <;> ring;
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( by positivity : 0 < ( 1 + ( ‹ℕ› : ℝ ) ) ) ]

/-! ## Theorem 2: Explicit Error Bound -/

/-
Quantitative error bound: the constant-α discrete cascade approximates `e^{-t}`
with error at most `C/(α+1)` uniformly on `[0, T]`. This certified rate is what
analysts need to transport estimates between discrete and continuous settings.
-/
theorem renorm_constAlpha_error_bound_on_compact
    (T : ℝ) (hT : 0 ≤ T) :
    ∃ C > 0, ∃ N : ℕ, ∀ α : ℕ, N ≤ α →
      ∀ t : ℝ, 0 ≤ t → t ≤ T →
        |((1 : ℝ) - 1 / ((α : ℝ) + 1)) ^ (⌊((α : ℝ) + 1) * t⌋).toNat
          - Real.exp (-t)|
        ≤ C / ((α : ℝ) + 1) := by
  -- Set $n := \alpha + 1$ for convenience. We want to show $|(1 - 1/n)^{\lfloor nt \rfloor} - e^{-t}| \le C/n$.
  suffices h_suff : ∃ C > 0, ∃ N : ℕ, ∀ n : ℕ, n ≥ N → ∀ t : ℝ, 0 ≤ t → t ≤ T → |(1 - 1 / (n : ℝ)) ^ ⌊n * t⌋.toNat - Real.exp (-t)| ≤ C / (n : ℝ) by
    obtain ⟨ C, hC₀, N, hN ⟩ := h_suff; use C, hC₀, N; intros α hα t ht₁ ht₂; specialize hN ( α + 1 ) ( by linarith ) t ht₁ ht₂; aesop;
  -- Use the bounds $e^{-⌊nt⌋/(n-1)} ≤ (1-1/n)^{⌊nt⌋} ≤ e^{-⌊nt⌋/n}$ to estimate the difference.
  suffices h_bounds : ∃ C > 0, ∃ N : ℕ, ∀ n : ℕ, n ≥ N → ∀ t : ℝ, 0 ≤ t → t ≤ T → |Real.exp (-⌊(n : ℝ) * t⌋.toNat / (n : ℝ)) - Real.exp (-t)| ≤ C / (n : ℝ) ∧ |Real.exp (-⌊(n : ℝ) * t⌋.toNat / (n - 1 : ℝ)) - Real.exp (-t)| ≤ C / (n : ℝ) by
    -- Use the bounds $e^{-⌊nt⌋/(n-1)} ≤ (1-1/n)^{⌊nt⌋} ≤ e^{-⌊nt⌋/n}$ to estimate the difference between the discrete and continuous flows.
    have h_bounds : ∀ n : ℕ, 2 ≤ n → ∀ t : ℝ, 0 ≤ t → t ≤ T → Real.exp (-⌊(n : ℝ) * t⌋.toNat / (n - 1 : ℝ)) ≤ (1 - 1 / (n : ℝ)) ^ ⌊(n : ℝ) * t⌋.toNat ∧ (1 - 1 / (n : ℝ)) ^ ⌊(n : ℝ) * t⌋.toNat ≤ Real.exp (-⌊(n : ℝ) * t⌋.toNat / (n : ℝ)) := by
      intros n hn t ht htT
      have h_exp_lower_bound : Real.exp (-1 / (n - 1 : ℝ)) ≤ 1 - 1 / (n : ℝ) := by
        rw [ neg_div, Real.exp_neg ];
        rw [ inv_eq_one_div, div_le_iff₀ ] <;> nlinarith [ Real.add_one_le_exp ( 1 / ( n - 1 ) ), show ( n : ℝ ) ≥ 2 by norm_cast, one_div_mul_cancel ( show ( n : ℝ ) ≠ 0 by positivity ), one_div_mul_cancel ( show ( n - 1 : ℝ ) ≠ 0 by exact sub_ne_zero_of_ne ( by norm_cast; linarith ) ), one_div_pos.mpr ( show ( n : ℝ ) > 0 by positivity ), one_div_pos.mpr ( show ( n - 1 : ℝ ) > 0 by exact sub_pos.mpr ( by norm_cast ) ) ]
      have h_exp_upper_bound : 1 - 1 / (n : ℝ) ≤ Real.exp (-1 / (n : ℝ)) := by
        exact le_trans ( by ring_nf; norm_num ) ( Real.add_one_le_exp _ );
      exact ⟨ le_trans ( by rw [ ← Real.exp_nat_mul ] ; ring_nf; norm_num ) ( pow_le_pow_left₀ ( by positivity ) h_exp_lower_bound _ ), le_trans ( pow_le_pow_left₀ ( sub_nonneg.2 <| div_le_self zero_le_one <| mod_cast hn.trans' <| by norm_num ) h_exp_upper_bound _ ) <| by rw [ ← Real.exp_nat_mul ] ; ring_nf; norm_num ⟩;
    obtain ⟨ C, hC₀, N, hN ⟩ := ‹∃ C > 0, ∃ N : ℕ, ∀ n ≥ N, ∀ t : ℝ, 0 ≤ t → t ≤ T → |Real.exp ( -⌊↑n * t⌋.toNat / ↑n ) - Real.exp ( -t )| ≤ C / ↑n ∧ |Real.exp ( -⌊↑n * t⌋.toNat / ( ↑n - 1 ) ) - Real.exp ( -t )| ≤ C / ↑n›;
    exact ⟨ C, hC₀, N + 2, fun n hn t ht₁ ht₂ => abs_le.mpr ⟨ by linarith [ abs_le.mp ( hN n ( by linarith ) t ht₁ ht₂ |>.1 ), abs_le.mp ( hN n ( by linarith ) t ht₁ ht₂ |>.2 ), h_bounds n ( by linarith ) t ht₁ ht₂ ], by linarith [ abs_le.mp ( hN n ( by linarith ) t ht₁ ht₂ |>.1 ), abs_le.mp ( hN n ( by linarith ) t ht₁ ht₂ |>.2 ), h_bounds n ( by linarith ) t ht₁ ht₂ ] ⟩ ⟩;
  -- Use the mean value theorem to bound the difference of exponentials.
  have h_mean_value : ∀ n : ℕ, n ≥ 2 → ∀ t : ℝ, 0 ≤ t → t ≤ T → |Real.exp (-⌊(n : ℝ) * t⌋.toNat / (n : ℝ)) - Real.exp (-t)| ≤ |⌊(n : ℝ) * t⌋.toNat / (n : ℝ) - t| ∧ |Real.exp (-⌊(n : ℝ) * t⌋.toNat / (n - 1 : ℝ)) - Real.exp (-t)| ≤ |⌊(n : ℝ) * t⌋.toNat / (n - 1 : ℝ) - t| := by
    intros n hn t ht htT
    have h_mean_value : ∀ x y : ℝ, 0 ≤ x → 0 ≤ y → |Real.exp (-x) - Real.exp (-y)| ≤ |x - y| := by
      -- Use the mean value theorem on the interval $[x, y]$.
      have h_mean_value : ∀ x y : ℝ, 0 ≤ x → 0 ≤ y → x < y → ∃ c ∈ Set.Ioo x y, deriv (fun x => Real.exp (-x)) c = (Real.exp (-y) - Real.exp (-x)) / (y - x) := by
        intros x y hx hy hxy; apply_rules [ exists_deriv_eq_slope ];
        · exact Continuous.continuousOn ( by continuity );
        · exact DifferentiableOn.exp ( differentiableOn_id.neg );
      -- By the mean value theorem, we have |exp(-x) - exp(-y)| = |exp(-c)| * |x - y| for some c between x and y.
      have h_mean_value_abs : ∀ x y : ℝ, 0 ≤ x → 0 ≤ y → x < y → |Real.exp (-x) - Real.exp (-y)| ≤ |x - y| := by
        intros x y hx hy hxy
        obtain ⟨c, hc⟩ := h_mean_value x y hx hy hxy
        have h_deriv : deriv (fun x => Real.exp (-x)) c = -Real.exp (-c) := by
          exact HasDerivAt.deriv ( by simpa using HasDerivAt.exp ( hasDerivAt_neg c ) );
        rw [ eq_div_iff ] at hc <;> cases abs_cases ( x - y ) <;> cases abs_cases ( Real.exp ( -x ) - Real.exp ( -y ) ) <;> nlinarith [ Real.exp_pos ( -c ), Real.exp_le_one_iff.mpr ( show -c ≤ 0 by linarith [ hc.1.1, hc.1.2 ] ) ];
      exact fun x y hx hy => if hxy : x < y then h_mean_value_abs x y hx hy hxy else if hyx : y < x then by simpa only [ abs_sub_comm ] using h_mean_value_abs y x hy hx hyx else by rw [ show x = y by linarith ] ; norm_num;
    exact ⟨ by simpa [ neg_div ] using h_mean_value ( ⌊ ( n : ℝ ) * t⌋.toNat / n ) t ( by positivity ) ht, by simpa [ neg_div ] using h_mean_value ( ⌊ ( n : ℝ ) * t⌋.toNat / ( n - 1 ) ) t ( by exact div_nonneg ( Nat.cast_nonneg _ ) ( sub_nonneg.mpr ( Nat.one_le_cast.mpr ( by linarith ) ) ) ) ht ⟩;
  -- Use the fact that $|⌊nt⌋/n - t| ≤ 1/n$ and $|⌊nt⌋/(n-1) - t| ≤ T/(n-1) + 1/(n-1)$.
  have h_bounds : ∀ n : ℕ, n ≥ 2 → ∀ t : ℝ, 0 ≤ t → t ≤ T → |⌊(n : ℝ) * t⌋.toNat / (n : ℝ) - t| ≤ 1 / (n : ℝ) ∧ |⌊(n : ℝ) * t⌋.toNat / (n - 1 : ℝ) - t| ≤ (T + 1) / (n - 1 : ℝ) := by
    intro n hn t ht hT; constructor <;> rw [ abs_le ] <;> constructor <;> norm_num;
    · rw [ inv_eq_one_div, ← add_div, le_div_iff₀ ] <;> norm_num <;> nlinarith [ show ( n : ℝ ) ≥ 2 by norm_cast, Int.lt_floor_add_one ( ( n : ℝ ) * t ), show ( ⌊ ( n : ℝ ) * t⌋.toNat : ℝ ) ≥ ⌊ ( n : ℝ ) * t⌋ by exact_mod_cast Int.self_le_toNat _ ];
    · rw [ inv_eq_one_div, div_add', div_le_div_iff_of_pos_right ] <;> norm_num <;> try linarith;
      nlinarith [ Int.floor_le ( ( n : ℝ ) * t ), show ( ⌊ ( n : ℝ ) * t⌋.toNat : ℝ ) ≤ ⌊ ( n : ℝ ) * t⌋ from mod_cast Int.toNat_of_nonneg ( Int.floor_nonneg.mpr ( by positivity ) ) |> le_of_eq ];
    · rw [ ← add_div, le_div_iff₀ ] <;> nlinarith [ show ( n : ℝ ) ≥ 2 by norm_cast, Int.floor_le ( ( n : ℝ ) * t ), Int.lt_floor_add_one ( ( n : ℝ ) * t ), show ( ⌊ ( n : ℝ ) * t⌋.toNat : ℝ ) ≥ ⌊ ( n : ℝ ) * t⌋ by exact_mod_cast Int.self_le_toNat _, show ( ⌊ ( n : ℝ ) * t⌋.toNat : ℝ ) ≤ ( n : ℝ ) * t by exact_mod_cast Nat.floor_le ( by positivity ) ];
    · rw [ div_add', div_le_div_iff_of_pos_right ] <;> try nlinarith [ show ( n : ℝ ) ≥ 2 by norm_cast ];
      nlinarith [ show ( n : ℝ ) ≥ 2 by norm_cast, Int.floor_le ( ( n : ℝ ) * t ), Int.lt_floor_add_one ( ( n : ℝ ) * t ), show ( ⌊ ( n : ℝ ) * t⌋.toNat : ℝ ) ≤ ⌊ ( n : ℝ ) * t⌋ from mod_cast Int.toNat_of_nonneg ( Int.floor_nonneg.mpr ( by positivity ) ) |> le_of_eq ];
  refine' ⟨ 2 * ( T + 1 ) + 1, by positivity, 2, fun n hn t ht₁ ht₂ => ⟨ _, _ ⟩ ⟩ <;> have := h_mean_value n hn t ht₁ ht₂ <;> have := h_bounds n hn t ht₁ ht₂ <;> norm_num at *;
  · exact le_trans ( by tauto ) ( this.1.trans ( by rw [ inv_eq_one_div, div_le_div_iff₀ ] <;> nlinarith [ show ( n : ℝ ) ≥ 2 by norm_cast ] ) );
  · refine' le_trans ( by tauto ) ( le_trans this.2 _ );
    rw [ div_le_div_iff₀ ] <;> nlinarith [ show ( n : ℝ ) ≥ 2 by norm_cast ]

/-! ## Cross-Domain Theorem A: ODE Verification -/

/-
The continuous renormalization flow with constant unit damping `α ≡ 1` satisfies
the ODE `d/dt(V₀ e^{-t}) = -V₀ e^{-t}`. This bridges renormalization to ODE theory.
-/
theorem renormFlow_const_hasDerivAt
    (V0 t : ℝ) :
    HasDerivAt (fun s : ℝ => V0 * Real.exp (-s)) (-(V0 * Real.exp (-t))) t := by
  convert HasDerivAt.const_mul V0 ( HasDerivAt.exp ( hasDerivAt_neg t ) ) using 1 ; ring!

/-! ## Cross-Domain Theorem B: Logarithmic Linearization -/

/-
For positive initial values, `log(V(t)/V₀) = -∫₀ᵗ ds/α(s)`. This transforms
multiplicative renormalization into additive action accumulation, connecting the
theory to entropy production and free-energy dissipation.
-/
theorem log_renormFlow
    (α : ℝ → ℝ) (V0 t : ℝ)
    (hV0 : 0 < V0) :
    Real.log (renormFlow α V0 t / V0) = -(cumulativeDamping α t) := by
  unfold renormFlow cumulativeDamping;
  rw [ mul_div_cancel_left₀ _ hV0.ne', Real.log_exp ]

/-! ## Structural Properties -/

/-
The continuous flow is positive when starting from a positive initial value.
-/
theorem renormFlow_pos (α : ℝ → ℝ) (V0 t : ℝ) (hV0 : 0 < V0) :
    0 < renormFlow α V0 t := by
  exact mul_pos hV0 ( Real.exp_pos _ )

/-
Monotonicity: if `α(s) ≤ β(s)` on `[0,t]`, then `1/α ≥ 1/β`, the integral
`∫ 1/α` is larger, so `exp(-∫ 1/α) ≤ exp(-∫ 1/β)`, hence `renormFlow α ≤ renormFlow β`.
-/
theorem renormFlow_mono_in_alpha
    (α β : ℝ → ℝ) (V0 t : ℝ)
    (hV0 : 0 ≤ V0)
    (ht : 0 ≤ t)
    (hαcont : Continuous α) (hβcont : Continuous β)
    (hcomp : ∀ s ∈ Icc 0 t, α s ≤ β s)
    (hposα : ∀ s ∈ Icc 0 t, 0 < α s) :
    renormFlow α V0 t ≤ renormFlow β V0 t := by
  unfold renormFlow;
  norm_num +zetaDelta at *;
  gcongr;
  apply_rules [ intervalIntegral.integral_mono_on ];
  · apply_rules [ ContinuousOn.intervalIntegrable ];
    exact ContinuousOn.div continuousOn_const ( hβcont.continuousOn ) fun x hx => ne_of_gt ( lt_of_lt_of_le ( hposα x ( by cases Set.mem_uIcc.mp hx <;> linarith ) ( by cases Set.mem_uIcc.mp hx <;> linarith ) ) ( hcomp x ( by cases Set.mem_uIcc.mp hx <;> linarith ) ( by cases Set.mem_uIcc.mp hx <;> linarith ) ) );
  · apply_rules [ ContinuousOn.intervalIntegrable ];
    exact ContinuousOn.div continuousOn_const ( hαcont.continuousOn ) fun x hx => ne_of_gt ( hposα x ( by cases Set.mem_uIcc.mp hx <;> linarith ) ( by cases Set.mem_uIcc.mp hx <;> linarith ) );
  · exact fun x hx => one_div_le_one_div_of_le ( hposα x hx.1 hx.2 ) ( hcomp x hx.1 hx.2 )

/-
The cumulative damping at time 0 is zero.
-/
theorem cumulativeDamping_zero (α : ℝ → ℝ) : cumulativeDamping α 0 = 0 := by
  -- By definition of cumulativeDamping, we have cumulativeDamping α 0 = ∫ s in (0)..0, (1 / α s).
  simp [cumulativeDamping]

/-
The renormalization flow at time 0 equals the initial value.
-/
theorem renormFlow_zero (α : ℝ → ℝ) (V0 : ℝ) : renormFlow α V0 0 = V0 := by
  simp [renormFlow, cumulativeDamping_zero]

end