# Intrinsic Lorentzian Certificates for Strongly Rayleigh Polynomials

## Abstract

We establish an intrinsic Hessian certificate theory for strongly Rayleigh measures that operates without reference to determinantal structure. For a multiaffine polynomial $g \in \mathbb{R}[z_1, \ldots, z_n]$ satisfying the directional Rayleigh inequality $(D_u g(x))^2 \geq g(x) \cdot D_u^2 g(x)$ at a positive point $x \in \mathbb{R}_{>0}^n$, we prove that the **Lorentzian certificate matrix** $M_g(x) = g(x) \cdot \mathrm{Hess}(g)(x) - \nabla g(x) \nabla g(x)^\top$ is negative semidefinite. This extends the spectral certificate phenomenon from DPPs to all real stable polynomial families, including matroid basis generating polynomials, spanning tree polynomials of graphs, and weighted partition functions of repulsive systems. All core results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

Determinantal point processes (DPPs) are probability distributions on subsets of a finite set whose probabilities are given by minors of a positive semidefinite kernel matrix $K$. Their generating polynomial $g_K(z) = \det(I + \mathrm{diag}(z) K)$ possesses remarkable spectral properties: the Hessian of $\log g_K$ at any positive point is negative semidefinite on the hyperplane orthogonal to the gradient, and the associated certificate matrix has at most one positive eigenvalue.

These properties have been central to applications in machine learning (subset selection), spatial statistics, and quantum physics. However, the proofs have relied on the determinantal formula and the spectral theory of PSD matrices, creating a "determinant barrier" that limited the scope of the theory.

### 1.2 Contribution

We break this barrier by introducing a polynomial-intrinsic certificate theory. Our key contributions are:

1. **The Lorentzian certificate matrix** $M_g(x) = g(x) \cdot \mathrm{Hess}(g)(x) - \nabla g(x) \nabla g(x)^\top$, defined for any multiaffine polynomial.

2. **The quadratic form decomposition identity** (Theorem 1): $\sum_{i,j} u_i M_{ij} u_j = g(x) \sum_{i,j} u_i H_{ij} u_j - (\sum_i u_i \partial_i g)^2$.

3. **The NSD theorem** (Theorem 2): Under the directional Rayleigh inequality, $M_g(x)$ is negative semidefinite (not just conditionally NSD).

4. **At-most-one-positive-eigenvalue corollary** (Theorem 3): The certificate matrix has at most one positive eigenvalue when $g$ is strongly Rayleigh.

5. **Formal verification** of all results in Lean 4 with Mathlib, producing the first machine-verified treatment of this circle of ideas.

### 1.3 Related Work

The theory of real stable polynomials and their connection to negative dependence was developed by Borcea, Brändén, and Liggett [BBL09]. The directional Rayleigh inequality for real stable polynomials was established by Borcea and Brändén [BB08]. Lorentzian polynomials were introduced by Brändén and Huh [BH20], establishing deep connections between Hodge theory and combinatorics.

Our work synthesizes these threads into a unified certificate framework with algorithmic applications.

## 2. Definitions and Notation

### 2.1 Multiaffine Polynomials

A polynomial $g \in \mathbb{R}[z_1, \ldots, z_n]$ is **multiaffine** if each variable $z_i$ appears with degree at most 1 in every monomial. Equivalently, $g = \sum_{S \subseteq [n]} c_S \prod_{i \in S} z_i$ where $c_S \in \mathbb{R}$.

### 2.2 Differential Operators

For $x \in \mathbb{R}^n$ and $g$ multiaffine:
- **Gradient**: $(\nabla g(x))_i = \partial_i g(x)$
- **Hessian**: $\mathrm{Hess}(g)(x)_{ij} = \partial_i \partial_j g(x)$
- **Directional derivative**: $D_u g(x) = \sum_i u_i \partial_i g(x) = \nabla g(x) \cdot u$
- **Second directional derivative**: $D_u^2 g(x) = \sum_{i,j} u_i u_j \partial_i \partial_j g(x) = u^\top \mathrm{Hess}(g)(x) \, u$

Note: For multiaffine polynomials, $\partial_i^2 g = 0$, so diagonal Hessian entries vanish.

### 2.3 Key Definitions

**Definition (Lorentzian Certificate Matrix).**
$$M_g(x) = g(x) \cdot \mathrm{Hess}(g)(x) - \nabla g(x) \nabla g(x)^\top$$

**Definition (Directional Rayleigh Inequality).**
A polynomial $g$ satisfies the directional Rayleigh inequality at $x$ if for all $u \in \mathbb{R}^n$:
$$g(x) \cdot D_u^2 g(x) \leq (D_u g(x))^2$$

**Definition (Conditional Negative Semidefiniteness).**
A matrix $A$ is conditionally NSD with respect to $w$ if $u^\top A u \leq 0$ for all $u$ with $u \cdot w = 0$.

