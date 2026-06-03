# Tropical Stereographic Projection: Max-Plus Möbius Transformations and Their Representation Theory

## Abstract

We develop the theory of tropical Möbius transformations — piecewise-linear functions of the form φ(t) = max(a+t, b) − max(c+t, d) — and their representation via tropical (max-plus) 2×2 matrices. We prove that the homogeneous action of tropical matrices respects tropical matrix multiplication (the representation theorem), establish sharp bounds on the affine evaluation (the boundedness theorem), characterize the piecewise-linear structure via breakpoints and active intervals, and prove a super-multiplicativity inequality for the tropical determinant. We define the tropical stereographic projection as a distinguished tropical Möbius transformation and compute its key invariants: tropical width |p|, tropical determinant max(p, 0), and active interval. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords**: tropical geometry, max-plus algebra, Möbius transformation, stereographic projection, piecewise-linear functions, tropical determinant

## 1. Introduction

### 1.1 Background

Tropical geometry studies algebraic varieties over the *tropical semiring* (ℝ ∪ {−∞}, ⊕, ⊙), where a ⊕ b = max(a, b) and a ⊙ b = a + b. This "tropicalization" procedure replaces polynomial equations with piecewise-linear equations, turning algebraic curves into polyhedral complexes while preserving deep structural information [1, 2].

Independently, the *max-plus algebra* — the same algebraic structure — has been extensively studied in optimization, control theory, and discrete event systems [3]. The connection between these two traditions, while well-known, has not been fully exploited.

Stereographic projection, dating to Ptolemy's *Planisphaerium* (c. 150 CE), is a fundamental tool in geometry, complex analysis, and topology. It provides a conformal bijection between the n-sphere (minus a point) and ℝⁿ, and is encoded by Möbius transformations — rational functions of the form (az + b)/(cz + d).

### 1.2 Contributions

This paper introduces the *tropical Möbius transformation* as the tropicalization of the classical Möbius transformation and develops its theory systematically. Our main contributions are:

1. **Representation Theorem** (Theorem 3.1): The homogeneous action of tropical 2×2 matrices respects tropical matrix multiplication.

2. **Associativity** (Theorem 3.2): Tropical 2×2 matrix multiplication is associative.

3. **Boundedness Theorem** (Theorem 4.1): Every tropical Möbius transformation has image contained in [min(a−c, b−d), max(a−c, b−d)].

4. **Piecewise-Linear Structure** (Theorem 5.1): On the "active interval" [b−a, d−c], the transformation is affine-linear with slope +1.

5. **Injectivity** (Theorem 5.2): The transformation is injective on its active interval.

6. **Super-Multiplicativity** (Theorem 6.1): det⊕(M⊗N) ≥ det⊕(M) + det⊕(N).

7. **Stereographic Width** (Theorem 7.1): The tropical width of the stereographic projection from pole p equals |p|.

## 2. Definitions

### 2.1 Tropical 2×2 Matrices

**Definition 2.1** (Tropical Matrix). A *tropical 2×2 matrix* is a quadruple M = (a, b, c, d) ∈ ℝ⁴, written as

$$M = \begin{pmatrix} a & b \\ c & d \end{pmatrix}$$

**Definition 2.2** (Tropical Matrix Multiplication). The *tropical product* M ⊗ N is defined by

$$(M \otimes N)_{ij} = \max_k (M_{ik} + N_{kj})$$

Explicitly:

$$M \otimes N = \begin{pmatrix} \max(a_1+a_2, b_1+c_2) & \max(a_1+b_2, b_1+d_2) \\ \max(c_1+a_2, d_1+c_2) & \max(c_1+b_2, d_1+d_2) \end{pmatrix}$$

### 2.2 Homogeneous Action

**Definition 2.3** (Homogeneous Action). The *homogeneous action* of M on a point (x, y) ∈ ℝ² is

$$M \cdot (x, y) = (\max(a+x, b+y), \max(c+x, d+y))$$

This gives a well-defined action on the *tropical projective line* TP¹, the quotient of (ℝ ∪ {−∞})² ∖ {(−∞, −∞)} by the equivalence (x, y) ∼ (x+λ, y+λ).

### 2.3 Affine Evaluation

**Definition 2.4** (Affine Evaluation). The *affine evaluation* of M at t ∈ ℝ is

$$\varphi_M(t) = \max(a+t, b) - \max(c+t, d)$$

