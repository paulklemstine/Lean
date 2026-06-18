# Future Directions: Berggren-Generated Exact Arithmetic Shell Meshes

## Overview

This document outlines five concrete breakthrough research directions opened by the formalization of Berggren shell meshes with certified tropical distances. Each direction includes specific conjectures, proof strategies, and cross-domain connections.

---

## Direction 1: Equidistribution and Discrepancy Bounds for Berggren Meshes

### Hypothesis
The depth-d Berggren mesh points, normalized to angles on the unit circle, become equidistributed as d → ∞, with discrepancy decaying polynomially in the mesh size N = (3^(d+1) − 1)/2.

### Specific Conjectures

**Conjecture 1.1.** For the depth-d Berggren mesh S_d ⊂ S¹, the spherical cap discrepancy satisfies:
```
D(S_d) = O(N^{-α}) for some α > 0
```
where N = |S_d|.

**Conjecture 1.2.** The maximum angular gap in S_d decreases at rate O(3^{-d}).

### Proof Strategy
1. Use the connection between Berggren matrices and O(2,1;ℤ) to relate mesh distribution to the spectral gap of the Laplacian on the modular surface.
2. Apply Weyl-type equidistribution criteria via exponential sums over Pythagorean angles.
3. Formalize the density result: primitive Pythagorean triples with hypotenuse ≤ T contribute ~T/2 rational points, and Berggren depth-d captures a positive proportion.

### Lean 4 Target
```lean
theorem berggren_mesh_max_gap_decreasing (d : ℕ) :
    max_angular_gap (berggren_mesh (d + 1)) ≤ max_angular_gap (berggren_mesh d) := by sorry
```

### Cross-Domain Connections
- Analytic number theory (distribution of Pythagorean angles)
- Ergodic theory (dynamics of O(2,1;ℤ) action on the circle)
- Computational geometry (point set quality metrics)

---

## Direction 2: Stereographic Lift to Rational S² Meshes

### Hypothesis
The Berggren circle mesh can be lifted to a rational mesh on the 2-sphere S² via inverse stereographic projection, preserving exactness and extending the tropical distance framework to three dimensions.

### Specific Conjectures

**Conjecture 2.1.** For a Berggren point (a/c, b/c) on S¹, the inverse stereographic projection to S² ⊂ ℝ³ yields a point with rational coordinates:
```
σ⁻¹(a/c, b/c) = (2a·c/(a²+b²+c²), 2b·c/(a²+b²+c²), (a²+b²−c²)/(a²+b²+c²))
```
which simplifies using a² + b² = c² to (a/c, b/c, 0) — the equatorial embedding.

**Conjecture 2.2.** Higher-dimensional Pythagorean equations a² + b² + c² = d² (Pythagorean quadruples) generate exact rational meshes on S² via the map (a/d, b/d, c/d).

### Proof Strategy
1. Formalize the stereographic projection as a birational map ℚ² → ℚ³.
2. Establish an analog of Theorem A for Pythagorean quadruples.
3. Develop a "Berggren-like" tree for quadruples using the classification of integer Lorentz matrices in O(3,1;ℤ).

### Lean 4 Target
```lean
theorem quad_on_sphere (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) (hd : d ≠ 0) :
    ((a:ℚ)/d)^2 + ((b:ℚ)/d)^2 + ((c:ℚ)/d)^2 = 1 := by sorry
```

### Cross-Domain Connections
- Algebraic geometry (rational points on spheres)
- Crystallography (exact lattice points on shells)
- Computer graphics (exact sphere meshes)

---

## Direction 3: Tropical Voronoi Combinatorics on Berggren Meshes

### Hypothesis
The tropical Voronoi decomposition of the plane induced by depth-d Berggren mesh sites has a rich combinatorial structure that can be computed exactly and whose complexity grows predictably with d.

### Specific Conjectures

**Conjecture 3.1.** The tropical Voronoi cell of a Berggren site (a/c, b/c) is a polygon with at most 8 edges (bounded independently of the mesh size).

**Conjecture 3.2.** The number of combinatorially distinct tropical Voronoi cells in a depth-d mesh is Θ(3^d).

**Conjecture 3.3.** Every edge of the tropical Voronoi diagram has slope in {0, ±1, ∞}, reflecting the L∞ geometry.

### Proof Strategy
1. Characterize tropical bisectors: for two points, the tropical bisector {x : d_∞(x,p) = d_∞(x,q)} is a piecewise-linear set.
2. Use the exact rational representation to compute intersections exactly.
3. Count cells and edges by induction on tree depth, exploiting the recursive structure.

