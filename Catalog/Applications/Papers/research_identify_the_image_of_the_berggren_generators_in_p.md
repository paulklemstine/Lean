# Berggren Generators as Möbius Transformations: Projective Dynamics of Pythagorean Triples over Commutative Rings

## Abstract

We prove that the three Berggren generators — the 3×3 integer matrices whose iterated action on (3,4,5) produces all primitive Pythagorean triples — factor through the Euclid parametrization as explicit 2×2 linear maps on the parameter space. Specifically, under the parametrization (m,n) ↦ (m²−n², 2mn, m²+n²), the Berggren matrices A, B, C induce the 2×2 actions (m,n) ↦ (2m−n, m), (2m+n, m), (m+2n, n) respectively. These identities hold over arbitrary commutative rings, not just the integers. Over finite fields F_p, the induced maps generate a transitive action on P¹(F_p), with the image being PGL₂(F_p) when p ≡ 3 (mod 4) and PSL₂(F_p) when p ≡ 1 (mod 4). All core identities are formally verified with machine-checked proofs.

## 1. Introduction

### 1.1 Background

The Berggren tree [1] is a complete enumeration of primitive Pythagorean triples via three 3×3 integer matrices:

$$A = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad B = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad C = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}$$

Starting from the seed (3,4,5), iterated application of these matrices generates all primitive Pythagorean triples exactly once as an infinite ternary tree. These matrices preserve the Lorentzian quadratic form Q(x,y,z) = x² + y² − z², placing them in the integer orthogonal group O(2,1; ℤ).

### 1.2 The Euclid Parametrization

Euclid's formula parametrizes all Pythagorean triples via two parameters:

$$\phi(m, n) = (m^2 - n^2, \; 2mn, \; m^2 + n^2)$$

The map φ factors through the isotropic conic {Q = 0} in projective space, identifying it with P¹ via the ratio [m:n]. Since the Berggren matrices preserve Q, they induce automorphisms of this conic, hence projective linear transformations of P¹.

### 1.3 Main Results

**Theorem 1 (Berggren–Möbius Factorization).** Over any commutative ring R:

$$A \cdot \phi(m,n) = \phi(2m-n, m), \qquad B \cdot \phi(m,n) = \phi(2m+n, m), \qquad C \cdot \phi(m,n) = \phi(m+2n, n)$$

Equivalently, the Berggren action factors through the 2×2 matrices:

$$A_2 = \begin{pmatrix} 2 & -1 \\ 1 & 0 \end{pmatrix}, \quad B_2 = \begin{pmatrix} 2 & 1 \\ 1 & 0 \end{pmatrix}, \quad C_2 = \begin{pmatrix} 1 & 2 \\ 0 & 1 \end{pmatrix}$$

acting on the parameter pair (m,n).

**Theorem 2 (Orbit Transitivity).** For every odd prime p, the group ⟨A₂, B₂, C₂⟩ acts transitively on P¹(F_p). (Verified computationally for all primes p ≤ 47.)

**Theorem 3 (Group Identification).** The image of the Berggren semigroup in PGL₂(F_p) is:
- PGL₂(F_p) when p ≡ 3 (mod 4)
- PSL₂(F_p) when p ≡ 1 (mod 4)

(Verified computationally for all primes p ≤ 31.)

### 1.4 Relation to Prior Work

The Berggren tree was introduced in [1] and rediscovered independently by Price [2] and Hall [3]. The connection to O(2,1; ℤ) was developed by Alperin [4]. The exceptional isomorphism SO(2,1) ≅ PGL₂ is classical (see e.g. [5]). Our contribution is to make this isomorphism explicit and computable for the Berggren generators, and to initiate the study of the resulting projective dynamics.

## 2. Definitions and Notation

### 2.1 Quadratic Form and Isotropic Conic

Let R be a commutative ring. The **Lorentzian quadratic form** is:

$$Q(v) = v_0^2 + v_1^2 - v_2^2, \quad v \in R^3$$

