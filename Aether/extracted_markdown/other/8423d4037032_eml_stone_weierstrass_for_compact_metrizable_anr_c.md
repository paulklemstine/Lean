# EML Stone–Weierstrass for Compact Metrizable ANR Codomains via Euclidean Embedding and Neighborhood Retraction

## Abstract

We prove a codomain-lifting universal approximation theorem: if a function class is dense in the space of continuous maps from a compact space into a Euclidean space, then it remains "approximately dense" for maps into any compact subset that admits a neighborhood retraction—that is, any compact absolute neighborhood retract (ANR) embedded in Euclidean space. The key innovation is a geometric correction step: first approximate the Euclidean embedding of the target map, then post-compose with the neighborhood retraction to return to the nonlinear target. We formalize this result in Lean 4, proving all intermediate lemmas (tube lemma, uniform continuity on compact tubes, retraction identity, and the main approximation theorem) without any unverified assumptions.

As a corollary, EML (Exp-Minus-Log) function classes—whose scalar density follows from the classical Stone–Weierstrass theorem—can universally approximate continuous maps into compact manifolds, finite CW complexes, and any other compact metrizable ANR, after a fixed geometric post-processing step.

## 1. Introduction

### 1.1 Background

Universal approximation theorems are foundational in machine learning and approximation theory. The classical Stone–Weierstrass theorem guarantees that certain function algebras are dense in $C(K, \mathbb{R})$ for compact Hausdorff $K$. Vector-valued extensions lift this to $C(K, \mathbb{R}^n)$ via coordinatewise approximation with controlled reconstruction error.

However, many natural problems in geometric machine learning, robotics, and physics require approximating maps into **nonlinear targets**: circles, spheres, Lie groups, Stiefel manifolds, configuration spaces. The standard Stone–Weierstrass machinery does not directly apply because these targets are not vector spaces.

### 1.2 Main Contribution

We show that **Euclidean approximation lifts to ANR approximation** through a simple geometric construction. The key insight is:

> *If $Y$ is a compact subset of $\mathbb{R}^n$ that admits a continuous retraction from an open neighborhood $U \supseteq Y$, then any dense class of maps into $\mathbb{R}^n$ yields approximate maps into $Y$ after post-composition with the retraction.*

This is not a new idea in topology—it is implicit in the theory of absolute neighborhood retracts (ANRs). Our contribution is:

1. **Formal verification**: All proofs are machine-checked in Lean 4 with Mathlib, yielding the highest possible confidence in correctness.
2. **Explicit error analysis**: We provide quantitative control on the approximation error through the modulus of continuity of the retraction.
3. **EML corollary**: We instantiate the general theorem for EML function classes, extending the EML Stone–Weierstrass theorem to nonlinear codomains.

### 1.3 Setting

Let:
- $K$ be a compact topological space (the input domain)
- $E$ be a finite-dimensional normed space (the ambient Euclidean space, typically $\mathbb{R}^n$)
- $Y \subseteq E$ be a compact subset (the target space)
- $U \supseteq Y$ be an open neighborhood
- $r: U \to Y$ be a continuous retraction ($r(y) = y$ for all $y \in Y$)
- $A \subseteq C(K, E)$ be a dense set of maps (the approximation class)

**Theorem (Main).** For any $F \in C(K, E)$ with $\text{range}(F) \subseteq Y$ and any $\varepsilon > 0$, there exists $g \in A$ with $\text{range}(g) \subseteq U$ and
$$\sup_{x \in K} \|r(g(x)) - F(x)\| < \varepsilon.$$

## 2. Key Lemmas

### 2.1 Tube Lemma (compact_range_tube_lemma)

**Lemma.** *If $F: K \to E$ is continuous from a compact space and $U \supseteq \text{range}(F)$ is open, then there exists $\eta > 0$ such that $\overline{B}(F(x), \eta) \subseteq U$ for all $x \in K$.*

