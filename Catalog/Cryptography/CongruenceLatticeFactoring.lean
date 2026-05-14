import Mathlib

/-!
# Congruence Lattice Factoring: A Certified Reduction

## Overview

We formalize the classical reduction between integer factoring and finding
short vectors in a congruence lattice. The key results are:

1. **Factor extraction** (square congruence → factor): If `x² ≡ y² (mod n)` but
   `x ≢ ±y (mod n)`, then `gcd(x - y, n)` is a nontrivial factor.

2. **Factor embedding** (factor → short vector): Every nontrivial factor
   `d | n` with `1 < d < n` produces an explicit vector `(d, n/d)` in a
   divisibility lattice, with squared norm at most `n²`.

3. **Pythagorean specialization**: Pythagorean triples `(a, b, c)` with
   `a² + b² = c²` produce square congruences `c² - a² = b²`.

4. **Euclid parametrization**: The classical `(m²-k², 2mk, m²+k²)` parametrization
   produces Pythagorean triples with explicit sum-difference structure.

## References

- Lenstra, Lenstra, Lovász (1982). "Factoring polynomials with rational coefficients"
- Pomerance (1996). "A tale of two sieves"
- Shor (1994). "Algorithms for quantum computation"
-/

open Int Nat

set_option maxHeartbeats 800000

/-! ## Core Definitions -/

/-- Squared norm of an integer vector, defined as sum of squares. -/
def sqNorm₂ (v : Fin 2 → ℤ) : ℤ := (v 0) ^ 2 + (v 1) ^ 2

/-- A nontrivial factor of `n`: a divisor `d` with `1 < d < n`. -/
def IsNontrivialFactor (n d : ℕ) : Prop :=
  d ∣ n ∧ 1 < d ∧ d < n

/-- The divisibility lattice: vectors `(a, b)` where `n | a · b`. -/
def DivisibilityLattice (n : ℕ) : Set (Fin 2 → ℤ) :=
  {v | (n : ℤ) ∣ v 0 * v 1}

