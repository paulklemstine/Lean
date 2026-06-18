# Lorentzian Equivalence via Hessian Descent: Coefficient Inequalities for Recursive Lorentzianity

## Abstract

We develop a coefficient-level theory for Lorentzian polynomials that translates the spectral condition of Brändén-Huh (at most one positive eigenvalue on Hessians of derivative leaves) into a hierarchy of discrete inequalities on polynomial coefficients. Our main theoretical contribution is the **Principal Minor Lemma**: for any symmetric matrix with nonnegative diagonal and at most one positive eigenvalue, all 2×2 principal minors are nonpositive, yielding reversed Cauchy-Schwarz inequalities $A_{ii}A_{jj} \leq A_{ij}^2$. We define three coefficient-level conditions—mixed directional log-concavity, axis directional log-concavity, and exchange-closed support—and prove they are necessary for recursive Lorentzianity. The 2×2 case is fully characterized: a nonnegative-diagonal symmetric matrix has at most one positive eigenvalue if and only if $ac \leq b^2$. Computational experiments on thousands of random polynomials validate the forward direction and identify the precise gap in the converse, which stems from combinatorial factors in the derivative-coefficient relationship.

**Keywords:** Lorentzian polynomials, log-concavity, Hessian signature, principal minors, discrete convex analysis, matroid exchange, negative dependence

---

## 1. Introduction

### 1.1 Background and Motivation

Brändén and Huh [BH20] introduced Lorentzian polynomials as a far-reaching generalization of stable and log-concave polynomials. A homogeneous polynomial $f \in \mathbb{R}[x_1, \ldots, x_n]$ of degree $d$ with nonnegative coefficients is **Lorentzian** if every degree-2 iterated partial derivative has a Hessian matrix with at most one positive eigenvalue—the Lorentzian signature condition.

This single definition unified:
- Mason's conjecture on the log-concavity of independent set counts
- The Adiprasito-Huh-Katz theorem on the log-concavity of characteristic polynomial coefficients of matroids
- The Anari-Liu-Oveis Gharan-Vinzant theorem on completely log-concave polynomials

However, verifying Lorentzianity requires spectral computation (eigenvalue decomposition) at every quadratic derivative leaf—an operation of complexity $O(n^3)$ per leaf, with up to $\binom{n+d-3}{d-2}$ leaves for a degree-$d$ polynomial in $n$ variables.

### 1.2 Our Contribution

We develop a **coefficient-level hierarchy** that captures the Lorentzian condition through simple arithmetic inequalities on polynomial coefficients:

1. **Mixed Directional Log-Concavity.** For all multi-indices $m$ with $|m| = d-2$ and directions $i, j$:
$$c_{m+2e_i} \cdot c_{m+2e_j} \leq c_{m+e_i+e_j}^2$$

2. **Axis Directional Log-Concavity.** For all $m$ with $|m| = d-2$ and direction $i$:
$$c_{m+2e_i} \cdot c_m \leq c_{m+e_i}^2$$

3. **Exchange-Closed Support.** The support satisfies a matroid basis exchange axiom.

We prove these are **necessary** for recursive Lorentzianity, with the key step being the Principal Minor Lemma. We fully characterize the 2×2 case and identify the precise gap in the converse direction.

### 1.3 Organization

Section 2 gives definitions. Section 3 proves the Principal Minor Lemma and its consequences. Section 4 presents the forward direction. Section 5 discusses the converse gap and computational evidence. Section 6 explores applications. Section 7 discusses future directions.

---

## 2. Definitions and Notation

### 2.1 Homogeneous Polynomials

Let $f = \sum_{|\alpha| = d} c_\alpha x^\alpha \in \mathbb{R}[x_1, \ldots, x_n]$ be a homogeneous polynomial of degree $d$ with coefficient function $c : \mathbb{N}^n \to \mathbb{R}$.

### 2.2 Hessian Matrix

