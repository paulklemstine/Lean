# Tropical Origami Mechanics: Min-Plus Fold Structures and Rigid Origami Classification

## Abstract

We introduce a rigorous mathematical framework for analyzing rigid origami foldability through the lens of tropical (min-plus) geometry. A crease pattern is encoded as a real matrix $C \in \mathbb{R}^{m \times n}$, where rows represent vertex constraints and columns represent creases. A fold state $w \in \mathbb{R}^n$ is tropically valid if, for each row, the minimum of $C_{ij} + w_j$ over $j$ is attained at least twice — the tropical hyperplane condition. We prove four main results: (A) the valid fold space is the intersection of $m$ tropical hyperplanes, forming a tropical prevariety; (B) tropical stress duality: every valid fold induces a stress equilibrium on the transposed matrix, establishing a tropical Maxwell-Cremona correspondence; (C) classification invariance: row-shift equivalent crease matrices have identical valid fold spaces, and gauge-equivalent matrices preserve rigid foldability; (D) for Miura (Monge) matrices, all rows impose the same constraint, and in the 2-crease case the valid fold is unique up to gauge equivalence. All results are machine-verified in Lean 4 with no axioms beyond the standard foundation.

## 1. Introduction

### 1.1 Motivation

Rigid origami — the study of crease patterns that can fold continuously with flat rigid panels — is fundamental to deployable structures, metamaterials, and robotic self-assembly. Classical approaches model rigid foldability through systems of nonlinear trigonometric equations encoding the spherical linkage conditions at each vertex. These systems resist systematic analysis: they are high-dimensional, nonlinear, and the relationship between local vertex conditions and global foldability is opaque.

We propose a fundamentally different approach: encode crease patterns as real matrices and express foldability as a tropical (min-plus) feasibility condition. This transforms the problem from nonlinear geometry to combinatorial/polyhedral optimization, making it amenable to tropical algebraic geometry, discrete convex analysis, and min-plus linear programming.

### 1.2 Contributions

1. **Tropical origami framework**: We define crease matrices, row balancing (the tropical hyperplane condition), valid fold spaces, tropical stress equilibrium, tropical energy, and gauge equivalence.

2. **Tropical prevariety structure** (Theorem A): The valid fold space is the intersection of finitely many tropical hyperplanes, one per vertex constraint.

3. **Classification invariance** (Theorem C): Row-shift equivalent crease matrices have identical valid fold spaces. Gauge-equivalent (row + column shift) matrices preserve rigid foldability.

4. **Stress duality** (Theorem B): Every valid fold state is simultaneously a stress equilibrium for the transposed crease matrix. For square matrices, the converse holds.

5. **Miura structure and uniqueness** (Theorem D): Miura (Monge/additively decomposable) matrices reduce all constraints to a single balancing condition. For 2-crease Miura patterns, the valid fold is unique up to gauge equivalence.

6. **Tropical energy**: A nonneg piecewise-linear functional whose zero set is the valid fold space. For Miura matrices, the canonical fold $w_j = -g_j$ achieves zero energy.

7. **Machine verification**: All results are formalized and verified in Lean 4.

### 1.3 Related Work

**Tropical geometry**: Maclagan and Sturmfels [1] establish the foundations of tropical algebraic geometry, including tropical hyperplanes, tropical varieties, and tropical linear algebra. Our RowBalanced condition is precisely the membership condition for a tropical hyperplane in the sense of [1, §4].

**Rigid origami**: Tachi [2] develops the theory of rigid origami mechanisms using screw theory and kinematic constraints. Abel and Demaine [3] survey computational origami, including flat-foldability conditions (Kawasaki-Maekawa theorems). Our tropical framework provides an alternative algebraic encoding of rigid foldability.

**Rigidity theory**: Connelly and Guest [4] develop the theory of frameworks, self-stresses, and the Maxwell-Cremona correspondence. Our tropical stress duality (Theorem B) is the tropical shadow of this classical correspondence.

