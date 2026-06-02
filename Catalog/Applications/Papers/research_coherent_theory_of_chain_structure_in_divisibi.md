# Chain Invariants in Divisibility Lattices: Rank, Spectrum, and Rigidity

## Abstract

We develop a theory connecting the combinatorial structure of divisibility chains in the natural numbers with classical arithmetic functions. A *divisibility chain* from 1 to *n* is a strictly increasing sequence 1 = a₀ | a₁ | ... | aₖ = n in the divisibility order. We establish three main results: (1) the **Chain Rank Theorem**, showing that the maximum chain length equals Ω(n), the number of prime factors with multiplicity; (2) **Spectrum Rigidity**, proving that every maximal chain has the same multiset of consecutive quotients (namely, the prime factorization of n), and consequently the same spectrum sum sopfr(n); and (3) **Exponential Growth**, showing that chain elements grow at least as fast as 2ᵏ, yielding the bound Ω(n) ≤ log₂(n). We introduce the *chain spectrum* and *chain defect* as new invariants, formulate a Chain Count Conjecture relating the number of maximal chains to multinomial coefficients, and connect the theory to the Anti-Escher property for infinite descending chains in PIDs. All main theorems are formalized and verified in Lean 4 with Mathlib.

**Keywords**: divisibility lattice, big omega function, prime factorization, chain invariants, Noetherian rings, sopfr

---

## 1. Introduction

The divisibility relation on the natural numbers defines a partial order (in fact, a lattice) whose structure is intimately connected to the arithmetic of prime factorization. While the basic properties of this lattice are well understood, the combinatorial theory of *chains* — totally ordered subsets — within it has received less systematic attention.

A natural question arises: given a positive integer *n*, what is the longest chain from 1 to *n* in the divisibility order? The answer, as we shall prove, is the arithmetic function Ω(n), the total number of prime factors of *n* counted with multiplicity. This result, which we call the **Chain Rank Theorem**, transforms Ω from a purely number-theoretic quantity into a lattice-theoretic invariant measuring the "depth" of *n* in the divisibility lattice.

More surprisingly, we show that maximal chains from 1 to *n* exhibit a remarkable rigidity: while different maximal chains can traverse very different elements, they all share the same *spectrum* — the multiset of consecutive quotients along the chain. This spectrum is always equal to the prime factorization of *n* viewed as a multiset. An immediate corollary is that the sum of consecutive quotients (the *spectrum sum*) equals sopfr(n), the sum of prime factors with repetition.

### 1.1 Organization

Section 2 establishes the complete additivity of Ω and key monotonicity properties. Section 3 defines divisibility chains and proves the Chain Rank Theorem. Section 4 introduces the chain spectrum and proves Spectrum Rigidity. Section 5 establishes exponential growth bounds. Section 6 discusses the Chain Count Conjecture and connections to the Anti-Escher property. Section 7 presents algorithms and computational examples.

---

## 2. Arithmetic Preliminaries

### 2.1 The Big Omega Function

**Definition 2.1.** For a positive integer *n*, define Ω(n) = |n.primeFactorsList|, the length of the prime factorization list of *n*.

Equivalently, if n = p₁^{e₁} · p₂^{e₂} · ... · pₖ^{eₖ}, then Ω(n) = e₁ + e₂ + ... + eₖ.

**Theorem 2.2** (Complete Additivity). *For positive integers a, b:*
$$\Omega(ab) = \Omega(a) + \Omega(b)$$

*Proof sketch.* The prime factorization list of *ab* is a permutation of the concatenation of the factorization lists of *a* and *b*. This follows from the fundamental theorem of arithmetic applied elementwise: for each prime *p*, the *p*-adic valuation satisfies v_p(ab) = v_p(a) + v_p(b), and the total count of prime factors (with multiplicity) is the sum over all primes.

**Corollary 2.3** (Monotonicity). *If a | b with a, b > 0, then Ω(a) ≤ Ω(b). If additionally a ≠ b, then Ω(a) < Ω(b).*

*Proof.* Write b = ac. Then Ω(b) = Ω(a) + Ω(c) ≥ Ω(a). If a ≠ b, then c ≥ 2, so Ω(c) ≥ 1.

### 2.2 Sum of Prime Factors with Repetition

**Definition 2.4.** For a positive integer *n*, define sopfr(n) = Σ_{p ∈ primeFactorsList(n)} p.

For example, sopfr(12) = 2 + 2 + 3 = 7 and sopfr(60) = 2 + 2 + 3 + 5 = 12.

---

## 3. The Chain Rank Theorem

### 3.1 Divisibility Chains