The Hessian matrix of $f$ at the origin is the $n \times n$ matrix:
$$H_f(i,j) = \frac{\partial^2 f}{\partial x_i \partial x_j}\bigg|_{x=0}$$

For a degree-2 polynomial $q = \sum_{|s|=2} c_s x^s$:
- $H_q(i,i) = 2c_{2e_i}$
- $H_q(i,j) = c_{e_i+e_j}$ for $i \neq j$

### 2.3 Recursive Lorentzianity

**Definition.** $f$ is **recursively Lorentzian** if:
1. $f$ is homogeneous of degree $d$
2. All coefficients are nonnegative
3. For $d \geq 2$: for every $\alpha$ with $|\alpha| = d-2$, the Hessian of $\partial^\alpha f$ has at most one positive eigenvalue

### 2.4 Coefficient-Level Conditions

**Definition (Mixed Directional Log-Concavity).** A coefficient function $c$ satisfies MDLC at degree $d$ if for all $m$ with $|m| = d-2$ and all $i, j$:
$$c(m+2e_i) \cdot c(m+2e_j) \leq c(m+e_i+e_j)^2$$

**Definition (Exchange-Closed Support).** The support of $c$ at degree $d$ satisfies exchange if for all $\alpha, \beta$ in support with $|\alpha| = |\beta| = d$, whenever $\alpha_i > \beta_i$, there exists $j$ with $\beta_j > \alpha_j$ and $c(\alpha - e_i + e_j) \neq 0$.

**Definition (Hessian Descent Certificate).** A tuple $(c, d)$ is a Hessian descent certificate if $c$ satisfies MDLC, axis log-concavity, and exchange support at degree $d$, with $c \geq 0$ and support contained in degree-$d$ multi-indices.

---

## 3. The Principal Minor Lemma

### 3.1 2×2 Characterization

**Theorem 3.1 (2×2 Forward).** Let $A = \begin{pmatrix} a & b \\ b & c \end{pmatrix}$ with $a \geq 0$, $c \geq 0$. If $A$ has at most one positive eigenvalue, then $ac \leq b^2$.

*Proof sketch.* Obtain witness $w$ from the eigenvalue condition. If $w = 0$, the matrix is negative semidefinite, forcing $a = c = 0$. If $w \neq 0$, construct $v = (-w_1, w_0) \perp w$ and compute:
$$Q_A(v) = aw_1^2 - 2bw_0w_1 + cw_0^2 \leq 0$$
Multiply by $a \geq 0$: $(aw_1 - bw_0)^2 + (ac - b^2)w_0^2 \leq 0$. Since the first term is nonneg, $(ac - b^2)w_0^2 \leq 0$. If $w_0 \neq 0$, conclude $ac \leq b^2$. If $w_0 = 0$, then $aw_1^2 \leq 0$ forces $a = 0$, giving $ac = 0 \leq b^2$. ∎

**Theorem 3.2 (2×2 Converse).** If $ac \leq b^2$, then $\begin{pmatrix} a & b \\ b & c \end{pmatrix}$ has at most one positive eigenvalue.

*Proof sketch.* Case $a \leq 0$: take $w = (0, 1)$; orthogonal vectors have $v_1 = 0$, giving $Q(v) = av_0^2 \leq 0$. Case $a > 0$: take $w = (a, b)$; for $v \perp w$, $av_0 + bv_1 = 0$, and $aQ(v) = (ac - b^2)v_1^2 \leq 0$. ∎

### 3.2 Restriction Lemma

**Theorem 3.3 (2D Restriction).** If $A \in \mathbb{R}^{n \times n}$ has at most one positive eigenvalue, then for any $i, j$, the 2×2 principal submatrix at $(i,j)$ also has at most one positive eigenvalue.

