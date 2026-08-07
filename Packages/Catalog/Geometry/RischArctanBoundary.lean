/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.RischLogIndependence

/-!
# The arctangent boundary: real logarithms are not enough

`Catalog/Geometry/RischSplitIntegration.lean` integrates every rational function whose
denominator splits over `ℚ`, and `RischSplit.not_splits_X_sq_add_one` records that
`1/(x²+1)` is outside that hypothesis.  That is only a statement about the *hypothesis*:
it leaves open whether some cleverer combination of rational functions and logarithms of
real affine factors might still integrate `1/(x²+1)`.

This file closes that gap.  Using the fact that a derivative of a rational function has no
simple pole (`RischLogIndep.simple_pole_not_derivative`), we prove

* `arctan_obstruction_complex` — the algebraic core: no identity
  `(A/B)' + ∑ c_i/(x - a_i) = 1/(x²+1)` can hold with `A/B` in lowest terms and all
  `a_i ≠ i`.  The reason is a residue count at the complex point `i`: the right-hand side
  has a simple pole there, the logarithmic terms have poles only at the `a_i`, and a
  derivative of a rational function never contributes a simple pole.

* `arctan_not_rational_plus_real_logs` — analytically over `ℝ`: the function `1/(x²+1)`
  has **no** antiderivative of the form `A(x)/B(x) + ∑_{a ∈ s} c_a · log (x - a)` with
  `A, B` real polynomials and `s` a finite set of real numbers.  Hence the catalog's
  rational-plus-logarithm language is genuinely incomplete over `ℝ`: a new elementary
  generator (`arctan`, equivalently a complex logarithm) is unavoidable.

This makes the boundary marked by `not_splits_X_sq_add_one` a theorem about the
*expressive power* of the language rather than about one particular algorithm.
-/

noncomputable section

open Polynomial

namespace RischArctan

/-! ## The algebraic core -/

/-- **No rational-plus-logarithm primitive for `1/(x²+1)`, algebraically.**

The hypothesis is the cleared-denominator form of
`(A/B)' + ∑_{i ∈ s} c_i/(x - a_i) = 1/(x² + 1)`, with `A/B` in lowest terms and every
logarithmic pole `a_i` different from `i`.  It is contradictory: the right-hand side has a
simple pole at `i` with nonzero residue, which a derivative of a rational function cannot
produce. -/
theorem arctan_obstruction_complex {ι : Type*} [DecidableEq ι] (s : Finset ι) (a c : ι → ℂ) (A B : ℂ[X])
    (hB : B ≠ 0) (hAB : IsCoprime A B) (hI : ∀ i ∈ s, a i ≠ Complex.I)
    (hid : (derivative A * B - A * derivative B) *
        ((X - C Complex.I) * ((X + C Complex.I) * ∏ i ∈ s, (X - C (a i))))
      = ((∏ i ∈ s, (X - C (a i))) - (X ^ 2 + 1) *
          ∑ i ∈ s, C (c i) * ∏ j ∈ s.erase i, (X - C (a j))) * B ^ 2) : False := by
  have hprod : (∏ i ∈ s, (X - C (a i))).eval Complex.I ≠ 0 := by
    rw [eval_prod]
    refine Finset.prod_ne_zero_iff.mpr fun i hi => ?_
    simpa using sub_ne_zero.mpr (fun hcon => hI i hi hcon.symm)
  refine RischLogIndep.simple_pole_not_derivative A B _
    ((X + C Complex.I) * ∏ i ∈ s, (X - C (a i))) Complex.I hB hAB ?_ ?_ hid
  · rw [eval_mul]
    refine mul_ne_zero ?_ hprod
    simp only [eval_add, eval_X, eval_C]
    intro hcon
    have : (2 : ℂ) * Complex.I = 0 := by linear_combination hcon
    simpa using (mul_eq_zero.mp this).resolve_left two_ne_zero
  · have hI2 : (Complex.I : ℂ) ^ 2 + 1 = 0 := by
      rw [Complex.I_sq]; ring
    simp only [eval_sub, eval_mul, eval_add, eval_pow, eval_X, eval_one]
    rw [hI2, zero_mul, sub_zero]
    exact hprod

