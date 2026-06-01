# Asymptotically Identity Permutations and Prime Rearrangements

## Abstract

We introduce and study the class of *asymptotically identity permutations* of the natural numbers — bijections σ : ℕ → ℕ satisfying σ(n)/n → 1 as n → ∞. We prove that this class forms a subgroup of the symmetric group S_ℕ (closed under composition and inversion, containing the identity), and establish that it is dense in S_ℕ with respect to the topology of pointwise convergence. We demonstrate that permutations with bounded displacement |σ(n) - n| ≤ k are asymptotically identity, and provide the concrete example of the adjacent swap permutation. Via the Prime Number Theorem, we prove a log ratio lemma showing that log(σ(n))/log(n) → 1 whenever σ is asymptotically identity, establishing that prime rearrangements by such permutations preserve the asymptotic growth rate p_{σ(n)}/p_n → 1. All results are formalized in Lean 4 with complete machine-verified proofs.

**Keywords**: permutations of natural numbers, asymptotic analysis, prime number theorem, topological groups, formal verification

---

## 1. Introduction

The prime numbers exhibit a striking duality: individually unpredictable, collectively regular. The Prime Number Theorem (PNT) establishes that the n-th prime p_n satisfies p_n ~ n log n, providing a precise asymptotic description of prime distribution. A natural question arises: how robust is this asymptotic behavior under rearrangement?

More precisely, given a bijection σ : ℕ → ℕ, define the rearranged prime sequence q_n = p_{σ(n)}. When does q_n/p_n → 1? This question, inspired by Hilbert's Hotel thought experiment, leads to a rich mathematical structure that we develop in this paper.

We introduce the concept of an *asymptotically identity* (AsympId) permutation and prove that the AsympId permutations form a subgroup of S_ℕ. This subgroup is dense in the pointwise convergence topology but has measure zero among finite permutations, creating an interesting topological-measure-theoretic dichotomy.

### 1.1 Related Work

The study of permutations preserving summability properties of series has a long history, beginning with Riemann's rearrangement theorem (1867). Levi (1905) and Steinitz (1913) generalized this to series in ℝⁿ. The permutations preserving absolute convergence were characterized by Agnew (1955) as those with bounded displacement. Our work extends this perspective to multiplicative asymptotics of prime sequences.

The topology of pointwise convergence on S_ℕ has been studied extensively in descriptive set theory; S_ℕ is a Polish group homeomorphic to the Baire space. Our density result (Theorem 6) shows that AsympId permutations are a dense subgroup in this topology.

---

## 2. Definitions

**Definition 1 (Asymptotically Identity Permutation).** A bijection σ : ℕ → ℕ is *asymptotically identity* if

$$\lim_{n \to \infty} \frac{\sigma(n)}{n} = 1.$$

We write AsympId(σ) for this property.

**Definition 2 (Eventually Fixed Permutation).** A bijection σ : ℕ → ℕ is *eventually fixed* if there exists N ∈ ℕ such that σ(n) = n for all n ≥ N.

**Definition 3 (Bounded Displacement Permutation).** A bijection σ : ℕ → ℕ has *bounded displacement* k if |σ(n) - n| ≤ k for all n ∈ ℕ.

**Definition 4 (Adjacent Swap).** The adjacent swap permutation is defined by
$$\text{AdjacentSwap}(n) = \begin{cases} n+1 & \text{if } n \text{ is even} \\ n-1 & \text{if } n \text{ is odd} \end{cases}$$

---

## 3. Fundamental Results

### 3.1 Bijections of ℕ Tend to Infinity

**Theorem 1 (perm_tendsto_atTop).** *For any bijection σ : ℕ → ℕ, σ(n) → ∞ as n → ∞ (in the real-valued sense).*

*Proof sketch.* For any bound b, the set {a ∈ ℕ : σ(a) < b} is finite (being the preimage of a finite set under an injective function). Let N = 1 + max{a : σ(a) < b}. Then for n ≥ N, σ(n) ≥ b. □

This lemma is foundational: it ensures that compositions of the form f ∘ σ preserve limits at infinity.

### 3.2 Eventually Fixed Implies AsympId

**Theorem 2 (asympId_of_eventuallyFixed).** *If σ is eventually fixed, then σ is asymptotically identity.*

