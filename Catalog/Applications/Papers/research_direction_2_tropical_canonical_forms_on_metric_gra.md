# Canonical Kernel Calculus on Metric Graph Models: A Formal Foundation for Tropical Jacobian Computation

## Abstract

We develop the first formally verified canonical kernel calculus for metric graph models, establishing the foundational theory for computing harmonic representatives, Jacobian classes, and energy pairings on compact metric graphs. Working with finite weighted graph models (finite simple graphs equipped with positive symmetric edge lengths), we prove: (1) pendant-edge rigidity — harmonic functions on pendant edges are constant; (2) Dirichlet energy non-negativity and its characterization of constant functions on connected graphs; (3) uniqueness of normalized harmonic kernels under mean-zero normalization; (4) the degree-zero property of S-principal divisors; and (5) symmetry of the energy bilinear form. All theorems are formally verified in Lean 4 with Mathlib, using only standard axioms. We provide efficient algorithms for canonical kernel computation, pendant-tree pruning, and subdivision refinement, along with computational demonstrations on cycle, theta, and lollipop graphs. The theory connects discrete chip-firing / Laplacian combinatorics with tropical geometry, electrical network theory, and quantum graph spectral theory.

**Keywords:** tropical Jacobian, metric graph Laplacian, chip-firing, Baker–Norine, Abel–Jacobi, electrical networks, effective resistance, quantum graphs, Dirichlet energy, piecewise-linear harmonic functions, subdivision invariance, tropical Hodge theory

---

## 1. Introduction

### 1.1 Motivation

The theory of divisors on finite graphs, initiated by Baker and Norine [BN07], establishes a striking analogy between Riemann surfaces and graphs. The graph Laplacian plays the role of the ∂∂̄-operator, principal divisors are images of the Laplacian, and the Jacobian group Jac(G) ≅ ℤ^n / Im(L) captures the essential algebraic geometry.

However, the passage from finite combinatorial graphs to *metric graphs* (also known as tropical curves or abstract tropical varieties) introduces continuous geometry: edge lengths, piecewise-linear functions, slopes, and a continuous Laplacian. This passage is essential for tropical geometry [MZ08, BF11] but has lacked formal computational foundations.

### 1.2 Contributions

This paper makes the following contributions:

1. **Formal definitions.** We introduce the `WMGraph` structure (weighted metric graph model) with positive symmetric edge lengths, metric Laplacian, Dirichlet energy, S-supported principal divisors, and energy bilinear form.

2. **Core algebraic theory.** We prove row-sum-zero, symmetry, linearity of the Laplacian operator, degree-zero property of principal divisors, and the harmonic function algebra.

3. **Pendant-edge rigidity.** We prove that harmonic functions on pendant edges are forced constant — the metric analogue of the discrete leaf rigidity theorem.

4. **Energy theory.** We prove non-negativity of Dirichlet energy, its characterization of constant functions on connected graphs, and symmetry of the energy bilinear form.

5. **Uniqueness theorem.** We prove that mean-zero normalized kernels are uniquely determined by their Laplacian source data on connected graphs.

6. **Algorithms.** We implement canonical kernel solvers, pendant-tree pruning, and subdivision refinement, with computational demonstrations.

7. **Formal verification.** All theorems are verified in Lean 4 with Mathlib. Proofs use only the standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

**Chip-firing and graph Jacobians.** Baker and Norine [BN07] proved the Riemann-Roch theorem for graphs. Dhar [Dha90] introduced chip-firing games. The Jacobian group of a graph is isomorphic to the critical group / sandpile group.

**Tropical geometry.** Mikhalkin and Zharkov [MZ08] developed the theory of tropical curves and their Jacobians. Baker and Faber [BF06] studied metrized graphs and their Laplacians.

**Formal mathematics.** Mathlib [Mat24] provides extensive formalized mathematics in Lean 4. Prior formal work on graph theory includes formalization of Euler's theorem and various combinatorial results.

---

## 2. Definitions and Notation

