# Tropical Min-Plus Diffie-Hellman: Formally Verified Key Exchange Protocols over the Tropical Semiring

## Abstract

We present a formal verification of two Diffie-Hellman-style key exchange protocols over the tropical (min-plus) semiring. The first protocol uses simple matrix powering, where shared key agreement follows from the commutativity of the power map: (G^a)^b = G^(ab) = (G^b)^a. The second implements the Grigoriev-Shpilrain conjugacy key exchange, where parties use conjugation by commuting matrices to establish shared keys without exchanging private data. We formally prove correctness of both protocols, establish the algebraic foundations (centralizer structure, non-commutativity witness, fiber multiplicity), and analyze security parameters. All results are machine-verified with zero unresolved proof obligations.

**Keywords**: Tropical algebra, min-plus semiring, Diffie-Hellman key exchange, conjugacy search problem, post-quantum cryptography, formal verification

## 1. Introduction

The tropical semiring (ℤ ∪ {∞}, min, +), where addition is replaced by minimum and multiplication by ordinary addition, has attracted significant cryptographic interest since Grigoriev and Shpilrain's seminal 2014 paper [1]. The key insight is that tropical matrix multiplication, while efficient to compute (O(n³)), creates computationally asymmetric problems suitable for public-key cryptography.

Unlike lattice-based schemes (e.g., NTRU, Kyber), tropical cryptography derives its hardness from the combinatorial geometry of tropical hypersurfaces rather than from the shortest vector problem. This provides a genuinely alternative hardness source for post-quantum cryptography.

### 1.1 Contributions

1. **Formal verification of Simple Tropical DH**: We prove (G^a)^b = (G^b)^a for tropical matrices, establishing correctness of the simplest key exchange protocol.

2. **Formal verification of the Grigoriev-Shpilrain Conjugacy Protocol**: We define the full protocol structure and prove key agreement: Alice's shared key equals Bob's shared key under the commutativity conditions on conjugator pairs.

3. **Centralizer theory**: We prove that powers of G lie in the centralizer of G, that the centralizer is closed under multiplication and powering, and that centralizer elements commute with all powers of G.

4. **Security foundations**: We prove non-commutativity of tropical matrix multiplication (explicit 2×2 witness), unbounded preimage fiber growth, and monotonicity of min-plus products.

5. **Novel definitions**: `TropConjSession` (conjugacy key exchange session), `TropConj` (tropical conjugation action), `InTropCentralizer` (centralizer predicate), `minPlusMul` (real-valued min-plus product), `tropVecAction` (min-plus matrix-vector action).

## 2. Mathematical Preliminaries

### 2.1 The Tropical Semiring

**Definition 2.1** (Tropical Semiring). The *tropical semiring* is the algebraic structure (ℤ ∪ {∞}, ⊕, ⊗) where:
- a ⊕ b = min(a, b) (tropical addition)
- a ⊗ b = a + b (tropical multiplication)
- The additive identity is ∞ (since min(a, ∞) = a)
- The multiplicative identity is 0 (since a + 0 = a)

This forms a commutative semiring (but NOT a ring — there are no additive inverses, since min is idempotent: a ⊕ a = a).

### 2.2 Tropical Matrices

**Definition 2.2** (Tropical Matrix Product). For n × n tropical matrices A, B, their product is:
```
(A ⊗ B)_{ij} = ⊕_k (A_{ik} ⊗ B_{kj}) = min_k (A_{ik} + B_{kj})
```
This is exactly the shortest-path composition: (A ⊗ B)_{ij} gives the minimum weight of any two-hop path from i to j through intermediate vertex k.

**Theorem 2.3** (Non-Commutativity). Tropical matrix multiplication is NOT commutative for n ≥ 2. We exhibit an explicit 2×2 witness.

*Proof*. Formally verified; see `trop_noncommutativity_2x2` in the Lean source.

### 2.3 Centralizer

**Definition 2.4** (Tropical Centralizer). The *centralizer* of G in the tropical matrix monoid is:
```
C(G) = {M : M ⊗ G = G ⊗ M}
```

**Theorem 2.5** (Centralizer Properties).
1. G^a ∈ C(G) for all a ∈ ℕ.
2. If A, B ∈ C(G), then A ⊗ B ∈ C(G).
3. If M ∈ C(G), then M^k ∈ C(G) for all k ∈ ℕ.
4. If M ∈ C(G), then M ⊗ G^k = G^k ⊗ M for all k ∈ ℕ.

*Proofs*. All formally verified by induction. The key step in (1) uses:
G^(k+1) ⊗ G = G^k ⊗ G ⊗ G, and G ⊗ G^(k+1) = G ⊗ G^k ⊗ G = G^k ⊗ G ⊗ G (by IH).

## 3. Protocol 1: Simple Tropical Diffie-Hellman

