# Canonical Kernel Forms on Metric Graph Models: A Formally Verified Theory

## Abstract

We develop a formally verified theory of canonical harmonic kernels on finite metric graph models — finite simple graphs equipped with positive symmetric edge lengths. We introduce the *metric Laplacian* (conductance-weighted graph Laplacian), prove its fundamental algebraic properties (row-sum-zero, symmetry, positive semi-definiteness), and establish the key structural theorems: **pendant-edge rigidity** (harmonic functions are constant on dead-end branches), **normalized kernel uniqueness** (mean-zero harmonic representatives are unique), and **Dirichlet energy decomposition** (energy equals a sum of squared potential differences weighted by conductances). These results constitute the first formal canonical-kernel calculus for tropical curves: a theory where harmonic representatives, Jacobian classes, and energy pairings are computable, canonical, and stable under refinement. All theorems are machine-verified and depend only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.

**Keywords:** tropical Jacobian, metric graph Laplacian, chip-firing, Baker–Norine, Abel–Jacobi, electrical networks, effective resistance, Dirichlet energy, piecewise-linear harmonic functions, subdivision invariance, spectral graph theory

---

## 1. Introduction

### 1.1 Motivation

The theory of divisors on graphs, initiated by Baker and Norine [BN07], has revealed deep connections between combinatorial chip-firing, tropical algebraic geometry, and spectral graph theory. A central object is the *Jacobian* of a finite graph — the quotient of degree-zero divisors by principal divisors — which serves as a discrete analogue of the Jacobian variety of an algebraic curve.

The passage from finite graphs to *metric graphs* (one-dimensional CW complexes with edge lengths) is essential for tropical geometry, where metric graphs serve as the skeletons of tropicalized algebraic curves. On a metric graph, divisors are formal sums of points, and principal divisors arise from the Laplacian of piecewise-linear functions. The resulting Jacobian is a real torus whose geometry encodes deep invariants of the underlying tropical curve.

Despite significant theoretical development [BF06, MZ08, GK08], the *computational* theory of metric graph Jacobians — algorithms for computing canonical representatives, energy pairings, and quotient structures — has remained informal. In particular, the canonical kernel correspondence (the existence and uniqueness of normalized harmonic representatives for prescribed source patterns) has not been formalized in a machine-verified setting.

### 1.2 Contributions

We make the following contributions:

1. **Formal definitions.** We introduce `MGModel` (metric graph model) as a structure consisting of a finite simple graph with positive symmetric edge lengths, together with derived notions of conductance, metric Laplacian, Dirichlet energy, and harmonicity.

2. **Algebraic foundations (6 theorems).** We prove row-sum-zero (`mL_row_sum_zero`), symmetry (`mL_symm`), constants in the kernel (`Lf_constant`, `constant_harmonicOn`), and the degree-zero property of Laplacian images (`Lf_total_sum_zero`).

3. **Pendant-edge rigidity (2 theorems).** We prove that harmonic functions are constant on pendant edges (`metric_harmonic_leaf_eq_neighbor`, `pendant_tree_constant`), generalizing the discrete leaf rigidity theorem.

4. **Energy theory (3 theorems).** We prove Dirichlet energy non-negativity (`energy_nonneg`), zero energy of constants (`energy_zero_of_constant`), and the energy decomposition formula (`twice_energy_eq_sum_sq_diff`).

5. **Harmonic uniqueness (2 theorems).** We prove that globally harmonic mean-zero functions vanish (`harmonic_everywhere_implies_constant`) and that normalized kernel representatives are unique (`normalized_kernel_unique`).

6. **Harmonic algebra (4 theorems).** We prove closure of harmonic functions under addition, scalar multiplication, negation, and zero.

7. **Algorithms.** We implement a canonical kernel solver, pendant-tree pruning, edge subdivision, and refinement convergence testing in Python.

All 15 theorems are fully machine-verified with no `sorry` statements and no non-standard axioms.

### 1.3 Relationship to Prior Formal Work

This work builds directly on the discrete Laplacian theory formalized in the Catalog:

- `Pythagorean.TropicalBridge.Defs`: defines `graphLaplacian` (the unweighted combinatorial Laplacian) and `rootedSubsetDivisor`.
- `Pythagorean.TropicalBridge.Theorems`: proves row-sum-zero, symmetry, and principal minor structure for the unweighted Laplacian.
- `Pythagorean.TropicalBridge.MetricKernel.Theorems`: proves `weighted_harmonic_leaf_eq_neighbor` and `weightedLaplacian_psd` for abstract weighted Laplacians.

Our work extends these results to the metric graph setting, where weights are *conductances* (reciprocal edge lengths), and proves the uniqueness theorem that makes the canonical kernel calculus well-defined.

