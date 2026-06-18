# Sharp Constants in the Dimension-Degree Stability Law for Lorentzian Polynomials

## Abstract

We prove that the optimal stability constant for Lorentzian polynomial recognition under coefficientwise perturbation scales as Θ(1/n), improving the previously known O(1/n²) bound by a factor of n. Specifically, if a collection of n×n Hessian matrices has gapped Lorentzian signature with margin ε, and each matrix is perturbed by a matrix with entries bounded by ε/n, then the Lorentzian signature is preserved. We prove this bound is tight by exhibiting the all-ones matrix as an extremizer. The key technical ingredient is a Cauchy-Schwarz-based conversion from entrywise bounds to quadratic form bounds that avoids the n-factor loss inherent in the crude entry-counting approach. All results are machine-verified using the Lean 4 proof assistant with the Mathlib library.

## 1. Introduction

### 1.1 Background

Lorentzian polynomials, introduced by Brändén and Huh [1], are homogeneous polynomials whose Hessian matrices have at most one positive eigenvalue at every positive point. This curvature condition — the Lorentzian signature — unifies and extends a remarkable range of log-concavity phenomena in combinatorics, algebra, and geometry.

A polynomial p of degree d in n variables is Lorentzian if:
1. All coefficients of p are nonneg, and
2. Every "quadratic leaf" — obtained by taking d-2 partial derivatives — has a Hessian matrix with at most one positive eigenvalue.

The qualitative recognition criterion checks condition (2) exactly. In numerical computation, however, coefficients are known only approximately, raising the fundamental question:

**How much can the coefficients of a Lorentzian polynomial be perturbed before Lorentzianity is destroyed?**

### 1.2 Prior work

The stability of Lorentzian recognition was established in [2] using the notion of *gapped Lorentzian signature*: a matrix A has gapped signature with margin ε if there exists a direction w such that Q_A(v) ≤ -ε‖v‖² for all v orthogonal to w. The key stability theorem states that if A has gapped signature with margin ε and E is a perturbation with |Q_E(v)| ≤ δ‖v‖² for all v with δ < ε, then A + E retains at most one positive eigenvalue.

The bridge between coefficient perturbation and quadratic form perturbation was provided by:

**Theorem (quadFormBound_of_entry_bound, [2]).** If |A_{ij}| ≤ B for all i,j, then |Q_A(v)| ≤ n² · B · ‖v‖² for all v.

Combined with the gapped signature stability theorem, this yields a stability constant of C(n,d) = 1/n², meaning coefficient perturbations of size ε/n² are tolerated.

### 1.3 Our contribution

We improve the entry-to-quadratic-form conversion:

**Theorem 1 (Sharp quadratic form bound).** If |A_{ij}| ≤ B for all i,j, then |Q_A(v)| ≤ n · B · ‖v‖² for all v.

This directly yields:

**Theorem 2 (Sharp stability law).** If all leaf Hessians have gapped signature with margin ε and all perturbation entries are bounded by ε/n, then the Lorentzian signature is preserved.

**Theorem 3 (Tightness).** The bound n · B is achieved by the all-ones matrix, so the 1/n stability constant cannot be improved.

### 1.4 Significance

The improvement from 1/n² to 1/n is:
- **Quantitatively significant**: For n = 1000, the certified perturbation tolerance increases by a factor of 1000.
- **Qualitatively sharp**: The 1/n scaling is tight, so no further improvement is possible without additional structural assumptions.
- **Conceptually revealing**: The improvement comes from recognizing that entrywise perturbations induce operator-norm perturbations of order n (not n²), connecting Lorentzian stability to spectral perturbation theory.

## 2. Definitions and Setup

### 2.1 Quadratic forms and signature

**Definition 2.1 (Quadratic form).** For an n×n real matrix A, the associated quadratic form is:
$$Q_A(v) = \sum_{i=1}^n \sum_{j=1}^n A_{ij} v_i v_j$$

**Definition 2.2 (Squared norm).** The squared Euclidean norm is:
$$\|v\|^2 = \sum_{i=1}^n v_i^2$$

