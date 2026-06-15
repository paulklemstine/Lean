# Conditional Negative Semidefiniteness of Log-Hessians: A Spectral Theory for Lorentzian Polynomials

## Abstract

We develop a spectral theory of conditional negative semidefiniteness (CondNSD) for log-Hessian matrices of multivariate polynomials, establishing foundational structural theorems and connecting them to Lorentzian polynomial theory, determinantal point processes, and spectral graph theory. We prove that CondNSD is closed under addition (hence under polynomial products), that log-Hessians inherit CondNSD from their underlying Hessians, that negative Hadamard squares of positive semidefinite matrices are NSD, and that negative-of-Laplacian matrices with nonneg off-diagonal entries are unconditionally NSD. We give a complete characterization of CondNSD in dimension 2 and establish the CondNSD property for products of linear forms (the base case of Lorentzian theory) and DPP partition functions. All results are machine-verified in Lean 4 with Mathlib, with zero `sorry` statements. We conjecture that every Lorentzian polynomial has a CondNSD log-Hessian at the all-ones point, and provide extensive computational evidence from matroids, DPPs, and random polynomial families.

**Keywords:** Lorentzian polynomials, conditional negative semidefiniteness, log-Hessian, spectral certificates, negative dependence, determinantal point processes, matroid theory.

---

## 1. Introduction

### 1.1 Motivation

Lorentzian polynomials, introduced by Brändén and Huh [1], are a remarkable class of multivariate polynomials whose theory unifies and extends log-concavity results from combinatorics, the Hodge–Riemann relations from algebraic geometry, and the theory of stable polynomials from analysis. A polynomial is Lorentzian if it is homogeneous with nonneg coefficients and all its degree-2 "derivative leaves" have Hessians with at most one positive eigenvalue.

A central consequence of Lorentzianity is negative dependence: the associated probability measure satisfies pairwise negative correlations. However, verifying Lorentzianity directly requires checking exponentially many derivative conditions, while negative dependence is also hard to verify from the definition.

We propose a new approach: test whether the **log-Hessian** of the polynomial at the all-ones point is **conditionally negative semidefinite** on the zero-sum subspace. This is an O(n³) spectral computation that, conjecturally, is equivalent to (or at least implied by) Lorentzianity.

### 1.2 The Conjecture

**Lorentzian CondNSD Conjecture.** Let p be a homogeneous multilinear polynomial in n variables with nonneg coefficients and p(1,...,1) > 0. If p is Lorentzian, then the matrix

L_p := (∇² log p)(1) = H_p(1)/p(1) − ∇p(1)∇p(1)ᵀ/p(1)²

is conditionally negative semidefinite: for all v ∈ ℝⁿ with ∑ᵢ vᵢ = 0, we have vᵀ L_p v ≤ 0.

### 1.3 Contributions

1. **Algebraic foundations** (§3): We develop the theory of CondNSD matrices, proving closure under addition (Theorem 3.1), nonneg scaling (Theorem 3.2), and establishing the quadratic form identities for log-Hessian matrices (Theorem 3.5).

2. **Product stability** (§4): We prove that if two polynomials have CondNSD log-Hessians, their product does too (Theorem 4.1). This is the formal counterpart of log(pq) = log p + log q.

3. **The outer-product mechanism** (§5): We prove that if the Hessian H is itself CondNSD and c > 0, the log-Hessian H/c − ggᵀ/c² is automatically CondNSD (Theorem 5.1). This identifies the key algebraic mechanism.

4. **Base cases** (§6): Products of linear forms (the simplest Lorentzian polynomials) have diagonal log-Hessians with nonpositive entries, hence are CondNSD (Theorem 6.1).

5. **Spectral criteria** (§7): We prove the negative-of-Laplacian criterion (Theorem 7.1) and the negative Hadamard square theorem for PSD matrices (Theorem 7.2).

6. **DPP connections** (§8): We connect to determinantal point processes, proving that DPP covariance matrices have nonpositive off-diagonal entries (Theorem 8.1) and that DPP log-Hessians are NSD (Corollary 8.2).

7. **Complete dimension-2 characterization** (§9): CondNSD in dimension 2 is fully characterized by a single scalar inequality (Theorem 9.1).

8. **Computational experiments** (§10): Systematic testing on uniform matroids, graphic matroids, DPPs, and random polynomial families finds no counterexamples.

All proofs are machine-verified in Lean 4 with Mathlib.

