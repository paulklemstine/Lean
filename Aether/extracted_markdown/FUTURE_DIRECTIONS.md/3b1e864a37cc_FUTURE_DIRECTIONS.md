# Future Directions: Research Roadmap

## Overview

The formalization of sorted canonical representatives for the voice-leading metric opens several breakthrough research paths. Each direction below is concrete enough for a team to pursue with clear hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Orbifold Structure of Chord Space with Singular Strata

### Vision
Formalize the quotient $\mathbb{Z}^n / S_n$ (or $\mathbb{R}^n / S_n$) as a genuine orbifold-like object. The sorted Weyl chamber $x_1 \leq x_2 \leq \cdots \leq x_n$ is the fundamental domain. Points with repeated coordinates (e.g., $x_i = x_{i+1}$) lie on singular strata where the stabilizer subgroup is non-trivial.

### Concrete Goals
1. **Define the stratification** of the sorted chamber by stabilizer type: stratum $S_\lambda$ for partition $\lambda$ of $n$ corresponding to the pattern of equalities among coordinates.
2. **Prove the metric completion** of the interior (strictly increasing tuples) is the full sorted chamber.
3. **Characterize geodesics**: show that geodesics (shortest L¹ paths) in the sorted chamber correspond to linear interpolation of sorted coordinates, with possible "collisions" at singular strata.
4. **Compute the local isometry group** at each stratum.

### Proof Strategy
- Use `Equiv.Perm.stabilizer` from Mathlib to define isotropy groups.
- Formalize the Weyl chamber as `{x : Fin n → ℤ | Monotone x}`.
- Prove that the quotient metric restricted to the chamber equals the L¹ metric (already done; extend to path-level).

### Cross-Domain Impact
- **Crystallography**: fundamental domains for space groups.
- **Eigenvalue theory**: Weyl chambers for symmetric matrices.
- **Representation theory**: weight lattices and dominant weights.

---

## Direction 2: Finite Wasserstein Equivalence and Transport Geometry

### Vision
Establish a formal bridge between the voice-leading metric and discrete optimal transport. Prove that `vlCostN` is precisely the Wasserstein-1 distance between empirical measures on $\mathbb{Z}$, and develop the transport-theoretic consequences.

### Concrete Goals
1. **Define empirical measures**: for $x : \mathrm{Fin}\, n \to \mathbb{Z}$, define $\mu_x = \frac{1}{n}\sum_i \delta_{x_i}$ as a `Measure` or `PMF` on $\mathbb{Z}$.
2. **Prove the Wasserstein equivalence**: $W_1(\mu_x, \mu_y) = \frac{1}{n} \cdot \mathrm{vlCostN}(x, y)$.
3. **Formalize Kantorovich-Rubinstein duality** for finite atomic measures: $W_1 = \sup_{f \in \mathrm{Lip}_1} |\int f\, d\mu - \int f\, d\nu|$.
4. **Prove the CDF characterization**: $W_1(\mu, \nu) = \sum_k |F_\mu(k) - F_\nu(k)|$ where $F$ is the cumulative distribution function.

### Proof Strategy
- Use Mathlib's `MeasureTheory.Measure` for the measure-theoretic formulation.
- The CDF characterization can be proved by Abel summation / summation by parts.
- The duality theorem for finite atomic measures is elementary and can be proved by linear programming duality.

### Cross-Domain Impact
- **Machine learning**: earth mover's distance for distributional comparison.
- **Statistics**: quantile-based tests, Wasserstein barycenters.
- **Economics**: optimal allocation and matching theory.

---

## Direction 3: Geodesics and Parsimonious Voice-Leading Paths

### Vision
Classify the geodesics (shortest paths) in the quotient metric on chord space. In music theory, these correspond to *parsimonious voice leadings*—the smoothest possible progressions between two chords.

### Concrete Goals
1. **Define geodesic paths**: a sequence of chords $x_0, x_1, \ldots, x_k$ where $\sum_i \mathrm{vlCostN}(x_{i-1}, x_i) = \mathrm{vlCostN}(x_0, x_k)$.
2. **Prove existence**: every pair of chords can be connected by a geodesic (of length 1, since the identity permutation gives a direct interpolation).
3. **Classify non-unique geodesics**: when do multiple geodesic paths exist? (This happens at singular strata where notes coincide.)
4. **Connect to neo-Riemannian theory**: show that PLR transformations (parallel, leading-tone, relative) between major and minor triads are near-geodesic.

### Proof Strategy
- Use the sorted representation: geodesics in the sorted chamber are simply line segments.
- The projection to the quotient may create "folds" at singular strata.
- Enumerate geodesic-length progressions between common chord types computationally.

