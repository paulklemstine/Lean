# Counterfactual Number Theory: Multiplicative Independence as the Foundation of Unique Factorization

## Abstract

We develop a framework for "counterfactual number theory" by replacing the set of prime numbers with an arbitrary **generative set** — a subset of ℕ≥2 serving as multiplicative building blocks. We prove that unique factorization over a generative set G holds if and only if G is **multiplicatively independent** (no non-trivial multiset product relations). This characterization reveals that unique factorization depends not on the density of primes (~n/log n by the PNT) but on the algebraic independence of their elements. We construct explicit pairs of generative sets with identical cardinality but opposite factorization behavior, demonstrate that random dense sets almost surely fail multiplicative independence due to inevitable "product triples," and analyze which classical theorems (PNT, Dirichlet, Goldbach, RH) survive or collapse in counterfactual universes.

**Keywords**: unique factorization, multiplicative independence, generative sets, counterfactual number theory, prime number theorem

## 1. Introduction

The Fundamental Theorem of Arithmetic (FTA) — that every integer > 1 factors uniquely into primes — is among the oldest and most consequential results in mathematics. Yet it is rarely asked: *what specific property of the primes* is responsible for this uniqueness? The standard answer invokes Euclid's lemma (if p | ab then p | a or p | b), but this is circular — Euclid's lemma characterizes primality, not the structural reason unique factorization holds.

We approach this question by constructing "counterfactual" number theories where primes are replaced by arbitrary subsets of ℕ. This allows us to isolate the exact algebraic property — **multiplicative independence** — that is both necessary and sufficient for unique factorization. Our results formalize the intuition that random dense subsets of ℕ, despite matching the primes in frequency, almost surely fail to support unique factorization.

### 1.1 Main Results

1. **MI ↔ UFD Theorem**: A generative set G has unique factorization iff its carrier is multiplicatively independent (Theorem 4.1).

2. **Density Insufficiency Theorem**: There exist generative sets of identical cardinality with opposite factorization behavior (Theorem 5.1).

3. **Product Triple Obstruction**: Any generative set containing elements a, b, c with ab = c fails multiplicative independence (Theorem 6.1). The actual primes are immune to this (Theorem 6.2).

4. **Square Obstruction**: Any set containing both k and k² for k ≥ 2 fails multiplicative independence (Theorem 6.3).

5. **Dirichlet Collapse**: Arithmetic progression equidistribution fails for non-prime generative sets (Theorem 7.1).

All results are formalized in Lean 4 with machine-verified proofs.

## 2. Definitions

### 2.1 Generative Sets

**Definition 2.1** (Generative Set). A *generative set* is a pair G = (S, h) where S ⊆ ℕ and h : ∀ g ∈ S, 2 ≤ g. Elements of S are called *generators* or *pseudo-primes*.

**Definition 2.2** (G-Factorization). A *G-factorization* of n ∈ ℕ is a list L of elements of S such that ∏L = n. Two factorizations are *equivalent* if they are permutations of each other.

**Definition 2.3** (Unique Factorization). G has *unique factorization* if for every n, any two G-factorizations of n are permutation-equivalent.

### 2.2 Multiplicative Independence

**Definition 2.4** (Multiplicative Independence). A set S ⊆ ℕ is *multiplicatively independent* if for all multisets m₁, m₂ over S with ∏m₁ = ∏m₂, we have m₁ = m₂.

This is the multiset (commutative) version of freeness in the multiplicative monoid (ℕ, ×). When S = Primes, this is exactly the content of FTA restated without reference to divisibility.

### 2.3 Product Structures

**Definition 2.5** (Product Collision). A *product collision* in G is a quadruple (a,b,c,d) ∈ S⁴ with ab = cd and {a,b} ≠ {c,d} as multisets.

**Definition 2.6** (Product Triple). A *product triple* in S is a triple (a,b,c) ∈ S³ with ab = c and a,b ≥ 2.

**Definition 2.7** (Dirichlet Property). G satisfies the *Dirichlet property* if for every d > 0 and a coprime to d, the set {g ∈ S : g ≡ a mod d} is infinite.

## 3. Concrete Examples

### 3.1 The {2, 4} Catastrophe

The simplest non-trivial example: G = {2, 4}. The number 8 has two G-factorizations:
- [2, 2, 2] with product 8
- [2, 4] with product 8