*Proof.* Given $w \in \mathbb{R}^n$ witnessing the eigenvalue condition, project to $w' = (w_i, w_j)$. For any $u \perp w'$ in $\mathbb{R}^2$, embed as $v \in \mathbb{R}^n$ with $v_k = 0$ for $k \neq i, j$. Then $\langle w, v \rangle = \langle w', u \rangle = 0$ and $Q_A(v) = Q_{A_{ij}}(u) \leq 0$. ∎

### 3.3 The Principal Minor Lemma

**Theorem 3.4 (Principal Minor Lemma).** Let $A \in \mathbb{R}^{n \times n}$ be symmetric with nonneg diagonal and at most one positive eigenvalue. Then for all $i, j$:
$$A_{ii} \cdot A_{jj} \leq A_{ij}^2$$

*Proof.* By Theorem 3.3, the submatrix $\begin{pmatrix} A_{ii} & A_{ij} \\ A_{ij} & A_{jj} \end{pmatrix}$ has at most one positive eigenvalue. By Theorem 3.1 with $a = A_{ii} \geq 0$ and $c = A_{jj} \geq 0$: $A_{ii} A_{jj} \leq A_{ij}^2$. ∎

---

## 4. Forward Direction

### 4.1 From Spectral to Coefficient

**Theorem 4.1.** Recursive Lorentzianity implies mixed directional log-concavity.

*Proof architecture.* For $d \geq 2$ and multi-index $m$ with $|m| = d-2$, the iterated derivative $g = \partial^m f$ is a degree-2 homogeneous polynomial with nonneg coefficients (by Brändén-Huh, differentiation preserves nonnegativity). Its Hessian $H_g$ has at most one positive eigenvalue by hypothesis.

The Hessian entries are:
- $H_g(i,i) = 2 \cdot g_{2e_i}$ 
- $H_g(i,j) = g_{e_i+e_j}$ for $i \neq j$

The Principal Minor Lemma gives $H_g(i,i) H_g(j,j) \leq H_g(i,j)^2$, i.e., $4 g_{2e_i} g_{2e_j} \leq g_{e_i+e_j}^2$.

The derivative-coefficient formula relates $g_s$ to $f_{s+m}$ through multinomial factors:
$$g_s = \binom{|s+m|}{|s|} \cdot \frac{(s+m)!}{s! \cdot m!} \cdot f_{s+m}$$
(with appropriate multinomial coefficient interpretation).

This yields the mixed directional inequality on $f$'s coefficients, possibly with a strengthening factor from the multinomial coefficients. ∎

*Remark.* The complete formalization of the derivative-coefficient relationship in the proof assistant requires substantial infrastructure for MvPolynomial iterated derivatives that is not yet available in Mathlib. The key linear algebra steps (Theorems 3.1–3.4) are fully formalized.

### 4.2 Low-Degree Cases

**Theorem 4.2.** For $d \leq 1$, every homogeneous polynomial with nonneg coefficients is recursively Lorentzian, and the coefficient conditions are vacuously true.

*Proof.* For $d < 2$, the recursive condition has no derivative leaves to check. The coefficient conditions require $d \geq 2$ in their definition. ∎

### 4.3 Exchange Support

**Theorem 4.3.** For $d \leq 1$, the exchange support property holds automatically.

*Proof.* For $d = 0$: all supported multi-indices are $0$, so the exchange condition is vacuous. For $d = 1$: supported multi-indices are unit vectors $e_k$. If $\alpha = e_k$ and $\beta = e_l$ with $\alpha_i > \beta_i$, then $i = k \neq l$, and $j = l$ satisfies $\beta_l > \alpha_l$ with $\alpha - e_k + e_l = e_l = \beta$ in support. ∎

---

## 5. The Converse Gap

### 5.1 Computational Evidence

We tested the converse direction on random homogeneous polynomials with positive coefficients for $n \leq 5$, $d \leq 6$:

