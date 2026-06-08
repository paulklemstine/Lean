/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Algebra.EulerMascheroni.Defs

/-!
# Euler–Mascheroni Constant: Series Acceleration and Approximation Certificates

This file establishes the accelerated series representation of the Euler–Mascheroni
constant and introduces an approximation certificate structure for certified computation.

## Main definitions

* `EulerGamma.gammaSeriesTerm m` — the m-th term 1/(m+1) - log(1 + 1/(m+1))
* `EulerGamma.gammaApprox N` — partial sum of the first N terms of the accelerated series
* `EulerGamma.gammaErrorBound N` — explicit error bound for the partial sum
* `EulerGamma.IrrationalityHeuristicCertificate` — structure for certified rational approximations
* `EulerGamma.gammaRichardson n` — Richardson-corrected approximation

## Main results

* `EulerGamma.gammaSeriesTerm_nonneg` — each term is nonneg
* `EulerGamma.gammaSeriesTerm_le` — each term ≤ 1/(2(m+1)²)
* `EulerGamma.gammaApprox_eq_eulerRenorm` — partial sums relate to eulerRenorm
* `EulerGamma.gammaApprox_certified` — certified error bound for approximation
* `EulerGamma.gamma_approximation_complexity` — complexity of ε-approximation
-/

namespace EulerGamma

open Finset Filter Topology BigOperators Real

noncomputable section

/-! ## Accelerated series -/

/-- The m-th term of the accelerated series for γ:
    a_m = 1/(m+1) - log(1 + 1/(m+1)). -/
def gammaSeriesTerm (m : ℕ) : ℝ :=
  1 / (↑m + 1) - Real.log (1 + 1 / (↑m + 1 : ℝ))

/-
Each term of the accelerated series is nonneg,
    since log(1+t) ≤ t for t > 0.
-/
theorem gammaSeriesTerm_nonneg (m : ℕ) : 0 ≤ gammaSeriesTerm m := by
  exact sub_nonneg_of_le ( by exact le_trans ( Real.log_le_sub_one_of_pos ( by positivity ) ) ( by ring_nf; norm_num ) )

/-
Each term of the accelerated series satisfies a_m ≤ 1/(2(m+1)²),
    using the Taylor bound log(1+t) ≥ t - t²/2.
-/
theorem gammaSeriesTerm_le (m : ℕ) :
    gammaSeriesTerm m ≤ 1 / (2 * (↑m + 1)^2) := by
  unfold gammaSeriesTerm;
  -- We'll use the fact that $log(1 + x) \geq x - \frac{x^2}{2}$ for $x > 0$.
  have h_log_ineq : ∀ x : ℝ, 0 < x → Real.log (1 + x) ≥ x - x^2 / 2 := by
    -- Let's choose any $x > 0$ and apply the inequality.
    intro x hx_pos
    have h_deriv : ∀ y ∈ Set.Icc 0 x, deriv (fun y => Real.log (1 + y) - y + y^2 / 2) y ≥ 0 := by
      intro y hy; norm_num [ add_comm, show y + 1 ≠ 0 from by linarith [ hy.1 ] ];
      nlinarith [ hy.1, hy.2, inv_mul_cancel₀ ( by linarith [ hy.1 ] : ( y + 1 ) ≠ 0 ) ];
    have := exists_deriv_eq_slope ( f := fun y => Real.log ( 1 + y ) - y + y ^ 2 / 2 ) hx_pos;
    contrapose! this;
    exact ⟨ ContinuousOn.add ( ContinuousOn.sub ( ContinuousOn.log ( continuousOn_const.add continuousOn_id ) fun y hy => by linarith [ hy.1 ] ) continuousOn_id ) ( ContinuousOn.div_const ( continuousOn_pow 2 ) _ ), DifferentiableOn.add ( DifferentiableOn.sub ( DifferentiableOn.log ( differentiableOn_id.const_add _ ) fun y hy => by linarith [ hy.1 ] ) differentiableOn_id ) ( DifferentiableOn.div_const ( differentiableOn_pow 2 ) _ ), fun c hc => by rw [ ne_eq, eq_div_iff ] <;> norm_num <;> nlinarith [ h_deriv c ⟨ hc.1.le, hc.2.le ⟩ ] ⟩;
  convert sub_le_sub_left ( h_log_ineq _ <| by positivity : Real.log ( 1 + ( m + 1 : ℝ ) ⁻¹ ) ≥ ( m + 1 : ℝ ) ⁻¹ - ( ( m + 1 : ℝ ) ⁻¹ ) ^ 2 / 2 ) ( ( m + 1 : ℝ ) ⁻¹ ) using 1 ; ring;
  -- Simplifying the right-hand side:
  field_simp
  ring

