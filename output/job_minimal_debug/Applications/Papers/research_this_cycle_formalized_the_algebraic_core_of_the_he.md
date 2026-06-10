# The Cassini-Hecke Identity: Algebraic Foundations of the Hecke Eigenvalue Recursion for GL₂

## Abstract

We establish the algebraic foundations of the Hecke eigenvalue recursion h(n+2) = a·h(n+1) − q·h(n) for GL₂ over arbitrary commutative rings. Our central result is the **Cassini-Hecke identity** h(n+1)² − h(n+2)·h(n) = q^(n+1), proved by induction without analytic machinery. This generalizes the classical Fibonacci–Cassini identity and encodes the propagation of the Frobenius determinant through all prime power levels. We prove an addition formula, a companion matrix power formula, parity identities, and analyze the tropical (min-plus) dequantization of the recursion, showing that the tropical sequence linearizes precisely in the Ramanujan regime. We introduce a Maslov dequantization bridge via soft-min interpolation between the classical and tropical recursions.

**Keywords**: Hecke eigenvalues, Cassini identity, linear recurrence, tropical mathematics, Maslov dequantization, Langlands program, GL₂

## 1. Introduction

### 1.1 Background

Let p be a prime and π an unramified automorphic representation of GL₂ over a non-archimedean local field with residue field of order q. The Hecke eigenvalues at prime powers p^n are determined by the Satake parameters α, β — the roots of the characteristic polynomial X² − a_p X + q, where a_p is the Hecke eigenvalue at p. Explicitly, h(n) = (α^(n+1) − β^(n+1))/(α − β) when α ≠ β.

This formula, while elegant, requires working over an algebraically closed field. The sequence h(n), however, is defined purely algebraically by the second-order recurrence

> h(0) = 1, h(1) = a, h(n+2) = a · h(n+1) − q · h(n)

and makes sense over any commutative ring R. This observation motivates a purely algebraic treatment of the structural identities satisfied by {h(n)}.

### 1.2 Main Results

Over any commutative ring R, with a, q ∈ R:

1. **Cassini-Hecke Identity** (Theorem 3.1): h(n+1)² − h(n+2)·h(n) = q^(n+1) for all n ≥ 0.

2. **Addition Formula** (Theorem 3.2): h(m+n+2) = h(m+1)·h(n+1) − q·h(m)·h(n) for all m, n ≥ 0.

3. **Companion Matrix Power** (Theorem 3.3): M^(n+2) = [[h(n+2), −q·h(n+1)], [h(n+1), −q·h(n)]] where M = [[a, −q], [1, 0]].

4. **Parity Identity** (Theorem 3.4): heckeSeq(−a, q, n) = (−1)^n · heckeSeq(a, q, n).

5. **Tropical Linearization** (Theorem 4.1): When 2a ≤ q (Ramanujan regime), the tropical Hecke sequence satisfies tropHeckeSeq(a, q, n) = n·a.

6. **Boundary Case** (Theorem 5.1): heckeSeq(2, 1, n) = n + 1 for all n ≥ 0.

### 1.3 Relation to Prior Work

The Cassini identity for Fibonacci numbers dates to 1680. Its generalization to Lucas sequences is classical; see Ribenboim (1999). The specific form for Hecke eigenvalues appears implicitly in the theory of modular forms but is typically derived analytically using the Satake isomorphism and Chebyshev polynomials. Our algebraic proof, valid over arbitrary commutative rings, appears to be new.

The tropical dequantization perspective connects to the work of Viro (2001) and Mikhalkin (2005) on tropical algebraic geometry, and to Maslov's idempotent analysis. The specific application to Hecke recursions and the observation of linearization in the Ramanujan regime appear to be new.

## 2. Definitions

### 2.1 The Hecke Eigenvalue Sequence

**Definition 2.1.** Let R be a commutative ring and a, q ∈ R. The *Hecke eigenvalue sequence* heckeSeq(a, q, ·) : ℕ → R is defined by:
- heckeSeq(a, q, 0) = 1
- heckeSeq(a, q, 1) = a
- heckeSeq(a, q, n+2) = a · heckeSeq(a, q, n+1) − q · heckeSeq(a, q, n)

