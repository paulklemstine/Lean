/-
# The flat class of ±-frames, and its sharp boundary

Combining the two structural symmetries

* prime inflation   `Φ_{np}(X) = Φ_n(X^p)`  (`p ∣ n`), and
* reflection        `Φ_{2n}(X) = Φ_n(-X)`   (`n` odd, `n > 1`),

with the two-parameter (Migotti) theorem of `Shared/PMFrameTwoParameter.lean` gives the sharp
flatness statement: `Φ_n` has all coefficients in `{-1,0,1}` as soon as the **odd part** of `n`
has at most two distinct prime divisors.  The boundary is genuine: `Φ₁₀₅` has a coefficient `-2`.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameFlatFamilies
import Algebra.PMFrameNegation
import Algebra.PMFrameTernaryBoundary

namespace PMFrameFlat

open Polynomial Finset PMFrame PMFrameNeg

/-- **Flatness of `2^a · m` for odd `m` with at most two prime divisors.** -/
theorem flatFrame_two_pow_mul {a m : ℕ} (hm : Odd m) (hcard : m.primeFactors.card ≤ 2) :
    FlatFrame (2 ^ a * m) := by
  have hm0 : m ≠ 0 := by
    rintro rfl
    rw [Nat.odd_iff] at hm
    omega
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.mpr hm0) with hm1 | hm1
  · -- `m = 1`: the order is a power of two
    rw [← hm1, mul_one]
    rcases Nat.eq_zero_or_pos a with rfl | ha
    · simpa using flatFrame_one
    · exact flatFrame_prime_pow Nat.prime_two ha
  · have hflatm : FlatFrame m := flatFrame_of_card_primeFactors_le_two hm0 hcard
    rcases a with _ | a'
    · simpa using hflatm
    · have hflat2m : FlatFrame (2 * m) := by
        intro k
        rw [abs_coeff_pmFrame_two_mul hm hm1 k]
        exact hflatm k
      have h := flatFrame_mul_prime_pow Nat.prime_two (Dvd.intro m rfl) hflat2m a'
      have hrw : 2 ^ (a' + 1) * m = (2 * m) * 2 ^ a' := by ring
      rwa [hrw]

/-- **Flatness classification.**  If the odd part of `n` has at most two distinct prime divisors
— equivalently, if `n` has at most two odd prime divisors — then every coefficient of `Φ_n`
lies in `{-1,0,1}`. -/
theorem flatFrame_of_card_odd_primeFactors_le_two {n : ℕ} (hn : n ≠ 0)
    (h : (n.primeFactors.erase 2).card ≤ 2) : FlatFrame n := by
  set a := n.factorization 2 with ha
  set m := n / 2 ^ a with hmdef
  have hsplit : 2 ^ a * m = n := Nat.ordProj_mul_ordCompl_eq_self n 2
  have hm0 : m ≠ 0 := (Nat.ordCompl_pos 2 hn).ne'
  have hmodd : Odd m := by
    have h2 : ¬ (2 ∣ m) := Nat.not_dvd_ordCompl Nat.prime_two hn
    rw [Nat.odd_iff]
    omega
  have hmpf : m.primeFactors = n.primeFactors.erase 2 := by
    have hfac := Nat.factorization_ordCompl n 2
    have := congrArg Finsupp.support hfac
    rwa [Nat.support_factorization, Finsupp.support_erase, Nat.support_factorization] at this
  rw [← hsplit]
  exact flatFrame_two_pow_mul hmodd (by rw [hmpf]; exact h)

/-- Trichotomy form of the classification. -/
theorem coeff_pmFrame_mem_of_card_odd_primeFactors_le_two {n : ℕ} (hn : n ≠ 0)
    (h : (n.primeFactors.erase 2).card ≤ 2) (k : ℕ) :
    (pmFrame n).coeff k = -1 ∨ (pmFrame n).coeff k = 0 ∨ (pmFrame n).coeff k = 1 := by
  have := flatFrame_of_card_odd_primeFactors_le_two hn h k
  rw [abs_le] at this
  omega

/-- Explicit form: `Φ_{2^a p^b q^c}` is flat for odd primes `p, q` (the proof does not need
`p ≠ q`: if `p = q` the odd part is a prime power, which is flat as well). -/
theorem flatFrame_two_pow_mul_prime_pow_mul_prime_pow {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpodd : Odd p) (hqodd : Odd q) {a b c : ℕ} (hb : 1 ≤ b) (hc : 1 ≤ c) :
    FlatFrame (2 ^ a * (p ^ b * q ^ c)) := by
  refine flatFrame_two_pow_mul (Odd.mul (hpodd.pow) (hqodd.pow)) ?_
  have hpf : (p ^ b * q ^ c).primeFactors = {p, q} := by
    rw [Nat.primeFactors_mul (pow_ne_zero _ hp.pos.ne') (pow_ne_zero _ hq.pos.ne'),
      Nat.primeFactors_pow p (by omega), Nat.primeFactors_pow q (by omega),
      hp.primeFactors, hq.primeFactors]
    rfl
  rw [hpf]
  exact le_trans (Finset.card_insert_le _ _) (by simp)

/-! ## Sharpness of the classification -/

theorem primeFactors_105 : (105 : ℕ).primeFactors = {3, 5, 7} := by
  have h : (105 : ℕ) = 3 * (5 * 7) := by norm_num
  rw [h, Nat.primeFactors_mul (by norm_num) (by norm_num),
    Nat.primeFactors_mul (by norm_num) (by norm_num),
    Nat.Prime.primeFactors (by norm_num), Nat.Prime.primeFactors (by norm_num),
    Nat.Prime.primeFactors (by norm_num)]
  rfl

theorem not_flatFrame_105 : ¬ FlatFrame 105 := by
  intro h
  have h7 := h 7
  rw [PMFrameTernary.coeff_pmFrame_105_seven] at h7
  norm_num at h7

/-- **The classification is sharp.**  There is an order whose odd part has three prime divisors
whose ±-frame is not flat, namely `n = 105 = 3 · 5 · 7`. -/
theorem flatness_classification_sharp :
    ∃ n : ℕ, n ≠ 0 ∧ (n.primeFactors.erase 2).card = 3 ∧ ¬ FlatFrame n := by
  refine ⟨105, by norm_num, ?_, not_flatFrame_105⟩
  rw [primeFactors_105]
  decide

end PMFrameFlat