/-
# Height reduction: the coefficient bound of a ±-frame depends only on the odd radical

The two structural symmetries

* prime inflation `Φ_{np}(X) = Φ_n(X^p)` for `p ∣ n`, and
* reflection `Φ_{2n}(X) = Φ_n(-X)` for odd `n > 1`

each preserve the multiset of absolute values of the coefficients.  Iterating them collapses an
arbitrary order `n` onto its **odd radical** `oddRad n = ∏ {p : p ∣ n, p odd prime}`:

    (∀ k, |Φ_n.coeff k| ≤ B)  ↔  (∀ k, |Φ_{oddRad n}.coeff k| ≤ B).

So every height question about cyclotomic polynomials reduces to squarefree odd orders — the flat
classification and the boundary example `Φ₁₀₅` are then two sides of one statement.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameFlatFamilies
import Algebra.PMFrameNegation

namespace PMFrameHeight

open Polynomial Finset PMFrame PMFrameFlat PMFrameNeg

/-- `Φ_n` has all coefficients bounded in absolute value by `B`. -/
def FrameBoundedBy (n : ℕ) (B : ℤ) : Prop := ∀ k : ℕ, |(pmFrame n).coeff k| ≤ B

/-- The **odd radical** of `n`: the product of the odd primes dividing `n`. -/
def oddRad (n : ℕ) : ℕ := ∏ p ∈ n.primeFactors.erase 2, p

theorem frameBoundedBy_nonneg {n : ℕ} {B : ℤ} (h : FrameBoundedBy n B) : 0 ≤ B :=
  le_trans (abs_nonneg _) (h 0)

/-! ## 1. Invariance under prime inflation -/

theorem coeff_pmFrame_mul_prime_mul {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) (k : ℕ) :
    (pmFrame (n * p)).coeff (k * p) = (pmFrame n).coeff k := by
  rw [coeff_pmFrame_mul_prime hp hdvd, if_pos (Dvd.intro_left k rfl),
    Nat.mul_div_cancel _ hp.pos]

theorem frameBoundedBy_mul_prime_iff {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) (B : ℤ) :
    FrameBoundedBy (n * p) B ↔ FrameBoundedBy n B := by
  constructor
  · intro h k
    have hk := h (k * p)
    rwa [coeff_pmFrame_mul_prime_mul hp hdvd k] at hk
  · intro h k
    have hB : 0 ≤ B := frameBoundedBy_nonneg h
    rw [coeff_pmFrame_mul_prime hp hdvd k]
    split
    · exact h _
    · simpa using hB

/-! ## 2. Invariance under reflection -/

theorem frameBoundedBy_two_mul_iff {m : ℕ} (hm : Odd m) (hm1 : 1 < m) (B : ℤ) :
    FrameBoundedBy (2 * m) B ↔ FrameBoundedBy m B := by
  constructor <;> intro h k
  · have hk := h k
    rwa [abs_coeff_pmFrame_two_mul hm hm1 k] at hk
  · rw [abs_coeff_pmFrame_two_mul hm hm1 k]
    exact h k

theorem frameBoundedBy_two_iff (B : ℤ) : FrameBoundedBy 2 B ↔ FrameBoundedBy 1 B := by
  have habs : ∀ k : ℕ, |(pmFrame 2).coeff k| = |(pmFrame 1).coeff k| := by
    intro k
    show |(cyclotomic 2 ℤ).coeff k| = |(cyclotomic 1 ℤ).coeff k|
    rw [Polynomial.cyclotomic_two, Polynomial.cyclotomic_one]
    match k with
    | 0 => simp
    | 1 => simp [Polynomial.coeff_add, Polynomial.coeff_sub, Polynomial.coeff_one]
    | (k + 2) => simp [Polynomial.coeff_X, Polynomial.coeff_one]
  constructor <;> intro h k
  · rw [← habs k]; exact h k
  · rw [habs k]; exact h k

/-! ## 3. The odd radical under the two moves -/