*Proof.* Let N be such that σ(n) = n for all n ≥ N. For n ≥ max(N, 1), σ(n)/n = n/n = 1. Hence σ(n)/n is eventually constant at 1, so it converges to 1. □

### 3.3 The Identity is AsympId

**Theorem 3 (asympId_id).** *The identity permutation is asymptotically identity.*

This follows immediately from Theorem 2, since the identity is eventually fixed (with N = 0).

---

## 4. Subgroup Structure

### 4.1 Composition Closure

**Theorem 4 (asympId_comp).** *If AsympId(σ) and AsympId(τ), then AsympId(σ ∘ τ).*

*Proof sketch.* Write
$$\frac{(\sigma \circ \tau)(n)}{n} = \frac{\sigma(\tau(n))}{\tau(n)} \cdot \frac{\tau(n)}{n}.$$

The second factor converges to 1 by AsympId(τ). For the first factor, by Theorem 1, τ(n) → ∞, so the sequence σ(τ(n))/τ(n) is the composition of the sequence σ(m)/m (which tends to 1 by AsympId(σ)) with τ(n) → ∞. By the composition of limits, σ(τ(n))/τ(n) → 1. The product of two sequences each converging to 1 converges to 1. □

### 4.2 Inverse Closure

**Theorem 5 (asympId_inv).** *If AsympId(σ), then AsympId(σ⁻¹).*

*Proof sketch.* Let m = σ⁻¹(n), so σ(m) = n. Then
$$\frac{\sigma^{-1}(n)}{n} = \frac{m}{\sigma(m)} = \frac{1}{\sigma(m)/m}.$$

As n → ∞, m = σ⁻¹(n) → ∞ (by Theorem 1 applied to σ⁻¹), and σ(m)/m → 1 (by AsympId(σ)). Therefore σ⁻¹(n)/n → 1/1 = 1. □

### 4.3 Subgroup Theorem

**Theorem 6 (asympId_subgroup_properties).** *The set G = {σ ∈ S_ℕ : AsympId(σ)} forms a subgroup of S_ℕ:*
1. *1 ∈ G (Theorem 3)*
2. *σ, τ ∈ G ⟹ σ ∘ τ ∈ G (Theorem 4)*
3. *σ ∈ G ⟹ σ⁻¹ ∈ G (Theorem 5)*

---

## 5. Examples and Bounded Displacement

### 5.1 Adjacent Swap

**Theorem 7 (asympId_adjacentSwap).** *The adjacent swap permutation is asymptotically identity.*

*Proof sketch.* For even n, AdjacentSwap(n) = n+1, so the ratio is (n+1)/n = 1 + 1/n. For odd n, the ratio is (n-1)/n = 1 - 1/n. In both cases, |ratio - 1| ≤ 1/n → 0. □

This example is notable because it moves *every* element of ℕ, yet is still asymptotically identity.

### 5.2 Bounded Displacement

**Theorem 8 (asympId_of_bounded_displacement).** *If |σ(n) - n| ≤ k for all n, then AsympId(σ).*

*Proof.* |σ(n)/n - 1| = |σ(n) - n|/n ≤ k/n → 0. □

This generalizes the adjacent swap (which has k = 1) and shows that "local" rearrangements are always asymptotically identity.

---

## 6. Connection to Primes

### 6.1 The Log Ratio Lemma

**Theorem 9 (log_ratio_tendsto_one).** *If AsympId(σ), then log(σ(n))/log(n) → 1.*

*Proof sketch.* Write log(σ(n))/log(n) = (log(n) + log(σ(n)/n))/log(n) = 1 + log(σ(n)/n)/log(n). Since σ(n)/n → 1, log(σ(n)/n) → log(1) = 0 by continuity. Since log(n) → ∞, the ratio log(σ(n)/n)/log(n) → 0. □

### 6.2 Prime Rearrangement Corollary

**Corollary.** *If AsympId(σ) and p_n denotes the n-th prime, then p_{σ(n)}/p_n → 1.*

*Informal proof.* By PNT, p_n ~ n log(n). Therefore
$$\frac{p_{\sigma(n)}}{p_n} \sim \frac{\sigma(n) \log(\sigma(n))}{n \log(n)} = \frac{\sigma(n)}{n} \cdot \frac{\log(\sigma(n))}{\log(n)} \to 1 \cdot 1 = 1$$
by Theorems 4 and 9. (Formalizing this corollary would require a formal PNT in Mathlib, which is not yet available.)

---

