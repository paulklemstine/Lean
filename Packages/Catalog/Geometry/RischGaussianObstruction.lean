/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.RischSplitIntegration

/-!
# The Gaussian obstruction: the negative side of the exponential Risch step

`Catalog/Geometry/RischResidueLiouville.lean` proves the *positive* half of the
one-exponential Risch criterion: for a nonzero rational rate `a`, the Risch differential
equation `q' + a q = p` always has a polynomial solution, hence `p(x) exp(a x)` always has
an elementary antiderivative.

This file proves the matching *negative* statement for a non-constant rate.  For
`exp(x²)` the associated Risch differential equation is `R' + 2 x R = 1`, and we show it
has **no** rational-function solution, over `ℂ` and therefore over `ℝ`.  Consequently

> `x ↦ exp(x²)` has no antiderivative of the form `R(x) exp(x²)` with `R` rational
> (`gaussian_no_rational_exponential_primitive`).

The proof has two independent parts, both algebraic:

* a leading-coefficient computation rules out polynomial solutions
  (`no_polynomial_solution_gaussian`), and
* an `(X - a)`-adic valuation argument at a root of the denominator forces the
  denominator to be constant (`no_rational_solution_gaussian`), reusing the technique
  developed for the simple-pole Liouville obstruction.

Together with `RischResidue.exp_poly_has_EML_primitive` this delimits exactly where the
first-order Risch differential equation stops being solvable: solvable for every
`ℚ`-linear exponent, unsolvable already for the quadratic exponent `x²`.
-/

noncomputable section

open Polynomial

namespace RischGaussian

/-! ## No polynomial solution -/

/-- The Risch differential equation of `exp(x²)` has no polynomial solution: comparing the
coefficient in degree `deg q + 1` forces the leading coefficient of `q` to vanish. -/
theorem no_polynomial_solution_gaussian (q : ℂ[X]) : derivative q + C 2 * X * q ≠ 1 := by
  intro h
  rcases eq_or_ne q 0 with rfl | hq
  · simp at h
  · set d := q.natDegree with hd
    have hcoeff := congrArg (fun r : ℂ[X] => r.coeff (d + 1)) h
    simp only [coeff_add, coeff_derivative, mul_assoc, coeff_C_mul, coeff_X_mul,
      Polynomial.coeff_one] at hcoeff
    have h1 : q.coeff (d + 1 + 1) = 0 := Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)
    have h2 : q.coeff d ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hq
    rw [h1, if_neg (by omega), zero_mul, zero_add] at hcoeff
    exact h2 ((mul_eq_zero.mp hcoeff).resolve_left two_ne_zero)

/-! ## No rational solution -/

