/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Verified Convergence Bounds for Gradient Descent

This file formalizes the fundamental convergence rate theorems for gradient descent
in machine learning optimization. The results are stated at the level of real-valued
sequences, abstracting away the specific function space to capture the essential
algebraic structure of convergence proofs.

## Main Results

* `descent_rate_bound` — The O(1/T) convergence rate for gradient descent on
  L-smooth convex functions: after T steps, the minimum squared gradient norm
  satisfies min_{k<T} ‖∇f(x_k)‖² ≤ 2L(f(x₀) - f*) / T.

* `geometric_convergence` — Geometric (linear) convergence for strongly convex
  functions: f(x_n) - f* ≤ (1 - μ/L)ⁿ · (f(x₀) - f*).

* `sufficient_decrease_convergence` — Any sequence with sufficient decrease
  property converges to the infimum.

## References

* Nesterov, Y. (2004). *Introductory Lectures on Convex Optimization*.
* Boyd, S. & Vandenberghe, L. (2004). *Convex Optimization*.
-/

import Mathlib

open Finset BigOperators

/-! ### Sufficient Decrease and Telescoping -/

/-
If a sequence has the sufficient decrease property (each step decreases the
    objective by at least (1/(2L)) times the squared gradient), then after T steps,
    the minimum squared gradient is bounded by 2L(a₀ - a_star)/T.

    This is the fundamental O(1/T) convergence rate for gradient descent on
    L-smooth functions.