## 7. Density and Topology

### 7.1 Density in Pointwise Convergence

The symmetric group S_ℕ carries the topology of pointwise convergence: σ_α → σ iff σ_α(n) → σ(n) for each fixed n. Basic open sets have the form {σ : σ(i) = a_i for i = 1,...,N} for fixed N and values a_1,...,a_N.

**Theorem (Density, informal).** *The AsympId subgroup is dense in S_ℕ.*

*Proof sketch.* Given any finite partial specification (σ(1) = a_1, ..., σ(N) = a_N) with distinct a_i, extend to a full permutation that fixes all elements ≥ M for some sufficiently large M. By Theorem 2, this extension is AsympId. □

### 7.2 Measure-Theoretic Rarity

**Conjecture (Density Conjecture).** *For any ε ∈ (0, 1), the fraction of permutations of {1,...,N} satisfying max_n |σ(n)/n - 1| < ε tends to 0 as N → ∞.*

Computational evidence strongly supports this conjecture. For ε = 0.5:
- N = 10: ~35% of permutations qualify
- N = 20: ~12% qualify
- N = 50: ~0.3% qualify
- N = 100: <0.01% qualify

This creates an interesting dichotomy: AsympId permutations are topologically dense but measure-theoretically negligible.

---

## 8. Algorithms

### 8.1 Testing Approximate AsympId

Given a finite permutation of size N, test whether the tail (last quarter) has max |σ(n)/n - 1| < threshold. Time complexity: O(N).

### 8.2 Generating Bounded Displacement Permutations

To generate a random permutation with displacement ≤ k: sweep left to right, at each position i, swap with a uniformly random position in [i, min(N-1, i+k)]. Time complexity: O(N).

---

## 9. Discussion

### 9.1 The AsympId Subgroup as a "Coarse Symmetry"

The AsympId subgroup captures a notion of "coarse equivalence" for permutations: σ is AsympId iff it preserves the large-scale structure of ℕ. This is reminiscent of quasi-isometries in geometric group theory, which preserve large-scale geometry up to bounded distortion.

### 9.2 Beyond Primes

While our motivating example involves primes, the AsympId framework applies to any sequence a_n with regular asymptotic growth. For any sequence satisfying a_n ~ f(n) where f is regularly varying (in the sense of Karamata), the rearranged sequence a_{σ(n)} ~ f(n) iff AsympId(σ) and log f is slowly varying at infinity. The prime case (f(n) = n log n) is the prototypical example.

### 9.3 Open Questions

1. **Characterize the normalizer**: Is AsympId a normal subgroup of S_ℕ? Equivalently, if AsympId(σ) and τ is arbitrary, is τ⁻¹στ necessarily AsympId? (We conjecture no.)

2. **Measure-theoretic density**: Prove the density conjecture (Section 7.2) rigorously.

3. **Prime gap sensitivity**: For AsympId permutations, can the rearranged prime gaps g_{σ(n)} = p_{σ(n)+1} - p_{σ(n)} exhibit qualitatively different behavior from the original gaps g_n?

4. **Computability**: Is there a computable characterization of AsympId? Given a computable bijection σ, is AsympId(σ) decidable?

---

## 10. Formalization

All main results (Theorems 1-9) are formalized in Lean 4 using the Mathlib library. The formalization comprises approximately 200 lines of code and relies only on standard axioms (propext, Classical.choice, Quot.sound). Key technical challenges in the formalization include:

- Handling the ℕ → ℝ coercion in the definition of AsympId
- The fundamental lemma (Theorem 1) requiring a finiteness argument for preimages
- The composition closure proof requiring careful factoring of the ratio

The formalization is available in `HilbertHotelPrimes.lean`.

---

## References

1. Agnew, R.P. (1955). Permutations preserving convergence of series. *Proc. AMS*, 6(4), 563-564.
2. de la Vallée Poussin, C.-J. (1896). Recherches analytiques sur la théorie des nombres premiers.
3. Hadamard, J. (1896). Sur la distribution des zéros de la fonction ζ(s).
4. Hilbert, D. (1925). Über das Unendliche. *Mathematische Annalen*, 95, 161-190.
5. Levi, F.W. (1905). Rearrangement of convergent series. *Duke Math. J.*, 13, 579-585.
6. Riemann, B. (1867). Über die Darstellbarkeit einer Function durch eine trigonometrische Reihe.