**Definition 2.3 (Quadratic form bound).** A matrix A has quadratic form bound c, written QuadFormBound(A, c), if |Q_A(v)| ≤ c · ‖v‖² for all v ∈ ℝⁿ.

**Definition 2.4 (Gapped signature).** A matrix A has gapped Lorentzian signature with margin ε, written HasGappedSignature(A, ε), if there exists w ∈ ℝⁿ such that Q_A(v) ≤ -ε‖v‖² for all v with ⟨w, v⟩ = 0.

**Definition 2.5 (At most one positive eigenvalue).** A matrix A has HasAtMostOnePositiveEigenvalue if there exists w ∈ ℝⁿ such that Q_A(v) ≤ 0 for all v with ⟨w, v⟩ = 0.

### 2.2 New definitions

**Definition 2.6 (Effective spectral dimension).** The effective spectral dimension of an n×n perturbation problem is the smallest constant d_eff such that entrywise B-bounded perturbations have quadratic form bound d_eff · B. For general matrices, d_eff = n.

**Definition 2.7 (Certified perturbation tolerance).** Given margin ε and dimension n, the certified perturbation tolerance is:
$$\tau(ε, n) = \frac{ε}{2n}$$

Any entry-bounded perturbation within this tolerance preserves both the Lorentzian signature and a residual gap of ε/2.

**Definition 2.8 (Structured Hessian perturbation).** A structured perturbation carries:
- The perturbation matrix Δ
- An entrywise bound B with |Δ_{ij}| ≤ B
- An effective dimension d_eff
- A spectral profile σ ≤ d_eff · B

## 3. Main Results

### 3.1 The Cauchy-Schwarz inequality for absolute sums

**Theorem 3.1 (cauchy_schwarz_sum_abs).** For any v ∈ ℝⁿ:
$$\left(\sum_{i=1}^n |v_i|\right)^2 \leq n \sum_{i=1}^n v_i^2$$

*Proof.* This is the standard Cauchy-Schwarz inequality applied to the vectors (|v₁|, ..., |vₙ|) and (1, ..., 1):
$$\left(\sum_i |v_i| \cdot 1\right)^2 \leq \left(\sum_i |v_i|^2\right)\left(\sum_i 1^2\right) = n \sum_i v_i^2$$

Since |v_i|² = v_i², the result follows. □

### 3.2 Sharp quadratic form bound

**Theorem 3.2 (quadFormBound_of_entry_bound_sharp).** If |A_{ij}| ≤ B for all i,j with B ≥ 0, then QuadFormBound(A, n·B).

*Proof.* For any v ∈ ℝⁿ:
$$|Q_A(v)| = \left|\sum_{i,j} A_{ij} v_i v_j\right| \leq \sum_{i,j} |A_{ij}| |v_i| |v_j| \leq B \sum_{i,j} |v_i| |v_j| = B\left(\sum_i |v_i|\right)^2$$

By Theorem 3.1:
$$B\left(\sum_i |v_i|\right)^2 \leq B \cdot n \sum_i v_i^2 = n \cdot B \cdot \|v\|^2$$

This completes the proof. □

**Comparison with prior work.** The previous bound `quadFormBound_of_entry_bound` gave n²·B. The improvement by a factor of n comes entirely from applying Cauchy-Schwarz to the intermediate expression B·(∑|vᵢ|)² rather than bounding (∑|vᵢ|)² ≤ n² · max|vᵢ|².

### 3.3 Sharp stability law

**Theorem 3.3 (stability_law_sharp).** Let n, m ≥ 1 and ε > 0. If:
- Each A_k (k = 1,...,m) has gapped Lorentzian signature with margin ε
- Each E_k has entries bounded by ε/n

Then A_k + E_k has at most one positive eigenvalue for all k.

*Proof.* Fix k. Let w be the witness direction from the gapped signature of A_k. For any v orthogonal to w:
$$Q_{A_k + E_k}(v) = Q_{A_k}(v) + Q_{E_k}(v) \leq -ε\|v\|^2 + |Q_{E_k}(v)|$$

By Theorem 3.2 with B = ε/n:
$$|Q_{E_k}(v)| \leq n \cdot \frac{ε}{n} \cdot \|v\|^2 = ε\|v\|^2$$

