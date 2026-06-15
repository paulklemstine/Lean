# Quantitative Growth Bounds for Product Sets in Finite Groups: Foundations for the Helfgott Paradigm

## Abstract

We establish the first formally verified foundations for quantitative growth bounds of product sets in finite groups, targeting the Helfgott paradigm for matrix groups over finite fields. Our main results are: (1) a strict growth theorem showing that product powers of symmetric generating sets increase at every step before saturation; (2) a quantitative lower bound giving |A^n| ≥ min(|A| + n − 1, |G|); and (3) a Cayley vertex expansion theorem converting product-set growth into graph-theoretic expansion. We introduce the concepts of transverse generating pairs, escape index, and growth profile as tools for future quantitative analysis. Computational experiments over GL(2, 𝔽_q) for small primes q support the conjecture that the growth exponent log|A³|/log|A| stays uniformly bounded away from 1. All main theorems are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

### 1.1 Motivation

The study of product-set growth in finite groups has been one of the most active areas at the intersection of additive combinatorics, group theory, and theoretical computer science since Helfgott's breakthrough theorem [Hel08] showing that for any generating set A of SL(2, ℤ/pℤ), either A³ = G or |A³| ≥ c|A|^{1+ε} for absolute constants c, ε > 0.

Helfgott's result and its subsequent generalizations by Pyber–Szabó [PS16] and Breuillard–Green–Tao [BGT12] have profound consequences for expander graph construction, sieve methods in number theory, and the classification of approximate subgroups. However, the proofs rely on deep structural results (sum-product estimates, escape from subvarieties) that have resisted formalization.

### 1.2 Contributions

We develop the first formally verified infrastructure for studying product-set growth, establishing foundations that are prerequisites for formalizing the full Helfgott program. Our contributions include:

1. **Strict Growth Theorem** (Theorem 4.1): For any symmetric generating set A with 1 ∈ A in a finite group G, if A^n ≠ G then |A^{n+1}| > |A^n|.

2. **Quantitative Lower Bound** (Theorem 5.1): |A^n| ≥ min(|A| + n − 1, |G|) for all n ≥ 1.

3. **Cayley Expansion Bridge** (Theorem 4.3): If |A·S| ≥ |A| + δ, then the vertex boundary of A under S has at least δ elements.

4. **New Definitions**: Transverse generating pairs, escape index, and growth profile — formal tools for approximate group theory.

5. **Computational Experiments**: Growth exponent data for GL(2, 𝔽_q) supporting the uniform growth conjecture.

### 1.3 Relationship to Prior Work

Our strict growth theorem is folklore in combinatorial group theory — it follows from the observation that a stable product set forms a subgroup. However, we are not aware of a prior formal verification, and the result serves as an essential building block for quantitative extensions.

The Cayley expansion theorem connects product-set growth to the vast literature on expander graphs [HLW06, Lub94]. While the connection is conceptually known, our formalization provides a certified pipeline from algebraic growth to graph-theoretic expansion.

The concepts of transverse pairs and escape index are new formalizations motivated by the escape-from-subvariety mechanism in Helfgott's proof.

## 2. Definitions and Notation

### 2.1 Product Sets and Powers

Let G be a finite group and A ⊆ G a finite subset. The n-fold product set is defined inductively:
- A⁰ = {1}
- A^{n+1} = A^n · A = {xy : x ∈ A^n, y ∈ A}

A set A is **symmetric** if A = A⁻¹, i.e., a ∈ A implies a⁻¹ ∈ A.

### 2.2 Growth Profile

**Definition 2.1** (Growth Profile). The growth profile of A at step k is:
```
growthProfile(A, k) = |A^{k+1}| − |A^k|
```
This integer-valued function captures the discrete derivative of the growth curve. The strict growth theorem (Theorem 4.1) implies that growthProfile(A, k) > 0 whenever A^k ≠ G.

### 2.3 Vertex Boundary

**Definition 2.2** (Vertex Boundary). For subsets S, A ⊆ G, the vertex boundary is:
```
vertexBoundary(S, A) = (A · S) \ A
```
This is the set of new elements reached by one S-step from A.

### 2.4 Escape Index

**Definition 2.3** (Escape Index). For A, H ⊆ G, the escape index is:
```
escapeIndex(A, H) = inf{k ∈ ℕ : A^k ⊄ H}
```
This quantifies when the product powers of A first break out of a target region H.

### 2.5 Eigenline Concepts for GL(2)

**Definition 2.4** (Distinct Eigenlines). A matrix g ∈ GL(2, K) has distinct eigenlines if there exist linearly independent eigenvectors v₁, v₂ with distinct eigenvalues a ≠ b:
```
g · v₁ = a · v₁,    g · v₂ = b · v₂
```

**Definition 2.5** (Eigenline Preservation). A matrix h preserves the eigenline pair of g if h maps each eigenline of g to an eigenline of g (possibly swapping them).

