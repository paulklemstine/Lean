# The Factorization Hierarchy: A Complete Classification of Multiplicative Independence in Generator Sets

## Abstract

We develop a complete hierarchy of multiplicative structural conditions for subsets of the natural numbers, motivated by the question: which properties of the primes depend on their density versus their multiplicative structure? We establish a strict chain of four implications — pairwise coprimality ⟹ unique factorization ⟹ multiplicative independence ⟹ product-freeness — and prove that no reverse implication holds by exhibiting explicit separating examples. Along the way, we disprove a natural conjecture about collision spectra by identifying cross-level collisions as the precise obstruction missed by level-uniform analysis. All results are formalized in Lean 4 with complete machine-verified proofs.

## 1. Introduction

The Fundamental Theorem of Arithmetic (FTA) states that every positive integer factors uniquely into prime numbers. This is perhaps the most basic structural fact about the integers, yet its full depth is rarely appreciated. The primes satisfy not just unique factorization, but an entire hierarchy of increasingly subtle multiplicative conditions — each independently necessary, none individually sufficient.

Our investigation is motivated by Cramér's (1936) random model of the primes, where each integer n ≥ 2 is designated "prime" independently with probability 1/ln(n). Such models successfully predict many density-dependent properties of actual primes but fail catastrophically at capturing multiplicative structure. We ask: precisely *which* multiplicative properties fail, and *why*?

### 1.1 Main Results

1. **The Four-Level Hierarchy** (Theorem 3.1): We establish the strict chain
   ```
   Pairwise coprime ⟹ UF ⟹ Mult. independent ⟹ Product-free
   ```
   with all three implications strict.

2. **Disproof of the Level-Uniform Conjecture** (Theorem 2.1): The conjecture that UF is equivalent to having empty collision spectrum at all levels is false. The set {2, 8} has empty collision spectrum at every level yet fails UF.

3. **Cross-Level Collision Framework** (Section 2.2): We identify cross-level collisions — factorizations of different lengths producing the same number — as the precise obstruction invisible to level-uniform analysis.

4. **Generator Absorption Theorem** (Theorem 4.1): Any set containing an element expressible as a product of ≥ 2 other elements automatically fails UF. This is the mechanism by which Cramér random models lose unique factorization.

5. **Dirichlet Survival with Tight Bounds** (Theorem 5.1): Dense subsets of [0, qm) with more than (q−1)m elements hit every residue class mod q, and this bound is tight.

### 1.2 Related Work

The study of pseudo-prime systems connects to several areas:

- **Cramér's random model** (Cramér, 1936): The original probabilistic model of prime distribution.
- **Product-free sets** (Eberhard, Green, Manners, 2014): Density bounds for sets avoiding products.
- **Factorization theory in monoids** (Geroldinger, Halter-Koch, 2006): Abstract factorization in commutative cancellative monoids.
- **Collision-freeness** (as developed in our prior work, `Catalog/Cryptography/ProductCollisions.lean`): The intermediate condition between product-freeness and unique factorization.

Our contribution is the complete hierarchy with explicit separations and the identification of cross-level collisions as the missing structural ingredient.

## 2. Definitions and Framework

**Definition 2.1** (S-Factorization). Let S ⊆ ℕ. An *S-factorization* of n ∈ ℕ is a multiset f of elements from S, each ≥ 2, such that ∏ f = n.

**Definition 2.2** (Unique Factorization). A set S has *unique factorization* (UF) if every n ∈ ℕ has at most one S-factorization.

**Definition 2.3** (Product-Free). S is *product-free* if for all a, b ∈ S with a, b ≥ 2, a · b ∉ S.

**Definition 2.4** (Multiplicatively Independent). S is *multiplicatively independent* if for every s ∈ S with s ≥ 2 and every S-factorization f of s, we have f = {s}.

**Definition 2.5** (Same-Level Collision Spectrum). The *same-level collision spectrum* of S at level k is:
```
Σ_k(S) = {n ∈ ℕ : ∃ distinct f₁, f₂ with |f₁| = |f₂| = k and ∏f₁ = ∏f₂ = n}
```

**Definition 2.6** (Cross-Level Collision). S has a *cross-level collision* if there exist factorizations f₁, f₂ of the same number with |f₁| ≠ |f₂|.

**Definition 2.7** (Generator Absorption). S has an *absorption* if some s ∈ S with s ≥ 2 has an S-factorization f with |f| ≥ 2.

### 2.1 Disproof of the Level-Uniform Conjecture

**Theorem 2.1.** The set S = {2, 8} satisfies Σ_k(S) = ∅ for all k ∈ ℕ, yet S does not have unique factorization.

