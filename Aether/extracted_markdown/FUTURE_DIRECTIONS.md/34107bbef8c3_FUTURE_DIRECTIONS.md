# Future Directions: Certified Inverse Metric Reconstruction

## Overview

This document outlines 5 concrete breakthrough next steps building on the formalized tree metric reconstruction theory. Each direction includes a precise theorem statement, proof strategy, dependencies, and cross-domain connections.

---

## Direction 1: Complete Cherry Reduction Formalization

### Theorem Statement

```lean
theorem cherry_reduction_preserves_metric {n : ℕ} (hn : 4 ≤ n)
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D) (h4 : FourPointCondition D)
    (i j : Fin n) (hc : IsCherryPair D i j) :
    let D' := cherryReduceMetric D i j
    IsFiniteMetric D' ∧ FourPointCondition D' ∧
    ∀ t' : LBTree, t'.Realizes D' →
      (cherryExtendTree t' i j (pendantLength D i j) (pendantLength D j i)).Realizes D
```

### Proof Strategy

1. **Define `cherryReduceMetric`**: Map Fin(n-1) → Fin(n) by skipping index j. For the merged point (corresponding to i), set D'(i',k') = D(i,k) - pendantLength(D,i,j,k_ref).
2. **Prove IsFiniteMetric preservation**: Triangle inequality for D' follows from triangle inequality for D and the cherry condition.
3. **Prove FourPointCondition preservation**: The four-point condition for D' follows from D's four-point condition and the cherry pair property.
4. **Define `cherryExtendTree`**: Replace the leaf labeled i in the reduced tree with a cherry subtree (internal node → leaf i, leaf j).
5. **Prove distance preservation**: Show that distances in the extended tree match D.

### Dependencies

- `IsCherryPair` definition (proved to exist)
- `pendantLength` properties (proved)
- `LBTree.dist` infrastructure (proved)
- Index manipulation lemmas for Fin(n) → Fin(n-1)

### Cross-Domain Connection

**Phylogenetics**: The cherry reduction is exactly the neighbor-joining step used in computational evolutionary biology. Formalizing it creates a verified foundation for phylogenetic software.

---

## Direction 2: Uniqueness / Canonicity Theorem

### Theorem Statement

```lean
/-- Two reduced tree realizations of the same metric are isomorphic
as weighted leaf-labeled trees. -/
theorem tree_realization_unique
    {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D) (h4 : FourPointCondition D)
    (t₁ t₂ : LBTree)
    (hr₁ : t₁.Realizes D) (hr₂ : t₂.Realizes D)
    (hred₁ : t₁.IsReduced) (hred₂ : t₂.IsReduced) :
    WeightedTreeIsomorphic t₁ t₂
```

### Proof Strategy

1. **Define `IsReduced`**: A tree is reduced if no internal node has degree 2 and no edge has weight 0 (except possibly root edges).
2. **Define `WeightedTreeIsomorphic`**: Two trees are isomorphic if there's a bijection on vertices preserving adjacency, labels, and edge weights.
3. **Prove by induction on n**: For n ≤ 3, direct. For n ≥ 4, both trees must have the same cherry pairs (determinable from D). Remove the same cherry from both, apply IH.
4. **Key lemma**: Cherry pairs are determined by D alone, not by the tree. Two different reduced trees must have the same set of cherries.

### Dependencies

- `exists_lbtree_realization` (general existence)
- `cherry_pair_exists` (proved)
- Tree isomorphism infrastructure

### Cross-Domain Connection

**Tropical geometry**: Uniqueness of reduced trees corresponds to the fact that points in the interior of maximal cones of the tropical Grassmannian have unique combinatorial types. This connects to the theory of tropical moduli spaces.

---

## Direction 3: Noisy Stability Theorem

### Theorem Statement

```lean
/-- If D is within ε of a tree metric D₀, then there exists a tree
whose distances are within f(ε,n) of D. -/
theorem noisy_reconstruction_stability {n : ℕ}
    (D D₀ : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D) (hm₀ : IsFiniteMetric D₀)
    (h4₀ : FourPointCondition D₀)
    (hclose : ∀ i j, |D i j - D₀ i j| ≤ ε)
    (hε : 0 ≤ ε) :
    ∃ t : LBTree,
      ∀ i j : Fin n, |t.dist i j - D i j| ≤ (2 * n - 2) * ε
```

