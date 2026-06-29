# Néron Component Groups via Tropical Jacobians: A Verified Computational Pipeline

## Abstract

We develop a formal, computationally verified bridge between the Néron component group Φ_J of the Jacobian of a semistable curve and the tropical Jacobian (critical group) of its dual graph. We introduce the notion of *semistable dual graph data* — a weighted graph Laplacian satisfying symmetry, zero row sums, and off-diagonal nonpositivity — and define the *reduced Laplacian cokernel* as a precise model for the tropical Jacobian. We prove that the reduced Laplacian is symmetric, that graph Laplacians are positive semidefinite (implying nonneg determinants for reduced Laplacians), and verify through explicit computation that det(L_red) equals the spanning tree count for several families of graphs. The arithmetic comparison principle is formalized as an axiomatized interface: given a bijective specialization map, the component group is isomorphic to the tropical Jacobian. We implement a complete computational pipeline (graph → Laplacian → SNF → invariant factors) and verify it against known results for genus-1 and genus-2 semistable reduction types. All key definitions and several theorems are machine-verified in Lean 4 with Mathlib.

**Keywords:** Néron model, component group, tropical Jacobian, graph Jacobian, critical group, semistable reduction, dual graph, Smith normal form, reduced Laplacian, matrix-tree theorem, Baker specialization, Raynaud theorem

---

## 1. Introduction

### 1.1 Motivation

The Néron component group Φ_J of the Jacobian J of a curve X over a discretely valued field K is a fundamental arithmetic invariant. It appears in:

- The **Birch and Swinnerton-Dyer conjecture**, where the product of local Tamagawa numbers c_v = |Φ_J(k_v)| enters the leading coefficient formula.
- **Chabauty-Coleman methods** for bounding rational points, where component group structure affects the local analysis.
- **Explicit BSD computations**, where Tamagawa numbers must be computed for each prime of bad reduction.

Despite its importance, computing Φ_J traditionally requires constructing the Néron model explicitly — a formidable task beyond genus 1.

### 1.2 The Graph-Theoretic Approach

The key insight, due to Raynaud [Ray70] and refined by Baker [Bak08], is that for semistable curves, Φ_J is completely determined by the dual graph Γ of the special fiber. Specifically:

**Theorem (Raynaud).** For a semistable curve X/K with dual graph Γ, the component group of the Néron model of Jac(X) is canonically isomorphic to the *tropical Jacobian* (critical group) of Γ.

The tropical Jacobian can be computed as the cokernel of the reduced Laplacian:

$$\Phi_J \cong \text{coker}(L_{\text{red}}) = \mathbb{Z}^{|V|-1} / \text{im}(L_{\text{red}})$$

This reduces the computation of a deep arithmetic invariant to integer linear algebra.

### 1.3 Contributions

1. **Formal definitions** of semistable dual graph data, reduced Laplacian, and tropical Jacobian cokernel in Lean 4 (§3).
2. **Machine-verified proofs** of symmetry, kernel structure, and PSD/nonneg determinant properties of graph Laplacians (§4).
3. **An axiomatized arithmetic interface** (the SpecializationComponentBridge) that cleanly separates the combinatorial engine from the arithmetic identification (§5).
4. **Concrete verified computations** for K₃, K₄, C₅, banana graphs, theta graphs, and genus-2 chain graphs (§6).
5. **A complete computational pipeline** in Python implementing the SNF-based algorithm with verified examples (§7).
6. **A testable conjecture** for genus-2 hyperelliptic curves, verified against known reduction types (§8).

---

## 2. Definitions and Notation

### 2.1 Semistable Dual Graph Data

**Definition 2.1.** A *semistable dual graph datum* is a tuple (V, L, connected, symmetric, rowSumZero, offDiag_nonpos) where:
- V is a finite set (vertices of the dual graph)
- L : V × V → ℤ is the weighted graph Laplacian
- Lᵀ = L (symmetry)
- ∀v, Σ_w L(v,w) = 0 (zero row sums)
- ∀v ≠ w, L(v,w) ≤ 0 (nonpositive off-diagonal)

The off-diagonal entries -L(v,w) ≥ 0 encode edge weights (multiplicities of intersection points in the special fiber).

