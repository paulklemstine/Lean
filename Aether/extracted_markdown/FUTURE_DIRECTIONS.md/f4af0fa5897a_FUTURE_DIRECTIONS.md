# Future Directions: Tropical Geometric Learning Theory

## Overview

This document outlines 5 concrete breakthrough research directions opened by the polyhedral robustness certification framework. Each direction includes specific theorem targets, proof strategies, cross-domain connections, and estimated difficulty.

---

## Direction 1: Exact Inradius Theorem for Tropical Cells

### Hypothesis
For bounded tropical cells (when the max-affine function has a unique global maximizer class on a compact region), the certified radius at a point x equals the radius of the largest inscribed Euclidean ball centered at x. Moreover, the inradius achieves its maximum at the Chebyshev center (analytic center) of the cell.

### Specific Theorem Target
```
theorem tropicalCell_certifiedRadius_eq_inradius
    (a : ι → E) (b : ι → ℝ) (k : ι) (x : E)
    (hx : ∀ j ≠ k, a j ≠ a k)
    (hstrict : ∀ j ≠ k, ℓ_j(x) < ℓ_k(x)) :
    certifiedRadius a b k x = iSup {r | Metric.ball x r ⊆ tropicalCell a b k}
```

### Proof Strategy
1. The upper bound follows from the single-competitor robustness theorem: if the ball exceeds the certified radius, some competitor's normalized margin is violated.
2. The lower bound follows from `ball_subset_tropicalCell`: the ball of certified radius is contained in the cell.
3. The key challenge is showing these bounds are tight, which requires the finite-dimensional projection theorem for convex sets.

### Cross-Domain Connections
- **Convex optimization:** The Chebyshev center computation is a linear program, connecting to certified robustness via LP duality.
- **Computational geometry:** Inradius computation for polytopes is well-studied; this imports that machinery into learning theory.

### Estimated Difficulty: Medium (2–3 weeks)

---

## Direction 2: Face Lattice Semantics of ReLU Explanations

### Hypothesis
The tropical cell complex has a face lattice structure where codimension-1 faces correspond to pairs of classes that tie, codimension-2 faces to triples, etc. Saliency regime changes (where the "explanation" of a classification changes) correspond exactly to crossing faces of specific codimension. This gives interpretability a precise combinatorial-geometric foundation.

### Specific Theorem Targets
```
-- A face of a tropical cell is defined by a subset of active constraints
theorem tropicalFace_eq_activeConstraints
    (a : ι → E) (b : ι → ℝ) (k : ι) (S : Finset ι) (hS : S ⊆ ι \ {k}) :
    tropicalFace a b k S =
      {x | (∀ j ∈ S, ℓ_j(x) = ℓ_k(x)) ∧ (∀ j ∉ S ∪ {k}, ℓ_j(x) < ℓ_k(x))}

-- Crossing a codimension-1 face changes exactly one active competitor
theorem face_crossing_changes_one_competitor ...

-- The face lattice is isomorphic to a sublattice of the partition lattice
theorem face_lattice_iso_partition_sublattice ...
```

### Proof Strategy
1. Define faces as intersections of the cell with tie hyperplanes.
2. Show the face poset is graded by codimension.
3. Prove that saliency (gradient of the winning score) changes exactly when crossing a face.
4. Connect to matroid theory for the combinatorial structure.

### Cross-Domain Connections
- **Explainable AI:** Provides a mathematical definition of "explanation region" as a face of the tropical cell.
- **Matroid theory:** The face lattice may have matroid structure from the hyperplane arrangement.
- **Algebraic topology:** The cell complex is a regular CW complex; its topology encodes classification stability.

### Estimated Difficulty: Hard (1–2 months)

---

## Direction 3: Tropical Data Processing Inequality

### Hypothesis
For a finite tropical classifier with certified radii r(x), a perturbation channel P that respects the certified radii (i.e., P(x) ∈ B(x, r(x)) almost surely) preserves label information perfectly. When perturbations can cross boundaries with probability p, mutual information between input and output labels contracts by at most h(p) + p·log(|ι|−1), yielding a Fano-type bound.

### Specific Theorem Targets
```
-- Perfect information preservation within certified radius
theorem label_mutual_information_preserved
    (P : Channel α α) (h_within : ∀ x, P(x) ∈ B(x, r(x))) :
    I(label ∘ X ; label ∘ P(X)) = H(label ∘ X)

-- Fano-type bound for boundary-crossing perturbations
theorem tropical_fano_bound
    (p : ℝ) (hp : p = Pr[label(P(X)) ≠ label(X)]) :
    I(label(X) ; label(P(X))) ≥ H(label(X)) - h(p) - p * log(|ι| - 1)
```

### Proof Strategy
1. Start with the deterministic label invariance theorem (already proved).
2. Define a finite probability space and a perturbation channel.
3. Condition on the event {label changes} and apply classical Fano's inequality.
4. Bound the probability of label change using the certified radius and the perturbation distribution.

