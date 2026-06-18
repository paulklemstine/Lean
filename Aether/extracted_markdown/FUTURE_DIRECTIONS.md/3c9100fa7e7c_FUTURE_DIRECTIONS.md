# Future Directions: Tropical Choquet–Voronoi Duality

## Overview

The Tropical Choquet–Voronoi Duality theorem establishes a certified dictionary between finite tropical convex semimodules, support hypergraphs, and polyhedral/Voronoi complexes. This document outlines five concrete breakthrough research directions opened by this work, each with specific theorem targets, proof strategies, and cross-domain applications.

---

## Direction 1: Tropical Carathéodory–Helly–Radon Package

### Goal
Prove tropical analogues of the classical trinity of convexity theorems using support certificates.

### Specific Theorem Targets

**Tropical Carathéodory Theorem:**
```
Every element in the tropical hull of a set S ⊆ Z^n admits a
tropical combination of at most n+1 elements of S.
```

In Lean:
```lean
theorem tropical_caratheodory (n : ℕ) (S : Finset (Fin n → ℤ))
    (x : Fin n → ℤ) (hx : x ∈ tropHull S) :
    ∃ T : Finset (Fin n → ℤ), T ⊆ S ∧ T.card ≤ n + 1 ∧ x ∈ tropHull T
```

**Tropical Helly Theorem:**
```
If every n+1 members of a finite family of tropical convex sets
have nonempty intersection, then the whole family has nonempty intersection.
```

**Tropical Radon Theorem:**
```
Any set of n+2 points in tropical Z^n can be partitioned into
two disjoint subsets whose tropical hulls intersect.
```

### Proof Strategy
- Use the minimal support machinery: supports have bounded cardinality by dimension.
- The Carathéodory bound follows from showing that minimal supports in Z^n have card ≤ n+1.
- Helly and Radon follow from Carathéodory via standard combinatorial reductions.

### Cross-Domain Impact
- **Optimization**: Tropical Carathéodory gives complexity bounds for tropical LP vertex enumeration.
- **Machine learning**: Bounds on support size = bounds on explanation complexity.
- **Computational geometry**: Extends the Helly-type toolkit to tropical settings.

---

## Direction 2: Stability and Perturbation Theory of Support Complexes

### Goal
Prove that support complexes are stable under small perturbations of generators, establishing a certified robustness theory for tropical decompositions.

### Specific Theorem Targets

```lean
theorem support_certificate_stability
    (n k : ℕ) (A : Matrix (Fin k) (Fin n) ℤ)
    (x : Fin n → ℤ) (σ : Finset (Fin k))
    (hσ : IsMinimalSupport A x σ)
    (hnd : SupportNondegeneracy A σ) :
    ∃ ε > 0, ∀ A' : Matrix (Fin k) (Fin n) ℤ,
      matrixDist A A' < ε →
      IsMinimalSupport A' x σ
```

### Proof Strategy
- Define a "support margin": the gap between the dominant generators and the subdominant ones at each coordinate.
- Show that perturbations smaller than the margin preserve support structure.
- Connect to the Lipschitz stability of tropical functionals from `TropicalChoquetClosureDuality.lean`.

### Cross-Domain Impact
- **Robust ML**: Certify that explanations (supports) are stable under data perturbation.
- **Post-quantum crypto**: Tropical lattice hardness amplification via support stability.
- **Numerical tropical geometry**: Error analysis for computational tropical algorithms.

---

## Direction 3: Tropical Information Geometry via Support Entropy

### Goal
Define an information-geometric structure on the space of tropical semimodules using support distributions, establishing tropical analogues of Fisher information and KL divergence.

### Key Definitions

**Support entropy:**
```
H(M) = - Σ_{σ ∈ Supp(M)} p(σ) log p(σ)
```
where `p(σ) = |{x : Supp(x) = σ}| / |M|`

**Tropical Fisher information:**
```
g_{ij}(A) = Σ_x ∂/∂A_i log p(Supp_A(x)) · ∂/∂A_j log p(Supp_A(x))
```

### Theorem Targets

```lean
theorem support_entropy_maximized_at_uniform
    (M : Type*) [Fintype M]
    (Supp : M → Finset M)
    (hnd : ∀ x y, x ≠ y → Supp x ≠ Supp y) :
    SupportEntropy Supp ≤ log (Fintype.card M)
```