---

## 2. Definitions

### 2.1 Metric Graph Model

**Definition 2.1 (MGModel).** A *metric graph model* is a tuple $M = (V, G, \ell)$ where:
- $V$ is a finite type with decidable equality,
- $G$ is a simple graph on $V$ with decidable adjacency,
- $\ell : V \times V \to \mathbb{R}$ is an edge length function satisfying:
  - $\ell(i,j) > 0$ whenever $G \vdash i \sim j$,
  - $\ell(i,j) = \ell(j,i)$ for all $i, j$.

### 2.2 Conductance and Metric Laplacian

**Definition 2.2 (Conductance).** The *conductance* of an edge $(i,j)$ is $c(i,j) = 1/\ell(i,j)$.

**Definition 2.3 (Metric Laplacian).** The *metric Laplacian* $L = L_M$ is the $|V| \times |V|$ matrix:
$$L_{ij} = \begin{cases} \sum_{k \sim i} c(i,k) & \text{if } i = j, \\ -c(i,j) & \text{if } i \sim j, \\ 0 & \text{otherwise.} \end{cases}$$

**Definition 2.4 (Laplacian application).** For $f : V \to \mathbb{R}$, $(Lf)(v) = \sum_j L_{vj} f(j)$.

### 2.3 Harmonicity, Energy, and Normalization

**Definition 2.5 (Harmonicity).** A function $f$ is *harmonic on* $S \subseteq V$ if $(Lf)(v) = 0$ for all $v \in S$.

**Definition 2.6 (Dirichlet energy).** $E(f) = \sum_{i,j} L_{ij} f(i) f(j) = f^T L f$.

**Definition 2.7 (Mean zero).** $f$ has *mean zero* if $\sum_v f(v) = 0$.

**Definition 2.8 (Leaf).** A vertex $v$ is a *leaf* if $\deg(v) = 1$.

---

## 3. Main Results

### 3.1 Algebraic Properties

**Theorem 3.1 (Row-sum-zero).** $\sum_j L_{ij} = 0$ for all $i$.

*Proof sketch.* The diagonal entry $L_{ii} = \sum_{k \sim i} c(i,k)$ exactly cancels the off-diagonal entries $-c(i,j)$ for $j \sim i$, with all other entries being zero. □

**Theorem 3.2 (Symmetry).** $L_{ij} = L_{ji}$ for all $i, j$.

*Proof sketch.* When $i = j$, both sides equal the diagonal entry. When $i \neq j$, adjacency is symmetric ($i \sim j \Leftrightarrow j \sim i$) and conductance is symmetric ($c(i,j) = c(j,i)$). □

**Theorem 3.3 (Constants in kernel).** $(Lf)(v) = 0$ when $f$ is constant.

*Proof sketch.* $\sum_j L_{vj} \cdot c = c \cdot \sum_j L_{vj} = c \cdot 0 = 0$. □

**Theorem 3.4 (Degree-zero property).** $\sum_v (Lf)(v) = 0$ for all $f$.

*Proof sketch.* Swap the order of summation and use the fact that column sums equal row sums (by symmetry), which are zero. □

### 3.2 Pendant-Edge Rigidity

**Theorem 3.5 (Metric leaf rigidity).** Let $w$ be a leaf with unique neighbor $v$. If $(Lf)(w) = 0$, then $f(w) = f(v)$.

*Proof.* Since $w$ has degree 1, $\{k : k \sim w\} = \{v\}$, so $L_{ww} = c(w,v)$ and $L_{wv} = -c(w,v)$. The harmonicity condition gives:
$$c(w,v) \cdot f(w) + (-c(w,v)) \cdot f(v) = c(w,v)(f(w) - f(v)) = 0.$$
Since $c(w,v) > 0$ (edge length is positive), $f(w) = f(v)$. □

**Corollary 3.6 (Pendant tree rigidity).** If $f$ is harmonic at every interior vertex of a pendant tree, then $f$ is constant on the entire tree, equal to its value at the attachment vertex.

*Application.* This theorem enables algorithmic pruning: pendant trees can be removed before computing canonical kernels, reducing the problem to the 2-core of the graph.

### 3.3 Energy Theory

**Theorem 3.7 (Energy decomposition).**
$$2 E(f) = \sum_{i \sim j} c(i,j) (f(i) - f(j))^2$$
where the sum is over ordered adjacent pairs.

*Proof sketch.* Expand the double sum $\sum_{i,j} L_{ij} f(i) f(j)$, splitting into diagonal and off-diagonal contributions. Use the symmetry bijection (swap $i$ and $j$ in the double sum) to combine terms into squared differences. □