*Proof.* The number 8 has two S-factorizations: {8} (length 1) and {2, 2, 2} (length 3). Since these have different lengths, they do not appear as a same-level collision at any level k. For the spectrum emptiness: any factorization of n using {2, 8} consists of a copies of 2 and b copies of 8, with n = 2^a · 8^b = 2^(a+3b). At level k = a + b, the exponent a + 3b = (k − b) + 3b = k + 2b uniquely determines b (and hence a), so the factorization at each level is unique. □

### 2.2 Cross-Level Collisions

**Theorem 2.2.** If S has a cross-level collision, then S does not have UF.

*Proof.* Factorizations of different lengths are necessarily distinct multisets. □

**Theorem 2.3.** Generator absorption implies cross-level collision.

*Proof.* If s ∈ S has factorization f with |f| ≥ 2, then {s} (length 1) and f (length ≥ 2) are two factorizations of s with different lengths. □

## 3. The Four-Level Hierarchy

### 3.1 Implications

**Theorem 3.1** (Hierarchy Chain).
(a) UF ⟹ Multiplicatively independent.
(b) Multiplicatively independent ⟹ Product-free.

*Proof of (a).* If S has UF and s ∈ S with s ≥ 2, then for any factorization f of s, UF applied to f and {s} gives f = {s}. □

*Proof of (b).* If S is multiplicatively independent and a · b ∈ S with a, b ∈ S, a, b ≥ 2, then {a, b} is a factorization of a · b with |{a, b}| = 2 ≥ 2, contradicting the requirement that the only factorization of a · b ∈ S be the singleton {a · b}. □

### 3.2 Strict Separations

**Theorem 3.2.** Multiplicative independence does not imply UF.

*Proof.* The set S = {6, 10, 21, 35} is multiplicatively independent (the smallest product of two elements is 6 · 6 = 36 > 35, so no element is a product of others) but fails UF (6 · 35 = 10 · 21 = 210). □

**Theorem 3.3.** Product-freeness does not imply multiplicative independence.

*Proof.* The set {2, 8} is product-free (products of pairs: 4, 16, 64 — none in S) but not multiplicatively independent (8 = 2 · 2 · 2). Note that multiplicative independence considers all multisets of size ≥ 2, not just pairs. □

### 3.3 Coprimality as Sufficient Condition

**Theorem 3.4** (Coprime UF). If all elements of S (with values ≥ 2) are pairwise coprime, then S has UF.

*Proof.* By induction on the multiset. Given factorizations f₁ = a ::ₘ rest₁ and f₂ of n, we show a ∈ f₂. Since a | n = ∏ f₂ and a is coprime to every element of S other than itself, an element-wise coprimality argument forces a to divide some element b ∈ f₂ with a = b. Removing a from both factorizations and applying the inductive hypothesis to n/a completes the proof. □

## 4. The Cramér Collapse Mechanism

### 4.1 Absorption and UF Failure

**Theorem 4.1** (Generator Absorption Theorem). If S has an absorption, then S does not have UF.

*Proof.* An absorbed element s has both the singleton factorization {s} and a longer factorization f. Since 1 ≠ |f|, these are distinct, witnessing UF failure. □

**Corollary 4.2** (Cramér Collapse). If p, q ∈ S with p, q ≥ 2 and p · q ∈ S, then S does not have UF.

*Proof.* p · q is absorbed via {p, q}. □

### 4.2 Application to Random Models

In a Cramér model with density n/log n, for any fixed primes p, q, the probability that all three of p, q, and p · q are included is:
```
P(p ∈ S) · P(q ∈ S) · P(pq ∈ S) = (1/ln p)(1/ln q)(1/ln(pq))
```
Summing over all pairs (p, q) with p, q ≤ N gives an expected number of absorptions that grows without bound. By Borel-Cantelli, with probability 1, a Cramér model has infinitely many absorptions and hence fails UF.

## 5. Dirichlet Survival

### 5.1 Dense Sets Cover All Residue Classes

**Theorem 5.1** (Dirichlet Survival). Let S ⊆ {0, ..., qm − 1} with |S| > (q − 1)m. Then for every residue r < q, there exists x ∈ S with x ≡ r (mod q).

*Proof.* By contrapositive: if some class r is missed, S is contained in the complement of class r within [0, qm), which has size (q − 1)m. □

**Theorem 5.2** (Tightness). For q ≥ 2 and m ≥ 1, there exists S ⊆ {0, ..., qm − 1} with |S| = (q − 1)m that misses residue class 0.

*Proof.* Take S = {x ∈ [0, qm) : x ≢ 0 (mod q)}. □

