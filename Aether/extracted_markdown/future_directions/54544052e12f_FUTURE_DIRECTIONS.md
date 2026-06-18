# Future Directions: Tropical Knot Theory

## Research Roadmap for Min-Plus Invariants in Knot Classification

This document outlines breakthrough-level research opportunities opened by the formalization of tropical knot theory. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

### Direction 1: Tropical Khovanov Homology via Min-Plus Chain Complexes

**Hypothesis:** The Khovanov homology chain complex admits a tropicalization that yields a strictly finer invariant than the tropical Jones polynomial, with computable homological graded pieces corresponding to optimal smoothing states.

**Proof Strategy:**
1. Define a tropical chain complex `C_trop^{i,j}(D)` over the min-plus semiring, indexed by homological degree `i` and quantum degree `j`.
2. Replace the differential (which involves addition and subtraction in classical Khovanov) with a min-plus analogue: the "tropical differential" selects the minimum-cost boundary map.
3. Prove that the resulting tropical Betti numbers `β^{i,j}_trop(D)` refine the tropical Jones polynomial: the tropical Euler characteristic recovers `tJones`.
4. Formalize in Lean 4 using the existing `KnotDiagram` type, extending the smoothing tree to a graded poset of states.

**Key Lemma to Prove First:**
```
theorem tropical_euler_char_eq_tJones (D : KnotDiagram) (n : ℤ) :
  alternating_sum (tropical_betti D n) = tJones D n
```

**Cross-Domain Connection:** Persistent homology in topological data analysis uses similar min/max filtrations. Tropical Khovanov homology could provide certified topological features for knot data.

**Estimated Difficulty:** Hard (6-12 months). Requires building tropical homological algebra in Lean.

---

### Direction 2: Polynomial-Time Algorithms for Rational Knot Classification

**Hypothesis:** For rational (2-bridge) knots, the tropical Jones polynomial can be computed in O(n) time where n is the length of the continued fraction encoding, and it completely classifies rational knots up to mirror image.

**Proof Strategy:**
1. Encode rational knots via continued fraction expansions `[a₁, a₂, ..., aₖ]`.
2. Show that the tropical Jones polynomial of a rational knot satisfies a simple recurrence on the continued fraction digits.
3. Prove that the tropical Jones polynomial distinguishes all rational knots (using the Schubert classification and the relationship between continued fractions and the Jones polynomial for 2-bridge knots).
4. Implement and benchmark the O(n) algorithm.

**Key Lemma:**
```
theorem rational_knot_tJones_recurrence (cf : List ℕ) :
  tJones (rationalKnot cf) = tJones_from_cf cf
```

**Cross-Domain Connection:** Continued fractions connect to hyperbolic geometry (via Farey tessellation), number theory, and efficient algorithms. This direction creates a bridge between knot theory and computational number theory.

**Estimated Difficulty:** Moderate (3-6 months). The classical theory is well-understood; the tropical translation is the novel contribution.

---

### Direction 3: Circuit Complexity Lower Bounds via Tropical Skein DAGs

**Hypothesis:** The depth of the skein expansion DAG (with memoization) provides a lower bound on the algebraic circuit complexity of the Jones polynomial, and this lower bound can be computed in polynomial time from the tropical Jones polynomial.

**Proof Strategy:**
1. Define the skein DAG as a directed acyclic graph where nodes are sub-diagrams and edges are crossing resolutions.
2. Prove that the tropical span of `tJones` is a lower bound on the DAG depth: `tropicalSpan(tJones D) ≤ depth(skeinDAG(D))`.
3. Show that this lower bound is tight for alternating diagrams (where it equals the crossing number).
4. Connect to algebraic circuit complexity: interpret the skein DAG as an algebraic circuit computing the Jones polynomial, where tropical span becomes an analogue of formal degree.

**Key Theorem:**
```
theorem state_dag_depth_lower_bound (D : KnotDiagram) :
  tropicalSpan (tJones D) ≤ skeinDAGDepth D
```

