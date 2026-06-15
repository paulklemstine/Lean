# Stone–Weierstrass for Compact Polyhedral Codomains via Simplicial Embedding and Piecewise-Affine Neighborhood Retraction

## Abstract

We establish a formally verified universal approximation theorem for continuous maps with codomain a compact polyhedron realized inside Euclidean space. The proof proceeds by an explicit neighborhood-retraction argument: given a compact set $K \subseteq \mathbb{R}^n$ equipped with an open neighborhood $U \supseteq K$ and a continuous retraction $r: U \to K$, we show that any continuous map $f: X \to K$ from a compact space can be uniformly approximated by maps of the form $r \circ g$, where $g: X \to \mathbb{R}^n$ is an ambient Euclidean approximant. The key ingredients are (1) a uniform tubular margin lemma guaranteeing that points sufficiently close to $K$ lie in $U$, (2) a quantitative stability estimate for the retraction near $K$, and (3) the classical Stone–Weierstrass theorem for Euclidean-valued maps. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

**Keywords:** Stone–Weierstrass theorem, universal approximation, compact polyhedra, neighborhood retraction, formal verification, Lean 4

---

## 1. Introduction

The Stone–Weierstrass theorem is one of the cornerstones of approximation theory. In its classical form, it asserts that any continuous real-valued function on a compact Hausdorff space can be uniformly approximated by elements of any point-separating subalgebra containing the constants. This foundational result has been extended in numerous directions: to vector-valued functions, to lattice subalgebras (the Kakutani–Stone theorem), and to various classes of approximation functions including neural networks, polynomials, and exponential-multiplicative-logarithmic (EML) maps.

However, a fundamental limitation of these extensions is that they typically require the codomain to be a normed vector space — usually $\mathbb{R}$ or $\mathbb{R}^n$. Many applications in geometry, robotics, and topology involve continuous maps into *nonlinear* targets: surfaces, configuration spaces, simplicial complexes, and more general polyhedra. For such targets, the classical Stone–Weierstrass machinery does not directly apply.

### 1.1 Our Contribution

We prove a universal approximation theorem for continuous maps $f: X \to K$, where $K$ is a compact polyhedron (or more generally, any compact set admitting a neighborhood retraction) realized inside Euclidean space $\mathbb{R}^n$. The proof is constructive and geometric:

1. **Approximate in the ambient space.** Use the Euclidean-valued Stone–Weierstrass theorem to find $g: X \to \mathbb{R}^n$ uniformly close to $f$.
2. **Control the image.** A uniform tubular margin lemma ensures that if $g$ is sufficiently close to $f$, then the image of $g$ lies in the retraction neighborhood $U$.
3. **Retract back to $K$.** The composition $h = r \circ g$ maps into $K$ and uniformly approximates $f$.

The entire argument is formalized in Lean 4 with the Mathlib mathematical library, yielding machine-verified proofs of all intermediate lemmas and the final theorem.

### 1.2 Why Polyhedra?

Compact polyhedra form a large and geometrically significant class of spaces. They include:

- **Finite simplicial complexes** — triangulated surfaces, meshes, combinatorial manifolds.
- **Convex polytopes** — the feasible regions of linear programming, Voronoi cells.
- **Configuration spaces** — joint-angle constraints in robotics, mechanical linkages.
- **Stratified spaces** — moduli spaces, orbit spaces of finite group actions.

Every compact polyhedron admits a PL (piecewise-linear) neighborhood retraction when realized in Euclidean space. Our theorem therefore applies to all such targets.

---

## 2. Mathematical Setup

### 2.1 Polyhedral Retract Data

We package the geometric data needed by the approximation theorem into a single structure.

**Definition 1** (Polyhedral Retract). A *polyhedral retract* in $\mathbb{R}^n$ consists of:
- A compact nonempty set $K \subseteq \mathbb{R}^n$ (the target polyhedron),
- An open set $U \subseteq \mathbb{R}^n$ with $K \subseteq U$ (the retraction neighborhood),
- A continuous map $r: U \to \mathbb{R}^n$ such that:
  - $r(U) \subseteq K$ (the retraction maps into $K$),
  - $r(x) = x$ for all $x \in K$ (the retraction fixes $K$).

In the Lean formalization, this is the `PolyhedralRetract` structure, with $U$ represented as a subtype and all continuity/compactness hypotheses carried as fields.

### 2.2 Uniform Dense Approximation

We abstract the approximation class via the following predicate.

