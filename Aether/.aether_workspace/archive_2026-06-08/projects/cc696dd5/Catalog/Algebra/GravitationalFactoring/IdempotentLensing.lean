/-
  # Idempotent Spectral Lensing: Ring-Theoretic Factorization via Idempotent Decomposition

  This file establishes the foundational theory of "gravitational factoring" —
  the observation that idempotent elements of ℤ/nℤ act as spectral lenses,
  splitting the prime spectrum into disconnected components whose product
  recovers the original integer n.

  Bridge: connects CommRing idempotent theory (algebra) to cryptographic factoring
  certificates (post-quantum security) and spectral decomposition (physics).
-/

import Mathlib

open Finset Nat

namespace GravitationalFactoring

/-! ## Section I: Foundational Structures -/

/-- A spectral lens captures an idempotent-induced factorization of n.
    Bridge: connects CommRing idempotent theory to cryptographic factoring certificates. -/
structure SpectralLens (n : ℕ) where
  e : ℕ
  e_pos : 0 < e
  e_lt : e < n
  idempotent : (e * e) % n = e % n

/-- The factorization data induced by a spectral lens via gcd extraction.
    Bridge: algebraic analog of gravitational lensing. -/
structure LensFactorization (n : ℕ) where
  factor_a : ℕ
  factor_b : ℕ
  a_dvd : factor_a ∣ n
  b_dvd : factor_b ∣ n

/-- A causal chain: a prime power tower p^k dividing n maximally.
    Bridge: Zariski topology (algebraic geometry) → analytic number theory. -/
structure CausalChain (n : ℕ) where
  p : ℕ
  is_prime : Nat.Prime p
  exponent : ℕ
  exp_pos : 0 < exponent
  divides : p ^ exponent ∣ n
  maximal : ¬(p ^ (exponent + 1) ∣ n)

/-- The causal depth profile records the global causal structure.
    Bridge: causal geometry (physics) → prime factorization (number theory). -/
structure CausalDepthProfile (n : ℕ) where
  num_chains : ℕ
  total_depth : ℕ

/-- A factorization certificate.
    Bridge: algebraic verification → post-quantum certification. -/
structure FactorizationCertificate (n : ℕ) where
  factors : List (ℕ × ℕ)
  all_prime : ∀ pe ∈ factors, Nat.Prime pe.1
  all_pos_exp : ∀ pe ∈ factors, 0 < pe.2
  product_eq : (factors.map (fun pe => pe.1 ^ pe.2)).prod = n

/-- Gravitational weight: min(gcd(n,e), n/gcd(n,e)).
    Bridge: gravitational lensing analogy (physics). -/
noncomputable def gravitationalWeight (n e : ℕ) : ℕ :=
  min (Nat.gcd n e) (n / Nat.gcd n e)

/-- Spectral width: number of independent lens axes. -/
noncomputable def spectralWidth (n : ℕ) : ℕ :=
  if n ≤ 1 then 0
  else n.primeFactors.card - 1

/-- Factorization entropy: Ω(n) = total prime factors with multiplicity. -/
noncomputable def factorizationEntropy (n : ℕ) : ℕ := n.primeFactorsList.length

/-! ## Section II: Idempotent Ring Theory (Abstract CommRing) -/

/-- **Idempotent complement**: 1 - e is idempotent when e is.
    Bridge: spectral theory (physics) → ring decomposition. -/
theorem idempotent_complement {R : Type*} [CommRing R]
    (e : R) (h : e * e = e) :
    (1 - e) * (1 - e) = (1 - e) := by
  have : (1 - e) * (1 - e) = 1 - 2 * e + e * e := by ring
  rw [this, h]; ring

/-- Idempotent orthogonality: e · (1 - e) = 0.
    Bridge: spectral orthogonality → coprime factoring. -/
theorem idempotent_orthogonal {R : Type*} [CommRing R]
    (e : R) (h : e * e = e) :
    e * (1 - e) = 0 := by
  have : e * (1 - e) = e - e * e := by ring
  rw [this, h]; ring

/-- Direct sum decomposition along an idempotent.
    Bridge: spectral decomposition (physics). -/
theorem idempotent_decomposition {R : Type*} [CommRing R]
    (e : R) (_h : e * e = e) (x : R) :
    x = e * x + (1 - e) * x := by ring

/-- **Idempotent meet**: Product of idempotents is idempotent.
    Bridge: Boolean algebra → spectral topology. -/