### 2.1 Metric Graph Model

**Definition 2.1 (WMGraph).** A *weighted metric graph model* M = (V, G, ℓ) consists of:
- A finite set V of vertices with |V| = n
- A simple graph G = (V, E) with decidable adjacency
- A symmetric edge length function ℓ: V × V → ℝ with ℓ(i,j) > 0 for all {i,j} ∈ E and ℓ(i,j) = ℓ(j,i)

**Definition 2.2 (Conductance).** The *conductance* of edge {i,j} is σ(i,j) = 1/ℓ(i,j).

**Definition 2.3 (Metric Laplacian).** The *metric Laplacian matrix* L ∈ ℝ^{V×V} is:

$$L_{ij} = \begin{cases} \sum_{k \sim i} \sigma(i,k) & \text{if } i = j \\ -\sigma(i,j) & \text{if } i \sim j \\ 0 & \text{otherwise} \end{cases}$$

**Definition 2.4 (Laplacian operator).** For f: V → ℝ, define (Lf)(v) = ∑_j L_{vj} f(j).

**Definition 2.5 (Harmonicity).** A function f is *harmonic on T ⊆ V* if (Lf)(v) = 0 for all v ∈ T.

**Definition 2.6 (Dirichlet Energy).** The *Dirichlet energy* of f: V → ℝ is E(f) = f^T L f = ∑_{i,j} L_{ij} f(i) f(j).

**Definition 2.7 (Mean-zero normalization).** A function f is *mean-zero* if ∑_v f(v) = 0.

**Definition 2.8 (S-principal divisor).** A function D: V → ℝ is *S-principal* if there exists f: V → ℝ such that (Lf)(v) = 0 for all v ∉ S and (Lf)(v) = D(v) for all v.

**Definition 2.9 (Energy bilinear form).** The *energy form* is ⟨f,g⟩_L = f^T L g = ∑_{i,j} L_{ij} f(i) g(j).

### 2.2 Leaf and Pendant Predicates

**Definition 2.10.** A vertex v is a *leaf* if deg(v) = 1.

**Definition 2.11.** An edge {v,w} is a *pendant edge* if w is a leaf.

---

## 3. Main Results

### 3.1 Algebraic Properties of the Metric Laplacian

**Theorem 3.1 (Row-sum-zero).** For all i ∈ V, ∑_j L_{ij} = 0.

*Proof sketch.* The diagonal entry L_{ii} = ∑_{k~i} σ(i,k) exactly cancels the off-diagonal entries −σ(i,j) for j ∼ i. Non-adjacent entries are zero. □

**Theorem 3.2 (Symmetry).** L_{ij} = L_{ji} for all i, j.

*Proof sketch.* Case analysis: if i = j, both sides equal the weighted degree. If i ∼ j, both sides equal −σ(i,j) = −σ(j,i) by symmetry of edge lengths. If i ≁ j, both sides are zero. □

**Theorem 3.3 (Constants in kernel).** For any constant c, (L·**c**)(v) = 0.

*Proof.* (L·**c**)(v) = c · ∑_j L_{vj} = c · 0 = 0 by row-sum-zero. □

**Theorem 3.4 (Linearity).** The Laplacian operator is linear:
- L(f + g) = Lf + Lg
- L(cf) = c · Lf
- L(f − g) = Lf − Lg

**Theorem 3.5 (Degree-zero).** For any f: V → ℝ, ∑_v (Lf)(v) = 0.

*Proof.* ∑_v (Lf)(v) = ∑_v ∑_j L_{vj} f(j) = ∑_j f(j) · (∑_v L_{vj}) = ∑_j f(j) · (∑_v L_{jv}) = ∑_j f(j) · 0 = 0, using symmetry and row-sum-zero. □

**Theorem 3.6 (Off-diagonal non-positivity).** For i ≠ j, L_{ij} ≤ 0.

### 3.2 Pendant-Edge Rigidity

