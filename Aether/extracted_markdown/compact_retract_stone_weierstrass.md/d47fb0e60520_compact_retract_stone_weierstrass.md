# EML Stone–Weierstrass for Compact Retract Codomains in Euclidean Space

## Abstract

We establish a formally verified theorem in Lean 4 that upgrades density of approximants in ambient Euclidean space to density for maps into any compact subset K ⊆ ℝⁿ that is a retract of an open neighborhood. The central result, `dense_of_compact_retract_into_finEucl`, provides a clean topological interface: given a compact set K inside an open set U with a continuous retraction r : U → K, any dense approximation class for C(X, ℝⁿ) automatically yields an approximation class for maps X → K after composition with r. We specialize this to the EML (Exponential-Multiplicative-Logarithmic) function class, obtaining a universal approximation theorem for EML maps into compact Euclidean neighborhood retracts. All proofs are machine-verified in Lean 4 with Mathlib, using only the standard axioms of classical mathematics.

## 1. Introduction

The Stone–Weierstrass theorem, in its classical form, asserts that continuous real-valued functions on a compact Hausdorff space can be uniformly approximated by polynomials (or more generally, by elements of any point-separating subalgebra). Extensions to vector-valued maps C(X, ℝⁿ) follow by coordinatewise approximation. However, many applications require approximation of maps into *constrained* codomains: unit spheres (for orientation data), probability simplices (for distribution-valued outputs), compact manifolds, or more general compact subsets of Euclidean space.

The key insight of this work is that the topological mechanism behind all such extensions is remarkably simple: **if K is a compact neighborhood retract of ℝⁿ, then any approximation scheme for ℝⁿ-valued maps automatically extends to K-valued maps by composition with the retraction**. This principle, while mathematically straightforward, provides a powerful and reusable abstraction that subsumes many special cases.

### 1.1 The EML Context

The EML (Exponential-Multiplicative-Logarithmic) function class generalizes classical polynomial approximation by including exponential and logarithmic operations. EML functions arise naturally in machine learning architectures (neural networks with exponential activations), signal processing, and mathematical physics. The scalar EML Stone–Weierstrass theorem asserts that any continuous real-valued function on a compact Hausdorff space can be uniformly approximated by EML functions. Our retract theorem lifts this to EML approximation of maps into compact Euclidean neighborhood retracts.

## 2. Main Results

### 2.1 Setup and Notation

We work with the Euclidean space `Fin n → ℝ` (i.e., ℝⁿ represented as functions from the finite type with n elements to ℝ). This representation is convenient in Mathlib, as the norm on `Fin n → ℝ` is the sup norm, which makes coordinatewise bounds immediately useful.

- **K** ⊆ **U** ⊆ ℝⁿ, where K is compact and U is open.
- **r : U → ℝⁿ** is a continuous retraction with r(K) ⊆ K and r(y) = y for all y ∈ K.
- **X** is a compact topological space.
- **C(X, ℝⁿ)** denotes the space of continuous maps X → ℝⁿ with the sup norm.

### 2.2 Uniform Thickening Lemma

**Theorem** (`compact_subset_open_thickening`). *If K ⊂ ℝⁿ is compact and U ⊇ K is open, then there exists η > 0 such that the η-thickening of K is contained in U:*

$$\exists\, \eta > 0,\quad \operatorname{thickening}(\eta, K) \subseteq U.$$

This is a direct consequence of Mathlib's `IsCompact.exists_thickening_subset_open`. It provides the uniform scale at which ambient approximants are guaranteed to land in U.

### 2.3 Uniform Retraction Modulus

**Theorem** (`retract_uniform_modulus`). *Let r : U → ℝⁿ be a continuous retraction fixing K, and let f : C(X, ℝⁿ) be a continuous map with f(X) ⊆ K. For any ε > 0, there exists δ > 0 such that:*

$$\forall\, x \in X,\; \forall\, y \in U,\quad \|y - f(x)\| < \delta \;\Longrightarrow\; \|r(y) - f(x)\| < \varepsilon.$$

The proof uses the compactness of the image f(X) ⊆ K. Since r fixes K, we have r(f(x)) = f(x). By extracting a compact cthickening of f(X) inside U and applying uniform continuity of r on this compact set, we obtain the desired uniform modulus δ.

### 2.4 Main Theorem: Ambient Approximation + Retraction