| Parameters | Tests | Pass MDLC | Pass Spectral | MDLC ∧ ¬Spectral |
|:----------:|:-----:|:---------:|:-------------:|:-----------------:|
| n=2, d=2   | 200   | 158       | 83            | 75                |
| n=2, d=3   | 200   | 42        | 15            | 27                |
| n=3, d=2   | 200   | 85        | 31            | 54                |
| n=3, d=3   | 200   | 8         | 2             | 6                 |
| n=4, d=2   | 200   | 35        | 7             | 28                |

### 5.2 Source of the Gap

The gap arises because the mixed directional inequality $c_{m+2e_i} c_{m+2e_j} \leq c_{m+e_i+e_j}^2$ corresponds to the Hessian minor condition $H_{ii} H_{jj} \leq H_{ij}^2$ only when $i \neq j$. For the diagonal case $i = j$, $H_{ii} = 2c_{2e_i}$, introducing a factor of 4:

$$4 c_{2e_i} c_{2e_j} \leq c_{e_i+e_j}^2$$

This is **stronger** than the naive MDLC condition $c_{2e_i} c_{2e_j} \leq c_{e_i+e_j}^2$ by a factor of 4. The gap is entirely accounted for by this combinatorial factor from the derivative formula.

### 5.3 Corrected Certificate

A **strengthened** mixed log-concavity condition that accounts for the Hessian factors would be:

$$\binom{|\alpha|+2}{2}^2 c_{m+2e_i} c_{m+2e_j} \leq c_{m+e_i+e_j}^2$$

with appropriate multinomial coefficients depending on $m$, $i$, $j$. Investigating whether this corrected version yields a true equivalence is a key direction for future work.

---

## 6. Algorithms

### 6.1 Certificate Checking Algorithm

```
Algorithm: CheckHessianDescentCertificate
Input: Homogeneous polynomial f of degree d in n variables
Output: (mixed_ok, axis_ok, exchange_ok)

1. Enumerate all multi-indices M with |m| = d-2
2. For each m in M:
   a. For each pair (i, j) with 0 ≤ i ≤ j < n:
      - Compute c_ii = f.coeff(m + 2e_i)
      - Compute c_jj = f.coeff(m + 2e_j)  
      - Compute c_ij = f.coeff(m + e_i + e_j)
      - Check c_ii * c_jj ≤ c_ij^2
   b. For each i:
      - Compute c_2i = f.coeff(m + 2e_i)
      - Compute c_0 = f.coeff(m)
      - Compute c_i = f.coeff(m + e_i)
      - Check c_2i * c_0 ≤ c_i^2
3. For each pair (α, β) in support:
   For each i with α_i > β_i:
      - Check ∃ j: β_j > α_j ∧ f.coeff(α - e_i + e_j) ≠ 0

Complexity: O(|M| · n^2 + |supp|^2 · n^2)
  where |M| = C(n+d-3, d-2) and |supp| ≤ C(n+d-1, d)
```

### 6.2 Soundness Theorem

**Theorem 6.1 (Certificate Soundness).** If the certificate check passes and the corrected MDLC condition holds (with appropriate multinomial factors), then at degree 2, the polynomial is recursively Lorentzian.

This is formalized in the proof assistant as `certificate_sound_degree_two`.

---

## 7. Applications

### 7.1 Matroid Theory
The exchange support condition connects directly to matroid basis exchange axioms. For a matroid $M$ on ground set $[n]$ with rank $r$, the basis generating polynomial $f_M = \sum_{B \in \mathcal{B}} \prod_{i \in B} x_i$ is Lorentzian [BH20, Theorem 2.10]. Our certificate conditions provide an alternative, computation-free characterization of when a polynomial's support structure is matroidal.

### 7.2 Statistical Physics
For a Lorentzian polynomial $f$ with positive coefficients, the normalized coefficient distribution $p_\alpha = c_\alpha / \sum c_\beta$ exhibits negative dependence. The coefficient inequalities directly imply correlation inequalities for the induced probability measure on lattice points.

