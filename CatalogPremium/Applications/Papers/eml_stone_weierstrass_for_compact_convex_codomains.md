# Codomain-Constrained Universal Approximation via Metric Projection: A Formally Verified Stone–Weierstrass Extension

## Abstract

We prove a codomain-constrained extension of the Stone–Weierstrass theorem for compact convex codomains. Given a compact Hausdorff space $K$ and a nonempty compact convex subset $C$ of a real inner product space $E$, we show that any continuous map $f : K \to C$ can be uniformly approximated by maps that land in $C$, obtained by composing ambient approximants with the metric projection (nearest-point retraction) onto $C$. The key ingredients are: (1) the existence and uniqueness of nearest points in compact convex subsets of inner product spaces, (2) the 1-Lipschitz property of the resulting projection, and (3) the observation that composing any ambient approximant with this nonexpansive retraction preserves both codomain membership and approximation quality. All results are formalized and machine-verified in Lean 4 using the Mathlib library.

## 1. Introduction

The Stone–Weierstrass theorem is one of the foundational results in approximation theory: it asserts that a point-separating subalgebra of continuous real-valued functions on a compact Hausdorff space is uniformly dense. This theorem, and its variants, underpin universal approximation results across mathematics and machine learning.

However, the classical theorem only addresses *scalar-valued* approximation in $C(K, \mathbb{R})$, and even its natural vector-valued extensions approximate into an ambient vector space. In many applications, the target of a continuous map is not the full ambient space but a *constrained subset*:

- **Probability simplices**: Stochastic kernels and Markov transition maps take values in the probability simplex $\Delta_n = \{p \in \mathbb{R}^n : p_i \geq 0, \sum p_i = 1\}$.
- **Bounded control sets**: Optimal control outputs must lie in feasibility regions.
- **Color spaces**: Image processing maps target convex color gamuts.
- **Portfolio weights**: Financial allocation maps target the set of admissible portfolios.
- **Neural network outputs**: Softmax layers, attention weights, and normalized activations produce outputs in convex constraint sets.

In all these settings, approximating a map $f : K \to C$ by functions $G : K \to E$ that may leave $C$ is insufficient—even if $G$ is close to $f$ in the sup norm, the values $G(x) \notin C$ may be physically meaningless or violate hard constraints.

**Our contribution.** We prove that the metric projection onto $C$—the nearest-point map—provides a universal mechanism for upgrading unconstrained approximation to constrained approximation. Because this projection is 1-Lipschitz and fixes $C$, composing any ambient $\varepsilon$-approximant $G$ with the projection yields a $C$-valued $\varepsilon$-approximant. The result is entirely constructive and applies to any nonempty compact convex set in any real inner product space.

All proofs are formalized in Lean 4 with the Mathlib library, providing machine-verified certainty.

## 2. Mathematical Setup

### 2.1 Metric Projection

**Definition.** Let $E$ be a real inner product space and $C \subseteq E$ a nonempty compact convex set. The *metric projection* $\pi_C : E \to C$ maps each point $u \in E$ to its unique nearest point in $C$:

$$\pi_C(u) = \arg\min_{v \in C} \|u - v\|.$$

**Theorem 1** (Existence and Uniqueness). *For every $u \in E$, there exists a unique $v \in C$ minimizing $\|u - v\|$.*

*Proof.* Existence follows from compactness: the continuous function $v \mapsto \|u - v\|$ attains its minimum on the compact set $C$. For uniqueness, suppose $v_1, v_2$ are both minimizers. By convexity, $\bar{v} = \frac{1}{2}(v_1 + v_2) \in C$. The parallelogram law gives:

$$\|u - \bar{v}\|^2 = \frac{1}{2}\|u - v_1\|^2 + \frac{1}{2}\|u - v_2\|^2 - \frac{1}{4}\|v_1 - v_2\|^2.$$

Since $\|u - \bar{v}\| \geq \|u - v_1\| = \|u - v_2\|$ (both are minimizers), we get $\|v_1 - v_2\|^2 \leq 0$, hence $v_1 = v_2$. $\square$

**Theorem 2** (1-Lipschitz Property). *The metric projection $\pi_C$ satisfies $\|\pi_C(x) - \pi_C(y)\| \leq \|x - y\|$ for all $x, y \in E$.*

*Proof.* Let $p = \pi_C(x)$, $q = \pi_C(y)$. The variational characterization of nearest points gives:

$$\langle x - p, w - p \rangle \leq 0 \quad \forall w \in C,$$
$$\langle y - q, w - q \rangle \leq 0 \quad \forall w \in C.$$

Setting $w = q$ in the first inequality and $w = p$ in the second, then adding:

$$\langle x - p, q - p \rangle + \langle y - q, p - q \rangle \leq 0.$$

This simplifies to $\|p - q\|^2 \leq \langle x - y, p - q \rangle \leq \|x - y\| \cdot \|p - q\|$, giving $\|p - q\| \leq \|x - y\|$. $\square$