**Definition 2.2.** The *Cassini defect* at step n is:
HeckeCassiniDefect(a, q, n) = h(n+1)² − h(n+2) · h(n)

**Definition 2.3.** The *companion matrix* of the Hecke recursion is:
M(a, q) = [[a, −q], [1, 0]] ∈ Mat₂(R)

**Definition 2.4.** The *characteristic polynomial* is:
P(X) = X² − aX + q ∈ R[X]

### 2.2 The Tropical Hecke Sequence

**Definition 2.5.** The *tropical Hecke sequence* tropHeckeSeq(a, q, ·) : ℕ → ℝ is defined by:
- tropHeckeSeq(a, q, 0) = 0
- tropHeckeSeq(a, q, 1) = a
- tropHeckeSeq(a, q, n+2) = min(a + tropHeckeSeq(a, q, n+1), q + tropHeckeSeq(a, q, n))

This is the *Maslov dequantization* of the classical recursion, obtained by the logarithmic substitution h(n) ↦ t·log(h(n)) and taking t → 0, which sends (×, +) ↦ (+, min).

### 2.3 The Maslov-Deformed Sequence

**Definition 2.6.** For t > 0, the *soft minimum* is:
softMin(t, x, y) = −t · log(exp(−x/t) + exp(−y/t))

**Definition 2.7.** The *Maslov-deformed Hecke sequence* maslovHeckeSeq(t, a, q, ·) : ℕ → ℝ is defined by replacing min with softMin(t, ·, ·) in the tropical recursion.

## 3. Main Results: Classical Theory

### 3.1 The Cassini-Hecke Identity

**Theorem 3.1** (Cassini-Hecke). *For all a, q ∈ R and n ≥ 0:*
h(n+1)² − h(n+2) · h(n) = q^(n+1)

*Proof sketch.* By induction on n.

**Base case** (n = 0): h(1)² − h(2) · h(0) = a² − (a² − q) · 1 = q = q¹. ✓

**Inductive step**: Assume h(n+1)² − h(n+2) · h(n) = q^(n+1). Using h(n+3) = a · h(n+2) − q · h(n+1) and h(n+2) = a · h(n+1) − q · h(n):

h(n+2)² − h(n+3) · h(n+1) = h(n+2)² − (a · h(n+2) − q · h(n+1)) · h(n+1)
= h(n+2)² − a · h(n+2) · h(n+1) + q · h(n+1)²
= h(n+2)(h(n+2) − a · h(n+1)) + q · h(n+1)²
= h(n+2)(−q · h(n)) + q · h(n+1)²
= q · (h(n+1)² − h(n+2) · h(n))
= q · q^(n+1) = q^(n+2). ∎

**Corollary 3.1.1.** h(n+2) · h(n) − h(n+1)² = −q^(n+1).

**Corollary 3.1.2** (Fibonacci–Cassini). Setting a = 1, q = −1: F(n+1)² − F(n+2) · F(n) = (−1)^(n+1).

### 3.2 The Addition Formula

**Theorem 3.2** (Addition Formula). *For all a, q ∈ R and m, n ≥ 0:*
h(m+n+2) = h(m+1) · h(n+1) − q · h(m) · h(n)

*Proof sketch.* By induction on n with m as a parameter. The base case n = 0 reduces to the recursion definition. The inductive step uses the recursion to express h(m+n+3) in terms of h(m+n+2) and h(m+n+1), then applies the inductive hypotheses at (m, n) and (m+1, n) to factor out the recursion in the n-variable. ∎

**Remark.** Setting m = n gives h(2n+2) = h(n+1)² − q · h(n)², a "duplication formula" analogous to the Fibonacci identity F(2n) = F(n)(2F(n+1) − F(n)).

### 3.3 The Companion Matrix

**Theorem 3.3** (Matrix Power Formula). det(M(a,q)) = q, and for all n ≥ 0:

M(a,q)^(n+2) = [[h(n+2), −q · h(n+1)], [h(n+1), −q · h(n)]]

*Proof sketch.* The determinant is a · 0 − (−q) · 1 = q. The matrix power formula follows by induction: M^(n+3) = M · M^(n+2), and multiplying out gives the recursion for each entry. ∎

