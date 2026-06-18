# Future Directions: Quantitative Lattice Isoperimetry Program

## Overview

The quantitative honeycomb rigidity theorem opens a systematic research program in discrete quantitative isoperimetry. Below are five concrete research directions, each with specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Sharp Constant Optimization

### Goal
Determine the smallest universal constant C* such that the rigidity theorem holds with C = C*.

### Hypothesis
We conjecture C* = 2 for the hexagonal lattice. Each unit of boundary excess corresponds to at most one "dent" in the hexagonal patch, and each dent moves at most 2 cells in symmetric difference (one removed from inside, one added outside).

### Proof Strategy
1. Classify all minimal boundary perturbations: single-cell removals and additions that increase boundary by exactly 1.
2. Show that each such perturbation changes symmetric difference by exactly 2.
3. Prove that general perturbations decompose into sums of minimal perturbations (convexity of the boundary functional).
4. Establish matching lower bounds by constructing extremal perturbations.

### Cross-Domain Connections
- **Coding theory:** The sharp constant determines the error-correction radius of "hexagonal codes" — finite sets characterized by their boundary profile.
- **Statistical mechanics:** C* determines the precise fluctuation exponent for droplet shapes at low temperature.

### Estimated Difficulty: Medium
The classification of minimal perturbations is finite and combinatorial. The decomposition into minimal perturbations requires a discrete convexity argument.

---

## Direction 2: Extension to All Cardinalities

### Goal
Extend the rigidity theorem from hexagonal-number cardinalities (3r² + 3r + 1) to arbitrary cardinalities n.

### Hypothesis
For general n, the optimal shapes are "truncated hexagons" — hex patches with partial outer shells. The rigidity constant C(n) should be uniformly bounded independent of n, though the optimal shape varies.

### Proof Strategy
1. Compute the isoperimetric profile of the hex lattice: for each n, determine the minimum boundary h(n).
2. Characterize the extremizers at each n. For most n, the extremizer is a hex patch with a partial outer ring.
3. Extend the compression argument to non-hexagonal-number cardinalities by tracking the interaction between compression and the partial outer shell.
4. Show that the defect accounting still yields a linear bound.

### Cross-Domain Connections
- **Combinatorial optimization:** The isoperimetric profile h(n) determines the optimal clustering in partition problems on the hex lattice.
- **Number theory:** The sequence h(n) has interesting arithmetic properties related to the geometry of centered hexagonal numbers.

### Estimated Difficulty: Hard
The main challenge is that extremizers are not unique at non-hexagonal cardinalities, complicating the stability analysis.

---

## Direction 3: Anisotropic Stability on Other Lattices

### Goal
Prove quantitative rigidity theorems for the square lattice (ℤ²) and triangular lattice.

### Hypothesis
On the square lattice, the optimal shapes (at diamond numbers) are ℓ¹-balls, and near-minimizers should be close to ℓ¹-balls. On the triangular lattice, the optimal shapes are triangular patches.

### Proof Strategy
1. **Square lattice:** Define directional compressions along the two principal axes. The proof is simpler because there are only 2 directions (vs. 3 for hex), but the optimal shapes have a different symmetry group.
2. **Triangular lattice:** Define compressions along 3 directions. The combinatorics are similar to the hex case but with different fiber structures.
3. Develop a unified framework that parameterizes the lattice geometry and derives stability from abstract compression properties.

### Cross-Domain Connections
- **Tropical geometry:** Wulff shapes on lattices correspond to Newton polytopes of tropical polynomials. Stability of Wulff shapes translates to stability of tropical varieties.
- **Discrete optimal transport:** The symmetric-difference bound is a zeroth-order transport bound. Upgrading to a first-order bound (actual transport distance) would connect to discrete Monge-Kantorovich theory.

### Estimated Difficulty: Medium-Hard
The square lattice case should be easier than the hex case. The triangular case requires new combinatorial ideas.

---

## Direction 4: Transport-Distance Strengthening

### Goal
Strengthen the rigidity bound from symmetric-difference distance to earth-mover (Wasserstein) distance.

### Hypothesis
If |S| = 3r² + 3r + 1 and edgeBoundary(S) ≤ 12r + 6 + δ, then there exists a bijection φ: S → hexPatch(r) + v with ∑_{p ∈ S} hexDist(p, φ(p)) ≤ C' · δ.

### Proof Strategy
1. The compression approach already provides an implicit transport map: each cell is moved by compression to fill a gap, and the total distance moved is controlled by the gap structure.
2. Formalize the transport map induced by sequential compression.
3. Show that the total transport distance is bounded by the boundary excess times a universal constant.

### Cross-Domain Connections
- **Computational geometry:** Transport-distance bounds are stronger than symmetric-difference bounds and provide guarantees for shape-matching algorithms.
- **Probability theory:** The transport-distance strengthening would imply concentration inequalities for random near-minimizers.

### Estimated Difficulty: Medium
This is a natural extension of the compression framework. The main new ingredient is tracking transport distances through compression steps.

---

## Direction 5: Probabilistic Fluctuation Bounds via Rigidity

### Goal
Apply the deterministic rigidity theorem to derive probabilistic bounds on droplet shapes in the low-temperature Ising model on the hex lattice.

### Hypothesis
In the Ising model at inverse temperature β on the hex lattice, conditioned on the droplet having volume n = 3r² + 3r + 1, the expected symmetric difference from a hex patch is O(1/β).

### Proof Strategy
1. Use the Wulff construction to show that the probability of a configuration with boundary excess δ decays as exp(-β · δ).
2. Apply the rigidity theorem to convert boundary-excess bounds into symmetric-difference bounds.
3. Integrate over δ to obtain the expected symmetric difference: E[symmDiff] ≤ C · ∑_δ δ · exp(-β · δ) = O(C/β²).
4. Obtain almost-sure bounds via Borel-Cantelli.

### Cross-Domain Connections
- **Statistical mechanics:** This directly addresses the droplet fluctuation problem, connecting to the Dobrushin-Kotecký-Shlosman theory of phase coexistence.
- **Percolation theory:** The rigidity framework may extend to percolation clusters, where near-critical clusters have controlled shape fluctuations.

### Estimated Difficulty: Hard
This requires both the deterministic rigidity theorem and substantial probabilistic machinery (large deviations, cluster expansion).

---

## Team Directive

Each direction above is self-contained and can be pursued by a separate team. The recommended priority ordering is:

1. **Direction 3 (square lattice)** — fastest path to a second rigidity theorem; validates the general framework.
2. **Direction 1 (sharp constants)** — refines the existing result; primarily combinatorial.
3. **Direction 4 (transport distance)** — natural strengthening; extends the compression framework.
4. **Direction 2 (all cardinalities)** — hardest combinatorics; requires isoperimetric profile.
5. **Direction 5 (probabilistic)** — highest impact but requires the most machinery from other fields.

Each team should:
- State formal conjectures in the proof assistant.
- Verify small cases computationally.
- Build the necessary infrastructure (definitions, basic lemmas) before attempting the main theorem.
- Document progress incrementally and share reusable lemmas across teams.