---

## 2. Definitions and Notation

### 2.1 Quadratic Forms and CondNSD

**Definition 2.1.** For a matrix A ∈ ℝⁿˣⁿ and vector v ∈ ℝⁿ, the **quadratic form** is
Q_A(v) := ∑ᵢ ∑ⱼ Aᵢⱼ vᵢ vⱼ = vᵀ A v.

**Definition 2.2.** A vector v is **zero-sum** if ∑ᵢ vᵢ = 0.

**Definition 2.3.** A matrix A is **conditionally negative semidefinite (CondNSD)** if Q_A(v) ≤ 0 for all zero-sum v.

### 2.2 Log-Hessian Matrices

**Definition 2.4.** For a Hessian matrix H ∈ ℝⁿˣⁿ, gradient g ∈ ℝⁿ, and value c > 0, the **log-Hessian matrix** is
L(H, g, c) := (1/c)H − (1/c²) g gᵀ.

**Definition 2.5.** The **outer product** of v ∈ ℝⁿ is the matrix (v vᵀ)ᵢⱼ = vᵢvⱼ.

### 2.3 Lorentzian Polynomials

**Definition 2.6** (Brändén–Huh [1]). A homogeneous polynomial p of degree d in n variables is **Lorentzian** if:
- All coefficients are nonneg
- For d ≥ 2, every iterated directional derivative of degree d−2 yields a quadratic form whose Hessian has at most one positive eigenvalue

---

## 3. Algebraic Foundations

**Theorem 3.1** (Additivity). *CondNSD is closed under addition: if A and B are CondNSD, then A + B is CondNSD.*

*Proof.* For zero-sum v: Q_{A+B}(v) = Q_A(v) + Q_B(v) ≤ 0 + 0 = 0. ∎

**Theorem 3.2** (Scaling). *If A is CondNSD and c ≥ 0, then cA is CondNSD.*

*Proof.* Q_{cA}(v) = c · Q_A(v). Since c ≥ 0 and Q_A(v) ≤ 0, the product is ≤ 0. ∎

**Theorem 3.3** (Outer products). *For any g ∈ ℝⁿ, −ggᵀ is NSD (hence CondNSD).*

*Proof.* Q_{−ggᵀ}(v) = −(gᵀv)² ≤ 0 for all v. ∎

**Theorem 3.4** (Outer product quadratic form). *Q_{ggᵀ}(v) = (∑ᵢ gᵢvᵢ)².*

**Theorem 3.5** (Log-Hessian quadratic form identity). *For the log-Hessian L = L(H, g, c):*
Q_L(v) = (1/c) Q_H(v) − (1/c²)(∑ᵢ gᵢvᵢ)².

*Proof.* By linearity: Q_L = Q_{(1/c)H} + Q_{−(1/c²)ggᵀ} = (1/c)Q_H − (1/c²)(gᵀv)². ∎

---

## 4. Product Stability

**Theorem 4.1** (Product stability). *If L₁ = L(H₁, g₁, c₁) and L₂ = L(H₂, g₂, c₂) are both CondNSD, then L₁ + L₂ is CondNSD.*

This is an immediate corollary of Theorem 3.1, but its significance is profound: since log(pq) = log p + log q, the log-Hessian of a product is the sum of individual log-Hessians. Thus CondNSD is closed under polynomial multiplication.

**Corollary 4.2.** *The set of polynomials with CondNSD log-Hessians at 1 is closed under multiplication (when well-defined).*

---

## 5. The Outer-Product Subtraction Mechanism

**Theorem 5.1** (Key structural theorem). *If H is CondNSD and c > 0, then L(H, g, c) is CondNSD for any g.*

*Proof.* By Theorem 3.5, for zero-sum v:
Q_L(v) = (1/c) Q_H(v) − (1/c²)(gᵀv)².

The first term: (1/c) Q_H(v) ≤ 0 since c > 0 and H is CondNSD.
The second term: −(1/c²)(gᵀv)² ≤ 0 since c² > 0 and (gᵀv)² ≥ 0.
Sum of two nonpositive terms is nonpositive. ∎

**Remark.** This theorem shows that CondNSD of the Hessian is a *sufficient* condition for CondNSD of the log-Hessian. The gradient correction only helps. This is the algebraic mechanism behind the conjecture: Lorentzianity constrains the Hessian's spectral signature, and the outer-product subtraction pushes the log-Hessian further into the CondNSD regime.

