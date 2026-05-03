# Stone–Weierstrass Approximation for Compact Neighborhood Retract Codomains: A Formally Verified Extension

## Abstract

We prove, with full machine verification in Lean 4 using Mathlib, that any dense approximation class for continuous maps into Euclidean space automatically extends to continuous maps into compact neighborhood retracts. Specifically, if a set *A* of continuous maps *X → ℝⁿ* is uniformly dense among all continuous maps (as guaranteed by Stone–Weierstrass-type theorems), then every continuous map *f : X → S*, where *S* is a compact subset of *ℝⁿ* admitting an open neighborhood *U ⊇ S* with a continuous retraction *r : U → S*, can be uniformly approximated by maps of the form *r ∘ g* for *g ∈ A*. The proof is entirely constructive in its approximation strategy, depending only on three classical topological ingredients: compact-set thickening, uniform continuity of retractions near compact sets, and the density hypothesis for the Euclidean-valued class.

**Keywords:** Stone–Weierstrass theorem, neighborhood retract, universal approximation, compact manifold, formal verification, Lean 4

---

## 1. Introduction

The classical Stone–Weierstrass theorem guarantees that continuous real-valued functions on a compact Hausdorff space can be uniformly approximated by elements of any subalgebra that separates points and contains the constants. Modern extensions to vector-valued functions (into ℝⁿ or finite-dimensional normed spaces) are equally classical. However, many applications in geometry, physics, and machine learning require approximating functions whose codomain is a *nonlinear* space — a sphere, a torus, a Lie group, a configuration manifold.

The purpose of this work is to establish, with full formal verification, the bridge between Euclidean-codomain approximation and manifold-codomain approximation. The key observation is:

> **Any compact manifold (or more generally, compact ENR) that embeds in Euclidean space admits a neighborhood retraction, and the retraction mechanism automatically converts Euclidean approximation into target-preserving approximation.**

This is mathematically folklore, but has — to our knowledge — never been formalized in a proof assistant. The formalization makes precise exactly what topological hypotheses are needed and separates the "soft" analysis (density in Euclidean space) from the "hard" topology (existence of retractions), yielding a modular theorem that applies to any approximation class, not just polynomials or neural networks.

### 1.1 Relation to Prior Work

The retraction method for extending approximation results has roots in:

- **Whitney's embedding theorem** (1936): every compact smooth manifold embeds in some ℝⁿ.
- **Tubular neighborhood theorem**: a smooth submanifold of Euclidean space has a neighborhood that deformation-retracts onto it.
- **Borsuk's theory of ANRs/ENRs** (1930s–1960s): compact Euclidean neighborhood retracts (ENRs) are precisely the compact spaces that embed in ℝⁿ with a retraction from an open neighborhood.

Our formalization avoids reliance on the full smooth-manifold API by working directly with the retract hypothesis, which is the minimal topological condition needed for the argument.

---

## 2. Mathematical Statement

### 2.1 Setup

Let:
- *X* be a compact Hausdorff topological space (the "domain"),
- *n* ∈ ℕ and *S ⊆ ℝⁿ* a compact subset (the "target"),
- *U ⊆ ℝⁿ* an open set with *S ⊆ U*,
- *r : U → S* a continuous retraction fixing *S* pointwise: *r(s) = s* for all *s ∈ S*,
- *A ⊆ C(X, ℝⁿ)* a set of continuous maps that is **uniformly dense**: for every *f ∈ C(X, ℝⁿ)* and *ε > 0*, there exists *g ∈ A* with ‖g(x) − f(x)‖ < ε for all *x ∈ X*.

### 2.2 Main Theorem

**Theorem** (Retract Approximation). *Under the above hypotheses, for every continuous map f : X → S and every ε > 0, there exists a continuous map g : X → S such that*

$$\sup_{x \in X} \|g(x) - f(x)\| < \varepsilon.$$

*Moreover, g has the form g = r ∘ g₀ for some g₀ ∈ A.*

### 2.3 Key Lemmas

The proof decomposes into three independent topological facts:

**Lemma 1** (Uniform Thickening). *If K ⊆ U with K compact and U open in ℝⁿ, then there exists δ > 0 such that every point within distance δ of K lies in U.*

