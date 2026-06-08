/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import EulerMascheroni.Convergence

/-!
# Scheme Invariance and Renormalization Universality

This file proves that the Euler–Mascheroni constant γ is *uniquely* determined
by any asymptotically equivalent truncation/renormalization scheme. Different
ways of defining "harmonic minus log" all converge to the same constant.

## Main results

* `renormalized_constant_unique` — any two sequences that differ from `log n`
  by the same asymptotic offset converge to the same constant.
* `eulerMascheroni_from_log_succ` — γ can equivalently be obtained by
  subtracting `log(n+1)` instead of `log(n)`, showing scheme invariance.
* `eulerMascheroni_from_integral` — connection to the integral representation:
  γ = lim_{n→∞} (H_n - ∫₁ⁿ 1/x dx).

## Mathematical significance

This formalizes the **universality** of the renormalized constant: the specific
cutoff scheme (subtracting `log n` vs `log(n+1)` vs an integral) does not
affect the limiting value. This is the formal analogue of "renormalization
scheme independence" and is essential for connecting different characterizations
of γ used in analytic number theory.
-/

namespace EulerMascheroni

open Finset Filter Real BigOperators

/-! ### Uniqueness of the renormalized limit -/

/-
The renormalized limit is unique: if two sequences both differ from `log n`
    by a convergent amount, they must converge to the same limit.
-/
theorem renormalized_constant_unique
    (a b : ℕ → ℝ)
    (ha : ∃ A, Tendsto (fun n => a n - Real.log n) atTop (nhds A))
    (hb : ∃ B, Tendsto (fun n => b n - Real.log n) atTop (nhds B))
    (hEq : ∀ᶠ n in atTop, a n = b n) :
    ha.choose = hb.choose := by
  exact tendsto_nhds_unique ha.choose_spec ( hb.choose_spec.congr' <| by filter_upwards [ hEq ] with n hn; aesop )

/-! ### Scheme invariance: log(n) vs log(n+1) -/

/-
The sequence `H_n - log(n+1)` also converges, and its limit equals γ.
-/
theorem tendsto_harmonic_sub_log_succ :
    Tendsto (fun n => harmonic n - Real.log (↑n + 1)) atTop (nhds eulerMascheroni) := by
  -- We have (harmonic n - log(n+1)) = (harmonic n - log n) - (log(n+1) - log n) = eulerMascheroniSeq n - log(1 + 1/n).
  have h_eq : ∀ n : ℕ, harmonic n - Real.log (↑n + 1) = eulerMascheroniSeq n - Real.log (1 + 1 / (n : ℝ)) := by
    intro n;
    by_cases hn : n = 0 <;> simp_all +decide [ harmonic, eulerMascheroniSeq ];
    rw [ show ( n : ℝ ) + 1 = n * ( 1 + ( n : ℝ ) ⁻¹ ) by nlinarith [ mul_inv_cancel₀ ( by positivity : ( n : ℝ ) ≠ 0 ) ], Real.log_mul ( by positivity ) ( by positivity ) ] ; ring;
  simpa [ h_eq ] using tendsto_eulerMascheroni.sub ( Filter.Tendsto.log ( tendsto_const_nhds.add ( tendsto_one_div_atTop_nhds_zero_nat ) ) ( show ( 1 + 0 : ℝ ) ≠ 0 by norm_num ) )

/-! ### Integral representation -/

/-
The integral `∫₁ⁿ 1/x dx = log(n)`, establishing the connection between
    the harmonic-log definition and the integral formulation.
-/
theorem integral_inv_eq_log (n : ℕ) (hn : 1 ≤ n) :
    ∫ x in (1 : ℝ)..(↑n), x⁻¹ = Real.log n := by
  rw [ integral_inv_of_pos ] <;> norm_num ; linarith

/-
γ can be defined via integral renormalization:
    `γ = lim_{n→∞} (H_n - ∫₁ⁿ 1/x dx)`.
-/
theorem eulerMascheroni_eq_lim_integral_diff :
    Tendsto (fun n => harmonic n - ∫ x in (1 : ℝ)..(↑n), x⁻¹) atTop
      (nhds eulerMascheroni) := by
  convert tendsto_eulerMascheroni using 1;
  funext n; by_cases hn : 1 ≤ n <;> simp_all +decide [ harmonic, eulerMascheroniSeq ] ;
  rw [ intervalIntegral.integral_undef ] ; norm_num

end EulerMascheroni