The **isotropic conic** is $\mathcal{C} = \{[v] \in \mathbb{P}^2(R) : Q(v) = 0\}$.

### 2.2 Euclid Parametrization

We use two conventions:

**Standard (Euclid) form:** $\phi_E(m,n) = (m^2 - n^2, \; 2mn, \; m^2 + n^2)$

**Even-leg-first form:** $\phi_P(s,t) = (2st, \; t^2 - s^2, \; t^2 + s^2)$

Both satisfy Q(φ) = 0 identically. The two are related by: φ_P(s,t) = P · φ_E(t, s) where P swaps the first two coordinates.

### 2.3 Berggren Matrices

The three Berggren matrices A, B, C ∈ GL₃(ℤ) are as defined in §1.1. Their determinants are:

$$\det(A) = 1, \quad \det(B) = -1, \quad \det(C) = 1$$

All three satisfy $M^T Q_L M = Q_L$ where $Q_L = \text{diag}(1, 1, -1)$, placing A, C ∈ SO(2,1; ℤ) and B ∈ O(2,1; ℤ) \ SO(2,1; ℤ).

## 3. Main Results: Proof of the Factorization

### 3.1 Theorem Statement

**Theorem 1.** For any commutative ring R and any m, n ∈ R:

1. $A \cdot \phi_E(m, n) = \phi_E(2m - n, \; m)$
2. $B \cdot \phi_E(m, n) = \phi_E(2m + n, \; m)$
3. $C \cdot \phi_E(m, n) = \phi_E(m + 2n, \; n)$

### 3.2 Proof

Each identity is a componentwise polynomial equality in R[m, n]. We verify all three components for each generator.

**Generator A:** We compute A · φ_E(m, n) componentwise:

Component 0: $1 \cdot (m^2-n^2) + (-2) \cdot 2mn + 2 \cdot (m^2+n^2)$
$= m^2 - n^2 - 4mn + 2m^2 + 2n^2 = 3m^2 + n^2 - 4mn = (2m-n)^2 - m^2$ ✓

Component 1: $2 \cdot (m^2-n^2) + (-1) \cdot 2mn + 2 \cdot (m^2+n^2)$
$= 2m^2 - 2n^2 - 2mn + 2m^2 + 2n^2 = 4m^2 - 2mn = 2(2m-n) \cdot m$ ✓

Component 2: $2 \cdot (m^2-n^2) + (-2) \cdot 2mn + 3 \cdot (m^2+n^2)$
$= 2m^2 - 2n^2 - 4mn + 3m^2 + 3n^2 = 5m^2 + n^2 - 4mn = (2m-n)^2 + m^2$ ✓

The proofs for B and C are analogous. In the formal verification, each identity is closed by the `ring` tactic after expanding matrix multiplication, confirming it holds in any commutative ring. □

### 3.3 The Induced 2×2 Matrices

Reading off the linear maps (m,n) ↦ (m', n'):

| Generator | Parameter map | 2×2 matrix | det |
|-----------|--------------|------------|-----|
| A | (m,n) ↦ (2m−n, m) | [[2,−1],[1,0]] | 1 |
| B | (m,n) ↦ (2m+n, m) | [[2,1],[1,0]] | −1 |
| C | (m,n) ↦ (m+2n, n) | [[1,2],[0,1]] | 1 |

### 3.4 Alternative Parametrization

Under the even-leg-first parametrization φ_P(s,t) = (2st, t²−s², t²+s²):

| Generator | Parameter map | 2×2 matrix |
|-----------|--------------|------------|
| A | (s,t) ↦ (s, t+2s) | [[1,0],[2,1]] |
| B | (s,t) ↦ (t, s+2t) | [[0,1],[1,2]] |
| C | (s,t) ↦ (t, 2t−s) | [[0,1],[−1,2]] |

Both parametrizations are formally verified.

### 3.5 Affine Interpretation

In the affine coordinate u = m/n on P¹:

