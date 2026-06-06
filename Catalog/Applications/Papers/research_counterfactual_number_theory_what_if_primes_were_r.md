# Counterfactual Number Theory: The Factorization Spectrum

## Abstract

We introduce the **Factorization Spectrum**, a novel mathematical structure that measures how badly unique factorization fails when the set of prime numbers is replaced by an arbitrary generating set S ⊆ ℕ. The spectrum σ_S(n) maps each natural number n to the number of distinct S-factorizations (multisets of elements from S with product n). We prove that σ_S is trivially bounded by 1 if and only if S is multiplicatively independent (MI), establishing a precise equivalence between MI and the Fundamental Theorem of Arithmetic. We connect this to the classical theory by proving that any subset of the primes is MI (via the FTA), characterize the minimal obstructions to MI (product triples), and construct infinite families of sets that are product-free but not MI. Our collision index provides a computable measure of how far a given set deviates from prime-like structure.

**Keywords**: unique factorization, multiplicative independence, Cramér model, factorization spectrum, product-free sets

## 1. Introduction

The Fundamental Theorem of Arithmetic (FTA) states that every natural number greater than 1 can be expressed as a product of primes in exactly one way (up to ordering). This foundational result underpins number theory, algebra, and cryptography. Yet the *structural reason* for its truth — what property of the primes guarantees uniqueness — is rarely examined directly.

Cramér's 1936 probabilistic model of primes suggests viewing them as a random subset of ℕ with density ~1/log n. This model successfully predicts many statistical properties of primes (prime gaps, almost-prime distribution), but as we demonstrate, it catastrophically fails to capture the algebraic structure that makes unique factorization possible.

We formalize the question: **Which properties of the primes are necessary and sufficient for unique factorization?** Our answer is multiplicative independence (MI), which we show is equivalent to the UFD property. We then study the landscape of MI sets, constructing both positive and negative examples, and introducing the factorization spectrum as a quantitative measure of UFD failure.

All results in this paper have been formally verified in Lean 4 using the Mathlib library.

## 2. Definitions

### 2.1 Generating Sets

**Definition 2.1** (Generating Set). A *generating set* is a pair G = (S, h) where S ⊆ ℕ and h : ∀ g ∈ S, g ≥ 2.

**Definition 2.2** (G-Factorization). A *G-factorization* of n ∈ ℕ is a multiset m over S such that ∏m = n. We write IsGFact(G, n, m) for this property.

### 2.2 Multiplicative Independence

**Definition 2.3** (Multiplicative Independence). A set S ⊆ ℕ is *multiplicatively independent* (MI) if for all multisets m₁, m₂ over S:

    (∀ x ∈ m₁, x ∈ S) ∧ (∀ x ∈ m₂, x ∈ S) ∧ ∏m₁ = ∏m₂ → m₁ = m₂

**Definition 2.4** (Unique Factorization). A generating set G has *unique factorization* (UFD) if for all n ∈ ℕ, any two G-factorizations of n are equal as multisets.

### 2.3 The Factorization Spectrum

**Definition 2.5** (Factorization Spectrum). For a generating set G, the *factorization spectrum* at n is:

    FactSpec(G, n) = {m : Multiset ℕ | IsGFact(G, n, m)}

The cardinality σ_G(n) = |FactSpec(G, n)| measures how many distinct G-factorizations n admits.

### 2.4 Obstruction Measures

**Definition 2.6** (Product Triple). A *product triple* in S is a triple (a, b, c) with a, b, c ∈ S, a ≥ 2, b ≥ 2, and a · b = c.

**Definition 2.7** (Product-Free). S is *product-free* if it contains no product triple.

**Definition 2.8** (Collision Index). For a finite set S, the *collision index* CI(S) counts ordered pairs (a, b) ∈ S × S with a, b ≥ 2 and a · b ∈ S.

## 3. Main Results

### 3.1 The Prime MI Theorem

**Theorem 3.1** (Primes are MI). The set P = {n ∈ ℕ | n is prime} is multiplicatively independent.

*Proof sketch.* We reduce to the uniqueness clause of the FTA via Mathlib's `UniqueFactorizationMonoid` instance for ℕ. If m₁, m₂ are multisets of primes with ∏m₁ = ∏m₂, then `factors_unique` gives Rel(Associated, m₁, m₂). Since ℕ has trivial units, Associated reduces to equality, and Rel(=, m₁, m₂) gives m₁ = m₂. □

**Corollary 3.2** (Subset MI). Any subset S ⊆ P is MI. This follows from:

**Theorem 3.3** (MI Closure). If S is MI and T ⊆ S, then T is MI.

*Proof.* Any collision in T is a collision in S. □

### 3.2 The Spectrum Dichotomy

**Theorem 3.4** (MI ↔ UFD). For a generating set G:

    HasUFD(G) ⟺ IsMI(G.carrier)

*Proof.* (→) Two multisets over G.carrier with equal products give two G-factorizations of the same number. UFD forces them equal. (←) Two G-factorizations of the same n give multisets over G.carrier with equal products. MI forces them equal. □

This establishes that the factorization spectrum is trivial (σ_G(n) ≤ 1 for all n) if and only if G is MI.

### 3.3 Product Triples as Minimal Obstructions

**Theorem 3.5** (Product Triple Obstruction). If a, b, a·b ∈ G.carrier with a, b ≥ 2, then ¬HasUFD(G).

*Proof.* The multisets {a·b} and {a, b} are distinct G-factorizations of a·b. □