### 3.1 Protocol Description

**Public**: Generator matrix G ∈ TMat(n).

| Step | Alice | Bob |
|------|-------|-----|
| 1. Choose secret | a ∈ ℕ | b ∈ ℕ |
| 2. Compute public key | P_A = G^a | P_B = G^b |
| 3. Exchange | Send P_A → | ← Send P_B |
| 4. Compute shared key | K = (P_B)^a = (G^b)^a | K = (P_A)^b = (G^a)^b |

### 3.2 Correctness

**Theorem 3.1** (Simple DH Correctness). For any tropical matrix G and natural numbers a, b:
```
(G^a)^b = (G^b)^a
```

*Proof*. By the power-of-power law:
```
(G^a)^b = G^(a·b) = G^(b·a) = (G^b)^a
```
using commutativity of natural number multiplication. Formally verified as `simple_tropical_dh_correctness`.

### 3.3 Security

The security rests on the **Tropical Discrete Logarithm Problem (TDLP)**: given G and G^a, find a. The orbit {G^k : k ∈ ℕ} is eventually periodic (by pigeonhole on the finite set of bounded-entry matrices), so the search space is bounded by the orbit period.

**Theorem 3.2** (Orbit Reduction). If G^p = I for some p > 0, then G^a = G^(a mod p).

This limits the effective key space but also bounds the brute-force attack complexity to O(p · n³).

## 4. Protocol 2: Conjugacy Key Exchange

### 4.1 Protocol Description (Grigoriev-Shpilrain)

**Public**: Generator matrix G ∈ TMat(n).

**Setup**: Alice and Bob choose their conjugator pairs from a common commutative sub-semigroup (e.g., powers of a shared auxiliary matrix C).

| Step | Alice | Bob |
|------|-------|-----|
| 1. Choose secrets | A₁, A₂ with A₁B₁ = B₁A₁, A₂B₂ = B₂A₂ | B₁, B₂ |
| 2. Compute public key | P_A = A₁ ⊗ G ⊗ A₂ | P_B = B₁ ⊗ G ⊗ B₂ |
| 3. Exchange | Send P_A → | ← Send P_B |
| 4. Compute shared key | K_A = A₁ ⊗ P_B ⊗ A₂ | K_B = B₁ ⊗ P_A ⊗ B₂ |

### 4.2 Correctness

**Theorem 4.1** (Conjugacy KE Correctness). If A₁ ⊗ B₁ = B₁ ⊗ A₁ and A₂ ⊗ B₂ = B₂ ⊗ A₂, then:
```
A₁ ⊗ (B₁ ⊗ G ⊗ B₂) ⊗ A₂ = B₁ ⊗ (A₁ ⊗ G ⊗ A₂) ⊗ B₂
```

*Proof sketch*. Expand both sides using associativity:
- LHS = (A₁ ⊗ B₁) ⊗ G ⊗ (B₂ ⊗ A₂)
- RHS = (B₁ ⊗ A₁) ⊗ G ⊗ (A₂ ⊗ B₂)

By hypothesis, A₁ ⊗ B₁ = B₁ ⊗ A₁ and A₂ ⊗ B₂ = B₂ ⊗ A₂ (equivalently B₂ ⊗ A₂ = A₂ ⊗ B₂). Hence LHS = RHS.

Formally verified as `trop_conj_ke_correctness`.

### 4.3 Security Analysis

The security rests on the **Tropical Conjugacy Search Problem (TCSP)**: given G and A₁ ⊗ G ⊗ A₂, find A₁ and A₂.

**Key space size**: With entries from {0, ..., B}, each conjugator has (B+1)^(n²) possible values. The total search space for the pair (A₁, A₂) is (B+1)^(2n²).

| n | B | Search space | Classical bits | Quantum bits |
|---|---|-------------|----------------|--------------|
| 3 | 10 | 11^18 ≈ 2^62 | 62 | 31 |
| 5 | 10 | 11^50 ≈ 2^173 | 173 | 86 |
| 8 | 10 | 11^128 ≈ 2^443 | 443 | 221 |
| 10 | 10 | 11^200 ≈ 2^692 | 692 | 346 |

For 128-bit quantum security, n = 8 with B = 10 provides ample margin.

## 5. Algebraic Foundations

### 5.1 Monotonicity of Min-Plus Products

**Theorem 5.1** (Monotonicity). If A ≤ A' and B ≤ B' entrywise, then minPlusMul(A, B) ≤ minPlusMul(A', B') entrywise.

*Proof*. For each (i, j), the minimum over k of (A_{ik} + B_{kj}) is bounded by the minimum over k of (A'_{ik} + B'_{kj}), since each summand is individually bounded. Formally verified as `minPlusMul_mono`.

### 5.2 Preimage Multiplicity

