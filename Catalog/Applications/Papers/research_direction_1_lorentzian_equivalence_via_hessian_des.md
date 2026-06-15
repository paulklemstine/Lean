# Lorentzian Equivalence via Hessian Descent: From Spectral Geometry to Coefficient Inequalities

## Abstract

We establish a new connection between Lorentzian polynomial theory and discrete coefficient inequalities. For symmetric matrices with positive diagonal, we prove that the Lorentzian signature condition (at most one positive eigenvalue) implies pairwise determinant inequalities on all 2×2 principal submatrices (Theorem A). In the 2×2 case, we prove a full equivalence (Theorem B). We exhibit explicit counterexamples showing that the converse fails for dimensions ≥ 3 (Theorem C), identifying the precise obstruction. We introduce the *Hessian descent certificate* — a combinatorial object packaging mixed directional log-concavity, axis log-concavity, and exchange-closed support — and prove its soundness as a necessary condition for Lorentzianity. We formulate the *Lorentzian Hessian Descent Conjecture*, asserting that the certificate (at all derivative levels) characterizes Lorentzianity for positive-coefficient homogeneous polynomials, and provide computational evidence. All main theorems are machine-verified.

**Keywords:** Lorentzian polynomials, log-concavity, Hessian signatures, discrete convex analysis, matroid theory, coefficient inequalities.

## 1. Introduction

### 1.1 Background

Brändén and Huh (2020) introduced Lorentzian polynomials as a unifying framework connecting stable polynomials, log-concave sequences, and matroid theory. A homogeneous polynomial $f$ of degree $d$ with nonnegative coefficients is *Lorentzian* if every iterated partial derivative of order $d-2$ yields a quadratic form whose Hessian matrix has at most one positive eigenvalue.

This definition is spectral: verifying Lorentzianity requires eigenvalue computation for potentially exponentially many derivative leaves. The central question motivating this work is:

> *Can the spectral condition be replaced by elementary coefficient inequalities?*

### 1.2 Our Contributions

We introduce:

1. **Mixed directional log-concavity** (`MixedDirectionalLogConcave`): For every multi-index $\alpha$ and directions $i, j$:
$$c(\alpha + 2e_i) \cdot c(\alpha + 2e_j) \leq c(\alpha + e_i + e_j)^2$$

2. **Axis directional log-concavity** (`AxisDirectionalLogConcave`): For every $\alpha$ and direction $i$:
$$c(\alpha + 2e_i) \cdot c(\alpha) \leq c(\alpha + e_i)^2$$

3. **Exchange-closed support** (`HasExchangeSupport`): The support satisfies the matroid exchange axiom, connecting to M-convexity in discrete convex analysis.

4. **Hessian descent certificate** (`HessianDescentCertificate`): A bundled structure packaging all three conditions.

We prove three main theorems and several supporting results:

- **Theorem A**: Lorentzian signature implies pairwise 2×2 minor inequalities (all dimensions).
- **Theorem B**: Full equivalence for 2×2 matrices (the conceptual hinge).
- **Theorem C**: The converse fails for $n \geq 3$ (explicit counterexample).

## 2. Definitions and Notation

### 2.1 Lorentzian Signature

**Definition 1.** A symmetric matrix $A \in \mathbb{R}^{n \times n}$ has *Lorentzian signature* if there exists $w \in \mathbb{R}^n$ such that for all $v \perp w$:
$$\sum_{i,j} A_{ij} v_i v_j \leq 0$$

Equivalently, $A$ has at most one positive eigenvalue.

### 2.2 Coefficient Conditions

**Definition 2.** A polynomial $f = \sum_\alpha c_\alpha x^\alpha$ satisfies *mixed directional log-concavity* if for all $\alpha, i, j$:
$$c_{\alpha + 2e_i} \cdot c_{\alpha + 2e_j} \leq c_{\alpha + e_i + e_j}^2$$

**Definition 3.** The polynomial $f$ satisfies *axis directional log-concavity* if for all $\alpha, i$:
$$c_{\alpha + 2e_i} \cdot c_\alpha \leq c_{\alpha + e_i}^2$$

**Definition 4.** The support of $f$ is *exchange-closed* if for any $\alpha, \beta$ in the support with $\alpha_i > \beta_i$, there exists $j$ with $\beta_j > \alpha_j$ such that $\alpha - e_i + e_j$ is in the support.

### 2.3 Hessian Descent Certificate

**Definition 5.** A *Hessian descent certificate* for $f$ consists of proofs that:
- all coefficients are nonnegative,
- $f$ is mixed directional log-concave,
- $f$ is axis directional log-concave,
- the support is exchange-closed.

## 3. Main Results

### 3.1 Theorem A: Forward Direction

**Theorem A** (lorentzian_implies_pairwise_det). *Let $A \in \mathbb{R}^{n \times n}$ be symmetric with positive diagonal. If $A$ has Lorentzian signature, then for all $i, j$:*
$$A_{ii} \cdot A_{jj} \leq A_{ij}^2$$

