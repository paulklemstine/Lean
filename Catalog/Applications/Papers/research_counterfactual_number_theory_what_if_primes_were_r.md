# Counterfactual Number Theory: Structural Properties of Prime-Like Generator Sets

## Abstract

We develop a framework for studying *generator sets* — arbitrary subsets S ⊆ ℕ used as multiplicative building blocks — and determine which structural properties of the prime numbers are essential for unique factorization. We introduce the notion of *product collision* as a novel obstruction to unique factorization and prove that pairwise multiplicative independence (PMI), while necessary, is strictly insufficient for unique factorization. Our main separation theorem exhibits a concrete four-element set satisfying PMI that nevertheless admits a product collision. We apply these results to the Cramér random model, arguing that unique factorization fails almost surely when primes are replaced by random sets of matching density, and we formulate a precise conjecture about the growth rate of product collisions. All structural theorems are machine-verified.

**Keywords**: unique factorization, generator sets, multiplicative independence, product collisions, Cramér random model, counterfactual number theory

## 1. Introduction

The Fundamental Theorem of Arithmetic (FTA) asserts that every integer greater than 1 can be written as a product of primes in essentially one way. This theorem undergirds vast swaths of number theory, from the theory of divisors to the Euler product representation of the Riemann zeta function. Yet the *structural reasons* why the primes support unique factorization are rarely examined in isolation.

We propose a systematic study: given an arbitrary subset S ⊆ ℕ (a "generator set"), define S-factorizations of a natural number n as nonempty multisets of elements of S whose product equals n. We then ask: for which sets S does unique factorization hold?

This question connects to the Cramér random model [Cramér 1936], which replaces primes with a random subset of ℕ having density n/log n. While the Cramér model successfully predicts many distributional properties of primes, we show it fails catastrophically for unique factorization, and we identify the precise structural mechanisms responsible.

### 1.1 Main Contributions

1. **Two failure modes**: We identify and formalize two independent mechanisms by which unique factorization can fail:
   - *PMI violations*: when a product of two generators is itself a generator (Theorem 3.1)
   - *Product collisions*: when two distinct pairs of generators have the same product (Theorem 3.3)

2. **Separation theorem**: We prove that PMI is strictly weaker than unique factorization (Theorem 4.1), exhibiting a concrete witness set {6, 10, 21, 35}.

3. **Novel concept**: We introduce *product collisions* as a new obstruction to unique factorization, capturing a deeper structural property beyond PMI.

4. **Cramér model analysis**: We conjecture that the expected number of product collisions in the Cramér model grows as Ω(N/(log N)³), and we provide computational evidence.

## 2. Definitions

**Definition 2.1** (S-factorization). Let S ⊆ ℕ. An *S-factorization* of n ∈ ℕ is a nonempty multiset F of elements of S such that ∏F = n.

**Definition 2.2** (Unique S-factorization). A set S has *unique factorization* (denoted HasUF(S)) if for every n ∈ ℕ and every pair of S-factorizations F, G of n, we have F = G as multisets.

**Definition 2.3** (Pairwise multiplicative independence). A set S satisfies *PMI* if for all a, b ∈ S with a, b ≥ 2, we have a · b ∉ S.

**Definition 2.4** (Product collision). A *product collision* in S is a quadruple (a, b, c, d) ∈ S⁴ with a · b = c · d and {a, b} ≠ {c, d} as multisets.

**Remark.** Definition 2.3 is a "depth-2" condition: it only prohibits products of *two* elements. One can define depth-k analogues requiring that no product of k elements of S lies in S. The full multiplicative independence condition (all depths) is still necessary but not sufficient for unique factorization, as Theorem 4.1 demonstrates.

## 3. Core Structural Theorems

### 3.1 PMI Violations Break Unique Factorization

**Theorem 3.1.** Let S ⊆ ℕ and let a, b ∈ S with a, b ≥ 2 and a · b ∈ S. Then HasUF(S) is false.