theorem oddRad_mul_prime {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) (hn : n ≠ 0) :
    oddRad (n * p) = oddRad n := by
  unfold oddRad
  have hpf : (n * p).primeFactors = n.primeFactors := by
    rw [Nat.primeFactors_mul hn hp.pos.ne', hp.primeFactors]
    exact Finset.union_eq_left.mpr
      (Finset.singleton_subset_iff.mpr (Nat.mem_primeFactors.mpr ⟨hp, hdvd, hn⟩))
  rw [hpf]

theorem two_notMem_primeFactors_of_odd {m : ℕ} (hm : Odd m) : 2 ∉ m.primeFactors := by
  intro h
  have h2 : (2 : ℕ) ∣ m := (Nat.mem_primeFactors.mp h).2.1
  rw [Nat.odd_iff] at hm
  omega

theorem oddRad_two_mul {m : ℕ} (hm0 : m ≠ 0) : oddRad (2 * m) = oddRad m := by
  unfold oddRad
  rw [Nat.primeFactors_mul (by norm_num) hm0, Nat.prime_two.primeFactors]
  congr 1
  ext q
  simp only [Finset.mem_erase, Finset.mem_union, Finset.mem_singleton]
  constructor
  · rintro ⟨hq2, hq | hq⟩
    · exact absurd hq hq2
    · exact ⟨hq2, hq⟩
  · rintro ⟨hq2, hq⟩
    exact ⟨hq2, Or.inr hq⟩

theorem oddRad_of_odd_squarefree {m : ℕ} (hm : Odd m) (hsq : Squarefree m) : oddRad m = m := by
  unfold oddRad
  rw [Finset.erase_eq_of_notMem (two_notMem_primeFactors_of_odd hm)]
  exact Nat.prod_primeFactors_of_squarefree hsq

theorem oddRad_one : oddRad 1 = 1 := by simp [oddRad]

theorem oddRad_two : oddRad 2 = 1 := by
  simp [oddRad, Nat.prime_two.primeFactors]

/-! ## 4. The reduction theorem -/

/-- **Height reduction.**  For every `n ≠ 0` and every bound `B`, the frame `Φ_n` is bounded by
`B` exactly when the frame of its odd radical is. -/
theorem frameBoundedBy_iff_oddRad :
    ∀ n : ℕ, n ≠ 0 → ∀ B : ℤ, (FrameBoundedBy n B ↔ FrameBoundedBy (oddRad n) B) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn B
    match n, hn with
    | 1, _ => rw [oddRad_one]
    | 2, _ => rw [oddRad_two]; exact frameBoundedBy_two_iff B
    | (n + 3), _ =>
      set N := n + 3 with hN
      have hN0 : N ≠ 0 := by omega
      by_cases hsq : Squarefree N
      · by_cases hodd : Odd N
        · rw [oddRad_of_odd_squarefree hodd hsq]
        · -- `N` is even and squarefree, so `N = 2m` with `m` odd and `1 < m`
          have heven : Even N := Nat.not_odd_iff_even.mp hodd
          obtain ⟨m, hm⟩ := heven
          have hNm : N = 2 * m := by omega
          have hm0 : m ≠ 0 := by omega
          have hmodd : Odd m := by
            rcases Nat.even_or_odd m with he | ho
            · exfalso
              obtain ⟨t, ht⟩ := he
              have h4 : 2 * 2 ∣ N := ⟨t, by omega⟩
              have := hsq 2 (by simpa using h4)
              simp at this
            · exact ho
          have hm1 : 1 < m := by
            rcases Nat.lt_or_ge m 2 with h | h
            · interval_cases m
              · omega
              · rw [Nat.odd_iff] at hmodd; omega
            · omega
          rw [hNm, oddRad_two_mul hm0, frameBoundedBy_two_mul_iff hmodd hm1]
          exact ih m (by omega) hm0 B
      · -- `N` has a repeated prime factor `p`
        rw [Nat.squarefree_iff_prime_squarefree] at hsq
        push_neg at hsq
        obtain ⟨p, hp, hpp⟩ := hsq
        obtain ⟨t, ht⟩ := hpp
        have hkeq : N = (p * t) * p := by rw [ht]; ring
        have hpdvd : p ∣ p * t := Dvd.intro t rfl
        have hpt0 : p * t ≠ 0 := by
          intro h
          rw [hkeq, h] at hN
          omega
        have hlt : p * t < N := by
          have hp2 : 2 ≤ p := hp.two_le
          have hptpos : 0 < p * t := Nat.pos_of_ne_zero hpt0
          calc p * t < (p * t) * 2 := by omega
            _ ≤ (p * t) * p := by exact Nat.mul_le_mul_left _ hp2
            _ = N := hkeq.symm
        rw [hkeq, frameBoundedBy_mul_prime_iff hp hpdvd, oddRad_mul_prime hp hpdvd hpt0]
        exact ih (p * t) hlt hpt0 B

/-- Flatness only depends on the odd radical. -/
theorem flatFrame_iff_oddRad {n : ℕ} (hn : n ≠ 0) : FlatFrame n ↔ FlatFrame (oddRad n) :=
  frameBoundedBy_iff_oddRad n hn 1

end PMFrameHeight