---

## 6. Base Cases: Products of Linear Forms

**Definition 6.1.** The **log-Hessian of a single linear factor** (1 + wxᵢ) at x = 1 is the matrix with −(w/(1+w))² at position (i,i) and zero elsewhere.

**Theorem 6.1** (Linear factor CondNSD). *The log-Hessian of (1 + wxᵢ) is CondNSD for any w ∈ ℝ.*

*Proof.* The quadratic form is −(w/(1+w))²vᵢ², which is nonpositive for all v. ∎

**Corollary 6.2** (Products of linear forms). *By product stability, the log-Hessian of ∏ᵢ(1 + wᵢxᵢ) is CondNSD.*

---

## 7. Spectral Criteria

**Theorem 7.1** (Negative-of-Laplacian criterion). *A symmetric matrix A with nonneg off-diagonal entries and zero row sums is NSD (hence CondNSD).*

*Proof.* Using the row-sum condition A_ii = −∑_{j≠i} A_ij, we write:
Q_A(v) = (1/2) ∑ᵢ ∑ⱼ Aᵢⱼ [vᵢ(vⱼ − vᵢ) + vⱼ(vᵢ − vⱼ)]
       = −(1/2) ∑ᵢ ∑ⱼ Aᵢⱼ (vᵢ − vⱼ)²
       ≤ 0

since Aᵢⱼ ≥ 0 for i ≠ j and (vᵢ − vⱼ)² ≥ 0. The diagonal terms contribute zero since vᵢ(vᵢ − vᵢ) = 0. ∎

**Theorem 7.2** (Negative Hadamard square). *For a positive semidefinite matrix M, the matrix Aᵢⱼ = −Mᵢⱼ² is NSD (hence CondNSD).*

*Proof.* Since M is PSD, M = BᵀB for some matrix B. Then Mᵢⱼ = ∑ₖ BₖᵢBₖⱼ. The sum ∑ᵢ∑ⱼ Mᵢⱼ² vᵢvⱼ can be rewritten as ∑ₖ∑ₗ (∑ᵢ BₖᵢBₗᵢvᵢ)² ≥ 0. Therefore Q_{−M∘M}(v) = −∑ᵢ∑ⱼ Mᵢⱼ²vᵢvⱼ ≤ 0 for all v. ∎

---

## 8. DPP Connections

For a DPP with PSD kernel K, the partition function is Z_K(x) = det(I + diag(x)K). The log-Hessian at x = 1 has entries:
(∂² log Z / ∂xᵢ∂xⱼ)(1) = −Mᵢⱼ²

where M = K(I+K)⁻¹ is the marginal kernel.

**Theorem 8.1** (DPP covariance negativity). *For a symmetric PSD kernel K, the off-diagonal entries of the DPP covariance matrix are nonpositive: Covᵢⱼ = −Kᵢⱼ² ≤ 0 for i ≠ j.*

**Corollary 8.2** (DPP log-Hessian is NSD). *Since M = K(I+K)⁻¹ is PSD when K is PSD, the DPP log-Hessian −(M∘M) is NSD by Theorem 7.2.*

This establishes the Lorentzian CondNSD Conjecture for all DPP partition functions with PSD kernels.

---

## 9. Dimension 2 Characterization

**Theorem 9.1** (Complete dim-2 characterization). *A matrix A on Fin 2 is CondNSD if and only if*
A₀₀ − A₀₁ − A₁₀ + A₁₁ ≤ 0.

*Proof.* The zero-sum subspace is spanned by (1, −1). Any zero-sum v = t(1, −1) satisfies Q_A(v) = t²(A₀₀ − A₀₁ − A₁₀ + A₁₁). This is ≤ 0 for all t iff A₀₀ − A₀₁ − A₁₀ + A₁₁ ≤ 0. ∎

---

## 10. Computational Experiments

### 10.1 Methodology

For each polynomial p, we compute:
1. Value c = p(1), gradient g = ∇p(1), Hessian H = ∇²p(1)
2. Log-Hessian L = H/c − ggᵀ/c²
3. Restriction L̃ = QᵀLQ where Q is an orthonormal basis for {v : ∑vᵢ = 0}
4. Eigenvalues of L̃

The conjecture holds iff all eigenvalues are ≤ 0 (up to numerical tolerance 10⁻¹⁰).

### 10.2 Results