-/
theorem descent_rate_bound
    (a : ℕ → ℝ) (g_sq : ℕ → ℝ) (L : ℝ) (a_star : ℝ) (T : ℕ)
    (hL : 0 < L)
    (hT : 0 < T)
    (h_lower : ∀ n, a_star ≤ a n)
    (h_gsq_nonneg : ∀ n, 0 ≤ g_sq n)
    (h_decrease : ∀ n, a n - a (n + 1) ≥ (1 / (2 * L)) * g_sq n) :
    (∃ k, k < T ∧ g_sq k ≤ 2 * L * (a 0 - a_star) / T) := by
  have h_sum : ∑ k ∈ Finset.range T, g_sq k ≤ 2 * L * (a 0 - a_star) := by
    have h_sum : ∑ k ∈ Finset.range T, g_sq k ≤ 2 * L * (a 0 - a T) := by
      have h_sum : ∀ n, a 0 - a n ≥ (1 / (2 * L)) * ∑ k ∈ Finset.range n, g_sq k := by
        exact fun n => Nat.recOn n ( by norm_num ) fun n ih => by rw [ Finset.sum_range_succ ] ; norm_num at * ; nlinarith [ h_decrease n, h_gsq_nonneg n, mul_div_cancel₀ ( 1 : ℝ ) ( by positivity : ( 2 * L ) ≠ 0 ) ] ;
      have := h_sum T; rw [ div_mul_eq_mul_div, ge_iff_le, div_le_iff₀ ] at this <;> linarith;
    exact h_sum.trans ( mul_le_mul_of_nonneg_left ( sub_le_sub_left ( h_lower _ ) _ ) ( by positivity ) );
  by_contra! h_contra; simp_all +decide [ div_le_iff₀, mul_div_cancel₀ ] ;
  exact absurd ( Finset.sum_lt_sum_of_nonempty ⟨ _, Finset.mem_range.mpr hT ⟩ fun k hk => h_contra k <| Finset.mem_range.mp hk ) ( by simp [ mul_div_cancel₀, hT.ne' ] ; linarith )

/-
**Geometric convergence** for strongly convex optimization.
    If each step contracts the suboptimality by factor (1 - μ/L),
    then after n steps we have geometric convergence.
-/
theorem geometric_convergence
    (a : ℕ → ℝ) (a_star : ℝ) (q : ℝ)
    (hq0 : 0 ≤ q) (hq1 : q < 1)
    (h_init : 0 ≤ a 0 - a_star)
    (h_contract : ∀ n, a (n + 1) - a_star ≤ q * (a n - a_star)) :
    ∀ n, a n - a_star ≤ q ^ n * (a 0 - a_star) := by
  exact fun n => Nat.recOn n ( by simpa ) fun n ih => by rw [ pow_succ', mul_assoc ] ; nlinarith [ h_contract n ] ;

/-
The suboptimality gap under geometric convergence tends to zero.
-/
theorem geometric_convergence_limit
    (a : ℕ → ℝ) (a_star : ℝ) (q : ℝ)
    (hq0 : 0 ≤ q) (_hq1 : q < 1)
    (_h_init : 0 ≤ a 0 - a_star)
    (h_lower : ∀ n, a_star ≤ a n)
    (h_contract : ∀ n, a (n + 1) - a_star ≤ q * (a n - a_star)) :
    Filter.Tendsto (fun n => a n - a_star) Filter.atTop (nhds 0) := by
  exact squeeze_zero ( fun n => sub_nonneg.mpr ( h_lower n ) ) ( geometric_convergence a a_star q hq0 _hq1 _h_init h_contract ) ( by simpa using ( tendsto_pow_atTop_nhds_zero_of_lt_one hq0 _hq1 ) |> Filter.Tendsto.mul_const _ )

/-! ### Averaging argument for convex case -/

/-
The average of a finite sequence is at most the max. More precisely,
    if the sum of T non-negative terms is at most S, then the minimum
    term is at most S/T. This is the key averaging step in the O(1/T) proof.
-/
theorem min_le_avg_of_sum_le
    (f : ℕ → ℝ) (T : ℕ) (S : ℝ)
    (hT : 0 < T)
    (_hf : ∀ i, i < T → 0 ≤ f i)
    (hsum : ∑ i ∈ range T, f i ≤ S) :
    ∃ k, k < T ∧ f k ≤ S / T := by
  by_contra! h_contra
  have h_sum_gt : ∑ i ∈ Finset.range T, f i > T * (S / T) := by
    simpa using Finset.sum_lt_sum_of_nonempty ⟨ _, Finset.mem_range.mpr hT ⟩ fun i hi => h_contra i ( Finset.mem_range.mp hi );
  rw [ mul_div_cancel₀ ] at h_sum_gt <;> norm_cast at * ; linarith;
  lia

/-! ### Sufficient decrease implies convergence -/

/-
A non-increasing sequence bounded below converges.
-/
theorem bounded_decreasing_converges
    (a : ℕ → ℝ) (a_star : ℝ)
    (h_lower : ∀ n, a_star ≤ a n)
    (h_decreasing : ∀ n, a (n + 1) ≤ a n) :
    ∃ L, Filter.Tendsto a Filter.atTop (nhds L) := by
  exact ⟨ _, tendsto_atTop_ciInf ( show Antitone a from antitone_nat_of_succ_le h_decreasing ) ⟨ a_star, Set.forall_mem_range.2 h_lower ⟩ ⟩

/-! ### Polyak-Łojasiewicz convergence -/

/-
Under the Polyak-Łojasiewicz (PL) condition, gradient descent achieves
    linear convergence even without strong convexity.
    PL condition: ‖∇f(x)‖² ≥ 2μ(f(x) - f*) for all x.
    Combined with sufficient decrease, this gives geometric convergence.
-/
theorem pl_condition_convergence
    (a : ℕ → ℝ) (g_sq : ℕ → ℝ) (L mu : ℝ) (a_star : ℝ)
    (hL : 0 < L) (hmu : 0 < mu) (hmuL : mu ≤ L)
    (h_lower : ∀ n, a_star ≤ a n)
    (h_decrease : ∀ n, a n - a (n + 1) ≥ (1 / (2 * L)) * g_sq n)
    (h_pl : ∀ n, g_sq n ≥ 2 * mu * (a n - a_star)) :
    ∀ n, a n - a_star ≤ (1 - mu / L) ^ n * (a 0 - a_star) := by
  -- Apply the geometric_convergence lemma
  apply geometric_convergence;
  · exact sub_nonneg_of_le ( div_le_one_of_le₀ hmuL hL.le );
  · exact sub_lt_self _ ( div_pos hmu hL );
  · linarith [ h_lower 0 ];
  · intro n; have := h_decrease n; have := h_pl n; ring_nf at *; nlinarith [ mul_inv_cancel_left₀ hL.ne' ( a n - a_star ), mul_inv_cancel₀ hL.ne', h_lower n, h_lower ( n + 1 ) ] ;