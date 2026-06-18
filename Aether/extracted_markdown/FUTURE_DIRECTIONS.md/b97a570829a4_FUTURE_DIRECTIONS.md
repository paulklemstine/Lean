# Future Directions: Tropical Music Theory

## Direction 1: Four-Part Chorale Writing via Layered Tropical Hypergraphs

**Hypothesis**: Four-part SATB chorale writing can be modeled as optimization over a tropical hypergraph where hyperedges encode simultaneity constraints (four-note chords), pairwise edges encode voice-leading constraints (six voice pairs), and node weights encode tessitura/range constraints.

**Proof Strategy**:
1. Define a 4-melody tuple (S, A, T, B) over Fin(n+1) → ℤ.
2. Extend the cost functional to include: (a) vertical tetrad consonance penalties, (b) all six pairwise parallel-motion penalties, (c) voice-crossing penalties, (d) spacing constraints.
3. Prove a higher-dimensional zero-cost equivalence: SATB legality ↔ hypergraph cost = 0.
4. Show the DP factorizes over the layered hypergraph: the state space becomes (Fin P)⁴ at each time step, with a Bellman recursion of complexity O(n · P⁸) reduced to O(n · P⁵) via Kronecker structure.
5. Prove Pareto structure with multiple variety measures (harmonic rhythm, voice independence, chord vocabulary).

**Cross-Domain Connection**: The hypergraph formulation connects to constraint satisfaction in SAT/SMT solving, where the tropical cost provides a continuous relaxation of the Boolean feasibility problem.

**Actionable First Step**: Formalize the 4-voice cost functional in Lean 4 and prove nonnegativity and zero-characterization lemmas. Test the DP algorithm on Bach chorale harmonizations.

---

## Direction 2: Tropical Rate-Distortion Theory for Harmonic Variety

**Hypothesis**: There exists a tropical analogue of Shannon's rate-distortion theorem where: distortion = contrapuntal penalty (tropical metric), rate = harmonic variety (support-size entropy), and the rate-distortion function R(D) describes the maximum achievable variety at each penalty level.

**Proof Strategy**:
1. Define tropical entropy as H_trop(v) = |support(interval map)|, a combinatorial (non-probabilistic) measure.
2. Define the rate-distortion function: R(D) = max{harmonicVariety(u, v) : totalCost(u, v) ≤ D} over all v in the pitch space.
3. Prove R(D) is a non-decreasing, concave, step function (by finiteness of the pitch space).
4. Establish a tropical data-processing inequality: for any pitch transformation T, harmonicVariety(u, T∘v) ≤ harmonicVariety(u, v). This means post-processing cannot increase variety.
5. Prove that the Pareto frontier is exactly the graph of the rate-distortion function.

**Cross-Domain Connection**: This bridges tropical algebra with information theory, suggesting that musical style operates under information-theoretic constraints analogous to channel coding.

**Actionable First Step**: Compute R(D) numerically for several cantus firmi and verify concavity. Formalize the tropical data-processing inequality in Lean 4.

---

## Direction 3: Categorical Composition Operators on Tropical Style Spaces

**Hypothesis**: Musical transformations (transposition, inversion, retrograde, augmentation) form a category where morphisms are tropical-cost-preserving maps, and style classes are isomorphism classes under this category.

**Proof Strategy**:
1. Define the category **TropCP** whose objects are (cantus, melody) pairs equipped with their cost vectors (vertical, melodic, parallel) and whose morphisms are pitch-space maps that preserve or bound cost change.
2. Prove that transposition by k semitones is an isomorphism in **TropCP** (cost is transposition-invariant by definition).
3. Prove that inversion is a cost-preserving morphism when consonance is symmetric (which it is by the |k| symmetry).
4. Define a functor from **TropCP** to the category of weighted graphs, sending each voice-leading problem to its DP lattice.
5. Prove that this functor preserves tropical optimality: the image of an optimal morphism is an optimal path.

**Cross-Domain Connection**: This connects to category-theoretic semantics in programming language theory, where composition of musical transformations corresponds to composition of certified program transformations.

**Actionable First Step**: Prove transposition invariance of totalCost in Lean 4. Define the morphism concept and verify that standard 12-tone operations are morphisms.

---

## Direction 4: Voice-Leading as Discrete Optimal Transport

**Hypothesis**: The voice-leading cost between two chords is a Wasserstein-type optimal transport distance over the discrete pitch space, and the counterpoint optimization problem can be recast as a dynamic optimal transport problem on a time-varying measure space.

**Proof Strategy**:
1. Model each vertical sonority as a discrete measure: μ_i = δ_{u(i)} + δ_{v(i)} on ℤ.
2. Define the transport cost c(x, y) = melodicLeapPenalty(x, y) between consecutive positions.
3. Show that the melodic component of totalCost equals the sum of Wasserstein-1 distances W₁(μ_i, μ_{i+1}) over consecutive time steps (in the two-voice case, this reduces to the absolute step cost).
4. Prove stability: if the cantus firmus changes by ε in sup-norm, the optimal melody changes by at most f(ε) for an explicit modulus of continuity.
5. Extend to multi-voice transport: the SATB problem becomes a multi-marginal optimal transport problem.

**Cross-Domain Connection**: Links to computational geometry, Wasserstein distances in machine learning, and stability theory for optimization problems.

**Actionable First Step**: Prove the Wasserstein characterization of the melodic cost component in Lean 4. Implement the transport formulation and compare with the DP solution.

---

## Direction 5: Mod-12 Pitch-Class Counterpoint and Interval-Class Geometry

**Hypothesis**: Working modulo 12 (pitch classes rather than absolute pitches) changes the optimization landscape qualitatively: the tropical cost becomes periodic, the DP lattice becomes a torus, and new symmetries enable faster algorithms and richer Pareto structure.

**Proof Strategy**:
1. Redefine Melody(n) = Fin(n+1) → ZMod 12.
2. Redefine consonance on ZMod 12 (interval classes: {0,3,4,5,7,8,9} are consonant, where 5 = P4 is now included as an inversion of P5).
3. Prove the zero-cost equivalence carries over to the mod-12 setting with the modified consonance table.
4. Show that the DP state space reduces from P to 12, giving O(n · 144) = O(n) complexity.
5. Prove that the mod-12 Pareto frontier has a different structure from the absolute-pitch version: with only 12 possible intervals, variety is bounded by 12 rather than by pitch range.
6. Compare the two theories: prove that mod-12 counterpoint is a quotient of absolute-pitch counterpoint under the octave equivalence relation.

**Cross-Domain Connection**: This connects to cyclic group theory, Fourier analysis on finite groups (DFT on ℤ/12ℤ for detecting intervallic patterns), and computational music analysis in the tradition of Forte's set theory.

**Actionable First Step**: Implement the mod-12 DP algorithm and compare optimal solutions with the absolute-pitch version on the same cantus firmi. Formalize ZMod 12 consonance in Lean 4.

---

## Cross-Cutting Themes

All five directions share common algebraic infrastructure:
- **Tropical semiring operations** (min, +) as the computational backbone
- **Finset optimization** for certified extrema
- **Pareto theory** over finite multi-objective spaces
- **Dynamic programming** as the algorithmic paradigm
- **Machine verification** as the quality standard

A unified Lean 4 library for tropical music theory would provide reusable components across all directions, enabling rapid exploration of new compositional models with guaranteed correctness.