**Theorem 5.2** (Unbounded Fiber). For any target sum s ∈ ℝ and any k ≥ 2, there exist k distinct pairs (a_i, b_i) with a_i + b_i = s.

*Proof*. Take (a_i, b_i) = (s/2 + i, s/2 − i) for i ∈ {0, ..., k−1}. Formally verified as `trop_preimage_growth`.

This establishes the many-to-one nature of tropical operations at the scalar level, which extends to matrix products by composition.

## 6. Known Attacks and Countermeasures

### 6.1 Linear Algebraic Attack (Isaac-Kahrobaei, 2021)

The simplest attack on conjugacy KE tries to solve the system of n² linear equations A₁ ⊗ G ⊗ A₂ = C in the tropical sense. However, tropical "linear" systems are actually piecewise-linear optimization problems, not true linear algebra. The min operation creates exponentially many cases.

### 6.2 Eigenvalue-Based Attack

If G has a unique tropical eigenvalue (minimum cycle mean), the attacker can attempt to read off spectral information from the public key. **Countermeasure**: choose G with degenerate tropical spectrum (multiple optimal permutations in the assignment problem det⊕(G)).

### 6.3 Brute-Force and Grover

Classical brute force requires (B+1)^(2n²) operations. Grover's quantum algorithm provides a quadratic speedup to (B+1)^(n²) quantum operations. The parameter table in §4.3 accounts for this.

## 7. Falsifiable Conjecture

**Conjecture 7.1** (Tropical Conjugacy Search Hardness). For random n×n tropical integer matrices G over {0,...,B} with B = Θ(n), any algorithm solving the TCSP requires Ω(B^(n²/2)) operations in the worst case.

**Testable prediction**: For n = 3 and B = 5, a brute-force enumeration should find that the average number of valid decompositions per target exceeds 2, confirming the many-to-one property and suggesting that the problem does not admit a polynomial-time algorithm via unique factorization.

## 8. Related Work

- **Grigoriev & Shpilrain (2014)** [1]: Original proposal of tropical matrix key exchange.
- **Grigoriev & Shpilrain (2019)** [2]: Extensions to tropical rational functions.
- **Isaac & Kahrobaei (2021)** [3]: Cryptanalysis of certain tropical key exchange variants.
- **Rudy & Monico (2022)** [4]: Analysis of the tropical discrete logarithm problem.

## 9. Conclusion

We have formally verified two tropical key exchange protocols and established their algebraic foundations. The simple tropical DH protocol, while elegant, has security limited by the orbit period of the generator. The conjugacy key exchange offers a richer security landscape, with search space scaling as (B+1)^(2n²).

The formal verification provides a solid foundation for future work on tropical cryptographic primitives. All proofs are machine-checked, eliminating the possibility of subtle algebraic errors that have historically plagued cryptographic protocol analysis.

## References

[1] D. Grigoriev and V. Shpilrain. "Tropical cryptography." *Communications in Algebra*, 42(6):2624–2632, 2014.

[2] D. Grigoriev and V. Shpilrain. "Tropical cryptography II: Extensions by homomorphisms." *Communications in Algebra*, 47(10):4224–4229, 2019.

[3] S. Isaac and D. Kahrobaei. "A closer look at the tropical cryptography." *International Journal of Computer Mathematics: Computer Systems Theory*, 6(2):137–142, 2021.

[4] D. Rudy and C. Monico. "Remarks on the tropical discrete logarithm problem." *Applicable Algebra in Engineering, Communication and Computing*, 33:747–755, 2022.

## Appendix: Verified Theorem Index

| Theorem | Statement | Status |
|---------|-----------|--------|
| `simple_tropical_dh_correctness` | (G^a)^b = (G^b)^a | ✓ Verified |
| `trop_conj_ke_correctness` | Conjugacy KE produces matching keys | ✓ Verified |
| `trop_power_in_centralizer` | G^a ∈ C(G) | ✓ Verified |
| `centralizer_commutes_with_pow` | M ∈ C(G) ⟹ M·G^k = G^k·M | ✓ Verified |
| `trop_centralizer_mul` | C(G) closed under ⊗ | ✓ Verified |
| `trop_centralizer_pow` | C(G) closed under powering | ✓ Verified |
| `trop_noncommutativity_2x2` | ∃ A,B: A⊗B ≠ B⊗A | ✓ Verified |
| `minPlusMul_mono` | Entrywise monotonicity | ✓ Verified |
| `trop_preimage_growth` | Unbounded fiber size | ✓ Verified |
| `trop_powers_commute` | G^a·G^b = G^b·G^a | ✓ Verified |
| `trop_power_orbit_mod` | G^a = G^(a%p) when G^p = 1 | ✓ Verified |
| `tropConj_compose` | Conjugation composition | ✓ Verified |
| `tropVecAction_mono` | Action monotonicity | ✓ Verified |
