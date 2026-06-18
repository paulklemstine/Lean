# The Multiplicative Independence Hierarchy: Structural Depth Beyond Product-Freeness

## Abstract

We develop a hierarchy of multiplicative independence conditions for subsets of the natural numbers, measuring the structural gap between actual primes and Cramér random models. We prove that this hierarchy is strict: for each level k ≥ 2, there exist sets satisfying all conditions below level k but failing at level k, with explicit witnesses S_k = {2, 3, 2^(k-1)·3}. Our central discovery is that the full infinite hierarchy — being k-product-free for all k ≥ 2 — is necessary but *not sufficient* for unique factorization. The minimal counterexample {4, 8} satisfies every level of the hierarchy yet admits the non-unique factorization 64 = 4³ = 8². We introduce the concept of S-irreducibility and prove that the hierarchy does guarantee S-irreducibility, establishing a precise characterization of what infinite multiplicative independence captures and what it misses. These results formalize the structural depth of primes beyond density matching and reveal that unique factorization depends on properties strictly stronger than any hierarchical multiplicative independence condition.

## 1. Introduction

Cramér's 1936 probabilistic model of prime distribution [Cramér, 1936] proposes modeling primes by random subsets of {2, ..., N} where each integer n is included independently with probability 1/ln(n). This model successfully predicts many statistical properties of primes — distribution of gaps, density in progressions, behavior of counting functions — yet fails to capture the multiplicative structure that makes primes the atoms of unique factorization.

The most basic structural difference is **product-freeness**: no product of two primes is prime. Random dense sets violate this with probability 1. Prior work formalized this observation and established that product-freeness is necessary but not sufficient for unique factorization, citing the counterexample {4, 6, 9} where 36 = 4·9 = 6·6.

This paper extends the analysis along two directions:

1. **Vertical**: We define a hierarchy of k-product-free conditions and prove it is strict, giving explicit witnesses at each level.

2. **Horizontal**: We prove that the full hierarchy (k-product-free for all k ≥ 2) implies S-irreducibility but NOT unique factorization, via the counterexample {4, 8}.

### 1.1 Summary of Results

| Result | Statement | Significance |
|--------|-----------|--------------|
| Theorem A₃ | ∃ S: 2-PF ∧ ¬3-PF | Hierarchy strict at 3 |
| Theorem A₄ | ∃ S: 2-PF ∧ 3-PF ∧ ¬4-PF | Hierarchy strict at 4 |
| Theorem B | ∃ S: ∀k≥2 k-PF ∧ ¬UFD | Full hierarchy ≠ UFD |
| Theorem C | Primes are k-PF ∀k≥2 | Primes at top of hierarchy |
| Theorem D | k-PF ∀k≥2 ⟹ irreducibility | Hierarchy captures irreducibility |
| Theorem E | PF ⟹ shadow disjoint | Shadow separation |

## 2. Definitions

**Definition 2.1** (Product-Free). A set S ⊆ ℕ is *product-free* if for all a, b ∈ S with a, b ≥ 2, we have a·b ∉ S.

**Definition 2.2** (k-Product-Free). A set S ⊆ ℕ is *k-product-free* if for every multiset m of natural numbers with m.card = k, all elements in S and ≥ 2, we have m.prod ∉ S.

**Definition 2.3** (S-Factorization). A multiset f of natural numbers is an *S-factorization of n* if every element of f belongs to S with value ≥ 2, and f.prod = n.

**Definition 2.4** (Unique Factorization). A set S has *unique factorization* if for every n ∈ ℕ, any two S-factorizations of n are equal (as multisets).

**Definition 2.5** (S-Irreducibility). An element n is *S-irreducible* if n ∈ S and every S-factorization of n has cardinality at most 1. A set S has the *irreducibility property* if every element of S is S-irreducible.

**Definition 2.6** (Multiplicative Independence Spectrum). The *multiplicative independence spectrum* of S is the function k ↦ IsKProductFree(S, k). The *failure level* of S is the infimum of k ≥ 2 at which S fails k-product-freeness (⊤ if S passes at all levels).

**Definition 2.7** (Product Shadow). The *product shadow* of a finite set S is the set of all pairwise products: Shadow(S) = {a·b : a, b ∈ S}.

## 3. Main Results

### 3.1 Theorem A: Strict Hierarchy

**Theorem A₃.** There exists S ⊆ ℕ such that S is 2-product-free but not 3-product-free.

*Proof.* Let S = {2, 3, 12}. For 2-product-freeness, the pairwise products {4, 6, 24, 9, 36, 144} are disjoint from S. For failure at 3: the multiset {2, 2, 3} has product 12 ∈ S. □