**Theorem 3.7 (Metric leaf rigidity).** Let w be a leaf vertex with unique neighbor v. If f is harmonic at w (i.e., (Lf)(w) = 0), then f(w) = f(v).

*Proof sketch.* Since deg(w) = 1, the neighbor set of w is {v}. The Laplacian equation at w reduces to σ(w,v) · (f(w) − f(v)) = 0. Since σ(w,v) = 1/ℓ(w,v) > 0, we conclude f(w) = f(v). □

*Remark.* This is the metric-graph generalization of the discrete `harmonic_at_leaf_eq_neighbor` theorem from the catalog. The weight affects the *rate* of propagation but not the *value* constraint.

**Theorem 3.8 (S-complement leaf rigidity).** If f is harmonic on S^c and w ∉ S is a leaf with neighbor v, then f(w) = f(v).

*Proof.* Since w ∉ S, we have w ∈ S^c, so (Lf)(w) = 0. Apply Theorem 3.7. □

### 3.3 Dirichlet Energy Theory

**Theorem 3.9 (Energy non-negativity).** E(f) ≥ 0 for all f: V → ℝ.

*Proof sketch.* We show that 2E(f) = ∑_{i~j} σ(i,j) · (f(i) − f(j))². Each term is non-negative since σ > 0 and squares are non-negative. □

*Cross-domain significance:*
- **Electrical networks:** Power dissipation is non-negative.
- **Statistical mechanics:** The action functional is bounded below.
- **Quantum graphs:** The Hamiltonian is bounded below (stability).

**Theorem 3.10 (Zero energy characterization).** On a connected graph, E(f) = 0 if and only if f is constant.

*Proof sketch.* (⇐) Follows from E(**c**) = 0 since L·**c** = 0.
(⇒) If E(f) = 0, then each term σ(i,j)(f(i)−f(j))² = 0 for adjacent pairs. Since σ > 0, f(i) = f(j) whenever i ∼ j. Connectedness propagates equality to all vertex pairs. □

**Theorem 3.11 (Energy form symmetry).** ⟨f,g⟩_L = ⟨g,f⟩_L.

*Proof.* Swap summation indices and use L_{ij} = L_{ji}. □

### 3.4 Harmonic Uniqueness

**Theorem 3.12 (Harmonic mean-zero implies zero).** On a connected graph, if f is globally harmonic ((Lf)(v) = 0 for all v) and mean-zero (∑ f(v) = 0), then f ≡ 0.

*Proof sketch.* Since f is harmonic, E(f) = ∑ f(v)(Lf)(v) = 0. By Theorem 3.10, f is constant: f = **c**. The mean-zero condition gives n·c = 0, so c = 0 (assuming V is nonempty; otherwise f is vacuously zero). □

**Theorem 3.13 (Normalized kernel uniqueness).** On a connected graph, if f₁ and f₂ are mean-zero and Lf₁ = Lf₂, then f₁ = f₂.

*Proof.* Let h = f₁ − f₂. Then Lh = Lf₁ − Lf₂ = 0 (linearity) and h is mean-zero. By Theorem 3.12, h ≡ 0, so f₁ = f₂. □

*Significance:* This is the rigidity theorem that makes canonical kernels well-defined. Combined with existence (guaranteed by linear algebra), it establishes the canonical kernel correspondence: each degree-zero S-supported divisor has a unique mean-zero harmonic representative.

### 3.5 S-Supported Jacobian Theory

**Theorem 3.14 (S-principal divisors have degree zero).** If D is S-principal, then ∑_v D(v) = 0.

*Proof.* By definition, D = Lf for some f. By Theorem 3.5, ∑ D(v) = ∑ (Lf)(v) = 0. □

---

## 4. Algorithms

### 4.1 Canonical Kernel Solver

**Algorithm 1: Normalized Kernel Computation**

```
Input: Metric graph model M, support set S, degree-zero divisor D
Output: Mean-zero potential f with Lf = D

1. Build metric Laplacian L using conductances 1/ℓ(e)
2. Set up system A·f = D where A = L
3. Replace last row of A with [1, 1, ..., 1] (mean-zero constraint)
4. Set last entry of D to 0
5. Solve A·f = D via Gaussian elimination
6. Return f
```

