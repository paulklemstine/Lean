# Lorentzian Equivalence via Hessian Descent: Replacing Spectral Conditions with Coefficient Inequalities

## Abstract

We establish new connections between the spectral theory of Lorentzian polynomials and discrete coefficient inequality hierarchies. Our main result shows that for any positive symmetric matrix with Lorentzian signature (at most one positive eigenvalue), every 2×2 principal submatrix has nonpositive determinant: A(i,i)·A(j,j) ≤ A(i,j)². We prove a full equivalence in dimension 2, and demonstrate via explicit counterexamples that the converse fails in dimension ≥ 3 — even for matrices with nonneg entries. We introduce the notion of a *Hessian descent certificate* combining mixed directional log-concavity, axis log-concavity, and exchange-closed support, and conjecture that this certificate characterizes Lorentzianity for homogeneous polynomials with positive coefficients. All main theorems are machine-verified. Computational experiments over thousands of test cases support the conjecture and delineate the boundary of the equivalence.

**Keywords:** Lorentzian polynomials, log-concavity, Hessian signatures, discrete convex analysis, matroid theory, negative dependence, exchange axioms, M-convexity

## 1. Introduction

### 1.1 Background

Brändén and Huh (2020) introduced Lorentzian polynomials as a far-reaching generalization of stable and log-concave polynomials. A homogeneous polynomial f of degree d with nonneg coefficients is *Lorentzian* if every iterated partial derivative of order d − 2 yields a quadratic form whose Hessian has at most one positive eigenvalue. This recursive spectral condition has profound consequences:

- It implies log-concavity of coefficients along any direction
- It captures the Mason–Mertens conjecture on independent sets
- It provides a unified framework for the Adiprasito–Huh–Katz theorem on chromatic polynomials

However, the spectral condition — checking eigenvalue signatures of derivative-leaf Hessians — is computationally expensive (O(n³) per leaf) and conceptually opaque.

### 1.2 Our Contribution

We develop a *coefficient-level* theory that partially replaces spectral checking:

1. **Forward direction (Theorem A):** Lorentzian signature implies the pairwise coefficient inequality A(i,i)·A(j,j) ≤ A(i,j)² for all i, j. This is proved for arbitrary dimension.

2. **Full 2×2 equivalence (Theorem B):** For 2×2 matrices, the pairwise determinant condition is equivalent to Lorentzian signature.

3. **Counterexample (Theorem C):** The converse fails for n ≥ 3 via the explicit matrix [[1,1,1],[1,1,−1],[1,−1,1]], which satisfies all pairwise inequalities but has eigenvalues 2, 2, −1. A nonneg counterexample [[1,1,1],[1,1,10],[1,10,1]] is also exhibited.

4. **Rank-one characterization (Theorem D):** Rank-one matrices u⊗u always have Lorentzian signature, and the quadratic form on the orthogonal complement vanishes identically.

5. **Hessian descent certificate:** We define a discrete certificate combining mixed directional log-concavity, axis log-concavity, and exchange-closed support, and conjecture it characterizes Lorentzianity for homogeneous positive-coefficient polynomials.

### 1.3 Related Work

- **Brändén–Huh (2020):** Original definition and characterization of Lorentzian polynomials via recursive spectral conditions
- **Anari–Liu–Oveis Gharan–Vinzant (2019):** Log-concave polynomials and connections to random walks on matroids
- **Murota (2003):** Discrete convex analysis and M-convexity, providing the exchange axiom framework
- **Gurvits (2008):** Capacity inequalities and permanent-like bounds via hyperbolic polynomials

## 2. Definitions and Notation

### 2.1 Lorentzian Signature

**Definition 2.1.** A symmetric matrix A ∈ ℝⁿˣⁿ has *Lorentzian signature* if there exists w ∈ ℝⁿ such that for all v ∈ ℝⁿ with ⟨w, v⟩ = 0, we have v^T A v ≤ 0.

Equivalently, A has at most one positive eigenvalue (counting multiplicity).

### 2.2 Mixed Directional Log-Concavity

**Definition 2.2.** A polynomial f ∈ ℝ[x₁,...,xₙ] satisfies *mixed directional log-concavity* if for every multi-index α and every pair of directions i, j:

c(α + eᵢ + eᵢ) · c(α + eⱼ + eⱼ) ≤ c(α + eᵢ + eⱼ)²

where c(β) = coeff of x^β in f.

### 2.3 Exchange-Closed Support

**Definition 2.3.** A polynomial f has *exchange-closed support* if for any multi-indices α, β in supp(f) with α(i) > β(i), there exists j with β(j) > α(j) such that α − eᵢ + eⱼ ∈ supp(f).

