# Edge Universality for Random Matrix Ensembles: Formal Foundations

## Abstract

We present a rigorous formalization of the structural foundations underlying edge universality in random matrix theory. We define the Catalan number recurrence, the Wigner semicircle density, the Airy kernel, and the Tracy-Widom edge scaling function, and prove 19 theorems establishing their fundamental properties. Key results include: (1) the Catalan numbers are strictly positive and bounded by 4^n, with the bound proved via identification with Mathlib's `catalan` function and the central binomial coefficient; (2) the semicircle density is non-negative, symmetric, supported on [-1,1], and vanishes at the edge; (3) the matrix trace of A² for symmetric matrices equals the Frobenius norm squared and is non-negative; (4) Tracy-Widom scaling is strictly monotone and correctly centered at the semicircle edge; (5) the Tracy-Widom tail bound is positive and at most 1. All proofs are machine-verified with no remaining sorry statements.

## 1. Introduction

Random matrix theory studies the statistical properties of eigenvalues of large matrices with random entries. The *edge universality* phenomenon — that the largest eigenvalue of a Wigner matrix, properly rescaled, converges to the Tracy-Widom distribution regardless of the entry distribution — is one of the deepest results in modern probability theory.

The original proofs of edge universality for Gaussian ensembles (GUE/GOE) rely on exact formulas involving orthogonal polynomials and the Airy function. Extension to non-Gaussian ensembles, achieved by Soshnikov (2002) for symmetric distributions and by Tao-Vu (2010-2012) and Erdős-Yau (2012) in full generality, uses fundamentally different techniques: the moment method, comparison arguments, and local semicircle laws.

Our contribution is to formalize the foundational layer of this theory: the definitions, structural properties, and key inequalities that underpin the more sophisticated arguments. While the full Tracy-Widom convergence theorem requires measure-theoretic probability and stochastic analysis beyond current formalization capabilities, the structural foundations are amenable to rigorous machine-checked proof.

## 2. Definitions

### 2.1 Catalan Numbers

**Definition 2.1** (Catalan Number). The Catalan numbers are defined by the recurrence:
- C(0) = 1
- C(n+1) = Σ_{k=0}^{n} C(k) · C(n-k)

Equivalently, C(n) = (2n)! / ((n+1)! · n!). The Catalan numbers count non-crossing pair partitions of {1,...,2n}.

In our formalization, we use a recursive definition with explicit termination proof via the `termination_by` and `decreasing_by` tactics.

### 2.2 Semicircle Density

**Definition 2.2** (Semicircle Density). The normalized semicircle density on [-1,1] is:
$$\rho(x) = \begin{cases} \frac{2}{\pi}\sqrt{1-x^2} & \text{if } -1 \leq x \leq 1 \\ 0 & \text{otherwise} \end{cases}$$

This is the density of the *arcsine distribution* of the second kind, and it describes the limiting spectral distribution of normalized Wigner matrices.

### 2.3 Tracy-Widom Scaling

**Definition 2.3** (Tracy-Widom Scaling). For matrix dimension n and eigenvalue λ:
$$s(n, \lambda) = n^{2/3} \left(\frac{\lambda}{\sqrt{n}} - 2\right)$$

This maps the edge location 2√n to 0 and rescales fluctuations by n^{2/3}.

### 2.4 Airy Kernel

**Definition 2.4** (Airy Kernel Data). We define a structure `AiryKernelData` containing the values Ai(x), Ai(y), Ai'(x), Ai'(y) at two points, with:
- Off-diagonal: K(x,y) = (Ai(x)Ai'(y) - Ai'(x)Ai(y)) / (x-y)
- Diagonal: K(x,x) = Ai'(x)² - x·Ai(x)²

### 2.5 Four-Moment Matching

**Definition 2.5** (Four-Moment Match). Two moment functions μ₁, μ₂ satisfy four-moment matching if they agree on the first four moments: mean zero, unit variance, equal third and fourth moments. This is the Tao-Vu condition for edge universality.

### 2.6 Normalized Trace and Spectral Moments

**Definition 2.6**. For an n×n matrix A:
- Normalized trace: m(A) = (1/n) Tr(A)
- k-th spectral moment: m_k(A) = (1/n) Tr(A^k)

## 3. Main Results

### 3.1 Catalan Number Properties

**Theorem 3.1** (Catalan Base Cases). C(0) = 1, C(1) = 1, C(2) = 2.

*Proof sketch*: Direct computation using the recurrence definition. C(1) and C(2) are verified via `native_decide`. □

**Theorem 3.2** (Catalan Positivity). For all n ≥ 0, C(n) > 0.

*Proof sketch*: By strong induction on n. For n = 0, 1: by computation. For n ≥ 2: C(n+1) = Σ C(k)C(n-k), and each term C(k)C(n-k) is positive by the induction hypothesis (both k and n-k are less than n+1). The sum of positive terms is positive. □

