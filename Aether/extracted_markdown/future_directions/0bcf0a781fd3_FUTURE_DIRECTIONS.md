# Future Directions: Tropical Scheme Theory

## Synthesis

This research cycle established rigorous foundations for tropical scheme theory, bridging Grothendieck's algebro-geometric framework with tropical (min-plus) geometry. The central discovery — that the structure presheaf of tropical polynomial functions satisfies the full sheaf axioms (separation and gluing) — validates the scheme-theoretic approach to tropical geometry. The most surprising finding was the failure of tropical primality for the identity congruence, which reveals that tropical algebra requires a fundamentally different notion of "irreducibility" based on total preorders rather than equality.

The strongest cross-domain connection is between tropical scheme theory and optimization/neural network theory. Tropical polynomials are exactly the piecewise-linear functions that appear as ReLU network outputs, and corner loci are the "decision boundaries" where the active set of linear regions changes. This suggests that tropical scheme theory could provide algebraic tools for understanding neural network geometry. The Kapranov correspondence, connecting classical roots to tropical corners, also bridges number theory (p-adic valuations) to combinatorial geometry, opening routes to tropical arithmetic geometry.

The most promising direction for breakthrough is the **tropical Riemann-Roch theorem** (Direction 1), which would compute dimensions of tropical linear series using only combinatorial data. This would unify several lines of research: Baker-Norine's graph-theoretic Riemann-Roch, Mikhalkin-Zharkov's tropical curves, and the scheme-theoretic framework we developed. If successful, it would provide a machine-checkable version of one of the deepest results in tropical geometry.

---

### Direction 1: Tropical Riemann-Roch via Scheme-Theoretic Methods

**Conjecture**: For a tropical curve Γ of genus g, the tropical Riemann-Roch theorem `r(D) - r(K - D) = deg(D) - g + 1` can be derived from the sheaf-theoretic properties of the tropical structure sheaf, specifically from the cohomological vanishing of the sheaf on acyclic tropical curves.

**Test**: Formalize tropical divisors on metric graphs as integer-valued functions on the vertex set. Define the rank function r(D) as the maximum k such that D - E is effective for all effective divisors E of degree k. Prove that for a tree (genus 0), r(D) = max(0, deg(D)), which is the base case of the tropical Riemann-Roch theorem.

**Impact**: If true, this would provide the first fully verified proof of the tropical Riemann-Roch theorem, connecting sheaf cohomology to chip-firing on graphs. If false, the failure would pinpoint exactly where the classical-to-tropical analogy breaks down in cohomological arguments.

**Catalog References**: `Tropical/Schemes/Core.lean` (tropical presheaf separation and gluing), `Tropical/Schemes/IdempotentScheme.lean` (corner stalk structure), `Catalog/Tropical/TropicalFrontiers.lean` (tropical_corner)

**Proof Strategy**: 
1. Define tropical divisors as functions D : V(Γ) → ℤ on the vertex set.
2. Define the Laplacian operator Δ on the metric graph.
3. Prove that r(D) for a tree equals max(0, deg(D)) by induction on the number of vertices.
4. For general graphs, use the reduced divisor algorithm of Baker-Norine: show every divisor is linearly equivalent to a unique q-reduced divisor for each vertex q.
5. Connect the rank function to the sheaf cohomology H⁰ and H¹ of the structure sheaf twisted by D.

**Domain Bridges**: Tropical geometry ↔ Graph theory (chip-firing) ↔ Algebraic geometry (Riemann-Roch)

**Lineage**: Builds on `tropical_presheaf_separation`, `tropical_presheaf_gluing`, and `corner_locus_determines_up_to_shift` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Primality and the F₁-Geometry Connection

**Conjecture**: The prime congruences on the tropical polynomial semiring T[x] are in natural bijection with the "bent hyperplanes" — codimension-1 subsets of ℤ where a tropical polynomial achieves its minimum on two complementary half-spaces. Specifically, every prime congruence on T[x] arises from the partition of ℤ into the "left" and "right" regions of some corner point.

**Test**: Formalize the lattice of tropical congruences on T[x] (the free tropical semiring in one variable). Enumerate all prime congruences for polynomials of degree ≤ 3 and verify the bijection with bent hyperplanes. Check whether the Spec functor from tropical semirings to topological spaces is fully faithful.

**Impact**: If true, this would establish that Spec(T[x]) is naturally homeomorphic to the tropical line ℝ ∪ {±∞}, providing the "right" definition of the tropical affine line as a scheme. This would connect tropical geometry to F₁-geometry (geometry over the "field with one element"), where similar spectral phenomena occur. If false, it would mean tropical Spec requires a fundamentally different construction than classical Spec.

**Catalog References**: `Tropical/Schemes/IdempotentScheme.lean` (identity_congruence_not_prime, trivial_congruence_is_prime), `Tropical/Schemes/Core.lean` (corner_locus_two_mon_iff)

**Proof Strategy**:
1. Classify all congruences on ℤ compatible with min and +. Show they correspond to "cuts" of the natural order.
2. Characterize which cuts are prime by analyzing the primality condition in terms of the cut point.
3. Lift to T[x] using the evaluation map T[x] → T at each point.
4. Show the topology on the resulting spectrum matches the Euclidean topology on ℝ ∪ {±∞}.

**Domain Bridges**: Tropical geometry ↔ F₁-geometry (Connes-Consani) ↔ Lattice theory (congruence lattices)

**Lineage**: Directly extends `identity_congruence_not_prime` and `trivial_congruence_is_prime` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Neural Network Geometry