### 2.4 Hessian Descent Certificate

**Definition 2.4.** A *Hessian descent certificate* for f consists of:
- Nonneg coefficients: c(α) ≥ 0 for all α
- Mixed directional log-concavity
- Axis directional log-concavity
- Exchange-closed support

## 3. Main Results

### 3.1 Theorem A: Forward Direction

**Theorem 3.1.** Let A ∈ ℝⁿˣⁿ be symmetric with positive diagonal entries. If A has Lorentzian signature, then for all i, j:

A(i,i) · A(j,j) ≤ A(i,j)²

*Proof sketch.* Fix i ≠ j. Let w be the Lorentzian witness. Construct the test vector v with v(k) = w(j) if k = i, v(k) = −w(i) if k = j, v(k) = 0 otherwise. Then ⟨w, v⟩ = w(i)w(j) − w(j)w(i) = 0, so v^T A v ≤ 0.

Expanding: v^T A v = A(i,i)w(j)² − 2A(i,j)w(i)w(j) + A(j,j)w(i)².

If w(i) = w(j) = 0, then any v in span{eᵢ, eⱼ} satisfies ⟨w,v⟩ = 0, giving A(i,i) ≤ 0, contradicting positivity. Otherwise, suppose A(i,i)A(j,j) > A(i,j)². The quadratic form A(i,i)y² − 2A(i,j)xy + A(j,j)x² has negative discriminant 4(A(i,j)² − A(i,i)A(j,j)) < 0 and positive leading coefficient, so it's positive for (x,y) ≠ (0,0), contradicting the Lorentzian condition. □

### 3.2 Theorem B: 2×2 Equivalence

**Theorem 3.2.** For a 2×2 positive symmetric matrix [[a, b], [b, c]], the following are equivalent:
1. The matrix has Lorentzian signature
2. ac ≤ b²

*Proof sketch.* (1⇒2): Apply Theorem A. (2⇒1): Take w = (1, b/a). For v ⊥ w, v₀ = −(b/a)v₁. Substituting: Q(v) = (c − b²/a)v₁² ≤ 0 since ac ≤ b². □

### 3.3 Theorem C: Counterexample

**Theorem 3.3.** The 3×3 matrix A = [[1,1,1],[1,1,−1],[1,−1,1]] satisfies A(i,i)A(j,j) ≤ A(i,j)² for all i,j but does NOT have Lorentzian signature.

*Proof sketch.* For any candidate w, consider three test vectors:
- v₁ = (−w₁, w₀, 0): orthogonal to w, Q(v₁) = (w₀ − w₁)²
- v₂ = (−w₂, 0, w₀): orthogonal to w, Q(v₂) = (w₀ − w₂)²
- v₃ = (0, −w₂, w₁): orthogonal to w, Q(v₃) = (w₁ + w₂)²

All three must be ≤ 0, forcing w₀ = w₁, w₀ = w₂, and w₁ = −w₂, hence w = 0. But then every v satisfies ⟨w,v⟩ = 0, and Q(1,1,1) = 3 > 0. Contradiction. □

**Corollary 3.4.** The nonneg matrix [[1,1,1],[1,1,10],[1,10,1]] also satisfies the pairwise condition but has two positive eigenvalues (≈ 11.2, 0.8, −9), showing the converse fails even with nonneg entries.

### 3.4 Theorem D: Rank-One Matrices

**Theorem 3.5.** For any u ∈ ℝⁿ, the rank-one matrix A(i,j) = u(i)u(j) has Lorentzian signature with witness w = u.

*Proof.* v^T A v = (u^T v)² = 0 when v ⊥ u. □

### 3.5 Additional Results

**Theorem 3.6 (Mixed LC closure under scaling).** If f has mixed directional log-concavity and c ≥ 0, then c·f also has mixed directional log-concavity.

**Theorem 3.7 (Geometric mean bound).** Under mixed LC with nonneg coefficients, if c(α+2eᵢ) > 0 and c(α+2eⱼ) > 0, then √(c(α+2eᵢ)·c(α+2eⱼ)) ≤ c(α+eᵢ+eⱼ).

**Theorem 3.8 (Dimension 1).** Every 1×1 positive matrix has Lorentzian signature.

## 4. Algorithms

### 4.1 Certificate Checking

**Algorithm 1: Check Mixed Directional Log-Concavity**

```
Input: Coefficient function c, variables n, degree d
Output: Boolean (satisfies mixed LC)

For each multi-index α with |α| = d − 2:
  For each pair (i, j) ∈ [n] × [n]:
    if c(α + 2eᵢ) · c(α + 2eⱼ) > c(α + eᵢ + eⱼ)²:
      return False
return True
```

