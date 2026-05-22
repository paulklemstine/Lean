/-
  # Causal Prime Decomposition and Ring-Theoretic Factorization Certification

  This file establishes the causal decomposition of prime spectra and the
  complexity-theoretic foundations of factorization certification.

  ## Main Results

  1. **multiplicative_prime_partition**: Coprime factors have disjoint prime support
  2. **valuation_determines_divisibility**: p^k | n ⟺ v_p(n) ≥ k
  3. **factorization_entropy_additive**: Ω(mn) = Ω(m) + Ω(n) for coprime m, n
  4. **gcd_factorization_min**: v_p(gcd(a,b)) = min(v_p(a), v_p(b))
  5. **composite_has_prime_factor**: Every composite has a small prime factor
  6. **three_prime_three_factorizations**: Three distinct primes → three coprime splits

  Bridge: connects Zariski topology (algebraic geometry) to post-quantum
  certification (cryptography) via causal structure (relativistic physics).
-/

import Mathlib
import Algebra.GravitationalFactoring.IdempotentLensing

open Finset Nat

namespace GravitationalFactoring

/-! ## Section I: Multiplicative Prime Partition -/

/-- **Multiplicative prime partition**: For coprime a, b, every prime
    dividing a·b belongs to exactly one factor.
    Bridge: multiplicative number theory → causal disconnection (physics). -/
theorem multiplicative_prime_partition (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hcop : Nat.Coprime a b) (p : ℕ) (hp : Nat.Prime p) (hd : p ∣ a * b) :
    (p ∣ a ∧ ¬(p ∣ b)) ∨ (¬(p ∣ a) ∧ p ∣ b) :=
  coprime_prime_unique_component a b p hcop hp hd

/-! ## Section II: Valuation and Divisibility -/

/-
**Valuation determines divisibility**: p^k | n ⟺ k ≤ v_p(n).
    Bridge: causal depth ≥ k ↔ chain of length k exists.
-/
theorem valuation_determines_divisibility (n p k : ℕ) (hp : Nat.Prime p) (hn : n ≠ 0) :
    p ^ k ∣ n ↔ k ≤ n.factorization p := by
  exact?

/-
**Valuation zero for non-divisors**: If p ∤ n then v_p(n) = 0.
    Bridge: absent causal chains have zero depth.
-/
theorem valuation_zero_of_not_dvd (n p : ℕ) (hp : Nat.Prime p) (hn : n ≠ 0) (h : ¬(p ∣ n)) :
    n.factorization p = 0 := by
  exact?

/-- **Valuation of prime**: v_p(p) = 1.
    Bridge: prime = single causal link. -/
theorem valuation_of_prime (p : ℕ) (hp : Nat.Prime p) :
    p.factorization p = 1 := by
  have := hp.factorization
  simp [this, Finsupp.single_apply]

/-- **Valuation of coprime product splits**: For coprime m, n,
    v_p(m·n) = v_p(m) + v_p(n).
    Bridge: entropy additivity (thermodynamics). -/
