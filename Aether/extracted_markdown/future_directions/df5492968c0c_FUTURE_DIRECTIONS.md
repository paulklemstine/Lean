# Future Research Directions

## Synthesis

This cycle established a formal bridge between first-species counterpoint and finite graph theory, revealing that the six consonant interval classes under stepwise voice leading form a balanced directed graph with exactly 26 edges and diameter 2. The most promising discovery is the **Stepwise Separation Theorem**: perfect consonances (unison and fifth) cannot reach each other in a single step because the maximum interval change (4 semitones) is insufficient to cross the 7-semitone gap. This forces all paths between perfect consonances through imperfect consonances, creating a natural 2-level stratification.

The most exciting cross-domain connection is between the **balanced graph property** and **Eulerian circuit theory**: a balanced finite directed graph admits an Eulerian circuit if and only if it is connected. Our graph IS connected (diameter 2), so it admits an Eulerian circuit traversing all 26 edges exactly once. This means there exists a 26-note counterpoint passage that uses every legal interval transition exactly once — a musical analog of an Euler tour. This connects directly to combinatorics (de Bruijn sequences, Eulerian graphs) and could yield novel compositional techniques.

The cycle's results relate to the broader Catalog through the voice leading cost seminorm (from `Catalog/Algebra/MusicalCounterpoint.lean`) and Pythagorean consonance theory (from `Catalog/Pythagorean/HarmonicMusicTheory.lean`). The graph-theoretic approach provides a third perspective that unifies ratio-based consonance classification with constraint-based voice leading optimization. The highest breakthrough potential lies in Direction 1 (Euler tours) and Direction 3 (spectral analysis of the adjacency matrix).

---

### Direction 1: Eulerian Circuits as Compositional Constraints

**Conjecture**: The 26-edge counterpoint transition graph admits exactly *N* distinct Eulerian circuits (up to starting vertex), where *N* can be computed via the BEST (de Bruijn) theorem or the Matrix-Tree theorem applied to the balanced digraph.

**Test**: (1) Verify the graph is Eulerian by confirming it is balanced and strongly connected (already done). (2) Compute the number of Eulerian circuits using the BEST theorem: the count equals t_w · ∏(deg⁺(v) - 1)!, where t_w is the number of arborescences rooted at any vertex w. Compute t_w via the Matrix-Tree theorem on the Laplacian of the graph. (3) Enumerate circuits computationally for verification.

**Impact**: If the count is small (say, under 100), each Eulerian circuit corresponds to a unique "maximally diverse" counterpoint passage — a composition that uses every legal transition exactly once. This would be a novel compositional constraint with mathematical guarantees. If the count is large, the combinatorial richness itself is interesting.

**Catalog References**: `Catalog/Algebra/MusicalCounterpoint.lean` (voice leading cost function for ranking circuits), `Catalog/Pythagorean/HarmonicMusicTheory.lean` (consonance classification)

**Proof Strategy**: Define the 6×6 adjacency matrix A of the transition graph. Compute the Laplacian L = D - A where D is the diagonal degree matrix. The number of arborescences rooted at vertex w is the determinant of the (w,w)-minor of L. Then apply the BEST theorem formula. This requires formalizing directed graph Laplacians and the Matrix-Tree theorem for digraphs, which are non-trivial but well-established results.

**Domain Bridges**: Combinatorics (Euler tours, de Bruijn sequences) ↔ Music theory (maximal-diversity counterpoint) ↔ Linear algebra (graph Laplacians, Matrix-Tree theorem)

**Lineage**: Builds on the 26-edge graph characterization and balanced graph theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Multi-Voice Counterpoint Categories

**Conjecture**: For *n*-voice first-species counterpoint (n ≥ 3), the consonant chord types form a finite category whose transition graph has significantly different structural properties than the 2-voice case. Specifically, in 3-voice counterpoint where the perfect fourth becomes consonant, the inversion asymmetry (Theorem A) is resolved, and the transition graph becomes inversion-symmetric.

**Test**: (1) Define consonant chord types for 3 voices (root position, first inversion, second inversion triads). (2) Enumerate valid transitions under stepwise motion with no parallel fifths/octaves. (3) Check whether the resulting graph is balanced, what its diameter is, and whether the inversion map σ is a graph automorphism.