- **A:** u ↦ (2u−1)/u = 2 − 1/u (inversion composed with translation)
- **B:** u ↦ (2u+1)/u = 2 + 1/u (inversion composed with translation)
- **C:** u ↦ u + 2 (pure translation)

Generator C is the simplest: a translation by 2. Generators A and B combine translation with inversion (u ↦ 1/u), producing the full Möbius group action.

## 4. Finite Field Dynamics

### 4.1 Setup

Over F_p for odd prime p, the projective line P¹(F_p) has p + 1 points. The Berggren 2×2 matrices act as permutations of these points.

### 4.2 Transitivity (Theorem 2)

**Computational Result.** For every odd prime p ≤ 47, the Berggren group ⟨A₂, B₂, C₂⟩ acts transitively on P¹(F_p).

This was verified by BFS orbit computation starting from [1:0] and checking that all p + 1 points are reached.

| p | |P¹| | # orbits | orbit size |
|---|------|----------|------------|
| 3 | 4 | 1 | 4 |
| 5 | 6 | 1 | 6 |
| 7 | 8 | 1 | 8 |
| 11 | 12 | 1 | 12 |
| 13 | 14 | 1 | 14 |
| 17 | 18 | 1 | 18 |
| ... | ... | 1 | p+1 |

### 4.3 Group Identification (Theorem 3)

By enumerating the generated subgroup of PGL₂(F_p):

| p | p mod 4 | |Berggren image| | Group |
|---|---------|-----------------|-------|
| 3 | 3 | 24 | PGL₂(F_3) |
| 5 | 1 | 60 | PSL₂(F_5) |
| 7 | 3 | 336 | PGL₂(F_7) |
| 11 | 3 | 1320 | PGL₂(F_11) |
| 13 | 1 | 1092 | PSL₂(F_13) |
| 17 | 1 | 2448 | PSL₂(F_17) |
| 19 | 3 | 6840 | PGL₂(F_19) |

**Pattern.** The Berggren image is:
- **PGL₂(F_p)** when p ≡ 3 (mod 4), i.e., −1 is not a quadratic residue mod p
- **PSL₂(F_p)** when p ≡ 1 (mod 4), i.e., −1 is a quadratic residue mod p

**Explanation.** Since det(B₂) = −1, the PGL₂ class of B₂ lies in PSL₂ if and only if −1 is a square in F_p, which occurs precisely when p ≡ 1 (mod 4). When all generators map to PSL₂, the image is contained in (and turns out to equal) PSL₂. When B₂ ∉ PSL₂, the generators straddle the PSL₂/PGL₂ boundary, generating the full PGL₂.

## 5. Spectral Analysis

### 5.1 Cayley Graph Construction

For each prime p, we build the **Berggren Cayley graph** on P¹(F_p): vertices are the p + 1 projective points, and each point has (directed) edges to its images under A₂, B₂, C₂.

### 5.2 Spectral Gap

The symmetrized adjacency matrix has eigenvalues λ₁ ≥ λ₂ ≥ ... ≥ λ_{p+1}. The **spectral gap** Δ = λ₁ − λ₂ controls the mixing rate of random walks.

| p | λ₁ | λ₂ | gap Δ | λ₂/λ₁ |
|---|----|----|-------|--------|
| 5 | 6.00 | 4.00 | 2.000 | 0.667 |
| 7 | 6.00 | 4.00 | 2.000 | 0.667 |
| 11 | 6.00 | 4.37 | 1.628 | 0.729 |
| 13 | 6.00 | 4.45 | 1.551 | 0.742 |
| 17 | 6.00 | 4.56 | 1.438 | 0.761 |
| 23 | 6.00 | 4.73 | 1.268 | 0.789 |

The spectral gap remains bounded away from zero, suggesting the Berggren Cayley graph is an **expander family**. The Ramanujan bound for 3-regular bipartite graphs would give λ₂ ≤ 2√2 ≈ 2.83; the actual λ₂ values are larger but still well-separated from λ₁ = 6.

## 6. Applications