theorem idempotent_meet {R : Type*} [CommRing R]
    (e f : R) (he : e * e = e) (hf : f * f = f) :
    (e * f) * (e * f) = e * f := by
  calc (e * f) * (e * f) = (e * e) * (f * f) := by ring
    _ = e * f := by rw [he, hf]

/-- **Idempotent join**: e + f - ef is idempotent.
    Bridge: lattice theory → spectral union. -/
theorem idempotent_join {R : Type*} [CommRing R]
    (e f : R) (he : e * e = e) (hf : f * f = f) :
    (e + f - e * f) * (e + f - e * f) = e + f - e * f := by
  calc (e + f - e * f) * (e + f - e * f)
    = (e * e) + 2 * (e * f) - 2 * ((e * e) * f)
      + (f * f) - 2 * (e * (f * f)) + (e * e) * (f * f) := by ring
    _ = e + 2 * (e * f) - 2 * (e * f)
      + f - 2 * (e * f) + e * f := by rw [he, hf]
    _ = e + f - e * f := by ring

/-- **Orthogonal pair → idempotent**: If e₁ + e₂ = 1, e₁ · e₂ = 0 then both idempotent.
    Bridge: orthogonality (physics) → coprime factoring (number theory). -/
theorem idempotent_from_orthogonal_pair {R : Type*} [CommRing R]
    (e₁ e₂ : R) (h_sum : e₁ + e₂ = 1) (h_prod : e₁ * e₂ = 0) :
    e₁ * e₁ = e₁ ∧ e₂ * e₂ = e₂ := by
  have h1 : e₂ = 1 - e₁ := by linear_combination h_sum
  rw [h1] at h_prod ⊢
  constructor
  · linear_combination -h_prod
  · have he : e₁ * e₁ = e₁ := by linear_combination -h_prod
    have : (1 - e₁) * (1 - e₁) = 1 - 2 * e₁ + e₁ * e₁ := by ring
    rw [this, he]; ring

/-! ## Section III: Idempotent Classification in ℤ/p -/

/-- **Prime idempotent classification**: In ℤ/p, x² = x implies x = 0 or x = 1.
    Primes are spectrally irreducible.
    Bridge: integral domain → causal irreducibility (physics). -/
theorem prime_idempotent_trivial (p : ℕ) (hp : Nat.Prime p)
    (e : ZMod p) (h : e * e = e) : e = 0 ∨ e = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  have key : e * (e - 1) = 0 := by
    have h2 : e ^ 2 - e = 0 := by rw [sq]; exact sub_eq_zero.mpr h
    linear_combination h2
  rcases mul_eq_zero.mp key with h1 | h1
  · left; exact h1
  · right; exact sub_eq_zero.mp h1

/-- Squared form of prime idempotent classification. -/
theorem zmod_prime_idempotent_iff (p : ℕ) (hp : Nat.Prime p) (e : ZMod p) :
    e ^ 2 = e ↔ e = 0 ∨ e = 1 := by
  constructor
  · intro h; rw [sq] at h; exact prime_idempotent_trivial p hp e h
  · rintro (rfl | rfl) <;> simp

/-! ## Section IV: CRT Idempotent Construction -/

/-
**CRT idempotent existence**: For coprime a, b > 1, there exists a
    nontrivial idempotent in ℤ/(a·b)ℤ.
    Bridge: Chinese Remainder Theorem → spectral decomposition → factoring.
-/
theorem coprime_has_nontrivial_idempotent
    (a b : ℕ) (ha : 1 < a) (hb : 1 < b) (hcop : Nat.Coprime a b) :
    ∃ e : ZMod (a * b), e * e = e ∧ e ≠ 0 ∧ e ≠ 1 := by
  -- Use ZMod.chineseRemainder hcop to get crt : ZMod (a*b) ≃+* ZMod a × ZMod b.
  have h_crt : Nonempty (ZMod (a * b) ≃+* (ZMod a) × (ZMod b)) := by
    exact ⟨ ZMod.chineseRemainder hcop ⟩;
  obtain ⟨ crt ⟩ := h_crt;
  -- Let $e = crt.symm (1, 0)$. We need to show that $e$ is a nontrivial idempotent in $ZMod (a*b)$.
  use crt.symm (1, 0);
  haveI := Fact.mk ha; haveI := Fact.mk hb; simp +decide [ ← map_mul ] ;

/-
**Orthogonal idempotent pair from CRT**: Complete pair with sum 1, product 0.
    Bridge: CRT orthogonality → cryptographic factoring.