### Lean 4 Target
```lean
def tropBisector (p q : ℚ × ℚ) : Set (ℚ × ℚ) :=
  {x | tropDistQ x p = tropDistQ x q}

theorem tropBisector_piecewise_linear (p q : ℚ × ℚ) (hne : p ≠ q) :
    ∃ lines : Finset (ℚ × ℚ × ℚ), ∀ x ∈ tropBisector p q,
      ∃ l ∈ lines, l.1 * x.1 + l.2.1 * x.2 + l.2.2 = 0 := by sorry
```

### Cross-Domain Connections
- Tropical algebraic geometry (tropical hypersurfaces)
- Computational geometry (Voronoi diagrams in non-Euclidean metrics)
- Optimization (facility location under L∞ metric)

---

## Direction 4: Berggren Primitivity Cascade and GCD Structure

### Hypothesis
The Berggren tree preserves not only the Pythagorean property but also a rich hierarchy of divisibility and GCD relationships that can be formalized as an "arithmetic descent" on the tree.

### Specific Conjectures

**Conjecture 4.1.** All Berggren descendants of (3, 4, 5) have pairwise coprime hypotenuses: if t₁ ≠ t₂ are distinct nodes in the Berggren tree, then gcd(c₁, c₂) = 1.

**Conjecture 4.2.** The sequence of hypotenuses along any root-to-leaf path in the B-branch satisfies the Pell-like recurrence c_{n+2} = 6c_{n+1} − c_n.

**Conjecture 4.3.** For any two Berggren points p₁, p₂ from the same depth-d mesh, the denominator of d_trop(p₁, p₂) in lowest terms divides c₁ · c₂, and equality holds generically.

### Proof Strategy
1. Use the matrix representation B₁, B₂, B₃ ∈ GL(3, ℤ) to track determinantal relations.
2. Exploit the Lorentz form preservation B^T Q B = Q to constrain GCD structure.
3. Apply p-adic valuation arguments to prove coprimality of hypotenuses.

### Lean 4 Target
```lean
theorem berggren_hyp_coprime (path₁ path₂ : List BerggrenStep)
    (hne : path₁ ≠ path₂) :
    let t₁ := applyPath path₁
    let t₂ := applyPath path₂
    Int.gcd t₁.2.2 t₂.2.2 = 1 := by sorry
```

### Cross-Domain Connections
- Algebraic number theory (unit groups, Pell equations)
- Arithmetic dynamics (iterated matrix actions on ℤ³)
- Cryptography (coprimality guarantees for key generation)

---

## Direction 5: Tropical Neural Network Verification via Berggren Test Instances

### Hypothesis
Exact Berggren shell meshes provide provably correct benchmark instances for verifying the tropical robustness certificates of ReLU neural networks.

### Specific Conjectures

**Conjecture 5.1.** For a ReLU network f: ℝ² → ℝ^k, the decision boundary restricted to the unit circle can be sampled exactly at Berggren mesh points, yielding certified robustness radii.

**Conjecture 5.2.** The tropical robustness radius at a Berggren point (a/c, b/c) — defined as the minimum tropical distance to a decision boundary — is a computable rational number when the network weights are rational.

**Conjecture 5.3.** Depth-d Berggren meshes with d ≥ 4 provide sufficient coverage to detect all robustness violations up to tropical radius ε > 0, for ε depending polynomially on 3^{-d}.

### Proof Strategy
1. Formalize the connection between ReLU networks and tropical rational functions.
2. Define the certified robustness radius as a tropical distance computation.
3. Show that mesh density (from Direction 1) guarantees detection of violations.

### Lean 4 Target
```lean
def tropRobustnessRadius (mesh : Finset BerggrenTriple) (classify : ℚ × ℚ → ℕ)
    (t : BerggrenTriple) : ℚ :=
  Finset.inf' (mesh.filter (fun s => classify (toRatPoint s) ≠ classify (toRatPoint t)))
    ⟨sorry⟩ (fun s => tropDistQ (toRatPoint t) (toRatPoint s))
```

### Cross-Domain Connections
- Machine learning (adversarial robustness certification)
- Tropical geometry (tropical polynomial decision boundaries)
- Formal verification (certified safety for AI systems)

---

## Research Team Directive

Each direction should be pursued by a team following this workflow:

1. **Formulate** precise mathematical conjectures with Lean type signatures.
2. **Validate** computationally with Python experiments (up to depth 6–8).
3. **Decompose** into helper lemmas and prove bottom-up.
4. **Cross-pollinate** — results in one direction often unlock progress in others.
5. **Iterate** — update conjectures based on computational evidence and proof attempts.

The most immediate high-impact targets are:
- Direction 1 (equidistribution) — foundational for all applications
- Direction 2 (spherical lift) — broadest geometric generalization
- Direction 4 (GCD structure) — deepest number-theoretic content
