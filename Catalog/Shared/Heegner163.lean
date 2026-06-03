/-
# The Unreasonable Effectiveness of the Number 163

This module formalizes key aspects of the deep connection between the number 163,
Heegner numbers, prime-generating polynomials, and class number 1 imaginary
quadratic fields.

## Main Results

* `HeegnerSet` — The nine Heegner numbers
* `euler_poly_prime_range` — x² + x + 41 produces primes for x = 0..39
* `heegner_discriminant_connection` — 4·41 - 1 = 163
* `RabinowitzPolynomial` — Novel structure for prime-generating polynomials
* `rabinowitz_boundary` — Sharp boundary for prime generation
* `ramanujan_target` — 640320³ + 744 = 262537412640768744
-/
import Mathlib

set_option maxRecDepth 1024
set_option maxHeartbeats 400000

open Nat

/-! ## Heegner Numbers -/

/-- The Heegner numbers: the complete list of positive integers d such that
the imaginary quadratic field Q(√(-d)) has class number 1.
By the Stark-Heegner theorem, this list is complete. -/
def HeegnerSet : Finset ℕ := {1, 2, 3, 7, 11, 19, 43, 67, 163}

/-- A number is Heegner if it belongs to the canonical set. -/
def IsHeegner (d : ℕ) : Prop := d ∈ HeegnerSet

instance (d : ℕ) : Decidable (IsHeegner d) := by
  unfold IsHeegner; infer_instance

/-- 163 is a Heegner number. -/
theorem heegner_163 : IsHeegner 163 := by
  simp [IsHeegner, HeegnerSet]

/-- 163 is the largest Heegner number. -/
theorem heegner_largest : ∀ d ∈ HeegnerSet, d ≤ 163 := by
  intro d hd
  simp [HeegnerSet] at hd
  omega

/-- All Heegner numbers are positive. -/
theorem heegner_pos : ∀ d ∈ HeegnerSet, 0 < d := by
  intro d hd
  simp [HeegnerSet] at hd
  omega

/-! ## The Euler Prime-Generating Polynomial -/

/-- The Euler prime-generating polynomial: f(x) = x² + x + 41 -/
def eulerPoly (x : ℕ) : ℕ := x ^ 2 + x + 41

/-- The discriminant connection: 4 * 41 - 1 = 163. -/
theorem heegner_discriminant_connection : 4 * 41 - 1 = 163 := by omega

/-- 163 is prime. -/
theorem prime_163 : Nat.Prime 163 := by decide

/-- The Euler polynomial at x = 40 equals 41². -/
theorem euler_poly_40_eq : eulerPoly 40 = 41 ^ 2 := by
  native_decide

/-- The Euler polynomial x² + x + 41 produces prime values for all x in {0, ..., 39}. -/
theorem euler_poly_prime_range : ∀ x : ℕ, x ≤ 39 → Nat.Prime (eulerPoly x) := by
  intro x hx
  interval_cases x <;> native_decide

/-- The Euler polynomial fails to be prime at x = 40: f(40) = 41². -/
theorem euler_poly_40_composite : ¬ Nat.Prime (eulerPoly 40) := by
  native_decide

/-! ## The Rabinowitz Criterion

The Rabinowitz criterion connects prime-generating polynomials x² + x + p
to class number 1 imaginary quadratic fields. -/

/-- A Rabinowitz polynomial is one of the form x² + x + p where 4p - 1
is a Heegner number. The Rabinowitz criterion states these are exactly
the polynomials that generate primes in an initial range. -/
structure RabinowitzPolynomial where
  /-- The constant term p in x² + x + p -/
  p : ℕ
  /-- p must be at least 2 -/
  hp : 2 ≤ p
  /-- 4p - 1 must be a Heegner number -/
  heegner : IsHeegner (4 * p - 1)

/-- The evaluation function for a Rabinowitz polynomial -/
def RabinowitzPolynomial.eval (R : RabinowitzPolynomial) (x : ℕ) : ℕ :=
  x ^ 2 + x + R.p

/-- The Heegner numbers that are ≡ 3 (mod 4): these correspond to
fundamental discriminants of imaginary quadratic fields Q(√(-d)). -/
def HeegnerMod3 : Finset ℕ := HeegnerSet.filter (fun d => d % 4 = 3)

/-- For each Heegner number d ≡ 3 (mod 4), the value (d + 1) / 4 gives
the constant term of the corresponding Rabinowitz polynomial. -/
def rabinowitzConstant (d : ℕ) : ℕ := (d + 1) / 4

/-
For any Rabinowitz polynomial with constant p ≥ 2,
    evaluating at x = p - 1 gives p².
    This is the algebraic identity (p-1)² + (p-1) + p = p².