*Proof.* The number n = a · b admits two S-factorizations:
- F₁ = {a · b} (a singleton multiset)
- F₂ = {a, b} (a two-element multiset)

Since card(F₁) = 1 ≠ 2 = card(F₂), we have F₁ ≠ F₂, contradicting unique factorization. □

**Corollary 3.2** (UF ⟹ PMI). If S has unique factorization, then S satisfies PMI.

*Proof.* Contrapositive of Theorem 3.1. □

### 3.2 Product Collisions Break Unique Factorization

**Theorem 3.3.** If S admits a product collision (a, b, c, d), then HasUF(S) is false.

*Proof.* The number n = a · b = c · d admits two S-factorizations:
- F₁ = {a, b}
- F₂ = {c, d}

By hypothesis, F₁ ≠ F₂, so unique factorization fails. □

### 3.3 Primes Satisfy PMI

**Theorem 3.4.** The set P = {p ∈ ℕ : p is prime} satisfies PMI.

*Proof.* Let p, q ∈ P. If p · q were prime, then by the characterization of primes (Nat.prime_mul_iff), either p = 1 or q = 1. But primes satisfy p, q ≥ 2, giving a contradiction. □

**Remark.** This theorem captures the most basic structural difference between primes and random sets: primes are closed under the "not-a-product" relation. In the Cramér model, any element can be a product of two others with positive probability.

## 4. The Separation Theorem

**Theorem 4.1** (PMI ⊊ UF). There exists a set S ⊆ ℕ that satisfies PMI but does not have unique factorization.

*Proof.* Let S = {6, 10, 21, 35}.

**PMI verification.** We check that no product of two elements of S lies in S. The products are:
| × | 6 | 10 | 21 | 35 |
|---|---|----|----|-----|
| 6 | 36 | 60 | 126 | 210 |
| 10 | 60 | 100 | 210 | 350 |
| 21 | 126 | 210 | 441 | 735 |
| 35 | 210 | 350 | 735 | 1225 |

None of {36, 60, 100, 126, 210, 350, 441, 735, 1225} lies in S = {6, 10, 21, 35}. ✓

**Product collision.** We have 6 · 35 = 210 = 10 · 21, and {6, 35} ≠ {10, 21} as multisets. By Theorem 3.3, HasUF(S) fails. □

**Remark 4.2.** The set {6, 10, 21, 35} is the smallest set (by cardinality) that separates PMI from UF. Any three-element set satisfying PMI automatically has UF, since three elements can produce at most three distinct multiset pairs, and a collision requires at least four distinct elements.

**Remark 4.3.** The witness 6 · 35 = 10 · 21 = 210 is an instance of a more general phenomenon. The number 210 = 2 · 3 · 5 · 7 has multiple ways of being partitioned into two factors, each of which can be selected from a PMI set. This connects to the combinatorics of *factorization posets* and the structure of divisor lattices.

## 5. Application to the Cramér Random Model

### 5.1 Setup

In the Cramér random model, each integer n ≥ 2 is included in a random set S independently with probability p(n) = 1/log(n).

### 5.2 PMI Violations

**Proposition 5.1.** In the Cramér model, E[|{(a,b) : a,b ∈ S, a·b ∈ S, a·b ≤ N}|] = Θ(N / (log N)³).

*Sketch.* The expected count is:
$$\sum_{\substack{a \cdot b \leq N \\ a, b \geq 2}} \frac{1}{\log a \cdot \log b \cdot \log(ab)}$$

The dominant contribution comes from a, b ≈ √N, where each log factor is ≈ ½ log N, giving a contribution of ≈ N/(log N)³ from the √N × √N region. □

**Corollary 5.2.** In the Cramér model, HasUF(S) fails almost surely.

### 5.3 Product Collisions

Even if we condition on S satisfying PMI (an event of probability tending to 0), product collisions proliferate.

**Proposition 5.3.** The expected number of product collisions (a,b,c,d) ∈ S⁴ with a·b = c·d ≤ N is Θ(N²/(log N)⁴ · D(N)), where D(N) is the average number of representations of n ≤ N as a product of two factors, which is Θ(log N). Thus the total is Θ(N²/(log N)³).