### Proof Strategy
- Use the support complex as a discrete probability space.
- Apply classical entropy maximization under uniform constraints.
- Connect to the tropical Fenchel–Legendre duality for convex functions.

### Cross-Domain Impact
- **Statistical mechanics**: Tropical free energy as support entropy.
- **Explainable AI**: Quantify explanation diversity via support distributions.
- **Coding theory**: Tropical codes via support-distance metrics.

---

## Direction 4: Equivalence with Regular Subdivisions and Tropical Polytopes

### Goal
Prove that the support complex is isomorphic (as a poset) to the face poset of a regular subdivision of a point configuration, connecting to the mature theory of tropical polytopes.

### Specific Theorem Targets

```lean
theorem support_complex_is_regular_subdivision
    (n k : ℕ) (A : Matrix (Fin k) (Fin n) ℤ)
    (Supp : (Fin n → ℤ) → Finset (Fin k)) :
    ∃ w : Fin k → ℤ,
      FacePoset (regularSubdivision A w) ≃o
      FacePoset (supportComplex Supp)
```

### Proof Strategy
- Show that the lifting heights `w_i = -c_i` (negated tropical coefficients) define a regular subdivision.
- The cells of this subdivision correspond exactly to support sets.
- Use secondary polytope theory to establish the poset isomorphism.

### Cross-Domain Impact
- **Algebraic geometry**: Connects to Newton polytope theory and tropical intersection theory.
- **Optimization**: Regular subdivisions encode optimal transport plans.
- **Computational geometry**: Efficient algorithms for tropical Voronoi diagrams.

---

## Direction 5: Certified Tropical Explainability for Piecewise-Linear Networks

### Goal
Apply the tropical Choquet–Voronoi duality to ReLU neural networks, which are piecewise-linear functions and hence tropical rational maps, to produce certified explanations.

### Key Insight
A ReLU network `f : R^n → R` is a tropical rational function (difference of two tropical polynomials). Its linear regions correspond to support cells in the tropical decomposition of its input space.

### Theorem Targets

```lean
theorem relu_network_support_decomposition
    (f : ReLUNetwork n m)
    (x : Fin n → ℝ) :
    ∃ σ : Finset (LinearRegion f),
      x ∈ tropHull σ ∧
      IsMinimalSupport f x σ ∧
      ∀ x' ∈ tropCell σ, f x' = linearPart σ x'
```

### Proof Strategy
- Decompose the ReLU network into a tropical polynomial (the max of affine functions).
- Apply the Choquet canonical decomposition to identify the active linear regions.
- Show that the support complex of the network = the arrangement of linear regions.
- Certify that within each support cell, the network is exactly linear.

### Cross-Domain Impact
- **Explainable AI**: Each prediction comes with a certified tropical support certificate identifying which prototypes/features are active.
- **Adversarial robustness**: Support stability → certified robustness radius.
- **Model compression**: Merge support cells with identical linear parts.
- **Formal verification of ML**: Machine-checked proofs that network explanations are correct.

---

## Implementation Priorities

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Carathéodory–Helly–Radon | Medium | High | Current work |
| 2. Support stability | Medium-High | Very High | Current + Lipschitz theory |
| 3. Information geometry | High | Medium | Current + probability theory |
| 4. Regular subdivisions | Very High | Very High | Current + polytope theory |
| 5. ReLU explainability | High | Transformative | Current + real analysis |

### Recommended Sequence
1. Start with Direction 1 (tropical Carathéodory) as it directly extends minimal support theory.
2. Then Direction 2 (stability) using the margin-based approach.
3. Direction 5 (ReLU networks) in parallel, as it has the highest practical impact.
4. Directions 3–4 as longer-term theory development.

---

## Required Mathlib Extensions

Several directions require Mathlib infrastructure that may need development:

- **Tropical semiring formalization**: `WithTop ℤ` with min-plus (partially exists).
- **Abstract simplicial complex API**: Face poset, nerve, link operations.
- **Regular subdivision theory**: Secondary polytope, lifting triangulations.
- **Piecewise-linear function spaces**: For the ReLU network connection.
- **Tropical polynomial rings**: For the algebraic geometry direction.

Each of these is independently valuable as a Mathlib contribution.
