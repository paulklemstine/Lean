# Future Directions: Tropical Geometric Learning Theory

## Overview

The theorems established in this work—hyperplane distance formulae, tropical cell polyhedrality, and polyhedral robustness certificates—form the foundation of a new mathematical framework. Below are five concrete breakthrough directions, each with specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Exact Inradius Theorem for Tropical Cells

### Hypothesis
For bounded tropical cells with nonempty interior, the maximum certified radius (over all interior points) equals the inradius—the radius of the largest inscribed Euclidean ball.

### Theorem Target
```
theorem tropical_cell_inradius_eq_max_certified_radius
  [Fintype ι] [DecidableEq ι] [FiniteDimensional ℝ E]
  (a : ι → E) (b : ι → ℝ) (k : ι)
  (h_bounded : Bornology.IsBounded (tropicalCell a b k))
  (h_nonempty_interior : (interior (tropicalCell a b k)).Nonempty) :
  ⨆ x ∈ interior (tropicalCell a b k),
    ⨅ j ∈ {j | j ≠ k}, (⟪a k, x⟫_ℝ + b k - (⟪a j, x⟫_ℝ + b j)) / ‖a k - a j‖
  = Metric.infDist (chebyshevCenter (tropicalCell a b k))
      (frontier (tropicalCell a b k))
```

### Proof Strategy
1. Prove that the certified radius function $r(x) = \min_{j \neq k} (\ell_k(x) - \ell_j(x)) / \|a_k - a_j\|$ is concave on $C_k$ (as a minimum of affine functions divided by constants).
2. Use concavity to show the maximum is attained at a unique interior point (the Chebyshev center).
3. Show that at the Chebyshev center, the inscribed ball touches at least $n+1$ facets (by LP duality / KKT conditions).
4. Connect to Mathlib's `Metric.infDist` and `Bornology.IsBounded`.

### Cross-Domain Connections
- **Convex optimization**: The Chebyshev center is a linear programming problem, connecting to duality theory.
- **Algorithmic certification**: The inradius gives the maximum robustness achievable by any input in the cell.
- **Tropical intersection theory**: The number of active facets at the Chebyshev center relates to the tropical cell's combinatorial type.

### Dependencies
Requires: `tropicalCell_convex`, `ball_subset_tropicalCell`, `tropicalCell_isClosed`. May need Mathlib's `IsCompact.exists_isMinOn` for bounded closed convex sets.

---

## Direction 2: Face-Lattice Semantics of ReLU Explanations

### Hypothesis
The face lattice of a tropical cell encodes a hierarchy of "explanation modes." Crossing a codimension-1 face corresponds to a change in the saliency ranking of competing classes. The face poset gives a complete combinatorial description of how explanations degrade.

### Theorem Target
```
theorem face_crossing_changes_saliency_ranking
  [Fintype ι] [DecidableEq ι] [FiniteDimensional ℝ E]
  (a : ι → E) (b : ι → ℝ) (k : ι)
  (F : Set E) (hF : IsFace (tropicalCell a b k) F)
  (x : E) (hx : x ∈ relativeInterior F)
  (j : ι) (hj : j ≠ k)
  (hactive : ⟪a j, x⟫_ℝ + b j = ⟪a k, x⟫_ℝ + b k) :
  ∀ y ∈ interior (tropicalCell a b k),
    ⟪a j, y⟫_ℝ + b j < ⟪a k, y⟫_ℝ + b k
```

### Proof Strategy
1. Define faces of tropical cells as subsets where specific tie constraints become equalities.
2. Show that faces correspond to subsets $S \subseteq \iota \setminus \{k\}$ where $\ell_j = \ell_k$ for $j \in S$.
3. Prove that the relative interior of a face is where exactly the constraints in $S$ are active.
4. Show that crossing from interior to a face activates a new competitor (saliency change).

### Cross-Domain Connections
- **Explainable AI**: Face structure gives a mathematical framework for saliency maps.
- **Combinatorial topology**: The face lattice of the cell complex is a CW complex structure on input space.
- **Tropical intersection theory**: Faces correspond to tropical stable intersections.

---

## Direction 3: Tropical Data Processing Inequality

### Hypothesis
A finite tropical mutual information surrogate satisfies a data processing inequality: if a perturbation channel does not cross any tropical cell boundary, mutual information is preserved. If it crosses boundaries with probability $p$, information contracts by at most $h(p) + p \log(|\iota| - 1)$.

### Theorem Target
```
theorem tropical_data_processing_inequality
  [Fintype ι] [Fintype α]
  (X : α → ι)  -- labeling function
  (P : α → α)  -- perturbation map
  (cert_radius : α → ℝ)
  (perturbation_bound : α → ℝ)
  (h_certified : ∀ a, perturbation_bound a ≤ cert_radius a →
    X (P a) = X a)
  (μ : Finset α)
  (p : ℝ)
  (hp : p = (μ.filter (fun a => X (P a) ≠ X a)).card / μ.card) :
  mutual_info X (X ∘ P) μ ≥ entropy X μ - binary_entropy p - p * log (Fintype.card ι - 1)
```