**Complexity:** O(n³) time, O(n²) space.

**Correctness:** By Theorem 3.13, the solution is unique. Existence is guaranteed when deg(D) = 0 by the rank-nullity theorem (L has rank n−1 on connected graphs).

### 4.2 Pendant-Tree Pruning

**Algorithm 2: Core Extraction**

```
Input: Metric graph model M
Output: Core vertices, leaf-to-attachment map

1. Initialize degrees = [deg(v) for v in V]
2. Initialize pruned = ∅, leaf_map = {}
3. Repeat until no changes:
   a. For each unpruned vertex v:
      i. Compute effective degree (excluding pruned neighbors)
      ii. If effective degree ≤ 1: mark v as pruned,
          record attachment in leaf_map
4. Return unpruned vertices, leaf_map
```

**Complexity:** O(|V| + |E|) time.

**Justification:** By Theorem 3.7, harmonic functions on pendant edges are constant. Pruning pendant trees does not change the space of harmonic functions restricted to the core, hence preserves the S-Jacobian for any S contained in the core.

### 4.3 Subdivision Refinement

**Algorithm 3: Edge Subdivision**

```
Input: Metric graph model M, edge (u,v), ratio r ∈ (0,1)
Output: Refined model M' with new vertex w

1. Create new vertex w
2. Remove edge (u,v) with length ℓ
3. Add edge (u,w) with length r·ℓ
4. Add edge (w,v) with length (1-r)·ℓ
5. Rebuild Laplacian
6. Return M'
```

**Key property:** The canonical kernel matrix at original support vertices is exactly preserved under subdivision (verified computationally; see Section 6).

---

## 5. Cross-Domain Connections

### 5.1 Electrical Networks

The metric Laplacian with conductances σ(i,j) = 1/ℓ(i,j) is precisely the conductance matrix of an electrical network. The canonical kernel k_s is the voltage distribution when unit current is injected at s and extracted at the base point. The energy form ⟨k_s, k_t⟩_L computes the effective resistance between terminals.

### 5.2 Tropical Geometry

The S-supported Jacobian quotient Div⁰_S(Γ)/Prin_S(Γ) is the computational realization of the tropical Jacobian restricted to S. The canonical kernel generators provide explicit Abel-Jacobi coordinates. The energy pairing descends to the tropical polarization form.

### 5.3 Quantum Graphs

The metric Laplacian is the Hamiltonian operator governing quantum dynamics on wire networks. The canonical kernels serve as combinatorial Green's functions, and the energy spectrum encodes quantum transport properties.

### 5.4 Statistical Mechanics

The Dirichlet energy form defines the precision matrix of the pinned Gaussian free field on the network. The canonical kernel matrix is the covariance kernel, with entries giving the correlation between field values at support vertices.

---

## 6. Computational Experiments

### 6.1 Cycle Graph C₄

Edge lengths [1, 2, 1, 2]. Support S = {0, 1, 2, 3}. Genus = 1.

**Energy pairing matrix:**
| | k₁ | k₂ | k₃ |
|---|---|---|---|
| k₁ | 0.833 | 0.500 | 0.333 |
| k₂ | 0.500 | 1.500 | 1.000 |
| k₃ | 0.333 | 1.000 | 1.333 |

Eigenvalues: [0.382, 0.667, 2.618]. All positive, confirming energy non-negativity.

Effective resistance R(0,2) = 1.500 = 1/(1/3 + 1/3), confirming the parallel resistance formula.

### 6.2 Theta Graph (Genus 2)

Path lengths (2, 3, 5). Genus = 2.

Poles-only support S = {0,1}: rank(Q) = 1 < 2 = genus. This demonstrates that the support set must be sufficiently large to capture full Jacobian information.

Full support S = {0,1,2,3,4}: rank(Q) = 4 > genus. The extra rank reflects S-support structure beyond topological genus.

