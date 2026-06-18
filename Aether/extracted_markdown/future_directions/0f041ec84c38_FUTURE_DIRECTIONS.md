# Future Research Directions

## Synthesis

This research cycle established that species counterpoint, when formalized as a constraint satisfaction problem over the voice motion lattice ℤⁿ, exhibits a rich interaction between the L¹ cost function and the distributive lattice structure. The central discovery is the **L¹-lattice identity**: cost(m₁ ⊓ m₂) + cost(m₁ ⊔ m₂) = cost(m₁) + cost(m₂), a conservation law stating that lattice operations redistribute voice leading cost exactly. This identity, combined with the sublattice theorem for ascending motions and the characterization of interval preservation via parallel motion, provides a complete algebraic toolkit for analyzing voice leading optimization.

The most promising cross-domain connection is between the lattice-cost conservation law and tropical geometry. The L¹ norm is the natural norm in tropical mathematics (where addition is replaced by min/max), and the lattice identity is essentially a tropical identity. This suggests that voice leading theory may be a natural application domain for tropical algebraic geometry, connecting the Catalog's existing tropical semiring work with the new counterpoint formalization. The consonance lattice also connects to the harmonic series and number theory through the ranking of interval classes by their frequency ratios.

The highest breakthrough potential lies in Direction 1 (tropical voice leading), because it would unify three apparently disparate areas — music theory, lattice theory, and tropical geometry — through a single algebraic framework. If the tropical semiring structure on voice motions can be made precise, it would provide new computational tools for voice leading optimization and potentially reveal deep connections between musical consonance and tropical algebraic varieties.

---

### Direction 1: Tropical Voice Leading Theory

**Conjecture**: The voice motion space ℤⁿ, equipped with the operations (⊓, +) where ⊓ is componentwise min, forms a tropical semiring, and the voice leading cost function is a tropical norm — i.e., it satisfies cost(m₁ ⊓ m₂) = min(cost(m₁), cost(m₂)) when m₁ and m₂ are "tropically compatible" (each component of one dominates the corresponding component of the other).

**Test**: Verify computationally for n = 2, 3, 4 whether the tropical norm property holds for randomly sampled pairs of voice motions that are componentwise comparable (m₁ ≤ m₂ pointwise). Check if the counterpoint constraint set is a tropical variety.

**Impact**: If true, this would establish voice leading as a natural domain for tropical geometry, giving access to tropical Bézout theorems, tropical intersection theory, and tropical linear algebra for analyzing counterpoint. If false, the failure mode would reveal which tropical axioms break in the musical context, potentially suggesting modified tropical structures adapted to music theory.

**Catalog References**: `Tropical/` (tropical semiring definitions), `Algebra/MusicalCounterpoint.lean` (L¹-lattice identity)

**Proof Strategy**: Define the tropical semiring structure on VoiceMotion(n) using min for addition and + for multiplication. Verify the semiring axioms. Then define the tropical norm and prove it equals the L¹ cost for tropically comparable pairs. The key lemma would be: if m₁ ≤ m₂ pointwise, then cost(m₁ ⊓ m₂) = cost(m₁) = min(cost(m₁), cost(m₂)).

**Domain Bridges**: Tropical Geometry <-> Music Theory <-> Lattice Theory

**Lineage**: Builds on the L¹-lattice identity (cost_meet_join_eq) and the ascending sublattice theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Multi-Step Voice Leading as Path Optimization

**Conjecture**: For a sequence of k chords connected by voice leadings under counterpoint constraints with stepwise bound b, the optimal total cost satisfies a dynamic programming recurrence, and the optimal path lies on the boundary of a polytope in ℤⁿᵏ defined by the constraint intersections.

**Test**: Implement the dynamic programming algorithm for k = 4 chords with n = 4 voices and b = 4. Compare the DP solution to brute-force enumeration for 100 random chord sequences. Verify that optimal paths are always on polytope boundaries by checking if relaxing any constraint changes the solution.

**Impact**: If true, this would reduce multi-step voice leading from exponential (brute force) to polynomial time, and the polytope characterization would connect counterpoint to combinatorial optimization and integer linear programming. If false, it would identify which constraint interactions create non-convexity, suggesting where heuristic methods are needed.

**Catalog References**: `Algebra/MusicalCounterpoint.lean` (cost function, constraint system), `Computation/InfoEfficientAlgorithms.lean` (algorithmic efficiency)

**Proof Strategy**: Define the state space as the set of feasible motions at each step. Show the cost function decomposes as a sum over steps. Apply the principle of optimality (Bellman) to establish the recurrence. For the polytope result, show that the feasible set at each step is defined by linear inequalities (|m(i)| ≤ b is equivalent to -b ≤ m(i) ≤ b) and the counterpoint constraints are linear (m(i) ≠ m(j) defines a complement of a hyperplane).

**Domain Bridges**: Combinatorial Optimization <-> Music Theory <-> Polytope Theory

**Lineage**: Extends optimal_exists_of_finset and stepwise_cost_bound from this cycle to sequential settings.

**Ambition**: extension

---

### Direction 3: Non-Commutative Counterpoint and Group Actions