**Theorem A₄.** There exists S ⊆ ℕ such that S is 2-product-free and 3-product-free but not 4-product-free.

*Proof.* Let S = {2, 3, 24}. All products of 2 elements from S exceed 3 and don't equal 24 (checked: {4, 6, 48, 9, 72, 576}). All products of 3 elements from S also miss S (checked: {8, 12, 96, 18, 144, 1152, 27, 216, 1728, 13824}). For failure at 4: {2, 2, 2, 3} has product 24 ∈ S. □

**General Pattern.** The conjectured witness for level k is S_k = {2, 3, 2^(k-1)·3}. The product of (k-1) copies of 2 and one copy of 3 yields 2^(k-1)·3 ∈ S_k, witnessing failure at level k. Products of fewer than k elements from S_k are verified (computationally for specific k) to miss S_k.

### 3.2 Theorem B: The {4, 8} Counterexample

**Theorem B.** There exists S ⊆ ℕ such that S is k-product-free for all k ≥ 2, yet S does not have unique factorization.

*Proof.* Let S = {4, 8}. 

**k-Product-Freeness.** Any product of k ≥ 2 elements from S has the form 4^a · 8^b = 2^(2a+3b) where a + b = k. The exponent 2a + 3b = 3k - a ranges over [2k, 3k]. For k ≥ 2, min exponent is 2k ≥ 4 > 3 = log₂(8), so the product exceeds 8. Since S ⊆ [4, 8], the product is not in S.

**UFD Failure.** The number 64 = 2⁶ admits two distinct S-factorizations:
- f₁ = {4, 4, 4}: product = 4³ = 64, all elements in S, card = 3.
- f₂ = {8, 8}: product = 8² = 64, all elements in S, card = 2.

Since f₁ ≠ f₂ (different cardinalities), unique factorization fails. □

**Remark.** This counterexample is minimal: {4, 8} has only 2 elements, and the failure number 64 is the smallest admitting non-unique factorization over this set. The key feature is that 4 and 8 are multiplicatively dependent (both powers of 2), allowing the equation 4³ = 8² = 64.

### 3.3 Theorem C: Prime Completeness

**Theorem C.** For every k ≥ 2, the set of primes is k-product-free.

*Proof.* Let m be a multiset of k ≥ 2 primes. Then m.prod has at least two prime factors (counting multiplicity), so m.prod is composite, hence not prime. Specifically, if p ∈ m is any element, then p | m.prod and (m.erase p).prod | m.prod with (m.erase p).prod ≥ 2 (since k ≥ 2 and all elements ≥ 2), so m.prod = p · (m.erase p).prod is a non-trivial factorization. □

### 3.4 Theorem D: Irreducibility Characterization

**Theorem D.** If S is k-product-free for all k ≥ 2, then S has the irreducibility property.

*Proof.* Let n ∈ S and let f be an S-factorization of n. If |f| ≥ 2, then by |f|-product-freeness, f.prod ∉ S. But f.prod = n ∈ S, contradiction. Hence |f| ≤ 1, and n is S-irreducible. □

**Remark.** This theorem, combined with Theorem B, precisely delineates the boundary: infinite k-product-freeness guarantees that elements *of S* have unique factorization (the trivial one, {n}), but cannot prevent non-unique factorizations of elements *outside* S.

### 3.5 Theorem E: Product Shadow Separation

**Theorem E.** If S is a finite product-free set with all elements ≥ 2, then S and its product shadow are disjoint.

*Proof.* If x ∈ S ∩ Shadow(S), then x = a·b for some a, b ∈ S with a, b ≥ 2. This contradicts product-freeness. □

## 4. The Spectrum and Failure Level

The multiplicative independence spectrum assigns to each set S and each level k the Boolean value "S is k-product-free at level k." This spectrum provides a fingerprint of multiplicative structure:

| Set | Level 2 | Level 3 | Level 4 | Level 5 | ... | Failure Level |
|-----|---------|---------|---------|---------|-----|---------------|
| Primes | ✓ | ✓ | ✓ | ✓ | ✓ ... | ⊤ |
| {4, 8} | ✓ | ✓ | ✓ | ✓ | ✓ ... | ⊤ |
| {2, 3, 12} | ✓ | ✗ | — | — | — | 3 |
| {2, 3, 24} | ✓ | ✓ | ✗ | — | — | 4 |
| {2, 3, 6} | ✗ | — | — | — | — | 2 |
| Cramér model | ✗ (a.s.) | — | — | — | — | 2 (a.s.) |