-/
theorem coprime_orthogonal_idempotent_pair
    (a b : ℕ) (ha : 1 < a) (hb : 1 < b) (hcop : Nat.Coprime a b) :
    ∃ e₁ e₂ : ZMod (a * b),
      e₁ * e₁ = e₁ ∧ e₂ * e₂ = e₂ ∧
      e₁ + e₂ = 1 ∧ e₁ * e₂ = 0 ∧
      e₁ ≠ 0 ∧ e₁ ≠ 1 ∧ e₂ ≠ 0 ∧ e₂ ≠ 1 := by
  obtain ⟨e₁, he₁⟩ : ∃ e₁ : ZMod (a * b), e₁ * e₁ = e₁ ∧ e₁ ≠ 0 ∧ e₁ ≠ 1 := by
    exact?;
  refine' ⟨ e₁, 1 - e₁, he₁.1, _, _, _, he₁.2.1, he₁.2.2, _, _ ⟩ <;> simp_all +decide [ sub_mul, mul_sub ];
  grind

/-! ## Section V: Compositeness Detection -/

/-- **Compositeness witness**: A nontrivial idempotent ⟹ n composite.
    Bridge: idempotent existence → compositeness certificate (cryptography). -/
theorem nontrivial_idempotent_implies_composite (n : ℕ) (hn : 1 < n)
    (e : ZMod n) (he : e * e = e) (he0 : e ≠ 0) (he1 : e ≠ 1) :
    ¬Nat.Prime n := by
  intro hp
  exact absurd (prime_idempotent_trivial n hp e he)
    (by push_neg; exact ⟨he0, he1⟩)

/-
**Semiprime idempotent existence**: n = p·q with p ≠ q has nontrivial idempotents.
    Bridge: RSA moduli → spectral lens factoring.
-/
theorem semiprime_has_nontrivial_idempotent (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    ∃ e : ZMod (p * q), e * e = e ∧ e ≠ 0 ∧ e ≠ 1 := by
  convert coprime_has_nontrivial_idempotent p q hp.one_lt hq.one_lt ( hp.coprime_iff_not_dvd.mpr fun h => hpq <| by rw [ Nat.prime_dvd_prime_iff_eq ] at h <;> tauto ) using 1

/-! ## Section VI: Coprimality and Spectral Disconnection -/

/-
**Coprime spectral disconnection**: Each prime divides exactly one factor.
    Bridge: Zariski topology → causal disconnection (physics).
-/
theorem coprime_prime_unique_component (m n p : ℕ)
    (hcop : Nat.Coprime m n) (hp : Nat.Prime p) (hd : p ∣ m * n) :
    (p ∣ m ∧ ¬(p ∣ n)) ∨ (¬(p ∣ m) ∧ p ∣ n) := by
  exact if h : p ∣ m then Or.inl ⟨ h, fun h' => hp.not_dvd_one <| hcop.gcd_eq_one ▸ Nat.dvd_gcd h h' ⟩ else Or.inr ⟨ h, by exact Or.resolve_left ( hp.dvd_mul.mp hd ) h ⟩

/-
**Disjoint prime support**: Coprime numbers share no prime factors.
    Bridge: spectrally disjoint → causally disconnected.
-/
theorem coprime_disjoint_primes (m n : ℕ) (hcop : Nat.Coprime m n) :
    ∀ p : ℕ, Nat.Prime p → p ∣ m → ¬(p ∣ n) := by
  exact fun p pp dm dn => pp.not_dvd_one <| hcop.gcd_eq_one ▸ Nat.dvd_gcd dm dn

/-! ## Section VII: GCD Factoring -/

/-- **GCD extracts factors**: gcd(a·b, a) = a. -/
theorem gcd_of_mul_left (a b : ℕ) :
    Nat.gcd (a * b) a = a := by
  rw [Nat.gcd_comm]; exact Nat.gcd_eq_left (dvd_mul_right a b)

/-
**Proper divisor detection via gcd**.
    Bridge: algebraic extraction → verified factoring (post-quantum).
-/
theorem gcd_proper_divisor (n d : ℕ) (hn : 1 < n)
    (hd : d ∣ n) (hd1 : 1 < d) (hdn : d < n) :
    1 < Nat.gcd n d ∧ Nat.gcd n d < n := by
  cases hd ; aesop

/-- **Factor consistency**: n = a·b with a, b > 1 ⟹ both are proper divisors. -/
theorem factor_consistency (n a b : ℕ) (hn : n = a * b)
    (ha : 1 < a) (hb : 1 < b) :
    a ∣ n ∧ b ∣ n ∧ a < n ∧ b < n := by
  subst hn
  exact ⟨dvd_mul_right a b, dvd_mul_left b a, by nlinarith, by nlinarith⟩

/-- **GCD certification soundness**: gcd(n, d) = d ⟹ d ∣ n.
    Bridge: algebraic soundness → zero-knowledge certification. -/
theorem gcd_certification_sound (n d : ℕ) (hgcd : Nat.gcd n d = d) :
    d ∣ n := by rw [← hgcd]; exact Nat.gcd_dvd_left n d

/-
**GCD trichotomy**: gcd(n, d) is trivial or a genuine factor.
    Bridge: certified ML prediction → gcd verification (neural factoring).
-/
theorem gcd_factor_trichotomy (n d : ℕ) (hn : 1 < n) :
    let g := Nat.gcd n d
    g = 1 ∨ g = n ∨ (1 < g ∧ g < n ∧ g ∣ n) := by
  exact Classical.or_iff_not_imp_left.2 fun h => Classical.or_iff_not_imp_left.2 fun h' => ⟨ lt_of_le_of_ne ( Nat.gcd_pos_of_pos_left _ ( pos_of_gt hn ) ) ( Ne.symm h ), lt_of_le_of_ne ( Nat.le_of_dvd ( pos_of_gt hn ) ( Nat.gcd_dvd_left _ _ ) ) h', Nat.gcd_dvd_left _ _ ⟩

/-! ## Section VIII: Causal Chain Theory -/

/-
**Causal chain existence**: Every prime factor determines a maximal chain.
    Bridge: prime factorization → causal structure (physics).
-/
theorem causal_chain_exists (n p : ℕ) (hn : n ≠ 0)
    (hp : Nat.Prime p) (hdvd : p ∣ n) :
    ∃ k : ℕ, 0 < k ∧ p ^ k ∣ n ∧ ¬(p ^ (k + 1) ∣ n) := by
  exact ⟨ Nat.factorization n p, Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by aesop ) ), Nat.ordProj_dvd _ _, Nat.pow_succ_factorization_not_dvd hn hp ⟩

