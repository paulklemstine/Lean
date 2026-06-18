# Future Directions: Formalized Primality Testing and Arithmetic Complexity

## Overview

This document outlines 5 concrete research directions opened by the formalization of Miller-Rabin and AKS primality testing infrastructure. Each direction includes precise theorem statements, proof strategies, and cross-domain significance.

---

## Direction 1: Complete the Miller-Rabin Quarter Bound via Unit Group CRT

### Target Theorem
```lean
theorem miller_rabin_liar_card_le_quarter
    (n : ℕ) (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n) (hge : 3 ≤ n) :
    4 * (MRLiars n).card ≤ n - 1
```

### Proof Strategy

The proof decomposes into two cases via `composite_odd_dichotomy` (already proved):

**Case 1: n = a · b with gcd(a,b) = 1.** The key infrastructure needed:
- Formalize the CRT isomorphism (ZMod n)ˣ ≅ (ZMod a)ˣ × (ZMod b)ˣ as a group isomorphism
- Show that strong pseudoprime liars must have "synchronized signatures" — both CRT components must reach -1 at the same squaring step
- Prove this synchronization constrains liars to a subgroup of index ≥ 4

**Case 2: n = p^k, k ≥ 2.** The key infrastructure needed:
- Formalize that (ZMod (p^k))ˣ is cyclic for odd prime p
- Show the liar set forms a subgroup whose size divides φ(p^k)/4

### Required Helper Lemmas (10-15 lemmas)
```lean
-- CRT for unit groups
theorem ZMod.unitsEquivProd (a b : ℕ) (hab : Nat.Coprime a b) :
    (ZMod (a * b))ˣ ≃* (ZMod a)ˣ × (ZMod b)ˣ

-- Cyclic structure of units mod prime power
theorem ZMod.units_prime_pow_isCyclic (p : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2) (k : ℕ) (hk : 1 ≤ k) :
    IsCyclic (ZMod (p ^ k))ˣ

-- Synchronized signature lemma
theorem liar_synchronized_signature (n a b : ℕ) (hn : n = a * b)
    (hcop : Nat.Coprime a b) (x : ℕ) (hx : StrongPseudoprimeBase n x) :
    ∃ r, (x ^ (d * 2^r) ≡ -1 [MOD a]) ∧ (x ^ (d * 2^r) ≡ -1 [MOD b])
```

### Cross-Domain Significance
- Creates reusable unit group CRT infrastructure for all of algebraic number theory
- Enables formal study of pseudoprime distributions and density theorems
- Foundation for Solovay-Strassen formalization (Direction 2)
- Connects to formal group theory and representation theory

### Estimated Effort
800-1200 lines of Lean, building on Mathlib's existing ZMod and group theory infrastructure.

---

## Direction 2: Formalized Solovay-Strassen via Jacobi Symbol Theory

### Target Theorem
```lean
theorem solovay_strassen_soundness
    (n : ℕ) (hn_odd : n % 2 = 1) (hn_comp : ¬ Nat.Prime n) (hge : 3 ≤ n) :
    2 * (EulerLiars n).card ≤ n - 1
```

where
```lean
def EulerLiar (n a : ℕ) : Prop :=
    Nat.Coprime a n ∧ a ^ ((n-1)/2) ≡ jacobiSymbol a n [MOD n]

def EulerLiars (n : ℕ) : Finset ℕ :=
    (Finset.range n).filter (fun a => 1 ≤ a ∧ EulerLiar n a)
```

### Proof Strategy
1. Formalize the Jacobi symbol as a multiplicative function on ℤ
2. Prove Euler's criterion: for prime p and gcd(a,p) = 1, a^((p-1)/2) ≡ (a/p) (mod p)
3. Show that for composite n, the Euler liars form a proper subgroup of (Z/nZ)*
4. Use Lagrange's theorem to bound the liar count at most (n-1)/2

### Key Supporting Theorems
```lean
-- Euler's criterion
theorem euler_criterion (p a : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2)
    (ha : Nat.Coprime a p) :
    a ^ ((p-1)/2) ≡ jacobiSymbol a p [MOD p]

-- Jacobi symbol multiplicativity
theorem jacobiSymbol_mul (a b n : ℤ) :
    jacobiSymbol (a * b) n = jacobiSymbol a n * jacobiSymbol b n

-- Every MR liar is an Euler liar
theorem strong_pseudoprime_implies_euler (n a : ℕ) :
    StrongPseudoprimeBase n a → EulerLiar n a
```

