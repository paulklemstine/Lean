# Future Directions: Tropical Lens Rigidity Duality

## Overview

The tropical lens rigidity duality theorem establishes that boundary geodesic data — specifically, the min-plus semimodule of distance profiles — is a complete invariant for rigid metric trees. This opens multiple research frontiers at the intersection of tropical algebra, inverse geometry, combinatorics, and applications. Below are five concrete breakthrough-level next steps.

---

## Direction 1: Extension from Star Trees to General Trees via Buneman Split Decomposition

**Status:** The current formalization proves rigidity, unique realization, and certified reconstruction for **star trees** (single internal vertex). The natural next step is the full Buneman theory.

**Target Theorem:**
```
theorem buneman_split_decomposition_duality
  {b : ℕ} (hb : 4 ≤ b)
  (d : Fin b → Fin b → ℚ)
  (hmetric : IsMetric d)
  (h4pt : FourPointCondition d) :
  ∃! S : SplitSystem b,
    S.BoundarySeparating ∧
    (∀ i j, S.dist i j = d i j) ∧
    S.IsMinimal
```

**Proof Strategy:**
1. Define the **Buneman index** for each candidate split: `β(A|B) = min_{a∈A, b∈B} (d(a,x) + d(b,y) - d(a,b) - d(x,y))/2` for suitable x, y.
2. Show that splits with positive Buneman index are pairwise compatible (this is the heart of the Buneman theorem).
3. Prove the split weights are uniquely determined by the distance matrix.
4. Show the reconstructed split-system distance equals the original.

**Key Lemma Needed:**
```
lemma positive_buneman_splits_compatible
  (d : Fin b → Fin b → ℚ) (h4pt : FourPointCondition d)
  (S₁ S₂ : Split b) (hS₁ : 0 < bunemanIndex d S₁) (hS₂ : 0 < bunemanIndex d S₂) :
  S₁.Compatible S₂
```

**Impact:** This would give the complete finite tree metric reconstruction theorem in Lean, connecting to decades of work in phylogenetics and combinatorial optimization.

---

## Direction 2: Tropical Injective Hull / Tight Span Formalization

**Target:** Formalize the Dress–Terhalle tight span construction and prove it coincides with the geodesic semimodule's tropical convex hull.

**Target Theorem:**
```
theorem tight_span_is_tropical_convex_hull
  (d : Fin b → Fin b → ℚ) (h4pt : FourPointCondition d) :
  tightSpan d ≅ tropicalConvexHull (distanceProfiles d)
```

**Mathematical Content:**
- The **tight span** (or injective envelope) of a metric space `(X, d)` is the set of functions `f : X → ℝ` satisfying `f(x) + f(y) ≥ d(x,y)` for all `x,y` and achieving equality for some `y` at each `x`.
- For tree metrics, the tight span is 1-dimensional (a tree!).
- The tight span coincides with the tropical convex hull of the distance rows.

**Proof Strategy:**
1. Define the tight span as a subset of `Fin b → ℚ`.
2. Show it is a tropical (min-plus) convex set.
3. For tree metrics, show the tight span has the structure of the original tree.
4. Identify the geodesic semimodule's generators as extremal points of the tight span.

**Impact:** Connects tropical convexity theory to metric geometry and would be the first formalization of tight spans, opening a rich vein of computational tropical geometry.

---

## Direction 3: Stable Reconstruction Under Perturbation — Certified Error Bounds

**Target:** Prove that small perturbations of tree-metric boundary data yield approximately correct tree reconstructions, with explicit error bounds.

**Target Theorem:**
```
theorem stable_star_reconstruction
  {b : ℕ} (hb : 3 ≤ b)
  (w : Fin b → ℚ) (hw : ∀ i, 0 < w i)
  (d : Fin b → Fin b → ℚ)
  (hclose : ∀ i j, |d i j - starDist w i j| ≤ ε) :
  ∀ i, |reconstructStarWeights d j₀ k₀ i - w i| ≤ 3 * ε / 2
```

**Proof Strategy:**
1. The reconstruction formula is linear in the distances, so perturbation analysis is straightforward.
2. For general trees, analyze the condition number of the split → distance map.
3. Prove that the four-point condition violation serves as a certificate of non-tree-likeness, with quantitative bounds.