/-! ## From analysis over `ℝ` to the algebraic identity -/

/-- Partial fractions in the other direction: a finite sum of simple fractions is the
quotient of the two obvious polynomials, at every point off the poles. -/
theorem sum_simple_fractions_eq (s : Finset ℝ) (c : ℝ → ℝ) {x : ℝ}
    (hx : ∀ a ∈ s, x ≠ a) :
    ∑ a ∈ s, c a / (x - a)
      = (∑ a ∈ s, c a * ∏ b ∈ s.erase a, (x - b)) / ∏ a ∈ s, (x - a) := by
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun a ha => ?_
  have hxa : x - a ≠ 0 := sub_ne_zero.mpr (hx a ha)
  have hsplit : (∏ b ∈ s, (x - b)) = (x - a) * ∏ b ∈ s.erase a, (x - b) :=
    (Finset.mul_prod_erase s _ ha).symm
  have hrest : (∏ b ∈ s.erase a, (x - b)) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.mpr fun b hb => ?_
    exact sub_ne_zero.mpr (hx b (Finset.mem_of_mem_erase hb))
  rw [hsplit]
  field_simp

/-- **The arctangent is not elementary over rational functions and real logarithms.**

There is no antiderivative of `1/(x²+1)` of the form
`A(x)/B(x) + ∑_{a ∈ s} c_a · log (x - a)` with `A, B` real polynomials (in lowest terms)
and `s` a finite set of real numbers.  The catalog's rational + logarithm normal form is
therefore strictly weaker than the full elementary closure over `ℝ`. -/
theorem arctan_not_rational_plus_real_logs (A B : ℝ[X]) (s : Finset ℝ) (c : ℝ → ℝ)
    (hB : B ≠ 0) (hAB : IsCoprime A B)
    (h : ∀ x : ℝ, B.eval x ≠ 0 → (∀ a ∈ s, x ≠ a) →
      HasDerivAt (fun y : ℝ => A.eval y / B.eval y + ∑ a ∈ s, c a * Real.log (y - a))
        (1 / (x ^ 2 + 1)) x) :
    False := by
  set D : ℝ[X] := ∏ a ∈ s, (X - C a) with hD
  set N : ℝ[X] := ∑ a ∈ s, C (c a) * ∏ b ∈ s.erase a, (X - C b) with hN
  have hDne : D ≠ 0 := by
    rw [hD]
    exact Finset.prod_ne_zero_iff.mpr fun a _ => Polynomial.X_sub_C_ne_zero a
  -- the cleared-denominator identity over `ℝ`
  have hid : (derivative A * B - A * derivative B) * ((X ^ 2 + 1) * D)
      = (D - (X ^ 2 + 1) * N) * B ^ 2 := by
    have hzero : (derivative A * B - A * derivative B) * ((X ^ 2 + 1) * D)
        - (D - (X ^ 2 + 1) * N) * B ^ 2 = 0 := by
      refine Polynomial.eq_zero_of_infinite_isRoot _ (Set.Infinite.mono ?_
        ((Set.infinite_univ (α := ℝ)).diff
          (Polynomial.finite_setOf_isRoot (mul_ne_zero hB hDne))))
      rintro x ⟨-, hx⟩
      have hx' : (B * D).eval x ≠ 0 := hx
      rw [eval_mul, mul_ne_zero_iff] at hx'
      obtain ⟨hBx, hDx⟩ := hx'
      have hDx' : (∏ a ∈ s, (x - a)) ≠ 0 := by
        rw [hD, eval_prod] at hDx
        simpa using hDx
      have hne : ∀ a ∈ s, x ≠ a := by
        intro a ha hcon
        exact hDx' (Finset.prod_eq_zero ha (by simp [hcon]))
      have hsq : x ^ 2 + 1 ≠ 0 := by positivity
      -- differentiate the candidate primitive
      have hlogs : HasDerivAt (fun y : ℝ => ∑ a ∈ s, c a * Real.log (y - a))
          (∑ a ∈ s, c a / (x - a)) x := by
        refine HasDerivAt.fun_sum (A := fun (a : ℝ) (y : ℝ) => c a * Real.log (y - a))
          (A' := fun a : ℝ => c a / (x - a)) fun a ha => ?_
        have hxa : x - a ≠ 0 := sub_ne_zero.mpr (hne a ha)
        have hl : HasDerivAt (fun y : ℝ => Real.log (y - a)) (1 / (x - a)) x := by
          simpa using (((hasDerivAt_id x).sub_const a).log hxa)
        simpa [mul_one_div] using HasDerivAt.const_mul (c a) hl
      have hd := ((A.hasDerivAt x).div (B.hasDerivAt x) hBx).add hlogs
      have heq := (h x hBx hne).unique hd
      rw [sum_simple_fractions_eq s c hne] at heq
      have hNx : (∑ a ∈ s, c a * ∏ b ∈ s.erase a, (x - b)) = N.eval x := by
        rw [hN, eval_finset_sum]
        exact Finset.sum_congr rfl fun a _ => by rw [eval_mul, eval_C, eval_prod]; simp
      have hDxv : (∏ a ∈ s, (x - a)) = D.eval x := by
        rw [hD, eval_prod]; simp
      rw [hNx, hDxv] at heq
      simp only [Set.mem_setOf_eq, IsRoot.def, eval_sub, eval_mul, eval_add, eval_pow,
        eval_X, eval_one]
      field_simp at heq
      linarith [heq]
    exact sub_eq_zero.mp hzero
  -- transfer to `ℂ` and apply the algebraic core
  have hmap := congrArg (Polynomial.map (algebraMap ℝ ℂ)) hid
  refine arctan_obstruction_complex s (fun r : ℝ => (r : ℂ)) (fun r : ℝ => (c r : ℂ))
    (A.map (algebraMap ℝ ℂ)) (B.map (algebraMap ℝ ℂ)) ?_
    (hAB.map (Polynomial.mapRingHom (algebraMap ℝ ℂ))) ?_ ?_
  · simpa [Polynomial.map_eq_zero_iff (algebraMap ℝ ℂ).injective] using hB
  · intro i _ hcon
    have : (Complex.I).im = 0 := by rw [← hcon]; simp
    simp at this
  · have hXX : ((X - C Complex.I) * (X + C Complex.I) : ℂ[X]) = X ^ 2 + 1 := by
      have h1 : (C Complex.I * C Complex.I : ℂ[X]) = -1 := by
        rw [← C_mul, Complex.I_mul_I]
        simp
      linear_combination -h1
    rw [hD, hN] at hmap
    simp only [Polynomial.map_mul, Polynomial.map_sub, Polynomial.map_add, Polynomial.map_pow,
      Polynomial.map_prod, Polynomial.map_sum, Polynomial.map_X, Polynomial.map_C,
      Polynomial.map_one] at hmap
    calc (derivative (A.map (algebraMap ℝ ℂ)) * B.map (algebraMap ℝ ℂ)
            - A.map (algebraMap ℝ ℂ) * derivative (B.map (algebraMap ℝ ℂ))) *
          ((X - C Complex.I) * ((X + C Complex.I) *
            ∏ i ∈ s, (X - C ((i : ℂ)))))
        = (derivative (A.map (algebraMap ℝ ℂ)) * B.map (algebraMap ℝ ℂ)
            - A.map (algebraMap ℝ ℂ) * derivative (B.map (algebraMap ℝ ℂ))) *
          ((X ^ 2 + 1) * ∏ i ∈ s, (X - C ((i : ℂ)))) := by
              rw [← hXX]; ring
      _ = ((∏ i ∈ s, (X - C ((i : ℂ)))) - (X ^ 2 + 1) *
            ∑ i ∈ s, C ((c i : ℂ)) * ∏ j ∈ s.erase i, (X - C ((j : ℂ)))) *
            B.map (algebraMap ℝ ℂ) ^ 2 := by
              simpa using hmap

end RischArctan