**Conjecture**: The "tropical scheme" of a ReLU neural network with n neurons in one hidden layer has exactly n corner points, and the corner locus determines the network's weight-bias parameters up to a finite group of symmetries (neuron permutations and sign flips). More precisely: two ReLU networks with the same corner locus and the same value at each corner point have identical input-output functions.

**Test**: Formalize a single-hidden-layer ReLU network as a tropical polynomial min(w₁x + b₁, ..., wₙx + bₙ, 0) in one variable. Prove that the corner locus has at most n elements. Show that the corner positions and values determine the weights wᵢ and biases bᵢ up to permutation.

**Impact**: If true, this would provide a mathematical framework for "identifiability" of neural networks: the geometric invariants of the tropical scheme determine the network parameters. This has implications for neural network interpretability and optimization landscape analysis. If false, it would quantify the degree of non-identifiability.

**Catalog References**: `Catalog/Tropical/OracleApplicationsFrontier.lean` (relu_tropical_polynomial), `Catalog/Tropical/Applications.lean` (tropical_network_lipschitz_bound), `Tropical/Schemes/Core.lean` (corner_locus_determines_up_to_shift)

**Proof Strategy**:
1. Model a ReLU network as an explicit tropical polynomial using the existing `TropicalMonomial` framework.
2. Prove that distinct slopes give distinct corner points (by the pairwise intersection formula).
3. Show that corner values determine the offset parameters.
4. Characterize the symmetry group as the Weyl group of permutations.

**Domain Bridges**: Tropical geometry ↔ Machine learning (ReLU networks) ↔ Optimization (piecewise-linear functions)

**Lineage**: Extends `relu_tropical_polynomial` from the catalog and `corner_locus_two_mon_iff` from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Intersection Theory and Bézout Bounds

**Conjecture**: For two tropical polynomials of degrees d₁ and d₂ in one variable, the number of common corner points (counted with multiplicity, where multiplicity at a point p is the minimum of the multiplicities of p in each polynomial) is at most d₁ · d₂. Moreover, equality holds generically (for "general" coefficient choices).

**Test**: Formalize tropical polynomial degree as the difference between the maximum and minimum slopes among monomials. Define tropical intersection multiplicity at a common corner point using the `CornerStalk` framework (minimum of the two slope changes). Prove the bound for degree-1 × degree-1 (already done as `tropical_nullstellensatz_two_mon`) and degree-1 × degree-2. Construct examples achieving equality.

**Impact**: A fully verified tropical Bézout theorem would be a major result in tropical intersection theory. The multiplicity formula connects to the dual subdivision of the Minkowski sum of Newton polygons, linking tropical geometry to combinatorial convexity.

**Catalog References**: `Catalog/Tropical/Bezout.lean` (tropical_bezout_bound_plane), `Tropical/Schemes/Multivariate.lean` (intersection_mult_canonical, tropical_stable_intersection), `Tropical/Schemes/IdempotentScheme.lean` (CornerStalk, multiplicity)

**Proof Strategy**:
1. Define degree of a tropical polynomial as max(slopes) - min(slopes).
2. Show that a degree-d polynomial has at most d corner points.
3. Define intersection multiplicity at a common corner using the determinant formula.
4. Prove the product formula by induction on max(d₁, d₂).
5. Show genericity of equality using a dimension count on the parameter space.

**Domain Bridges**: Tropical geometry ↔ Convex geometry (Minkowski sums) ↔ Enumerative geometry (Bézout theorem)

**Lineage**: Extends `tropical_bezout_bound_plane` from the catalog and `intersection_mult_canonical` from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Cohomology and Hodge Theory

**Conjecture**: For a smooth tropical curve Γ of genus g, the tropical analogue of the Hodge decomposition holds: the space of tropical 1-forms on Γ (harmonic functions on the edges, modulo constants) has dimension exactly g. This can be proved using the tropical structure sheaf developed in this cycle.

**Test**: Define tropical 1-forms on a metric graph as piecewise-linear functions on edges with integer slopes, satisfying the balancing condition at each vertex. Define the tropical de Rham complex 0 → Ω⁰ → Ω¹ → 0 and compute its cohomology. Verify that H¹ has dimension g for explicit examples: genus 0 (tree), genus 1 (cycle), genus 2 (theta graph).

**Impact**: This would connect our sheaf-theoretic framework to tropical Hodge theory (Itenberg-Katzarkov-Mikhalkin-Zharkov), providing a bridge between the algebraic and analytic perspectives on tropical curves. A verified tropical Hodge decomposition would be a significant contribution to the formalization of modern algebraic geometry.

**Catalog References**: `Tropical/Schemes/Core.lean` (tropical_presheaf_separation, tropical_presheaf_gluing), `Tropical/Schemes/Multivariate.lean` (tropical_balancing_canonical, dual_edge_perpendicular)

**Proof Strategy**:
1. Define the chain complex of a metric graph (vertices, edges, incidence).
2. Define tropical 0-forms and 1-forms as sections of sheaves on the graph.
3. Compute H⁰ = ℤ (connected) and H¹ by Euler characteristic: dim H¹ = |E| - |V| + 1 = g.
4. Show the balancing condition at vertices is the cocycle condition for 1-forms.
5. Identify the space of harmonic 1-forms with H¹ via the Hodge-theoretic identification.

**Domain Bridges**: Tropical geometry ↔ Hodge theory ↔ Graph theory (homology of graphs)

**Lineage**: Extends the sheaf axioms and balancing condition from this cycle.

**Ambition**: grand_challenge