**Lemma 2** (Compact Range). *If X is compact and f : X → S is continuous, then the image of f (viewed in ℝⁿ) is compact.*

**Lemma 3** (Uniform Retract Control). *If r : U → S is a continuous retraction fixing S, K ⊆ S is compact, then for every ε > 0 there exists δ > 0 such that for all y ∈ K and z ∈ U with ‖z − y‖ < δ, we have ‖r(z) − y‖ < ε.*

---

## 3. Proof

**Step 1: Establish the compact image.** Given *f : X → S*, the image *K = f(X)* (viewed in ℝⁿ) is compact by Lemma 2. Since *K ⊆ S ⊆ U*, Lemma 1 provides *δ₀ > 0* such that every point within distance *δ₀* of *K* lies in *U*.

**Step 2: Uniform continuity of retraction.** Since *K ⊆ S* and *r* fixes *S*, Lemma 3 provides *δ₁ > 0* such that for any *y ∈ K* and *z ∈ U* with *‖z − y‖ < δ₁*, we have *‖r(z) − y‖ < ε*.

**Step 3: Approximate in Euclidean space.** Set *δ = min(δ₀, δ₁)*. The embedded map *F : X → ℝⁿ*, *F(x) = f(x)*, is continuous. By density of *A*, there exists *g₀ ∈ A* with *‖g₀(x) − F(x)‖ < δ* for all *x ∈ X*.

**Step 4: Retract and estimate.** Since *‖g₀(x) − f(x)‖ < δ ≤ δ₀* and *f(x) ∈ K*, the point *g₀(x)* lies in *U*. Define *g(x) = r(g₀(x))*; this is well-defined and continuous. Since *‖g₀(x) − f(x)‖ < δ ≤ δ₁* and *f(x) ∈ K ⊆ S*:

$$\|g(x) - f(x)\| = \|r(g_0(x)) - f(x)\| < \varepsilon. \qquad \square$$

---

## 4. Formal Verification

The entire proof is formalized in Lean 4 with Mathlib in the file `EML/RetractApprox.lean`. The formalization consists of approximately 130 lines of Lean code, with four theorems:

1. `compact_subset_open_has_uniform_nhds` — uses Mathlib's `IsCompact.exists_thickening_subset_open`
2. `isCompact_range_coe_of_continuous` — direct application of `isCompact_range`
3. `retract_near_compact_uniform` — proved by contradiction using sequential compactness
4. `eml_uniform_approx_subtype_of_neighborhoodRetract` — combines the three lemmas

All theorems depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### 4.1 Design Decisions