### Proof Strategy
1. Define finite entropy and mutual information over finite types (avoid measure theory).
2. Prove that label preservation implies perfect channel transmission.
3. Apply a discrete Fano inequality to bound information loss by boundary-crossing probability.
4. Use the polyhedral robustness theorems to upper-bound boundary-crossing probability.

### Cross-Domain Connections
- **Information theory**: Directly extends Shannon's data processing inequality to the tropical setting.
- **Privacy**: The tropical cell structure gives geometric bounds on information leakage.
- **Channel coding**: Tropical cells become "decoding regions" in a communication channel.

### Dependencies
Requires: `label_invariant_under_certified_perturbation`, a finite entropy/mutual information library.

---

## Direction 4: Certified Robustness for Tropical Rational Maps

### Hypothesis
ReLU network outputs are not just max-affine but tropical *rational*—differences of tropical polynomials. Decision boundaries for tropical rational classifiers are arrangements of tropical hypersurfaces, and the robustness certificate generalizes to the minimum distance over all hypersurfaces in the arrangement.

### Theorem Target
```
theorem tropical_rational_robustness
  [Fintype ι] [FiniteDimensional ℝ E]
  (f g : ι → E → ℝ)  -- numerator and denominator tropical polynomials
  (hf : ∀ i, IsTropicalPolynomial (f i))
  (hg : ∀ i, IsTropicalPolynomial (g i))
  (k : ι) (x : E)
  (hx : ∀ j, f j x - g j x ≤ f k x - g k x)
  (r : ℝ) (hr : r < min_tropical_hypersurface_distance x k f g) :
  ∀ y ∈ Metric.ball x r, ∀ j, f j y - g j y ≤ f k y - g k y
```

### Proof Strategy
1. Define tropical polynomials as maxima of affine forms.
2. Show that within a linearity region of both $f$ and $g$, the decision is affine and the current theorems apply.
3. At linearity region boundaries, analyze how the active piece changes and bound the worst case.
4. The overall certificate is the minimum over (a) distance to decision boundary within current region and (b) distance to a linearity region boundary.

### Cross-Domain Connections
- **Deep network verification**: Multi-layer ReLU networks produce tropical rational maps.
- **Algebraic geometry**: Tropical rational maps are fundamental objects in tropical algebraic geometry.
- **Optimization**: The linearity region decomposition connects to the theory of piecewise-linear optimization.

---

## Direction 5: Algorithmic Certification with Verified Extraction

### Hypothesis
The polyhedral certification algorithm (compute active facet and certified radius from weight data) can be formally verified end-to-end, producing a certified algorithm that is correct by construction.

### Theorem Target
```
theorem verified_certification_algorithm
  [Fintype ι] [DecidableEq ι]
  (a : ι → Fin n → ℝ) (b : ι → ℝ)
  (x : Fin n → ℝ)
  (k : ι) (hk : k = argmax (fun i => ∑ d, a i d * x d + b i)) :
  let r := computeCertifiedRadius a b k x
  ∀ y, (∑ d, (y d - x d)^2) < r^2 →
    argmax (fun i => ∑ d, a i d * y d + b i) = k
```

### Proof Strategy
1. Define `computeCertifiedRadius` as a computable function (no `noncomputable`).
2. Show it equals the mathematical certified radius from Theorem 5.2.
3. Use the verified connection to prove that the algorithm's output is a valid certificate.
4. Optionally, extract to executable code using Lean's code generation.

### Cross-Domain Connections
- **Verified software**: The first formally verified ML certification algorithm.
- **Safety-critical systems**: Directly deployable in automotive, medical, and aviation AI.
- **Proof-carrying code**: The certificate is itself a mathematical proof of robustness.

### Dependencies
Requires: All theorems from this work, plus a computable argmax and sum implementation.

---

## Timeline and Priority

| Direction | Difficulty | Impact | Priority |
|-----------|-----------|--------|----------|
| 1. Inradius Theorem | Medium | High | ★★★★★ |
| 2. Face-Lattice Semantics | High | Very High | ★★★★☆ |
| 3. Data Processing Inequality | Medium | Very High | ★★★★★ |
| 4. Tropical Rational Maps | Very High | Transformative | ★★★☆☆ |
| 5. Verified Algorithm | Medium | Very High | ★★★★☆ |

Directions 1 and 3 are the most tractable immediate next steps. Direction 2 builds the interpretability bridge. Direction 4 is the long-term vision. Direction 5 is the practical impact multiplier.

---

## Team Directive

Create research teams for each direction. Each team should:
1. **Validate the hypothesis** computationally using the Python implementations provided.
2. **Build the Lean skeleton** with `sorry`-marked lemmas capturing the key logical steps.
3. **Prove bottom-up**, starting from the simplest supporting lemmas.
4. **Cross-pollinate**: results from one direction should be used in others (e.g., Direction 1's concavity result feeds Direction 5's algorithm design).

The ultimate goal is a comprehensive **formal tropical learning theory library** in Lean 4 that makes tropical geometry a first-class citizen of certified machine learning.