### Cross-Domain Connections
- **Information theory:** Connects robustness radii to channel capacity and data processing inequalities.
- **Privacy:** Certified radii give differential privacy-style guarantees for classification.
- **Rate-distortion theory:** The optimal tradeoff between perturbation size and information loss is a rate-distortion problem.

### Estimated Difficulty: Medium-Hard (3–6 weeks)

---

## Direction 4: Certified Robustness for Tropical Rational Maps

### Hypothesis
Multi-layer ReLU networks compute tropical rational maps (differences of tropical polynomials). Their decision boundaries are arrangements of tropical hypersurfaces, not just single hyperplanes. The certified radius for a tropical rational classifier can be bounded by the minimum distance to any hypersurface in the arrangement, using a layer-by-layer polyhedral analysis.

### Specific Theorem Targets
```
-- Composition of tropical affine maps preserves polyhedral structure
theorem tropicalComposition_cell_is_polyhedron
    (f g : TropicalAffineMap) :
    ∀ k, IsPolyhedron (compositionCell f g k)

-- Certified radius for two-layer tropical network
theorem twoLayer_certified_radius_ge
    (net : TwoLayerTropicalNet) (x : E) (k : ι) :
    certifiedRadius net x k ≥ min (certifiedRadius_layer1 x) (certifiedRadius_layer2 x)
```

### Proof Strategy
1. Prove that the preimage of a polyhedron under a piecewise-affine map is a polyhedral complex.
2. Show that for each layer, the certified radius can be computed from the layer's weight matrix.
3. Compose the per-layer certificates using the chain rule for Lipschitz constants within each active region.
4. The key insight is that within a single linearity region of the first layer, the two-layer composition is affine, so the single-layer theory applies.

### Cross-Domain Connections
- **Deep learning theory:** Connects network depth to the combinatorial complexity of the cell decomposition.
- **Algebraic geometry:** Tropical rational maps are objects of study in tropical algebraic geometry.
- **Verification:** Enables layer-by-layer certified verification of deep networks.

### Estimated Difficulty: Very Hard (2–4 months)

---

## Direction 5: Algorithmic Certification with Verified Computation

### Hypothesis
The certified radius computation can be implemented as a verified algorithm that:
(a) takes a network's weight matrices and an input point,
(b) computes the certified radius in polynomial time,
(c) produces a machine-checkable certificate (proof object) that the radius is correct.

### Specific Theorem Targets
```
-- The certified radius is computable
noncomputable def certifiedRadiusComputable
    (A : Matrix (Fin m) (Fin n) ℚ) (b : Fin m → ℚ) (k : Fin m) (x : Fin n → ℚ) : ℚ

-- The computation is correct
theorem certifiedRadiusComputable_correct
    (A b k x) :
    (certifiedRadiusComputable A b k x : ℝ) = certifiedRadius (fun i j => A i j) b k x

-- The computation runs in O(m·n) time
theorem certifiedRadiusComputable_complexity :
    timeBound (certifiedRadiusComputable A b k x) ≤ O(m * n)
```

### Proof Strategy
1. Implement the certified radius algorithm over ℚ (exact arithmetic).
2. Prove it computes the correct value by unfolding the definition and using rational arithmetic.
3. Extract the algorithm to executable code using Lean's code generation.
4. For floating-point networks, prove an interval arithmetic version with verified rounding.

### Cross-Domain Connections
- **Verified software:** Produces deployment-ready certified robustness checkers.
- **Interval arithmetic:** Handles floating-point networks with sound rounding.
- **Safety certification:** Provides regulators with machine-checkable evidence of AI safety properties.

### Estimated Difficulty: Medium (3–4 weeks for ℚ version; harder for float version)

---

## Research Program Architecture

These five directions form a coherent research program:

```
Direction 1 (Inradius)          Direction 2 (Face Lattice)
     │                                │
     ▼                                ▼
Direction 3 (Info Theory) ◄── Direction 4 (Multi-layer)
     │                                │
     └──────────┬─────────────────────┘
                ▼
    Direction 5 (Verified Algorithms)
```

- **Foundation:** Directions 1 and 2 deepen the single-layer geometric theory.
- **Extension:** Direction 4 extends to multi-layer networks.
- **Application:** Directions 3 and 5 connect to information theory and verified computation.

Each direction produces both mathematical theorems (formalized in Lean) and computational tools (Python/Lean implementations), maintaining the bridge between theory and practice that characterizes this research program.

---

## Team Directive

To pursue this program effectively:
1. **Assign one researcher per direction** for the first 2 months.
2. **Weekly cross-team meetings** to identify shared lemma needs and avoid duplication.
3. **Shared Lean library:** All proven lemmas go into a common `TropicalRobustness` module.
4. **Hypothesis testing:** Before formalizing, test each conjecture with `#eval` on concrete examples.
5. **Iterate:** After initial results, recombine teams for the integration phase (Directions 3–5).