**Applications:**
- **Network tomography:** Real-world measurements are noisy. Certified error bounds guarantee that reconstructed topologies are close to the true network.
- **Phylogenetics:** Evolutionary distance estimates from sequence alignment have statistical error. Stable reconstruction is essential for practical tree inference.
- **Machine learning:** Verifying learned metric spaces are approximately tree-like, with confidence intervals on the recovered tree parameters.

---

## Direction 4: Categorification — Tropical Tannaka Reconstruction for Metric Networks

**Target:** Lift the rigidity duality from an object-level theorem to a categorical equivalence between a category of rigid weighted trees and a category of separated tropical semimodules.

**Target Theorem:**
```
theorem tropical_tannaka_equivalence :
  CategoryEquivalence RigidWeightedTreeCat SeparatedTropicalSemimoduleCat
```

**Mathematical Content:**
- Define `RigidWeightedTreeCat` with objects = rigid weighted trees, morphisms = weight-preserving graph homomorphisms.
- Define `SeparatedTropicalSemimoduleCat` with objects = finitely generated separated geodesic semimodules satisfying four-point, morphisms = tropical semimodule homomorphisms preserving extremal generators.
- The geodesic semimodule functor `G : TreeCat → SemimodCat` is full, faithful, and essentially surjective.

**Proof Strategy:**
1. Full faithfulness follows from the rigidity theorem (morphisms between semimodules = morphisms between trees).
2. Essential surjectivity follows from the realization theorem.
3. Package into a Lean category theory framework using Mathlib's `CategoryTheory`.

**Impact:** This is a "Tannaka duality for metric trees" — recovering geometric objects from their algebraic representations. It would be the first formal categorical duality theorem in tropical geometry.

---

## Direction 5: Extension to Graphs with Cycles — Tropical Cycle Defect and Block-Graph Rigidity

**Target:** Extend the rigidity framework from trees to graphs with controlled cycle structure (cactus graphs, block graphs, series-parallel graphs).

**Target Theorem:**
```
theorem block_graph_rigidity_with_cycle_defect
  (G : BlockGraph α) (hrig : G.IsRigid)
  (hcycle : G.CycleDefect ≤ k) :
  G.GeodesicSemimodule.MinimalGeneratingSetSize = G.EdgeCount + G.CycleDefect
```

**Mathematical Content:**
- For graphs with cycles, the four-point condition fails. The **cycle defect** measures how far a metric is from being a tree metric.
- Block graphs (graphs where every biconnected component is a clique) are a natural generalization of trees.
- The geodesic semimodule of a block graph has additional generators corresponding to cycle contributions.
- Rigidity holds if the cycle defect is bounded and the generators satisfy "tropical Kirchhoff equations."

**Proof Strategy:**
1. Define block decomposition and cycle defect for finite weighted graphs.
2. Show that each biconnected component contributes independent generators to the semimodule.
3. Prove that the block tree structure is recoverable from the semimodule's "tree part," and cycle contributions are recoverable from the "defect generators."
4. Establish uniqueness under the condition that generators respect the block structure.

**Applications:**
- **Network tomography with redundant paths:** Real networks have cycles for redundancy. Block-graph rigidity handles this case.
- **Chemical graph theory:** Molecular graphs often have cactus or block-graph structure.
- **Tropical Hodge theory:** Cycle defects connect to tropical homology and Betti numbers.

---

## Cross-Domain Research Connections

Each direction above connects to multiple application domains:

| Direction | Phylogenetics | Network Tomography | Tropical Geometry | Machine Learning |
|-----------|:---:|:---:|:---:|:---:|
| 1. Buneman | Core | Medium | High | Medium |
| 2. Tight Span | Medium | Low | Core | Low |
| 3. Stability | High | Core | Medium | Core |
| 4. Categorify | Low | Low | Core | Low |
| 5. Cycles | Medium | Core | High | Medium |

## Implementation Priorities

1. **Direction 1** (Buneman) is the highest-impact formalization target — it completes the classical theory.
2. **Direction 3** (Stability) has the most immediate practical value for applications.
3. **Direction 4** (Categorification) has the highest mathematical novelty but requires significant categorical infrastructure.
4. **Directions 2 and 5** are more exploratory but could yield breakthrough results in tropical convexity and graph rigidity respectively.