/-- **Causal depth of prime power**: v_p(p^k) = k.
    Bridge: causal geometry = arithmetic multiplicity. -/
theorem causal_depth_prime_power (p k : ℕ) (hp : Nat.Prime p) :
    (p ^ k).factorization p = k := by
  simp [hp.factorization_pow]

/-
**Causal chains are disjoint**: Distinct primes give coprime powers.
    Bridge: disconnected causal components ↔ coprime factorization.
-/
theorem causal_chains_coprime (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) (k₁ k₂ : ℕ) :
    Nat.Coprime (p ^ k₁) (q ^ k₂) := by
  exact Nat.coprime_pow_primes _ _ hp hq hpq

/-! ## Section IX: Valuation Theory -/

/-- **Valuation additivity**: v_p(m·n) = v_p(m) + v_p(n).
    Bridge: p-adic valuation → causal depth addition (thermodynamics). -/
theorem valuation_additive (m n p : ℕ) (hm : m ≠ 0) (hn : n ≠ 0) :
    (m * n).factorization p = m.factorization p + n.factorization p := by
  rw [Nat.factorization_mul hm hn]; simp [Finsupp.coe_add]

/-
**Holographic reconstruction**: Same valuations ⟹ same number.
    Bridge: holographic principle (physics) → unique factoring.
-/
theorem holographic_reconstruction (m n : ℕ) (hm : m ≠ 0) (hn : n ≠ 0)
    (h : ∀ p : ℕ, Nat.Prime p → m.factorization p = n.factorization p) :
    m = n := by
  exact Nat.factorization_inj hm hn <| by ext p; by_cases hp : Nat.Prime p <;> aesop;

/-! ## Section X: Certification Complexity -/

/-- **GCD bound**: gcd(a, b) ≤ min(a, b).
    Bridge: certification cost → O((log n)²) complexity. -/