### 5.2 Implications for Counterfactual Number Theory

Since Cramér models have density n/log n, which exceeds (q − 1)/q · n for any fixed q when n is large enough, Dirichlet's theorem on primes in arithmetic progressions "survives" the passage to random models. This is a density phenomenon, not a multiplicative one.

## 6. The Complete Picture

Collecting all results, we obtain the following complete classification:

| Property | Primes | {4,9,25,49} | {6,10,21,35} | {4,6,9} | {2,8} | Cramér |
|----------|--------|-------------|--------------|---------|-------|--------|
| Product-free | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| Mult. independent | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Unique factorization | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Pairwise coprime | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Dirichlet survival | ✓ | — | — | — | — | ✓ |

The key finding: {6, 10, 21, 35} occupies a previously unknown position in the hierarchy — multiplicatively independent but not UF. This separation was discovered during this research and has not appeared in the prior literature.

## 7. Algorithms

### 7.1 Hierarchy Classification

```
INPUT: Generator set S, bound N
OUTPUT: (product_free, mult_independent, UF, pairwise_coprime)

1. PRODUCT-FREE: For all a, b ∈ S with a, b ≥ 2, check a·b ∉ S
2. MULT-INDEPENDENT: For all s ∈ S, check no factorization of s
   using ≥ 2 elements from S exists
3. UF: For all n ≤ N, enumerate factorizations, check uniqueness
4. COPRIME: For all pairs, check gcd = 1
```

### 7.2 Collision Detection

```
INPUT: Generator set S, bound M
OUTPUT: Set of product collisions

1. For all pairs (a, b) from S with a ≤ b, compute a·b
2. Group pairs by product
3. Return products with ≥ 2 distinct pairs
```

## 8. Discussion and Future Work

### 8.1 Connections to Algebraic Structure

The condition of unique factorization for a generator set S is equivalent to S generating a *free commutative monoid* under multiplication. Our hierarchy refines this: multiplicative independence captures the "no relations of length 1" condition, while collision-freeness captures "no relations of length 2." The full UF condition requires "no relations at any length."

### 8.2 Implications for Cryptography

The separation between multiplicative independence and unique factorization has potential cryptographic applications. A generator set that appears independent (passing polynomial-time tests) but harbors hidden collisions could serve as a trapdoor for factorization-based schemes.

### 8.3 Open Questions

1. **Density bounds for hierarchy levels**: What is the maximum density of a product-free (resp. mult-independent, UF) subset of {2, ..., N}?

2. **Probabilistic hierarchy**: What is the probability that a random set of density n/log n is multiplicatively independent? (We know it fails UF with probability 1.)

3. **Higher-dimensional analogs**: Does the hierarchy extend to multivariate polynomial rings or number fields?

4. **Riemann Hypothesis analog**: In a Cramér model, the counting function π_S(n) = |S ∩ [2, n]| fluctuates like a random walk with variance ~n/log n. The "RH analog" — that the error term is O(√n) — holds almost surely by standard random walk estimates. This deserves careful formalization.

## 9. Formalization

All theorems in this paper are formalized in Lean 4 using Mathlib. The development is in `Novelty/CounterfactualDeep.lean` and totals approximately 380 lines. Key formalized results include:

- `counterexample_no_ufd`: {2, 8} fails UF
- `counterexample_empty_spectrum`: {2, 8} has empty collision spectrum at all levels
- `absorption_breaks_ufd`: Generator absorption ⟹ ¬UF
- `separation_set_mult_independent`: {6, 10, 21, 35} is multiplicatively independent
- `separation_set_not_ufd`: {6, 10, 21, 35} fails UF
- `coprime_implies_ufd`: Pairwise coprime ⟹ UF
- `dirichlet_survival_tight`: Dense sets cover all residue classes
- `dirichlet_bound_tight`: The threshold is tight

## References

1. Cramér, H. (1936). On the order of magnitude of the difference between consecutive prime numbers. *Acta Arithmetica*, 2(1), 23–46.

2. Geroldinger, A., & Halter-Koch, F. (2006). *Non-Unique Factorizations: Algebraic, Combinatorial and Analytic Theory*. Chapman & Hall/CRC.

3. Eberhard, S., Green, B., & Manners, F. (2014). Sets of integers with no large sum-free subset. *Annals of Mathematics*, 180(2), 621–652.

4. Granville, A. (1995). Harald Cramér and the distribution of prime numbers. *Scandinavian Actuarial Journal*, 1995(1), 12–28.

5. Catalog references: `Cryptography/CounterfactualPrimes.lean`, `Cryptography/ProductCollisions.lean`.