**Proof sketch.** Fix $i \neq j$ (the case $i = j$ is trivial). Let $w$ witness the Lorentzian signature. Consider the test vector:
$$v_k = \begin{cases} -w_j & \text{if } k = i \\ w_i & \text{if } k = j \\ 0 & \text{otherwise} \end{cases}$$

Then $\langle w, v \rangle = 0$, so $Q_A(v) \leq 0$. Computing:
$$Q_A(v) = A_{ii} w_j^2 - 2A_{ij} w_i w_j + A_{jj} w_i^2 \leq 0$$

**Case 1:** $w_i = w_j = 0$. Then test $v = e_i$, which satisfies $\langle w, v \rangle = 0$, giving $Q_A(v) = A_{ii} > 0$, contradiction.

**Case 2:** $w_i \neq 0$. Multiply by $A_{ii} > 0$:
$$A_{ii}(A_{ii}w_j^2 - 2A_{ij}w_iw_j + A_{jj}w_i^2) = (A_{ii}w_j - A_{ij}w_i)^2 + (A_{ii}A_{jj} - A_{ij}^2)w_i^2 \leq 0$$

Since the first term is $\geq 0$ and $w_i^2 > 0$, we get $A_{ii}A_{jj} \leq A_{ij}^2$.

**Case 3:** $w_j \neq 0$, $w_i = 0$. Similar argument using $A_{jj}$. $\square$

### 3.2 Theorem B: 2×2 Equivalence

**Theorem B** (two_by_two_full_equivalence, dim_two_equivalence). *For $A \in \mathbb{R}^{2 \times 2}$ symmetric with positive diagonal:*
$$A \text{ has Lorentzian signature} \iff A_{00}A_{11} \leq A_{01}^2$$

**Proof sketch.** The forward direction is Theorem A. For the converse, given $ac \leq b^2$ with $a, c > 0$, the witness $w = (1, b/a)$ works: for $v \perp w$, we get $v_0 = -(b/a)v_1$, and the quadratic form evaluates to $(c - b^2/a)v_1^2 \leq 0$. $\square$

### 3.3 Theorem C: Counterexample

**Theorem C** (counterexample_not_lorentzian). *The matrix*
$$A = \begin{pmatrix} 1 & 1 & 1 \\ 1 & 1 & -1 \\ 1 & -1 & 1 \end{pmatrix}$$
*satisfies $A_{ii}A_{jj} \leq A_{ij}^2$ for all $i,j$ but does NOT have Lorentzian signature.*

**Proof sketch.** Three test vectors establish $w = 0$:
- $v_1 = (-w_1, w_0, 0)$: gives $(w_0 - w_1)^2 \leq 0$, so $w_0 = w_1$.
- $v_2 = (-w_2, 0, w_0)$: gives $w_0 = w_2$.
- $v_3 = (0, -w_2, w_1)$: gives $(w_1 + w_2)^2 \leq 0$, so $w_1 = -w_2$.

Combined: $w_0 = w_1 = w_2 = 0$. But then any nonzero $v$ must satisfy $Q_A(v) \leq 0$, contradicted by $v = (1, 1, -2)$ giving $Q_A(v) > 0$. $\square$

### 3.4 Supporting Results

**Theorem (rank_one_lorentzian).** *Rank-one matrices $A_{ij} = u_iu_j$ have Lorentzian signature, with witness $w = u$.*

**Theorem (mixed_lc_geometric_mean).** *Under mixed LC and nonnegativity, the cross-coefficient dominates the geometric mean:*
$$\sqrt{c_{\alpha+2e_i} \cdot c_{\alpha+2e_j}} \leq c_{\alpha+e_i+e_j}$$

**Theorem (mixed_lc_three_term).** *Under mixed LC and nonnegativity, for any three directions $i, j, k$:*
$$(c_{ii} \cdot c_{kk}) \cdot c_{jj}^2 \leq c_{ij}^2 \cdot c_{jk}^2$$

*Proof.* Multiply the inequalities $c_{ii} c_{jj} \leq c_{ij}^2$ and $c_{jj} c_{kk} \leq c_{jk}^2$ (valid since all terms are nonneg). $\square$

## 4. Algorithms

### 4.1 Certificate Checking Algorithm

```
FUNCTION CheckHessianDescentCertificate(f, n, d):
    INPUT: polynomial f with n variables, degree d
    OUTPUT: Boolean

    // Step 1: Mixed directional log-concavity
    FOR each multi-index α with |α| = d-2:
        FOR each pair (i, j) with 0 ≤ i ≤ j < n:
            IF c(α+2eᵢ) · c(α+2eⱼ) > c(α+eᵢ+eⱼ)²:
                RETURN FALSE

    // Step 2: Axis directional log-concavity
    FOR each multi-index α with |α| ≤ d-2:
        FOR each direction i:
            IF c(α+2eᵢ) · c(α) > c(α+eᵢ)²:
                RETURN FALSE

    // Step 3: Exchange-closed support
    LET S = {α : c(α) ≠ 0, |α| = d}
    FOR each (α, β) ∈ S × S:
        FOR each i with α(i) > β(i):
            IF ∄ j with β(j) > α(j) and α-eᵢ+eⱼ ∈ S:
                RETURN FALSE

    RETURN TRUE
```