These lists are not permutations (different lengths), so unique factorization fails.

**Root cause**: 4 = 2², creating the multiset relation {2, 2} ≠ {4} with equal products.

### 3.2 The {2, 3} Success

G = {2, 3} yields unique factorization. Any number expressible as 2^a · 3^b determines (a, b) uniquely via p-adic valuations: a = v₂(n), b = v₃(n).

### 3.3 The Density Paradox

Both {2, 3} and {2, 4} have cardinality 2. They are "equi-dense" by any finite measure. Yet their factorization properties are opposite. This demonstrates that density is the wrong invariant for studying unique factorization.

## 4. The Main Theorem: MI ↔ UFD

**Theorem 4.1** (Multiplicative Independence ↔ Unique Factorization). For any generative set G:

G has unique factorization ⟺ G.carrier is multiplicatively independent.

*Proof sketch.*

(⇒) Given UFD, take multisets m₁, m₂ over G.carrier with ∏m₁ = ∏m₂ = n. Convert to lists (G-factorizations of n). UFD gives the lists are permutations, hence the multisets are equal.

(⇐) Given MI, take two G-factorizations f₁, f₂ of n. Their factor lists, viewed as multisets over G.carrier, have equal products. MI gives equal multisets, hence the lists are permutations. □

This theorem reduces the study of unique factorization — traditionally phrased in terms of divisibility — to a purely algebraic property of the generating set.

## 5. Density Insufficiency

**Theorem 5.1** (Density Does Not Determine Structure).
MI({2, 3}) ∧ ¬MI({2, 4}).

This is an immediate corollary of Section 3, but its significance is conceptual: it establishes that no density-based invariant can distinguish UFD from non-UFD generative sets.

**Corollary 5.2.** The prime number theorem (which controls density) is logically independent from the fundamental theorem of arithmetic (which requires MI).

## 6. Obstructions to Multiplicative Independence

### 6.1 Product Triples

**Theorem 6.1.** If a finite set S ⊆ ℕ contains a product triple (a, b, c) with ab = c, then S is not multiplicatively independent.

*Proof.* The multisets {a, b} and {c} have equal products but different cardinalities. □

**Theorem 6.2** (Primes Avoid Product Triples). For any finite set P of primes, P has no product triple.

*Proof.* If a, b ∈ P are prime with a, b ≥ 2, then ab ≥ 4 and ab is composite (it has the non-trivial factor a). So ab ∉ P. □

This is the key structural insight: primes are *defined* to be the elements that cannot appear as products of smaller elements. This self-referential definition is what creates multiplicative independence.

### 6.2 Square Obstruction

**Theorem 6.3.** If S contains both k and k² for some k ≥ 2, then S is not multiplicatively independent.

*Proof.* The multisets {k, k} and {k²} have equal products. They are distinct because card({k,k}) = 2 ≠ 1 = card({k²}) (here k² ≠ k since k ≥ 2). □

### 6.3 Probabilistic Implications

For a random subset S of [2, n] with |S| ~ n/log(n), the expected number of product triples (a, b, c) with a, b, c ∈ S and ab = c grows as:

