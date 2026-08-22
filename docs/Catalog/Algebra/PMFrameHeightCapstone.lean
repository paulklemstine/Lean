/-
# An infinite family of ±-frames of height exactly two

Height reduction (`Algebra/PMFrameHeightReduction.lean`) says that the coefficient bound of `Φ_n`
depends only on the odd radical of `n`; the explicit computation of `Φ₁₀₅`
(`Algebra/PMFrame105Explicit.lean`) pins that bound down for the odd radical `105`.  Combining the
two determines the height of every order of the shape `2^a 3^b 5^c 7^d` (`b, c, d ≥ 1`): it is
exactly `2`.  In particular none of these frames is flat, while every order whose odd part has at
most two prime divisors is flat — the two results together delimit the flat class from both sides.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameFlatFamilies
import Algebra.PMFrameFlatClassification
import Algebra.PMFrame105Explicit
import Algebra.PMFrameHeightReduction

namespace PMFrameHeight

open Polynomial Finset PMFrame PMFrameFlat

/-! ## 1. Odd radicals of the family `2^a 3^b 5^c 7^d` -/

theorem oddRad_mul_prime_pow {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) (hn : n ≠ 0) :
    ∀ c : ℕ, oddRad (n * p ^ c) = oddRad n := by
  intro c
  induction c with
  | zero => simp
  | succ c ih =>
      have hrw : n * p ^ (c + 1) = (n * p ^ c) * p := by ring
      have hne : n * p ^ c ≠ 0 := by
        exact Nat.mul_ne_zero hn (pow_ne_zero _ hp.pos.ne')
      rw [hrw, oddRad_mul_prime hp (Dvd.dvd.mul_right hdvd _) hne, ih]

theorem oddRad_two_pow_mul {m : ℕ} (hm : m ≠ 0) : ∀ a : ℕ, oddRad (2 ^ a * m) = oddRad m := by
  intro a
  induction a with
  | zero => simp
  | succ a ih =>
      have hrw : 2 ^ (a + 1) * m = 2 * (2 ^ a * m) := by ring
      rw [hrw, oddRad_two_mul (Nat.mul_ne_zero (pow_ne_zero _ (by norm_num)) hm), ih]

theorem oddRad_105 : oddRad 105 = 105 := by
  rw [oddRad, PMFrameFlat.primeFactors_105]
  decide

/-- The odd radical of `2^a 3^{b+1} 5^{c+1} 7^{d+1}` is `105`. -/
theorem oddRad_family (a b c d : ℕ) :
    oddRad (2 ^ a * (3 ^ (b + 1) * (5 ^ (c + 1) * 7 ^ (d + 1)))) = 105 := by
  have h105 : (105 : ℕ) ≠ 0 := by norm_num
  have h3 : ((105 : ℕ) * 3 ^ b) ≠ 0 := by positivity
  have h5 : ((105 : ℕ) * 3 ^ b * 5 ^ c) ≠ 0 := by positivity
  have hrw : 3 ^ (b + 1) * (5 ^ (c + 1) * 7 ^ (d + 1)) = 105 * 3 ^ b * 5 ^ c * 7 ^ d := by
    ring
  rw [hrw, oddRad_two_pow_mul (by positivity),
    oddRad_mul_prime_pow (p := 7) (by norm_num) ⟨15 * 3 ^ b * 5 ^ c, by ring⟩ h5,
    oddRad_mul_prime_pow (p := 5) (by norm_num) ⟨21 * 3 ^ b, by ring⟩ h3,
    oddRad_mul_prime_pow (p := 3) (by norm_num) ⟨35, by norm_num⟩ h105,
    oddRad_105]

/-! ## 2. The height of the family is exactly two -/

/-- **Height two for the whole family.**  For all `a b c d`, the frame of the order
`2^a 3^{b+1} 5^{c+1} 7^{d+1}` has least coefficient bound `2`. -/
theorem isLeast_height_family (a b c d : ℕ) :
    IsLeast {B : ℤ | FrameBoundedBy (2 ^ a * (3 ^ (b + 1) * (5 ^ (c + 1) * 7 ^ (d + 1)))) B} 2 := by
  have hn0 : (2 ^ a * (3 ^ (b + 1) * (5 ^ (c + 1) * 7 ^ (d + 1)))) ≠ 0 := by positivity
  have hiff := frameBoundedBy_iff_oddRad _ hn0
  constructor
  · rw [Set.mem_setOf_eq, hiff 2, oddRad_family a b c d]
    exact PMFrame105.abs_coeff_pmFrame_105_le_two
  · intro B hB
    rw [Set.mem_setOf_eq, hiff B, oddRad_family a b c d] at hB
    have h7 := hB 7
    rw [PMFrame105.coeff_pmFrame_105_eq_neg_two.1] at h7
    simpa using h7

/-- None of the frames in that family is flat. -/
theorem not_flatFrame_family (a b c d : ℕ) :
    ¬ FlatFrame (2 ^ a * (3 ^ (b + 1) * (5 ^ (c + 1) * 7 ^ (d + 1)))) := by
  intro h
  have hmem : (1 : ℤ) ∈ {B : ℤ | FrameBoundedBy
      (2 ^ a * (3 ^ (b + 1) * (5 ^ (c + 1) * 7 ^ (d + 1)))) B} := h
  have := (isLeast_height_family a b c d).2 hmem
  norm_num at this

/-- The dichotomy at three odd primes: with at most two odd prime divisors the frame is flat, and
for the family `2^a 3^b 5^c 7^d` (three odd prime divisors) it never is. -/
theorem flat_dichotomy (a b c d : ℕ) {m : ℕ} (hm : m ≠ 0)
    (hm2 : (m.primeFactors.erase 2).card ≤ 2) :
    FlatFrame m ∧ ¬ FlatFrame (2 ^ a * (3 ^ (b + 1) * (5 ^ (c + 1) * 7 ^ (d + 1)))) :=
  ⟨flatFrame_of_card_odd_primeFactors_le_two hm hm2, not_flatFrame_family a b c d⟩

end PMFrameHeight