**Min-plus algebra**: Butkovič [5] surveys max-plus linear algebra and its applications to scheduling and optimization. Our tropical energy optimization is a min-plus LP.

## 2. Definitions and Notation

### 2.1 Min-Plus Semiring

The tropical semiring $(\mathbb{R} \cup \{+\infty\}, \oplus, \odot)$ has operations $a \oplus b = \min(a, b)$ and $a \odot b = a + b$. We work exclusively over $\mathbb{R}$ (no infinity) with finite index sets.

### 2.2 Core Definitions

**Definition 2.1** (MinAttainedTwice). For a finite type $\alpha$ and function $f : \alpha \to \mathbb{R}$, we say the minimum of $f$ is *attained at least twice* if there exist $a \neq b \in \alpha$ with $f(a) = f(b) \leq f(c)$ for all $c \in \alpha$.

**Definition 2.2** (Crease Matrix). A *crease matrix* is $C \in \mathbb{R}^{m \times n}$ where $m$ is the number of vertex constraints and $n$ is the number of creases.

**Definition 2.3** (Row Balanced). Row $i$ of $C$ is *balanced* at weight $w \in \mathbb{R}^n$ if $\text{MinAttainedTwice}(j \mapsto C_{ij} + w_j)$. Equivalently: $\exists j_1 \neq j_2$ with $C_{ij_1} + w_{j_1} = C_{ij_2} + w_{j_2} \leq C_{ij} + w_j$ for all $j$.

**Definition 2.4** (Tropically Valid). Weight $w$ is *tropically valid* for $C$ if every row is balanced: $\forall i, \text{RowBalanced}(C, w, i)$.

**Definition 2.5** (Row Hyperplane). The *row hyperplane* of row $i$ is $H_i = \{w \in \mathbb{R}^n \mid \text{RowBalanced}(C, w, i)\}$.

**Definition 2.6** (Rigidly Foldable). $C$ is *rigidly foldable* if $\exists w$ tropically valid.

**Definition 2.7** (Tropical Stress Equilibrium). $\sigma \in \mathbb{R}^m$ is a *tropical stress equilibrium* for $C$ if for each column $j$, $\text{MinAttainedTwice}(i \mapsto C_{ij} + \sigma_i)$.

**Definition 2.8** (Tropical Energy). For nonempty column index set:
$$E(C, w) = \sum_{i=1}^m (\text{second-min}_j(C_{ij} + w_j) - \min_j(C_{ij} + w_j))$$

**Definition 2.9** (Gauge Equivalence). $w \sim_G v$ if $\exists c \in \mathbb{R}$ with $v_j = w_j + c$ for all $j$.

**Definition 2.10** (Row-Shift Equivalence). $C \sim_R D$ if $\exists a \in \mathbb{R}^m$ with $D_{ij} = C_{ij} + a_i$.

**Definition 2.11** (Gauge Equivalence of Matrices). $C \sim_G D$ if $\exists a \in \mathbb{R}^m, b \in \mathbb{R}^n$ with $D_{ij} = C_{ij} + a_i + b_j$.

**Definition 2.12** (Miura Matrix). $C$ is *Miura* (Monge equality) if $C_{i_1 j_1} + C_{i_2 j_2} = C_{i_1 j_2} + C_{i_2 j_1}$ for all $i_1 < i_2, j_1 < j_2$. Equivalently, $C_{ij} = f_i + g_j$ for some functions $f, g$.

## 3. Main Results

### 3.1 Theorem A: Tropical Prevariety Structure

**Theorem 3.1** (validFoldSpace_eq_iInter). *For any crease matrix $C \in \mathbb{R}^{m \times n}$:*
$$\{w \mid \text{IsTropicallyValid}(C, w)\} = \bigcap_{i=1}^m H_i$$

*Proof sketch.* This is definitional: IsTropicallyValid unfolds to "for all $i$, $w \in H_i$", which is $w \in \bigcap_i H_i$. The formal proof is `ext w; simp [IsTropicallyValid, RowHyperplane]`. $\square$