**Definition 3.1.** A *strict divisibility chain* is a list [a₀, a₁, ..., aₖ] of positive integers such that aᵢ | aᵢ₊₁ and aᵢ ≠ aᵢ₊₁ for each i. The *length* of the chain is k (the number of steps).

**Definition 3.2.** A *divisibility chain from 1 to n* is a strict divisibility chain with a₀ = 1 and aₖ = n.

### 3.2 Statement and Proof

**Theorem 3.3** (Chain Rank Theorem). *For any positive integer n, the maximum length of a divisibility chain from 1 to n is Ω(n).*

*Proof.* We establish both bounds separately.

**Upper bound.** Let [1 = a₀, a₁, ..., aₖ = n] be a chain. By Corollary 2.3, Ω(aᵢ) < Ω(aᵢ₊₁) for each i. Thus the sequence Ω(a₀), Ω(a₁), ..., Ω(aₖ) is strictly increasing in ℕ. Since Ω(a₀) = Ω(1) = 0, we have Ω(aᵢ) ≥ i for all i, giving k ≤ Ω(aₖ) = Ω(n).

**Lower bound.** Let [p₁, p₂, ..., pₘ] = primeFactorsList(n) with m = Ω(n). Define the chain as the list of partial products:
  a₀ = 1, a₁ = p₁, a₂ = p₁p₂, ..., aₘ = p₁p₂···pₘ = n.

This is a valid chain: each aᵢ divides aᵢ₊₁ (since aᵢ₊₁ = aᵢ · pᵢ₊₁), and aᵢ ≠ aᵢ₊₁ (since pᵢ₊₁ ≥ 2). The chain has length m = Ω(n).

---

## 4. Spectrum Rigidity

### 4.1 The Chain Spectrum

**Definition 4.1.** The *spectrum* of a strict divisibility chain [a₀, a₁, ..., aₖ] is the list of consecutive quotients [a₁/a₀, a₂/a₁, ..., aₖ/aₖ₋₁].

**Definition 4.2.** The *spectrum sum* of a chain is the sum of its spectrum.

**Proposition 4.3** (Telescoping). *The product of the spectrum of a chain from 1 to n equals n.*

*Proof.* The product telescopes: ∏ᵢ (aᵢ₊₁/aᵢ) = aₖ/a₀ = n/1 = n.

### 4.2 Maximal Chain Spectrum

**Theorem 4.4** (Spectrum Primality). *In a maximal chain from 1 to n (one of length Ω(n)), every element of the spectrum is prime.*

*Proof.* A maximal chain has Ω(n) steps, starting from Ω(1) = 0 and ending at Ω(n). Each step increases Ω by at least 1 (Corollary 2.3). Since the total increase equals the number of steps, each step increases Ω by exactly 1. At step i with quotient qᵢ = aᵢ₊₁/aᵢ, we have Ω(aᵢ₊₁) = Ω(aᵢ) + Ω(qᵢ) by complete additivity. Thus Ω(qᵢ) = 1. Since qᵢ ≥ 2, this implies qᵢ is prime.

**Theorem 4.5** (Spectrum Rigidity). *For any maximal chain from 1 to n, the spectrum sum equals sopfr(n).*

*Proof.* By Theorem 4.4, the spectrum is a list of primes. By Proposition 4.3, their product is n. By the uniqueness of prime factorization, this list is a permutation of primeFactorsList(n). Since permutations preserve sums, the spectrum sum equals sopfr(n).

### 4.3 Discussion

Theorem 4.5 establishes a surprising invariance: every maximal path from 1 to *n* in the divisibility lattice, despite potentially visiting entirely different intermediate elements, always "costs" the same total amount measured by the sum of step ratios.

This result can be interpreted information-theoretically. Each step in a maximal chain "reveals" exactly one prime factor of *n*. Different chains reveal the factors in different orders, but the total information content — measured by the spectrum sum — is invariant.

---

## 5. Exponential Growth

**Theorem 5.1** (Exponential Growth). *In any strict divisibility chain [a₀, a₁, ..., aₖ], we have aᵢ ≥ 2ⁱ for all i.*

*Proof.* By induction on i. The base case a₀ ≥ 1 = 2⁰ follows from positivity. For the inductive step, aᵢ₊₁ = aᵢ · qᵢ where qᵢ = aᵢ₊₁/aᵢ ≥ 2 (since aᵢ properly divides aᵢ₊₁ with aᵢ > 0). So aᵢ₊₁ ≥ 2aᵢ ≥ 2 · 2ⁱ = 2ⁱ⁺¹.

