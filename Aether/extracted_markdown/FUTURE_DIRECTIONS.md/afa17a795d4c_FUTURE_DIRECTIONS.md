# Future Directions

## Synthesis

This research cycle established that first-species counterpoint, when formalized over ℤ₁₂ with step-bounded voice leadings, has a clean metric characterization: the step-2 transition graph equals the ball graph of radius 4 on the consonant intervals {0, 3, 4, 7, 8, 9} in the chromatic circle. The most surprising finding is the **redundancy of the parallel motion rule** at the whole-tone scale — the geometry alone determines all transitions, rendering Fux's central prohibition a consequence rather than an axiom.

The cycle also revealed a **categorical phase transition** between step bounds 2 and 3: the transition relation goes from a non-transitive, structured graph category (with diameter 2) to the trivial codiscrete category (complete graph). This phase transition connects naturally to persistent homology filtrations and may have analogs in other algebraic settings (e.g., the Bruhat order on Coxeter groups filtered by reduced word length, or the Cayley graph filtration of finitely generated groups).

The most promising cross-domain connection is between **counterpoint filtration** and **persistent homology**. The sequence of graphs G₁ ⊂ G₂ ⊂ G₃ = K₆, parameterized by step bound, is formally analogous to a Vietoris-Rips filtration. Computing the persistent homology of this filtration would yield barcodes with musical interpretation — a barcode for counterpoint. This bridges music theory, algebraic topology, and computational geometry in a way that could yield publishable results.

---

### Direction 1: Persistent Homology of the Counterpoint Filtration

**Conjecture**: The persistent homology of the Vietoris-Rips filtration on the consonant intervals {0, 3, 4, 7, 8, 9} ⊂ ℤ₁₂ (with chromatic distance) has exactly three H₀ bars born at scale 0 (reflecting the step-1 partition {0}, {3,4}, {7,8,9}) that merge into one bar at scale 5, and exactly one non-trivial H₁ bar (representing a cycle that persists across specific scale thresholds).

**Test**: Compute the Vietoris-Rips complex at each radius r = 1, 2, ..., 6 on the 6-point metric space of consonant intervals. Compute homology with ℤ/2ℤ coefficients at each scale. Track birth/death of generators. Formalize the resulting barcode as a theorem in Lean 4.

**Impact**: If confirmed, this gives the first "barcode of counterpoint" — a topological invariant that encodes the multi-scale structure of musical voice leading. It would bridge persistent homology (a major tool in applied topology) with music theory, potentially opening a new subfield.

**Catalog References**: `Novelty/CounterpointCategory.lean` (consonant interval definitions, step-bound filtration), `FINAL/Bridges/KnuthBendixCompletion.lean` (categorical completion analogies)

**Proof Strategy**: 
1. Define the simplicial complex at each scale as the nerve of the distance balls
2. Compute Betti numbers β₀, β₁, β₂ at each scale (finite computation)
3. Track generators to build the persistence module
4. Prove the barcode matches the conjectured pattern

**Domain Bridges**: Algebraic Topology ↔ Music Theory ↔ Computational Geometry

**Lineage**: Extends the Metric Bridge Theorem (step2_iff_chromDist_le_four) and Chromatic Partition (step1_three_components) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Diatonic Counterpoint and Non-Uniform Metrics

**Conjecture**: When voice leadings are restricted to diatonic steps (available intervals depend on scale position), the Metric Bridge Theorem fails: there exist consonant intervals at chromatic distance ≤ 4 that cannot be connected by diatonic voice leadings of step ≤ 2, AND consonant intervals at distance ≥ 5 that CAN be connected (because diatonic steps have non-uniform chromatic sizes: 1 or 2 semitones).

**Test**: Fix the C major diatonic scale (C D E F G A B = 0 2 4 5 7 9 11). Enumerate all consonant intervals achievable between scale-tone pairs. For each pair, determine valid diatonic voice leadings with step bound 1 (diatonic step). Compare the resulting transition graph with the chromatic metric prediction.

**Impact**: If the Metric Bridge Theorem breaks down for diatonic counterpoint, it reveals that Fux's rules are not purely geometric — they genuinely constrain the diatonic setting beyond what the metric structure provides. This would deepen our understanding of what is "geometric" vs. "algebraic" about counterpoint.

**Catalog References**: `Novelty/CounterpointCategory.lean`, `FINAL/Pythagorean/HarmonicMusicTheory.lean`

**Proof Strategy**:
1. Formalize diatonic pitch as a subtype of ℤ₁₂ (the 7-element subset {0,2,4,5,7,9,11})
2. Define diatonic intervals as differences of diatonic pitches
3. Define diatonic voice leadings (steps within the scale)
4. Compute the diatonic transition graph and compare with chromatic predictions

**Domain Bridges**: Music Theory ↔ Number Theory (non-uniform metrics on cyclic groups) ↔ Combinatorics

**Lineage**: Directly extends the Metric Bridge Theorem to a more realistic musical setting.

**Ambition**: extension