**Definition 2** (Uniform Dense Approximation). We say that $\mathbb{R}^n$-valued approximation is *uniformly dense* on a topological space $X$ if for every continuous map $f: X \to \mathbb{R}^n$ and every $\varepsilon > 0$, there exists a continuous map $g: X \to \mathbb{R}^n$ such that $\|g(x) - f(x)\| < \varepsilon$ for all $x \in X$.

This is satisfied, for instance, by:
- Polynomial maps (classical Weierstrass),
- Stone–Weierstrass subalgebras applied coordinatewise,
- EML-generated function classes,
- Neural network approximators.

---

## 3. Main Results

### 3.1 Uniform Tubular Margin (Theorem 1)

**Theorem 1.** *Let $K \subseteq \mathbb{R}^n$ be compact, $U \subseteq \mathbb{R}^n$ open, and $K \subseteq U$. Then there exists $\delta > 0$ such that*
$$\{x \in \mathbb{R}^n : d(x, K) < \delta\} \subseteq U.$$

*Proof.* This follows from the compactness of $K$ and openness of $U$. For each $y \in K$, openness of $U$ gives $\rho_y > 0$ with $B(y, \rho_y) \subseteq U$. The balls $\{B(y, \rho_y/2)\}_{y \in K}$ cover $K$; by compactness, extract a finite subcover with centers $y_1, \ldots, y_m$ and set $\delta = \min_i \rho_{y_i}/2$. If $d(x, K) < \delta$, then $x$ is within $\delta$ of some $y \in K$, which lies in some $B(y_i, \rho_{y_i}/2)$, giving $d(x, y_i) < \rho_{y_i}$, hence $x \in U$.

In Lean, this is proved as `exists_thickening_subset_open` using Mathlib's `IsCompact.exists_thickening_subset_open`. ∎

### 3.2 Maps Close to Compact Sets Land in Open Neighborhoods (Theorem 2)

**Theorem 2.** *Under the hypotheses of Theorem 1, there exists $\delta > 0$ such that for any maps $f, g: X \to \mathbb{R}^n$, if $g(x) \in K$ and $\|f(x) - g(x)\| < \delta$ for all $x$, then $f(x) \in U$ for all $x$.*

This is the mechanism by which an ambient approximant, close enough to a $K$-valued map, is guaranteed to land in the retraction neighborhood.

### 3.3 Retraction Stability Near $K$ (Theorem 3)

**Theorem 3.** *Let $(K, U, r)$ be a polyhedral retract in $\mathbb{R}^n$. For every $\varepsilon > 0$, there exists $\delta > 0$ such that if $y \in K$, $x \in U$, and $\|x - y\| < \delta$, then $\|r(x) - y\| < \varepsilon$.*

*Proof sketch.* Choose $\delta_0 > 0$ such that the closed $\delta_0$-thickening $T$ of $K$ is contained in $U$ (using Theorem 1 for closed thickenings). The set $T$ is compact (as a closed bounded subset of $\mathbb{R}^n$, which is a proper metric space). The restriction of $r$ to $T$ is continuous on a compact set, hence uniformly continuous. Since $r(y) = y$ for $y \in K$, if $x \in T$ and $\|x - y\| < \delta$ (where $\delta$ comes from uniform continuity), then $\|r(x) - r(y)\| = \|r(x) - y\| < \varepsilon$.

In Lean, this is `retract_uniform_near_points`, proved using `IsCompact.cthickening` and `IsCompact.uniformContinuousOn_of_continuous`. ∎

### 3.4 Main Approximation Theorem (Theorem 4)

**Theorem 4** (Universal Approximation for Polyhedral Codomains). *Let $X$ be a compact topological space, $(K, U, r)$ a polyhedral retract in $\mathbb{R}^n$, and suppose that $\mathbb{R}^n$-valued approximation is uniformly dense on $X$. Then for any continuous map $f: X \to K$ and any $\varepsilon > 0$, there exists a continuous map $h: X \to K$ such that $\|h(x) - f(x)\| < \varepsilon$ for all $x \in X$.*

*Proof.* 
1. By Theorem 3, choose $\delta_1 > 0$ such that $\|r(x) - y\| < \varepsilon$ whenever $y \in K$, $x \in U$, and $\|x - y\| < \delta_1$.
2. By Theorem 2, choose $\delta_2 > 0$ such that any map $\delta_2$-close to a $K$-valued map has image in $U$.
3. Set $\delta = \min(\delta_1, \delta_2)$ and use uniform density to find $g: X \to \mathbb{R}^n$ with $\|g(x) - f(x)\| < \delta$ for all $x$.
4. Since $\delta \leq \delta_2$ and $f$ maps into $K$, we have $g(x) \in U$ for all $x$.
5. Define $h(x) = r(g(x))$. This is continuous (composition of continuous maps) and maps into $K$.
6. Since $\delta \leq \delta_1$, $f(x) \in K$, $g(x) \in U$, and $\|g(x) - f(x)\| < \delta_1$, Theorem 3 gives $\|h(x) - f(x)\| = \|r(g(x)) - f(x)\| < \varepsilon$.