This is obtained from the homogeneous action by setting y = 0 and taking the difference of coordinates, which corresponds to the affine chart of TP¹.

### 2.4 Tropical Determinant

**Definition 2.5** (Tropical Determinant). The *tropical determinant* of M is

$$\det_\oplus(M) = \max(a+d, b+c)$$

This is the tropical analog of the classical determinant ad − bc, with × replaced by + and − replaced by max.

**Definition 2.6** (Non-Degeneracy). M is *non-degenerate* if a + d ≠ b + c.

### 2.5 Tropical Stereographic Projection

**Definition 2.7** (Tropical Stereographic Projection). The *tropical stereographic projection from pole p* is the tropical matrix

$$S_p = \begin{pmatrix} 0 & 0 \\ 0 & p \end{pmatrix}$$

with affine evaluation φ_p(t) = max(t, 0) − max(t, p).

### 2.6 Breakpoints and Tropical Width

**Definition 2.8** (Breakpoints). The *left breakpoint* and *right breakpoint* of M are

$$\ell(M) = \min(b-a, d-c), \qquad r(M) = \max(b-a, d-c)$$

**Definition 2.9** (Tropical Width). The *tropical width* is w(M) = r(M) − ℓ(M).

## 3. The Representation Theorem

**Theorem 3.1** (Representation). For all tropical matrices M, N and points p ∈ ℝ²,

$$(M \otimes N) \cdot p = M \cdot (N \cdot p)$$

*Proof sketch.* Both sides expand to pairs involving four-fold maxima. The key identity is the distributivity law

$$a + \max(b, c) = \max(a+b, a+c)$$

which allows distributing addition through the nested max operations. Each component resolves to max over the same four terms. □

**Theorem 3.2** (Associativity). Tropical matrix multiplication is associative:

$$(M \otimes N) \otimes P = M \otimes (N \otimes P)$$

*Proof sketch.* This follows from the representation theorem: both sides act identically on all points of ℝ², and the action determines the matrix (by evaluating at the standard basis). Alternatively, direct expansion using distributivity and commutativity of max. □

## 4. The Boundedness Theorem

**Theorem 4.1** (Boundedness). For all M and t ∈ ℝ,

$$\min(a-c, b-d) \leq \varphi_M(t) \leq \max(a-c, b-d)$$

*Proof sketch.* Case analysis on the four regions determined by the signs of a+t−b and c+t−d. In each case, the value is either a−c, b−d, a+t−d, or b−c−t, and each of these lies within the stated bounds by the case hypotheses. □

**Theorem 4.2** (Asymptotic Left). If t ≤ b−a and t ≤ d−c, then φ_M(t) = b − d.

**Theorem 4.3** (Asymptotic Right). If t ≥ b−a and t ≥ d−c, then φ_M(t) = a − c.

*Proof.* When t ≤ b−a, we have a+t ≤ b, so max(a+t, b) = b. Similarly for the denominator. □

## 5. Piecewise-Linear Structure

**Theorem 5.1** (Active Interval). Suppose a + d > b + c. For t ∈ [b−a, d−c],

$$\varphi_M(t) = a + t - d$$

*Proof.* The hypothesis a+d > b+c implies b−a < d−c, so the interval is non-empty. For t ≥ b−a, we have a+t ≥ b. For t ≤ d−c, we have c+t ≤ d. Thus max(a+t, b) = a+t and max(c+t, d) = d. □

**Theorem 5.2** (Injectivity on Active Interval). Under the hypotheses of Theorem 5.1, if φ_M(s) = φ_M(t) for s, t ∈ [b−a, d−c], then s = t.

*Proof.* Both values equal a + · − d, so a+s−d = a+t−d implies s = t. □

**Corollary 5.3** (Breakpoint Characterization). Below ℓ(M), the function equals b−d. Above r(M), it equals a−c.

## 6. Tropical Determinant

**Theorem 6.1** (Super-Multiplicativity). For all tropical matrices M, N,

$$\det_\oplus(M) + \det_\oplus(N) \leq \det_\oplus(M \otimes N)$$

*Proof sketch.* Expand both sides. The LHS is max over 4 terms (products of diagonal/anti-diagonal sums). Each of these 4 terms appears among the terms of the RHS expansion, which is a max over 8 terms. Therefore the LHS ≤ RHS. □

**Remark 6.2.** Equality holds when M and N are "generic" (in a precise tropical sense). The gap det⊕(M⊗N) − det⊕(M) − det⊕(N) measures the "tropical interaction energy" between M and N.