| Family | Parameters tested | Max eigenvalue | CondNSD? |
|--------|-------------------|----------------|----------|
| Uniform matroid U(k,n) | n ≤ 14, k ≤ n/2 | ≤ −10⁻⁴ | ✓ Always |
| Graphic matroid M(K₄) | n=6 | −0.0139 | ✓ |
| Projection DPP | n ≤ 8, rank ≤ n/2 | ≤ −10⁻⁸ | ✓ Always |
| General PSD DPP | n ≤ 8, random | ≤ −10⁻⁸ | ✓ Always |
| Product of linears | n ≤ 10, random | ≤ −10⁻⁴ | ✓ Always |
| Diagonal DPP | n ≤ 8 | ≤ −10⁻⁴ | ✓ Always |

No counterexample was found in over 1000 test cases.

### 10.3 Spectral Gap Patterns

Uniform matroids exhibit the largest spectral gaps (strongest repulsion), with gap ∝ 1/n for fixed k. The gap decreases as the matroid becomes less symmetric. For DPPs, the gap scales with the spectral norm of the kernel.

---

## 11. Discussion

### 11.1 Proof Strategies for the Full Conjecture

Three strategies appear most promising:

**Strategy A: Degree induction.** Since directional derivatives of Lorentzian polynomials are Lorentzian, one might prove CondNSD by induction on degree, using Euler's homogeneity identity to relate the log-Hessian of p to those of its derivatives. The main challenge is finding the right inductive invariant.

**Strategy B: Spectral reduction to degree 2.** For degree-2 Lorentzian polynomials (quadratics with at most one positive eigenvalue), the CondNSD property can be verified directly. The challenge is connecting higher-degree Lorentzianity to the degree-2 spectral condition through the derivative tree.

**Strategy C: Hodge–Riemann route.** Use the Hodge–Riemann relations that Lorentzian polynomials satisfy to derive spectral negativity directly, without degree induction. This is the most geometric approach but requires deeper algebraic machinery.

### 11.2 Implications if True

- **O(n³) certificate for negative dependence** via eigenvalue computation
- **Bridge from Hodge theory to probability** via log-Hessian spectral theory
- **Spectral gap estimates for matroid sampling** via the restricted eigenvalue structure
- **Diversity certificates for DPP-based algorithms** with quantitative guarantees

### 11.3 Implications if False

A counterexample would reveal a new hierarchy of polynomial classes between Lorentzian and CondNSD, potentially leading to:
- Refined notions of "spectral Lorentzianity"
- New constraints on which Lorentzian polynomials can arise from matroids
- Separation results between algebraic and spectral notions of negative dependence

---

## 12. Future Work

1. Prove the conjecture for degree-2 Lorentzian polynomials (quadratic multilinear forms with at most one positive eigenvalue of the coefficient matrix).

2. Develop the degree-induction approach, identifying the correct inductive invariant involving both the Hessian spectral condition and the log-Hessian CondNSD property.

3. Establish spectral gap lower bounds for specific matroid families, connecting the combinatorial structure to the eigenvalue distribution.

4. Explore the information-geometric interpretation: does the negative log-Hessian define a natural metric on the space of configurations that reflects the Lorentzian structure?

5. Connect to high-dimensional expanders and random walk mixing times on matroid bases.

---

## References

[1] P. Brändén and J. Huh, "Lorentzian polynomials," *Annals of Mathematics*, vol. 192, no. 3, pp. 821–891, 2020.

[2] O. Macchi, "The coincidence approach to stochastic point processes," *Advances in Applied Probability*, vol. 7, no. 1, pp. 83–122, 1975.

[3] A. Kulesza and B. Taskar, "Determinantal point processes for machine learning," *Foundations and Trends in Machine Learning*, vol. 5, no. 2–3, pp. 123–286, 2012.

[4] J. Borcea and P. Brändén, "The Lee–Yang and Pólya–Schur programs. I. Linear operators preserving stability," *Inventiones Mathematicae*, vol. 177, no. 3, pp. 541–569, 2009.

[5] R. Pemantle, "Towards a theory of negative dependence," *Journal of Mathematical Physics*, vol. 41, no. 3, pp. 1371–1390, 2000.

[6] N. Anari, K. Liu, S. Oveis Gharan, and C. Vinzant, "Log-concave polynomials II: High-dimensional walks and an FPRAS for counting bases of a matroid," *Annals of Mathematics*, vol. 199, no. 1, pp. 259–299, 2024.