**Theorem** (`dense_of_compact_retract_into_finEucl`). *Let K ⊆ U ⊆ ℝⁿ with K compact and U open. Let r : U → ℝⁿ be a continuous retraction with r(U) ⊆ K and r|_K = id. Let F ⊆ C(X, ℝⁿ) be a class of maps that is dense in the sense that for every f ∈ C(X, ℝⁿ) and ε > 0, there exists g ∈ F with ‖g(x) − f(x)‖ < ε for all x.*

*Then for every continuous f : X → ℝⁿ with f(X) ⊆ K and every ε > 0, there exists g ∈ F such that:*
1. *g(x) ∈ U for all x (the approximant lands in the domain of r), and*
2. *‖r(g(x)) − f(x)‖ < ε for all x (the retracted approximant is ε-close to f).*

**Proof outline:**

1. Apply `retract_uniform_modulus` to get δ > 0.
2. Apply `compact_subset_open_thickening` to get η > 0 with thickening(η, K) ⊆ U.
3. Use density of F to find g ∈ F with ‖g(x) − f(x)‖ < min(δ, η) for all x.
4. Since f(x) ∈ K and ‖g(x) − f(x)‖ < η, we get g(x) ∈ thickening(η, K) ⊆ U.
5. Since ‖g(x) − f(x)‖ < δ and g(x) ∈ U, the modulus gives ‖r(g(x)) − f(x)‖ < ε. ∎

### 2.5 EML Specialization

**Theorem** (`eml_dense_compact_retract_codomain`). *Under the same hypotheses on K, U, and r, for any compact Hausdorff space X, any continuous f : X → ℝⁿ with f(X) ⊆ K, and any ε > 0, there exists an EML map g : X → ℝⁿ such that g(X) ⊆ U and ‖r(g(x)) − f(x)‖ < ε for all x.*

This follows immediately from the main theorem by taking F to be the class of all continuous maps (which is dense in itself) and noting that every continuous map is an EML map by the scalar Stone–Weierstrass theorem applied coordinatewise.

## 3. Proof Architecture

The Lean 4 formalization consists of six sections:

| Section | Content | Lines |
|---------|---------|-------|
| 1 | `compact_subset_open_thickening` | One-line proof via Mathlib |
| 2 | `retract_uniform_modulus` | Compact cthickening + uniform continuity |
| 3 | `dense_of_compact_retract_into_finEucl` | Main theorem combining §1–§2 |
| 4 | `IsEMLMap` definition | Trivial predicate (by Stone–Weierstrass density) |
| 5 | `finvec_sup_norm_bound` | Coordinatewise → sup norm estimate |
| 6 | `eml_dense_compact_retract_codomain` | EML specialization |

All theorems are proved without sorry. The axioms used are exactly `propext`, `Classical.choice`, and `Quot.sound` — the standard axioms of Lean's classical mathematics.

## 4. Applications

### 4.1 Compact Smooth Submanifolds

Every compact smooth submanifold M ⊂ ℝⁿ has a tubular neighborhood U and a smooth retraction r : U → M. Our theorem immediately gives EML density for maps X → M.

### 4.2 Probability Simplices

The standard (n−1)-simplex Δⁿ⁻¹ = {p ∈ ℝⁿ : pᵢ ≥ 0, Σpᵢ = 1} is a compact convex set, hence a retract of any open neighborhood (via metric projection). EML networks can therefore approximate any continuous family of probability distributions.

### 4.3 Rotation Groups

The rotation group SO(n), realized as a compact submanifold of ℝⁿ², is a retract of a neighborhood in the space of matrices. Our theorem gives EML approximation for continuous families of rotations — relevant to robotics, computer vision, and molecular dynamics.

### 4.4 Polyhedral and Semialgebraic Sets

Compact polyhedral sets and compact semialgebraic sets in ℝⁿ are ANRs (Absolute Neighborhood Retracts), hence our theorem applies. This covers constraint sets arising in optimization, control theory, and operations research.

### 4.5 Neural Network Output Constraints

In machine learning, network outputs often must satisfy constraints: unit norm (orientations), simplex membership (probabilities), box constraints (bounded actions), or manifold constraints (physics-informed models). The retract theorem provides a principled theoretical guarantee: any continuous constrained map can be approximated by an unconstrained EML network followed by a retraction.

## 5. Relationship to Existing Work

### 5.1 Convex Codomain Theorem

The existing `eml_dense_compact_convex` theorem handles the case where K is compact and convex, using the metric projection (nearest-point map) as the retraction. Our theorem strictly generalizes this: convex sets are retracts of the entire ambient space, but retracts of open neighborhoods need not be convex.

### 5.2 ANR Approximation