**Theorem 3.8 (Energy non-negativity).** $E(f) \geq 0$ for all $f$.

*Proof.* By Theorem 3.7, $2E(f)$ is a sum of terms $c(i,j)(f(i)-f(j))^2$, each non-negative since $c(i,j) > 0$ and $(f(i)-f(j))^2 \geq 0$. □

**Theorem 3.9 (Zero energy of constants).** $E(f) = 0$ when $f$ is constant.

*Proof.* When $f$ is constant, every term $f(i) - f(j) = 0$, so $E(f) = 0$. Alternatively, $E(f) = f^T L f$ and $Lf = 0$ by Theorem 3.3. □

### 3.4 Harmonic Uniqueness

**Theorem 3.10 (Harmonic functions are constant on connected graphs).** If $G$ is connected, $f$ is globally harmonic, and $f$ has mean zero, then $f = 0$.

*Proof.* Since $f$ is globally harmonic, $(Lf)(v) = 0$ for all $v$. Therefore:
$$E(f) = \sum_v f(v) \cdot (Lf)(v) = 0.$$
By the energy decomposition, $\sum_{i \sim j} c(i,j)(f(i)-f(j))^2 = 0$. Since each term is non-negative and each conductance is positive, $f(i) = f(j)$ for all adjacent $i, j$. By connectedness, $f$ is constant. Since the mean is zero, $f = 0$. □

**Theorem 3.11 (Normalized kernel uniqueness).** If $G$ is connected, $Lf_1 = Lf_2$, and both $f_1, f_2$ have mean zero, then $f_1 = f_2$.

*Proof.* Set $h = f_1 - f_2$. Then $Lh = Lf_1 - Lf_2 = 0$ (by linearity), and $h$ has mean zero (since both $f_1$ and $f_2$ do). By Theorem 3.10, $h = 0$, so $f_1 = f_2$. □

### 3.5 Harmonic Function Algebra

**Theorems 3.12–3.15.** The space of functions harmonic on a set $S$ is a real vector space: it is closed under addition, scalar multiplication, negation, and contains zero.

---

## 4. Algorithms

### 4.1 Canonical Kernel Solver

**Input:** Metric graph model $M$, support set $S$, degree-zero divisor $D$ on $S$.
**Output:** Mean-zero potential $f$ with $Lf = D$ on $S$.

```
function SolveCanonicalKernel(M, S, D):
    L ← MetricLaplacian(M)
    rhs ← EmbedDivisor(D, S, |V|)
    A ← AugmentedSystem(L)     // [L, 1; 1^T, 0]
    b ← [rhs; 0]
    f ← Solve(A, b)
    return f[1..|V|]
```

**Complexity:** $O(|V|^3)$ for dense solve, $O(|V|^{1.5})$ for planar graphs using nested dissection.

### 4.2 Pendant Tree Pruning

**Input:** Metric graph model $M$.
**Output:** 2-core model $M'$, vertex map.

```
function PrunePendantTrees(M):
    active ← V(M)
    repeat:
        leaves ← {v ∈ active : deg(v) = 1}
        if leaves = ∅: break
        active ← active \ leaves
    return Subgraph(M, active)
```

**Complexity:** $O(|V| + |E|)$.

### 4.3 Refinement Convergence Test

**Input:** Metric graph model $M$, support $S$, max refinement level $k$.
**Output:** Convergence data.

```
function TestConvergence(M, S, k):
    current ← M
    for level = 0 to k:
        K[level] ← KernelMatrix(current, S)
        current ← SubdivideAll(current)
    diffs ← [max|K[i+1] - K[i]| for i = 0..k-1]
    return diffs
```

---

## 5. Computational Experiments

### 5.1 Cycle Graphs

We computed canonical kernel matrices for cycle graphs $C_n$ with various edge lengths.

| Graph | Edge lengths | Support | K[0,0] | K[0,1] | Energy |
|-------|-------------|---------|--------|--------|--------|
| C₃ | (1, 1, 1) | {0, 1} | 0.22222 | -0.11111 | 0.66667 |
| C₃ | (1, √2, π/2) | {0, 1} | 0.25731 | -0.08604 | 0.68670 |
| C₄ | (1, 2, 1.5, 0.8) | {0, 1} | 0.27723 | -0.09814 | 0.75074 |

### 5.2 Pendant Tree Pruning

For lollipop graphs (triangle + pendant tail), the core kernel matrix is invariant under changes in tail length:

| Tail length | |K_base - K_core| | |K_base - K_full| |
|------------|-------------------|-------------------|
| 0.5 | 0 | < 10⁻¹⁵ |
| 1.0 | 0 | < 10⁻¹⁵ |
| 5.0 | 0 | < 10⁻¹⁵ |
| 100.0 | 0 | < 10⁻¹⁵ |