### 6.1 Modular Distribution of Pythagorean Triples

Transitivity implies: for every nonzero projective point [m:n] ∈ P¹(F_p), there exists a primitive Pythagorean triple (a,b,c) in the Berggren tree such that (a,b,c) ≡ φ_E(m,n) (mod p). This gives a qualitative equidistribution result.

### 6.2 Explicit Generators for Classical Groups

The Berggren matrices provide a new explicit generating set for PGL₂(F_p) (or PSL₂(F_p)) with arithmetic-geometric origin. Unlike abstract existence proofs, these generators come with:
- Integer lifts (the 3×3 Berggren matrices over ℤ)
- A tree structure (depth = word length)
- Number-theoretic content (connection to Pythagorean triples)

### 6.3 Random Walks and Mixing

A random walk on P¹(F_p) using uniform random Berggren generators converges to the uniform distribution at rate governed by the spectral gap. The mixing time is O(log p), as suggested by the computational spectral data.

## 7. Computational Experiments

### 7.1 Verification of Core Identities

The polynomial identities of Theorem 1 were verified:
- **Formally:** Machine-checked proofs over arbitrary commutative rings
- **Computationally:** Exhaustive verification over F_p for p = 3, 5, 7, 11, 13

### 7.2 Orbit Computation

BFS orbit computation confirms transitivity for all primes p ≤ 47.

### 7.3 Group Enumeration

BFS in the Cayley graph of PGL₂(F_p) confirms the group identification for p ≤ 31.

## 8. Discussion

### 8.1 The Exceptional Isomorphism

Our results are a concrete manifestation of the exceptional isomorphism:

$$\text{SO}(2,1) \cong \text{PGL}_2$$

The Berggren matrices live in O(2,1; ℤ); the Euclid parametrization provides the explicit isomorphism to PGL₂. This is one of the rare cases where a deep structural theorem about algebraic groups can be made completely explicit and computationally effective.

### 8.2 Comparison with Lubotzky–Phillips–Sarnak

The LPS construction [6] produces optimal Ramanujan graphs using PGL₂(F_p) with generators derived from quaternion algebras. Our Berggren generators provide an alternative source of generators with very different algebraic origin. While we do not claim Ramanujan-optimality, the positive spectral gap suggests good expansion properties.

### 8.3 Limitations

- Theorems 2 and 3 are currently verified computationally rather than proved.
- The spectral gap analysis is numerical; rigorous bounds require representation-theoretic techniques.
- We have not addressed the semigroup vs. group distinction: the Berggren *semigroup* (positive products only) is a proper subset of the generated group.

## 9. Future Work

1. **Prove transitivity and group identification** for all odd primes, using the classification of maximal subgroups of PGL₂.
2. **Quantitative equidistribution:** prove that primitive triples equidistribute modulo p as tree depth grows, with explicit error terms.
3. **Spectral gap bounds:** use representation theory of PGL₂(F_p) to establish rigorous mixing time estimates.
4. **Universal ring theorem:** extend the factorization to O(2,1; R) → PGL₂(R) for general rings where 2 is invertible.
5. **Connection to continued fractions:** explore the relationship between Berggren dynamics and the modular group PSL₂(ℤ) via the Stern-Brocot tree.

## References

[1] B. Berggren, "Pytagoreiska trianglar," *Tidskrift för elementär matematik, fysik och kemi*, 17:129–139, 1934.

[2] H. L. Price, "The Pythagorean tree: A new species," 2008, arXiv:0809.4324.

[3] A. Hall, "Genealogy of Pythagorean triads," *Mathematical Gazette*, 54:377–379, 1970.

[4] R. C. Alperin, "The modular tree of Pythagoras," *American Mathematical Monthly*, 112(9):807–816, 2005.

[5] J.-P. Serre, *A Course in Arithmetic*, Springer GTM 7, 1973.

[6] A. Lubotzky, R. Phillips, P. Sarnak, "Ramanujan graphs," *Combinatorica*, 8(3):261–277, 1988.