**Conjecture**: The set of voice leadings satisfying a fixed constraint system, modulo octave equivalence (ℤⁿ/12ℤⁿ), forms a group under composition, and the no-parallel-fifths constraint defines a normal subgroup of index related to the number of perfect fifths in the source chord.

**Test**: For n = 2 voices with source chord containing a perfect fifth (e.g., C-G), enumerate all motions modulo 12 that satisfy no-parallel-fifths, and check if they form a group under addition mod 12. Compute the index of this subgroup in (ℤ/12ℤ)².

**Impact**: If true, this would connect counterpoint to group theory and potentially to representation theory (via group actions on chord spaces). The index formula would give a precise count of "how many voice leadings the parallel-fifths rule eliminates." If false, it would reveal that constraint satisfaction and group structure are incompatible, which itself is an important structural result.

**Catalog References**: `Algebra/MusicalCounterpoint.lean` (noParallelFifths), `Cryptography/BerggrenGroupoidOrbit.lean` (group actions)

**Proof Strategy**: Work in (ℤ/12ℤ)ⁿ. The no-parallel-fifths constraint eliminates motions where m(i) ≡ m(j) mod 12 for voices i, j that are a fifth apart. This complement of a diagonal in (ℤ/12ℤ)² has 144 - 12 = 132 elements. Check closure under addition — this requires showing that if m₁ avoids the diagonal and m₂ avoids the diagonal, then m₁ + m₂ avoids the diagonal. This is likely FALSE (counterexample: m₁ = (1,0), m₂ = (0,1), m₁+m₂ = (1,1) which IS on the diagonal). So the conjecture may need refinement: perhaps the quotient set has interesting combinatorial structure even without being a group.

**Domain Bridges**: Group Theory <-> Music Theory <-> Combinatorics

**Lineage**: Extends noParallelFifths and the interval characterization from this cycle.

**Ambition**: extension

---

### Direction 4: Spectral Theory of Consonance

**Conjecture**: The consonance score function, extended to a function on ℤ via the pitch class map, is a positive definite function on the group ℤ/12ℤ, and its Fourier transform on ℤ/12ℤ has exactly 4 nonzero coefficients corresponding to the "circle of fifths" generators.

**Test**: Compute the discrete Fourier transform of the consonance score function on ℤ/12ℤ. Check if all Fourier coefficients are nonneg (positive definiteness). Count the number of significantly nonzero coefficients.

**Impact**: If true, this would connect consonance theory to harmonic analysis on finite groups, suggesting that consonance is fundamentally a frequency-domain phenomenon even at the level of discrete pitch classes. The connection to the circle of fifths would provide a group-theoretic explanation for why the fifth is the most consonant non-trivial interval. If false, it would show that consonance cannot be captured by linear (Fourier) methods, suggesting a fundamentally nonlinear theory.

**Catalog References**: `Algebra/MusicalCounterpoint.lean` (consonanceScore), `EML/AdvancedTheory.lean` (spectral methods)

**Proof Strategy**: The consonance score values are [8,1,2,5,5,6,0,7,4,4,1,1] for pitch classes 0-11. Compute the DFT: ĉ(k) = (1/12) Σⱼ c(j) exp(-2πijk/12). Check nonnegativity. The positive definiteness is equivalent to the Toeplitz matrix [c(i-j mod 12)] being positive semidefinite.

**Domain Bridges**: Harmonic Analysis <-> Music Theory <-> Number Theory

**Lineage**: Extends the consonanceScore definition from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Categorical Voice Leading

**Conjecture**: There exists a category **VL** whose objects are chords (integer-valued functions on a finite set) and whose morphisms are feasible voice leadings, such that the voice leading cost function is a lax monoidal functor from **VL** to (ℝ≥0, +), and the lattice operations on voice motions correspond to limits and colimits in **VL**.

**Test**: Define **VL** explicitly for n = 2 voices with stepwise bound b = 2. Verify the category axioms (identity = zero motion, composition = addition of motions). Check whether the cost function satisfies cost(g ∘ f) ≤ cost(f) + cost(g) (lax monoidality = triangle inequality). Determine if meets/joins of voice motions are categorical products/coproducts.

**Impact**: If true, this would embed voice leading theory into category theory, giving access to universal properties, adjunctions, and Kan extensions for analyzing musical structure. The lax functor structure would generalize the seminorm properties. If false, it would identify precisely which categorical axiom fails, revealing a structural obstacle to categorical music theory.

**Catalog References**: `Algebra/MusicalCounterpoint.lean` (full framework), `Bridges/` (cross-domain connections)

**Proof Strategy**: Objects = Chord(n), morphisms from c₁ to c₂ = feasible motions m with c₂ = c₁ + m (interpreted as voice motion). Identity = zero motion (cost 0). Composition = addition (cost satisfies triangle inequality by Theorem 3.3). The question is whether meets/joins have universal properties. The meet m₁ ⊓ m₂ is the greatest lower bound in the pointwise order, which should be a categorical product if the pointwise order defines the morphism ordering.

**Domain Bridges**: Category Theory <-> Music Theory <-> Lattice Theory

**Lineage**: Extends the full framework (seminorm, lattice identity, constraints) from this cycle.

**Ambition**: extension
