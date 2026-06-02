import Mathlib

/-!
# Ramanujan's Taxicab Number: Sums of Two and Three Cubes

This file formalizes key properties of 1729, the Hardy-Ramanujan taxicab number.

## Main results

* `taxicab_1729`: A `TaxicabWitness` packaging the two representations
  1729 = 1³ + 12³ = 9³ + 10³ with a proof of distinctness.
* `taxicab_three_cube_nontrivial`: 1729 = (-7)³ + (-5)³ + 13³, a nontrivial
  three-cube representation with all terms nonzero.
* `three_cube_inversion`: A general algebraic principle for constructing
  three-cube representations from two-cube decompositions of an overshoot.
* `no_sum_three_cubes_mod9_eq4/5`: The mod-9 obstruction for sums of three cubes.
* `three_cube_from_two_cube_overshoot`: A reduction theorem showing how to
  systematically construct nontrivial three-cube representations.

## Key discovery

The initial conjecture that 1729 has no nontrivial three-cube representation
is **refuted**: (-7)³ + (-5)³ + 13³ = -343 + (-125) + 2197 = 1729.
The three-cube inversion principle explains WHY this works: 13³ - 1729 = 468 = 7³ + 5³.
-/

/-! ## Definitions -/

/-- A representation of a natural number as a sum of two positive cubes. -/
structure SumTwoCubesRep (n : ℕ) where
  a : ℕ
  b : ℕ
  ha : 0 < a
  hb : 0 < b
  hab : a ≤ b
  sum_eq : a ^ 3 + b ^ 3 = n

/-- A `TaxicabWitness` packages a number with two distinct representations
as a sum of two positive cubes, together with a proof that the pairs are
genuinely different. This captures the essential structure of taxicab numbers. -/
structure TaxicabWitness (n : ℕ) where
  rep1 : SumTwoCubesRep n
  rep2 : SumTwoCubesRep n
  distinct : rep1.a ≠ rep2.a

/-- A `NontrivialThreeCubeRep` witnesses that n = x³ + y³ + z³ with all
three summands nonzero. -/
structure NontrivialThreeCubeRep (n : ℤ) where
  x : ℤ
  y : ℤ
  z : ℤ
  hx : x ≠ 0
  hy : y ≠ 0
  hz : z ≠ 0
  sum_eq : x ^ 3 + y ^ 3 + z ^ 3 = n

/-- A number has taxicab order at least k if it has k distinct representations
as a sum of two positive cubes. -/
def HasTaxicabOrder (n : ℕ) (k : ℕ) : Prop :=
  ∃ reps : Fin k → SumTwoCubesRep n,
    ∀ i j : Fin k, i ≠ j → (reps i).a ≠ (reps j).a

/-! ## The Taxicab Property of 1729 -/

/-- 1729 has the taxicab property: it admits two distinct representations
as a sum of two positive cubes: 1³ + 12³ and 9³ + 10³. -/
def taxicab_1729 : TaxicabWitness 1729 where
  rep1 := ⟨1, 12, by omega, by omega, by omega, by norm_num⟩
  rep2 := ⟨9, 10, by omega, by omega, by omega, by norm_num⟩
  distinct := by decide

/-- 1729 has taxicab order at least 2. -/
theorem taxicab_1729_order_two : HasTaxicabOrder 1729 2 := by
  refine ⟨![⟨1, 12, by omega, by omega, by omega, by norm_num⟩,
           ⟨9, 10, by omega, by omega, by omega, by norm_num⟩], ?_⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [Matrix.cons_val_zero, Matrix.cons_val_one]

/-! ## Three-Cube Representation -/

/-- 1729 has a nontrivial representation as a sum of three cubes
with all terms nonzero: 1729 = (-7)³ + (-5)³ + 13³. -/
def taxicab_three_cube_nontrivial : NontrivialThreeCubeRep 1729 where
  x := -7
  y := -5
  z := 13
  hx := by omega
  hy := by omega
  hz := by omega
  sum_eq := by norm_num

/-! ## Cube Residues Modulo 9 -/

/-- Every integer cube is congruent to 0, 1, or 8 modulo 9. -/
theorem cube_mod_nine (x : ℤ) : x ^ 3 % 9 = 0 ∨ x ^ 3 % 9 = 1 ∨ x ^ 3 % 9 = 8 := by
  have h1 : 0 ≤ x % 9 := Int.emod_nonneg x (by norm_num)
  have h2 : x % 9 < 9 := Int.emod_lt_of_pos x (by norm_num)
  have key : x ^ 3 % 9 = (x % 9) ^ 3 % 9 := by
    conv_lhs => rw [show x = 9 * (x / 9) + x % 9 from (Int.mul_ediv_add_emod x 9).symm]
    ring_nf; omega
  rw [key]
  interval_cases (x % 9) <;> norm_num

/-- No integer ≡ 4 (mod 9) can be written as a sum of three cubes.
This is a fundamental obstruction in the sum-of-three-cubes problem. -/
theorem no_sum_three_cubes_mod9_eq4 (n : ℤ) (hn : n % 9 = 4)
    (x y z : ℤ) : x ^ 3 + y ^ 3 + z ^ 3 ≠ n := by
  intro h
  have := cube_mod_nine x
  have := cube_mod_nine y
  have := cube_mod_nine z
  omega

/-- No integer ≡ 5 (mod 9) can be written as a sum of three cubes. -/
theorem no_sum_three_cubes_mod9_eq5 (n : ℤ) (hn : n % 9 = 5)
    (x y z : ℤ) : x ^ 3 + y ^ 3 + z ^ 3 ≠ n := by
  intro h
  have := cube_mod_nine x
  have := cube_mod_nine y
  have := cube_mod_nine z
  omega