**Corollary 3.3.1.** det(M^(n+2)) = q^(n+2), which gives:
h(n+2) · (−q · h(n)) − (−q · h(n+1)) · h(n+1) = q^(n+2),
i.e., h(n+1)² − h(n+2) · h(n) = q^(n+1). This recovers the Cassini-Hecke identity.

### 3.4 Parity and Specializations

**Theorem 3.4** (Parity). heckeSeq(−a, q, n) = (−1)^n · heckeSeq(a, q, n).

**Theorem 3.5.** heckeSeq(a, 0, n) = a^n (trivial representation).

**Theorem 3.6.** heckeSeq(0, q, 2k) = (−q)^k and heckeSeq(0, q, 2k+1) = 0.

**Theorem 3.7** (Boundary Case). heckeSeq(2, 1, n) = n + 1.

*Proof.* By induction: h(n+2) = 2 · h(n+1) − h(n) = 2(n+2) − (n+1) = n + 3 = (n+2) + 1. ∎

### 3.5 Trace Relation

**Theorem 3.8.** h(n+2) + q · h(n) = a · h(n+1).

This follows immediately from the recursion definition by rearrangement.

## 4. Tropical Theory

### 4.1 Ramanujan Linearization

**Theorem 4.1** (Tropical Affinity in the Ramanujan Regime). *If 2a ≤ q, then tropHeckeSeq(a, q, n) = n · a for all n ≥ 0.*

*Proof sketch.* By strong induction. The key observation is that when 2a ≤ q, we have q + n · a ≥ 2a + n · a = (n+2) · a and a + (n+1) · a = (n+2) · a, so the minimum always selects the a-branch: min((n+2)a, q + na) = (n+2)a. ∎

**Theorem 4.2** (Vanishing Tropical Cassini Defect). *If 2a ≤ q, then:*
2 · tropHeckeSeq(a, q, n+1) − tropHeckeSeq(a, q, n+2) − tropHeckeSeq(a, q, n) = 0

*Proof.* Immediate from Theorem 4.1: 2(n+1)a − (n+2)a − na = 0. ∎

### 4.2 Interpretation

The condition 2a ≤ q is the tropical analog of the **Ramanujan bound** a² ≤ 4q. In the classical setting, this bound is equivalent to the Satake parameters having equal absolute values (|α| = |β| = √q), which is the Ramanujan conjecture for GL₂. In the tropical setting, the bound becomes an *exact* linearization condition: the tropical sequence is *exactly* affine, with zero tropical curvature.

The vanishing of the tropical Cassini defect (Theorem 4.2) has a geometric interpretation: the tropical curve defined by the sequence {(n, t(n))} is a straight line. Outside the Ramanujan regime (2a > q), the curve develops "corners" where the minimum switches branches, introducing tropical curvature.

## 5. The Growth Dichotomy

### 5.1 The Boundary Case

Theorem 3.7 establishes the exact behavior at the boundary a² = 4q (with a = 2, q = 1):
h(n) = n + 1

This is polynomial growth of degree 1 in n — the sequence grows linearly.

### 5.2 Conjecture

**Conjecture 5.1** (Hecke Growth Dichotomy). For a, q ∈ ℤ with q > 0:
- If a² ≤ 4q, then |h(n)| ≤ (n+1) · q^(n/2) for all n ≥ 0.
- If a² > 4q, then |h(n)| grows exponentially: there exist constants C > 0 and λ > √q such that |h(n)| ≥ C · λ^n for all sufficiently large n.

The forward direction (Ramanujan bound) is known over ℂ via Chebyshev polynomials: when a² ≤ 4q, write a = 2√q · cos(θ), and then h(n) = q^(n/2) · sin((n+1)θ)/sin(θ), giving |h(n)| ≤ (n+1) · q^(n/2). A purely algebraic proof (over ℤ, without trigonometric substitution) remains an open challenge.

## 6. The Maslov Dequantization Bridge

### 6.1 Soft-Min Interpolation

The soft minimum softMin(t, x, y) = −t · log(exp(−x/t) + exp(−y/t)) has the properties:
- lim_{t→0⁺} softMin(t, x, y) = min(x, y)
- softMin(t, x, y) ≤ min(x, y) for all t > 0
- softMin(t, x, y) = min(x, y) − t · log(1 + exp(−|x−y|/t))