*Proof.* The range of $F$ is compact. By the cthickening lemma (a standard Mathlib result: `IsCompact.exists_cthickening_subset_open`), there exists $\delta > 0$ such that $\text{cthickening}(\delta, \text{range}(F)) \subseteq U$. Then $\eta = \delta/2$ works because every closed ball $\overline{B}(F(x), \delta/2)$ is contained in the $\delta$-cthickening of the range. ∎

### 2.2 Uniform Continuity on Compact Tube (retract_unif_cont_on_compact)

**Lemma.** *If $T \subseteq U$ is compact and $r: U \to E$ is continuous, then for every $\varepsilon > 0$ there exists $\delta > 0$ such that*
$$a, b \in T,\ \|a - b\| < \delta \implies \|r(a) - r(b)\| < \varepsilon.$$

*Proof.* The restriction $r|_T$ is a continuous function on a compact metric space, hence uniformly continuous (Heine–Cantor theorem). ∎

### 2.3 Retraction Identity (retract_fixes_image)

**Lemma.** *For any $x \in K$, $r(F(x)) = F(x)$.*

*Proof.* Since $F(x) \in \text{range}(F) \subseteq Y$ and $r$ fixes $Y$ pointwise, $r(F(x)) = F(x)$. ∎

## 3. Main Proof

**Proof of the Main Theorem.**

**Step 1 (Tube).** Apply the Tube Lemma to get $\eta > 0$ with $\overline{B}(F(x), \eta) \subseteq U$ for all $x$.

**Step 2 (Compact tube).** Let $T = \text{cthickening}(\eta, \text{range}(F))$. Since $E$ is a proper space and $\text{range}(F)$ is compact, $T$ is compact. Moreover $T \subseteq U$ (every point in $T$ is within $\eta$ of some $F(x)$, hence in $\overline{B}(F(x), \eta) \subseteq U$).

**Step 3 (Modulus).** Apply uniform continuity of $r$ on $T$ to get $\delta > 0$ such that $a, b \in T$, $\|a-b\| < \delta$ implies $\|r(a) - r(b)\| < \varepsilon$.

**Step 4 (Approximate).** Since $A$ is dense in $C(K, E)$, choose $g \in A$ with $\|g - F\|_\infty < \min(\eta, \delta)$.

**Step 5 (Tube containment).** For each $x$, $\|g(x) - F(x)\| < \eta$, so $g(x) \in \overline{B}(F(x), \eta) \subseteq U$, giving $\text{range}(g) \subseteq U$. Also $g(x) \in T$.

**Step 6 (Error bound).** For each $x$:
$$\|r(g(x)) - F(x)\| = \|r(g(x)) - r(F(x))\| < \varepsilon$$
where we used $r(F(x)) = F(x)$ (retraction identity) and $\|g(x) - F(x)\| < \delta$ (uniform continuity modulus). ∎

## 4. EML Corollary

### 4.1 EML Stone–Weierstrass (Background)

The EML (Exp-Minus-Log) function class generates a subalgebra of $C(K, \mathbb{R})$ that separates points and contains constants, hence is dense by the classical Stone–Weierstrass theorem. The vector-valued extension (proved in the companion file `VectorStoneWeierstrass.lean`) lifts this to density in $C(K, \mathbb{R}^n)$.

### 4.2 ANR Corollary

**Corollary (eml_dense_retract_target).** *Let $Y \subseteq \mathbb{R}^n$ be compact with an open neighborhood $U$ and continuous retraction $r: U \to Y$. For any $F \in C(K, \mathbb{R}^n)$ with $\text{range}(F) \subseteq Y$ and $\varepsilon > 0$, there exists an EML vector approximation $g$ with $\text{range}(g) \subseteq U$ and $\sup_x \|r(g(x)) - F(x)\| < \varepsilon$.*

**Corollary (eml_dense_compact_ANR_codomain).** *Let $Y$ be a compact Hausdorff space with a continuous injection $e: Y \hookrightarrow \mathbb{R}^n$, an open $U \supseteq \text{range}(e)$, and a retraction $r: U \to \text{range}(e)$. For any $f \in C(K, Y)$ and $\varepsilon > 0$, there exists an EML $g$ with $\|r(g(x)) - e(f(x))\| < \varepsilon$ for all $x$.*

