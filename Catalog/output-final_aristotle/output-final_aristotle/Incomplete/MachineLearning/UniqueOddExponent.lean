/-
# Unique Odd Exponent in Odd Perfect Numbers

This file proves that any odd perfect number has exactly one prime
with an odd exponent in its factorization. This is the core
factorization-parity theorem that underlies Euler's decomposition.

## Main result

* `odd_perfect_unique_odd_valuation` — There exists a unique prime p
  such that n.factorization p is odd

This theorem reframes odd perfect numbers as having exactly one
"parity defect" in the prime-exponent vector, making it a canonical
API theorem for further structural analysis.
-/
import Mathlib
import Logic.Defs
import Speculative.OddPerfect.SigmaParity

open Finset Nat BigOperators OddPerfect

namespace OddPerfect

/-! ## Auxiliary lemmas about σ₁ parity -/

/-- σ₁(p^a) for odd prime p is odd iff a is even. -/
theorem sigma₁_prime_pow_odd_iff {p : ℕ} (hp : Nat.Prime p) (hoddp : p % 2 = 1) (a : ℕ) :
    sigma₁ (p ^ a) % 2 = 1 ↔ Even a := by
  rw [sigma₁_prime_pow hp]
  exact sigmaPP_odd_prime_odd_iff hp hoddp a

/-
For an odd number n > 0, σ₁(n) is odd iff every prime exponent is even,
    i.e., n is a perfect square.