**Corollary 5.2.** *For any positive integer n, Ω(n) ≤ log₂(n).*

*Proof.* A maximal chain from 1 to *n* has length Ω(n), and its last element is n ≥ 2^{Ω(n)}.

---

## 6. Extensions and Conjectures

### 6.1 Chain Count Conjecture

**Conjecture 6.1.** *For n = p₁^{e₁} · p₂^{e₂} · ... · pₖ^{eₖ}, the number of maximal divisibility chains from 1 to n equals the multinomial coefficient Ω(n)! / (e₁! · e₂! · ... · eₖ!).*

**Computational Evidence:**
| n | Factorization | Ω(n) | Predicted count | Verified count |
|---|---|---|---|---|
| 12 | 2² · 3 | 3 | 3!/(2!·1!) = 3 | 3 |
| 30 | 2 · 3 · 5 | 3 | 3! = 6 | 6 |
| 60 | 2² · 3 · 5 | 4 | 4!/(2!) = 12 | 12 |
| 360 | 2³ · 3² · 5 | 6 | 6!/(3!·2!) = 60 | 60 |

### 6.2 The Chain Defect

**Definition 6.2.** The *chain defect* of a divisibility chain from 1 to *n* is δ = Ω(n) - len(chain). A chain is maximal iff δ = 0.

The chain defect measures how far a chain is from being maximally refined. It has potential applications in algorithmic number theory, where the choice of chain (i.e., the order in which to apply prime factor tests) can affect computational efficiency.

### 6.3 Anti-Escher Property

**Theorem 6.3** (Anti-Escher, proved in companion file). *In ℤ, any infinite strictly descending chain of nonzero principal ideals has trivial intersection.*

This result follows from exponential growth: the generators of such a chain grow at least as fast as 2ⁿ, so no nonzero integer can be divisible by all of them.

**Conjecture 6.4** (Escher Conjecture). *Every non-Noetherian integral domain admits an infinite strictly descending chain of nonzero ideals with nonzero intersection.*

---

## 7. Algorithms

### 7.1 Computing Chain Invariants

```
Algorithm: ComputeChainInvariants(n)
Input: Positive integer n
Output: Ω(n), sopfr(n), list of maximal chains

1. Compute factorization n = p₁^{e₁} · ... · pₖ^{eₖ}
2. Set Ω ← e₁ + ... + eₖ
3. Set sopfr ← e₁·p₁ + ... + eₖ·pₖ
4. Build factor list L = [p₁, ..., p₁, p₂, ..., p₂, ..., pₖ, ..., pₖ]
5. For each distinct permutation σ of L:
   a. Build chain: [1, σ(1), σ(1)·σ(2), ..., n]
   b. Add to output list
6. Return (Ω, sopfr, chains)
```

### 7.2 Complexity

Step 1 (factorization) dominates at O(√n). Step 5 enumerates Ω(n)!/(e₁!·...·eₖ!) permutations. For highly composite numbers, this count can be large, but for most numbers it is manageable.

---

## 8. Discussion

The results in this paper establish the divisibility lattice of ℕ as a remarkably rigid combinatorial structure. Three themes emerge:

1. **Arithmetic functions as lattice invariants.** The Chain Rank Theorem shows that Ω(n) is not merely a count of prime factors but the lattice-theoretic depth of *n*. Similarly, sopfr(n) emerges as the unique spectrum sum of any maximal chain.

2. **Rigidity from unique factorization.** The Spectrum Rigidity theorem is, at heart, a consequence of the uniqueness of prime factorization. But it reveals this uniqueness in a new guise: not as a statement about the representation of *n*, but as a constraint on the *paths* through the lattice to *n*.

3. **Growth constraints.** The exponential growth lemma provides a bridge between the additive structure (Ω as a sum of exponents) and the multiplicative structure (chain elements as products). The logarithmic bound Ω(n) ≤ log₂(n) is one manifestation of this bridge.

---

## 9. Future Work

- Extend the chain theory to rings of algebraic integers, where unique factorization may fail.
- Prove the Chain Count Conjecture.
- Study the distribution of chain lengths for random *n*.
- Explore connections between chain defect and algorithmic complexity of factorization.
- Investigate analogues for polynomial rings and function fields.

---

## References

1. Hardy, G. H. & Wright, E. M. *An Introduction to the Theory of Numbers*, 6th ed. Oxford University Press, 2008.
2. Stanley, R. P. *Enumerative Combinatorics*, Vol. 1, 2nd ed. Cambridge University Press, 2012.
3. Grätzer, G. *Lattice Theory: Foundation*. Birkhäuser, 2011.