**Impact**: If the 3-voice graph is inversion-symmetric (as predicted by the resolution of the fourth's consonance status), this confirms that the 2-voice asymmetry is an artifact of the 2-voice restriction, not a deep property of counterpoint. If the asymmetry persists in a different form, that would be surprising and indicate a deeper structural principle.

**Catalog References**: `Catalog/Algebra/MusicalCounterpoint.lean` (n-voice framework already defined), `Catalog/Pythagorean/HarmonicMusicTheory.lean` (interval classification)

**Proof Strategy**: Represent a 3-voice chord state as a tuple of interval classes (i₁₂, i₁₃, i₂₃) ∈ (ℤ/12ℤ)³ with the constraint i₂₃ = i₁₃ - i₁₂. This reduces the state space to pairs (i₁₂, i₁₃). Enumerate consonant pairs, define transitions, build the graph, and check properties computationally and formally.

**Domain Bridges**: Music theory (multi-voice counterpoint) ↔ Combinatorics (higher-dimensional transition graphs) ↔ Group theory (symmetry groups of chord spaces)

**Lineage**: Direct extension of the 2-voice results from this cycle, specifically extending Theorem A (inversion asymmetry).

**Ambition**: extension

---

### Direction 3: Spectral Theory of the Counterpoint Adjacency Matrix

**Conjecture**: The eigenvalues of the 6×6 adjacency matrix of the counterpoint transition graph encode musically meaningful information. Specifically, the spectral gap (difference between largest and second-largest eigenvalue) correlates with the graph's mixing time, which has a musical interpretation as "how quickly a random walk on consonances forgets its starting interval."

**Test**: (1) Compute the adjacency matrix A of the 26-edge graph. (2) Find its eigenvalues (over ℝ or ℂ). (3) Compute the spectral gap and mixing time. (4) Interpret the eigenvectors: do they separate perfect from imperfect consonances? (5) Formalize the spectral computation and prove the characteristic polynomial in Lean 4.

**Impact**: If the eigenvectors separate perfect from imperfect consonances, this provides an independent spectral characterization of the consonance hierarchy — the partition into perfect/imperfect would be "audible" in the spectrum of the graph. This connects music theory to spectral graph theory in a novel way.

**Catalog References**: `Catalog/Computation/SpectralProofComplexity.lean` (spectral methods in Lean), `Catalog/Algebra/MusicalCounterpoint.lean` (counterpoint framework)

**Proof Strategy**: The adjacency matrix is:
```
A = [0 1 1 0 1 1]   (rows/cols indexed by 0,3,4,7,8,9)
    [1 1 1 1 0 0]
    [1 1 1 1 1 0]
    [0 1 1 0 1 1]
    [1 0 1 1 1 1]
    [1 0 0 1 1 1]
```
Compute det(A - λI) to get the characteristic polynomial. Analyze eigenvalues over ℚ[√·]. The block structure (0 and 7 have identical rows) means the matrix has rank at most 5, giving at least one zero eigenvalue. This structural zero eigenvalue is itself interesting.

**Domain Bridges**: Spectral graph theory ↔ Music theory (consonance hierarchy) ↔ Markov chains (random walks on consonances) ↔ Linear algebra (eigenvalue problems)

**Lineage**: Builds on the 26-edge graph from this cycle and the spectral methods in the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Counterpoint Transition Monoid

**Conjecture**: The set of all valid stepwise voice leadings (as pairs (a,b) with |a|,|b| ≤ 2), under the composition operation of sequential application, generates a finite monoid whose structure (idempotents, Green's relations, minimal ideal) encodes counterpoint-theoretic information.

**Test**: (1) Define the monoid of voice leading transformations on the interval class ℤ/12ℤ. Each voice leading (a,b) acts as i ↦ i + (b-a) mod 12. (2) The semigroup generated by the 25 stepwise pairs (5×5 grid) is a finite transformation monoid on {0,1,...,11}. (3) Compute its size, find its Green's structure, and determine which elements preserve the consonance set. (4) The restriction to consonance-preserving transformations gives the "counterpoint monoid" — compute its structure.

**Impact**: If the counterpoint monoid has a non-trivial ideal structure, this provides an algebraic explanation for why certain interval sequences feel more "final" than others (they correspond to idempotents or elements in the minimal ideal). This connects music theory to algebraic semigroup theory.

**Catalog References**: `Catalog/Bridges/KnuthBendixCompletion.lean` (algebraic completion methods), `Catalog/Algebra/MusicalCounterpoint.lean` (voice leading framework)

**Proof Strategy**: Represent each voice leading as a function ℤ/12ℤ → ℤ/12ℤ (specifically, a translation by (b-a)). The generated monoid is a subgroup of the translation group ℤ/12ℤ. Identify which translations preserve the consonance set {0,3,4,7,8,9}. This is equivalent to finding which d ∈ ℤ/12ℤ satisfy {0,3,4,7,8,9} + d = {0,3,4,7,8,9}. The answer gives the symmetry group of the consonance set.

**Domain Bridges**: Semigroup theory (Green's relations) ↔ Music theory (voice leading algebra) ↔ Group theory (symmetry of consonance sets)

**Lineage**: Extends the voice leading composition (Theorem E) from this cycle into full algebraic structure.

**Ambition**: extension

---

### Direction 5: Tropical Counterpoint: Voice Leading Over Min-Plus

**Conjecture**: If voice leading cost is viewed as a tropical (min-plus) algebra quantity rather than a classical one, the counterpoint transition graph acquires a tropical metric structure where "distance" between intervals equals the minimum voice leading cost of a path between them.

**Test**: (1) Compute the minimum-cost valid voice leading for each of the 26 edges. (2) Compute the tropical distance matrix D where D[i,j] = minimum total cost over all valid paths from i to j. (3) Verify D satisfies the tropical triangle inequality (min-plus). (4) Compare D to the ordinary shortest-path distance (hop count). (5) Determine whether D is a tropical metric (i.e., D[i,j] + D[j,i] > 0 for i ≠ j, which fails for self-loops).

**Impact**: Tropical geometry has deep connections to algebraic geometry and optimization. If the counterpoint distance matrix has interesting tropical-geometric properties (e.g., its tropical convex hull has a specific structure), this opens a bridge between music theory and tropical geometry — two fields not previously connected.

**Catalog References**: `Catalog/Tropical/` (tropical algebra framework), `Catalog/Algebra/MusicalCounterpoint.lean` (voice leading cost), `Catalog/Cryptography/` (tropical cryptography)

**Proof Strategy**: Define the tropical semiring (ℕ ∪ {∞}, min, +). Compute the adjacency matrix with edge weights = voice leading cost. Apply tropical matrix multiplication (Floyd-Warshall with min-plus) to compute all-pairs shortest paths. Formalize the tropical metric axioms and verify them.

**Domain Bridges**: Tropical geometry ↔ Music theory (voice leading cost) ↔ Optimization (shortest paths) ↔ Category theory (enriched categories over tropical semiring)

**Lineage**: Combines the cost grading (Theorem E) from this cycle with the tropical algebra framework in the Catalog.

**Ambition**: extension