### 6.3 Pendant-Tree Pruning

Lollipop graph (cycle C₄ + pendant stick). Energy eigenvalues on core vertices:

| Stick length | λ₁ | λ₂ | λ₃ |
|---|---|---|---|
| 1.0 | 0.2929 | 0.5000 | 1.7071 |
| 10.0 | 0.2929 | 0.5000 | 1.7071 |
| 100.0 | 0.2929 | 0.5000 | 1.7071 |

Eigenvalues are *exactly* invariant under pendant attachment, confirming Theorem 3.7.

### 6.4 Subdivision Convergence

Cycle C₃ with edge lengths [1, √2, π/2] under uniform subdivision:

| Level | |K - K_prev| | λ₁ | λ₂ |
|---|---|---|---|
| 0 | — | 0.4434 | 1.2573 |
| 1 | 5.6×10⁻¹⁷ | 0.4434 | 1.2573 |
| 2 | 3.3×10⁻¹⁶ | 0.4434 | 1.2573 |
| 3 | 4.4×10⁻¹⁶ | 0.4434 | 1.2573 |

Kernel matrices are preserved to machine precision under subdivision.

---

## 7. Discussion

### 7.1 Significance

This work provides the first formally verified computational framework for canonical kernels on metric graph models. The key contributions are:

1. **Formal rigor:** All core theorems verified in Lean 4 with standard axioms only.
2. **Algorithmic utility:** Pendant-tree pruning reduces computation to the cycle core.
3. **Cross-domain unification:** A single mathematical framework connects electrical networks, tropical geometry, quantum graphs, and statistical mechanics.
4. **Subdivision stability:** Canonical kernel data is intrinsic to the metric graph, independent of discretization.

### 7.2 Limitations

- The current formalization works with vertex-based models. Full metric graph theory (points on edge interiors) would require additional infrastructure.
- Existence of normalized kernels is not formally proved (it follows from linear algebra / rank-nullity, which we verify computationally).
- The Jacobian quotient isomorphism is stated but not fully formalized.

### 7.3 Conjectures

**Conjecture A (Resolution stability).** The canonical kernel matrices K_n computed on uniform subdivisions converge to a limit K_∞ independent of the subdivision scheme.

*Status:* Computationally confirmed to machine precision. A formal proof would require extending the theory to continuous metric graphs.

**Conjecture B (Core-support sufficiency).** If S meets every cycle of Γ, then the canonical kernel quotient realizes the full Jacobian J(Γ).

*Status:* Partially falsified — the theta graph with poles-only support gives rank 1 < genus 2. The conjecture needs strengthening to require sufficiently many points on each cycle.

---

## 8. Future Work

1. Formalize existence of normalized kernels via matrix rank theory in Lean 4.
2. Extend to continuous metric graphs (points on edge interiors) with PL functions.
3. Prove the full Jacobian quotient isomorphism.
4. Connect to Baker-Norine Riemann-Roch via the canonical kernel calculus.
5. Develop certified tropical Abel-Jacobi algorithms for genus ≥ 3.

---

## References

[BF06] Baker, M. and Faber, X. "Metrized graphs, Laplacian operators, and electrical networks." *Quantum Graphs and Their Applications*, Contemporary Mathematics 415 (2006).

[BN07] Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph." *Advances in Mathematics* 215 (2007), 766–788.

[BF11] Baker, M. and Faber, X. "Metric properties of the tropical Abel-Jacobi map." *Journal of Algebraic Combinatorics* 33 (2011), 349–381.

[Dha90] Dhar, D. "Self-organized critical state of sandpile automaton models." *Physical Review Letters* 64 (1990), 1613.

[Mat24] The Mathlib Community. "Mathlib: the Lean mathematical library." 2024.

[MZ08] Mikhalkin, G. and Zharkov, I. "Tropical curves, their Jacobians and theta functions." *Curves and Abelian Varieties*, Contemporary Mathematics 465 (2008), 203–230.