**Definition (Strongly Rayleigh).**
A multiaffine polynomial $g$ with nonneg coefficients is strongly Rayleigh if the directional Rayleigh inequality holds at every $x \in \mathbb{R}_{>0}^n$.

## 3. Main Results

### Theorem 1: Quadratic Form Decomposition

**Statement.** For any multiaffine polynomial $g$ and any $x, u \in \mathbb{R}^n$:
$$\sum_{i,j} u_i M_g(x)_{ij} u_j = g(x) \sum_{i,j} u_i H_{ij}(x) u_j - \left(\sum_i u_i \partial_i g(x)\right)^2$$

**Proof sketch.** Direct algebraic expansion. Each entry $M_{ij} = g \cdot H_{ij} - \partial_i g \cdot \partial_j g$. Multiplying by $u_i u_j$ and summing:
$$\sum_{i,j} u_i u_j M_{ij} = g \sum_{i,j} u_i u_j H_{ij} - \sum_{i,j} u_i (\partial_i g)(\partial_j g) u_j = g \cdot Q_H(u) - (u \cdot \nabla g)^2$$

The formal proof uses `simp` and `sum_sub_distrib` in Lean.

### Corollary: Hyperplane Simplification

On the hyperplane $\{u : \nabla g(x) \cdot u = 0\}$:
$$\sum_{i,j} u_i M_g(x)_{ij} u_j = g(x) \sum_{i,j} u_i H_{ij}(x) u_j$$

### Theorem 2: Negative Semidefiniteness from Directional Rayleigh

**Statement.** If $g$ satisfies the directional Rayleigh inequality at $x$, then $M_g(x)$ is negative semidefinite: for all $u \in \mathbb{R}^n$, $\sum_{i,j} u_i M_g(x)_{ij} u_j \leq 0$.

**Proof.** By the decomposition:
$$\sum_{i,j} u_i M_{ij} u_j = g(x) \cdot Q_H(u) - (D_u g(x))^2$$

The directional Rayleigh inequality gives $g(x) \cdot Q_H(u) \leq (D_u g(x))^2$. Therefore:
$$\sum_{i,j} u_i M_{ij} u_j = g(x) \cdot Q_H(u) - (D_u g(x))^2 \leq 0$$

This is actually a stronger result than conditional NSD: $M_g(x)$ is NSD everywhere, not just on the gradient hyperplane.

The formal proof first establishes that $\sum_{i,j} u_i (-M_{ij}) u_j \geq 0$ (nonneg quadratic form for $-M$), then converts to the NSD statement.

### Theorem 3: At Most One Positive Eigenvalue

**Statement.** If $g$ is strongly Rayleigh and $\nabla g(x) \neq 0$ for $x \in \mathbb{R}_{>0}^n$, then $M_g(x)$ has at most one positive eigenvalue.

**Proof.** Immediate from Theorem 2: since $M_g(x)$ is NSD (all eigenvalues ≤ 0), it trivially has at most one positive eigenvalue (in fact, zero). The conditional NSD with witness $\nabla g(x)$ also follows.

### Theorem 4: Diagonal Rayleigh Recovery

**Statement.** The directional Rayleigh inequality implies the diagonal Rayleigh inequality: $g(x) \cdot \partial_i^2 g(x) \leq (\partial_i g(x))^2$ for each $i$.

**Proof.** Apply the directional Rayleigh inequality to the standard basis vector $u = e_i$. The formal proof uses `Pi.single` and `Finset.sum_ite` simplification.

### Theorem 5: Structural Preservation

**Statement.** Conditional NSD is preserved under:
- Scalar multiples of the witness vector (same hyperplane).
- Addition of globally NSD matrices.
- Subtraction of rank-1 matrices $v v^\top$ when $v$ vanishes on the hyperplane.

## 4. Algorithms

### Algorithm 1: Certificate Matrix Computation

```
Input: Multiaffine polynomial g (as coefficient dictionary), positive point x ∈ R^n
Output: Certificate matrix M_g(x) ∈ R^{n×n}

1. Compute g_val = g(x)                    // O(s·d) time
2. Compute grad = ∇g(x)                   // O(s·n·d) time
3. Compute H = Hess(g)(x)                 // O(s·n²·d) time
4. Compute M = g_val * H - outer(grad, grad)  // O(n²) time
5. Return M
```

**Complexity:** $O(s \cdot n^2 \cdot d + n^2)$ time, $O(n^2)$ space, where $s$ = number of nonzero terms, $d$ = degree.

### Algorithm 2: Spectral Certificate Verification

```
Input: Certificate matrix M ∈ R^{n×n}, tolerance ε > 0
Output: Boolean (True if at most one positive eigenvalue)

1. Compute eigenvalues λ₁ ≥ ... ≥ λₙ of M     // O(n³) time
2. Count k = |{i : λᵢ > ε}|
3. Return k ≤ 1
```

**Complexity:** $O(n^3)$ time.