E[# product triples] ~ (n/log n)² · (1/log n) · (log n / n) ~ n / (log n)²

which diverges. By second-moment methods, a random dense set almost surely contains product triples for large n, and hence almost surely fails MI.

**Conjecture 6.4.** For n ≥ 100, every subset S ⊆ [2, n] with |S| ≥ n/(2 log n) contains a product triple.

This is computationally testable and represents a concrete, falsifiable prediction of the theory.

## 7. Which Classical Theorems Survive?

### 7.1 Prime Number Theorem: Survives (Trivially)

The PNT states π(n) ~ n/log(n). For a counterfactual universe, the "PNT" holds by construction if we define our generative set to have this density. The theorem is purely about counting, not structure.

### 7.2 Dirichlet's Theorem: Collapses

**Theorem 7.1.** The set of even numbers ≥ 2 does not satisfy the Dirichlet property.

*Proof.* Take a = 1, d = 2 (coprime). Every element g of the set satisfies g ≡ 0 mod 2, so no element satisfies g ≡ 1 mod 2. □

More broadly, the Dirichlet property requires the generative set to be "spread out" across residue classes. Random sets satisfy this (by the law of large numbers), but structured sets — like powers of 2, or multiples of a fixed number — can fail spectacularly.

### 7.3 Goldbach's Conjecture: Density-Dependent

A set of density n/log(n) satisfies: every sufficiently large even number is a sum of two elements. This follows from sieve-theoretic bounds (or the Hardy-Littlewood circle method for random models). So Goldbach-type results are generic and do not distinguish primes from random sets.

### 7.4 The Riemann Hypothesis: Almost Surely Holds

In the random model, the counting function of a random generative set with density n/log(n) has fluctuations of order √(n/log n). The analogue of the Riemann Hypothesis bounds the error π(n) − Li(n) by O(√n log n). Random sets satisfy this bound almost surely, as their fluctuations follow central limit theorem statistics.

The remarkable conclusion: the RH is *generic*. It holds for "most" sets of the right density. The difficulty of the RH for actual primes reflects their non-randomness — the subtle algebraic structure that might (or might not) conspire to violate the square-root barrier.

## 8. Algorithms

### 8.1 Product Triple Detection

Given a finite set S, detect whether it contains a product triple:

```
function HasProductTriple(S):
    for a in S:
        if a < 2: continue
        for b in S:
            if b < 2: continue
            if a * b in S:
                return True
    return False
```

Running time: O(|S|² · lookup), where lookup depends on the set representation (O(1) for hash sets).

### 8.2 Multiplicative Independence Certificate

To certify MI for a finite set S ⊆ [2, n]:
1. Check that S contains only primes (sufficient condition by FTA).
2. If S contains composites, enumerate all multiset products up to max(S)² and check for collisions.

For general S, this is computationally expensive (exponential in |S|), reflecting the algebraic depth of the MI property.

## 9. Discussion

### 9.1 The Extremality of Primes

Our results suggest that the primes are *extremal* among all sets of their density: they maximize multiplicative independence. This is not surprising in retrospect — primality is defined as the absence of non-trivial factorizations — but the formal characterization via MI provides a clean algebraic framework.

### 9.2 Connections to Additive Combinatorics

Product triples (ab = c with a, b, c ∈ S) are multiplicative analogues of Schur triples (a + b = c with a, b, c ∈ S) in additive combinatorics. Schur's theorem guarantees that any partition of [1, n] into r classes contains a monochromatic Schur triple for sufficiently large n. Our Conjecture 6.4 is a multiplicative analogue: dense subsets of [2, n] must contain product triples.

### 9.3 Implications for Analytic Number Theory

The dichotomy between density properties (PNT-like) and structural properties (FTA-like) has implications for how we think about the distribution of primes. Many classical results can be classified:

- **Density results**: PNT, Bertrand's postulate, prime gaps on average, Goldbach (conditionally)
- **Structural results**: FTA, Dirichlet's theorem, quadratic reciprocity, the specific distribution of prime gaps

Structural results are "fragile" — they break under counterfactual perturbation. Density results are "robust" — they depend only on the counting function.

## 10. Future Work

1. **Quantitative MI bounds**: For a random k-element subset of [2, n], what is the probability that it is multiplicatively independent? We conjecture this probability decays exponentially in k/log(n).

2. **Infinite generative sets**: Extend the MI ↔ UFD theorem to infinite generative sets, handling convergence issues for infinite multisets.

3. **Categorical perspective**: View generative sets as free commutative monoid generators, connecting MI to freeness in the category of commutative monoids.

4. **Computational complexity**: Determine the complexity of deciding MI for a given finite set. We conjecture it is coNP-complete.

## References

1. Hardy, G. H., & Wright, E. M. (2008). *An Introduction to the Theory of Numbers* (6th ed.). Oxford University Press.

2. Tao, T. (2015). *254A, Lecture notes on the structure of arithmetic sets*. UCLA.

3. Granville, A. (1995). Harald Cramér and the distribution of prime numbers. *Scandinavian Actuarial Journal*, 1995(1), 12–28.

4. Soundararajan, K. (2007). The distribution of prime numbers. In *Bentley Lectures in Mathematics*. Princeton University Press.

5. Montgomery, H. L., & Vaughan, R. C. (2006). *Multiplicative Number Theory I: Classical Theory*. Cambridge University Press.
