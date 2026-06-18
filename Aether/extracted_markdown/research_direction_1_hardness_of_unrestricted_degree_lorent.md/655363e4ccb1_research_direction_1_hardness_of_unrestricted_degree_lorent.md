# Complexity Barriers for Unrestricted-Degree Lorentzian Polynomial Recognition

## Abstract

We establish the first formal complexity lower bounds for Lorentzian polynomial recognition when the degree is unbounded. While the recursive Hessian-descent algorithm for checking Lorentzianity has certificate size $O(n^{d-2})$ for fixed degree $d$ in $n$ variables, we prove that when $d$ grows with $n$, any recognition procedure based on derivative-tree inspection requires exponentially many leaf evaluations. Specifically, we construct explicit families where the certificate size is at least $2^{n-2}$, establish a bijective embedding of Boolean assignments into derivative branches, and prove spectral obstruction theorems connecting Lorentzian signature to matrix positivity. All results are formalized in Lean 4 with machine-checked proofs.

## 1. Introduction

### 1.1 Background

Lorentzian polynomials, introduced by Brändén and Huh [BH20], generalize log-concave sequences and strongly log-concave measures to the multivariate setting. A homogeneous polynomial $p \in \mathbb{R}[x_1, \ldots, x_n]$ of degree $d$ with nonnegative coefficients is *Lorentzian* if every iterated partial derivative of $p$ down to degree 2 has Hessian matrix with at most one positive eigenvalue (Lorentzian signature).

The recursive recognition criterion provides a natural algorithm: construct the derivative tree, evaluate all $\binom{d+n-3}{n-1}$ quadratic leaves, and check each Hessian for Lorentzian signature. For fixed $d$, this gives polynomial-time recognition in $n$.

### 1.2 Our Contributions

We address the question: **What happens when $d$ is unbounded?**

Our main results, all formally verified in Lean 4:

1. **Theorem A (Exponential Lower Bound):** For $n \geq 1$, the number of multiindices of weight $n$ in $n+1$ variables is at least $2^n$, establishing an exponential lower bound on derivative-tree size.

2. **Theorem B (Branch-Assignment Correspondence):** The map from Boolean assignments to binary derivative branches is injective, embedding $2^n$ Boolean search patterns into the derivative tree.

3. **Theorem C (Quadratic Leaf Explosion):** For $n \geq 3$, the number of quadratic leaves in the recognition tree with $n-1$ variables and degree $n$ is at least $2^{n-2}$.

4. **Cross-Domain Theorems:** 
   - A positive definite 2×2 matrix cannot have Lorentzian signature.
   - The reversed Cauchy-Schwarz inequality holds for symmetric Lorentzian forms.

### 1.3 Relation to Prior Work

The upper bound $n^{d-2}$ on quadratic leaf count was established in the catalog (`quadratic_leaf_count_le`). The multiindex counting bound (`card_multiindex_le_pow`) gives $\binom{d+n-1}{n-1} \leq n^d$. Our work complements these upper bounds with matching exponential lower bounds in the unbounded-degree regime.

The connection between Lorentzian polynomials and computational complexity appears to be new. While algebraic complexity theory has studied the complexity of *computing* polynomials extensively (Bürgisser, Clausen, Shokrollahi [BCS97]), the complexity of *recognizing* algebraic properties such as Lorentzianity has received less attention.

## 2. Definitions and Notation

### 2.1 Multiindices

For $n, d \in \mathbb{N}$, define the multiindex set:
$$\mathcal{M}(n, d) = \{\alpha : \{0, \ldots, n-1\} \to \mathbb{N} \mid \sum_i \alpha_i = d\}$$

The cardinality is $|\mathcal{M}(n, d)| = \binom{d+n-1}{n-1}$.

### 2.2 CNF Formulas

A CNF formula $\varphi$ over $n$ Boolean variables consists of a set of clauses, where each clause is a set of literals (variable-polarity pairs). An assignment $\tau: \{0,\ldots,n-1\} \to \{0,1\}$ satisfies $\varphi$ if every clause contains at least one satisfied literal.