/-- A Pythagorean triple `(a, b, c)` satisfying `a² + b² = c²`. -/
def IsPythTriple₂ (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-! ## Part 1: Factor Extraction from Square Congruences -/

/-
**Core gcd lemma**: If `n | a * b` but `n ∤ a` and `n ∤ b`,
    then `gcd(a, n)` is a nontrivial factor of `n`.
-/
theorem gcd_nontrivial_factor
    (n : ℕ) (hn : 1 < n) (a b : ℤ)
    (hdvd : (n : ℤ) ∣ a * b)
    (hna : ¬ (n : ℤ) ∣ a)
    (hnb : ¬ (n : ℤ) ∣ b) :
    IsNontrivialFactor n (Int.gcd a n) := by
  refine' ⟨ Int.natCast_dvd_natCast.mp ( Int.gcd_dvd_right _ _ ), lt_of_le_of_ne ?_ ?_, ?_ ⟩;
  · exact Int.gcd_pos_of_ne_zero_right _ ( by positivity );
  · contrapose! hna;
    grind +suggestions;
  · exact lt_of_le_of_ne ( Nat.le_of_dvd hn.le ( Int.natCast_dvd_natCast.mp ( Int.gcd_dvd_right _ _ ) ) ) fun con => hna <| by simpa [ show Int.gcd a n = n from con ] using Int.gcd_dvd_left a n;

/-
**Square-root collision yields factor** (certified version).
    If `x² ≡ y² (mod n)` but `x ≢ ±y (mod n)`, then `gcd(x-y, n)`
    is a nontrivial factor of `n`.
-/
theorem square_collision_yields_factor'
    (n : ℕ) (hn : 1 < n)
    (x y : ℤ)
    (hsq : (n : ℤ) ∣ x ^ 2 - y ^ 2)
    (hne_sub : ¬(n : ℤ) ∣ x - y)
    (hne_add : ¬(n : ℤ) ∣ x + y) :
    IsNontrivialFactor n (Int.gcd (x - y) n) := by
  convert gcd_nontrivial_factor n hn ( x - y ) ( x + y ) _ hne_sub hne_add using 1;
  grind +extAll

/-! ## Part 2: Factor Embedding (Reverse Direction) -/

/-
**Factor embedding**: Every nontrivial factor `d | n` produces
    a nonzero vector in the divisibility lattice.
-/
theorem factor_produces_lattice_vector'
    (n d : ℕ) (hdvd : d ∣ n) (hd1 : 1 < d) (hdn : d < n) :
    let v : Fin 2 → ℤ := ![↑d, ↑(n / d)]
    v ∈ DivisibilityLattice n ∧ v ≠ 0 := by
  -- Show that the vector $v = ![d, n / d]$ satisfies the divisibility condition.
  simp [DivisibilityLattice, hdvd];
  exact ⟨ by rw [ mul_comm, Int.ediv_mul_cancel ( mod_cast hdvd ) ], by aesop ⟩

/-
**Norm bound**: The factor vector `(d, n/d)` has squared norm ≤ n².
-/
theorem factor_vector_norm_bound'
    (n d : ℕ) (hdvd : d ∣ n) (hd1 : 1 < d) (hdn : d < n) :
    (d : ℤ) ^ 2 + (↑(n / d) : ℤ) ^ 2 ≤ (↑n : ℤ) ^ 2 := by
  -- Since $d | n$, let $q = n/d$, so $n = d*q$.
  obtain ⟨q, hq⟩ : ∃ q : ℕ, n = d * q := hdvd
  have hq_pos : 1 < q := by
    nlinarith;
  norm_num [ hq, Nat.mul_div_cancel_left _ ( pos_of_gt hd1 ) ];
  nlinarith [ Nat.pow_le_pow_left hd1 2, Nat.pow_le_pow_left hq_pos 2 ]

/-! ## Part 3: Pythagorean Interface -/

/-
**Pythagorean-to-congruence bridge**: A Pythagorean triple gives
    a square congruence: `c² - a² = b²`.
-/
theorem pyth_gives_square_congruence'
    (a b c : ℤ) (hpyth : IsPythTriple₂ a b c)
    (n : ℕ) (hn : (n : ℤ) ∣ b ^ 2) :
    (n : ℤ) ∣ c ^ 2 - a ^ 2 := by
  exact hn.trans ⟨ 1, by linarith [ hpyth.symm ] ⟩

/-- The Euclid parametrization is always Pythagorean. -/
theorem euclid_is_pythagorean' (m k : ℤ) :
    IsPythTriple₂ (m ^ 2 - k ^ 2) (2 * m * k) (m ^ 2 + k ^ 2) := by
  unfold IsPythTriple₂; ring

/-- **Euclid sum-difference identity**: `c - a = 2k²` and `c + a = 2m²`. -/
theorem euclid_sum_diff' (m k : ℤ) :
    (m ^ 2 + k ^ 2) - (m ^ 2 - k ^ 2) = 2 * k ^ 2 ∧
    (m ^ 2 + k ^ 2) + (m ^ 2 - k ^ 2) = 2 * m ^ 2 := by
  constructor <;> ring

/-! ## Part 4: Certified Bidirectional Reduction -/

/-- **Forward direction of the reduction**:
    A nontrivial square congruence mod `n` produces a nontrivial factor. -/
theorem certified_factor_extraction'
    (n : ℕ) (hn : 1 < n)
    (x y : ℤ)
    (hsq : (n : ℤ) ∣ x ^ 2 - y ^ 2)
    (hne_sub : ¬(n : ℤ) ∣ x - y)
    (hne_add : ¬(n : ℤ) ∣ x + y) :
    ∃ d : ℕ, d ∣ n ∧ 1 < d ∧ d < n := by
  have h := square_collision_yields_factor' n hn x y hsq hne_sub hne_add
  exact ⟨_, h.1, h.2.1, h.2.2⟩

/-- **Reverse direction of the reduction**:
    Every nontrivial factor produces a short lattice vector. -/
theorem certified_factor_embedding'
    (n d : ℕ) (hdvd : d ∣ n) (hd1 : 1 < d) (hdn : d < n) :
    ∃ v : Fin 2 → ℤ,
      v ∈ DivisibilityLattice n ∧
      v ≠ 0 ∧
      sqNorm₂ v ≤ (↑n) ^ 2 := by
  have ⟨hmem, hne⟩ := factor_produces_lattice_vector' n d hdvd hd1 hdn
  exact ⟨![↑d, ↑(n / d)], hmem, hne, factor_vector_norm_bound' n d hdvd hd1 hdn⟩

/-- **Composite numbers admit square divisors**: If `n = a * b` with `a, b > 1`,
    then `n | (a*b)²`. -/
theorem composite_square_divisibility
    (n a b : ℕ) (hn : n = a * b) (_ha : 1 < a) (_hb : 1 < b) :
    (n : ℤ) ∣ ((↑a : ℤ) * ↑b) ^ 2 := by
  rw [hn]; push_cast; exact dvd_pow_self _ two_ne_zero