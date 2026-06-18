# Future Directions: Tropical Knot Theory

## Overview

This document outlines five breakthrough-level research directions opened by the formalization of tropical knot invariants. Each direction includes specific hypotheses, proof strategies, and cross-domain connections that make it actionable for a research team.

---

## Direction 1: Reidemeister Invariance for Tropical Jones

### Hypothesis
The tropical Jones polynomial, when appropriately normalized by a writhe-dependent factor, is invariant under Reidemeister moves I, II, and III for combinatorial knot diagrams.

### Significance
Currently, our tropical Jones is a *diagram* invariant, not a *knot* invariant. Proving Reidemeister invariance would establish it as a genuine topological invariant, dramatically increasing its mathematical value.

### Proof Strategy
1. **Encode Reidemeister moves** as transformations on the `KnotDiagram` inductive type. Each move modifies the local structure of the resolution tree.
2. **Reidemeister I:** This introduces/removes a curl (nugatory crossing). The tropical effect is adding/removing a crossing where both resolutions are equivalent up to circle count adjustment. Requires a writhe normalization: multiply the tropical polynomial by the total writhe to cancel the R-I contribution.
3. **Reidemeister II:** Two crossings cancel if they form an antiparallel pair. Tropically, this corresponds to showing that two nested min operations with specific shift patterns reduce to the identity.
4. **Reidemeister III:** The Yang–Baxter equation for tropical skein operations. This requires showing that reordering three crossing resolutions preserves the tropical minimum.

### Concrete Next Steps
- Define `Writhe : KnotDiagram → ℤ` and a normalized tropical Jones `tJones_norm D n = tJones D (n - writhe D)`.
- Formalize R-I invariance for the restricted class of *reduced* diagrams (no nugatory crossings).
- Prove R-II invariance for antiparallel crossing pairs.
- R-III is the deepest; consider proving it first for 2-bridge knots.

### Cross-Domain Connections
- Yang–Baxter equation in quantum groups
- Rewriting confluence in term rewriting systems
- Gauge invariance in lattice gauge theory

---

## Direction 2: Certified Search for Tropical-Classical Separation

### Hypothesis
There exist explicit knot diagrams D₁, D₂ such that classicalJones(D₁) = classicalJones(D₂) but tJones(D₁) ≠ tJones(D₂).

### Significance
This would establish that tropicalization genuinely increases distinguishing power, representing a fundamental advance in knot invariant theory. The formal separation schema (Theorem D) reduces this to a finite search.

### Search Strategy
1. **Enumerate knot diagrams** up to 12 crossings using the Rolfsen/KnotInfo tables.
2. **Group by classical Jones polynomial.** Pairs with identical Jones polynomials are candidates.
3. **Compute tropical Jones** for each candidate pair using the DP algorithm.
4. **Check separation** at each degree within the support bound.

### Known Candidate Pairs
- Conway and Kinoshita-Terasaka knots (11 crossings): identical Jones polynomials.
- Mutant knot pairs: related by Conway mutation, which preserves the Jones polynomial.
- Certain satellite knots with matching Jones polynomials.

### Concrete Next Steps
- Implement a knot table parser that constructs `KnotDiagram` trees from standard PD (planar diagram) notation.
- Compute tropical Jones for all knots through 10 crossings.
- Run the separation check on all Jones-equivalent pairs.
- If separation is found, formalize the specific witness pair in Lean.

### Cross-Domain Connections
- Computational knot theory and tabulation
- SAT/CSP solvers for finding combinatorial witnesses
- Quantum computing (quantum algorithms for Jones polynomial computation)

---

## Direction 3: Tropical Khovanov Homology

### Hypothesis
The Khovanov chain complex admits a meaningful tropicalization, producing a *tropical Khovanov complex* whose homology is a strictly stronger invariant than the tropical Jones polynomial.

### Significance
Khovanov homology categorifies the Jones polynomial: the Jones polynomial is the Euler characteristic of the Khovanov chain complex. A tropical version would categorify the tropical Jones polynomial, potentially producing an entirely new class of knot invariants.

### Construction Strategy
1. **Tropical chain groups:** Replace the coefficient ring with the tropical semiring. Each chain group becomes a tropical module.
2. **Tropical differentials:** The Khovanov differential involves maps between smoothed states. Tropicalize these maps to min-plus linear maps.
3. **Tropical homology:** Define the tropical kernel and image of differentials using tropical linear algebra (the image of a min-plus linear map is a tropical module).
4. **Euler characteristic recovery:** Show that the "tropical rank" alternating sum recovers the tropical Jones polynomial.

### Challenges
- Tropical linear algebra lacks exact sequences in the classical sense.
- The tropical rank of a matrix is not straightforward.
- May need to work with valuated matroids or tropical modules instead of classical homology.