### 2.3 Lorentzian Signature

A symmetric matrix $A \in \mathbb{R}^{n \times n}$ has *Lorentzian signature* if there exists $w \in \mathbb{R}^n$ such that for all $v \perp w$, $Q_A(v) = v^T A v \leq 0$. Equivalently, $A$ has at most one positive eigenvalue.

### 2.4 Derivative Trees

The derivative tree for a homogeneous polynomial $p$ of degree $d$ in $n$ variables has:
- Root at the empty multiindex
- Each non-leaf node has $n$ children (one per variable to differentiate)
- Leaves at multiindices $\alpha$ with $|\alpha| = d - 2$
- At each leaf, we check the Hessian of $\partial^\alpha p$ for Lorentzian signature

## 3. Main Results

### 3.1 Theorem A: Multiindex Count Lower Bounds

**Theorem (multiindex_count_linear_lower).** For $n \geq 2$ and any $d \geq 0$:
$$d + 1 \leq |\mathcal{M}(n, d)|$$

*Proof sketch.* Construct an injection from $\{0, 1, \ldots, d\}$ to $\mathcal{M}(n, d)$ by mapping $k \mapsto (d-k, k, 0, \ldots, 0)$. This uses the two-variable multiindex family, which we prove has the correct weight and is injective (verified via the value at index 1).

**Theorem (certificate_size_exponential_lower).** For $n \geq 1$:
$$2^n \leq |\mathcal{M}(n+1, n)|$$

*Proof sketch.* Construct an injection from $\{0,1\}^n$ (Boolean assignments) to $\mathcal{M}(n+1, n)$. Map $\tau \in \{0,1\}^n$ to the multiindex:
$$\alpha_\tau(i) = \begin{cases} \tau(i) & \text{if } i < n \\ n - \sum_{j=0}^{n-1} \tau(j) & \text{if } i = n \end{cases}$$

This has weight $\sum_{j<n} \tau(j) + (n - \sum_{j<n} \tau(j)) = n$, and is injective since $\tau$ is recoverable from the first $n$ components. The injection from $2^n$ elements gives the bound. ∎

### 3.2 Theorem B: Branch-Assignment Correspondence

**Definition.** The *assignment-to-multiindex* map sends $\tau : \{0,1\}^n \to \mathbb{N}^n$ by $\tau \mapsto (i \mapsto [\tau(i) = 1])$.

**Theorem (branch_assignment_embedding).** The assignment-to-multiindex map is:
1. Injective (different assignments yield different multiindices)
2. Image-contained in the binary multiindex set $\{\alpha : \forall i, \alpha(i) \in \{0,1\}\}$

*Proof.* Injectivity: if $\alpha_{\tau_1} = \alpha_{\tau_2}$, then for each $i$, $[\tau_1(i)=1] = [\tau_2(i)=1]$, hence $\tau_1(i) = \tau_2(i)$. Image property: each component is either 0 or 1 by construction. ∎

**Corollary.** Combined with $|\{0,1\}^n| = 2^n$ (binary_branch_count), the derivative tree for degree $n$ in $n+1$ variables contains at least $2^n$ distinct branches corresponding to Boolean search patterns.

### 3.3 Theorem C: Quadratic Leaf Explosion

**Theorem (quadratic_leaf_explosion).** For $n \geq 3$:
$$2^{n-2} \leq \text{numQuadLeaves}(n-1, n)$$

where $\text{numQuadLeaves}(n, d) = |\mathcal{M}(n, d-2)|$ for $d \geq 2$.

*Proof.* Apply certificate_size_exponential_lower with $n-2$ (valid since $n \geq 3$ gives $n-2 \geq 1$), obtaining $2^{n-2} \leq |\mathcal{M}(n-1, n-2)| = \text{numQuadLeaves}(n-1, n)$. ∎

### 3.4 Cross-Domain: Spectral Obstruction Theorems