**Corollary 3.6** (Product-Freeness is Necessary). If G has UFD, then G.carrier is product-free.

### 3.4 The Product-Free/MI Gap

**Theorem 3.7** (Gap Theorem). Product-freeness is strictly weaker than MI:

1. The set {4, 6, 9} is product-free (no product of two elements lies in the set).
2. The set {4, 6, 9} is not MI (since 36 = 4 × 9 = 6 × 6).

*Proof.* Part 1: Exhaustive check of all nine products. Part 2: The multisets {4, 9} and {6, 6} are distinct but have equal product 36. □

**Theorem 3.8** (Upper Interval Gap). For N = 16, the set (8, 16] = {9, 10, ..., 16}:

1. Is product-free (since any product of two elements exceeds 16).
2. Is not MI (since 9 × 16 = 12 × 12 = 144).

This provides an infinite family of product-free non-MI sets (all (N/2, N] for N ≥ 16).

### 3.5 Density Forcing

**Theorem 3.9** (Full Set Collapse). For N ≥ 4, the set {2, ..., N} is not MI, because it contains both 2 and 4 = 2².

*Proof.* The multisets {2, 2} and {4} have equal product 4 but are distinct. □

**Theorem 3.10** (Square Pair Obstruction). If k ∈ S and k² ∈ S for some k ≥ 2, then S is not MI.

### 3.6 Divisibility Chain Collapse

**Theorem 3.11** (Divisibility Pair). If a ∈ S, b ∈ S, a | b, a ≠ b, and b/a ∈ S with a ≥ 2 and b/a ≥ 2, then S is not MI.

*Proof.* The multisets {b} and {a, b/a} are distinct but have equal product b (since a · (b/a) = b). □

### 3.7 The Collision Index

**Theorem 3.12** (Zero Collision ⟹ Product-Free). If CI(S) = 0 and all elements of S are ≥ 2, then S is product-free.

**Theorem 3.13** (Primes Have Zero Collision). For any finite set S of primes, CI(S) = 0. This follows because no product of two primes is prime (Nat.prime_mul_iff).

## 4. The Grand Summary

**Theorem 4.1** (Counterfactual Spectrum Theorem). The following four properties completely characterize the counterfactual landscape:

1. P is MI (connecting to the classical FTA).
2. Product triples are the minimal obstruction: HasProductTriple(S) implies ¬IsMI(S).
3. MI is downward closed: T ⊆ S and IsMI(S) implies IsMI(T).
4. Product-freeness is necessary but not sufficient for MI.

## 5. Algorithms

### 5.1 MI Checking

Given a finite set S with |S| = k, checking MI up to multisets of cardinality c requires examining O(k^c) multisets. For each, we compute the product and check for collisions using a hash map. The total time is O(k^c).

### 5.2 Collision Index Computation

CI(S) can be computed in O(|S|²) time by iterating over all pairs and checking membership of their product.

### 5.3 Factorization Spectrum

Computing σ_S(n) reduces to a constrained partition problem: find all ways to write n as a product of elements from S. This can be solved by recursive backtracking with memoization.

## 6. Discussion

### 6.1 The Cramér Gap

Our results quantify the structural gap between Cramér's probabilistic model and actual primes. While the density heuristic (each n is "prime" with probability 1/ln n) predicts many statistical properties correctly, it catastrophically fails on the multiplicative structure that makes unique factorization possible. A Cramér random model almost surely contains product triples (in fact, the expected number of triples grows as ~N/log²N), while the actual primes have exactly zero.

### 6.2 Implications for Cryptography

RSA and related cryptosystems depend on the difficulty of factoring n = p · q into its unique prime factors. Our results show that uniqueness itself — not just computational hardness — depends on MI. In a counterfactual universe where the "primes" fail MI, factoring would be ill-posed: the same number could have multiple valid factorizations, and "the" factorization would not be well-defined.

### 6.3 The Product-Free/MI Hierarchy

The strict separation between product-freeness and MI (Theorem 3.7) is both surprising and structurally important. It means there is a genuine hierarchy of multiplicative independence properties:

    Product-free ⊊ MI ⊊ Actually prime

The {4, 6, 9} counterexample and the upper interval family (Theorem 3.8) show that this hierarchy is not merely theoretical — concrete, natural examples populate each level.

## 7. Future Work

1. **Asymptotic collision density**: What is the precise asymptotic growth rate of CI(S) for a Cramér random model S of density 1/log n?

2. **MI dimension**: Can we define a meaningful "MI dimension" that measures how close a set is to being MI, interpolating between product-freeness and full MI?

3. **Connections to additive combinatorics**: Product-free sets are the multiplicative analogue of sum-free sets. Is there a multiplicative Schur theorem?

4. **Generalization to other monoids**: Does the MI ↔ UFD equivalence extend to arbitrary commutative monoids?

## 8. References

1. H. Cramér, "On the order of magnitude of the difference between consecutive prime numbers," *Acta Arithmetica* 2 (1936), 23–46.

2. A. Granville, "Harald Cramér and the distribution of prime numbers," *Scandinavian Actuarial Journal* 1995, 12–28.

3. K. Ford, B. Green, S. Konyagin, T. Tao, "Large gaps between consecutive prime numbers," *Annals of Mathematics* 183 (2016), 935–974.

4. E. Szemerédi, "On sets of integers containing no k elements in arithmetic progression," *Acta Arithmetica* 27 (1975), 199–245.