### Proof Strategy

1. **Reconstruct from D₀** (exact): obtain tree t₀ realizing D₀.
2. **Perturb edge weights**: Adjust each edge weight by at most ε to match D as closely as possible.
3. **Error propagation**: Each leaf-to-leaf path traverses at most 2n-2 edges (diameter of binary tree), so errors accumulate additively.
4. **Alternative**: Use the Buneman algorithm on D directly and bound the four-point violation's effect on the output.

### Dependencies

- `exists_lbtree_realization` (for exact reconstruction of D₀)
- `LBTree.dist` properties
- Pendant length continuity estimates

### Cross-Domain Connection

**Network tomography**: Real network delay measurements are noisy. The stability theorem would provide certified error bounds for network topology inference from noisy measurements.

---

## Direction 4: Series-Parallel Graph Reconstruction

### Theorem Statement

```lean
/-- Characterize when a metric is realizable by a weighted
series-parallel graph, and provide a reconstruction algorithm. -/
def IsSPMetric {n : ℕ} (D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  IsFiniteMetric D ∧ SPCondition D

theorem exists_sp_realization {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hsp : IsSPMetric D) :
    ∃ G : SPGraph n, G.Realizes D
```

### Proof Strategy

1. **Define SPGraph**: Series-parallel graphs built from single edges by series (path concatenation) and parallel (edge doubling) composition.
2. **Define SPCondition**: The analogue of the four-point condition for series-parallel metrics. This involves constraints on sextets of distances (6-point conditions).
3. **Prove existence by induction on the SP decomposition tree**: Each series or parallel operation corresponds to a specific metric transformation.
4. **Complexity**: The reconstruction should be polynomial (likely O(n⁴)).

### Dependencies

- `IsFiniteMetric` (proved)
- Tree reconstruction infrastructure (as a subcase)
- Shortest-path algorithms for SP graphs

### Cross-Domain Connection

**Electrical networks**: Series-parallel circuits are the simplest non-tree networks. Resistance distances in SP circuits satisfy specific metric constraints. Formalizing their reconstruction connects to circuit analysis and reliability theory.

---

## Direction 5: Tropical Grassmannian Characterization

### Theorem Statement

```lean
/-- Four-point metrics correspond to points in the tropical
Grassmannian Gr(2,n), providing an algebraic characterization
of tree realizability. -/
theorem four_point_iff_tropical_grassmannian {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D) :
    FourPointCondition D ↔ D ∈ TropicalGrassmannian 2 n
```

### Proof Strategy

1. **Define the tropical Grassmannian** Gr(2,n) as the set of distance matrices satisfying tropical Plücker relations.
2. **Show equivalence**: The tropical Plücker relations for Gr(2,n) are exactly the four-point conditions when restricted to symmetric zero-diagonal matrices.
3. **Prove the forward direction**: Four-point condition implies Plücker relations (coordinate transformation).
4. **Prove the reverse direction**: Plücker relations plus metric axioms imply four-point (algebraic manipulation).

### Dependencies

- `FourPointCondition` (defined)
- Tropical semiring definitions
- Tropical Plücker coordinates

### Cross-Domain Connection

**Algebraic geometry**: The tropical Grassmannian is a fundamental object in tropical algebraic geometry. Connecting it to tree metrics creates a bridge between combinatorial optimization, algebraic geometry, and phylogenetics. This direction would also connect to the Dressian and the theory of valuated matroids.

---

## Implementation Priority

1. **Direction 1** (Cherry reduction) — Highest priority, completes the main theorem
2. **Direction 2** (Uniqueness) — Natural next theorem, moderate difficulty
3. **Direction 3** (Stability) — High practical impact, moderate difficulty
4. **Direction 4** (Series-parallel) — Novel research direction, high difficulty
5. **Direction 5** (Tropical) — Most visionary, requires new infrastructure

Each direction builds on the current cycle's definitions and theorems, particularly `IsFiniteMetric`, `FourPointCondition`, `LBTree`, `pendantLength`, and `cherry_pair_exists`.