**Cross-Domain Connection:** This directly connects knot theory to the VP vs VNP question in algebraic complexity theory. If the tropical lower bound can be shown to be superpolynomial for certain knot families, it would have implications for circuit complexity.

**Estimated Difficulty:** Hard (6-12 months). The algebraic complexity connection is deep and may require new techniques.

---

### Direction 4: Zero-Temperature Statistical Mechanics of Knot State Models

**Hypothesis:** The tropical Jones polynomial is the zero-temperature limit of the partition function of the Potts model on the knot diagram graph, and phase transitions in the temperature parameter correspond to changes in the support structure of the tropical invariant.

**Proof Strategy:**
1. Define the Potts model partition function `Z_β(D)` on knot diagrams at inverse temperature `β`.
2. Prove that `lim_{β→∞} (1/β) log Z_β(D, n) = -tJones(D, n)` (the tropical Jones value is the ground-state energy at degree n).
3. Identify phase transitions: values of `β` where the support structure changes.
4. Relate phase transitions to topological changes in the knot (e.g., crossing number thresholds).

**Key Lemma:**
```
theorem tropical_is_ground_state (D : KnotDiagram) (n : ℤ) :
  Filter.Tendsto (fun β => (1/β) * Real.log (Z_β D n)) Filter.atTop
    (nhds (-↑(tJones D n)))
```

**Cross-Domain Connection:** This connects knot theory to statistical physics, providing a physical interpretation of tropical invariants. It also connects to the theory of large deviations in probability.

**Estimated Difficulty:** Moderate-Hard (4-8 months). The statistical mechanics is standard; the formalization in Lean requires building some analysis infrastructure.

---

### Direction 5: Certified Search for Tropically-Separated Knot Pairs

**Hypothesis:** There exist pairs of knots with the same classical Jones polynomial but different tropical Jones polynomials, and such pairs can be found by systematic computational search among knots with ≤ 15 crossings.

**Proof Strategy:**
1. Implement a certified knot table for small crossing numbers using the existing `KnotDiagram` type.
2. Compute classical Jones polynomials and tropical Jones polynomials for all knots up to a crossing bound.
3. Apply the separation schema theorem: if `tropicalStateProfile D1 ≠ tropicalStateProfile D2` but `classicalJones D1 = classicalJones D2`, then tropical Jones separates them.
4. If a separating pair is found, formalize the witness in Lean as a concrete theorem.

**Key Deliverable:**
```
theorem knot_pair_separated :
  sameClassicalJones trefoil_variant_1 trefoil_variant_2 jones ∧
  differentTropicalJones trefoil_variant_1 trefoil_variant_2
```

**Cross-Domain Connection:** This connects to computational topology, knot tabulation, and the fundamental question of how much information polynomial invariants capture. A positive result would be a major breakthrough in knot theory.

**Estimated Difficulty:** Unknown — depends on whether such pairs exist among small knots. The computational search is feasible (weeks of CPU time); the existence question is open.

---

## Implementation Priorities

| Priority | Direction | Impact | Feasibility | Timeline |
|----------|-----------|--------|-------------|----------|
| 1 | Dir 2 (Rational knots) | High | High | 3-6 months |
| 2 | Dir 5 (Certified search) | Very High | Medium | 3-6 months |
| 3 | Dir 3 (Circuit complexity) | High | Medium | 6-12 months |
| 4 | Dir 4 (Statistical mechanics) | Medium | Medium | 4-8 months |
| 5 | Dir 1 (Tropical Khovanov) | Very High | Low | 6-12 months |

## Team Structure

- **Formal Methods Team:** Lean 4 formalization, proof engineering, Mathlib integration
- **Algorithms Team:** Efficient computation, knot table generation, benchmarking
- **Theory Team:** New mathematical results, proof sketches, conjectures
- **Applications Team:** Cross-domain connections, physical interpretations, visualizations

## Key Metrics

- Number of theorems formalized without sorry
- Crossing number bound tightness (ratio of tropical span to crossing number)
- Computation time for tropical Jones on standard knot tables
- Number of knot pairs tested for tropical separation