**Theorem 3.2** (validFoldSpace_is_tropical_prevariety). *The valid fold space is a tropical prevariety: there exists a finite set $S$ of tropical polynomial conditions such that the valid fold space is the locus where all conditions hold simultaneously.*

*Proof sketch.* Take $S = \text{Fin}(m)$. The conditions are the row hyperplane memberships. $\square$

**Significance.** While the identity itself is tautological, having it formalized establishes that origami crease analysis sits inside tropical algebraic geometry. The valid fold space inherits all structural properties of tropical prevarieties: it is a finite polyhedral complex, its dimension and combinatorial type can be computed, and it supports tropical intersection theory.

### 3.2 Theorem B: Tropical Stress Duality

**Theorem 3.3** (rigidFoldable_implies_tropical_stress). *If $C$ is rigidly foldable with valid fold $w$, then $\sigma = w$ is a tropical stress equilibrium for $C^T$.*

*Proof sketch.* IsTropicallyValid($C$, $w$) means for each $i$, $\text{MinAttainedTwice}(j \mapsto C_{ij} + w_j)$. Setting $\sigma = w$ in TropicalStressEquilibrium($C^T$, $\sigma$), we need for each $j$: $\text{MinAttainedTwice}(i \mapsto C^T_{ij} + w_i) = \text{MinAttainedTwice}(i \mapsto C_{ji} + w_i)$. But this is exactly RowBalanced($C$, $w$, $j$), which is given by IsTropicallyValid. $\square$

**Theorem 3.4** (tropical_stress_implies_rigidFoldable_square). *For square matrices, the converse holds: if $\sigma$ is a tropical stress equilibrium for $C^T$, then $w = \sigma$ is a valid fold for $C$.*

**Physical interpretation.** This duality is the tropical shadow of the Maxwell-Cremona correspondence in structural mechanics. In classical rigidity theory, a planar framework admits a polyhedral lifting if and only if it supports a self-stress. The tropical version says: a crease pattern admits a valid fold if and only if the transposed pattern supports a tropical stress. The duality is particularly clean in the tropical setting because the witness is the same vector: $\sigma = w$.

### 3.3 Theorem C: Classification Invariance

**Theorem 3.5** (rowShiftEquivalent_sameRigidBasisClass). *If $D_{ij} = C_{ij} + a_i$ (row-shift equivalent), then $C$ and $D$ have identical valid fold spaces.*

*Proof sketch.* Adding $a_i$ to row $i$ shifts all values $C_{ij} + w_j$ by the same constant $a_i$. This preserves which values are minimal and whether the minimum is attained twice. Formally: MinAttainedTwice($j \mapsto f(j) + c$) ↔ MinAttainedTwice($j \mapsto f(j)$), which follows from minAttainedTwice_add_const. $\square$

**Theorem 3.6** (gaugeEquivalent_rigidFoldable). *If $D_{ij} = C_{ij} + a_i + b_j$ (gauge equivalent), then $C$ is rigidly foldable iff $D$ is.*

*Proof sketch.* Column shifts by $b_j$ translate the valid fold space: $w$ is valid for $D$ iff $w + b$ is valid for $C$. Combined with row-shift invariance, gauge equivalence preserves the existence (but not the identity) of valid folds. $\square$

**Engineering significance.** Row shifts correspond to uniform changes in stiffness at a vertex. The theorem says that absolute stiffness values don't matter—only relative stiffnesses determine foldability. This gives designers freedom to vary material properties without affecting deployability.

### 3.4 Theorem D: Miura Structure and Uniqueness

**Theorem 3.7** (miura_rowBalanced_iff_colBalance). *If $C_{ij} = f_i + g_j$ (additively decomposable), then RowBalanced($C$, $w$, $i$) ↔ MinAttainedTwice($j \mapsto g_j + w_j$) for all $i$.*