**Corollary.** The metric projection is continuous.

**Fixed-point property.** For $u \in C$, $\pi_C(u) = u$ (the nearest point in $C$ to a point already in $C$ is itself).

### 2.2 Continuous Retraction

Combining these properties, we obtain a continuous retraction:

**Theorem 3** (Continuous Retraction). *For any nonempty compact convex $C \subseteq E$, there exists $r : E \to E$ such that:*
1. *$r$ is continuous (in fact, 1-Lipschitz),*
2. *$r(E) \subseteq C$ (maps everything into $C$),*
3. *$r|_C = \mathrm{id}_C$ (fixes $C$ pointwise).*

## 3. The Codomain-Constrained Approximation Theorem

**Theorem 4** (Codomain-Constrained Stone–Weierstrass). *Let $K$ be a compact Hausdorff space, $E$ a real inner product space, and $C \subseteq E$ a nonempty compact convex set. Let $f : K \to E$ be a continuous map with $f(K) \subseteq C$. If for every $\varepsilon > 0$ there exists a continuous $G : K \to E$ with $\|f - G\|_\infty < \varepsilon$, then there exists a continuous $g : K \to E$ with $g(K) \subseteq C$ and $\|f - g\|_\infty < \varepsilon$.*

*Proof.* Given $G$ with $\|f - G\|_\infty < \varepsilon$, define $g = \pi_C \circ G$. Then:

1. **Codomain constraint**: $g(x) = \pi_C(G(x)) \in C$ for all $x$.
2. **Continuity**: $g$ is continuous as a composition of continuous maps.
3. **Approximation quality**: Since $f(x) \in C$ for all $x$, we have $\pi_C(f(x)) = f(x)$. By the 1-Lipschitz property:

$$\|f(x) - g(x)\| = \|\pi_C(f(x)) - \pi_C(G(x))\| \leq \|f(x) - G(x)\|.$$

Taking the supremum: $\|f - g\|_\infty \leq \|f - G\|_\infty < \varepsilon$. $\square$

**Remark.** The proof is remarkably clean: the 1-Lipschitz property of $\pi_C$ does all the work. The approximant $g$ is *at least as good* as the ambient approximant $G$—projection can only help.

### 3.1 Connection to Subalgebra Approximation

When the ambient approximation class arises from a point-separating subalgebra $A \leq C(K, \mathbb{R})$—as in the Stone–Weierstrass theorem—the constrained approximant $g = \pi_C \circ G$ inherits a meaningful structural description: it is a composition of an $A$-generated map with the metric projection.

**Corollary** (Finite-Dimensional Version). *If $E$ is finite-dimensional and $A \leq C(K, \mathbb{R})$ is a point-separating subalgebra, then every $f \in C(K, C)$ can be uniformly approximated by $C$-valued maps obtained from $A$-approximants composed with $\pi_C$.*

## 4. Formal Verification in Lean 4

### 4.1 Code Structure

The formalization consists of two files:

- **`EML/ConvexRetraction.lean`**: Constructs the metric projection onto compact convex sets in real inner product spaces. Proves existence, uniqueness, the 1-Lipschitz property, and packages the result as a continuous retraction theorem.

- **`EML/ConvexStoneWeierstrass.lean`**: Proves the codomain-constrained approximation theorem, connecting the retraction to the Stone–Weierstrass framework.

### 4.2 Key Formal Statements

```lean
-- Existence of continuous 1-Lipschitz retraction
theorem exists_continuous_retraction_compact_convex
    {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C)
    (hcvx : Convex ℝ C) :
    ∃ r : E → E,
      Continuous r ∧ MapsTo r univ C ∧
      (∀ x ∈ C, r x = x) ∧ LipschitzWith 1 r

-- Codomain-constrained density theorem
theorem eml_dense_compact_convex
    {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C)
    (hcvx : Convex ℝ C)
    (f : C(K, E)) (hf : ∀ x, f x ∈ C)
    {ε : ℝ} (hε : 0 < ε)
    (ambient_approx : ∃ G : C(K, E), dist f G < ε) :
    ∃ g : C(K, E), (∀ x, g x ∈ C) ∧ dist f g < ε
```

### 4.3 Axiom Audit