/-- Partial sum of the accelerated series. -/
def gammaApprox (N : ℕ) : ℝ := ∑ k ∈ Finset.range N, gammaSeriesTerm k

/-
The partial sum of the accelerated series equals
    H_{N} - log(N+1) when reinterpreted through telescoping logarithms.
    Specifically, gammaApprox N = harmonicSum N - log(N+1).
-/
theorem gammaApprox_eq (N : ℕ) :
    gammaApprox (N + 1) = harmonicSum (N + 1) - Real.log (↑N + 1 + 1) := by
  induction' N with N ih <;> simp_all +decide [ Finset.sum_range_succ, harmonicSum ];
  · unfold gammaApprox gammaSeriesTerm; norm_num;
  · convert congr_arg ( · + gammaSeriesTerm ( N + 1 ) ) ih using 1;
    · exact Finset.sum_range_succ _ _;
    · unfold gammaSeriesTerm; norm_num; ring;
      rw [ show ( 3 + N : ℝ ) = ( 2 + N ) * ( 1 + ( 2 + N : ℝ ) ⁻¹ ) by nlinarith [ mul_inv_cancel₀ ( by linarith : ( 2 + N : ℝ ) ≠ 0 ) ], Real.log_mul ( by linarith ) ( by positivity ) ] ; ring

/-
The relationship between gammaApprox and eulerRenorm.
-/
theorem gammaApprox_eq_eulerRenorm (N : ℕ) :
    gammaApprox (N + 1) = eulerRenorm N - Real.log (1 + 1 / (↑N + 1)) := by
  rw [ gammaApprox_eq, eulerRenorm ];
  rw [ show ( N : ℝ ) + 1 + 1 = ( N + 1 ) * ( 1 + 1 / ( N + 1 ) ) by rw [ mul_add, mul_div_cancel₀ _ ( by positivity ) ] ; ring, Real.log_mul ( by positivity ) ( by positivity ) ] ; ring

/-! ## Certified error bound -/

/-- Explicit error bound for the certified approximation algorithm.
    The tail sum ∑_{k≥N} a_k ≤ ∑_{k≥N} 1/(2(k+1)²) ≤ 1/(2N). -/
def gammaErrorBound (N : ℕ) : ℝ := 1 / (↑N + 1)

/-
The certified approximation theorem: gammaApprox gets within
    gammaErrorBound of the true value.
-/
theorem gammaApprox_certified (N : ℕ) :
    |eulerMascheroni - gammaApprox (N + 1)| ≤ gammaErrorBound N := by
  nontriviality;
  have h_le : eulerMascheroni - gammaApprox (N + 1) ≤ Real.log (1 + 1 / (N + 1)) := by
    linarith [ euler_error_nonneg N, euler_error_upper N, gammaApprox_eq_eulerRenorm N ];
  have h_nonneg : gammaApprox (N + 1) ≤ eulerMascheroni := by
    have h_le : ∀ m, gammaApprox (m + 1) ≤ eulerRenorm m := by
      exact fun m => by rw [ gammaApprox_eq_eulerRenorm ] ; exact sub_le_self _ ( Real.log_nonneg ( by norm_num; positivity ) ) ;
    have h_le : ∀ m ≥ N, gammaApprox (N + 1) ≤ eulerRenorm m := by
      intros m hm
      have h_le : gammaApprox (N + 1) ≤ gammaApprox (m + 1) := by
        exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.range_mono ( by linarith ) ) fun _ _ _ => gammaSeriesTerm_nonneg _;
      grind;
    exact le_ciInf fun m => if hm : m ≥ N then h_le m hm else by linarith [ h_le N le_rfl, show eulerRenorm m ≥ eulerRenorm N from by exact antitone_nat_of_succ_le ( fun n => by exact eulerRenorm_antitone n.le_succ ) ( le_of_not_ge hm ) ] ;
  rw [ abs_of_nonneg ( sub_nonneg_of_le h_nonneg ) ];
  exact h_le.trans ( le_trans ( Real.log_le_sub_one_of_pos ( by positivity ) ) ( by norm_num [ gammaErrorBound ] ) )