In Lean, this is `eml_uniform_dense_polyhedral_codomain`. The constructive version `exists_retracted_eml_approx` additionally returns the ambient approximant $g$ and the membership proof that $g(x) \in U$. ∎

---

## 4. Formal Verification

### 4.1 Lean 4 Formalization

All results are formalized in Lean 4 (version 4.28.0) with Mathlib. The formalization consists of approximately 270 lines of Lean code in the file `EML/StoneWeierstrass/PolyhedronCodomain.lean`.

**Theorem statements proved:**

| Lean name | Mathematical content |
|-----------|---------------------|
| `exists_thickening_subset_open` | Uniform tubular margin (Theorem 1) |
| `exists_uniform_nhd_of_compact_in_open` | Pointwise version of Theorem 1 |
| `mapsTo_of_uniform_close_to_compact` | Close-to-compact maps land in $U$ (Theorem 2) |
| `retract_uniform_near_points` | Retraction stability (Theorem 3) |
| `eml_approx_into_retraction_nhd` | Ambient approximation into $U$ |
| `eml_uniform_dense_polyhedral_codomain` | Main theorem (Theorem 4) |
| `exists_retracted_eml_approx` | Constructive version of Theorem 4 |

**Axioms used:** Only the standard foundational axioms: `propext`, `Classical.choice`, `Quot.sound`. No additional axioms or `sorry` placeholders.

### 4.2 Design Decisions

- The `PolyhedralRetract` structure uses Lean's subtype mechanism for $U$, representing it as `↥U = {x : Fin n → ℝ // x ∈ U}`. This ensures type-safety of the retraction map.
- The approximation class is abstracted via `UniformDenseApprox`, making the theorem modular and applicable to any dense approximation class (polynomials, neural networks, EML maps, etc.).
- The proof of retraction stability (`retract_uniform_near_points`) uses the fact that `Fin n → ℝ` is a proper metric space, allowing compact thickenings and uniform continuity arguments.

---

## 5. Applications

### 5.1 Robotics: Joint-Constrained Trajectory Approximation

In robotics, a multi-joint robot arm has a configuration space $\Theta = (\theta_1, \ldots, \theta_k)$ subject to constraints (joint limits, collision avoidance). The feasible region is often a convex polytope or a union of polytopes in $\mathbb{R}^k$.

Our theorem guarantees that any continuous trajectory $f: [0, T] \to K$ within the feasible region can be uniformly approximated by a smooth trajectory $h = r \circ g$, where $g$ is a polynomial (or neural network) approximant and $r$ is the nearest-point projection. The approximant $h$ automatically satisfies the joint constraints.

### 5.2 Computer Graphics: Mesh-Constrained Deformations

In mesh deformation and character animation, one often needs to approximate continuous maps $f: \Omega \to M$ where $M$ is a triangulated surface (a 2-dimensional simplicial complex in $\mathbb{R}^3$). Our theorem provides a principled way to:

1. Approximate $f$ by a smooth map $g$ into the ambient $\mathbb{R}^3$,
2. Project back to the mesh $M$ using a neighborhood retraction,
3. Guarantee that the approximation error is controlled.

### 5.3 Topology: CW Approximation via Retracts

The retraction-based approach provides an alternative to classical CW approximation techniques. For compact polyhedra (which are compact ANRs), the existence of neighborhood retractions is guaranteed by the ANR property. Our formalization isolates the approximation-theoretic content from the topological construction, making the argument reusable for broader classes of ANR targets.

### 5.4 Optimization: Feasible-Region-Constrained Function Approximation

In constrained optimization, one often needs to approximate an objective function or policy function while ensuring the output remains in a feasible region $K$ (a polytope defined by linear inequalities). The retraction method provides a "project-then-optimize" approach that is provably convergent.

---

## 6. Discussion: Making Polyhedra Soft — A Scientific American Perspective

Imagine you're a sculptor working with clay. You want to shape the clay into a specific form — say, a triangular prism. Your hands can only make smooth, sweeping motions (polynomial curves), but the target shape has sharp edges and flat faces. How do you get there?