### 2.2 Reduced Laplacian

**Definition 2.2.** For a vertex v₀ ∈ V, the *reduced Laplacian* L_red is the principal submatrix of L obtained by deleting the row and column of v₀:

$$L_{\text{red}} = L[V \setminus \{v_0\}, V \setminus \{v_0\}]$$

### 2.3 Tropical Jacobian / Critical Group

**Definition 2.3.** The *tropical Jacobian* (or *critical group*, or *graph Jacobian*) is:

$$\text{Jac}(\Gamma) = \mathbb{Z}^{V \setminus \{v_0\}} / \text{im}(L_{\text{red}})$$

This is the cokernel of L_red viewed as a ℤ-linear map.

### 2.4 Specialization Component Bridge

**Definition 2.4.** A *specialization component bridge* for a semistable dual graph datum G with distinguished vertex v₀ consists of:
- A type Φ with additive commutative group structure (the Néron component group)
- A group homomorphism toTrop : Φ →+ Jac(Γ)
- Proofs that toTrop is both injective and surjective

This axiomatizes Raynaud's theorem in a way that separates the combinatorial computation from the arithmetic identification.

---

## 3. Formalization in Lean 4

### 3.1 Structure Definitions

```lean
structure SemistableDualGraphData where
  V : Type
  [fintype_V : Fintype V]
  [decEq_V : DecidableEq V]
  laplacian : Matrix V V ℤ
  connected : Prop
  symmetric : laplacianᵀ = laplacian
  rowSumZero : ∀ v, ∑ w, laplacian v w = 0
  offDiag_nonpos : ∀ v w, v ≠ w → laplacian v w ≤ 0

noncomputable def reducedLaplacian (L : Matrix V V ℤ) (v0 : V) :=
  L.submatrix Subtype.val Subtype.val

noncomputable def reducedLaplacianCokernel (L : Matrix V V ℤ) (v0 : V) :=
  ({v : V // v ≠ v0} → ℤ) ⧸ (laplacianImageSubmodule L v0).toAddSubgroup
```

### 3.2 Key Theorems (Verified)

1. **Reduced Laplacian symmetry:** If Lᵀ = L, then (L_red)ᵀ = L_red.
2. **Column sum zero:** Symmetry + row sum zero implies column sum zero.
3. **Kernel contains constants:** L · (const c) = 0 for all c ∈ ℤ.
4. **Diagonal nonnegativity:** Off-diagonal nonpositivity + row sum zero implies L(v,v) ≥ 0.
5. **PSD determinant:** det(L_red) ≥ 0 for any graph Laplacian (via eigenvalue argument).
6. **Arithmetic comparison:** Given a bijective specialization map, Φ ≃+ Jac(Γ).

### 3.3 Computational Verifications

- det(L_red(K₃)) = 3 ✓
- det(L_red(K₄)) = 16 ✓
- det(L_red(banana(n))) = n ✓
- det(L_red(theta)) = 3 ✓
- det(L_red(genus-2 chain)) = 2 ✓

---

## 4. Main Results

### 4.1 Theorem: Reduced Laplacian Determinant is Nonnegative

**Theorem 4.1.** For any semistable dual graph datum G with Laplacian L and vertex v₀, det(L_red) ≥ 0.

*Proof sketch.* The quadratic form x^T L x equals Σ_{i≠j} (-L(i,j))(x_i - x_j)²/2 ≥ 0, since -L(i,j) ≥ 0 for i ≠ j. Restricting to x with x(v₀) = 0 gives PSD of L_red over ℝ. PSD matrices have nonneg eigenvalues, so their determinant (product of eigenvalues) is nonneg. The integer determinant equals the real determinant, giving det(L_red) ≥ 0 over ℤ. □

This proof is fully machine-verified in Lean 4.

### 4.2 Theorem: Arithmetic Comparison Principle

**Theorem 4.2.** Given a specialization component bridge B with bijective toTrop, the component group Φ is isomorphic as an additive group to Jac(Γ).

*Proof.* Construct AddEquiv.ofBijective from the bijective AddMonoidHom. □

### 4.3 Theorem (Stated): Independence of Deleted Vertex