/-- If the denominator of a hypothetical rational solution has a root, the
`(X - a)`-adic valuation of `P'Q - P Q' + 2 X P Q = Q²` forces that root to be shared
with the numerator, contradicting coprimality. -/
theorem denominator_root_impossible (P Q : ℂ[X]) (hQ : Q ≠ 0) (hco : IsCoprime P Q) (a : ℂ)
    (ha : Q.IsRoot a)
    (hid : derivative P * Q - P * derivative Q + C 2 * X * P * Q = Q ^ 2) : False := by
  set k := Q.rootMultiplicity a with hk
  have hkpos : 0 < k := (Polynomial.rootMultiplicity_pos hQ).mpr ha
  obtain ⟨j, hj⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  set R := Q /ₘ (X - C a) ^ k with hR
  have hQeq : Q = (X - C a) ^ (j + 1) * R := by
    have := Polynomial.pow_mul_divByMonic_rootMultiplicity_eq Q a
    rw [← hk, ← hR] at this
    simpa [hj] using this.symm
  have hR0 : R.eval a ≠ 0 := Polynomial.eval_divByMonic_pow_rootMultiplicity_ne_zero a hQ
  set U : ℂ[X] := derivative P * (X - C a) * R - C ((j : ℂ) + 1) * P * R
      - P * (X - C a) * derivative R + C 2 * X * P * (X - C a) * R with hU
  have hkey : ((X - C a : ℂ[X])) ^ j * U
      = (X - C a) ^ j * ((X - C a) ^ (j + 2) * R ^ 2) := by
    have h1 : derivative P * Q - P * derivative Q + C 2 * X * P * Q = (X - C a) ^ j * U := by
      rw [hQeq, hU]
      simp only [derivative_mul, derivative_pow, derivative_sub, derivative_X, derivative_C,
        sub_zero, mul_one, Nat.add_sub_cancel]
      push_cast
      ring
    have h2 : Q ^ 2 = (X - C a) ^ j * ((X - C a) ^ (j + 2) * R ^ 2) := by
      rw [hQeq]; ring
    rw [← h1, ← h2, hid]
  have hXne : ((X - C a : ℂ[X])) ^ j ≠ 0 := pow_ne_zero _ (Polynomial.X_sub_C_ne_zero a)
  have hU' : U = (X - C a) ^ (j + 2) * R ^ 2 := mul_left_cancel₀ hXne hkey
  have h := congrArg (Polynomial.eval a) hU'
  rw [hU] at h
  simp only [eval_add, eval_sub, eval_mul, eval_X, eval_C, eval_pow, sub_self, mul_zero,
    zero_mul, zero_sub, zero_pow (Nat.succ_ne_zero (j + 1))] at h
  have hj1 : ((j : ℂ) + 1) ≠ 0 := by
    intro hcon
    have hcast : ((j : ℝ) + 1 : ℂ) = 0 := by exact_mod_cast hcon
    have hre : ((j : ℝ) + 1) = 0 := by exact_mod_cast hcast
    nlinarith [Nat.cast_nonneg (α := ℝ) j]
  have hP0 : P.eval a = 0 := by
    have hprod : ((j : ℂ) + 1) * (P.eval a * R.eval a) = 0 := by linear_combination -h
    rcases mul_eq_zero.mp hprod with h' | h'
    · exact absurd h' hj1
    · exact (mul_eq_zero.mp h').resolve_right hR0
  have hXP : (X - C a : ℂ[X]) ∣ P := (Polynomial.dvd_iff_isRoot).mpr hP0
  have hXQ : (X - C a : ℂ[X]) ∣ Q := (Polynomial.dvd_iff_isRoot).mpr ha
  exact (Polynomial.prime_X_sub_C a).not_unit (hco.isUnit_of_dvd' hXP hXQ)

/-- **The Risch differential equation `R' + 2 x R = 1` has no rational solution.**
Equivalently, `exp(x²)` has no antiderivative of the form `R(x) exp(x²)` with `R`
a rational function over `ℂ`. -/
theorem no_rational_solution_gaussian (P Q : ℂ[X]) (hQ : Q ≠ 0) (hco : IsCoprime P Q)
    (hid : derivative P * Q - P * derivative Q + C 2 * X * P * Q = Q ^ 2) : False := by
  by_cases hdeg : Q.natDegree = 0
  · obtain ⟨c, rfl⟩ : ∃ c, Q = C c := ⟨Q.coeff 0, Polynomial.eq_C_of_natDegree_eq_zero hdeg⟩
    have hc : c ≠ 0 := fun h => hQ (by simp [h])
    have hCc : (C c : ℂ[X]) ≠ 0 := by simpa using hc
    refine no_polynomial_solution_gaussian (C c⁻¹ * P) ?_
    have hid' : derivative P * C c + C 2 * X * P * C c = C c ^ 2 := by simpa using hid
    have key : derivative P + C 2 * X * P = C c :=
      mul_left_cancel₀ hCc (by linear_combination hid')
    have expand : derivative (C c⁻¹ * P) + C 2 * X * (C c⁻¹ * P)
        = C c⁻¹ * (derivative P + C 2 * X * P) := by
      simp
      ring
    rw [expand, key, ← C_mul, inv_mul_cancel₀ hc, C_1]
  · obtain ⟨a, ha⟩ := IsAlgClosed.exists_root Q (by
      intro hdz
      exact hdeg (Polynomial.natDegree_eq_zero_iff_degree_le_zero.mpr (le_of_eq hdz)))
    exact denominator_root_impossible P Q hQ hco a ha hid

/-! ## The analytic statement over the reals -/

/-- A rational primitive `R(x) exp(x²)` of the Gaussian forces the Wronskian identity. -/
theorem gaussian_wronskian_identity (P Q : ℝ[X]) (hQ : Q ≠ 0)
    (h : ∀ x : ℝ, Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => (P.eval y / Q.eval y) * Real.exp (y ^ 2)) (Real.exp (x ^ 2)) x) :
    derivative P * Q - P * derivative Q + C 2 * X * P * Q = Q ^ 2 := by
  have hzero : derivative P * Q - P * derivative Q + C 2 * X * P * Q - Q ^ 2 = 0 := by
    refine Polynomial.eq_zero_of_infinite_isRoot _ (Set.Infinite.mono ?_
      ((Set.infinite_univ (α := ℝ)).diff (Polynomial.finite_setOf_isRoot hQ)))
    rintro x ⟨-, hQx⟩
    have hQx' : Q.eval x ≠ 0 := hQx
    have hexp : HasDerivAt (fun y : ℝ => Real.exp (y ^ 2)) (Real.exp (x ^ 2) * (2 * x)) x := by
      simpa using (hasDerivAt_pow 2 x).exp
    have hd := ((P.hasDerivAt x).div (Q.hasDerivAt x) hQx').mul hexp
    have heq := (h x hQx').unique hd
    have hE : Real.exp (x ^ 2) ≠ 0 := Real.exp_ne_zero _
    simp only [Pi.div_apply] at heq
    simp only [Set.mem_setOf_eq, IsRoot.def, eval_sub, eval_add, eval_mul, eval_X, eval_C,
      eval_pow]
    field_simp at heq ⊢
    nlinarith [heq]
  exact sub_eq_zero.mp hzero

/-- **The Gaussian has no rational-times-exponential antiderivative.**  This is the
sharp negative counterpart of `RischResidue.exp_poly_has_EML_primitive`: a *linear*
exponent always admits an elementary primitive of this shape, a *quadratic* exponent
never does. -/
theorem gaussian_no_rational_exponential_primitive (P Q : ℝ[X]) (hQ : Q ≠ 0)
    (hco : IsCoprime P Q)
    (h : ∀ x : ℝ, Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => (P.eval y / Q.eval y) * Real.exp (y ^ 2)) (Real.exp (x ^ 2)) x) :
    False := by
  have hid := gaussian_wronskian_identity P Q hQ h
  refine no_rational_solution_gaussian (P.map (algebraMap ℝ ℂ)) (Q.map (algebraMap ℝ ℂ)) ?_
    (hco.map (Polynomial.mapRingHom (algebraMap ℝ ℂ))) ?_
  · simpa [Polynomial.map_eq_zero_iff (algebraMap ℝ ℂ).injective] using hQ
  · have hmap := congrArg (Polynomial.map (algebraMap ℝ ℂ)) hid
    simpa [Polynomial.derivative_map, Polynomial.map_add, Polynomial.map_sub,
      Polynomial.map_mul, Polynomial.map_pow] using hmap

end RischGaussian