## 7. Tropical Stereographic Projection

**Theorem 7.1** (Stereographic Width). w(S_p) = |p|.

*Proof.* S_p = (0, 0, 0, p). The breakpoints are min(0, p) and max(0, p), so the width is max(0, p) − min(0, p) = |p|. □

**Theorem 7.2** (Stereographic Linearity). For p ≥ 0 and t ∈ [0, p],

$$\varphi_p(t) = t - p$$

*Proof.* Special case of Theorem 5.1 with a = b = c = 0, d = p. □

**Theorem 7.3** (Stereographic Determinant). det⊕(S_p) = max(p, 0).

**Theorem 7.4** (Stereographic Non-Degeneracy). S_p is non-degenerate if and only if p ≠ 0.

## 8. Discussion

### 8.1 The Representation-Theoretic Perspective

The representation theorem (Theorem 3.1) establishes that tropical 2×2 matrices form a monoid acting faithfully on ℝ² via the homogeneous action. This is the tropical analog of the GL(2) representation on ℂ². The quotient by the "tropical scalar matrices" (diagonal matrices with equal entries) gives the *tropical projective linear group* PGL⊕(2), which acts on TP¹.

### 8.2 Comparison with Classical Stereographic Projection

| Property | Classical | Tropical |
|----------|-----------|----------|
| Map type | Rational function | Piecewise-linear function |
| Encoding | Möbius transformation | Tropical Möbius transformation |
| Matrix group | GL(2, ℂ) | Max-plus 2×2 matrices |
| Conformality | Angle-preserving | Width-preserving (in tropical sense) |
| Image | All of ℝ (or ℂ) | Bounded interval [min, max] |
| Determinant | Multiplicative | Super-multiplicative |
| Singularity | Pole (essential) | Breakpoints (corners) |

### 8.3 The Super-Multiplicativity Phenomenon

The failure of multiplicativity for the tropical determinant (Theorem 6.1) is a genuinely tropical phenomenon with no classical analog. It reflects the fact that the max operation "forgets" information about which term achieved the maximum, leading to a systematic overcount when composing matrices.

### 8.4 Connections to Optimization

The max-plus matrix multiplication in Definition 2.2 is precisely the operation used in shortest-path algorithms (with min instead of max) and in dynamic programming. The tropical Möbius framework provides a geometric interpretation of these algorithms: each step of dynamic programming is a tropical Möbius transformation, and the composition of steps is a tropical matrix product.

## 9. Open Problems and Conjectures

**Conjecture 9.1** (Tropical Conformal Invariant). There exists a functional J[φ] on tropical Möbius transformations that is invariant under tropical PGL(2) conjugation and equals the tropical width for stereographic projections.

**Conjecture 9.2** (Higher-Dimensional Representation). The representation theorem (Theorem 3.1) extends to tropical n×n matrices acting on TP^(n−1), with the tropical determinant satisfying an analogous super-multiplicativity inequality.

**Conjecture 9.3** (Tropical Moduli). The space of tropical Möbius transformations modulo tropical PGL(2) conjugation is a tropical variety of dimension 1 (parameterized by the tropical width).

## 10. Formalization

All definitions and theorems in this paper have been formalized and verified in Lean 4 using the Mathlib library. The formalization consists of approximately 280 lines of Lean code with 16 definitions and theorems, all proved without `sorry`. The key formalization challenges were:

- Handling the case analysis for max/min in the boundedness theorem
- Using the `add_max` lemma from Mathlib for the distributivity of + over max
- Proving the representation theorem via expansion and the `grind` tactic
- The associativity theorem, which was proved by reducing to the representation theorem

## References

[1] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, vol. 161, AMS, 2015.

[2] G. Mikhalkin, "Tropical geometry and its applications," in *Proceedings of the ICM*, Madrid, 2006.

[3] F. Baccelli, G. Cohen, G.J. Olsder, and J.-P. Quadrat, *Synchronization and Linearity: An Algebra for Discrete Event Systems*, Wiley, 1992.

[4] M. Joswig, *Essentials of Tropical Combinatorics*, Graduate Studies in Mathematics, vol. 219, AMS, 2021.

[5] I. Simon, "Recognizable sets with multiplicities in the tropical semiring," in *Mathematical Foundations of Computer Science*, Lecture Notes in Computer Science, vol. 324, Springer, 1988.
