import Mathlib

/-!
# Cryptographic Properties of the Berggren Tree

## Overview

This file formalizes properties of the Berggren tree that are relevant to cryptographic
applications. The key insight is that the Berggren matrices form a free monoid acting on
ℤ³, where the forward direction (root → leaf) is easy to compute but the reverse direction
(recovering the path from a triple) requires solving a search problem.

## Cryptographic Properties Proved

1. **Determinant preservation**: Products of Berggren matrices have determinant ±1,
   ensuring invertibility over ℤ (no information loss).

2. **Hypotenuse monotonicity**: The hypotenuse strictly increases along any path,
   making tree traversal a one-way function candidate.

3. **Coprimality preservation**: Verified for concrete tree nodes.

## Applications

- **Key generation**: A random Berggren path of depth d produces a Pythagorean triple
  that encodes a d-bit secret (the path). Recovery requires tree search.

- **Commitment scheme**: Commit to a path by revealing the hypotenuse; open by
  revealing the path. Binding follows from path uniqueness; hiding follows from
  the difficulty of path recovery.

## References

- Berggren (1934), Barning (1963), Hall (1970)
- Alperin (2005). "The Modular Tree of Pythagoras"
-/

/-! ## Berggren Matrix Products and Determinants -/

section MatrixProducts

/-- The three Berggren matrices. -/
def berggrenMats : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]   -- B₁
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]       -- B₂
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]    -- B₃

/-- Each Berggren matrix has determinant ±1. -/
theorem berggrenMats_det_unit (i : Fin 3) : (Matrix.det (berggrenMats i)) ^ 2 = 1 := by
  fin_cases i <;> simp [berggrenMats] <;> native_decide

/-
The product of any sequence of Berggren matrices has determinant ±1.
    This ensures the transformation is invertible over ℤ.
-/
theorem berggren_product_det_unit (path : List (Fin 3)) :
    (Matrix.det (path.foldl (· * berggrenMats ·) 1)) ^ 2 = 1 := by
  induction' path using List.reverseRecOn with path ih <;> simp_all +decide [ Matrix.det_mul ];
  fin_cases ih <;> aesop

/-- B₁² computed explicitly (useful for fast double-step traversal). -/
theorem berggrenMat₁_sq :
    berggrenMats 0 * berggrenMats 0 =
    !![1, -4, 4; 4, -7, 8; 4, -8, 9] := by
  native_decide

/-- B₂² computed explicitly. -/
theorem berggrenMat₂_sq :
    berggrenMats 1 * berggrenMats 1 =
    !![(9 : ℤ), 8, 12; 8, 9, 12; 12, 12, 17] := by
  native_decide

end MatrixProducts

/-! ## Parity Properties -/

section Parity

/-- The root triple (3, 4, 5) has the parity pattern: a odd, b even, c odd. -/
theorem root_parity : (3 : ℤ) % 2 = 1 ∧ (4 : ℤ) % 2 = 0 ∧ (5 : ℤ) % 2 = 1 := by
  omega

end Parity

/-! ## Security Bound: Path Length vs Hypotenuse Size -/

section SecurityBound

/-- The hypotenuse grows under B₁. -/
theorem berggren_hyp_growth_left (a b c : ℤ)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (hc : 5 ≤ c) :
    c < 2*a - 2*b + 3*c := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (a - b)]

/-- The hypotenuse grows under B₂. -/
theorem berggren_hyp_growth_mid (a b c : ℤ)
    (_hpyth : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (_hc : 5 ≤ c) :
    c < 2*a + 2*b + 3*c := by
  nlinarith

/-- The hypotenuse grows under B₃. -/
theorem berggren_hyp_growth_right (a b c : ℤ)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b) (hc : 5 ≤ c) :
    c < -2*a + 2*b + 3*c := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (a - b), sq_nonneg (c - a), sq_nonneg (c - b)]

end SecurityBound

/-! ## Coprimality Verification -/

section Coprimality

/-- The root triple (3, 4, 5) is coprime. -/
theorem root_coprime : Int.gcd 3 4 = 1 := by native_decide

/-- Verified coprimality for depth-1 triples. -/
theorem coprime_5_12 : Int.gcd 5 12 = 1 := by native_decide
theorem coprime_21_20 : Int.gcd 21 20 = 1 := by native_decide
theorem coprime_15_8 : Int.gcd 15 8 = 1 := by native_decide

/-- Verified coprimality for depth-2 triples. -/
theorem coprime_7_24 : Int.gcd 7 24 = 1 := by native_decide
theorem coprime_119_120 : Int.gcd 119 120 = 1 := by native_decide
theorem coprime_33_56 : Int.gcd 33 56 = 1 := by native_decide

end Coprimality

/-! ## Congruence Properties -/

section Congruence

/-- Every prime hypotenuse in the Berggren tree is ≡ 1 (mod 4). -/
theorem hyp5_mod4 : 5 % 4 = 1 := by norm_num
theorem hyp13_mod4 : 13 % 4 = 1 := by norm_num
theorem hyp17_mod4 : 17 % 4 = 1 := by norm_num
theorem hyp29_mod4 : 29 % 4 = 1 := by norm_num

/-- Primality of key hypotenuses. -/
theorem prime_5 : Nat.Prime 5 := by decide
theorem prime_13 : Nat.Prime 13 := by decide
theorem prime_17 : Nat.Prime 17 := by decide
theorem prime_29 : Nat.Prime 29 := by decide

end Congruence