**Theorem 4.3.** For a matrix L with zero row sums and any vertices v₁, v₂, there exists an additive group isomorphism coker(L_red(v₁)) ≃+ coker(L_red(v₂)).

*Proof strategy.* Both cokernels are isomorphic to Div⁰(Γ)/Prin(Γ), the quotient of degree-zero divisors by principal divisors. The projection ℤ^{V\{v₀}} → Div⁰ extends by the constraint Σf = 0, and this extension intertwines the reduced Laplacian images.

### 4.4 Theorem (Stated): Cardinality = |det|

**Theorem 4.4.** When det(L_red) ≠ 0, the cokernel is finite with |coker(L_red)| = |det(L_red)|.

*Proof strategy.* Via Smith Normal Form: L_red = UDV with U, V unimodular, D diagonal. Then coker(L_red) ≅ ⊕ ℤ/d_iℤ with |coker| = ∏|d_i| = |det(D)| = |det(L_red)|.

### 4.5 Theorem (Stated): SNF Classification

**Theorem 4.5.** The cokernel of any integer matrix A is isomorphic to a direct sum of cyclic groups ⊕ ℤ/d_iℤ where the d_i are the SNF invariant factors.

---

## 5. Algorithms

### 5.1 Complete Pipeline

**Algorithm:** ComponentGroupFromDualGraph

**Input:** Weighted adjacency matrix A of the dual graph
**Output:** Invariant factors of Φ_J, group structure, order

```
1. L ← GraphLaplacian(A)     // O(n²)
2. L_red ← L[1:,1:]          // O(n²), delete row/col 0
3. D, factors ← SNF(L_red)   // O(n³ log M), M = max entry
4. order ← |det(L_red)|      // O(n³) via Bareiss
5. return factors, order
```

**Complexity:** O(n³ log M) where n = |V| and M = max |L_red(i,j)|.

### 5.2 Smith Normal Form Algorithm

The SNF algorithm over ℤ proceeds by:
1. Find a nonzero pivot and move to position (k,k).
2. Use the pivot to eliminate entries in row k and column k via integer division.
3. If the pivot doesn't divide some entry in the remaining submatrix, add the pivot's row to create a smaller entry, and restart.
4. Repeat until all off-diagonal entries in the k-th row and column are zero.
5. The divisibility condition ensures d_k | d_{k+1} for consecutive diagonal entries.

### 5.3 Verified Implementation

The Python implementation in `algorithms.py` provides:
- `graph_laplacian_from_edges(n, edges)`: O(n² + |E|)
- `reduced_laplacian(L, v0)`: O(n²)
- `smith_normal_form(A)`: O(n³ log M)
- `component_group(L, v0)`: Full pipeline

---

## 6. Computational Experiments

### 6.1 Complete Graphs

| Graph | |V| | Spanning Trees | Φ_J | Formula |
|-------|-----|----------------|-----|---------|
| K₂ | 2 | 1 | 0 | n^(n-2) = 1 |
| K₃ | 3 | 3 | ℤ/3ℤ | 3¹ = 3 |
| K₄ | 4 | 16 | ℤ/4ℤ × ℤ/4ℤ | 4² = 16 |
| K₅ | 5 | 125 | (ℤ/5ℤ)³ | 5³ = 125 |
| K₆ | 6 | 1296 | (ℤ/6ℤ)⁴ | 6⁴ = 1296 |

For K_n, the component group is (ℤ/nℤ)^(n-2) with order n^(n-2), matching Cayley's formula.

### 6.2 Cycle Graphs

| Graph | Spanning Trees | Φ_J |
|-------|---------------|-----|
| C₃ | 3 | ℤ/3ℤ |
| C₄ | 4 | ℤ/4ℤ |
| C₅ | 5 | ℤ/5ℤ |
| C_n | n | ℤ/nℤ |

### 6.3 Banana Graphs (n parallel edges between 2 vertices)

| n | Spanning Trees | Φ_J |
|---|---------------|-----|
| 1 | 1 | 0 |
| 2 | 2 | ℤ/2ℤ |
| 3 | 3 | ℤ/3ℤ |
| n | n | ℤ/nℤ |

### 6.4 Genus-2 Reduction Types