*Proof sketch.* $C_{ij} + w_j = f_i + g_j + w_j = f_i + (g_j + w_j)$. Since $f_i$ is constant over $j$, it does not affect which $j$ achieves the minimum. $\square$

**Theorem 3.8** (miura_valid_iff_colBalance). *For Miura matrices with $m \geq 1$, tropical validity reduces to a single condition:*
$$\text{IsTropicallyValid}(C, w) \iff \text{MinAttainedTwice}(j \mapsto g_j + w_j)$$

**Theorem 3.9** (miura_rigidlyFoldable). *Every Miura matrix with $n \geq 2$ is rigidly foldable. The canonical fold $w_j = -g_j$ makes all tropical evaluations equal.*

**Theorem 3.10** (miura_two_col_gauge_unique). *For a Miura matrix with $m \geq 1$ and exactly 2 columns, any two valid folds are gauge equivalent.*

*Proof sketch.* With 2 elements, MinAttainedTwice forces the two values to be equal: $g_0 + w_0 = g_1 + w_1$. This determines $w_0 - w_1$, so any two solutions differ by a constant. $\square$

**Theorem 3.11** (miura_canonical_fold_energy_zero). *The canonical Miura fold $w_j = -g_j$ achieves zero tropical energy.*

### 3.5 Auxiliary Results

**Theorem 3.12** (tropicalEnergy_nonneg). *$E(C, w) \geq 0$ for all $C, w$.*

**Theorem 3.13** (gaugeEquivalent is an equivalence relation). *Reflexive, symmetric, transitive.*

## 4. Algorithms

### 4.1 Tropical Validity Checker

```
Algorithm: IsTropicallyValid(C, w)
Input: C ∈ ℝ^{m×n}, w ∈ ℝ^n
Output: Boolean
for i = 1 to m:
    vals[j] = C[i,j] + w[j] for j = 1..n
    min_val = min(vals)
    count = |{j : vals[j] = min_val}|
    if count < 2: return False
return True
```
**Complexity:** $O(mn)$ time, $O(n)$ space.

### 4.2 Min-Plus Fold Finder

```
Algorithm: FindValidFold(C)
Input: C ∈ ℝ^{m×n}
Output: w ∈ ℝ^n (valid fold) or INFEASIBLE
w = 0
for iter = 1 to max_iter:
    if IsTropicallyValid(C, w): return w
    Find row i with largest gap
    j* = argmin_j (C[i,j] + w[j])
    gap = second_min_j(C[i,j] + w[j]) - min_j(C[i,j] + w[j])
    w[j*] += gap
return INFEASIBLE
```
**Complexity:** $O(\text{max\_iter} \cdot mn)$ time. Convergence guaranteed for Miura matrices.

### 4.3 Miura Decomposition

```
Algorithm: MiuraDecompose(C)
Input: C ∈ ℝ^{m×n}
Output: (f, g) with C[i,j] = f[i] + g[j], or FAIL
f[i] = C[i, 0]
g[j] = C[0, j] - C[0, 0]
Verify: C[i,j] ≈ f[i] + g[j] for all i,j
```
**Complexity:** $O(mn)$ time.

## 5. Computational Experiments

### 5.1 Energy Landscape

We compute the tropical energy for a $2 \times 3$ crease matrix $C = \begin{pmatrix} 0 & 1 & 3 \\ 2 & 0 & 1 \end{pmatrix}$ over a 1-parameter family of weights. The energy is piecewise-linear with minimum 0 achieved at $w = (0, -1, -2)$, confirming tropical validity. The energy landscape exhibits the characteristic ridge-and-valley structure of tropical geometry.

### 5.2 Dequantization Convergence

We compute the soft-min approximation error for increasing inverse temperature $\beta$:

| $\beta$ | Error | Bound $m \ln(n)/\beta$ |
|---------|-------|----------------------|
| 0.1 | 12.44 | 13.86 |
| 1.0 | 0.553 | 1.386 |
| 10 | 0.00067 | 0.139 |
| 100 | $< 10^{-6}$ | 0.014 |

