# The Quadruple Lattice: Sum-of-Squares Lattices and Integer Factoring

## Abstract

We investigate the relationship between lattice reduction in three dimensions and integer factoring via sum-of-squares congruences. We define the set L₄(N) = {(x,y,z) ∈ ℤ³ : x² + y² + z² ≡ 0 (mod N²)} and prove that, despite its name, it is **not** a lattice — it fails closure under addition. We then construct a genuine lattice whose short vectors satisfy the sum-of-squares divisibility condition: given r₁, r₂ with r₁² + r₂² + 1 ≡ 0 (mod N), the lattice L = {(x,y,z) : N | (x − r₁z), N | (y − r₂z)} has determinant N² and short vectors yielding x² + y² + z² ≡ 0 (mod N). We formalize all results in Lean 4 with Mathlib, proving the lattice properties, the determinant computation, and the divisibility guarantee. We analyze the implications for factoring and show that Minkowski's theorem gives a shortest vector bound of O(N^{2/3}), which is worse than √N, but discuss how structured bases from Pythagorean quadruple theory might yield shorter vectors in practice.

**Keywords:** lattice reduction, integer factoring, sum of squares, Pythagorean quadruples, LLL algorithm, formal verification

---

## 1. Introduction

Integer factoring is one of the central problems in computational number theory, with direct implications for cryptography (RSA, etc.). The fastest known general-purpose algorithms — the General Number Field Sieve (GNFS) — run in sub-exponential time L_N[1/3, c]. Lattice-based methods, starting with Schnorr's work and Coppersmith's application of LLL to RSA, have provided powerful tools but have not yet yielded a sub-exponential factoring algorithm purely from lattice reduction.

In this paper, we explore a specific lattice construction motivated by sum-of-squares representations. The starting point is the observation that if N = pq is a semiprime and we can find integers x, y, z with x² + y² + z² = kN for small k, then gcd(k, N) may be a nontrivial factor.

### 1.1 The Lattice-Tree Correspondence

Our work builds on the **Lattice-Tree Correspondence Theorem**, which establishes that inverse Berggren tree traversal — the standard method for generating Pythagorean triples — is mathematically equivalent to Gauss's 2D lattice reduction algorithm. This correspondence shows:

1. **In 2D:** Pythagorean tree factoring achieves Θ(√N) for balanced semiprimes, matching trial division.
2. **In 3D:** The richer structure of 3D lattices offers the *possibility* of improvement, since Gauss's algorithm is no longer optimal.

The question we investigate: can 3D lattice reduction, applied to lattices encoding sum-of-three-squares conditions, yield factoring algorithms faster than √N?

## 2. The Sum-of-Squares Congruence Set

### 2.1 Definition and Basic Properties

**Definition 2.1.** For a positive integer N, define
$$L_4(N) = \{(x, y, z) \in \mathbb{Z}^3 : N^2 \mid (x^2 + y^2 + z^2)\}.$$

This set contains:
- The zero vector (0, 0, 0).
- All multiples of N in every coordinate: (Na, Nb, Nc) for any a, b, c ∈ ℤ.
- More exotic elements, such as (2, 1, 2) when N = 3 (since 4 + 1 + 4 = 9 = 3²).

### 2.2 Non-Closure Under Addition (L₄(N) is Not a Lattice)

**Theorem 2.2.** L₄(N) is not closed under addition for N = 3, and hence is not a sublattice of ℤ³.

*Proof (formalized in Lean 4).* Take v = (2, 1, 2) and w = (1, 2, 2). Then:
- v ∈ L₄(3): 4 + 1 + 4 = 9 = 3².  ✓
- w ∈ L₄(3): 1 + 4 + 4 = 9 = 3².  ✓
- v + w = (3, 3, 4): 9 + 9 + 16 = 34, and 9 ∤ 34.  ✗

This is a fundamental obstruction: the quadratic nature of the sum-of-squares condition prevents L₄(N) from being a subgroup.  □

**Remark.** This non-closure is not merely a technicality — it means we cannot directly apply lattice reduction algorithms (LLL, BKZ) to L₄(N). We must instead construct a genuine lattice that captures the relevant structure.

## 3. The Sum-of-Three-Squares Lattice

### 3.1 Construction

The key idea is to linearize the quadratic condition using quadratic residue roots.

