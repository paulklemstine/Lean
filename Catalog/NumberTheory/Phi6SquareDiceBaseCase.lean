import Mathlib

/-!
# Cyclotomic dice: the explicit base-case witness `p = 2, q = 3, m = 6, n = 2`

This file formalizes a single, fully explicit *admissible instance* of the cyclotomic
"dice transfer" construction.  The combinatorial object behind the algebra is a pair of
weighted dice whose generating polynomials multiply to the product of two consecutive-face
dice generating polynomials.

We work entirely over `Polynomial ℤ` (with auxiliary natural-coefficient polynomials over
`Polynomial ℕ` used only to certify coefficient nonnegativity).

The witness is built from the sixth cyclotomic polynomial `Φ₆ = X² - X + 1`.  Writing
`S N = X + X² + ⋯ + X^N` for the generating polynomial of a fair `N`-faced die, we prove:

* `phi6_mul_P36 : Phi6 * P36 = S 36`,
* `Q4_eq_phi6_mul_S4 : Q4 = Phi6 * S 4`,
* `product_identity : P36 * Q4 = S 36 * S 4`,
* `eval_P36_one : eval 1 P36 = 36` and `eval_Q4_one : eval 1 Q4 = 4`,
* coefficient nonnegativity of both `P36` and `Q4`.

Together these certify that the weighted dice with generating polynomials `P36` and `Q4`
have nonnegative integer face weights summing to `36` and `4` respectively, and reproduce
the product `S 36 * S 4` of two fair-dice generating polynomials.
-/

namespace Phi6SquareDiceBaseCase

open Polynomial Finset

/-- Generating polynomial of a fair `N`-faced die: `X + X² + ⋯ + X^N`. -/
noncomputable def S (N : ℕ) : Polynomial ℤ := ∑ i ∈ Finset.range N, X ^ (i + 1)

/-- The sixth cyclotomic polynomial `Φ₆ = X² - X + 1`. -/
noncomputable def Phi6 : Polynomial ℤ := X ^ 2 - X + 1

/-- The `j`-th natural-coefficient block: `X^{6j+1} + 2 X^{6j+2} + 2 X^{6j+3} + X^{6j+4}`. -/
noncomputable def blockNat (j : ℕ) : Polynomial ℕ :=
  X ^ (6 * j + 1) + C 2 * X ^ (6 * j + 2) + C 2 * X ^ (6 * j + 3) + X ^ (6 * j + 4)

/-- Natural-coefficient generating polynomial of the first weighted die. -/
noncomputable def P36Nat : Polynomial ℕ := ∑ j ∈ Finset.range 6, blockNat j

/-- The first weighted die's generating polynomial, over `ℤ`. -/
noncomputable def P36 : Polynomial ℤ := P36Nat.map (Nat.castRingHom ℤ)

/-- Natural-coefficient generating polynomial of the second weighted die. -/
noncomputable def Q4Nat : Polynomial ℕ := X + X ^ 3 + X ^ 4 + X ^ 6

/-- The second weighted die's generating polynomial, over `ℤ`. -/
noncomputable def Q4 : Polynomial ℤ := Q4Nat.map (Nat.castRingHom ℤ)

/-- Coefficientwise nonnegativity of an integer polynomial. -/
def CoeffNonneg (P : Polynomial ℤ) : Prop := ∀ k, 0 ≤ P.coeff k

/-- `Φ₆ · P36 = S 36`: the first die divides the fair 36-die generating polynomial. -/
theorem phi6_mul_P36 : Phi6 * P36 = S 36 := by
  unfold Phi6 P36 S P36Nat
  simp +decide [Finset.sum_range_succ, blockNat]
  ring

/-- `Q4 = Φ₆ · S 4`: the second die's generating polynomial factors through `Φ₆`. -/
theorem Q4_eq_phi6_mul_S4 : Q4 = Phi6 * S 4 := by
  unfold Q4 Q4Nat S Phi6
  simp only [Polynomial.map_add, Polynomial.map_pow, Polynomial.map_X,
    Finset.sum_range_succ, Finset.sum_range_zero]
  ring

/-- The product identity `P36 · Q4 = S 36 · S 4`, obtained algebraically from the two
factorizations above. -/
theorem product_identity : P36 * Q4 = S 36 * S 4 := by
  have h1 : Phi6 * P36 = S 36 := phi6_mul_P36
  have h2 : Q4 = Phi6 * S 4 := Q4_eq_phi6_mul_S4
  calc P36 * Q4 = (Phi6 * P36) * S 4 := by rw [h2]; ring
    _ = S 36 * S 4 := by rw [h1]

/-- The total face weight of the first die is `36`. -/
theorem eval_P36_one : Polynomial.eval 1 P36 = 36 := by
  unfold P36 P36Nat blockNat
  norm_num [Polynomial.eval_map, Polynomial.eval₂_finset_sum]

/-- The total face weight of the second die is `4`. -/
theorem eval_Q4_one : Polynomial.eval 1 Q4 = 4 := by
  unfold Q4 Q4Nat
  norm_num [Polynomial.eval_map]

/-- Coefficients of the `ℤ`-cast of a natural-coefficient polynomial are nonnegative. -/
theorem coeffNonneg_map (p : Polynomial ℕ) : CoeffNonneg (p.map (Nat.castRingHom ℤ)) := by
  intro k
  rw [Polynomial.coeff_map, Nat.castRingHom]
  exact Int.natCast_nonneg _

/-- All coefficients of `P36` are nonnegative. -/
theorem coeffNonneg_P36 : CoeffNonneg P36 := coeffNonneg_map P36Nat

/-- All coefficients of `Q4` are nonnegative. -/
theorem coeffNonneg_Q4 : CoeffNonneg Q4 := coeffNonneg_map Q4Nat

end Phi6SquareDiceBaseCase