| Type | Dual Graph | |Φ_J| | Φ_J |
|------|-----------|-------|-----|
| Good reduction | Point | 1 | 0 |
| Single bridge | Edge | 1 | 0 |
| Banana(2) | Two parallel edges | 2 | ℤ/2ℤ |
| Theta | Three parallel edges | 3 | ℤ/3ℤ |
| Triangle | K₃ | 3 | ℤ/3ℤ |
| Chain (tree) | Path | 1 | 0 |
| Weighted chain | Weighted path | 2 | ℤ/2ℤ |

### 6.5 Vertex Independence Verification

For all tested graphs (K₃, K₄, K₅, C₅, C₆, banana graphs, weighted K₃), the invariant factors computed from the reduced Laplacian are independent of the choice of deleted vertex. This provides strong computational evidence for Theorem 4.3.

---

## 7. Discussion

### 7.1 Cross-Domain Connections

The results establish four precise bridges:

1. **Arithmetic Geometry ↔ Tropical Geometry:** Φ_J ≅ Jac(Γ)
2. **Arithmetic Geometry ↔ Spectral Graph Theory:** |Φ_J| = det(L_red)
3. **Arithmetic Geometry ↔ Statistical Mechanics:** |Φ_J| = τ(Γ) (spanning tree count)
4. **Arithmetic Geometry ↔ Algorithmic Number Theory:** Φ_J computable via SNF in polynomial time

### 7.2 Limitations

The formalization leaves several deep theorems as sorry'd (unproved):
- Independence of the deleted vertex (Theorem 4.3)
- Cardinality = |det| (Theorem 4.4)
- SNF classification (Theorem 4.5)

These require substantial Mathlib infrastructure (quotient module cardinality formulas, full SNF decomposition for modules). The proof strategies are well-understood mathematically, but the formal infrastructure is not yet available.

### 7.3 The Positive Semidefiniteness Proof

The most substantial verified proof is Theorem 4.1 (det(L_red) ≥ 0). This proof:
1. Establishes the quadratic form identity x^T L x = -Σ L(i,j)(x_i-x_j)²/2
2. Shows each term is nonneg from off-diagonal nonpositivity
3. Restricts to the reduced subspace {x : x(v₀) = 0}
4. Lifts to ℝ and applies Matrix.PosSemidef.det_nonneg
5. Casts back to ℤ

This is a multi-step proof combining algebraic, analytic, and spectral arguments.

---

## 8. Conjecture and Predictions

**Conjecture 8.1 (Genus-2 Semistable Hyperelliptic Match).** For every genus-2 hyperelliptic curve over a discretely valued field with semistable reduction and dual graph Γ, the invariant factors of the Néron component group Φ_J agree with the SNF invariant factors of the weighted reduced Laplacian of Γ.

**Testable prediction:** For each tabulated genus-2 semistable reduction type, the SNF computed from the dual graph matches the published component group structure. Our computational experiments confirm this for all standard types.

---

## 9. Future Work

1. Complete the formal proof of vertex independence using the Div⁰/Prin quotient approach.
2. Formalize the SNF classification of integer matrix cokernels in Lean/Mathlib.
3. Extend to metrized complexes and non-Archimedean Berkovich spaces.
4. Apply to explicit BSD computations for higher-genus curves.
5. Explore tropical analogues of the height pairing via effective resistance.

---

## References

[Bak08] Baker, M. "Specialization of linear systems from curves to graphs." Algebra & Number Theory 2 (2008), 613–653.

[BN07] Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph." Advances in Mathematics 215 (2007), 766–788.

[Kir47] Kirchhoff, G. "Über die Auflösung der Gleichungen, auf welche man bei der Untersuchung der linearen Vertheilung galvanischer Ströme geführt wird." Annalen der Physik 148 (1847), 497–508.

[Ner64] Néron, A. "Modèles minimaux des variétés abéliennes sur les corps locaux et globaux." Publications Mathématiques de l'IHÉS 21 (1964), 5–128.

[Ray70] Raynaud, M. "Spécialisation du foncteur de Picard." Publications Mathématiques de l'IHÉS 38 (1970), 27–76.

[Smi61] Smith, H.J.S. "On systems of linear indeterminate equations and congruences." Philosophical Transactions of the Royal Society of London 151 (1861), 293–326.
