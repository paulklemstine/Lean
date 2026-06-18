# Future Directions: Voice-Leading Geometry and Neo-Riemannian Theory

## Overview

The formally verified bridge between PLR transformations and voice-leading geodesics opens several concrete research programs. Each direction below includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Extension to Seventh Chords and the 4-Voice Orbifold

### Hypothesis
The analogue of PLR for four-note chords (dominant seventh, diminished seventh, half-diminished, minor seventh, major seventh) consists of transformations that move exactly one voice by 1–2 semitones, and these are geodesic or near-geodesic in the 4-voice quotient orbifold (ℤ₁₂)⁴/S₄.

### Approach
1. **Classify all 2-common-tone quality changes** among standard seventh chord types. The 3-common-tone moves are the direct analogues of PLR.
2. **Compute voice-leading distances** by optimal transport over S₄ (24 permutations per pair). The space has ~48 chords (12 roots × 4+ qualities), giving ~2,304 pairs — still finite and decidable.
3. **Formalize in Lean** using the same `native_decide` methodology. The combinatorial explosion is larger but tractable.
4. **Prove geodesicity or near-geodesicity** with an explicit constant C.

### Key Challenge
Seventh chords have more quality types and more complex interval structures. The analogue of the "unique minimizer" theorem may fail — there could be more than 2 geodesic quality-changing moves from a given chord.

### Cross-Domain Connection
The 4-voice orbifold connects to the theory of 4-body configuration spaces in physics and chemistry (e.g., molecular geometry under bond permutation symmetry).

### Deliverables
- Classification of all "parsimonious" seventh chord moves
- Lean formalization of geodesicity for the 4-voice case
- Comparison with existing music-theoretic catalogues (Childs 1998, Douthett & Steinbach 1998)

---

## Direction 2: The Continuous Voice-Leading Orbifold

### Hypothesis
In the continuous orbifold (ℝ/12ℤ)³/S₃, the straight-line segments between sorted representatives of PLR-related chords project to minimizing geodesics. When the segment crosses a singular stratum (the walls of the Weyl chamber where two coordinates coincide), the projected path length still equals the quotient distance.

### Approach
1. **Define the orbifold metric** formally as the infimum of path lengths over all smooth (or piecewise-linear) paths in the quotient, using the standard Riemannian metric lifted from (ℝ/12ℤ)³.
2. **Prove that the fundamental domain** (sorted chamber {x₁ ≤ x₂ ≤ x₃}) is convex in the ambient metric.
3. **Show that line segments in the sorted chamber are geodesics** by verifying the geodesic equation or using comparison geometry.
4. **Handle singular strata**: when a path crosses a wall {xᵢ = xⱼ}, the quotient identification may fold the path. Prove that for PLR endpoints, this folding does not increase path length.

### Key Challenge
The singular strata require careful analysis. At walls where two coordinates coincide, the orbifold has a ℤ₂ singularity (locally a cone over ℝP¹). Geodesics passing through these points may "refract."

### Cross-Domain Connection
This connects directly to Alexandrov geometry (curvature bounds on quotient spaces) and to the theory of geodesics in Weyl chambers used in Lie theory and symmetric spaces.

### Deliverables
- Lean formalization of the continuous orbifold as a metric space
- Proof of convexity of the sorted chamber
- Geodesicity theorem for PLR in the continuous case

---

## Direction 3: The Tonnetz as a Tropical Subcomplex

### Hypothesis
The Tonnetz graph embeds isometrically as a subcomplex of a tropical polyhedral complex whose ambient metric agrees with the voice-leading distance on vertices.

### Approach
1. **Identify the polyhedral structure**: the sorted chamber in ℤ₁₂³ is a finite polyhedral complex. The quotient by S₃ gives a cell complex whose 0-cells are triads and whose 1-cells correspond to minimal voice leadings.
2. **Define the tropical fan**: use the min-plus algebra structure of sorted coordinates to define a tropical variety. The Tonnetz vertices correspond to lattice points in this fan.
3. **Prove isometric embedding**: show that the shortest-path metric on the 1-skeleton of the tropical complex restricts to the voice-leading distance on PLR-adjacent vertices.
4. **Connect to the tropical Grassmannian**: the space of 3-note chords in ℤ₁₂ may relate to the tropical Grassmannian Gr(3, 12) studied in algebraic combinatorics.

### Key Challenge
Defining the right tropical complex requires choosing the correct polyhedral decomposition. The natural candidates are the secondary polytope of ℤ₁₂³ and the Weyl chamber decomposition.