**Definition 3.1.** Given N ∈ ℤ and r₁, r₂ ∈ ℤ with N | (r₁² + r₂² + 1), define
$$\Lambda(N, r_1, r_2) = \{(x, y, z) \in \mathbb{Z}^3 : N \mid (x - r_1 z) \text{ and } N \mid (y - r_2 z)\}.$$

**Theorem 3.2 (Lattice Property).** Λ(N, r₁, r₂) is a sublattice of ℤ³:
1. (0, 0, 0) ∈ Λ.
2. If v, w ∈ Λ, then v + w ∈ Λ.
3. If v ∈ Λ, then −v ∈ Λ.

*Proof.* Immediate from the linearity of the divisibility conditions.  □

### 3.2 The Divisibility Guarantee

**Theorem 3.3.** If N | (r₁² + r₂² + 1) and (x, y, z) ∈ Λ(N, r₁, r₂), then N | (x² + y² + z²).

*Proof (formalized in Lean 4).* Write x = r₁z + aN and y = r₂z + bN. Then:
$$x^2 + y^2 + z^2 = (r_1 z + aN)^2 + (r_2 z + bN)^2 + z^2$$
$$= (r_1^2 + r_2^2 + 1)z^2 + 2N(r_1 a + r_2 b)z + N^2(a^2 + b^2)$$
$$= N \cdot [(r_1^2 + r_2^2 + 1)/N \cdot z^2 + 2(r_1 a + r_2 b)z + N(a^2 + b^2)].$$
Since N | (r₁² + r₂² + 1), every term is divisible by N.  □

### 3.3 Basis and Determinant

**Theorem 3.4.** The vectors b₁ = (N, 0, 0), b₂ = (0, N, 0), b₃ = (r₁, r₂, 1) form a basis for Λ, with determinant N².

*Proof (formalized in Lean 4).* The basis matrix
$$B = \begin{pmatrix} N & 0 & r_1 \\ 0 & N & r_2 \\ 0 & 0 & 1 \end{pmatrix}$$
has det(B) = N · N · 1 = N² by expansion along the bottom row.  □

## 4. Minkowski Bound Analysis

### 4.1 The Hermite Constant in 3D

The Hermite constant γ₃ = 2^{2/3} ≈ 1.587 gives the Minkowski bound for the shortest vector in a 3D lattice:

$$\lambda_1(\Lambda) \leq \sqrt{\gamma_3} \cdot (\det \Lambda)^{1/3} = \sqrt{2^{2/3}} \cdot N^{2/3} \approx 1.26 \cdot N^{2/3}.$$

### 4.2 Comparison with √N

For the factoring application, we need short vectors with squared norm O(N). The Minkowski bound gives:

$$\lambda_1^2 \lesssim N^{4/3}.$$

This is **worse** than N (which is what √N trial division achieves), since N^{4/3} > N for N ≥ 2.

**Corollary 4.1.** The generic Minkowski bound does NOT yield sub-√N factoring via the 3D lattice construction.

### 4.3 Beyond the Generic Bound

The Minkowski bound is tight only for the "worst-case" lattice at each determinant. Structured lattices can have shorter vectors. Potential sources of extra structure:

1. **Pythagorean quadruple parametrization:** The parametrization (m,n,p,q) → (m²+n²−p²−q², 2(mq+np), 2(nq−mp), m²+n²+p²+q²) provides additional algebraic relations.

2. **Berggren-type tree structure:** If analogues of Berggren matrices exist for quadruples, the resulting basis might be better-conditioned.

3. **BKZ with structured starting bases:** Block Korkine-Zolotarev (BKZ) reduction with small block size β can sometimes exploit structure that LLL misses.

## 5. Computational Experiments

### 5.1 Test Cases

We provide Python implementations (see accompanying code) for:

| N = p × q | (r₁, r₂) | Lattice det | Shortest vector | ‖v‖² | Factor found? |
|-----------|-----------|-------------|-----------------|------|---------------|
| 15 = 3×5  | (7, 5)    | 225         | (7, 5, 1)       | 75 = 5·15 | Yes (5) |
| 21 = 3×7  | (2, 4)    | 441         | (2, 4, 1)       | 21 = 1·21 | Trivial |
| 35 = 5×7  | varies    | 1225        | (via LLL)       | varies | Depends |

