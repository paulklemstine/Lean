# Future Directions: Equivariant Impossibility Spectra

## Synthesis

This research cycle established a complete formal framework for the **impossibility spectrum** — the set of subgroups H ≤ G for which no H-equivariant map exists between two G-sets. We proved its fundamental structural properties (upward closure, conjugation invariance, transfer principle) and introduced three novel concepts: the **spectral gap** (minimal obstructing subgroups, forming an antichain), the **equivariant defect set** (quantifying non-equivariance with a characterization theorem), and the **orbit-type obstruction** (stabilizer-based impossibility that strictly generalizes fixed-point obstructions).

The most promising cross-domain connection is between the spectral gap structure and the closure systems in `Bridges/AlgebraEMLClosureComputation.lean`. The impossibility spectrum's upward closure makes it dual to a closure operator's fixed-point set: while closure operators capture what *must* be included (downward closure), the impossibility spectrum captures what *cannot* be achieved (upward closure). The orbit-type obstruction theorem connects to cardinality arguments in `Computation/InfoEfficientAlgorithms.lean`, where stabilizer counting plays a role analogous to information-theoretic lower bounds. The defect composition theorem provides a bridge to the probe families in `Bridges/AlgebraEMLClosureComputation.lean`, where compositional structure of measurement systems parallels the compositional structure of equivariant defects.

The direction with highest breakthrough potential is **Spectral Completeness** (Direction 1). Every impossibility spectrum (with nonempty target) satisfies the obstruction filter axioms — upward closure, conjugation invariance, and exclusion of the trivial subgroup. The converse question — whether every obstruction filter is realizable — would transform the study of equivariant impossibility from case-by-case analysis into a complete classification theory. The Burnside ring provides the key algebraic tool: the marks homomorphism sends a virtual G-set to its table of fixed-point counts, and realizability reduces to solving integer linear programs in these marks.

---

### Direction 1: Spectral Completeness via the Burnside Ring

**Conjecture**: Every obstruction filter on a finite group G is realizable as the impossibility spectrum of some pair of finite G-sets. Formally: given a set S of subgroups of a finite group G that is (1) upward closed, (2) conjugation invariant, and (3) does not contain the trivial subgroup, there exist finite G-sets X and Y with Spec(G, X, Y) = S.

**Test**: For G = S₃ (symmetric group on 3 elements), enumerate all obstruction filters (there are finitely many, since S₃ has finitely many conjugacy classes of subgroups). For each filter, explicitly construct G-sets X and Y realizing it, or prove no such pair exists. The subgroup lattice of S₃ has conjugacy classes {1}, ⟨(12)⟩, ⟨(123)⟩, S₃, giving a manageable combinatorial problem.

**Impact**: If true, this would provide a complete classification of equivariant impossibility: the obstruction filter axioms would be necessary and sufficient. If false, it would reveal additional arithmetic constraints on impossibility spectra beyond the filter axioms, likely related to the Burnside ring's integrality conditions.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (closure systems as dual structure), `Computation/InfoEfficientAlgorithms.lean` (cardinality bounds)