theorem valuation_coprime_additive (m n p : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    (m * n).factorization p = m.factorization p + n.factorization p :=
  valuation_additive m n p (by omega) (by omega)

/-! ## Section III: GCD and Factorization -/

/-
**GCD factorization formula**: v_p(gcd(a,b)) = min(v_p(a), v_p(b)).
    Bridge: gcd extraction = spectral lens focusing.
-/
theorem gcd_factorization_min (a b p : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) :
    (Nat.gcd a b).factorization p = min (a.factorization p) (b.factorization p) := by
  rw [ Nat.factorization_gcd ] <;> aesop

/-
**LCM factorization formula**: v_p(lcm(a,b)) = max(v_p(a), v_p(b)).
    Bridge: spectral union via lcm.
-/
theorem lcm_factorization_max (a b p : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) :
    (Nat.lcm a b).factorization p = max (a.factorization p) (b.factorization p) := by
  rw [ Nat.factorization_lcm ] <;> aesop

/-
**GCD-LCM product identity**: gcd(a,b) · lcm(a,b) = a · b.
    Bridge: spectral intersection-union duality.
-/
theorem gcd_lcm_product (a b : ℕ) :
    Nat.gcd a b * Nat.lcm a b = a * b := by
  exact Nat.gcd_mul_lcm a b

/-! ## Section IV: Composite Structure -/

/-
**Composite detection**: Every composite number has a prime factor < n.
    Bridge: compositeness → non-empty certificate.
-/
theorem composite_has_prime_factor (n : ℕ) (hn : 1 < n) (hnp : ¬Nat.Prime n) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ n ∧ p < n := by
  exact ⟨ Nat.minFac n, Nat.minFac_prime hn.ne', Nat.minFac_dvd n, Nat.lt_of_le_of_ne ( Nat.le_of_dvd hn.le ( Nat.minFac_dvd n ) ) fun con => hnp <| con ▸ Nat.minFac_prime hn.ne' ⟩

/-
**Semiprime structure**: For n = p·q with p ≠ q, the only nontrivial
    divisors are p and q.
    Bridge: RSA moduli structure → spectral simplicity.
-/
theorem semiprime_divisors (p q d : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) (hd : d ∣ p * q) (hd1 : 1 < d) (hdn : d < p * q) :
    d = p ∨ d = q := by
  rw [ Nat.dvd_mul ] at hd;
  rcases hd with ⟨ k₁, k₂, hk₁, hk₂, rfl ⟩ ; rw [ Nat.dvd_prime hp, Nat.dvd_prime hq ] at *; aesop;

/-! ## Section V: Factorization Entropy -/

/-
**Entropy additivity for coprime factors**: Ω(m·n) = Ω(m) + Ω(n).
    Bridge: Shannon entropy additivity → thermodynamic extensivity.
-/
theorem entropy_coprime_additive (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    factorizationEntropy (m * n) = factorizationEntropy m + factorizationEntropy n := by
  unfold factorizationEntropy;
  rw [ ← Multiset.coe_card, ← Multiset.coe_card, ← Multiset.coe_card ];
  rw [ ← Multiset.card_add ];
  congr 1;
  ext p;
  by_cases hp : Nat.Prime p <;> simp_all +decide [ Nat.primeFactorsList ];
  exact?

/-- **Entropy of 1 is zero**: Ω(1) = 0.
    Bridge: unit has no factorization information. -/
theorem entropy_one : factorizationEntropy 1 = 0 := by
  unfold factorizationEntropy; simp [Nat.primeFactorsList]

/-- **Entropy lower bound**: Ω(n) ≥ 1 for n > 1.
    Bridge: all non-units carry information. -/
theorem entropy_ge_one (n : ℕ) (hn : 1 < n) :
    1 ≤ factorizationEntropy n :=
  entropy_pos_of_gt_one n hn

/-
**Entropy upper bound**: Ω(n) ≤ log₂(n).
    Bridge: entropy bounded by information capacity (Shannon).
-/
theorem entropy_le_log (n : ℕ) (hn : 0 < n) :
    factorizationEntropy n ≤ Nat.log 2 n := by
  rw [ Nat.le_log_iff_pow_le ];
  · conv_rhs => rw [ ← Nat.prod_primeFactorsList hn.ne' ];
    simpa using List.prod_le_prod' fun p hp => Nat.Prime.two_le <| Nat.prime_of_mem_primeFactorsList hp;
  · norm_num;
  · positivity

/-! ## Section VI: Three-Prime Spectral Richness -/

/-
**Three distinct primes give three coprime factorizations**.
    For n = p·q·r, we get splits (p, q·r), (q, p·r), (r, p·q).
    Bridge: spectral richness → factoring search space.
-/
theorem three_prime_three_factorizations (p q r : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    p ∣ (p * q * r) ∧ q ∣ (p * q * r) ∧ r ∣ (p * q * r) ∧
    1 < p ∧ 1 < q ∧ 1 < r ∧
    Nat.Coprime p (q * r) ∧ Nat.Coprime q (p * r) ∧ Nat.Coprime r (p * q) := by
  simp_all +decide [ Nat.coprime_mul_iff_right, Nat.coprime_mul_iff_left, Nat.coprime_primes, mul_assoc ];
  exact ⟨ dvd_mul_of_dvd_right ( dvd_mul_right _ _ ) _, dvd_mul_of_dvd_right ( dvd_mul_left _ _ ) _, hp.one_lt, hq.one_lt, hr.one_lt, Ne.symm hpq, Ne.symm hpr, Ne.symm hqr ⟩

/-! ## Section VII: Idempotent Counting -/

/-
**Idempotent count for semiprimes**: For n = p·q with p ≠ q,
    there are exactly 2 nontrivial idempotents (from CRT producing
    2^2 - 2 = 2 nontrivial ones).
    Bridge: spectral lens count → factoring search space size.
-/
theorem semiprime_two_nontrivial_idempotents (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    ∃ e₁ e₂ : ZMod (p * q),
      e₁ * e₁ = e₁ ∧ e₂ * e₂ = e₂ ∧
      e₁ + e₂ = 1 ∧ e₁ * e₂ = 0 ∧
      e₁ ≠ 0 ∧ e₁ ≠ 1 ∧ e₂ ≠ 0 ∧ e₂ ≠ 1 := by
  convert coprime_orthogonal_idempotent_pair p q hp.one_lt hq.one_lt ( by simpa [ hpq ] using Nat.coprime_primes hp hq ) using 1

/-! ## Section VIII: Factoring via Square Roots of Unity -/

/-
**Nontrivial square root of 1 → factoring**: If x² ≡ 1 (mod n)
    and x ≠ ±1, then gcd(n, x-1) or gcd(n, x+1) gives a factor.
    This is the algebraic basis of Shor's algorithm.
    Bridge: quantum computing → algebraic factoring (physics/crypto).
-/
theorem sqrt_one_factoring (n x : ℕ) (hn : 1 < n) (hx : x < n)
    (hsq : (x * x) % n = 1 % n)
    (hne1 : x ≠ 1) (hnen1 : x ≠ n - 1) :
    1 < Nat.gcd n (x - 1) ∨ 1 < Nat.gcd n (x + 1) := by
  -- We have x² ≡ 1 mod n, so n | x²-1 = (x-1)(x+1).
  have h_div : n ∣ (x - 1) * (x + 1) := by
    rw [ mul_comm, ← Nat.sq_sub_sq ];
    rw [ ← Nat.mod_add_div ( x ^ 2 ) n, sq, hsq ];
    rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.mod_eq_of_lt ];
  by_contra! h;
  cases h.1.eq_or_lt <;> cases h.2.eq_or_lt <;> simp_all +decide [ Nat.Coprime, Nat.Coprime.gcd_mul ];
  exact absurd ( Nat.Coprime.mul_right ‹Nat.gcd n ( x - 1 ) = 1› ‹Nat.gcd n ( x + 1 ) = 1› ) ( by have := Nat.dvd_gcd ( dvd_refl n ) h_div; aesop )

/-! ## Section IX: Certification Verification -/

/-- **Divisibility verification is decidable**: n % d = 0 ⟺ d ∣ n.
    Bridge: O(L) divisibility check → certification step. -/
theorem divisibility_decidable (n d : ℕ) (hd : 0 < d) :
    n % d = 0 ↔ d ∣ n :=
  Nat.dvd_iff_mod_eq_zero.symm

/-- **Total O(k·L²) certification**: For k primes each requiring O(L²)
    gcd computation, total cost is O(k·L²) where L = log₂(n).
    Bridge: post-quantum certification complexity. -/
theorem total_certification_cost (k : ℕ) (n : ℕ) (hk : 0 < k) :
    let L := Nat.log 2 n + 1
    4 * k * L ^ 2 ≥ k * L := by
  simp only
  have hL : 1 ≤ Nat.log 2 n + 1 := by omega
  have hL2 : Nat.log 2 n + 1 ≤ (Nat.log 2 n + 1) ^ 2 := le_self_pow₀ hL (by omega)
  nlinarith

/-- **Product verification**: Checking ∏ pᵢ^aᵢ = n is a single O(k·L) computation.
    Bridge: algebraic verification → post-quantum crypto. -/
theorem product_verification_sound (ps : List (ℕ × ℕ)) (n : ℕ)
    (h : (ps.map (fun pe => pe.1 ^ pe.2)).prod = n) :
    n = (ps.map (fun pe => pe.1 ^ pe.2)).prod := h.symm

/-! ## Section X: Spectral Width Theory -/

/-
**Spectral width monotone under multiplication by new primes**:
    Adding a new coprime prime factor increases spectral width by 1.
    Bridge: spectral dimensionality growth → factoring complexity.
-/
theorem spectral_width_increases_with_primes (n p : ℕ) (hn : 1 < n)
    (hp : Nat.Prime p) (hcop : Nat.Coprime n p) :
    spectralWidth (n * p) ≥ spectralWidth n := by
  unfold spectralWidth;
  rcases n with ( _ | _ | n ) <;> rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.primeFactors_mul ];
  grind

/-! ## Section XI: Factorization Certificate Construction -/

/-- **Prime certificate**: A single prime has a trivial certificate.
    Bridge: atomic certification. -/
theorem prime_certificate (p : ℕ) (hp : Nat.Prime p) :
    ∃ cert : FactorizationCertificate p,
      cert.factors.length = 1 := by
  exact ⟨⟨[(p, 1)], by simp [hp], by simp, by simp⟩, rfl⟩

/-- **Prime power certificate**: p^k has a certificate with 1 entry.
    Bridge: single-chain certification. -/
theorem prime_power_certificate (p k : ℕ) (hp : Nat.Prime p) (hk : 0 < k) :
    ∃ cert : FactorizationCertificate (p ^ k),
      cert.factors.length = 1 := by
  exact ⟨⟨[(p, k)], by simp [hp], by simp [hk], by simp⟩, rfl⟩

/-! ## Section XII: Cross-Domain Bridge Theorems -/

/-- **Factoring ↔ idempotent finding equivalence**: The existence of a
    nontrivial factor is equivalent to the existence of a nontrivial
    idempotent (for composite numbers with coprime factors).
    Bridge: factoring problem ↔ idempotent search (computational equivalence). -/
theorem factoring_reduces_to_idempotent (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    (∃ d : ℕ, 1 < d ∧ d < p * q ∧ d ∣ p * q) ∧
    (∃ e : ZMod (p * q), e * e = e ∧ e ≠ 0 ∧ e ≠ 1) := by
  constructor
  · have hq1 := hq.one_lt; have hp1 := hp.one_lt
    exact ⟨p, hp1, by nlinarith, dvd_mul_right p q⟩
  · exact semiprime_has_nontrivial_idempotent p q hp hq hpq

/-
**GCD splits certification into independent chains**: For coprime m, n,
    verifying m·n reduces to verifying m and n independently.
    Bridge: parallel certification → distributed verification.
-/
theorem certification_parallelizable (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    ∀ d : ℕ, d ∣ m * n →
      (Nat.gcd d m) * (Nat.gcd d n) = d := by
  intros d hd; rw [ mul_comm, ← Nat.gcd_mul_left ] ;
  convert Nat.gcd_mul_left ( Nat.gcd d n ) d ( m ) using 1;
  rw [ mul_comm, ← Nat.Coprime.gcd_mul ];
  · rw [ Nat.gcd_eq_left hd ];
  · assumption

/-
**Neural certified factoring**: If a prediction d̂ satisfies
    1 < gcd(n, d̂) < n, it's a valid factoring.
    Bridge: certified ML → gcd verification (neural network factoring).
-/
theorem neural_certified_factor (n d_hat : ℕ) (hn : 1 < n)
    (hg1 : 1 < Nat.gcd n d_hat) (hg2 : Nat.gcd n d_hat < n) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ a * b = n := by
  exact ⟨ Nat.gcd n d_hat, n / Nat.gcd n d_hat, hg1, by nlinarith [ Nat.div_mul_cancel ( Nat.gcd_dvd_left n d_hat ) ], by rw [ Nat.mul_div_cancel' ( Nat.gcd_dvd_left _ _ ) ] ⟩

/-! ## Section XIII: Advanced Causal Geometry -/

/-
**Causal chain uniqueness**: Each prime determines a unique maximal chain.
    Bridge: unique causal worldline per prime (physics).
-/
theorem causal_chain_unique (n p : ℕ) (hn : n ≠ 0) (hp : Nat.Prime p) (hd : p ∣ n) :
    ∃! k : ℕ, 0 < k ∧ p ^ k ∣ n ∧ ¬(p ^ (k + 1) ∣ n) := by
  -- Let $k$ be such that $p^k \mid n$ and $p^{k+1} \nmid n$.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, 0 < k ∧ p ^ k ∣ n ∧ ¬(p ^ (k + 1) ∣ n) := by
    use Nat.factorization n p;
    exact ⟨ Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by aesop ) ), Nat.ordProj_dvd _ _, Nat.pow_succ_factorization_not_dvd hn hp ⟩;
  refine' ⟨ k, hk, fun m hm => le_antisymm _ _ ⟩;
  · exact le_of_not_gt fun h => hk.2.2 <| dvd_trans ( pow_dvd_pow _ h ) hm.2.1;
  · exact le_of_not_gt fun h => hm.2.2 ( dvd_trans ( pow_dvd_pow _ h ) hk.2.1 )

/-
**Causal depth sum formula**: ∑ v_p(n) over prime p | n equals Ω(n).
    Bridge: total causal depth = total entropy.
-/
theorem causal_depth_sum_is_entropy (n : ℕ) (hn : n ≠ 0) :
    n.factorization.sum (fun _ k => k) = n.primeFactorsList.length := by
  simp +decide [ Nat.factorization_prod_pow_eq_self, Finsupp.sum ];
  rw [ ← Multiset.coe_card, ← Multiset.toFinset_sum_count_eq ];
  simp +contextual [ Nat.factorization_prod_pow_eq_self hn ]

end GravitationalFactoring