theorem gcd_le_min (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    Nat.gcd a b ≤ min a b :=
  le_min (Nat.gcd_le_left b (by omega)) (Nat.gcd_le_right a (by omega))

/-- **Certification cost bound**: 4k(L+1)² ≥ k where L = log₂(n).
    Bridge: post-quantum certification complexity. -/
theorem certification_cost_bound (k n : ℕ) (hk : 0 < k) :
    4 * k * (Nat.log 2 n + 1) ^ 2 ≥ k := by
  have h1 : 1 ≤ (Nat.log 2 n + 1) ^ 2 := Nat.one_le_pow 2 _ (by omega)
  nlinarith

/-! ## Section XI: Entropy Theory -/

/-- **Entropy of prime**: Ω(p) = 1.
    Bridge: prime = atomic information unit. -/
theorem entropy_prime (p : ℕ) (hp : Nat.Prime p) :
    factorizationEntropy p = 1 := by
  unfold factorizationEntropy; rw [Nat.primeFactorsList_prime hp]; simp

/-- **Entropy of prime power**: Ω(p^k) = k.
    Bridge: prime power depth → quantum energy level. -/
theorem entropy_prime_pow (p k : ℕ) (hp : Nat.Prime p) :
    factorizationEntropy (p ^ k) = k := by
  unfold factorizationEntropy; rw [hp.primeFactorsList_pow, List.length_replicate]

/-- **Omega inequality**: ω(n) ≤ Ω(n).
    Bridge: connected components ≤ total depth. -/
theorem omega_le_bigOmega (n : ℕ) :
    n.primeFactorsList.dedup.length ≤ n.primeFactorsList.length :=
  List.Sublist.length_le (List.dedup_sublist n.primeFactorsList)

/-! ## Section XII: Spectral Width -/

/-
**Spectral width zero for primes**: Primes are spectrally irreducible.
    Bridge: zero spectral width → causally irreducible (physics).
-/
theorem spectral_width_prime (p : ℕ) (hp : Nat.Prime p) :
    spectralWidth p = 0 := by
  unfold spectralWidth;
  aesop

/-! ## Section XIII: GCD Product Decomposition -/

/-- **GCD splits over coprime products**.
    Bridge: spectral decomposition → parallel certification. -/
theorem gcd_coprime_split (m n a : ℕ) (hcop : Nat.Coprime m n) :
    Nat.gcd (m * n) a = Nat.gcd m a * Nat.gcd n a :=
  Nat.Coprime.mul_gcd hcop a

/-- **GCD monotone**: a ∣ b ⟹ gcd(n, a) ∣ gcd(n, b).
    Bridge: spectral lens coherence. -/
theorem gcd_dvd_of_dvd (n a b : ℕ) (hab : a ∣ b) :
    Nat.gcd n a ∣ Nat.gcd n b :=
  Nat.dvd_gcd (Nat.gcd_dvd_left n a) (dvd_trans (Nat.gcd_dvd_right n a) hab)

/-
**Disjoint primes → coprimality**.
    Bridge: spectrally disjoint → causally disconnected.
-/
theorem disjoint_primes_coprime (a b : ℕ)
    (h : ∀ p : ℕ, Nat.Prime p → ¬(p ∣ a ∧ p ∣ b)) :
    Nat.Coprime a b := by
  exact Nat.coprime_of_dvd <| by tauto;

/-! ## Section XIV: Gravitational Weight -/

/-- **Weight bound**: gravitationalWeight(n, e) ≤ n.
    Bridge: gravitational lensing → factoring efficiency bound. -/
theorem gravitational_weight_le (n e : ℕ) (hn : 0 < n) :
    gravitationalWeight n e ≤ n := by
  unfold gravitationalWeight
  exact le_trans (min_le_left _ _) (Nat.gcd_le_left e (by omega))

/-- **Weight of a factor**: If a ∣ n, weight at a = min(a, n/a).
    Bridge: optimal lens → balanced factoring (RSA cryptanalysis). -/
theorem gravitational_weight_factor (n a : ℕ) (hd : a ∣ n) :
    gravitationalWeight n a = min a (n / a) := by
  unfold gravitationalWeight
  have : Nat.gcd n a = a := by rw [Nat.gcd_comm]; exact Nat.gcd_eq_left hd
  rw [this]

/-- Coprime factors are strictly smaller than their product.
    Bridge: nontriviality of lens factorizations. -/
theorem coprime_strict_factors (a b : ℕ) (ha : 1 < a) (hb : 1 < b) :
    a < a * b ∧ b < a * b := by
  constructor <;> nlinarith

/-
Entropy positive for n > 1.
    Bridge: all composites carry factorization information.
-/
theorem entropy_pos_of_gt_one (n : ℕ) (hn : 1 < n) :
    0 < factorizationEntropy n := by
  exact List.length_pos_iff.mpr ( by induction hn <;> simp_all +decide [ Nat.primeFactorsList ] )

end GravitationalFactoring