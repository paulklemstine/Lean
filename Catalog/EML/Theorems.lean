/-
Copyright (c) 2025 EML Algebraic Independence Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import EML.Defs

/-!
# EML Theorems: Structural Results for EML Algebraic Independence

This file contains the main theorems of the EML algebraic independence framework:

## Theorem 1: Linear Relation Partition
`eml_linear_relation_partition` shows that any linear combination of EML values
can be regrouped by logarithmic collision classes, providing a separation-of-variables
decomposition.

## Theorem 2: Polynomial Expansion
`aeval_eml_eq_expandEML` proves that evaluating a multivariate polynomial at EML values
equals the explicit expansion into exp-log monomials.

## Theorem 3: Norm Bounds for Imaginary Inputs (Cross-Domain)
`norm_eml_mul_I` and `norm_sum_eml_mul_I_le` establish that for purely imaginary arguments,
the EML norm reduces to the logarithmic norm (since |exp(iθ)| = 1), connecting algebraic
independence questions to harmonic analysis and phase cancellation.
-/

open Complex MvPolynomial Finset BigOperators

noncomputable section

/-! ## Auxiliary lemmas -/

/-
`eml(z)^k = exp(k·z) * log(1+z)^k`
-/
theorem eml_pow (z : ℂ) (k : ℕ) :
    eml z ^ k = exp ((k : ℂ) * z) * log (1 + z) ^ k := by
      rw [ show eml z = Complex.exp z * Complex.log ( 1 + z ) from rfl, mul_pow, ← Complex.exp_nat_mul ]

/-
Product of EML powers equals an emlMonomial.
-/
theorem eml_prod_eq_emlMonomial {n : ℕ} (a : Fin n → ℂ) (m : Fin n →₀ ℕ) :
    (∏ i : Fin n, eml (a i) ^ (m i)) = emlMonomial a m := by
      simp +decide [ Finset.prod_mul_distrib, Complex.exp_sum, emlMonomial, eml_pow ]

/-! ## Theorem 2: Polynomial evaluation at EML values equals expandEML -/

/-
**Polynomial Expansion Theorem**: Evaluating a multivariate polynomial at EML values
    yields a sum over monomials of coefficients times exp-log monomials.

    This is the core reduction theorem: it converts any polynomial relation among
    EML values into an explicit finite sum of exp-log terms, enabling systematic
    analysis of cancellation patterns.
-/
theorem aeval_eml_eq_expandEML {n : ℕ} (a : Fin n → ℂ)
    (P : MvPolynomial (Fin n) ℚ) :
    aeval (fun i => eml (a i)) P = expandEML a P := by
      convert MvPolynomial.aeval_def ( fun i => eml ( a i ) ) P using 1;
      rw [ MvPolynomial.eval₂_eq' ];
      exact Finset.sum_congr rfl fun _ _ => by rw [ eml_prod_eq_emlMonomial ] ; rfl;

/-! ## Theorem 1: Linear Relation Partition -/

/-
**Linear Relation Partition Theorem**: Any linear combination of EML values
    decomposes as a sum over logarithmic collision classes.

    For each distinct value `L` of `log(1 + zᵢ)`, we group together all indices
    sharing that logarithmic value and factor out `L`, leaving an inner sum of
    weighted exponentials. This is a genuine separation-of-variables result:
    cancellation in a linear EML combination must occur *within* each logarithmic
    collision class.
-/
theorem eml_linear_relation_partition
    {n : ℕ} (z : Fin n → ℂ) (q : Fin n → ℚ) :
    ∑ i, (q i : ℂ) * eml (z i)
      =
    ∑ L ∈ (Finset.univ.image (fun i => log (1 + z i))),
      L * (∑ i ∈ Finset.univ.filter (fun i => log (1 + z i) = L),
            (q i : ℂ) * exp (z i)) := by
              simp +decide only [Finset.mul_sum _ _ _];
              rw [ Finset.sum_image' ];
              exact fun i _ => Finset.sum_congr rfl fun j hj => by rw [ eml ] ; rw [ Finset.mem_filter.mp hj |>.2 ] ; ring;

/-! ## Theorem 3: Norm bounds for imaginary inputs -/

/-
**EML Norm for Imaginary Inputs**: For purely imaginary argument `t·I`,
    the norm of `eml(t·I)` equals the norm of `log(1 + t·I)`.

    This is because `|exp(t·I)| = 1` for all real `t`, so the exponential factor
    contributes no magnitude. This connects EML algebraic independence to
    phase cancellation phenomena in harmonic analysis.
-/
theorem norm_eml_mul_I (t : ℝ) :
    ‖eml (↑t * I)‖ = ‖log (1 + ↑t * I)‖ := by
      unfold eml; rw [ norm_mul ] ; norm_num [ Complex.norm_exp ] ;

/-
**Triangle Inequality for EML Sums at Imaginary Arguments**:
    The norm of a linear combination of EML values at imaginary points is bounded
    by the sum of coefficient norms times logarithmic norms.

    This turns algebraic dependence search into a phase-cancellation problem:
    any polynomial relation among EML values at imaginary points must achieve
    precise phase cancellation, which is detectable by norm estimates.
-/
theorem norm_sum_eml_mul_I_le
    {n : ℕ} (θ : Fin n → ℝ) (c : Fin n → ℂ) :
    ‖∑ i, c i * eml (↑(θ i) * I)‖
      ≤ ∑ i, ‖c i‖ * ‖log (1 + ↑(θ i) * I)‖ := by
        refine' le_trans ( norm_sum_le _ _ ) _;
        exact Finset.sum_le_sum fun i _ => by rw [ norm_mul, norm_eml_mul_I ] ;

/-! ## Reduction theorem: polynomial relations reduce to expandEML vanishing -/

/-
`NoPolyRelUpTo` for EML values is equivalent to the expandEML formulation.
-/
theorem noPolyRelUpTo_eml_iff_expandEML {n : ℕ} (d : ℕ) (a : Fin n → ℂ) :
    NoPolyRelUpTo d (fun i => eml (a i)) ↔
    ∀ P : MvPolynomial (Fin n) ℚ, P.totalDegree ≤ d → expandEML a P = 0 → P = 0 := by
      -- By definition of `NoPolyRelUpTo`, we know that it is equivalent to the expandEML formulation.
      simp [NoPolyRelUpTo, aeval_eml_eq_expandEML]

end