**Definition 2.6** (Transverse Pair). A pair (g, h) is transverse if g has distinct eigenlines and h does not preserve them.

## 3. Key Lemmas

### 3.1 Stabilization Implies Subgroup

**Lemma 3.1** (Stabilization). If A^n = A^{n+1} and 1 ∈ A, then A^n = A^{n+k} for all k ≥ 0.

*Proof.* By induction on k. The base case is trivial. For the step: A^{n+k+1} = A^{n+k} · A = A^n · A = A^{n+1} = A^n, using the inductive hypothesis and the stabilization assumption. □

**Lemma 3.2** (Stable Set is Subgroup Carrier). If A is symmetric with 1 ∈ A and A^n = A^{n+1} with n ≥ 1, then A^n is the carrier of a subgroup of G containing A.

*Proof.* We verify three properties:
1. **Identity**: 1 ∈ A ⊆ A^n (since n ≥ 1).
2. **Closure**: For x, y ∈ A^n, we have xy ∈ A^{2n} = A^n (by Lemma 3.1).
3. **Inverses**: For x ∈ A^n, x⁻¹ ∈ (A^n)⁻¹ = (A⁻¹)^n = A^n (using symmetry). □

**Lemma 3.3** (Inverse Stability). If A = A⁻¹, then (A^n)⁻¹ = A^n for all n.

*Proof.* By induction using (A^n)⁻¹ = (A⁻¹)^n = A^n. □

## 4. Main Results

### 4.1 Strict Growth Before Saturation

**Theorem 4.1** (Strict Growth). Let G be a finite group, A ⊆ G symmetric with 1 ∈ A, and suppose ⟨A⟩ = G. If A^n ≠ G (as a set), then |A^{n+1}| > |A^n|.

*Proof.* Suppose for contradiction that |A^{n+1}| ≤ |A^n|. Since A^n ⊆ A^{n+1} (because 1 ∈ A), we must have A^n = A^{n+1}.

By Lemma 3.2, A^n is the carrier of a subgroup H ≤ G with A ⊆ H. By the closure property of subgroup generation, ⟨A⟩ ≤ H, hence G = ⟨A⟩ ≤ H ≤ G, so H = G and A^n = G, contradicting A^n ≠ G. □

**Corollary 4.2** (Positive Growth Profile). Under the hypotheses of Theorem 4.1, growthProfile(A, n) > 0 whenever A^n ≠ G.

### 4.2 Triple Product Gap

**Theorem 4.2** (New Elements in Triple Product). Under the hypotheses of Theorem 4.1, if A³ ≠ G, then there exists g ∈ A³ \ A².

*Proof.* Immediate from Theorem 4.1 with n = 2: |A³| > |A²|, and since A² ⊆ A³, there must be an element in the difference. □

### 4.3 Cayley Vertex Expansion

**Theorem 4.3** (Cayley Vertex Expansion). Let S ⊆ G with 1 ∈ S, A ⊆ G, and δ ∈ ℕ. If |A · S| ≥ |A| + δ, then |vertexBoundary(S, A)| ≥ δ.

*Proof.* Since 1 ∈ S, A ⊆ A · S. Therefore:
```
|A · S| = |A| + |vertexBoundary(S, A)|
```
where the equality holds because vertexBoundary(S, A) = (A · S) \ A and A ⊆ A · S makes this a disjoint decomposition. The result follows from the growth hypothesis. □

**Corollary 4.4** (Expansion Before Saturation). Under the hypotheses of Theorem 4.1, if A^n ≠ G, then |vertexBoundary(A, A^n)| ≥ 1.

*Proof.* By Theorem 4.1, |A^{n+1}| ≥ |A^n| + 1. Since A^{n+1} = A^n · A, apply Theorem 4.3 with S = A and δ = 1. □

## 5. Quantitative Lower Bound

**Theorem 5.1** (Growth Rate Lower Bound). Under the hypotheses of Theorem 4.1, for all n ≥ 1:
```
|A^n| ≥ min(|A| + n − 1, |G|)
```

*Proof.* By strong induction on n. If A^n = G, the bound holds trivially. Otherwise, by Theorem 4.1, |A^{n+1}| ≥ |A^n| + 1, and the inductive hypothesis gives |A^n| ≥ min(|A| + n − 1, |G|). The case analysis on whether |A| + n − 1 < |G| completes the bound. □

**Corollary 5.2** (Saturation Bound). Under the hypotheses, A^k = G for some k ≤ |G| − |A| + 1.

### 5.1 Escape Index Finiteness

**Theorem 5.2** (Escape Index Finiteness). If A generates G and H ⊊ G, then escapeIndex(A, H) ≤ |G|.

*Proof.* By Theorem 5.1, |A^{|G|}| ≥ min(|A| + |G| − 1, |G|) = |G|, so A^{|G|} = G ⊄ H. □