-/
set_option maxHeartbeats 800000 in
theorem sigma₁_odd_iff_all_even_exponents {n : ℕ} (hn : 0 < n) (hodd : Odd n) :
    Odd (sigma₁ n) ↔ ∀ p ∈ n.factorization.support, Even (n.factorization p) := by
  -- Use the factorization of n: n = ∏_{p ∈ n.factorization.support} p ^ (n.factorization p).
  have h_factorization : n.divisors.sum id = ∏ p ∈ n.factorization.support, (p ^ (n.factorization p + 1) - 1) / (p - 1) := by
    -- By definition of sum of divisors function, we can write it as a product over the prime factors of n.
    have h_sum_divisors : n.divisors.sum id = (∏ p ∈ n.factorization.support, (∑ i ∈ Finset.range (n.factorization p + 1), p ^ i)) := by
      -- Apply the multiplicativity of the sum of divisors function.
      have h_mul : ∀ {m n : ℕ}, Nat.Coprime m n → (Nat.divisors (m * n)).sum id = (Nat.divisors m).sum id * (Nat.divisors n).sum id := by
        intros m n h_coprime; exact (by
        convert sigma₁_mul_coprime h_coprime using 1);
      conv_lhs => rw [ ← Nat.factorization_prod_pow_eq_self hn.ne' ];
      -- Apply the multiplicativity of the sum of divisors function to each prime power in the factorization.
      have h_mul_prime_powers : ∀ {S : Finset ℕ} {f : ℕ → ℕ}, (∀ p ∈ S, Nat.Prime p) → (Nat.divisors (∏ p ∈ S, p ^ f p)).sum id = ∏ p ∈ S, (Nat.divisors (p ^ f p)).sum id := by
        intro S f hf; induction S using Finset.induction <;> simp_all +decide ;
        rw [ h_mul, ‹∑ x ∈ ( ∏ p ∈ _, p ^ f p |> Nat.divisors ), x = _› ];
        · simp +decide [ Nat.divisors_prime_pow hf.1 ];
        · exact Nat.Coprime.prod_right fun p hp => Nat.Coprime.pow _ _ <| hf.1.coprime_iff_not_dvd.mpr fun h => ‹¬_› <| by have := Nat.prime_dvd_prime_iff_eq hf.1 ( hf.2 p hp ) ; aesop;
      convert h_mul_prime_powers _ using 2;
      · rw [ Nat.divisors_prime_pow ( Nat.prime_of_mem_primeFactors ‹_› ) ] ; aesop;
      · exact fun p hp => Nat.prime_of_mem_primeFactors hp;
    exact h_sum_divisors.trans ( Finset.prod_congr rfl fun p hp => by rw [ Nat.geomSum_eq ( Nat.prime_of_mem_primeFactors hp |> Nat.Prime.one_lt ) ] );
  -- By definition of $sigma₁$, we know that $sigma₁(n) = \prod_{p \in n.factorization.support} \frac{p^{n.factorization p + 1} - 1}{p - 1}$.
  have h_sigma_prod : ∀ p ∈ n.factorization.support, ((p ^ (n.factorization p + 1) - 1) / (p - 1)) % 2 = if Even (n.factorization p) then 1 else 0 := by
    intro p hp; rw [ ← Nat.geomSum_eq ( Nat.Prime.one_lt ( Nat.prime_of_mem_primeFactors hp ) ) ] ;
    norm_num [ Nat.pow_mod, Finset.sum_nat_mod, Nat.even_iff ];
    cases Nat.Prime.eq_two_or_odd ( Nat.prime_of_mem_primeFactors hp ) <;> simp_all +decide [ Finset.sum_range_succ' ];
    · grind +splitIndPred;
    · grind;
  -- Apply the parity result to each term in the product.
  have h_prod_parity : (∏ p ∈ n.factorization.support, ((p ^ (n.factorization p + 1) - 1) / (p - 1))) % 2 = if ∀ p ∈ n.factorization.support, Even (n.factorization p) then 1 else 0 := by
    rw [ Finset.prod_nat_mod, Finset.prod_congr rfl h_sigma_prod ];
    split_ifs <;> simp_all +decide [ Finset.prod_ite ];
    rw [ Finset.card_eq_zero.mpr ] <;> aesop;
  unfold sigma₁; split_ifs at h_prod_parity <;> simp_all +decide [ Nat.even_iff ] ;
  · exact Nat.odd_iff.mpr h_prod_parity;
  · grind

/-
The set of primes with odd exponent in the factorization of an odd perfect number
    has exactly one element. This is the core structural theorem.
-/
theorem odd_perfect_exists_unique_odd_exponent {n : ℕ}
    (hn : 0 < n)
    (hodd : Odd n)
    (hperf : sigma₁ n = 2 * n) :
    ∃! p : ℕ, p ∈ n.factorization.support ∧ Odd (n.factorization p) := by
  -- Let $p$ be a prime with odd exponent in the factorization of $n$.
  obtain ⟨p, hp⟩ : ∃ p ∈ n.factorization.support, Odd (n.factorization p) := by
    contrapose! hperf;
    -- If $n$ is a perfect square, then $\sigma_1(n)$ is odd.
    have h_sigma_odd : Odd (sigma₁ n) := by
      exact sigma₁_odd_iff_all_even_exponents hn hodd |>.2 fun p hp => by aesop;
    grind;
  refine' ⟨ p, hp, fun q hq => _ ⟩;
  -- By contradiction, assume $q \ne p$.
  by_contra hne;
  -- Since $p$ and $q$ are distinct primes with odd exponents in the factorization of $n$, we have $\sigma_1(p^{e_p})$ and $\sigma_1(q^{e_q})$ are both even.
  have h_even_p : Even (sigma₁ (p ^ (n.factorization p))) := by
    rw [ sigma₁_prime_pow ];
    · exact sigmaPP_odd_prime_even_iff ( Nat.prime_of_mem_primeFactors hp.1 ) ( Nat.odd_iff.mp ( hodd.of_dvd_nat ( Nat.dvd_of_mem_primeFactors hp.1 ) ) ) _ |>.2 hp.2;
    · exact Nat.prime_of_mem_primeFactors hp.1
  have h_even_q : Even (sigma₁ (q ^ (n.factorization q))) := by
    simp_all +decide [ sigma₁_prime_pow, parity_simps ];
    exact sigmaPP_odd_prime_even_iff hq.1.1 ( Nat.Prime.eq_two_or_odd hq.1.1 |> Or.resolve_left <| by rintro rfl; exact absurd ( hodd.of_dvd_nat hq.1.2 ) ( by decide ) ) _ |>.2 hq.2;
  -- Since $\sigma_1$ is multiplicative, we have $\sigma_1(n) = \sigma_1(p^{e_p}) \cdot \sigma_1(q^{e_q}) \cdot \sigma_1(m)$ for some integer $m$.
  obtain ⟨m, hm⟩ : ∃ m, n = p ^ (n.factorization p) * q ^ (n.factorization q) * m ∧ Nat.Coprime (p ^ (n.factorization p) * q ^ (n.factorization q)) m := by
    refine' ⟨ n / ( p ^ n.factorization p * q ^ n.factorization q ), _, _ ⟩;
    · rw [ Nat.mul_div_cancel' ];
      exact Nat.Coprime.mul_dvd_of_dvd_of_dvd ( Nat.coprime_pow_primes _ _ ( Nat.prime_of_mem_primeFactors hp.1 ) ( Nat.prime_of_mem_primeFactors hq.1 ) ( by aesop ) ) ( Nat.ordProj_dvd _ _ ) ( Nat.ordProj_dvd _ _ );
    · refine' Nat.Coprime.mul_left _ _;
      · refine' Nat.Coprime.pow_left _ ( Nat.Prime.coprime_iff_not_dvd ( Nat.prime_of_mem_primeFactors hp.1 ) |>.2 _ );
        rw [ Nat.Prime.dvd_iff_one_le_factorization ] <;> simp_all +decide [ Nat.factorization_div ( Nat.Coprime.mul_dvd_of_dvd_of_dvd ( Nat.coprime_pow_primes _ _ ( Nat.prime_of_mem_primeFactors hp.1 ) ( Nat.prime_of_mem_primeFactors hq.1 ) ( by aesop ) ) ( Nat.ordProj_dvd _ _ ) ( Nat.ordProj_dvd _ _ ) ) ];
        exact Nat.le_of_dvd hn ( Nat.Coprime.mul_dvd_of_dvd_of_dvd ( Nat.coprime_pow_primes _ _ hp.1.1 hq.1.1 ( by aesop ) ) ( Nat.ordProj_dvd _ _ ) ( Nat.ordProj_dvd _ _ ) );
      · refine' Nat.Coprime.pow_left _ ( Nat.Prime.coprime_iff_not_dvd ( Nat.prime_of_mem_primeFactors hq.1 ) |>.2 _ );
        rw [ Nat.dvd_div_iff_mul_dvd ];
        · intro h; have := Nat.factorization_le_iff_dvd ( by aesop ) ( by aesop ) |>.2 h; simp_all +decide [ Nat.factorization_mul, ne_of_gt ] ;
          replace := this q; simp_all +decide [ Nat.factorization_mul, hp.1.1.ne_zero, hq.1.1.ne_zero ] ;
        · exact Nat.Coprime.mul_dvd_of_dvd_of_dvd ( Nat.coprime_pow_primes _ _ ( Nat.prime_of_mem_primeFactors hp.1 ) ( Nat.prime_of_mem_primeFactors hq.1 ) ( by aesop ) ) ( Nat.ordProj_dvd _ _ ) ( Nat.ordProj_dvd _ _ );
  -- Since $\sigma_1$ is multiplicative, we have $\sigma_1(n) = \sigma_1(p^{e_p}) \cdot \sigma_1(q^{e_q}) \cdot \sigma_1(m)$.
  have h_sigma_mul : sigma₁ n = sigma₁ (p ^ (n.factorization p)) * sigma₁ (q ^ (n.factorization q)) * sigma₁ m := by
    rw [ hm.1, sigma₁_mul_coprime, sigma₁_mul_coprime ];
    · rw [ ← hm.1 ];
    · exact Nat.coprime_pow_primes _ _ ( Nat.prime_of_mem_primeFactors hp.1 ) ( Nat.prime_of_mem_primeFactors hq.1 ) ( by rintro rfl; exact hne rfl );
    · exact hm.2;
  replace h_sigma_mul := congr_arg ( · % 4 ) h_sigma_mul ; rcases h_even_p with ⟨ k, hk ⟩ ; rcases h_even_q with ⟨ l, hl ⟩ ; push_cast [ hk, hl, hperf ] at h_sigma_mul ; ring_nf at h_sigma_mul ; norm_num [ Nat.add_mod, Nat.mul_mod ] at h_sigma_mul;
  grind

/-
Packaged version using IsOddPerfect.
-/
theorem odd_perfect_unique_odd_valuation {n : ℕ}
    (h : IsOddPerfect n) :
    ∃! p : ℕ, Nat.Prime p ∧ p ∣ n ∧ Odd (n.factorization p) := by
  -- Apply the odd_perfect_exists_unique_odd_exponent theorem to obtain the existence and uniqueness of such a prime p.
  obtain ⟨p, hp⟩ : ∃! p : ℕ, p ∈ n.factorization.support ∧ Odd (n.factorization p) := by
    apply odd_perfect_exists_unique_odd_exponent h.2.2 h.1 h.2.1;
  exact ⟨ p, ⟨ Nat.prime_of_mem_primeFactors hp.1.1, Nat.dvd_of_mem_primeFactors hp.1.1, hp.1.2 ⟩, fun q hq => hp.2 q ⟨ Nat.mem_primeFactors.mpr ⟨ hq.1, hq.2.1, by aesop ⟩, hq.2.2 ⟩ ⟩

end OddPerfect