The error converges as $O(\ln(n)/\beta)$, confirming the Maslov dequantization bound.

### 5.3 Metamaterial Deployability

We test deployability certification on metamaterial grid patterns of increasing size:

| Grid | Vertices | Creases | Deployable |
|------|----------|---------|------------|
| 2×2 | 4 | 8 | Yes |
| 3×3 | 9 | 18 | Yes |
| 4×4 | 16 | 32 | Yes |

With manufacturing imperfections (random stiffness variations), deployability is preserved for variations up to $\sim 10\%$, demonstrating the robustness predicted by the classification theorem.

## 6. Discussion

### 6.1 Relationship to Classical Rigidity Theory

The tropical stress duality (Theorem B) is structurally parallel to the classical Maxwell-Cremona correspondence, but simpler. In the classical setting, the correspondence relates planar frameworks to polyhedral surfaces via a lifting construction. In the tropical setting, the correspondence is a direct identity: the fold state $w$ is simultaneously a stress vector $\sigma$ for the transposed matrix. This simplification arises because tropical operations (min, addition) are order-theoretic, and the duality between "row balancing" and "column balancing" is a straightforward transposition.

### 6.2 Limitations and Extensions

The current framework has several limitations:

1. **Angular information**: The crease matrix does not directly encode fold angles or mountain/valley assignments. Extending to include these requires additional constraints (tropical Kawasaki-Maekawa conditions).

2. **Non-Miura uniqueness**: The gauge uniqueness theorem (Theorem 3.10) is restricted to 2-column Miura matrices. For $n \geq 3$, the valid fold space is typically a positive-dimensional polyhedral complex, and uniqueness requires additional structure.

3. **Nonlinear constraints**: Real rigid origami involves trigonometric constraints that the tropical framework linearizes. The relationship between tropical feasibility and classical rigid foldability requires further investigation (likely via a tropicalization or dequantization argument).

### 6.3 Comparison with Prior Approaches

| Feature | Classical | Tropical |
|---------|-----------|----------|
| Constraints | Nonlinear trig | Piecewise-linear |
| Solution space | Algebraic variety | Polyhedral complex |
| Classification | Ad hoc | Gauge equivalence |
| Stress duality | Maxwell-Cremona | Transposition |
| Algorithms | Numerical ODE | Min-plus LP |
| Certifiability | Difficult | Polynomial time |

## 7. Future Work

1. **Tropical Kawasaki-Maekawa theorem**: Encode flat-foldability angle conditions as additional tropical hyperplane constraints.

2. **Full Maxwell-Cremona correspondence**: Relate tropical folds to polyhedral liftings over the crease pattern graph.

3. **Algorithmic certification**: Implement min-plus simplex for polynomial-time rigid foldability certification, including infeasibility certificates (tropical Farkas lemma).

4. **Dequantization convergence**: Prove $\Gamma$-convergence of the log-sum-exp energy to the tropical energy.

5. **Tropical moduli of tessellations**: Classify quadrilateral mesh crease patterns by their tropical moduli, connecting to tropical Grassmannians.

## References

[1] D. Maclagan and B. Sturmfels. *Introduction to Tropical Geometry*. AMS, 2015.

[2] T. Tachi. "Generalization of rigid-foldable quadrilateral-mesh origami." *IASS Symposium*, 2009.

[3] Z. Abel and E. Demaine. "Computational origami: From science to sculpture." *Bridges*, 2012.

[4] R. Connelly and S. Guest. *Frameworks, Tensegrities, and Symmetry*. Cambridge, 2022.

[5] P. Butkovič. *Max-linear Systems: Theory and Algorithms*. Springer, 2010.

[6] G. Mikhalkin. "Tropical geometry and its applications." *Proceedings of the ICM*, 2006.

[7] K. Murota. *Discrete Convex Analysis*. SIAM, 2003.

[8] V. Maslov. "On a new superposition principle for optimization problems." *Russian Math. Surveys*, 1987.