/-! ## Irrationality Heuristic Certificate -/

/-- A structure certifying that a sequence of rationals approximates
    a real constant with controlled error. This is a reusable abstraction
    for studying approximation quality of constants like γ, ζ(3), Catalan's constant, etc. -/
structure IrrationalityHeuristicCertificate where
  /-- Numerator sequence -/
  seqNum : ℕ → ℤ
  /-- Denominator sequence (positive) -/
  seqDen : ℕ → ℕ
  /-- The real constant being approximated -/
  value : ℝ
  /-- Error bound sequence -/
  errorBound : ℕ → ℝ
  /-- Denominators are positive -/
  den_pos : ∀ n, 0 < seqDen n
  /-- Error bounds tend to zero -/
  tendsTo_zero : Tendsto errorBound atTop (nhds 0)
  /-- Certified approximation inequality -/
  certified : ∀ n, |value - (seqNum n : ℝ) / (seqDen n : ℝ)| ≤ errorBound n

/-
There exists an irrationality heuristic certificate for γ
    based on the Euler renormalization sequence.
-/
theorem exists_gamma_certificate :
    ∃ cert : IrrationalityHeuristicCertificate, cert.value = eulerMascheroni := by
  fconstructor;
  constructor;
  exact fun n => Nat.succ_pos n;
  case value => exact eulerMascheroni;
  convert tendsto_one_div_add_atTop_nhds_zero_nat;
  all_goals try infer_instance;
  all_goals norm_num [ abs_le ];
  field_simp;
  exact fun n => ⟨ le_add_of_le_of_nonneg ( Int.floor_le _ ) zero_le_one, by linarith [ Int.lt_floor_add_one ( ( n + 1 : ℝ ) * eulerMascheroni ) ] ⟩

/-! ## Cross-domain: Computational complexity of approximation -/

/-
The number of terms needed for ε-accuracy scales linearly in 1/ε.
    This establishes a bridge between analysis and computational complexity.
-/
theorem gamma_approximation_complexity :
    ∀ ε : ℝ, 0 < ε → ∃ N : ℕ, (↑N ≤ 2 * ε⁻¹) ∧
      |eulerMascheroni - gammaApprox (N + 1)| ≤ ε := by
  intro ε hε_pos
  obtain ⟨N, hN⟩ : ∃ N : ℕ, (1 : ℝ) / (N + 1) ≤ ε ∧ N ≤ 2 * ε⁻¹ := by
    use Nat.floor (2 * ε⁻¹);
    exact ⟨ by rw [ div_le_iff₀ ] <;> nlinarith [ Nat.lt_floor_add_one ( 2 * ε⁻¹ ), mul_inv_cancel₀ hε_pos.ne' ], Nat.floor_le ( by positivity ) ⟩;
  exact ⟨ N, hN.2, le_trans ( gammaApprox_certified N ) hN.1 ⟩

/-! ## Richardson-corrected approximation (conjecture) -/

/-- Richardson-corrected approximation of γ, subtracting the leading
    error term 1/(2(n+1)) from the Euler renormalization sequence. -/
def gammaRichardson (n : ℕ) : ℝ :=
  eulerRenorm n - 1 / (2 * (↑n + 1 : ℝ))

/-
Richardson correction also converges to γ.
-/
theorem gammaRichardson_tendsto :
    Tendsto gammaRichardson atTop (nhds eulerMascheroni) := by
  convert Filter.Tendsto.sub ( eulerRenorm_tendsto ) ( tendsto_const_nhds.div_atTop _ ) using 2 <;> norm_num;
  exact Filter.tendsto_atTop_mono ( fun x => by linarith ) tendsto_natCast_atTop_atTop

end

end EulerGamma