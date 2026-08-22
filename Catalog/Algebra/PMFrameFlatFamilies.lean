/-
# Flat families of ±-frames: from two parameters to the full `ω ≤ 2` class

Continuation of the research thread of `Shared/PMFrameTwoParameter.lean`.
-/
import Mathlib
import Shared.PMFrameTwoParameter

namespace PMFrameFlat

open Polynomial Finset PMFrame

/-- A ±-frame is **flat** when all its coefficients lie in `{-1,0,1}`. -/
def FlatFrame (n : ℕ) : Prop := ∀ k : ℕ, |(pmFrame n).coeff k| ≤ 1

/-- Coefficient transport under multiplication by a prime already dividing the order. -/
theorem coeff_pmFrame_mul_prime {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) (k : ℕ) :
    (pmFrame (n * p)).coeff k = if p ∣ k then (pmFrame n).coeff (k / p) else 0 := by
  unfold pmFrame
  rw [← Polynomial.cyclotomic_expand_eq_cyclotomic hp hdvd ℤ, Polynomial.coeff_expand hp.pos]

theorem flatFrame_mul_prime {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) (h : FlatFrame n) :
    FlatFrame (n * p) := by
  intro k
  rw [coeff_pmFrame_mul_prime hp hdvd k]
  split
  · exact h _
  · simp

theorem flatFrame_one : FlatFrame 1 := by
  intro k
  unfold pmFrame
  rw [Polynomial.cyclotomic_one]
  rcases k with _ | _ | k <;> simp [Polynomial.coeff_X, Polynomial.coeff_one]

theorem flatFrame_prime {p : ℕ} (hp : p.Prime) : FlatFrame p := by
  intro k
  rcases coeff_pmFrame_prime_mem p hp k with h | h <;> rw [h] <;> norm_num

theorem flatFrame_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q) :
    FlatFrame (p * q) := fun k => coeff_pmFrame_two_param_abs_le_one hp hq h k

/-! ## Prime-power inflation -/

theorem flatFrame_mul_prime_pow {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) (h : FlatFrame n) :
    ∀ c : ℕ, FlatFrame (n * p ^ c) := by
  intro c
  induction c with
  | zero => simpa using h
  | succ c ih =>
      have hrw : n * p ^ (c + 1) = (n * p ^ c) * p := by ring
      rw [hrw]
      exact flatFrame_mul_prime hp (Dvd.dvd.mul_right hdvd _) ih

theorem coeff_pmFrame_mul_prime_pow {n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n) :
    ∀ (c k : ℕ), (pmFrame (n * p ^ c)).coeff (k * p ^ c) = (pmFrame n).coeff k := by
  intro c
  induction c with
  | zero => simp
  | succ c ih =>
      intro k
      have hrw : n * p ^ (c + 1) = (n * p ^ c) * p := by ring
      have hk : k * p ^ (c + 1) = (k * p ^ c) * p := by ring
      rw [hrw, hk, coeff_pmFrame_mul_prime hp (Dvd.dvd.mul_right hdvd _),
        if_pos (Dvd.intro_left (k * p ^ c) rfl), Nat.mul_div_cancel _ hp.pos, ih]