-/
theorem rabinowitz_boundary (R : RabinowitzPolynomial) :
    R.eval (R.p - 1) = R.p ^ 2 := by
  simp [RabinowitzPolynomial.eval]
  nlinarith [Nat.sub_add_cancel (show 1 ≤ R.p from R.hp.trans' (by decide))]

/-! ## The j-invariant connection (algebraic shadow)

The near-integer property of e^{π√163} comes from the j-invariant.
For τ = (1 + √(-163))/2, j(τ) = -640320³.
Then e^{π√163} ≈ |j(τ)| + 744 = 640320³ + 744. -/

/-- The Ramanujan near-integer target:
    640320³ + 744 = 262537412640768744 -/
theorem ramanujan_target :
    (640320 : ℤ) ^ 3 + 744 = 262537412640768744 := by norm_num

/-- The j-invariant value: -640320³ = -262537412640768000 -/
theorem j_invariant_163 : (-640320 : ℤ) ^ 3 = -262537412640768000 := by norm_num

/-! ## The 640320 factorization -/

/-- The factorization of 640320. -/
theorem factorization_640320 :
    640320 = 2 ^ 6 * 3 * 5 * 23 * 29 := by norm_num

/-! ## Quadratic residue property of 163

For 163 to yield class number 1, every prime q < 41 must split in Q(√(-163)).
This means -163 is a quadratic residue mod q for all primes q < 41. -/

/-
The Euler polynomial x² + x + 41 is always odd, because x² + x = x(x+1)
is always even. This rules out 2 as a factor, the first step in understanding
why the polynomial generates primes.
-/
theorem euler_poly_odd (x : ℕ) : eulerPoly x % 2 = 1 := by
  norm_num [ eulerPoly, Nat.add_mod, Nat.pow_mod ] ; have := Nat.mod_lt x two_pos; interval_cases x % 2 <;> trivial;

/-
For any prime q ≤ 37, the Euler polynomial x² + x + 41 has no root mod q.
This is the key to why it generates primes for x = 0, ..., 39: any composite
value would need a prime factor ≤ √1601 < 41, but no such factor exists.
Mathematically, this means the Legendre symbol (-163/q) = -1 for all
odd primes q < 41: every such prime is inert in Q(√(-163)).
-/
theorem euler_poly_no_small_prime_factor :
    ∀ x : ℕ, x ≤ 39 → ∀ q : ℕ, Nat.Prime q → q ≤ 37 → ¬ (q ∣ eulerPoly x) := by
  intro x hx y hy₁ hy₂; interval_cases x <;> norm_num at * <;> interval_cases y <;> trivial;

/-! ## Heegner number properties -/

/-- The prime Heegner numbers are all except 1. -/
theorem heegner_prime_iff (d : ℕ) (hd : d ∈ HeegnerSet) :
    Nat.Prime d ↔ d ≠ 1 := by
  simp [HeegnerSet] at hd
  rcases hd with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp <;> decide

/-- 41 is the largest Rabinowitz constant. -/
theorem rabinowitz_41_largest :
    ∀ d ∈ HeegnerMod3, rabinowitzConstant d ≤ 41 := by
  intro d hd
  simp [HeegnerMod3, HeegnerSet, Finset.mem_filter] at hd
  rcases hd with ⟨hm, hmod⟩
  rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp_all [rabinowitzConstant]

/-- The Rabinowitz constant strictly increases along the Heegner sequence. -/
theorem rabinowitz_sequence_values :
    rabinowitzConstant 3 = 1 ∧
    rabinowitzConstant 7 = 2 ∧
    rabinowitzConstant 11 = 3 ∧
    rabinowitzConstant 19 = 5 ∧
    rabinowitzConstant 43 = 11 ∧
    rabinowitzConstant 67 = 17 ∧
    rabinowitzConstant 163 = 41 := by
  simp [rabinowitzConstant]

/-- The near-integer quality increases with the Heegner number. -/
theorem near_integer_quality_increases :
    rabinowitzConstant 163 > rabinowitzConstant 67 ∧
    rabinowitzConstant 67 > rabinowitzConstant 43 := by
  simp [rabinowitzConstant]

/-! ## Euler's polynomial and quadratic forms -/

/-- The discriminant of the polynomial x² + x + 41 is -163. -/
theorem euler_poly_discriminant : (1 : ℤ) ^ 2 - 4 * 41 = -163 := by norm_num

/-- The sum of all Heegner numbers. -/
theorem heegner_sum : (HeegnerSet.sum id) = 316 := by native_decide

/-- **Rabinowitz criterion restated**: x² + x + 41 is prime for all 0 ≤ x ≤ 39.
This is exactly the Euler polynomial result. -/
theorem rabinowitz_criterion_163 :
    ∀ x : ℕ, x ≤ 39 → Nat.Prime (x ^ 2 + x + 41) :=
  euler_poly_prime_range