### Cross-Domain Connection
- Tropical algebraic geometry (Maclagan & Sturmfels 2015)
- Polyhedral combinatorics and fiber polytopes
- Persistent homology of musical chord spaces

### Deliverables
- Definition of the tropical chord complex
- Proof that PLR edges are 1-cells
- Computation of the full face lattice

---

## Direction 4: PLR Dynamics and Coxeter Group Actions

### Hypothesis
The PLR group, viewed as a subgroup of the symmetry group of the Tonnetz, has a natural interpretation as a Coxeter group acting on a polyhedral complex. The geodesicity theorem implies that PLR generators correspond to reflections across the walls of a Coxeter chamber, with the voice-leading distance equal to the length function on the Coxeter group.

### Approach
1. **Identify the Coxeter structure**: the PLR group is isomorphic to D₁₂ = ℤ₁₂ ⋊ ℤ₂. Determine whether this group arises as a Coxeter group with natural generators corresponding to geometric reflections.
2. **Compute the word metric**: the word metric on the PLR group (minimum number of P, L, R moves to reach a given group element) should relate to the voice-leading distance.
3. **Prove a quasi-isometry**: show that the word metric on the PLR group is quasi-isometric to the voice-leading metric on chords, with explicit constants.
4. **Generalize to higher cardinalities**: for n-note chords, determine the Coxeter-type structure of the generalized PLR group.

### Key Challenge
The PLR group is not a standard Coxeter group because P, L, R are involutions but do not satisfy braid relations in general. The connection to Coxeter theory may require passing to a larger group or a quotient.

### Cross-Domain Connection
- Coxeter groups and reflection groups (Humphreys 1990)
- Geometric group theory: quasi-isometry and Gromov hyperbolicity
- Crystallographic groups and lattice symmetries

### Deliverables
- Lean formalization of the PLR group structure
- Computation of the Cayley graph with voice-leading edge weights
- Quasi-isometry constants between word metric and voice-leading metric

---

## Direction 5: Formally Verified Harmonic Analysis for MIR

### Hypothesis
The voice-leading distance, with its formally verified metric properties (especially the triangle inequality), provides a principled, provably correct basis for harmonic similarity computation in music information retrieval (MIR). Algorithms using this metric will outperform ad hoc distance measures on standard MIR benchmarks.

### Approach
1. **Extract verified algorithms**: compile the Lean-verified metric computations to executable code using Lean's code generation, producing a provably correct distance oracle.
2. **Implement DTW with the verified metric**: dynamic time warping using chordDist as the base metric, with formal guarantees on the output.
3. **Benchmark on MIR datasets**: test on standard chord recognition and harmonic similarity datasets (e.g., Billboard, RWC, Isophonics).
4. **Prove convergence of clustering**: using the triangle inequality, prove that k-medoids clustering with chordDist converges and produces a valid partition.

### Key Challenge
MIR applications require handling chord types beyond major/minor triads (sevenths, suspended, augmented, power chords, etc.). Extending the verified metric to a richer chord vocabulary is necessary for practical applicability.

### Cross-Domain Connection
- Music information retrieval and computational musicology
- Verified software engineering: extracting formally correct algorithms from proofs
- Metric learning and kernel methods in machine learning

### Deliverables
- Lean-verified implementation of harmonic DTW
- Python library wrapping the verified metric for MIR pipelines
- Benchmark results on standard datasets
- Formal correctness certificate for the distance computation

---

## Priority Ranking

| Direction | Novelty | Feasibility | Impact | Priority |
|-----------|---------|-------------|--------|----------|
| 1. Seventh chords | Medium | High | High | **1st** |
| 5. MIR applications | Medium | High | High | **2nd** |
| 4. Coxeter dynamics | High | Medium | Medium | **3rd** |
| 3. Tropical complex | Very High | Medium | High | **4th** |
| 2. Continuous orbifold | High | Low | Very High | **5th** |

---

## Cross-Cutting Themes

All five directions share common mathematical infrastructure:

- **Quotient metrics on orbifolds**: the fundamental tool is the optimal-transport distance on a quotient space.
- **Finite decidability + formal verification**: the strategy of proving theorems by exhaustive computation over finite structures is applicable to all discrete extensions.
- **Polyhedral geometry**: sorted chambers, Weyl chambers, and tropical fans provide the geometric framework.
- **Symmetry analysis**: the interplay between the permutation group Sₙ and the cyclic group ℤ₁₂ drives all the algebraic structure.

The research program aims to build a comprehensive, formally verified theory of harmonic geometry, bridging music theory, algebraic combinatorics, metric geometry, and computational applications.