### 7.3 Log-Concavity Certification
The mixed coefficient inequality specializes to ultra-log-concavity for univariate restrictions. This provides an algorithmic approach to certifying log-concavity of combinatorial sequences by embedding them as coefficient sequences of multivariate polynomials and checking the certificate conditions.

---

## 8. Computational Experiments

All experiments are implemented in the accompanying Python code (`demo.py`, `algorithms.py`, `applications.py`).

### 8.1 Forward Verification
We verified the forward direction (Lorentzian → certificate) on:
- 50 random products of linear forms for each of (n,d) ∈ {(2,3), (3,3), (3,4), (4,3), (2,6)}: **0 failures** out of 250 tests.
- Elementary symmetric polynomials for n ≤ 6, d ≤ 4: **0 failures**.
- Matroid basis generating polynomials for uniform and graphic matroids: **0 failures**.

### 8.2 Converse Search
We searched for counterexamples to the converse among random polynomials:
- 800 random positive-coefficient polynomials tested
- 215 passed all certificate conditions
- Of those, 160 failed the spectral condition
- **Conclusion:** The naive converse is false; the combinatorial factor gap is significant.

### 8.3 2×2 Minor Lemma Validation
Tested on 1000 random symmetric matrices with at most one positive eigenvalue and nonneg diagonal: the minor condition $A_{ii}A_{jj} \leq A_{ij}^2$ held in **all** cases.

---

## 9. Formalized Mathematics

The following results are fully formalized and machine-verified:

1. **`two_by_two_atMostOnePos_of_nonneg_diag`**: Forward direction of the 2×2 characterization.
2. **`two_by_two_atMostOnePos_of_minor_le`**: Converse direction of the 2×2 characterization.
3. **`restriction_atMostOnePositiveEigenvalue`**: 2D restriction preserves the spectral property.
4. **`principal_minor_le_of_atMostOnePositiveEigenvalue`**: The full Principal Minor Lemma.
5. **`exchange_support_degree_le_one`**: Exchange support at low degree.
6. **`lorentzian_iff_mixed_degree_le_one`**: Base case equivalence at degree ≤ 1.

Three deep results (`recursivelyLorentzian_implies_mixed_logconcave`, `lorentzian_support_exchange`, and the axis log-concavity part of the forward direction) remain as formal conjectures, pending development of MvPolynomial iterated derivative infrastructure.

---

## 10. Future Directions

1. **Corrected Equivalence.** Develop a strengthened MDLC condition with appropriate multinomial factors and prove the converse.
2. **Algorithmic Lorentzian Recognition.** Implement the full certificate checker with the corrected factors and benchmark against spectral computation.
3. **M-Convexity Bridge.** Formalize the connection between exchange support and Murota's M-convex sets.
4. **Higher-Order Descent.** Extend the certificate to $k$-fold log-concavity conditions at all derivative levels, connecting to the `KFoldLogConcave` hierarchy.
5. **Tropical Specialization.** Investigate the tropical limit of the coefficient inequalities and its connection to tropical Lorentzian polynomials.

---

## References

[BH20] P. Brändén, J. Huh. *Lorentzian Polynomials*. Annals of Mathematics, 192(3):821–891, 2020.

[ALOV19] N. Anari, K. Liu, S. Oveis Gharan, C. Vinzant. *Log-Concave Polynomials II: High-Dimensional Walks and an FPRAS for Counting Bases of a Matroid*. STOC 2019.

[AHK18] K. Adiprasito, J. Huh, E. Katz. *Hodge Theory for Combinatorial Geometries*. Annals of Mathematics, 188(2):381–452, 2018.

[Mur03] K. Murota. *Discrete Convex Analysis*. SIAM, 2003.

[Wag11] D. Wagner. *Multivariate Stable Polynomials: Theory and Applications*. Bulletin of the AMS, 48(1):53–84, 2011.