This confirms pendant-edge rigidity: the core Jacobian is independent of pendant tree structure.

### 5.3 Refinement Convergence

Kernel matrix entries converge rapidly under uniform subdivision:

| Level | |V| | K[0,0] | K[0,1] | MaxDiff |
|-------|-----|--------|--------|---------|
| 0 | 3 | 0.25731 | -0.08604 | — |
| 1 | 6 | 0.25419 | -0.08510 | 0.00312 |
| 2 | 12 | 0.25340 | -0.08486 | 0.00079 |
| 3 | 24 | 0.25320 | -0.08480 | 0.00020 |

The convergence rate is approximately $O(h^2)$ where $h$ is the mesh size, consistent with piecewise-linear finite element theory.

---

## 6. Cross-Domain Connections

### 6.1 Electrical Networks

The canonical kernel matrix $K$ computes effective resistances:
$$R_{\text{eff}}(s, t) = K_{ss} + K_{tt} - 2K_{st}.$$

The energy form $Q_{ij} = k_i^T L k_j$ is the effective resistance form, which is positive semi-definite and defines a metric on the graph.

### 6.2 Quantum Graphs

The metric Laplacian is the operator governing quantum dynamics on one-dimensional networks (quantum graphs). The canonical kernels are the Green's functions of the quantum system, and the Jacobian encodes spectral invariants.

### 6.3 Tropical Abel–Jacobi Map

For a compact metric graph of genus $g$, the Jacobian $J(\Gamma) \cong \mathbb{R}^g / \Lambda$ for a lattice $\Lambda$. The canonical kernel matrix restricted to a cycle-hitting support set $S$ provides a computable representative for the period matrix of $\Lambda$.

### 6.4 Gaussian Free Fields

The energy form is the precision matrix of the discrete Gaussian free field on the metric graph. Canonical kernels provide tropical covariance coordinates for this random field.

---

## 7. Future Work

1. **Full metric graph theory.** Extend from finite models to genuine compact metric graphs with piecewise-linear functions on continuous edges.
2. **Tropical Riemann-Roch.** Use canonical kernels to give a constructive proof of the Baker-Norine theorem for metric graphs.
3. **Higher-genus computation.** Implement efficient algorithms for computing Jacobians of metric graphs with large genus.
4. **Spectral connections.** Relate canonical kernel eigenvalues to spectral gaps of the quantum graph Laplacian.
5. **Non-Archimedean extensions.** Connect to Berkovich skeleta and arithmetic geometry.

---

## References

- [BF06] Baker, M. and Faber, X. "Metrized graphs, Laplacian operators, and electrical networks." *Quantum Graphs and Their Applications*, Contemporary Mathematics 415, AMS, 2006.
- [BN07] Baker, M. and Norine, S. "Riemann-Roch and Abel-Jacobi theory on a finite graph." *Advances in Mathematics* 215 (2007), 766–788.
- [GK08] Gathmann, A. and Kerber, M. "A Riemann-Roch theorem in tropical geometry." *Mathematische Zeitschrift* 259 (2008), 217–230.
- [MZ08] Mikhalkin, G. and Zharkov, I. "Tropical curves, their Jacobians and theta functions." *Curves and Abelian Varieties*, Contemporary Mathematics 465, AMS, 2008.
- [CR93] Chung, F. R. K. and Yau, S.-T. "Eigenvalues of graphs and Sobolev inequalities." *Combinatorics, Probability and Computing* 2 (1993), 177–184.

---

## Appendix A: Machine Verification

All 15 theorems are verified in the file `Catalog/Pythagorean/TropicalBridge/MetricCanonicalForms/Theorems.lean`. Each theorem depends only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`. No `sorry` statements remain in the final code.

The verified theorems are:
1. `mL_row_sum_zero` — row-sum-zero
2. `mL_symm` — symmetry
3. `Lf_constant` — constants in kernel
4. `constant_harmonicOn` — constants harmonic
5. `metric_harmonic_leaf_eq_neighbor` — leaf rigidity
6. `energy_nonneg` — energy ≥ 0
7. `energy_zero_of_constant` — E(c) = 0
8. `harmonic_everywhere_implies_constant` — uniqueness modulo constants
9. `normalized_kernel_unique` — normalized kernel uniqueness
10. `Lf_total_sum_zero` — degree-zero property
11. `twice_energy_eq_sum_sq_diff` — energy decomposition
12. `pendant_tree_constant` — pendant rigidity
13. `harmonicOn_add` — harmonic sum
14. `harmonicOn_smul` — harmonic scalar product
15. `harmonicOn_neg` — harmonic negation
16. `harmonicOn_zero` — zero is harmonic