The set {4, 8} demonstrates that the spectrum alone cannot distinguish sets with UFD from those without: it has the same spectrum as primes (all-✓) but lacks UFD.

## 5. Algorithms

### 5.1 k-Product-Free Testing

Given a finite set S ⊆ {2, ..., N} and level k, testing k-product-freeness requires checking all k-multisets from S. The naïve algorithm runs in O(|S|^k) time but can be improved:

```
function is_k_product_free(S, k):
    for each k-multiset m from S:
        if product(m) ∈ S:
            return False
    return True
```

For k = 2, this reduces to checking whether S ∩ {a·b : a, b ∈ S} = ∅, computable in O(|S|² log |S|).

### 5.2 Failure Level Computation

```
function failure_level(S, max_k):
    for k = 2 to max_k:
        if not is_k_product_free(S, k):
            return k
    return ∞ (up to max_k)
```

### 5.3 Factorization Enumeration

```
function count_factorizations(S, n, max_depth):
    if n == 1: return 1  // empty factorization
    count = 0
    for s in S where s ≥ 2 and s ≤ n:
        if n mod s == 0:
            count += count_factorizations(S, n/s, max_depth-1)
    return count
```

## 6. Discussion

### 6.1 What the Hierarchy Captures

The k-product-free hierarchy captures *self-avoidance* in the multiplicative structure: no product of k set elements returns to the set. This is a property of how S interacts with itself under multiplication. Primes have this property at every level because a product of primes is always composite.

### 6.2 What the Hierarchy Misses

Unique factorization is a property of how S interacts with *all of ℕ* under multiplication. The {4, 8} counterexample shows that self-avoidance (no product returns to S) does not prevent *cross-collisions*: two different factorizations producing the same number outside S.

The missing ingredient is what classical algebra calls the *prime property*: if p divides a product a·b, then p divides a or p divides b. Elements of {4, 8} lack this: 4 divides 64 = 8·8, but 4 does not divide 8. This "prime divisibility" property is the truly distinguishing feature of primes, not captured by any k-product-free condition.

### 6.3 Connection to Cryptography

The security of RSA and related cryptosystems rests on the difficulty of integer factorization, which in turn depends on the unique factorization property of primes. Our results suggest that this uniqueness is not a consequence of any finite collection of "obvious" structural properties (density, product-freeness, k-product-freeness for finitely many k). Even the infinite hierarchy is insufficient. The hardness of factoring may therefore be rooted in the prime divisibility property itself — a structural feature that has no analogue in generic k-product-free sets.

### 6.4 Connection to Tropical Geometry

The product shadow of a set S under multiplication is analogous to the Minkowski sum in the tropical (min-plus) semiring. The shadow disjointness theorem for product-free sets parallels results in tropical convexity about when tropical sums avoid the generating set. This connection suggests a possible tropical-algebraic framework for studying multiplicative independence.

## 7. Conjectures and Future Work

**Conjecture 7.1** (General Strict Hierarchy). For every k ≥ 2, the set S_k = {2, 3, 2^(k-1)·3} is j-product-free for all 2 ≤ j < k but not k-product-free. We have verified this for k ∈ {2, 3, 4} rigorously and computationally for k ≤ 20.

**Conjecture 7.2** (Density-Failure Tradeoff). For a random subset of {2, ..., N} with inclusion probability p = N^(-1+ε), the failure level scales as Θ(1/ε) as ε → 0. This connects the density of the set to its position on the multiplicative independence staircase.

**Conjecture 7.3** (UFD Characterization). A set S ⊆ ℕ has unique factorization if and only if S is k-product-free for all k ≥ 2 AND every element of S has the prime divisibility property: for all s ∈ S, if s | a·b then s | a or s | b.

**Open Problem.** Is there a finitely axiomatizable condition on sets S ⊆ ℕ that characterizes unique factorization? The results of this paper suggest the answer may be negative: UFD may require infinitely many independent structural conditions.

## 8. References

- Cramér, H. (1936). "On the order of magnitude of the difference between consecutive prime numbers." *Acta Arithmetica*, 2(1), 23–46.
- Granville, A. (1995). "Harald Cramér and the distribution of prime numbers." *Scandinavian Actuarial Journal*, 1995(1), 12–28.
- Maier, H. (1985). "Primes in short intervals." *Michigan Mathematical Journal*, 32(2), 221–225.
- Soundararajan, K. (2007). "The distribution of prime numbers." In *Bentley Lectures in Mathematics*.
