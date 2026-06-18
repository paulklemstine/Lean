# Future Directions: Tropical Metric Rigidity and Phylogenetic Reconstruction

This document outlines breakthrough-level research directions opened by the cherry pair metric invariance theorem and its surrounding infrastructure.

---

## 1. Full Reduced-Tree Uniqueness Up to Isomorphism

### Target Theorem
```
theorem reduced_realization_same_topology
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D) (h4 : FourPointCondition D)
    (T₁ T₂ : LBTree) (hred₁ : T₁.Reduced) (hred₂ : T₂.Reduced)
    (hreal₁ : T₁.Realizes D) (hreal₂ : T₂.Realizes D)
    (hlabels₁ : T₁.labels = ...) (hlabels₂ : T₂.labels = ...) :
    T₁.SameTopology T₂
```

### Why It Matters
This is the formal version of Buneman's fundamental theorem: the four-point condition determines a unique reduced tree. Our current development reduces cherry invariance to this single theorem, which is already stated with its precise hypotheses. Proving it would eliminate the last `sorry` in the cherry invariance chain and establish the first complete formal proof of tree-metric uniqueness.

### Proof Strategy
- **Strong induction on n.** For n ≤ 3, direct case analysis (infrastructure already exists: `tripodTree_realizes` for n=3).
- **For n ≥ 4:** Use `cherry_pair_exists` to identify a cherry pair detectable from the metric. Show this cherry must appear in both T₁ and T₂ (requires proving the backward direction: metric cherry detection → structural cherry, which is more subtle than IsCherryPair alone). Prune the cherry in both trees to get (n-1)-leaf realizations. Apply IH.
- **Key sub-lemma needed:** A correct metric characterization of cherry pairs (stronger than `IsCherryPair`, which characterizes splits, not cherries). The characterization should involve the Gromov product maximization: (a,b) is a cherry iff it maximizes the Gromov product (a|b)_r over all pairs for some reference r.

### Feasibility
High. All infrastructure is in place. The main barrier is the correct metric cherry characterization and the pruning/re-attachment formalization.

### Cross-Domain Connections
- Tropical geometry: uniqueness corresponds to points in the interior of maximal cones of the tropical Grassmannian Gr(2,n) determining unique combinatorial types.
- Moduli theory: formalizes a key property of the tropical moduli space M_{0,n}^{trop}.

---

## 2. Cone-Interior Uniqueness for Tropical Tree Space

### Target Theorem
```
theorem cone_interior_determines_combinatorial_type
    (σ : CombType n)   -- a combinatorial type (tree topology)
    (D : Matrix (Fin n) (Fin n) ℝ)
    (h_interior : D ∈ relativeInterior (cone σ))
    (h_tree : IsTreeMetric D) :
    ∀ σ', D ∈ cone σ' → σ' = σ
```

### Why It Matters
This is the tropical-geometric reformulation of tree uniqueness. The space of tree metrics on n leaves decomposes into cones indexed by combinatorial types. A metric in the relative interior of a cone has a unique combinatorial type — it cannot lie in the interior of any other cone. This is the fundamental structure theorem for the tropical Grassmannian.

### Proof Strategy
- Build on `reduced_realization_same_topology` by defining the cone structure explicitly.
- Each cone is defined by the set of tree metrics with a given topology (edge-weight positivity gives the interior).
- The `Reduced` condition in our development corresponds exactly to lying in the relative interior.
- Use `tropical_fundamental_theorem` and `tropical_interior_convex` from the catalog as foundational tools.

### Feasibility
Medium-high. Requires formalizing the cone decomposition of tree space, which is additional infrastructure but mathematically well-understood.

---

## 3. Stability of Full Combinatorial Type Under Perturbations

### Target Theorem
```
theorem combinatorial_type_stable_under_perturbation
    (D₀ : Matrix (Fin n) (Fin n) ℝ)
    (h_tree : IsTreeMetric D₀)
    (h_sep : combinatorial_type_separation_margin D₀ > δ)
    (D : Matrix (Fin n) (Fin n) ℝ)
    (h_close : ∀ i j, |D i j - D₀ i j| ≤ ε)
    (h_ε : ε < δ / C(n)) :
    combinatorial_type_of D = combinatorial_type_of D₀
```