### Cross-Domain Significance
- Bridges to quadratic reciprocity and class field theory
- Creates infrastructure for Jacobi sums and character theory
- Connects to formal L-function theory
- Relevant to lattice-based cryptography verification

### Estimated Effort
600-900 lines. Mathlib already has some Jacobi symbol infrastructure.

---

## Direction 3: Full AKS Correctness Proof

### Target Theorem
```lean
theorem aks_criterion
    (n r : ℕ) (hn : 2 ≤ n)
    (hpowfree : ¬ ∃ a b : ℕ, 2 ≤ b ∧ 1 < a ∧ n = a ^ b)
    (hord : orderMod n r > (Nat.log 2 n) ^ 2)
    (hcong : ∀ a : ℕ, a ≤ bound_AKS n r →
        PolynomialCongruenceModXRMinusOne n r a)
    (hr_cop : Nat.Coprime n r) (hr : 1 < r) :
    Nat.Prime n
```

### Proof Strategy (based on Agrawal-Kayal-Saxena 2004)

The proof requires several deep components:

**Step 1: Introspection Lemma.** If the congruences hold and n has a prime factor p, then p acts like Frobenius on the splitting field of X^r - 1 over F_p. Formalize the "introspection" technique showing that products and powers of roots of X^r - 1 are mapped consistently by both p-th and n-th power maps.

**Step 2: Group Theory Bound.** The set G of numbers t such that n^t acts consistently on all r-th roots of unity forms a group. The congruence conditions ensure |G| > log²(n) · √φ(r).

**Step 3: Pigeonhole on Polynomials.** If n has two distinct prime factors or n = p^k for large k, then there are too many distinct polynomial evaluations, contradicting a degree bound. Therefore n must be a prime power.

**Step 4: Eliminating Prime Powers.** The power-free hypothesis eliminates n = p^k for k ≥ 2.

### Required Infrastructure
```lean
-- Splitting field of X^r - 1
noncomputable def CyclotomicSplittingField (p r : ℕ) := ...

-- Introspection lemma
theorem aks_introspection (p r : ℕ) (hp : Nat.Prime p) (hp_dvd : p ∣ n)
    (hcong : ∀ a ≤ bound, PolynomialCongruenceModXRMinusOne n r a) :
    ∀ t ∈ introspectionGroup n r, ∀ ζ : CyclotomicSplittingField p r,
      ζ ^ (n^t) = ζ ^ (p^(something))

-- Polynomial degree bound
theorem distinct_residues_bound (p r : ℕ) (G : Finset ℕ) (hG : ...) :
    G.card ≤ r
```

### Cross-Domain Significance
- First complete formalization of a PRIMES ∈ P proof
- Creates infrastructure for finite field extensions, cyclotomic fields
- Foundation for formal algebraic complexity theory
- Connects to polynomial identity testing (PIT)

### Estimated Effort
3000-5000 lines. This is a major formalization project comparable to the formal proof of the odd order theorem.

---

## Direction 4: Proof-Producing Primality Certificates

### Target Theorems
```lean
-- Pratt certificate verification
inductive PrattCertificate where
  | prime (p : ℕ) (witness : ℕ) (factorization : List (ℕ × PrattCertificate))
  | two : PrattCertificate

def verifyPrattCertificate : PrattCertificate → ℕ → Bool

theorem pratt_certificate_sound (cert : PrattCertificate) (n : ℕ) :
    verifyPrattCertificate cert n = true → Nat.Prime n

-- Compositeness certificate (Miller-Rabin witness)
structure CompositenessCertificate where
  n : ℕ
  witness : ℕ
  chain : List ℕ  -- squaring chain

theorem compositeness_certificate_sound (cert : CompositenessCertificate) :
    verifyCertificate cert = true → ¬ Nat.Prime cert.n
```