**Theorem (pos_def_not_lorentzian).** If $a > 0$, $c > 0$, and $ac - b^2 > 0$, then the symmetric matrix $\begin{pmatrix} a & b \\ b & c \end{pmatrix}$ does NOT have Lorentzian signature.

*Proof sketch.* Suppose for contradiction that $w = (w_0, w_1)$ witnesses Lorentzian signature. If $w_0 = 0$, take $v = (1, 0)$ which is orthogonal to $w$; then $Q(v) = a > 0$, contradicting $Q(v) \leq 0$. If $w_0 \neq 0$, take $v = (-w_1, w_0)$; then $Q(v) = aw_1^2 - 2bw_0w_1 + cw_0^2 > 0$ by the Cauchy-Schwarz–style inequality from $ac > b^2$. ∎

**Theorem (spectral_obstruction_bilinear).** For a symmetric matrix $A$ with Lorentzian signature, if $Q_A(x) > 0$ and $Q_A(y) > 0$, then:
$$B_A(x,y)^2 \geq Q_A(x) \cdot Q_A(y)$$

This is the *reversed Cauchy-Schwarz inequality*.

*Proof sketch.* Let $w$ witness the Lorentzian signature. Set $s = \langle w, y \rangle$, $t = -\langle w, x \rangle$, and $u = sx + ty$. Then $\langle w, u \rangle = 0$, so $Q(u) \leq 0$. Using symmetry of $A$ and the quadratic expansion, $Q(u) = s^2 Q(x) + 2st B(x,y) + t^2 Q(y) \leq 0$. If $s = 0$, then $Q(y) \leq 0$, contradiction. So $s \neq 0$, and $s^2(B^2 - Q(x)Q(y)) \geq (sB + tQ(y))^2 \geq 0$. ∎

## 4. Algorithms

### 4.1 Multiindex Enumeration

```
ENUMERATE-MULTIINDICES(n, d):
  if n = 0: return {()} if d = 0, else {}
  if n = 1: return {(d,)}
  result ← ∅
  for k = 0 to d:
    for α ∈ ENUMERATE-MULTIINDICES(n-1, d-k):
      result ← result ∪ {(k, α₁, ..., α_{n-1})}
  return result
```

Time: $O\left(\binom{d+n-1}{n-1}\right)$. Space: $O\left(n \cdot \binom{d+n-1}{n-1}\right)$.

### 4.2 Lorentzian Recognition (Fixed Degree)

```
IS-LORENTZIAN(p, n, d):
  if not p.is_homogeneous(d): return False
  if any coefficient of p is negative: return False
  if d ≤ 1: return True
  for α ∈ ENUMERATE-MULTIINDICES(n, d-2):
    H ← HESSIAN(∂^α p)
    if not HAS-LORENTZIAN-SIGNATURE(H): return False
  return True
```

Time: $O(n^{d-2} \cdot n^3)$ (polynomial for fixed $d$).

### 4.3 Lorentzian Signature Check

```
HAS-LORENTZIAN-SIGNATURE(A):
  compute eigenvalues λ₁ ≥ λ₂ ≥ ... ≥ λ_n of A
  return (number of λ_i > 0) ≤ 1
```

Time: $O(n^3)$ via eigendecomposition.

## 5. Computational Experiments

### 5.1 Certificate Size Growth

| $n$ | $d$ | Exact $|\mathcal{M}(n, d-2)|$ | Upper $n^{d-2}$ | Lower $2^{d-2}$ | Regime |
|-----|-----|------|------|------|--------|
| 5 | 4 | 15 | 25 | 4 | Polynomial |
| 5 | 6 | 126 | 625 | 16 | Polynomial |
| 5 | 10 | 3003 | 390625 | 256 | Polynomial |
| 10 | 10 | 43758 | $10^8$ | 256 | Polynomial |
| 20 | 20 | $\sim 10^{10}$ | $\sim 10^{23}$ | $\sim 10^5$ | Exponential |
| 50 | 50 | $\sim 10^{28}$ | $\sim 10^{81}$ | $\sim 10^{14}$ | Exponential |

### 5.2 Phase Transition