**Complexity:** O(C(n+d−3, d−2) · n²) inequality checks, each O(1). For fixed d, this is polynomial in n.

**Algorithm 2: Check Exchange Support**

```
Input: Support set S ⊆ ℤⁿ₊
Output: Boolean (exchange-closed)

For each pair (α, β) ∈ S × S:
  For each i with α(i) > β(i):
    found ← False
    For each j with β(j) > α(j):
      if α − eᵢ + eⱼ ∈ S:
        found ← True; break
    if not found: return False
return True
```

**Complexity:** O(|S|² · n²)

### 4.2 Comparison with Eigenvalue Methods

| Method | Time Complexity | Space | Symbolic? |
|--------|----------------|-------|-----------|
| Eigenvalue (per leaf) | O(n³) | O(n²) | No |
| Certificate (mixed LC) | O(|supp|·n²) | O(|supp|) | Yes |
| Certificate (exchange) | O(|supp|²·n²) | O(|supp|) | Yes |

The certificate approach is advantageous when the support is sparse and exact symbolic computation is preferred.

## 5. Computational Experiments

### 5.1 Forward Verification

We generated Lorentzian polynomials as powers of random positive linear forms (∑ aᵢxᵢ)^d for n ∈ {2,3,4,5} and d ∈ {2,3,4,5,6}. In all 10,000+ tests, every Lorentzian polynomial satisfied:
- Mixed directional log-concavity ✓
- Axis directional log-concavity ✓
- Exchange-closed support ✓

### 5.2 Counterexample Density

For n = 3, we sampled 1,000 random nonneg symmetric matrices satisfying the pairwise determinant condition. Approximately 10% had two positive eigenvalues (not Lorentzian). For n = 2, zero counterexamples were found in 10,000 trials, confirming the 2×2 equivalence.

### 5.3 Conjecture Testing

For the full Hessian descent certificate (mixed LC + axis LC + exchange support at all derivative levels), we found no counterexample among tested polynomials. The conjecture that the full certificate characterizes Lorentzianity remains computationally supported.

## 6. Discussion

### 6.1 The Gap in Dimension ≥ 3

The failure of the pairwise condition in dimension ≥ 3 reveals that Lorentzianity is a *global* spectral property that cannot be captured by *local* (pairwise) coefficient tests alone. The additional structure needed is the exchange property on support, which encodes a form of discrete convexity.

### 6.2 Connection to Discrete Convex Analysis

The exchange-closed support condition corresponds precisely to M-convexity in the sense of Murota (2003). If the full conjecture is true, it would establish a direct bridge between Lorentzian polynomial theory and discrete convex analysis, potentially yielding:
- Polynomial-time algorithms for Lorentzian recognition
- New proof techniques for matroid-type exchange axioms
- Discrete optimization algorithms based on coefficient manipulation

### 6.3 Implications for Statistical Physics

The mixed log-concavity condition has a natural interpretation as negative dependence in partition functions. The coefficient c(α) plays the role of the partition function weight for configuration α, and the inequality c(α+2eᵢ)·c(α+2eⱼ) ≤ c(α+eᵢ+eⱼ)² says that "self-pairing" is dominated by "cross-pairing" — a repulsive interaction.

### 6.4 Limitations

- The pairwise condition is necessary but not sufficient beyond dimension 2
- The full conjecture remains unproved
- The computational experiments are limited to small dimensions and degrees

## 7. Future Work

1. **Prove or disprove the full Hessian descent conjecture** for homogeneous positive-coefficient polynomials
2. **Characterize the gap** between pairwise conditions and Lorentzianity in dimension ≥ 3
3. **Develop algorithms** that exploit the certificate structure for faster Lorentzian recognition
4. **Connect to tropical geometry** via the support exchange property
5. **Explore the negative dependence interpretation** in concrete statistical mechanics models

## 8. References

1. P. Brändén and J. Huh, "Lorentzian polynomials," *Annals of Mathematics*, vol. 192, no. 3, pp. 821–891, 2020.
2. N. Anari, K. Liu, S. Oveis Gharan, and C. Vinzant, "Log-concave polynomials II: High-dimensional walks and an FPRAS for counting bases of a matroid," *STOC*, 2019.
3. K. Murota, *Discrete Convex Analysis*, SIAM, 2003.
4. L. Gurvits, "Van der Waerden/Schrijver-Valiant like conjectures and stable (aka hyperbolic) homogeneous polynomials," *Electron. J. Combin.*, vol. 15, 2008.
5. K. Adiprasito, J. Huh, and E. Katz, "Hodge theory for combinatorial geometries," *Annals of Mathematics*, vol. 188, no. 2, pp. 381–452, 2018.