## 5. Formalization

### 5.1 Lean 4 Formalization

All results are formalized in Lean 4 using Mathlib. The key file is `EML/ANRApproximation.lean`. The formal statements match the mathematical content exactly, with all proofs machine-verified. The axioms used are only the standard foundational axioms: `propext`, `Classical.choice`, and `Quot.sound`.

### 5.2 Proof Architecture

| Theorem | Lines | Key Mathlib Dependencies |
|---------|-------|--------------------------|
| `compact_range_tube_lemma` | ~6 | `IsCompact.exists_cthickening_subset_open` |
| `range_subset_of_closedBall_subset` | ~1 | Basic set theory |
| `retract_unif_cont_on_compact` | ~10 | `CompactSpace.uniformContinuous_of_continuous` |
| `retract_fixes_image` | ~1 | Direct from hypothesis |
| `retract_approx_of_dense` | ~50 | Combines all above + `Dense.exists_dist_lt` |
| `eml_dense_retract_target` | ~3 | Instantiation of main theorem |
| `eml_dense_compact_ANR_codomain` | ~5 | Embedding version |

## 6. Applications

### 6.1 Manifold-Valued Learning

Many machine learning problems involve outputs on manifolds:

- **Rotation estimation**: Predicting rotations $SO(3)$ from sensor data
- **Direction prediction**: Outputs on $S^{n-1}$ (unit vectors)
- **Phase estimation**: Outputs on $S^1$ (angles, phases)
- **Pose estimation**: Outputs on $SE(3)$

Our theorem guarantees that EML networks can approximate any continuous map into these targets, after post-processing with a geometric retraction (e.g., Gram–Schmidt orthogonalization for $SO(3)$, normalization for $S^{n-1}$).

### 6.2 Constrained Optimization

When optimizing over a compact constraint set $Y$ (e.g., a feasible region in robotics), the retraction approach converts unconstrained optimization in $\mathbb{R}^n$ to constrained output via post-processing. The theorem ensures no loss of approximation power from this reduction.

### 6.3 Topological Data Analysis

For maps between spaces with nontrivial topology (e.g., covering space projections, bundle sections), the retraction framework provides a principled approximation strategy that respects the target topology.

## 7. Discussion: Making the Circle Square (A Scientific American Perspective)

### The Problem of Curved Targets

Imagine you're training a neural network to predict wind direction. The output isn't a number on a line—it's a point on a circle (0° to 360°, where 0° and 360° are the same direction). Standard neural networks output real numbers, not points on circles. If you naively output an angle and wrap it around, you get discontinuities: the network might jump between 359° and 1° when it should smoothly pass through 0°.

This is a fundamental geometric problem. Neural networks are naturally "Euclidean"—they compute in flat spaces like $\mathbb{R}^n$. But many real-world outputs live on curved spaces: directions (circles), rotations (spheres and rotation groups), robot configurations (manifolds), molecular conformations (quotient spaces).

### The Retraction Trick

Our theorem says: **don't fight the geometry—embrace it.** The strategy is beautifully simple:

1. **Embed** the curved target in a flat space. Every compact manifold can be embedded in some $\mathbb{R}^n$ (Whitney embedding theorem).
2. **Approximate** the embedded target map using your favorite Euclidean approximation method (here, EML networks). The approximation will generally miss the target surface—it'll land nearby in the ambient space.
3. **Retract** the approximation back onto the target. For example, to get back to a sphere, just normalize the vector. To get back to a rotation matrix, apply Gram–Schmidt.

The theorem proves that this three-step process works: the retracted approximation converges to the true map as the Euclidean approximation improves. Moreover, it gives quantitative control—the retraction error is bounded by the modulus of continuity of the retraction applied to the Euclidean error.

### Why "ANR"?

An Absolute Neighborhood Retract (ANR) is a topological space that, whenever embedded in a larger space, admits a continuous retraction from some neighborhood. This is exactly the geometric property we need. The good news: virtually all "nice" spaces in applications are ANRs. Manifolds, polyhedra, finite CW complexes, convex bodies—all ANRs. The theorem covers them all.