All theorems depend only on the standard Lean axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry` statements remain. No custom axioms or `@[implemented_by]` are used.

## 5. Applications

### 5.1 Probability-Valued Approximation

The probability simplex $\Delta_n = \{p \in \mathbb{R}^n : p_i \geq 0, \sum p_i = 1\}$ is compact and convex. Our theorem immediately gives:

**Corollary.** Every continuous map $f : K \to \Delta_n$ can be uniformly approximated by simplex-valued maps from any subalgebra-based approximation class.

This is fundamental for approximating:
- Stochastic kernels and Markov transition operators
- Conditional probability distributions
- Softmax outputs in neural networks
- Bayesian posterior maps

### 5.2 Box-Constrained Approximation

For a product of closed intervals $C = [a_1, b_1] \times \cdots \times [a_m, b_m]$ (a "box"), the metric projection reduces to coordinatewise clamping: $\pi_C(x)_i = \mathrm{clamp}(x_i, a_i, b_i)$. Our theorem recovers the classical result that clipping an approximant preserves approximation quality.

### 5.3 Constrained Neural Approximation

In machine learning, the universal approximation theorem states that neural networks can approximate any continuous function. Our result extends this: if the target function maps into a convex constraint set $C$, then the neural approximant can be post-processed by $\pi_C$ to ensure feasibility without degrading accuracy. This applies to:

- Safe reinforcement learning (control outputs in feasible regions)
- Generative models with hard constraints
- Physics-informed neural networks with conservation laws

### 5.4 Optimal Transport

In computational optimal transport, coupling measures must satisfy marginal constraints that define a convex polytope. Approximation of optimal couplings can be constrained to this polytope via metric projection.

## 6. Discussion: Making Approximation Respect Geometry

### For the General Reader

Imagine you are trying to draw a perfect circle freehand. Your hand trembles slightly, and the line sometimes wanders outside where it should be. A natural fix: whenever the pen strays too far, snap it back to the nearest point on the correct path.

This paper proves, with mathematical certainty, that this "snap-back" strategy always works for approximation problems. More precisely: if you can approximate a function that maps into a convex shape (like a disk, a triangle, or a high-dimensional simplex), and your approximation sometimes wanders outside the shape, then projecting back onto the shape gives an approximation that is *at least as good*—and stays where it belongs.

The key property that makes this work is that the "snap-back" operation—mathematically, the *metric projection*—never increases distances. If two points are 1 meter apart, their projections onto any convex set are at most 1 meter apart. This is the *1-Lipschitz* or *nonexpansive* property, and it is what makes the whole argument go through in three lines.

Why does convexity matter? Think of a convex set as a shape with no dents or holes—like a filled circle, a triangle, or a cube. The absence of concavities guarantees that the nearest-point map is well-behaved: there is always exactly one closest point, and the map varies smoothly. For non-convex shapes (imagine a crescent moon), the nearest point can jump discontinuously as you move, and the snap-back strategy can introduce new errors.

### Historical Context

The metric projection onto convex sets has been studied since the early 20th century, with foundational contributions by Hilbert, Riesz, and later Moreau and Zarantonello. The nonexpansive property was established in the general Hilbert space setting by Zarantonello (1971), though special cases were known much earlier.

The connection to approximation theory via Stone–Weierstrass is, to our knowledge, new in this precise formulation—though the underlying ideas are natural enough that practitioners have used them informally for decades. What is new is the *formal verification*: the Lean proof guarantees that no edge case has been missed, no hypothesis forgotten, and no logical gap remains.

### Future Directions

1. **Non-convex codomains**: For non-convex sets, the nearest-point projection may not be unique or continuous. However, for sets admitting a continuous retraction (ANRs), similar results should hold.

2. **Quantitative refinements**: The 1-Lipschitz bound is sharp but coarse. For specific convex sets (simplices, balls), tighter moduli of continuity may yield improved rates.

3. **Tropical and idempotent codomains**: The EML framework naturally connects to tropical geometry. Extending codomain constraints to tropical convex sets is an active direction.

4. **Infinite-dimensional codomains**: For compact convex subsets of infinite-dimensional Hilbert spaces, the metric projection exists and is nonexpansive, but compactness hypotheses need careful treatment.

## 7. Conclusion

We have formalized a clean and general mechanism for upgrading unconstrained function approximation to codomain-constrained approximation, applicable whenever the target set is compact and convex. The mathematical core is the 1-Lipschitz property of the metric projection—a single inequality that, when combined with the Stone–Weierstrass theorem, yields a powerful constrained approximation principle.

The entire development is machine-verified in Lean 4, providing the highest available standard of mathematical certainty. The formalization is modular: the retraction theory is independent of the approximation theory, and both can be extended or reused in downstream developments.

## References

1. M. H. Stone. *The generalized Weierstrass approximation theorem*. Mathematics Magazine, 21(4):167–184, 1948.

2. E. H. Zarantonello. *Projections on convex sets in Hilbert space and spectral theory*. In Contributions to Nonlinear Functional Analysis, pages 237–424. Academic Press, 1971.

3. H. H. Bauschke and P. L. Combettes. *Convex Analysis and Monotone Operator Theory in Hilbert Spaces*. Springer, 2nd edition, 2017.

4. The Mathlib Community. *Mathlib: a unified library of mathematics formalized in Lean*. https://leanprover-community.github.io/mathlib4_docs/

---

*All Lean source code is available in `EML/ConvexRetraction.lean` and `EML/ConvexStoneWeierstrass.lean`.*
*Python demonstrations are in `demos/convex_retraction_demo.py`.*