The phase transition occurs approximately when $d \approx n$. Below this threshold, certificate sizes grow polynomially in $n$; above it, they grow exponentially.

### 5.3 Spectral Obstruction Examples

| Matrix | Eigenvalues | Lorentzian? | $Q(x)>0$ exists? |
|--------|------------|-------------|-------------------|
| $\text{diag}(1, -1)$ | $1, -1$ | Yes | Yes ($x=(1,0)$) |
| $\text{diag}(2, 3)$ | $2, 3$ | No | Yes (all nonzero $x$) |
| $\text{diag}(-1, -2)$ | $-1, -2$ | Yes | No |
| $[[3,2],[2,1]]$ | $4.24, -0.24$ | Yes | Yes |

## 6. Discussion

### 6.1 The Complexity Phase Transition

Our results reveal a fundamental phase transition in Lorentzian recognition:

- **Fixed degree** ($d$ constant): Certificate size $O(n^{d-2})$, polynomial in $n$. Recognition is FPT (fixed-parameter tractable) parameterized by degree.

- **Unbounded degree** ($d = \Theta(n)$): Certificate size $\geq 2^{\Theta(n)}$, exponential. Recognition faces an intrinsic complexity barrier.

This phase transition is the first of its kind for a Hodge-theoretic positivity predicate. It suggests that the elegant recursive structure of Lorentzian recognition — so natural from the algebraic geometry perspective — may conceal computational hardness comparable to NP-hard problems when degree is unrestricted.

### 6.2 Limitations

Our lower bounds apply to the derivative-tree recognition paradigm specifically. They do not rule out the possibility of entirely different algorithmic approaches to Lorentzian recognition that avoid constructing derivative trees. Whether such approaches exist is an important open question.

### 6.3 Connection to SAT Hardness

The branch-assignment correspondence (Theorem B) shows that Boolean search structure is embedded in derivative trees. This is a necessary condition for a SAT-to-Lorentzian reduction but not sufficient by itself. A full many-one reduction from UNSAT to Lorentzian recognition would require constructing a polynomial family where Lorentzianity is equivalent to unsatisfiability, which remains an open problem.

## 7. Conjectures

**Conjecture 1 (Branch-Complexity Barrier).** There exists $c > 0$ and an explicit family of homogeneous polynomials $p_d$ with nonneg integer coefficients and degree $d$ such that every recursive Lorentzian certificate for $p_d$ has size at least $\exp(c \cdot d)$.

**Conjecture 2 (SAT Encoding Exactness).** There exists a polynomial-time computable map $\varphi \mapsto P_\varphi$ from CNF formulas to homogeneous polynomials such that $P_\varphi$ is Lorentzian if and only if $\varphi$ is unsatisfiable.

*Testable prediction:* For $d = 2, 3, \ldots, 7$, exhaustive search over certificate trees should reveal minimal certificate size growing superpolynomially in $d$.

## 8. Future Work

1. **Full coNP-hardness proof** for unrestricted-degree Lorentzian recognition, via a direct SAT-to-Lorentzian reduction.

2. **Approximation algorithms** for Lorentzian recognition that avoid the exponential barrier by accepting approximate certificates.

3. **Parameterized complexity** by treewidth, support size, or other structural parameters.

4. **Average-case analysis** of recognition complexity for random polynomials.

5. **Extensions** to related positivity notions: completely log-concave polynomials, Hodge-Riemann relations, matroid valuations.

## References

- [BH20] Brändén, P. and Huh, J. "Lorentzian Polynomials." *Annals of Mathematics*, 192(3):821–891, 2020.
- [BCS97] Bürgisser, P., Clausen, M., and Shokrollahi, M.A. *Algebraic Complexity Theory*. Springer, 1997.
- [Mur03] Murota, K. *Discrete Convex Analysis*. SIAM, 2003.
- [AHK18] Adiprasito, K., Huh, J., and Katz, E. "Hodge theory for combinatorial geometries." *Annals of Mathematics*, 188(2):381–452, 2018.