### Concrete Next Steps
- Define `TropicalChainComplex` as a sequence of `WithTop ℕ`-valued matrices.
- Prove basic properties: the composition of consecutive differentials has "tropically zero" image.
- Compute tropical Khovanov homology for the trefoil and figure-eight knots.
- Compare with classical Khovanov homology to detect refinement.

### Cross-Domain Connections
- Persistent homology (tropical Betti numbers as filtration invariants)
- Tropical algebraic K-theory
- Floer homology and gauge theory

---

## Direction 4: Complexity Lower Bounds via Tropical Knot Invariants

### Hypothesis
The tropical span of a knot's tropical Jones polynomial gives lower bounds on the circuit complexity of computing the knot's classical Jones polynomial.

### Significance
This would establish a direct bridge between knot invariant theory and computational complexity theory, potentially producing new lower bound techniques for algebraic circuits.

### Argument Outline
1. **State-sum as circuit:** The Kauffman bracket state sum is computed by an algebraic circuit of depth equal to the number of crossings. The tropical version is the "min-plus" evaluation of this circuit.
2. **Tropical degree bound:** In algebraic circuit complexity, the degree of the output polynomial bounds the circuit depth from below. The tropical analogue is that the tropical span bounds the "tropical circuit depth."
3. **Transfer principle:** If the tropical span of tJones is Ω(n) for a family of knots with n crossings, then any circuit computing the classical Jones polynomial for this family must have depth Ω(n).

### Concrete Next Steps
- Define `StateDag : KnotDiagram → Type` encoding the resolution DAG.
- Prove `tropicalSpan (tJones D) ≤ stateDagDepth D`.
- Construct families of diagrams where the tropical span grows linearly with crossing number.
- Connect to existing algebraic circuit lower bound results (Baur-Strassen, etc.).

### Cross-Domain Connections
- Algebraic circuit complexity (VP vs VNP)
- Communication complexity
- Proof complexity (lower bounds for resolution proofs)
- The catalog theorems `depth_lower_bound_from_degree` and `mulGates_lower_bound_from_degree`

---

## Direction 5: Zero-Temperature Statistical Mechanics of Knots

### Hypothesis
The tropical Jones polynomial is the ground-state energy profile of the Potts-like model associated to a knot diagram, and phase transitions in knot families correspond to discontinuities in the tropical support.

### Significance
This connects tropical knot theory to mathematical physics, potentially yielding new knot invariants from thermodynamic considerations and enabling the import of statistical mechanical methods into topology.

### Development Strategy
1. **Partition function formulation:** Express the Kauffman bracket as a partition function Z(T) = Σ_s exp(-E(s)/T), where s ranges over resolution states and E(s) is the state energy.
2. **Zero-temperature limit:** Show that lim_{T→0} -T log Z(T) = tropical Jones polynomial (coefficient-wise).
3. **Phase transitions:** For parameterized families of knots (e.g., torus knots T(2,n)), study how the support of the tropical Jones polynomial changes as n varies. Discontinuities in the support pattern indicate phase transitions.
4. **Ground state degeneracy:** The number of resolution states achieving the minimum at each degree gives a "tropical Betti number" measuring ground state degeneracy.

### Concrete Next Steps
- Implement the temperature-dependent partition function Z(T) for small diagrams.
- Numerically verify convergence to the tropical Jones polynomial as T → 0.
- Plot the "tropical phase diagram" for torus knot families.
- Formalize the zero-temperature limit theorem in Lean.

### Cross-Domain Connections
- Potts model and Tutte polynomial
- Random matrix theory (spectral gap analysis)
- Topological quantum field theory (TQFT)
- Condensed matter physics (topological phases of matter)
- The large deviation principle in probability theory

---

## Research Infrastructure Recommendations

### For a Research Team
1. **Knot table integration:** Build a parser for PD/DT notation → `KnotDiagram` inductive type, enabling large-scale computational experiments.
2. **Lean library:** Factor the Lean development into a standalone Mathlib-compatible library `TropicalKnotTheory` with clean API boundaries.
3. **Benchmarking suite:** Create a standard benchmark of tropical Jones computations on known knot families for performance comparison.
4. **Visualization tools:** Extend the matplotlib visualizations to include interactive 3D plots of tropical moduli spaces and animated simplification sequences.

### Priority Order
1. Direction 2 (Separation search) — highest impact, most immediately testable
2. Direction 1 (Reidemeister invariance) — foundational, enables all downstream work
3. Direction 4 (Complexity bounds) — bridges two major fields
4. Direction 5 (Statistical mechanics) — deepest conceptual connections
5. Direction 3 (Tropical Khovanov) — most technically challenging, longest timeline

### Timeline Estimate
- **3 months:** Directions 1 and 2 (Reidemeister invariance for restricted classes; computational separation search)
- **6 months:** Direction 4 (complexity lower bound framework)
- **12 months:** Direction 5 (statistical mechanics connections)
- **18+ months:** Direction 3 (tropical Khovanov homology)