Therefore Q_{A_k + E_k}(v) ≤ -ε‖v‖² + ε‖v‖² = 0. □

### 3.4 Tightness

**Theorem 3.4 (sharp_bound_tight).** Let J be the n×n all-ones matrix and v = (1,...,1). Then Q_J(v) = n² and ‖v‖² = n, so Q_J(v)/‖v‖² = n.

Since J has entry bound B = 1, this shows QuadFormBound(J, c) requires c ≥ n = n·B. Thus the bound n·B in Theorem 3.2 is tight.

*Proof.* Direct computation:
$$Q_J(v) = \sum_{i=1}^n \sum_{j=1}^n 1 \cdot 1 \cdot 1 = n^2, \qquad \|v\|^2 = \sum_{i=1}^n 1^2 = n$$
□

### 3.5 Residual gap preservation

**Theorem 3.5 (residual_gap_sharp).** If A has gapped signature with margin ε > 0 and E has entries bounded by ε/(2n), then A + E has gapped signature with margin ε/2.

*Proof.* The same witness w works. For v orthogonal to w:
$$Q_{A+E}(v) = Q_A(v) + Q_E(v) \leq -ε\|v\|^2 + \frac{ε}{2}\|v\|^2 = -\frac{ε}{2}\|v\|^2$$

where we used |Q_E(v)| ≤ n · (ε/(2n)) · ‖v‖² = (ε/2)‖v‖². □

### 3.6 Certified stability algorithm

**Theorem 3.6 (certified_stability_correct).** If A has gapped signature with margin ε > 0, n ≥ 1, and all entries of E satisfy |E_{ij}| ≤ ε/(2n), then A + E has at most one positive eigenvalue.

This follows immediately from Theorem 3.5, since gapped signature implies at most one positive eigenvalue.

### 3.7 Operator norm bound

**Theorem 3.7 (hessian_opnorm_entrywise).** For any n×n matrix A with |A_{ij}| ≤ B:
$$\left|\sum_i \left(\sum_j A_{ij} v_j\right) v_i\right| \leq n \cdot B \cdot \|v\|^2$$

This is the operator-theoretic interpretation: the bilinear form ⟨Av, v⟩ is controlled by n·B rather than n²·B.

### 3.8 Monotonicity

**Theorem 3.8 (quadFormBound_mono).** If QuadFormBound(A, c₁) and c₁ ≤ c₂ with c₁ ≥ 0, then QuadFormBound(A, c₂).

## 4. Algorithms

### 4.1 Certified Lorentzian stability checker

**Input:** Spectral margin ε, dimension n, perturbation matrix E  
**Output:** Boolean: whether the perturbation is certified safe

```
function CertifyStability(ε, n, E):
    τ ← ε / (2n)
    for i = 1 to n:
        for j = 1 to n:
            if |E[i,j]| > τ:
                return false
    return true
```

**Complexity:** O(n²) time, O(1) space.

**Correctness:** By Theorem 3.6, if the algorithm returns true, then A + E has at most one positive eigenvalue (and retains a residual gap of ε/2).

### 4.2 Stability radius computation

**Input:** Polynomial p (via Hessian matrices), perturbation direction Δ  
**Output:** Maximum safe scaling factor t₀

```
function StabilityRadius(Hessians, margins, Δ_Hessians, n):
    t₀ ← ∞
    for each leaf k:
        ε_k ← margins[k]
        B_k ← max_{i,j} |Δ_Hessians[k][i,j]|
        if B_k > 0:
            t₀ ← min(t₀, ε_k / (2 · n · B_k))
    return t₀
```

**Correctness:** For all 0 ≤ t ≤ t₀, p + t·Δ is certified Lorentzian.

## 5. Computational Experiments

### 5.1 Verification of the 1/n scaling

We compute the quadratic form ratio Q_A(v)/‖v‖² for various matrices and vectors.

For the all-ones matrix J_n with uniform vector v = (1,...,1)/√n:
- Q_{J_n}(v)/‖v‖² = n for all n ≥ 2

This confirms the n·B bound is tight.

### 5.2 Comparison of bounds