/-- **Flatness for two-prime-power orders.**  For distinct primes `p ≠ q` and any exponents
`a, b ≥ 1`, every coefficient of `Φ_{p^a q^b}` lies in `{-1,0,1}`. -/
theorem flatFrame_prime_pow_mul_prime_pow {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) : FlatFrame (p ^ a * q ^ b) := by
  obtain ⟨a', rfl⟩ : ∃ a', a = a' + 1 := ⟨a - 1, by omega⟩
  obtain ⟨b', rfl⟩ : ∃ b', b = b' + 1 := ⟨b - 1, by omega⟩
  have h0 : FlatFrame (p * q) := flatFrame_semiprime hp hq hne
  have h1 : FlatFrame ((p * q) * p ^ a') :=
    flatFrame_mul_prime_pow hp ⟨q, rfl⟩ h0 a'
  have h2 : FlatFrame (((p * q) * p ^ a') * q ^ b') :=
    flatFrame_mul_prime_pow hq ⟨p * p ^ a', by ring⟩ h1 b'
  have hrw : p ^ (a' + 1) * q ^ (b' + 1) = ((p * q) * p ^ a') * q ^ b' := by ring
  rwa [hrw]

/-- **Flatness for prime-power orders.** -/
theorem flatFrame_prime_pow {p : ℕ} (hp : p.Prime) {a : ℕ} (ha : 1 ≤ a) : FlatFrame (p ^ a) := by
  obtain ⟨a', rfl⟩ : ∃ a', a = a' + 1 := ⟨a - 1, by omega⟩
  have h1 : FlatFrame (p * p ^ a') := flatFrame_mul_prime_pow hp dvd_rfl (flatFrame_prime hp) a'
  have hrw : p ^ (a' + 1) = p * p ^ a' := by ring
  rwa [hrw]

/-! ## Sharpness: the value `-1` is attained in every two-prime-power frame -/

/-- For distinct primes `p ≠ q` and exponents `a, b ≥ 1`, the coefficient of
`X^{p^{a-1} q^{b-1}}` in `Φ_{p^a q^b}` equals `-1`; so the flat bound is sharp. -/
theorem coeff_pmFrame_prime_pow_sharp {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (a b : ℕ) :
    (pmFrame (p ^ (a + 1) * q ^ (b + 1))).coeff (p ^ a * q ^ b) = -1 := by
  have hbase : (pmFrame (p * q)).coeff 1 = -1 := coeff_pmFrame_one_eq_neg_one hp hq hne
  have h1 : ∀ k : ℕ, (pmFrame ((p * q) * p ^ a)).coeff (k * p ^ a) = (pmFrame (p * q)).coeff k :=
    coeff_pmFrame_mul_prime_pow hp ⟨q, rfl⟩ a
  have h2 : ∀ k : ℕ, (pmFrame (((p * q) * p ^ a) * q ^ b)).coeff (k * q ^ b)
      = (pmFrame ((p * q) * p ^ a)).coeff k :=
    coeff_pmFrame_mul_prime_pow hq ⟨p * p ^ a, by ring⟩ b
  have hrw : p ^ (a + 1) * q ^ (b + 1) = ((p * q) * p ^ a) * q ^ b := by ring
  have hidx : p ^ a * q ^ b = (1 * p ^ a) * q ^ b := by ring
  rw [hrw, hidx, h2, h1, hbase]

/-! ## The classification: every order with at most two prime factors is flat -/

/-- **Flatness classification.**  If `n ≠ 0` has at most two distinct prime divisors, then every
coefficient of the ±-frame `Φ_n` lies in `{-1,0,1}`.  This is the exact generalisation of the
two-parameter (Migotti) theorem from squarefree semiprimes to arbitrary orders with `ω(n) ≤ 2`. -/
theorem flatFrame_of_card_primeFactors_le_two {n : ℕ} (hn : n ≠ 0)
    (h : n.primeFactors.card ≤ 2) : FlatFrame n := by
  have hprod : ∏ p ∈ n.primeFactors, p ^ n.factorization p = n := by
    have h' := Nat.factorization_prod_pow_eq_self hn
    rwa [Finsupp.prod, Nat.support_factorization] at h'
  have hexp : ∀ p ∈ n.primeFactors, 1 ≤ n.factorization p := by
    intro p hp
    have hmem : p ∈ n.factorization.support := by rwa [Nat.support_factorization]
    have := Finsupp.mem_support_iff.mp hmem
    omega
  have hcard : n.primeFactors.card = 0 ∨ n.primeFactors.card = 1 ∨ n.primeFactors.card = 2 := by
    omega
  rcases hcard with hc | hc | hc
  · have hempty : n.primeFactors = ∅ := Finset.card_eq_zero.mp hc
    rcases Nat.primeFactors_eq_empty.mp hempty with h0 | h1
    · exact absurd h0 hn
    · rw [h1]; exact flatFrame_one
  · obtain ⟨p, hp⟩ := Finset.card_eq_one.mp hc
    have hpmem : p ∈ n.primeFactors := by rw [hp]; simp
    have hpp : p.Prime := Nat.prime_of_mem_primeFactors hpmem
    have hne : n = p ^ n.factorization p := by
      have h' := hprod.symm
      rwa [hp, Finset.prod_singleton] at h'
    rw [hne]
    exact flatFrame_prime_pow hpp (hexp p hpmem)
  · obtain ⟨p, q, hpq, hset⟩ := Finset.card_eq_two.mp hc
    have hpmem : p ∈ n.primeFactors := by rw [hset]; simp
    have hqmem : q ∈ n.primeFactors := by rw [hset]; simp
    have hpp : p.Prime := Nat.prime_of_mem_primeFactors hpmem
    have hqp : q.Prime := Nat.prime_of_mem_primeFactors hqmem
    have hne : n = p ^ n.factorization p * q ^ n.factorization q := by
      have h' := hprod.symm
      rwa [hset, Finset.prod_pair hpq] at h'
    rw [hne]
    exact flatFrame_prime_pow_mul_prime_pow hpp hqp hpq (hexp p hpmem) (hexp q hqmem)

/-- Trichotomy form of the classification. -/
theorem coeff_pmFrame_mem_of_card_primeFactors_le_two {n : ℕ} (hn : n ≠ 0)
    (h : n.primeFactors.card ≤ 2) (k : ℕ) :
    (pmFrame n).coeff k = -1 ∨ (pmFrame n).coeff k = 0 ∨ (pmFrame n).coeff k = 1 := by
  have := flatFrame_of_card_primeFactors_le_two hn h k
  rw [abs_le] at this
  omega

end PMFrameFlat