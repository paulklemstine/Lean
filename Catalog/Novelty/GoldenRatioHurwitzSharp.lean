import Mathlib
import Novelty.GoldenRatioApproximation

/-!
# The constant `√5` in Hurwitz's theorem is optimal

Hurwitz's theorem states that for every irrational `ξ` there are infinitely many
rationals `p/q` with `|ξ - p/q| < 1/(√5 · q²)`, and that `√5` is the *largest*
constant for which this holds for all irrationals.  The extremal case is the
golden ratio `φ = (1+√5)/2`.

This file proves the **sharpness** half: for any `c > √5`, the inequality
`|φ - p/q| < 1/(c q²)` has only finitely many solutions.  We package this as a
denominator threshold: beyond some `Q`, *no* rational with denominator `≥ Q`
beats the rate `1/(c q²)`.  Mathlib contains the existence side only through
Dirichlet's weaker `1/q²` bound; the `√5`-optimality is new here.

The engine is the same norm-form inequality used in
`Catalog.Novelty.GoldenRatioApproximation`:
`1 ≤ |p - qφ| · (|p - qφ| + q√5)`, which for a *good* approximation
(`|p - qφ|` small) forces `q√5 · |p - qφ| ≳ 1`, i.e. `|φ - p/q| ≳ 1/(√5 q²)`.

-- !-- Lab Notes -- !--
HYPOTHESIS.  `√5` is the best possible Hurwitz constant, witnessed by `φ`: for
`c > √5` only finitely many rationals satisfy `|φ - p/q| < 1/(c q²)`.

EXPERIMENT.  Reuse `GoldenRatio.one_le_abs_norm`, `GoldenRatio.norm_form`,
`GoldenRatio.phi_sub_psi` to get the master inequality `key`:
`1 ≤ t·(t + q√5)` with `t = |p - qφ|`.  Suppose `|φ - p/q| < 1/(c q²)`, so
`t < 1/(c q)`.  Then `1 ≤ t² + √5 (q t) < 1/(c²q²) + √5/c`.  Because `c > √5`,
`√5/c < 1`, so for `q` large enough that `1/(c²q²) ≤ 1 - √5/c`, the right side
is `≤ 1`, contradicting `1 ≤ … < …`.

ANALYSIS.  The whole asymmetry between Dirichlet (`1/q²`, always achievable) and
Hurwitz-sharpness (`1/(c q²)`, `c > √5`, only finitely often) is captured by the
single algebraic fact `√5/c < 1`.  The convergents `fib (n+1)/fib n` realise the
boundary rate `1/(√5 q²)`, so the threshold cannot be pushed to `c = √5`.

CRITIQUE.  The statement is the threshold form `∃ Q, ∀ q ≥ Q, …`; it is logically
equivalent to finiteness of the solution set and avoids `Set.Finite` plumbing
while remaining a genuine `√5`-optimality theorem.  No hidden vacuity: the
hypothesis `√5 < c` is satisfiable and load-bearing (it gives `√5/c < 1`).

SYNTHESIS.  Existence (Dirichlet/Mathlib) + sharpness (this file) pin the optimal
Diophantine constant of `φ` to exactly `√5`.
-/

open GoldenRatio

namespace GoldenRatioHurwitz

/-
**Master norm inequality.**  With `t = |p - qφ|`, one has
`1 ≤ t · (t + q√5)` for all integers `p` and `q ≥ 1`.
-/
lemma key (p q : ℤ) (hq : 1 ≤ q) :
    (1 : ℝ) ≤ |(p : ℝ) - q * phi| *
      (|(p : ℝ) - q * phi| + (q : ℝ) * Real.sqrt 5) := by
  -- By combining the results from the norm and the triangle inequality, we get the desired inequality.
  have h_combined : 1 ≤ |(p : ℝ) - q * phi| * (|(p : ℝ) - q * psi|) := by
    convert GoldenRatio.one_le_abs_norm p q hq using 1;
    rw [ ← abs_mul ] ; congr ; rw [ GoldenRatio.norm_form ] ;
  refine le_trans h_combined ?_;
  exact mul_le_mul_of_nonneg_left ( by rw [ show ( p : ℝ ) - q * psi = ( p : ℝ ) - q * phi + q * Real.sqrt 5 by rw [ show ( psi : ℝ ) = ( 1 - Real.sqrt 5 ) / 2 by rfl, show ( phi : ℝ ) = ( 1 + Real.sqrt 5 ) / 2 by rfl ] ; ring ] ; rw [ abs_le ] ; constructor <;> cases abs_cases ( ( p : ℝ ) - q * phi ) <;> nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ), ( by norm_cast : ( 1 :ℝ ) ≤ q ) ] ) ( abs_nonneg _ )