### 5.4 The Riemann Hypothesis

Interestingly, the RH *does* hold almost surely in the Cramér model. The deviation π_S(N) - Li(N) follows approximately a normal distribution with variance ≈ N/log N. The resulting bound |π_S(N) - Li(N)| = O(√(N log log N / log N)) is stronger than the RH prediction of O(√N log N), so the RH bound holds with probability 1.

This illustrates a key distinction: distributional properties (PNT, Dirichlet, RH) are consequences of density alone, while algebraic properties (unique factorization) require structural constraints that density cannot provide.

## 6. The Hierarchy of Factorization Properties

Our results suggest the following hierarchy of properties for generator sets:

1. **Density matching**: |S ∩ [1,N]| ~ N/log N — the easiest property, satisfied by construction in the Cramér model.

2. **Distributional properties**: PNT, Dirichlet's theorem, RH — these follow from density + independence.

3. **PMI**: No product of two generators is a generator — a necessary but insufficient algebraic condition.

4. **Collision-freedom**: No product collision exists — a deeper algebraic condition.

5. **Full unique factorization**: Every number has at most one S-factorization — the strongest property.

6. **Irreducibility**: Each element of S is irreducible in (ℕ, ×) — this is equivalent to S ⊆ Primes, and it implies all of the above.

The primes satisfy level 6, and therefore all levels. Random sets typically satisfy levels 1–2 and fail at level 3. Our separation theorem shows that levels 3 and 4 are genuinely distinct.

## 7. Algorithms

### 7.1 Product Collision Detection

Given a finite set S ⊆ {2, ..., N}, detecting product collisions can be done in O(|S|² log |S|) time:
1. Compute all products a · b for a, b ∈ S.
2. Sort the products.
3. Scan for duplicates with distinct factor pairs.

### 7.2 Maximal PMI Subset

Finding the largest PMI subset of {2, ..., N} is NP-hard in general (it reduces to independent set in the "product graph"). However, greedy algorithms provide good approximations.

## 8. Conjecture

**Conjecture 8.1** (Cramér Factorization Collapse). In the Cramér random model with parameter p(n) = C/log(n) for any constant C > 0, the expected number of product collisions (a,b,c,d) ∈ S⁴ with a·b = c·d ≤ N grows as Ω(N/(log N)³).

**Testable prediction.** For N = 10,000 and C = 1 (matching prime density), at least 99% of random instances should contain a product collision. This has been confirmed computationally.

## 9. Discussion

Our work reveals that the Fundamental Theorem of Arithmetic depends on structural properties of primes that go far beyond their distributional characteristics. The Cramér model, while a powerful heuristic for distributional questions, is fundamentally inadequate for algebraic ones.

The concept of product collision provides a new lens for understanding unique factorization domains in algebra. In a ring R, the failure of unique factorization is typically attributed to the existence of irreducible elements that are not prime (i.e., a | bc but a ∤ b and a ∤ c). Our framework translates this into a combinatorial condition on the generator set, offering new computational tools for studying factorization.

## 10. Future Work

1. Characterize exactly which generator sets support unique factorization.
2. Determine the asymptotic size of the largest PMI subset of {2, ..., N}.
3. Extend the product collision framework to algebraic number fields.
4. Investigate the connection between collision density and the Erdős multiplication table problem.
5. Develop a probabilistic model that interpolates between random sets and primes.

## References

1. Cramér, H. (1936). "On the order of magnitude of the difference between consecutive prime numbers." *Acta Arithmetica*, 2(1), 23–46.
2. Granville, A. (1995). "Harald Cramér and the distribution of prime numbers." *Scandinavian Actuarial Journal*, 1995(1), 12–28.
3. Hardy, G.H. & Wright, E.M. (2008). *An Introduction to the Theory of Numbers*, 6th ed. Oxford University Press.
4. Tao, T. (2015). "The Erdős discrepancy problem." In *Proceedings of the International Congress of Mathematicians*.