- **Codomain as subtype.** We represent *S* as a subtype `↥S` of `Fin n → ℝ` (Lean's Euclidean space). This avoids carrying separate equivalences and makes the retraction signature precise.

- **Norm-based error.** Approximation error is stated pointwise as `‖(g x : Fin n → ℝ) − (f x : Fin n → ℝ)‖ < ε`, matching the standard sup-norm formulation.

- **Retract hypothesis, not manifold.** The theorem is stated for any compact neighborhood retract, which is strictly more general than compact manifolds. This avoids dependence on Mathlib's smooth manifold API while still capturing the full intended generality.

---

## 5. Applications

### 5.1 Sphere-Valued Functions (Sⁿ)

The unit sphere *Sⁿ ⊂ ℝⁿ⁺¹* is a compact neighborhood retract with retraction *r(x) = x/‖x‖* defined on *ℝⁿ⁺¹ \ {0}*. Any continuous map *f : X → Sⁿ* can therefore be uniformly approximated by maps of the form *x ↦ g(x)/‖g(x)‖* where *g* comes from the Euclidean approximation class. This applies to:

- **Unit normal fields** on surfaces in ℝ³
- **Phase fields** in physics (order parameters on S¹)
- **Spin directions** in magnetic systems

### 5.2 Rotation Groups (SO(n))

The rotation group *SO(n) ⊂ ℝⁿˣⁿ* is a compact Lie group, hence a compact smooth submanifold of Euclidean space. The retraction can be constructed via polar decomposition: for a matrix *M* close to *SO(n)*, set *r(M) = UV^T* where *M = UΣV^T* is the SVD. Applications include:

- **Robotic arm orientations**
- **Attitude control** in spacecraft engineering
- **Frame fields** in geometry processing

### 5.3 Tori and Product Manifolds

The torus *T² ⊂ ℝ³* (or more generally *Tⁿ ⊂ ℝ²ⁿ*) is a compact neighborhood retract. The theorem guarantees polynomial/neural-network approximation of:

- **Periodic state variables** (angles, phases)
- **Crystal lattice configurations**
- **Toroidal magnetic confinement geometries** (tokamaks)

### 5.4 Neural Network Approximation

When *A* is taken to be the class of ReLU neural networks (or any other universal approximation class for ℝⁿ-valued functions), the theorem immediately yields:

> **Neural networks composed with a retraction can uniformly approximate any continuous map into a compact ENR.**

This provides a rigorous foundation for manifold-valued neural networks used in geometric deep learning.

---

## 6. Discussion: The Retraction Trick

*For a general audience.*

Imagine you want to predict where a robot's arm will point — not just any direction, but specifically a unit vector (a point on a sphere). You have powerful tools (polynomials, neural networks) that can approximate any function into ordinary Euclidean space. But these tools don't know about the constraint that the output should be a unit vector; a polynomial approximation to a sphere-valued function will generally *leave the sphere*.

The retraction trick is beautifully simple: **approximate freely in Euclidean space, then project back.** If you normalize the polynomial output *p(x)* to get *p(x)/‖p(x)‖*, you're back on the sphere — and if *p(x)* was close to the sphere to begin with, the normalization barely changes it, so the result is still a good approximation.

What our theorem shows is that this trick works *universally*: not just for spheres, but for any compact shape in Euclidean space that admits a "gentle" projection from its neighborhood. This includes all compact manifolds (by Whitney's embedding theorem), all compact Lie groups, all configuration spaces that arise naturally in robotics and physics.

The mathematical key is a two-part argument about *margins*:
1. **The compact image stays safely inside the neighborhood.** Since the function's image is compact and the projection domain is open, there's a positive "safety margin" — a uniform buffer zone around the image that stays inside the projection domain.
2. **The projection doesn't amplify small errors too much.** Near any point on the target, the projection acts like a gentle deformation (it's the identity on the target and continuous nearby), so small perturbations in Euclidean space produce small perturbations in the projected output.

These two margins give you room to maneuver: approximate well enough in Euclidean space (within both margins), and the retraction delivers a valid, close approximation on the target shape.

This is a paradigmatic example of a *reduction theorem*: it reduces a harder problem (manifold-valued approximation) to an easier one (Euclidean approximation) via a clean topological interface (the retraction). Once proved, it can be composed with *any* future Euclidean approximation result — polynomials, neural networks, wavelets, whatever — to immediately yield a manifold-valued version.

---

## 7. Future Directions

1. **ANR codomains.** The theorem generalizes immediately to abstract ANRs (absolute neighborhood retracts), which include all compact manifolds with boundary, finite simplicial complexes, and many infinite-dimensional spaces.

2. **Rate-preserving retraction.** If the Euclidean approximation achieves a specific convergence rate (e.g., O(1/n) for n-term approximation), the retraction preserves this rate up to the Lipschitz constant of *r*. Formalizing this quantitative refinement would give rate-optimal manifold-valued approximation.

3. **Smooth retraction and derivative approximation.** When *r* is smooth (as in the tubular neighborhood), the retracted approximant inherits differentiability from the Euclidean approximant. This extends to derivative approximation on manifolds.

4. **Equivariant approximation.** If the target *S* carries a group action compatible with the retraction, the theorem can be strengthened to produce equivariant approximants — important for physics applications with symmetry constraints.

---

## References

- Borsuk, K. (1931). Sur les rétractes. *Fundamenta Mathematicae*, 17, 152–170.
- Stone, M. H. (1937). Applications of the theory of Boolean rings to general topology. *Transactions of the AMS*, 41(3), 375–481.
- Whitney, H. (1936). Differentiable manifolds. *Annals of Mathematics*, 37(3), 645–680.
- The Mathlib Community. (2020–2025). *Mathlib: a unified library of mathematics formalized in Lean 4.* https://github.com/leanprover-community/mathlib4