### Proof Strategy
1. Implement Pratt certificate verification as a decidable procedure
2. Prove soundness: a valid certificate implies primality (by Lucas' theorem)
3. Implement Miller-Rabin witness certificates for compositeness
4. Connect to the `norm_num` / `decide` tactic framework for proof-producing computation

### Cross-Domain Significance
- Creates certified decision procedure for primality
- Enables verified cryptographic parameter generation
- Foundation for proof-carrying code in security applications
- Connects to SAT/SMT reflection patterns

### Estimated Effort
500-800 lines. Pratt certificates are well-understood and the verification logic is straightforward.

---

## Direction 5: Strong Pseudoprime Classification for Semiprimes

### Target Theorem
```lean
theorem semiprime_liar_bound (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) (hp_odd : p ≠ 2) (hq_odd : q ≠ 2) :
    (MRLiars (p * q)).card = 
      gcd_count (p-1) (q-1) (DecomposeTwos (p*q-1)).1 * factor
```

where `factor` depends on the 2-adic structure of p-1 and q-1.

### Proof Strategy

For n = p · q (a semiprime), the exact liar count can be computed in terms of:
- gcd(p-1, q-1) — controls the d-th power condition
- The 2-adic valuations v₂(p-1) and v₂(q-1) — controls the squaring chain interaction
- The minimum of v₂(p-1) and v₂(q-1) — determines the "synchronization window"

The proof uses the CRT isomorphism explicitly:
1. Map liars through CRT: (Z/pqZ)* → (Z/pZ)* × (Z/qZ)*
2. Classify liar pairs: (a mod p, a mod q) must satisfy synchronized conditions
3. Count using the formula for solutions in cyclic groups

### Explicit Formula
For n = pq with p, q distinct odd primes, let s₁ = v₂(p-1), s₂ = v₂(q-1), s = v₂(n-1), d₁ = (p-1)/2^s₁, d₂ = (q-1)/2^s₂, d = (n-1)/2^s.

|L(n)| = gcd(d, d₁) · gcd(d, d₂) · (1 + 2·min(s₁, s₂) - [s₁ = s₂]) + corrections

### Cross-Domain Significance
- Enables precise analysis of Miller-Rabin for RSA moduli
- Connects to analytic number theory (distribution of primes in arithmetic progressions)
- Foundation for formal pseudorandomness analysis
- Relevant to cryptanalysis of poorly generated RSA keys

### Estimated Effort
400-700 lines, building on the CRT infrastructure from Direction 1.

---

## Implementation Roadmap

### Phase 1 (Immediate, 1-2 months)
- Direction 4 (Pratt certificates) — highest impact-to-effort ratio
- Begin Direction 1 (CRT for units) — foundational infrastructure

### Phase 2 (Short-term, 3-6 months)
- Complete Direction 1 (quarter bound)
- Direction 2 (Solovay-Strassen) — leverages Direction 1 infrastructure
- Direction 5 (semiprime classification) — leverages Direction 1

### Phase 3 (Medium-term, 6-18 months)
- Direction 3 (AKS correctness) — major project
- Extend to formal derandomization theory
- Connect to polynomial identity testing

### Phase 4 (Long-term, 1-3 years)
- Formal BPP vs P framework
- Verified cryptographic parameter generation pipeline
- Connection to arithmetic circuit complexity

---

## Cross-Cutting Themes

### Theme A: Formalized Derandomization
The progression Miller-Rabin → AKS is a concrete instance of derandomization (BPP → P). Formalizing both tests creates a case study for general derandomization techniques, connecting to:
- Nisan-Wigderson generators
- Hardness vs. randomness paradigm
- Arithmetic circuit lower bounds

### Theme B: Certified Computational Algebra
The modular arithmetic reflection framework (eval_mod_norm_sound) extends naturally to:
- Verified polynomial arithmetic in quotient rings
- Certified Gröbner basis computation
- Formal NTT (Number Theoretic Transform) verification
- Ring-based cryptographic protocol verification (RLWE, etc.)

### Theme C: Proof-Producing Computation
The certificate approach (Direction 4) exemplifies a broader paradigm:
- Compute results quickly using unverified algorithms
- Produce certificates that can be checked in polynomial time
- Verify certificates using a trusted proof checker
This pattern applies to SAT solving, integer factorization, graph coloring, and many other domains.