### Why It Matters
Extends our noisy cherry stability theorems (`noisy_cherry_forward`, `noisy_cherry_backward`) from individual cherry pairs to the FULL combinatorial type. This is the entry point to certified robust phylogenetic reconstruction: if input distances are close enough to a tree metric, the reconstructed tree topology is guaranteed correct.

### Proof Strategy
- **Bottom-up from cherries.** Use the noisy cherry stability results as the base case.
- **Recursive pruning.** After certifiably detecting a cherry pair under noise, prune it and check that the reduced metric is still close to a tree metric.
- **Error propagation.** Track how perturbation error grows through the pruning process. The constant C(n) should be polynomial in n.
- The separation margin `δ` corresponds to the minimum edge weight in the reduced tree (distance from cone boundary).

### Feasibility
Medium. The individual perturbation bounds are proved. The main challenge is tracking error propagation through recursive reconstruction. The constant C(n) needs to be made explicit.

### Applications
- Phylogenetic reconstruction from noisy empirical data with correctness guarantees.
- Condition number theory for the tree-metric inverse problem.
- Robust statistics for distance-based methods in bioinformatics.

---

## 4. Certified Reconstruction Algorithm with Formal Correctness Proof

### Target Theorem
```
theorem cherry_picking_correct
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D) (h4 : FourPointCondition D) :
    let T := cherry_picking_algorithm D
    T.Realizes D ∧ T.Reduced
```

### Why It Matters
Cherry-picking (recursive pruning of cherry pairs) is the simplest tree reconstruction algorithm. A formal correctness proof would be the first certified phylogenetic reconstruction algorithm — the tree output is mathematically guaranteed to realize the input distance matrix.

### Proof Strategy
- Define `cherry_picking_algorithm` as a computable function.
- Use `cherry_pair_exists` to find a cherry at each step.
- Prove that pruning preserves the four-point condition on the reduced matrix.
- Prove that the reconstructed tree has the correct distances.
- The existing `exists_lbtree_realization` provides the existence framework; making it algorithmic requires choosing a specific cherry detection strategy.

### Feasibility
High. The mathematical content is in `cherry_pair_exists` and `exists_lbtree_realization`. The main work is defining the algorithm computably and proving termination.

### Applications
- Certified bioinformatics software.
- Formally verified phylogenetic pipelines.
- Template for certifying other tree reconstruction algorithms (neighbor joining, UPGMA).

---

## 5. Bridge Between Four-Point Tree Metrics and Tropical Plücker Fan Structure

### Target Theorem
```
theorem four_point_cone_is_tropical_plucker
    (D : TreeMetric n) :
    D ∈ tropicalization (Grassmannian 2 n) ↔
    FourPointCondition D.matrix
```

### Why It Matters
The space of tree metrics on n leaves IS the tropical Grassmannian Gr(2,n) — this is the Speyer-Sturmfels theorem. Formalizing this connection would bridge our finite metric/phylogenetic development with the tropical algebraic geometry catalog. It would place tree-metric uniqueness and cherry detection in the context of tropical variety structure.

### Proof Strategy
- Define the tropical Grassmannian as the tropicalization of the Plücker embedding.
- The Plücker coordinates correspond to pairwise distances (up to tropical scaling).
- The four-point condition is exactly the tropical Plücker relation for 2-by-n matrices.
- Connect to existing tropical catalog results (`tropical_fundamental_theorem`).

### Feasibility
Medium-low. Requires substantial tropical algebraic geometry infrastructure (tropicalization, Plücker embedding, tropical varieties). However, the statement itself is well-known and the n=4 case is tractable.

### Cross-Domain Significance
This is the "Rosetta Stone" theorem connecting:
- Finite metric geometry (four-point condition)
- Algebraic geometry (Grassmannian)
- Tropical geometry (tropicalization)
- Phylogenetics (tree reconstruction)

A formal proof would be a landmark result connecting these four domains.

---

## Summary of Dependencies

```
                    [5. Tropical Plücker]
                           ↑
                    [2. Cone Interior]
                           ↑
              [1. Full Tree Uniqueness]  ←→  [4. Certified Algorithm]
                     ↑           ↑
         [cherry_pair_metric_invariant]
                     ↑
    [cherry_dist_diff_eq_rootDist_diff]
         [same_topology_cherry_iff]
              [noisy stability]
                     ↑
           [3. Full Stability]
```

Each direction builds on the current development and opens new formal research territory at the intersection of tropical geometry, metric rigidity, and algorithmic phylogenetics.