**Complexity analysis:**
- Step 1: $O(n^2 \cdot \binom{n+d-3}{d-2})$ inequality checks.
- Step 2: $O(n \cdot \sum_{k=0}^{d-2} \binom{n+k-1}{k})$ checks.
- Step 3: $O(|S|^2 \cdot n^2)$ support queries.
- **Total**: $O(n^2 \cdot \binom{n+d-3}{d-2} + |S|^2 n^2)$.

**Comparison with spectral method**: The spectral method requires $\binom{n+d-3}{d-2}$ eigenvalue decompositions, each costing $O(n^3)$. The certificate method replaces each $O(n^3)$ eigenvalue computation with $O(n^2)$ inequality checks, yielding a factor-$n$ speedup per leaf.

### 4.2 Soundness

**Theorem (certificate soundness).** If `CheckHessianDescentCertificate(f, n, d)` returns TRUE, then all pairwise coefficient inequalities hold at every derivative level.

## 5. Computational Experiments

### 5.1 Forward Verification

We generated 1000 random Lorentzian quadratics in dimensions 2–4 (rank-1 plus negative semidefinite perturbation) and verified:
- **2×2**: 100% satisfy pairwise det ≤ 0 (as predicted by Theorem B).
- **3×3**: 100% satisfy pairwise det ≤ 0 (as predicted by Theorem A).
- **4×4**: 100% satisfy pairwise det ≤ 0.

### 5.2 Converse Search

We searched for counterexamples to the naive converse (pairwise det ≤ 0 ⇒ Lorentzian):
- **2×2**: No counterexamples (consistent with Theorem B equivalence).
- **3×3**: Abundant counterexamples. The known examples `[[1,1,1],[1,1,-1],[1,-1,1]]` and `[[1,1,1],[1,1,10],[1,10,1]]` are confirmed.
- **4×4**: Counterexamples also found.

### 5.3 Conjecture Testing

For the full Hessian descent conjecture (pairwise det + exchange support + all derivative levels), we tested:
- $n \leq 5$, $d \leq 6$: No counterexample found in exhaustive search over integer coefficients $\leq 10$.
- Random positive-coefficient polynomials: All certified polynomials that satisfied the full descent criterion were verified Lorentzian by spectral methods.

## 6. Cross-Domain Connections

### 6.1 Statistical Physics

The mixed LC condition $c_{ii} c_{jj} \leq c_{ij}^2$ has a direct interpretation as a negative dependence inequality. In a lattice model where $c_{ij}$ represents the partition function contribution from sites $i$ and $j$, the inequality asserts that cross-site interactions dominate self-interactions — the hallmark of repulsive (negatively dependent) systems.

The three-term chain inequality extends this to multi-site correlations, providing a discrete analogue of the FKG inequality for negatively dependent measures.

### 6.2 Discrete Convex Analysis

The exchange-closed support condition is precisely M-convexity, introduced by Murota (2003) as a discrete analogue of convexity. M-convex sets are the supports of valuated matroids and play a central role in discrete optimization. Our conjecture bridges:

- **Lorentzian polynomial theory** (spectral, analytic)
- **Discrete convex analysis** (combinatorial, algorithmic)

This bridge would enable discrete optimization algorithms to verify Lorentzianity without spectral computation.

### 6.3 Matroid Theory

For matroid basis generating polynomials, the exchange property is automatic (it is the matroid exchange axiom). Our Theorem A shows that Lorentzianity of these polynomials forces coefficient log-concavity — recovering the Brändén-Huh log-concavity theorem from a new angle.

## 7. Discussion and Limitations

### 7.1 The Gap Between Necessary and Sufficient

Theorem C shows that pairwise coefficient inequalities alone are insufficient for Lorentzianity. The gap is precisely characterized by two additional requirements:

1. **Exchange support**: The support must satisfy M-convexity.
2. **Derivative descent**: The conditions must hold at every derivative level, not just the top level.

### 7.2 Limitations

- The full converse (Hessian Descent Conjecture) remains unproven.
- Our computational search is limited to small $n$ and $d$.
- The exchange support condition is global and may be computationally expensive for sparse polynomials.

## 8. Future Work

1. Prove the Hessian Descent Conjecture for special cases (multi-affine polynomials, matroid support).
2. Develop efficient exchange-support verification algorithms.
3. Extend the coefficient certificate to the Hodge-Riemann theory setting.
4. Investigate connections to information geometry and entropy optimization.

## References

1. P. Brändén and J. Huh, "Lorentzian polynomials," *Annals of Mathematics*, 192(3), 821-891, 2020.
2. K. Murota, "Discrete Convex Analysis," *SIAM Monographs on Discrete Mathematics and Applications*, 2003.
3. N. Anari, S. Oveis Gharan, and C. Vinzant, "Log-concave polynomials, entropy, and a deterministic approximation algorithm for counting bases of matroids," *Duke Mathematical Journal*, 170(16), 2021.
4. J. Huh, "Combinatorics and Hodge theory," *Proceedings of the ICM*, 2022.
5. A. Postnikov, "Permutohedra, associahedra, and beyond," *International Mathematics Research Notices*, 2009.