/-
**Sharpness of Hurwitz's constant.**  For any `c > √5` there is a
denominator threshold `Q` beyond which no rational `p/q` approximates `φ`
better than the rate `1/(c q²)`.  Hence `|φ - p/q| < 1/(c q²)` has only
finitely many solutions, so the Hurwitz constant `√5` cannot be improved.
-/
theorem hurwitz_constant_sharp (c : ℝ) (hc : Real.sqrt 5 < c) :
    ∃ Q : ℝ, ∀ (p q : ℤ), Q ≤ (q : ℝ) →
      (1 : ℝ) / (c * (q : ℝ) ^ 2) ≤ |phi - (p : ℝ) / (q : ℝ)| := by
  -- Choose the threshold Q. We need Q ≥ 1 and for q ≥ Q: 1/(c²·q²) ≤ 1 - √5/c.
  obtain ⟨Q₀, hQ₀⟩ : ∃ Q₀ : ℝ, ∀ q : ℝ, (1 : ℝ) ≤ q → Q₀ ≤ q → (1 : ℝ) / (c ^ 2 * q ^ 2) ≤ 1 - Real.sqrt 5 / c := by
    have hQ₀ : Filter.Tendsto (fun q : ℝ => 1 / (c ^ 2 * q ^ 2)) Filter.atTop (nhds 0) := by
      exact tendsto_const_nhds.div_atTop ( Filter.Tendsto.const_mul_atTop ( sq_pos_of_pos <| lt_trans ( Real.sqrt_pos.mpr ( by norm_num ) ) hc ) <| by norm_num );
    exact Filter.eventually_atTop.mp ( hQ₀.eventually ( ge_mem_nhds <| sub_pos.mpr <| by rw [ div_lt_iff₀ ] <;> nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ) ) |> fun ⟨ Q₀, hQ₀ ⟩ ↦ ⟨ Q₀, fun q hq₁ hq₂ ↦ hQ₀ q hq₂ ⟩;
  use ⌈Q₀⌉₊ + 1;
  intro p q hq
  have hq_ge_1 : 1 ≤ (q : ℝ) := by
    linarith
  have hq_ge_Q₀ : Q₀ ≤ (q : ℝ) := by
    linarith [ Nat.le_ceil Q₀ ]
  have h_ineq : 1 / (c * (q : ℝ) ^ 2) ≤ |(p : ℝ) - q * phi| / (q : ℝ) := by
    by_cases h_case : |(p : ℝ) - q * phi| < 1 / (c * (q : ℝ));
    · have h_ineq : 1 ≤ |(p : ℝ) - q * phi| * (|(p : ℝ) - q * phi| + (q : ℝ) * Real.sqrt 5) := by
        convert key p q ( Int.le_of_lt_add_one <| by { rw [ ← @Int.cast_lt ℝ ] ; push_cast; linarith } ) using 1;
      have h_ineq : |(p : ℝ) - q * phi| ^ 2 + (q : ℝ) * Real.sqrt 5 * |(p : ℝ) - q * phi| < 1 / (c ^ 2 * (q : ℝ) ^ 2) + Real.sqrt 5 / c := by
        convert add_lt_add_of_lt_of_le ( pow_lt_pow_left₀ h_case ( abs_nonneg _ ) two_ne_zero ) ( mul_le_mul_of_nonneg_left h_case.le ( show ( 0 : ℝ ) ≤ q * Real.sqrt 5 by positivity ) ) using 1 ; ring;
        grind;
      grind;
    · convert div_le_div_of_nonneg_right ( le_of_not_gt h_case ) ( by positivity : 0 ≤ ( q : ℝ ) ) using 1 ; ring;
  convert h_ineq using 1 ; rw [ sub_div', abs_div ] <;> norm_num [ show q ≠ 0 by norm_cast at *; linarith ] ; ring_nf;
  rw [ show - ( phi * q ) + p = - ( phi * q - p ) by ring, abs_neg, abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ q ) ]

end GoldenRatioHurwitz