/-- 1729 ≡ 1 (mod 9), so it is not obstructed from being a sum of three cubes. -/
theorem taxicab_1729_mod9 : (1729 : ℤ) % 9 = 1 := by norm_num

/-! ## Algebraic Structure -/

/-- The factorization identity: a³ + b³ = (a + b)(a² - ab + b²). -/
theorem cube_sum_factor (a b : ℤ) :
    a ^ 3 + b ^ 3 = (a + b) * (a ^ 2 - a * b + b ^ 2) := by ring

/-- 1729 = 13 · 133 via the first representation 1³ + 12³. -/
theorem taxicab_factor_rep1 :
    (1 + 12) * (1 ^ 2 - 1 * 12 + 12 ^ 2) = (1729 : ℤ) := by norm_num

/-- 1729 = 19 · 91 via the second representation 9³ + 10³. -/
theorem taxicab_factor_rep2 :
    (9 + 10) * (9 ^ 2 - 9 * 10 + 10 ^ 2) = (1729 : ℤ) := by norm_num

/-- 1729 = 7 × 13 × 19 (prime factorization). -/
theorem taxicab_factorization : (1729 : ℕ) = 7 * 13 * 19 := by norm_num

/-! ## Three-Cube Inversion Principle -/

/-- **Three-Cube Inversion Principle**: If c³ - n = a'³ + b'³,
then n = (-a')³ + (-b')³ + c³. This provides a systematic method
for constructing three-cube representations from two-cube decompositions
of the "overshoot" c³ - n. -/
theorem three_cube_inversion {n a' b' c : ℤ}
    (h_overshoot : c ^ 3 - n = a' ^ 3 + b' ^ 3) :
    (-a') ^ 3 + (-b') ^ 3 + c ^ 3 = n := by
  have h1 : (-a') ^ 3 = -(a' ^ 3) := by ring
  have h2 : (-b') ^ 3 = -(b' ^ 3) := by ring
  linarith

/-- Application to 1729: since 13³ - 1729 = 468 = 7³ + 5³, the inversion
principle yields 1729 = (-7)³ + (-5)³ + 13³. -/
theorem taxicab_via_inversion :
    (-7 : ℤ) ^ 3 + (-5 : ℤ) ^ 3 + 13 ^ 3 = 1729 :=
  three_cube_inversion (by norm_num : (13 : ℤ) ^ 3 - 1729 = 7 ^ 3 + 5 ^ 3)

/-- 13³ - 1729 = 468 = 7³ + 5³. The overshoot of the dominant positive
cube decomposes as a sum of two cubes involving prime factors of 1729. -/
theorem three_cube_overshoot :
    (13 : ℤ) ^ 3 - 1729 = 7 ^ 3 + 5 ^ 3 := by norm_num

/-- The dominant cube in the three-cube representation exceeds the target. -/
theorem three_cube_exceeds_target : (13 : ℤ) ^ 3 > 1729 := by norm_num

/-! ## Nontrivial Three-Cube Rep via Inversion Construction -/

/-- Construct a nontrivial three-cube representation from the inversion principle. -/
def NontrivialThreeCubeRep.fromInversion {n : ℤ} {a b c : ℤ}
    (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0)
    (h : c ^ 3 - n = a ^ 3 + b ^ 3) : NontrivialThreeCubeRep n where
  x := -a
  y := -b
  z := c
  hx := neg_ne_zero.mpr ha
  hy := neg_ne_zero.mpr hb
  hz := hc
  sum_eq := three_cube_inversion h

/-- The 1729 three-cube representation via the inversion construction. -/
def taxicab_1729_from_inversion : NontrivialThreeCubeRep 1729 :=
  NontrivialThreeCubeRep.fromInversion
    (by omega : (7 : ℤ) ≠ 0)
    (by omega : (5 : ℤ) ≠ 0)
    (by omega : (13 : ℤ) ≠ 0)
    (by norm_num : (13 : ℤ) ^ 3 - 1729 = 7 ^ 3 + 5 ^ 3)

/-! ## Carmichael Connection -/

/-- Korselt's criterion for 1729: each prime factor p satisfies (p-1) | 1728. -/
theorem korselt_1729 :
    (6 : ℕ) ∣ 1728 ∧ (12 : ℕ) ∣ 1728 ∧ (18 : ℕ) ∣ 1728 :=
  ⟨⟨288, by norm_num⟩, ⟨144, by norm_num⟩, ⟨96, by norm_num⟩⟩

/-- 1729 - 1 = 12³, connecting the Carmichael property back to cubes. -/
theorem carmichael_cube_connection : (1729 : ℕ) - 1 = 12 ^ 3 := by norm_num

/-! ## Reduction Theorem -/

/-- The three-cube inversion principle reduces nontrivial three-cube
representability to two-cube representability of overshoots.
If for some nonzero c, the overshoot c³ - n is a sum of two nonzero cubes,
then n has a nontrivial three-cube representation. -/
theorem three_cube_from_two_cube_overshoot {n : ℤ} {c : ℤ}
    (hc : c ≠ 0)
    (h : ∃ a b : ℤ, a ≠ 0 ∧ b ≠ 0 ∧ a ^ 3 + b ^ 3 = c ^ 3 - n) :
    ∃ x y z : ℤ, x ≠ 0 ∧ y ≠ 0 ∧ z ≠ 0 ∧ x ^ 3 + y ^ 3 + z ^ 3 = n := by
  obtain ⟨a, b, ha, hb, hab⟩ := h
  exact ⟨-a, -b, c, neg_ne_zero.mpr ha, neg_ne_zero.mpr hb, hc,
    three_cube_inversion (by linarith)⟩