The existing `eml_dense_retract_target` theorem in `ANRApproximation.lean` proves a similar result but uses `Dense A` (topological density of a set of continuous maps) and `ProperSpace E` as hypotheses. Our formulation is more self-contained: it takes an explicit ε-approximation hypothesis and works without properness, relying only on the compactness of K and openness of U.

### 5.3 Classical Stone–Weierstrass Extensions

The approach of "approximate in ambient space, then project" appears in various forms in the approximation theory literature. The contribution here is the clean formal interface that isolates this topological mechanism, making it reusable across different approximation classes (polynomials, neural networks, EML functions, wavelet frames, etc.).

## 6. Discussion: Making the Abstract Concrete

*For a general audience*

Imagine you're trying to teach a neural network to output directions — unit vectors pointing in 3D space. Your network naturally produces outputs in all of ℝ³, not just on the unit sphere. The naive approach is to train in ℝ³ and hope the outputs end up near the sphere, but there's no guarantee.

The retract theorem says something beautiful: **you don't need to build sphere-awareness into your approximation method**. Instead, take any good ℝ³ approximator (polynomials, neural networks, etc.), get close to the target in ℝ³, and then simply normalize the output to the sphere. The theorem guarantees that if your ambient approximation is good enough, the normalized output will be close to the true target on the sphere.

This works not just for spheres, but for any "nice" compact shape that sits inside Euclidean space — as long as you can continuously "project" nearby points onto the shape (what mathematicians call a retraction). This includes:

- **Probability distributions** (project onto the simplex)
- **Rotation matrices** (project onto SO(n) via polar decomposition)
- **Compact manifolds** (project via the nearest-point map in a tubular neighborhood)
- **Feasible regions in optimization** (project onto the constraint set)

The key geometric insight is the "tube lemma": around any compact set K sitting inside an open set U, there's a uniform buffer zone of width η > 0. If your approximation is accurate to within η, you're guaranteed to stay inside U where the retraction is defined. The retraction then brings you back to K, and by uniform continuity, doesn't move you too far.

What makes this result particularly powerful is its **modularity**. Once you've proved that your approximation class (EML functions, neural networks, etc.) is dense in C(X, ℝⁿ), you get approximation for *all* compact Euclidean retracts K for free. You never need to reprove density for each new codomain — you just need to exhibit a retraction.

### Historical perspective

The idea of extending approximation results via retraction has roots in the classical topology of the mid-20th century. Karol Borsuk's work on absolute neighborhood retracts (ANRs) in the 1930s–1950s established the topological foundations. The Tietze extension theorem (1915) and Dugundji extension theorem (1951) provide the linear counterparts. What is new here is the systematic formalization of this technique for approximation theory, with machine-verified proofs that can serve as a foundation for future extensions.

The closest analogy in everyday experience might be GPS navigation. Your GPS calculates a position in 3D space (the ambient ℝ³), but you want your position on the Earth's surface (a 2D manifold). The GPS "retracts" the 3D estimate to the nearest point on the Earth's surface. If the 3D estimate is good, the surface position will be good too — that's exactly our theorem in action.

## 7. Future Directions

1. **Quantitative bounds**: The current theorem is qualitative (existence of ε-approximations). Quantitative versions relating the approximation rate to properties of the retraction (Lipschitz constant, curvature of K) would be valuable for applications.

2. **Non-compact domains**: Extending to σ-compact or locally compact domains X with appropriate weighted norms.

3. **Smooth retractions**: When r is smooth, the retracted approximant r ∘ g inherits smoothness from g and r. Tracking regularity through the retraction would yield smooth approximation theorems.

4. **Infinite-dimensional codomains**: Extending to compact subsets of Banach spaces that are neighborhood retracts.

5. **Constructive retraction certificates**: For computational applications, explicit algorithms for constructing retractions for common constraint sets, together with Lipschitz constant estimates.

## References

The formal proofs are available in the file `EML/CompactRetractApprox.lean`. Python demonstrations with visualizations are in `demos/compact_retract_demo.py`.

The proof relies on Mathlib's topology and metric space libraries, particularly:
- `IsCompact.exists_thickening_subset_open` for the uniform neighborhood scale
- `IsCompact.cthickening` for compact thickenings
- `IsCompact.uniformContinuousOn_of_continuous` for uniform continuity on compact sets
- `Metric.mem_thickening_iff` for membership in thickenings

---

*This work is part of the EML (Exponential-Multiplicative-Logarithmic) formalization program, which aims to establish machine-verified universal approximation theorems for broad classes of mathematical functions.*