### Cross-Domain Impact
- **Algorithmic composition**: generate smooth voice leadings automatically.
- **Music information retrieval**: measure harmonic distance in audio analysis.
- **Path planning in robotics**: analogous to shortest paths in configuration spaces with symmetry.

---

## Direction 4: Tropical and Polyhedral Structure

### Vision
Connect the sorted-chamber model to tropical geometry and polyhedral combinatorics. The L¹ metric on the Weyl chamber has a natural piecewise-linear (tropical) structure.

### Concrete Goals
1. **Formalize the Weyl chamber as a polyhedral cone**: $C = \{x \in \mathbb{Z}^n : x_1 \leq x_2 \leq \cdots \leq x_n\}$ defined by $n-1$ linear inequalities.
2. **Prove the L¹ metric on the chamber is piecewise-linear**: $d(x, y) = \sum |x_i - y_i|$ is a polyhedral norm.
3. **Connect to tropical semirings**: the voice-leading cost is a min-plus optimization, naturally expressed in the tropical semiring $(\mathbb{Z} \cup \{\infty\}, \min, +)$.
4. **Prove that the Voronoi cells** (in the L¹ metric) around lattice points in the chamber are permutohedra or their faces.

### Proof Strategy
- Use Mathlib's `Polyhedron` or `Finset.conv` for polyhedral geometry.
- The tropical connection follows from the min-plus formulation of `vlCostN`.
- Voronoi cell structure can be proved by explicit computation for small $n$ and extended by induction.

### Cross-Domain Impact
- **Tropical algebraic geometry**: new examples of tropical varieties from music theory.
- **Combinatorial optimization**: Monge matrices and totally monotone matrices.
- **Computational geometry**: L¹ Voronoi diagrams.

---

## Direction 5: Extended Symmetry Groups — Transposition and Inversion

### Vision
Extend the theory from pure voice permutation ($S_n$ action) to the semidirect product $S_n \ltimes \mathbb{Z}$ (voice permutation plus transposition) and further to include pitch-class inversion. These extended symmetries correspond to the full group of musical transformations in post-tonal theory.

### Concrete Goals
1. **Define the extended group action**: $S_n \ltimes \mathbb{Z}$ acts on $\mathbb{Z}^n$ by $(\sigma, t) \cdot x = (x_{\sigma(1)} + t, \ldots, x_{\sigma(n)} + t)$.
2. **Identify the fundamental domain**: for $S_n \ltimes \mathbb{Z}$, this is $\{x : x_1 \leq \cdots \leq x_n,\, x_1 = 0\}$ (sorted and anchored at zero).
3. **Prove the quotient metric** is still computable: sort, anchor, and sum.
4. **Add inversion**: $x \mapsto -x$ (pitch-class inversion). The group becomes $S_n \ltimes (\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z})$. Identify the fundamental domain and prove metric computability.

### Proof Strategy
- Build on `vlCostN_perm_both` for the permutation part.
- Transposition invariance: $\mathrm{vlCostN}(x + c, y + c) = \mathrm{vlCostN}(x, y)$ (straightforward).
- Inversion requires a separate argument: $\mathrm{vlCostN}(-x, -y) = \mathrm{vlCostN}(x, y)$ by the symmetry $|(-a) - (-b)| = |a - b|$.
- The combined fundamental domain is a simplicial cone.

### Cross-Domain Impact
- **Post-tonal music theory**: pitch-class set theory, the T/I group.
- **Group actions in geometry**: orbifolds under semidirect product groups.
- **Invariant theory**: computing invariant rings for finite group actions.

---

## Priority Ordering

1. **Direction 2** (Wasserstein equivalence) — highest impact, connects to the largest community, and builds most directly on current results.
2. **Direction 5** (extended symmetries) — most natural next step for music theory, moderate formalization effort.
3. **Direction 1** (orbifold structure) — deepest mathematically, but requires more infrastructure.
4. **Direction 3** (geodesics) — most musically interesting, depends on Direction 1.
5. **Direction 4** (tropical structure) — most speculative, but could yield surprising connections.

---

## Immediate Next Steps

For each direction, the first concrete task is:

1. **Orbifold**: Define `ChordStratum (n : ℕ) (λ : Partition n)` and prove it decomposes the sorted chamber.
2. **Wasserstein**: Define `empiricalMeasure (x : Fin n → ℤ) : Measure ℤ` and prove `vlCostN x y = n * W₁(μ_x, μ_y)`.
3. **Geodesics**: Define `isGeodesic (path : List (Fin n → ℤ))` and prove linear interpolation in sorted coordinates is geodesic.
4. **Tropical**: Define `tropicalVLCost` using min-plus algebra and prove equivalence with `vlCostN`.
5. **Extended symmetry**: Prove `vlCostN_translation_invariant : vlCostN (x + c) (y + c) = vlCostN x y`.