**Proof Strategy**: 
1. Formalize the Burnside ring Ω(G) for finite G and the marks homomorphism φ : Ω(G) → ∏_{(H)} ℤ.
2. Show that the impossibility spectrum is determined by the fixed-point counts φ_H(X) and φ_H(Y).
3. Reduce realizability to solving φ_H(X) > φ_H(Y) for H ∈ S and φ_H(X) ≤ φ_H(Y) for H ∉ S.
4. Use the characterization of the image of φ (the Burnside ring's congruence conditions) to determine feasibility.

**Domain Bridges**: Burnside ring (algebra) ↔ impossibility spectrum (combinatorics/topology) ↔ integer programming (optimization)

**Lineage**: Builds on this cycle's `impSpec_isUpperSet`, `impSpec_conj_invariant`, `bot_not_mem_impSpec`, `fixed_point_obstruction`, and the ObstructionFilter structure from `Shared/EquivariantSpectrum/Filter.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Metric Equivariant Defect and Approximation Bounds

**Conjecture**: For a compact metric G-space Y and finite group G, when H is in the impossibility spectrum of (X, Y), there exists a positive lower bound δ(H, X, Y) > 0 such that every function f : X → Y has sup_{h ∈ H, x ∈ X} d(f(h·x), h·f(x)) ≥ δ. Moreover, this bound is computable from the geometry of the orbit decomposition.

**Test**: For G = ℤ/2ℤ acting on X = {0, 1, 2} by (0↔1, 2↦2) and Y = {a, b} by (a↔b), with the discrete metric, compute the minimum defect explicitly. The spectrum should contain G (since X has a fixed point {2} but Y has no fixed point), and the minimum defect should be exactly 1 (the discrete metric distance).

**Impact**: If true, this would bridge the gap between discrete impossibility theory (no equivariant map exists) and continuous approximation theory (how close can we get). This has direct applications to equivariant neural network design, where approximate equivariance is the practical standard.

**Catalog References**: `Physics/EquivariantSpectra.lean` (defect set theory), `Bridges/AlgebraEMLClosureComputation.lean` (probe families as measurement systems)

**Proof Strategy**:
1. Define the metric defect: ε(f, H) = sup_{h ∈ H, x ∈ X} d(f(h·x), h·f(x)).
2. Show that when H ∈ ImpSpec, the infimum of ε(f, H) over all f is positive (by compactness of the function space for finite X and compact Y).
3. Express the optimal defect in terms of orbit geometry: the minimum distance between the image of FixedPts(H, X) and the complement of FixedPts(H, Y).
4. Derive explicit formulas for specific group actions (cyclic, dihedral, symmetric).

**Domain Bridges**: Metric geometry ↔ equivariant defect (algebra) ↔ neural network design (ML)

**Lineage**: Builds on this cycle's `defect_empty_iff_equivariant` and `defect_comp_of_equivariant`.

**Ambition**: extension

---

### Direction 3: Higher Orbit-Type Stratification and the Burnside Category

**Conjecture**: The orbit-type obstruction can be refined using the Burnside category. For a finite group G, define the Burnside category B(G) with objects = conjugacy classes of subgroups and morphisms = spans of equivariant maps. The impossibility spectrum is determined by the functor that assigns to each conjugacy class (H) the set FixedPts(H, X) → FixedPts(H, Y).

**Test**: For G = ℤ/3ℤ acting on X = G/1 (free orbit of size 3) and Y = G/G (single fixed point), verify that the impossibility spectrum equals {G} (the full group is obstructed because a free orbit of size 3 must map to a fixed point, but the equivariance constraint forces f(g·x) = g·f(x) = f(x) for all g, making f constant on the orbit, which is compatible). Actually verify the exact spectrum computationally to calibrate the theory.

**Impact**: If the Burnside category characterization works, it would reduce impossibility spectrum computation to checking a finite collection of set maps between fixed-point sets — a purely combinatorial problem. This would also connect to the Elmendorf theorem in equivariant homotopy theory.

**Catalog References**: `Physics/EquivariantSpectra.lean` (orbit-type obstruction), `Algebra/AntipodeUniqueness.lean` (categorical algebra)

**Proof Strategy**:
1. Define the fixed-point presheaf F_X : B(G)^op → Set, sending (H) to FixedPts(H, X).
2. Show that HasHEquivariantMap(H, X, Y) is equivalent to the existence of a natural transformation F_X → F_Y that is compatible with the inclusion maps between fixed-point sets.
3. Formalize the Elmendorf reconstruction theorem: a G-set is determined by its fixed-point presheaf.
4. Derive the spectrum directly from the natural transformation condition.

**Domain Bridges**: Category theory (Burnside category) ↔ equivariant topology (Elmendorf) ↔ combinatorics (fixed-point counting)

**Lineage**: Builds on this cycle's `orbit_type_blocks_injective` and `equivariant_maps_fixed`.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Gap Width and Complexity Classification

**Conjecture**: The number of conjugacy classes in the spectral gap (the "spectral width") is bounded by the number of prime divisors of |G| for transitive G-sets. Specifically, for G acting transitively on X and Y, the spectral gap contains at most ω(|G|) conjugacy classes, where ω is the number of distinct prime divisors.

**Test**: Compute the spectral gap for all transitive actions of groups of order ≤ 30. For each pair of transitive G-sets, count the conjugacy classes in the spectral gap and compare with ω(|G|). A single counterexample disproves the conjecture.

**Impact**: If true, this would show that the complexity of the impossibility landscape is controlled by the arithmetic of the group order, connecting number theory to equivariant combinatorics. The bound would also make spectral gap computation polynomial in the number of primes dividing |G|.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (complexity bounds), `Algebra/ArtinPrimitiveRoot.lean` (prime structure of groups)

**Proof Strategy**:
1. For transitive G-sets X = G/H and Y = G/K, characterize when L ∈ ImpSpec(G, G/H, G/K) in terms of the double coset structure H\G/K.
2. Show that the spectral gap elements correspond to maximal elements of a certain poset of "incompatible pairs" of subgroups.
3. Use the structure theory of p-subgroups (Sylow theory) to bound the number of incompatible pairs by the number of primes.

**Domain Bridges**: Number theory (prime factorization) ↔ group theory (Sylow structure) ↔ impossibility spectra (combinatorics)

**Lineage**: Builds on this cycle's `spectral_gap_antichain` and `spectral_gap_subset_spectrum`.

**Ambition**: extension

---

### Direction 5: Equivariant Impossibility in Quantum Information

**Conjecture**: For a finite group G acting unitarily on Hilbert spaces H₁ and H₂, the impossibility spectrum for quantum channels (completely positive trace-preserving maps) Φ : B(H₁) → B(H₂) satisfying Φ(UρU†) = UΦ(ρ)U† is determined by the decomposition into irreducible representations. Specifically, H is in the quantum impossibility spectrum if and only if some irreducible representation of H appears with higher multiplicity in H₁ than in H₂.

**Test**: For G = ℤ/2ℤ with H₁ = ℂ² (standard representation) and H₂ = ℂ (trivial representation), verify that G is in the quantum impossibility spectrum (the irreducible decomposition of H₁ contains the sign representation, which doesn't appear in H₂).

**Impact**: If true, this would provide a representation-theoretic characterization of quantum channel impossibility, connecting the classical G-set theory to quantum information theory. The multiplicity condition is computable and would yield immediate applications to quantum error correction (which symmetries can be preserved by error-correcting codes).

**Catalog References**: `Physics/EquivariantSpectra.lean` (classical impossibility spectrum), `Physics/SpectralTheory.lean` (spectral decomposition)

**Proof Strategy**:
1. Formalize equivariant quantum channels as completely positive maps commuting with the group action.
2. Use Schur's lemma to decompose the channel into blocks indexed by irreducible representations.
3. Show that the channel exists iff each block has a valid (trace-preserving, completely positive) realization.
4. Reduce block realizability to a multiplicity comparison.

**Domain Bridges**: Quantum information (channels) ↔ representation theory (Schur's lemma) ↔ impossibility spectra (algebra)

**Lineage**: Builds on this cycle's structural results, extending from classical G-sets to quantum G-representations.

**Ambition**: grand_challenge