**Theorem 3.3** (Catalan Exponential Bound). For all n ≥ 0, C(n) ≤ 4^n.

*Proof sketch*: We establish that our `catalanNumber` function equals Mathlib's `catalan` function (by strong induction on the recurrence), then use `catalan_eq_centralBinom_div` to write C(n) = (2n choose n)/(n+1). Since C(n) ≤ (2n choose n) (dividing by n+1 ≥ 1), and (2n choose n) ≤ 2^{2n} = 4^n (since (2n choose n) is one term in Σ_{k=0}^{2n} (2n choose k) = 2^{2n}), we conclude C(n) ≤ 4^n. □

### 3.2 Semicircle Density Properties

**Theorem 3.4** (Non-negativity). ρ(x) ≥ 0 for all x ∈ ℝ.

*Proof sketch*: Outside [-1,1], ρ(x) = 0 ≥ 0. Inside, (2/π) > 0 and √(1-x²) ≥ 0, so their product is non-negative. The `positivity` tactic handles this automatically. □

**Theorem 3.5** (Symmetry). ρ(-x) = ρ(x) for all x ∈ ℝ.

*Proof sketch*: The condition -1 ≤ -x ∧ -x ≤ 1 is equivalent to -1 ≤ x ∧ x ≤ 1, and (-x)² = x², so the defining formula gives the same value. □

**Theorem 3.6** (Support). If |x| > 1, then ρ(x) = 0.

*Proof sketch*: |x| > 1 implies ¬(-1 ≤ x ∧ x ≤ 1), so the else branch of the definition applies. □

**Theorem 3.7** (Maximum at Origin). ρ(0) = 2/π.

*Proof sketch*: 0 ∈ [-1,1], so ρ(0) = (2/π)√(1-0²) = (2/π)·1 = 2/π. □

**Theorem 3.8** (Edge Vanishing). ρ(1) = 0.

*Proof sketch*: 1 ∈ [-1,1], so ρ(1) = (2/π)√(1-1²) = (2/π)·0 = 0. □

### 3.3 Matrix Trace Results

**Theorem 3.9** (Frobenius Decomposition). For any n×n real matrix A:
$$\text{Tr}(A^2) = \sum_{i,j} A_{ij} A_{ji}$$

*Proof sketch*: Direct unfolding of matrix multiplication and trace. This is definitionally true. □

**Theorem 3.10** (Symmetric Frobenius). For symmetric A:
$$\text{Tr}(A^2) = \sum_{i,j} A_{ij}^2$$

*Proof sketch*: From Theorem 3.9, replace A_{ji} with A_{ij} using symmetry (A.IsSymm.apply), obtaining A_{ij} · A_{ij} = A_{ij}². □

**Theorem 3.11** (Non-negative Trace of Square). For symmetric A, Tr(A²) ≥ 0.

*Proof sketch*: By Theorem 3.10, Tr(A²) = Σ_{i,j} A_{ij}², which is a sum of squares, hence non-negative. □

**Theorem 3.12** (Additivity of Normalized Trace). m(A+B) = m(A) + m(B).

*Proof sketch*: (1/n)Tr(A+B) = (1/n)(Tr(A) + Tr(B)) = (1/n)Tr(A) + (1/n)Tr(B). Uses linearity of trace and distributivity of multiplication over addition. □

**Theorem 3.13** (Zeroth Spectral Moment). For n > 0, m₀(A) = 1.

*Proof sketch*: m₀(A) = (1/n)Tr(A⁰) = (1/n)Tr(I) = (1/n)·n = 1. □

### 3.4 Airy Kernel Properties

**Theorem 3.14** (Numerator Antisymmetry). For the Airy kernel numerator:
$$\text{Ai}(x)\text{Ai}'(y) - \text{Ai}'(x)\text{Ai}(y) = -[\text{Ai}(y)\text{Ai}'(x) - \text{Ai}'(y)\text{Ai}(x)]$$

*Proof sketch*: Pure algebra: a·d - c·b = -(b·c - d·a). Proved by `ring`. □