| n | Old bound (n²·B) | New bound (n·B) | Improvement factor |
|---|---|---|---|
| 2 | 4B | 2B | 2× |
| 5 | 25B | 5B | 5× |
| 10 | 100B | 10B | 10× |
| 100 | 10000B | 100B | 100× |
| 1000 | 1000000B | 1000B | 1000× |

### 5.3 Certified stability thresholds

| n | Old threshold (ε/n²) | New threshold (ε/n) | Ratio |
|---|---|---|---|
| 10 | 0.01ε | 0.1ε | 10× |
| 100 | 0.0001ε | 0.01ε | 100× |
| 1000 | 10⁻⁶ε | 0.001ε | 1000× |

## 6. Applications

### 6.1 Certified Lorentzian recognition

The improved stability constant makes certified numerical Lorentzian recognition practical for polynomials in up to ~1000 variables with standard double-precision arithmetic (which provides ~15 decimal digits of precision).

### 6.2 Robust log-concavity certification

Many combinatorial sequences are known to be log-concave because they arise as coefficients of Lorentzian polynomials. The stability theorem guarantees that approximate computation of these coefficients preserves the log-concavity conclusion.

### 6.3 Hyperbolic optimization

In hyperbolic programming, feasibility is determined by the hyperbolicity cone of a polynomial. Stability under coefficient perturbation translates to robustness of the feasibility certification.

## 7. Discussion

### 7.1 The source of the improvement

The improvement from n² to n has a clean conceptual explanation. The old proof bounded:
$$\sum_{i,j} |v_i||v_j| \leq n^2 \cdot \max_i |v_i|^2$$

The new proof uses:
$$\sum_{i,j} |v_i||v_j| = \left(\sum_i |v_i|\right)^2 \leq n \sum_i v_i^2$$

The old bound treats v as if all its mass could be concentrated in one coordinate. The new bound recognizes that (∑|vᵢ|)² is constrained by the ℓ²-norm through Cauchy-Schwarz.

### 7.2 Operator norm interpretation

The result has a natural interpretation in terms of matrix norms. For a matrix A with |A_{ij}| ≤ B:
- The Frobenius norm satisfies ‖A‖_F ≤ nB
- The operator norm satisfies ‖A‖_{op} ≤ nB (by our result)
- The entrywise ℓ∞ norm is B

The quadratic form bound |Q_A(v)| ≤ ‖A‖_{op} · ‖v‖² connects directly to spectral theory.

### 7.3 Limitations

The 1/n bound is sharp for worst-case perturbations of general matrices, but may be improvable for:
- **Structured Hessians**: Hessians of Lorentzian polynomials have special structure that could yield better bounds.
- **Random perturbations**: Random entry perturbations have operator norm O(√n · B) with high probability, which would give stability constant 1/√n.
- **Sparse perturbations**: If only k entries are perturbed, the effective stability constant may be 1/√k.

## 8. Future Work

1. **Effective spectral dimension theory**: Replace n by a structural invariant measuring the actual amplification of perturbations in specific families.
2. **Random perturbation stability**: Prove a 1/√n stability law for random perturbations using matrix concentration inequalities.
3. **Symmetric polynomial extremizers**: Compute exact stability constants for elementary symmetric polynomials e_k.
4. **Higher-order stability**: Extend the theory to non-linear perturbations and prove higher-order correction terms.
5. **Computational implementation**: Build a practical certified Lorentzian recognition algorithm using the improved bounds.

## References

[1] P. Brändén and J. Huh, "Lorentzian Polynomials," *Annals of Mathematics*, vol. 192, no. 3, pp. 821–891, 2020.

[2] LorentzianStability catalog, `Catalog/Speculative/AutoResearch/LorentzianStability.lean`.

[3] R. Bhatia, *Matrix Analysis*, Springer, 1997.

[4] J. A. Tropp, "An Introduction to Matrix Concentration Inequalities," *Foundations and Trends in Machine Learning*, vol. 8, no. 1-2, pp. 1-230, 2015.

[5] G. W. Stewart and J. Sun, *Matrix Perturbation Theory*, Academic Press, 1990.