---

### Direction 3: Counterpoint Over ℤ_n: Generalized Consonance Sets

**Conjecture**: For a cyclic group ℤ_n and a "consonance set" S ⊆ ℤ_n with |S| = k, the completeness threshold (minimum step bound s such that the transition graph G_s is the complete graph K_k) equals ⌈d_max/2⌉, where d_max = max{d(i,j) : i,j ∈ S} is the diameter of S in the cyclic metric.

**Test**: Verify for n = 12, S = {0,3,4,7,8,9} (our counterpoint case: d_max = 6, ⌈6/2⌉ = 3 ✓). Test for n = 7, S = {0,2,4} (major triad in diatonic setting). Test for n = 24, S = quarter-tone consonances.

**Impact**: A general formula for completeness thresholds would unify counterpoint theory across different tuning systems and consonance definitions. It would show that the threshold-3 result for standard counterpoint is an instance of a universal pattern.

**Catalog References**: `Novelty/CounterpointCategory.lean` (completeness_threshold)

**Proof Strategy**:
1. Prove upper bound: if d(i,j) ≤ 2s for all i,j ∈ S, then G_s is complete (by constructing explicit oblique voice leadings)
2. Prove lower bound: if d(i,j) > 2s for some i,j ∈ S, then G_s is not complete (by the step constraint argument)
3. This reduces to proving the equivalence of "step-s reachability" and "metric ball" for general cyclic groups

**Domain Bridges**: Music Theory ↔ Combinatorics on Cyclic Groups ↔ Extremal Graph Theory

**Lineage**: Generalizes the Metric Bridge Theorem and Completeness Threshold from ℤ₁₂ to arbitrary ℤ_n.

**Ambition**: extension

---

### Direction 4: The Tonnetz as a 2-Category of Counterpoint

**Conjecture**: The Tonnetz (the note-relationship lattice used in Neo-Riemannian theory, generated by major-third and perfect-fifth axes) can be enriched to a 2-category where:
- 0-cells are individual pitch classes
- 1-cells are consonant intervals (our objects)
- 2-cells are valid voice leadings (our morphisms)

This 2-category is equivalent to a specific 2-dimensional CW-complex whose fundamental group encodes the voice-leading orbits of classical harmony.

**Test**: Define the 2-category formally. Compute its nerve (a simplicial set). Compute π₁ of the geometric realization. Check if it matches the group of T/I transformations (the dihedral group D₁₂ or its quotient).

**Impact**: If the fundamental group of the counterpoint 2-category equals (or contains) the neo-Riemannian transformation group, it would provide a categorical unification of two major branches of mathematical music theory that have developed independently.

**Catalog References**: `Novelty/CounterpointCategory.lean`, `FINAL/Pythagorean/HarmonicMusicTheory.lean`

**Proof Strategy**:
1. Define the 2-category using Mathlib's category theory library
2. Construct the nerve using the standard simplicial nerve construction
3. Compute the fundamental group using van Kampen's theorem (applicable since the CW-complex has finitely many cells)
4. Compare with the dihedral group D₁₂ = ⟨T, I | T¹² = I² = (IT)² = 1⟩

**Domain Bridges**: Category Theory ↔ Algebraic Topology ↔ Music Theory ↔ Group Theory

**Lineage**: Extends the categorical structure from this cycle (free category on G₂) to a higher-dimensional framework.

**Ambition**: grand_challenge

---

### Direction 5: Counterpoint Automata and Language Theory

**Conjecture**: The language of valid counterpoint sequences (infinite sequences of consonant intervals connected by valid step-2 voice leadings) is a sofic shift — the set of bi-infinite paths on the counterpoint graph G₂. Its topological entropy equals log(λ₁), where λ₁ is the largest eigenvalue of the adjacency matrix of G₂.

**Test**: Compute the adjacency matrix of G₂ (a 6×6 matrix with 28 ones). Compute its largest eigenvalue. Prove this equals the topological entropy of the sofic shift. Compare with the entropy of actual musical corpora.

**Impact**: This would provide a rigorous measure of the "complexity" of counterpoint — how many valid compositions exist per unit length. Comparing with empirical musical entropy would reveal whether composers use the full space of possibilities or inhabit a low-entropy subspace.

**Catalog References**: `Novelty/CounterpointCategory.lean` (adjacency structure), `FINAL/MachineLearning/InfiniteGames.lean` (infinite sequence strategies)

**Proof Strategy**:
1. Define the sofic shift as the set of bi-infinite paths on G₂
2. Use the standard result that topological entropy of a sofic shift = log(spectral radius of adjacency matrix)
3. Compute the characteristic polynomial of the 6×6 adjacency matrix
4. Find its dominant root (numerically and/or algebraically)

**Domain Bridges**: Symbolic Dynamics ↔ Music Theory ↔ Information Theory ↔ Spectral Graph Theory

**Lineage**: Extends the graph-theoretic analysis of G₂ to a dynamical systems perspective.

**Ambition**: extension