The Maslov-deformed Hecke recursion provides a continuous path from the tropical recursion (t → 0) to a "log-space" version of the classical recursion.

### 6.2 Connections to Statistical Mechanics

The soft-min function arises naturally in statistical mechanics as the free energy of a two-state system at temperature t. In this analogy, the tropical recursion is the zero-temperature (ground state) limit, and the classical recursion is the high-temperature limit. The Ramanujan regime corresponds to a phase where the system has a unique ground state (the a-branch dominates at every step), while the non-Ramanujan regime corresponds to a frustrated system with competing ground states.

## 7. Algorithms

### 7.1 Fast Hecke Sequence Computation

The companion matrix formulation enables O(log n) computation of h(n) via matrix exponentiation:

1. Compute M^(n+2) by repeated squaring: O(log n) matrix multiplications.
2. Read off h(n+2) from the (0,0) entry.
3. Each matrix multiplication costs O(1) ring operations (2×2 matrices).

**Total cost**: O(log n) ring operations for a single h(n).

### 7.2 Addition Formula for Batch Computation

The addition formula h(m+n+2) = h(m+1)·h(n+1) − q·h(m)·h(n) enables divide-and-conquer computation:
- To compute h(2n): use h(2n+2) = h(n+1)² − q·h(n)² (set m = n in the addition formula), then subtract from the known recursion.
- This gives an O(log n) algorithm using only ring operations.

## 8. Discussion

### 8.1 Generality

All results (Theorems 3.1–3.8) are proved over arbitrary commutative rings. This means they hold simultaneously for:
- ℤ: integer arithmetic, relevant for actual Hecke eigenvalues
- 𝔽_p: finite field arithmetic, relevant for mod-p Galois representations
- ℤ_p: p-adic integers, relevant for p-adic Langlands
- ℚ[X]: polynomial rings, giving universal polynomial identities
- Any commutative ring with a second-order recurrence

### 8.2 Relation to Chebyshev Polynomials

Over an algebraically closed field of characteristic 0, if a² ≠ 4q, then
h(n) = (α^(n+1) − β^(n+1))/(α − β) where α, β are the roots of X² − aX + q.

When a = 2√q · cos(θ), this becomes h(n) = q^(n/2) · U_n(cos θ) where U_n is the Chebyshev polynomial of the second kind. The Cassini-Hecke identity then follows from the identity U_n(x)² − U_{n+1}(x) · U_{n-1}(x) = 1 (after appropriate scaling).

Our algebraic proof bypasses this entirely, working directly with the recursion.

### 8.3 Limitations and Future Work

1. **Growth dichotomy**: The full conjecture (Section 5.2) remains open algebraically.
2. **Maslov convergence**: The convergence maslovHeckeSeq(t, ·) → tropHeckeSeq as t → 0 is formally stated but not yet proved.
3. **GL₃ generalization**: The third-order Hecke recursion for GL₃ should admit analogous identities.
4. **Arithmetic properties**: Divisibility patterns of h(n) modulo primes remain unexplored.

## References

1. Bump, D. *Automorphic Forms and Representations*. Cambridge University Press, 1997.
2. Cassini, G.D. (1680). Identity for Fibonacci numbers.
3. Deligne, P. "La conjecture de Weil. I." *Publ. Math. IHÉS* 43 (1974): 273–307.
4. Maslov, V.P. "On a new superposition principle for optimization problems." *Séminaire sur les Équations aux Dérivées Partielles*, 1985–1986.
5. Mikhalkin, G. "Enumerative tropical algebraic geometry in ℝ²." *J. Amer. Math. Soc.* 18 (2005): 313–377.
6. Ribenboim, P. "The Fibonacci numbers and the Arctic Ocean." In *Symposia Gaussiana*, 1999.
7. Shimura, G. *Introduction to the Arithmetic Theory of Automorphic Functions*. Princeton University Press, 1971.
8. Viro, O. "Dequantization of real algebraic geometry on logarithmic paper." In *European Congress of Mathematics*, 2001.