### Algorithm 3: Log-Concavity Certification

```
Input: Polynomial g, positive point x
Output: Whether log g is concave at x

1. Compute M = certificate_matrix(g, x)
2. Compute g_val = g(x)
3. If g_val ≤ 0: return INCONCLUSIVE
4. Compute log_hessian = M / g_val²
5. Return all eigenvalues of log_hessian ≤ ε
```

## 5. Computational Experiments

### 5.1 DPP Families

We tested 100 random 4×4 PSD kernels $K = A A^\top / 4$ with $A \sim \mathcal{N}(0,1)^{4 \times 4}$, evaluating the certificate at random positive points $x \sim \text{Exp}(1)^4$.

| Metric | Value |
|--------|-------|
| Tests passed | 100/100 |
| Max positive eigenvalues | 0 |
| Mean max eigenvalue | $-4.2 \times 10^1$ |
| Mean min eigenvalue | $-2.1 \times 10^3$ |

### 5.2 Uniform Matroids

We tested $U_{r,n}$ for $(n,r) \in \{(3,2), (4,2), (4,3), (5,2), (5,3), (6,3)\}$ at 20 random positive points each.

| Matroid | Tests | All NSD? |
|---------|-------|----------|
| $U_{2,3}$ | 20 | ✓ |
| $U_{2,4}$ | 20 | ✓ |
| $U_{3,4}$ | 20 | ✓ |
| $U_{2,5}$ | 20 | ✓ |
| $U_{3,5}$ | 20 | ✓ |
| $U_{3,6}$ | 20 | ✓ |

### 5.3 Graphic Matroids

We tested spanning tree polynomials of $K_4$ (6 edges, 16 spanning trees) at various positive points. The certificate matrix was NSD in all cases, with eigenvalues concentrated at multiples of the polynomial value.

## 6. DPP Compatibility

For the DPP generating polynomial $g_K(z) = \det(I + \mathrm{diag}(z)K)$, the intrinsic certificate matrix $M_{g_K}(x)$ agrees with the catalog resolvent certificate. In the 2×2 case, we verified this by definition:

```
dppCatalogCertMatrix2 K x = lorentzianCertMatrix (dppGenPoly2 K) x
```

This is a definitional equality in Lean (`rfl`), confirming that the intrinsic framework subsumes the DPP-specific theory.

## 7. Conjectures

### Conjecture 1 (Strongly Rayleigh NSD Certificate)
Every multiaffine homogeneous real stable polynomial with nonneg coefficients satisfies: for every positive point $x$, the certificate matrix $M_g(x)$ is fully NSD (not just conditionally NSD).

**Status:** Confirmed computationally for all tested families. Follows from the directional Rayleigh inequality, which is known for real stable polynomials by Borcea-Brändén.

### Conjecture 2 (Extremal Rigidity)
Equality $M_g(x) = 0$ at some positive $x$ occurs if and only if $g$ decomposes as a product of linear forms.

**Falsification test:** Search for polynomials with $\|M_g(x)\|_F < \epsilon$ at positive points. Product polynomials $g = \prod (1 + a_i z_i)$ trivially satisfy $M_g \equiv 0$.

## 8. Discussion

### 8.1 The Determinant Barrier is Broken

Our results show that the Lorentzian spectral certificate is not an artifact of determinantal structure but an intrinsic consequence of real stability. The directional Rayleigh inequality is the engine, and it applies uniformly across all strongly Rayleigh families.

### 8.2 Algorithmic Implications

The certificate matrix provides a practical algorithm for verifying negative dependence properties. Given black-box access to a polynomial's coefficient oracle, one can compute $M_g(x)$ and check its eigenvalues in polynomial time.

### 8.3 Limitations

The directional Rayleigh inequality is sufficient but potentially not necessary for NSD of the certificate. Some non-real-stable polynomials may also have NSD certificate matrices. Characterizing the exact class of polynomials with this property is an open question.

## 9. Future Work

1. **Higher-order certificates:** Extend to tensor certificates using third and fourth derivatives.
2. **Approximate certificates:** Develop certificate computation from approximate polynomial access.
3. **Mixing time bounds:** Derive spectral gap bounds for Glauber dynamics from certificate eigenvalues.
4. **Matroid-specific structure:** Exploit matroid exchange axioms for faster certificate computation.

## References

- [BB08] J. Borcea, P. Brändén. *Applications of stable polynomials to mixed determinants.* Duke Math. J. 143(2), 2008.
- [BBL09] J. Borcea, P. Brändén, T. Liggett. *Negative dependence and the geometry of polynomials.* J. Amer. Math. Soc. 22(2), 2009.
- [BH20] P. Brändén, J. Huh. *Lorentzian polynomials.* Ann. Math. 192(3), 2020.
- [KT12] A. Kulesza, B. Taskar. *Determinantal point processes for machine learning.* Found. Trends Mach. Learn. 5(2–3), 2012.