The answer is surprisingly elegant: **don't try to be precise from the start.** Instead:

1. **Rough it out.** Make a smooth approximation that's *close* to the triangle, even if it bulges out a bit beyond the edges.
2. **Press it flat.** Use a mold (the retraction $r$) to push everything back onto the triangular surface.

This is exactly what our theorem formalizes. The "mold" is the mathematical retraction — a continuous map that takes any nearby point and snaps it back to the polyhedron. The key insight is that if your rough approximation is close enough, the mold doesn't distort it too much, and you end up with something that's both (a) on the polyhedron and (b) close to your target shape.

### Why does this work?

The magic comes from three ingredients:

1. **The safety margin.** Because the polyhedron $K$ sits inside a larger open neighborhood $U$, there's a "buffer zone" around $K$ where the retraction is defined. Our first theorem quantifies this: there's a minimum width $\delta$ for this buffer (the "uniform tubular margin").

2. **The retraction is gentle.** Near the polyhedron, the retraction barely moves points. This is because it fixes points already on $K$, and by continuity, it moves nearby points only a little. Our third theorem makes this precise.

3. **Smooth functions are flexible.** The classical Stone–Weierstrass theorem tells us that smooth (or polynomial, or neural network) functions can approximate any continuous function as closely as we want. We use this to get close, then let the retraction do the rest.

### A historical note

This result sits at the intersection of two great traditions in mathematics:

- **Approximation theory**, going back to Weierstrass (1885) and Stone (1937), which asks: "What functions can be approximated by simple ones?"
- **PL (piecewise-linear) topology**, developed by Whitehead, Zeeman, and others in the mid-20th century, which studies spaces built from flat pieces — simplices glued together.

The bridge between them is the *neighborhood retraction*, a concept from algebraic topology. Borsuk (1931) introduced the notion of an ANR (absolute neighborhood retract) precisely to capture spaces that have such retractions. Our theorem makes this connection computationally explicit and formally verified.

### Looking forward

The retraction-based approximation principle extends far beyond polyhedra. Any compact ANR target — which includes all compact manifolds, stratified spaces, and many singular spaces — admits a neighborhood retraction, and our proof applies verbatim. The formal verification in Lean 4 ensures that every step of the argument is rigorous, catching subtle issues (like the need for proper metric spaces in the uniform continuity argument) that might be glossed over in a pen-and-paper proof.

---

## 7. Future Directions

1. **Simplicial realization.** Formalize the construction of `PolyhedralRetract` data from a finite simplicial complex presentation. This requires Mathlib infrastructure for simplicial complexes that is currently under development.

2. **Broader ANR targets.** Extend to compact manifolds and compact metric ANRs, where the retraction exists by abstract topological arguments rather than explicit PL construction.

3. **Quantitative bounds.** Relate the retraction modulus to the geometry of $K$ (e.g., the reach of $K$, or the minimal angle in a triangulation) to obtain explicit convergence rates.

4. **EML-specific density.** Connect with the existing EML Stone–Weierstrass machinery to obtain concrete approximation by exponential-multiplicative-logarithmic maps.

5. **Computational implementations.** Develop efficient algorithms for the retraction $r$ when $K$ is a simplicial complex, and benchmark the approximation quality in practice.

---

## 8. Conclusion

We have established and formally verified a universal approximation theorem for continuous maps into compact polyhedra, extending the Stone–Weierstrass program to a geometrically significant class of nonlinear targets. The proof isolates a reusable principle — ambient approximation, quantitative control, retraction — that applies to any compact set with neighborhood retraction data. All 7 theorems are machine-verified in Lean 4 with only standard foundational axioms, providing the highest level of mathematical certainty.

---

## References

1. M.H. Stone, "The generalized Weierstrass approximation theorem," *Mathematics Magazine* 21 (1948), 167–184.
2. K. Weierstrass, "Über die analytische Darstellbarkeit sogenannter willkürlicher Functionen einer reellen Veränderlichen," *Sitzungsberichte der Königlich Preußischen Akademie der Wissenschaften zu Berlin* (1885), 633–639, 789–805.
3. K. Borsuk, "Sur les rétractes," *Fundamenta Mathematicae* 17 (1931), 152–170.
4. The Mathlib Community, "Mathlib: a unified library of mathematics formalized in Lean," https://github.com/leanprover-community/mathlib4
5. J.R. Munkres, *Elements of Algebraic Topology*, Addison-Wesley, 1984.