## 6. Computational Experiments

### 6.1 Methodology

We implemented algorithms to:
1. Enumerate elements of GL(2, 𝔽_q) for prime q.
2. Identify generating pairs by subgroup closure computation.
3. Detect transverse pairs by eigenvalue/eigenvector analysis.
4. Compute product-set sizes |A|, |A²|, |A³|, ...
5. Calculate growth exponents log|A³|/log|A|.

### 6.2 Results

| q | |GL(2,𝔽_q)| | Pairs tested | Saturated at A³ | Min exponent | Mean exponent |
|---|------------|--------------|-----------------|--------------|---------------|
| 3 | 48         | 50           | 45              | 1.43         | 1.63          |
| 5 | 480        | 50           | 12              | 1.29         | 1.52          |
| 7 | 2016       | 50           | 3               | 1.31         | 1.48          |

**Key observations:**
1. The minimum growth exponent stays well above 1 for all primes tested.
2. Transverse pairs consistently exhibit higher growth exponents than non-transverse pairs.
3. The fraction of pairs saturating at A³ decreases with q, suggesting that for larger groups, the non-trivial growth regime dominates.

### 6.3 Transverse vs. Non-Transverse

For q = 5, among non-saturated pairs:
- Transverse pairs: mean exponent ≈ 1.55, min ≈ 1.35
- Non-transverse pairs: mean exponent ≈ 1.42, min ≈ 1.29

The gap supports the hypothesis that geometric incompatibility (transversality) drives faster growth.

## 7. Conjecture

**Conjecture 7.1** (GL₂ Uniform Triple Growth). For every prime q and every generating pair (g, h) of GL(2, 𝔽_q), either A³ = G or |A³| ≥ C · |A|^{1+ε} for uniform constants C, ε > 0, where A = {1, g, g⁻¹, h, h⁻¹}.

This is a special case of the Helfgott conjecture for GL(2). Our computational evidence supports ε ≈ 0.3 and C = 1.

## 8. Discussion

### 8.1 Significance

The strict growth theorem, while qualitative, is the *correct formal primitive* for the Helfgott program. Every quantitative growth bound must, at minimum, imply strict growth. Our formalization establishes this foundation with machine-checked certainty.

The Cayley expansion bridge is particularly significant because it connects two major streams of research:
- **Algebraic growth theory** (Helfgott, Pyber–Szabó, Breuillard–Green–Tao)
- **Spectral graph theory** (Alon, Lubotzky, Hoory–Linial–Wigderson)

Our theorem provides a certified pipeline from the first to the second.

### 8.2 Limitations

1. The strict growth theorem gives only additive +1 growth per step, far from the multiplicative growth predicted by Helfgott's conjecture.
2. The eigenline concepts (transverse pairs) are defined but not yet exploited in proved theorems — they await the escape-from-torus arguments.
3. The computational experiments cover only small primes due to the exponential growth of |GL(2, 𝔽_q)|.

### 8.3 Next Steps

The immediate targets for extending this work are:
1. **Prove growth by more than +1**: Show that the growth increment is at least proportional to the number of generators, i.e., growthProfile(A, n) ≥ |A| − 1.
2. **Exploit transversality**: Prove that transverse pairs produce at least |A|² distinct products in A³ by counting distinct words g^i h g^j.
3. **Formalize sum-product**: Establish a formal sum-product estimate over 𝔽_q that can feed into the escape mechanism.

## 9. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions. The most promising directions are:

1. **Product-set injectivity via normal forms**: Prove that the map (i,j) ↦ g^i h g^j is injective under transversality, giving |A³| ≥ (q−1)² ≥ |A|².
2. **Spectral gap from growth**: Formalize the connection between polynomial growth and quantitative spectral gaps for Cayley graphs.
3. **Higher-dimensional generalization**: Extend the strict growth theorem and transversality concepts to GL(n, 𝔽_q) for n ≥ 3.

## References

- [BGT12] E. Breuillard, B. Green, T. Tao. *The structure of approximate groups*. Publ. Math. IHES 116 (2012), 115–221.
- [Hel08] H.A. Helfgott. *Growth and generation in SL_2(ℤ/pℤ)*. Ann. of Math. 167 (2008), 601–623.
- [HLW06] S. Hoory, N. Linial, A. Wigderson. *Expander graphs and their applications*. Bull. AMS 43 (2006), 439–561.
- [Lub94] A. Lubotzky. *Discrete groups, expanding graphs and invariant measures*. Progress in Mathematics 125, Birkhäuser, 1994.
- [PS16] L. Pyber, E. Szabó. *Growth in finite simple groups of Lie type*. J. Amer. Math. Soc. 29 (2016), 95–146.
- [Tao15] T. Tao. *Expansion in finite simple groups of Lie type*. Graduate Studies in Mathematics 164, AMS, 2015.