**Theorem 3.15** (Diagonal Formula). The diagonal Airy kernel at (x,x) with Ai(x) = a, Ai'(x) = a' is:
$$K(x,x) = (a')^2 - x \cdot a^2$$

*Proof sketch*: Direct unfolding of the `diagonal` definition. □

### 3.5 Tracy-Widom Scaling Properties

**Theorem 3.16** (Strict Monotonicity). For n > 0, the Tracy-Widom scaling function λ ↦ s(n,λ) is strictly monotone.

*Proof sketch*: s(n,λ) = n^{2/3} · (λ/√n - 2). Since n > 0, the coefficient n^{2/3} > 0. The function λ ↦ λ/√n - 2 is strictly increasing (positive slope 1/√n). Multiplication by a positive constant preserves strict monotonicity. □

**Theorem 3.17** (Edge Centering). For n > 0, s(n, 2√n) = 0.

*Proof sketch*: s(n, 2√n) = n^{2/3} · (2√n/√n - 2) = n^{2/3} · (2 - 2) = n^{2/3} · 0 = 0. □

### 3.6 Tail Bound Properties

**Theorem 3.18** (Positivity). The tail bound exp(-2s^{3/2}/3) > 0 for all s.

*Proof sketch*: The exponential function is always positive. □

**Theorem 3.19** (Upper Bound). For s ≥ 0, exp(-2s^{3/2}/3) ≤ 1.

*Proof sketch*: For s ≥ 0, s^{3/2} ≥ 0, so -2s^{3/2}/3 ≤ 0, hence exp(-2s^{3/2}/3) ≤ exp(0) = 1. □

## 4. Algorithms

### 4.1 Catalan Number Computation

The recurrence C(n+1) = Σ C(k)C(n-k) can be computed in O(n²) time with memoization. The closed-form C(n) = (2n choose n)/(n+1) is computable in O(n) time.

### 4.2 Wigner Matrix Generation

Generate an n×n Wigner matrix:
1. Sample n² i.i.d. entries from the chosen distribution
2. Symmetrize: W ← (W + Wᵀ)/2
3. Normalize: W ← W/√n

### 4.3 Edge Universality Testing

To test edge universality numerically:
1. Generate M independent Wigner matrices of size n
2. Compute the largest eigenvalue λ_max of each
3. Apply Tracy-Widom scaling: s = n^{2/3}(λ_max/√n - 2)
4. Compare the empirical distribution of s values across different entry distributions
5. Verify convergence to Tracy-Widom F₂

## 5. Discussion

### 5.1 Relationship to the Catalog

Our formalization connects to several existing catalog results:

- **trace_identity_matrix** (`Algebra/ChimeraFactoring.lean`): We extend trace computations to symmetric matrix powers, proving the Frobenius decomposition Tr(A²) = Σ A_{ij}².
- **exponential_convergence_bound** (`Algebra/IntegerEnergy/ConvergenceTheory.lean`): Our Tracy-Widom tail bound exp(-2s^{3/2}/3) parallels exponential convergence bounds.
- **Catalan-moment connection**: The identification of our `catalanNumber` with Mathlib's `catalan` function bridges elementary combinatorics with random matrix spectral theory.

### 5.2 The Four-Moment Matching Paradigm

The Tao-Vu four-moment matching theorem states that if two entry distributions share their first four moments, then the joint distribution of any fixed number of eigenvalues is asymptotically the same. Our `FourMomentMatch` structure formalizes this condition. The key application is: given any Wigner matrix with entries having mean 0, variance 1, matching third moment, and matching fourth moment to the Gaussian, edge universality follows from the Gaussian case.

### 5.3 Limitations

Our formalization captures structural properties but not the full probabilistic content of edge universality. A complete formalization would require:
1. Measure-theoretic probability (available in Mathlib but complex)
2. Weak convergence of probability measures
3. Determinantal point processes
4. Fredholm determinant theory
5. Riemann-Hilbert analysis for the Airy kernel

These represent significant formalization challenges that go beyond current capabilities.

## 6. Future Work

1. **Full semicircle law**: Formalize the convergence of empirical spectral measures to the semicircle distribution using the moment method.
2. **Stieltjes transform**: Define and prove properties of the Stieltjes transform, which provides an alternative proof of the semicircle law.
3. **Local semicircle law**: Formalize the Erdős-Schlein-Yau local semicircle law, which gives eigenvalue density estimates at mesoscopic scales.
4. **Tracy-Widom CDF**: Define the Tracy-Widom distribution via the Painlevé II equation and prove its basic properties.
5. **Determinantal structure**: Formalize the connection between the Airy kernel and the correlation functions of eigenvalues at the edge.

## 7. References

1. E. Wigner, "Characteristic vectors of bordered matrices with infinite dimensions," Ann. Math. 62 (1955), 548-564.
2. C. Tracy and H. Widom, "Level-spacing distributions and the Airy kernel," Comm. Math. Phys. 159 (1994), 151-174.
3. A. Soshnikov, "A note on universality of the distribution of the largest eigenvalue in certain sample covariance matrices," J. Stat. Phys. 108 (2002), 1033-1056.
4. T. Tao and V. Vu, "Random matrices: Universality of local eigenvalue statistics up to the edge," Comm. Math. Phys. 298 (2010), 549-572.
5. L. Erdős and H.-T. Yau, "Universality of local spectral statistics of random matrices," Bull. AMS 49 (2012), 377-414.
6. G. Anderson, A. Guionnet, and O. Zeitouni, "An Introduction to Random Matrices," Cambridge University Press, 2010.