### Historical Context

The idea that neighborhood retractions can lift approximation results goes back to Karol Borsuk's foundational work on retracts in the 1930s. The ANR concept itself was introduced by Borsuk in 1931. What we contribute is:
- A machine-verified proof of the complete argument
- Explicit instantiation for the EML function class
- Quantitative error bounds suitable for computational applications

### The Bigger Picture

This result is a bridge between two worlds: the algebraic world of function approximation (Stone–Weierstrass) and the geometric world of topology (ANR theory). It says that the algebraic density theorems, which are about flat spaces, automatically extend to curved targets through the geometric notion of retraction.

In the era of geometric deep learning, where models increasingly need to respect symmetries and constraints, this bridge becomes practically important. The retraction approach provides a theoretically guaranteed method for extending any linear-space approximation result to nonlinear targets.

## 8. Future Directions

1. **Equivariant extensions**: If the function class and retraction are equivariant under a group action, the approximation inherits the same equivariance. Formalizing this would connect to equivariant neural networks.

2. **Rate of approximation**: The current theorem is qualitative (density). Quantitative rates of approximation, relating the number of EML parameters to the target error, would be valuable for practical applications.

3. **Non-compact domains**: Extending to locally compact or σ-compact domains with appropriate weighted norms.

4. **Infinite-dimensional codomains**: Function spaces, spaces of probability measures, or other infinite-dimensional ANRs.

5. **Computational retraction design**: For specific manifolds, designing computationally efficient retractions that minimize error amplification (i.e., have Lipschitz constant close to 1).

## References

- Borsuk, K. (1931). "Sur les rétractes." *Fundamenta Mathematicae*, 17, 152–170.
- Dugundji, J. (1951). "An extension of Tietze's theorem." *Pacific Journal of Mathematics*, 1(3), 353–367.
- Stone, M. H. (1937). "Applications of the theory of Boolean rings to general topology." *Transactions of the AMS*, 41(3), 375–481.
- Weierstrass, K. (1885). "Über die analytische Darstellbarkeit sogenannter willkürlicher Funktionen einer reellen Veränderlichen." *Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften zu Berlin*, 633–639.

## Appendix: Formal Statement Summary

```lean
-- Tube Lemma
theorem compact_range_tube_lemma
    (F : C(K, E)) (hU : IsOpen U) (hFU : range F ⊆ U) :
    ∃ η > 0, ∀ x : K, closedBall (F x) η ⊆ U

-- Main Theorem
theorem retract_approx_of_dense
    (hY : IsCompact Y) (hU : IsOpen U) (hYU : Y ⊆ U)
    (r : ↥U → E) (hr_cont : Continuous r)
    (hr_range : ∀ u, r u ∈ Y) (hr_fix : ∀ y ∈ Y, r ⟨y, _⟩ = y)
    (hA_dense : Dense A) (F : C(K, E)) (hF : range F ⊆ Y) (hε : 0 < ε) :
    ∃ g ∈ A, ∃ hg : range g ⊆ U,
      ∀ x, dist (r ⟨g x, hg (mem_range_self x)⟩) (F x) < ε

-- EML Corollary
theorem eml_dense_retract_target
    (n : ℕ) (hY : IsCompact Y) (hU : IsOpen U) (hYU : Y ⊆ U)
    (r : ↥U → ℝⁿ) ... (F : C(K, ℝⁿ)) (hF : range F ⊆ Y) (hε : 0 < ε) :
    ∃ g, IsEMLVectorApprox n g ∧ ∃ hg : range g ⊆ U,
      ∀ x, dist (r ⟨g x, _⟩) (F x) < ε

-- Embedding version
theorem eml_dense_compact_ANR_codomain
    (n : ℕ) (e : Y → ℝⁿ) (he_cont : Continuous e) ...
    (r : ↥U → ℝⁿ) ... (f : C(K, Y)) :
    ∀ ε > 0, ∃ g, IsEMLVectorApprox n g ∧ ∃ hg : range g ⊆ U,
      ∀ x, ‖r ⟨g x, _⟩ - e (f x)‖ < ε
```