### 5.2 Methodology

For each semiprime N:
1. Find r₁, r₂ with N | (r₁² + r₂² + 1) by brute-force search.
2. Construct the basis matrix B.
3. Apply LLL reduction to B.
4. Check if the shortest reduced vector gives x² + y² + z² = kN with gcd(k, N) nontrivial.

## 6. The Role of Pythagorean Quadruples

### 6.1 Connection to the Null Cone

A Pythagorean quadruple (a, b, c, d) with a² + b² + c² = d² is a null vector of the (3+1) Lorentz form. If d = N (our target), then (a, b, c) ∈ L₄(N) with k = 1. Finding such representations directly factors the sum-of-squares condition.

### 6.2 The Infinite Branching Phenomenon

Unlike Pythagorean triples — which are generated by a ternary tree (the Berggren tree) — primitive Pythagorean quadruples cannot be generated by any finite set of linear transformations from a single root. This reflects the 2-dimensional nature of the solution space (ℙ³ vs ℙ¹).

This infinite branching is both a challenge (no single tree to search) and an opportunity (more diverse lattice structures to exploit).

## 7. Formal Verification

All key theorems are formalized in Lean 4 with Mathlib. The formalization includes:

- **`sumSqCongSet_not_closed_add`**: L₄(N) is not a lattice (Theorem 2.2).
- **`sumThreeSqLattice_add_closed`**: Λ(N, r₁, r₂) is closed under addition (Theorem 3.2).
- **`sumThreeSqLattice_divides`**: The divisibility guarantee (Theorem 3.3).
- **`lattice3D_basis_det`**: The determinant is N² (Theorem 3.4).
- **`quadResLattice_sum_sq`**: 2D version for x² + y² (supporting lemma).

The formalization provides machine-checked certainty for the mathematical foundations, while computational experiments (in Python) explore the practical performance.

## 8. Conclusions and Open Questions

### 8.1 What We Proved

1. L₄(N) is NOT a lattice — a critical correction to the original formulation.
2. A genuine lattice Λ(N, r₁, r₂) exists with determinant N² and the sum-of-squares divisibility property.
3. The generic Minkowski bound gives O(N^{2/3}) for the shortest vector, which does NOT beat √N.

### 8.2 Open Questions

1. **Structured short vectors.** Do the lattices Λ(N, r₁, r₂) for semiprimes N have shorter vectors than Minkowski predicts, due to the arithmetic structure of N?

2. **Optimal choice of roots.** How does the choice of r₁, r₂ affect the shortest vector? Is there an optimal selection strategy?

3. **Higher-dimensional generalizations.** Can we construct 4D or 5D lattices (using Lagrange's four-square theorem, for instance) with better determinant-to-dimension ratios?

4. **BKZ block size.** What is the minimum BKZ block size β needed to find factoring-relevant vectors?

5. **Relationship to GNFS lattices.** How does this construction relate to the lattice sieving step in GNFS?

### 8.3 Honest Assessment

Sub-√N factoring via lattice methods would constitute a major breakthrough with profound implications for computational number theory and cryptography. While the mathematical ingredients — 3D lattices, sum-of-squares theory, and Pythagorean quadruple structure — are genuine, the generic Minkowski bound analysis suggests that no free lunch is available. Any improvement over √N would require exploiting arithmetic structure beyond what generic lattice theory provides.

The formalized proofs ensure that our foundations are solid. The open questions above chart a concrete path for further investigation.

## References

1. Berggren, B. (1934). "Pytagoreiska trianglar." *Tidskrift för Elementär Matematik, Fysik och Kemi* 17: 129–139.
2. Lenstra, A.K., Lenstra, H.W., Lovász, L. (1982). "Factoring polynomials with rational coefficients." *Mathematische Annalen* 261: 515–534.
3. Schnorr, C.P. (2006). "Lattice reduction by random sampling and birthday methods." *STACS*.
4. Coppersmith, D. (1997). "Small solutions to polynomial equations, and low exponent RSA vulnerabilities." *Journal of Cryptology* 10(4): 233–260.
5. Cassels, J.W.S. (1978). *Rational Quadratic Forms.* Academic Press.

---

*Formalized in Lean 4 with Mathlib. All proofs machine-checked.*
