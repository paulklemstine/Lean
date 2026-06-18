# Future Directions: Equivariant Impossibility Spectra

## Synthesis

This research cycle established a complete formal framework for the **impossibility spectrum** — the set of subgroups H ≤ G for which no H-equivariant map exists between two G-sets. We proved its fundamental structural properties: upward closure in the subgroup lattice, fixed-point and orbit-theoretic obstruction mechanisms, the transfer principle under equivariant bijections, and conjugation invariance. We introduced the **obstruction filter** as a novel algebraic structure axiomatizing these properties and showed that every impossibility spectrum (with nonempty target) is an obstruction filter.

The most promising cross-domain connection is between the obstruction filter structure and existing Catalog results on closure systems (`Bridges/AlgebraEMLClosureComputation.lean`). The upward closure property makes the impossibility spectrum dual to a closure operator's fixed-point set: while closure operators capture what *must* be included (downward closure of the complement), the impossibility spectrum captures what *cannot* be achieved (upward closure of impossibility). This duality, combined with the orbit image theorem's connection to the cardinality arguments in `Computation/InfoEfficientAlgorithms.lean`, suggests a deeper algebraic bridge between impossibility theory and computational complexity.

The direction with highest breakthrough potential is **Spectral Completeness** (Direction 1). Proving that every obstruction filter is realizable would transform the study of equivariant impossibility from case-by-case analysis into a complete classification theory. The connection to the Burnside ring makes this tractable: the marks homomorphism provides a concrete approach via integer linear programming on fixed-point counts. Direction 3 (Approximate Equivariance) has the highest application potential, as it would bridge the gap between idealized impossibility theorems and the approximate symmetries of real-world systems.

---

### Direction 1: Spectral Completeness via the Burnside Ring

**Conjecture**: For any finite group G and any obstruction filter F on G, there exist finite G-sets X, Y (with Y nonempty) such that ImpSpec(G, X, Y) = F.carrier. Moreover, X and Y can be chosen with |X| + |Y| ≤ f(|G|) for some computable function f.

**Test**: For G = ℤ/6ℤ (cyclic group of order 6), there are 4 subgroups: {e}, ℤ/2ℤ, ℤ/3ℤ, ℤ/6ℤ. Enumerate all upper sets S in this lattice with {e} ∉ S. For each S, explicitly construct finite G-sets X, Y with ImpSpec(G, X, Y) = S. If any S cannot be realized, the conjecture is false.

**Impact**: If true, this establishes a perfect dictionary between abstract filter-like objects on subgroup lattices and concrete equivariant impossibility phenomena. It would mean that the obstruction filter axioms *completely* characterize impossibility — no further axioms are needed. If false, the counterexample would reveal additional constraints on realizability, potentially leading to a richer axiomatic system.

**Catalog References**: `Bridges/EquivariantImpossibilitySpectra.lean` (ObstructionFilter, ImpossibilitySpectrum, SpectralCompletenessConjecture), `Bridges/AlgebraEMLClosureComputation.lean` (ClosureSemimoduleSystem)

**Proof Strategy**: Use the Burnside ring Ω(G). The marks homomorphism φ : Ω(G) → ∏_{(H)} ℤ sends a G-set X to the tuple (|X^H|) indexed by conjugacy classes of subgroups. The impossibility spectrum depends on the image of the mark vector of X minus some "target profile" derived from Y. The key step is showing that for any upper set S (not containing ⊥), one can choose mark vectors for X and Y such that |X^H| > 0, |Y^H| = 0 for H ∈ S, and |Y^H| > 0 for H ∉ S. This reduces to a feasibility question in the image of the marks homomorphism, which is completely characterized by congruence conditions (the Dress–Siebeneicher–Washington theory).

**Domain Bridges**: Impossibility theory ↔ Burnside ring algebra ↔ integer linear programming ↔ computational group theory

**Lineage**: Builds on ImpossibilitySpectrum, ObstructionFilter, fixedPoint_obstruction, and impossibilitySpectrum_toFilter from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Equivariant Impossibility in Categories Beyond Set

**Conjecture**: The impossibility spectrum framework extends to G-objects in any category C with a terminal object, yielding an obstruction filter on Sub(G) for pairs of G-objects (X, Y) in C. Moreover, for G-objects in the category of topological spaces (with continuous G-actions), the impossibility spectrum refines the set-theoretic spectrum — there exist pairs where a set-theoretic equivariant map exists but no continuous one does, and this difference is detected by equivariant cohomological invariants.

**Test**: For G = ℤ/2ℤ acting antipodally on S^n, compute the impossibility spectrum for (S^n, S^{n-1}) in Set versus Top. In Set, {e} and ℤ/2ℤ should both be outside the spectrum (since both spaces have elements not fixed by the antipodal map, and non-equivariant maps trivially exist). In Top (continuous maps), the Borsuk–Ulam theorem says ℤ/2ℤ is in the spectrum. This demonstrates a strict refinement.

**Impact**: Would unify classical topological impossibility theorems (Borsuk–Ulam, Lusternik–Schnirelmann) with the algebraic framework, providing a single invariant that captures both algebraic and topological obstructions.

**Catalog References**: `Bridges/EquivariantImpossibilitySpectra.lean` (ImpossibilitySpectrum, equivariant_orbit_image_eq)

**Proof Strategy**: Define `CategoricalImpSpec(C, G, X, Y)` for G-objects in a category C. The key challenge is formalizing "G-object in C" — this requires the category of functors from the one-object category BG to C. The upward closure theorem generalizes immediately (it's purely algebraic). For the topological case, use the equivariant Dold theorem or the degree-based proof of Borsuk–Ulam to show ℤ/2ℤ ∈ ImpSpec_{Top}(S^n, S^{n-1}).

**Domain Bridges**: Equivariant algebra ↔ equivariant topology ↔ category theory ↔ cohomology theory

**Lineage**: Builds on impossibilitySpectrum_upward_closed, equivariant_orbit_image_eq from this cycle; connects to the Borsuk–Ulam theorem.

**Ambition**: grand_challenge

---

### Direction 3: Approximate Equivariance and Stability of the Impossibility Spectrum

**Conjecture**: For a finite group G acting by isometries on compact metric G-spaces (X, d_X) and (Y, d_Y), define the **ε-impossibility spectrum** as {H ≤ G : there is no map f : X → Y with sup_{x, h} d_Y(f(h·x), h·f(x)) ≤ ε}. Then: (a) ImpSpec_0 = ImpSpec (the exact spectrum); (b) ImpSpec_ε is upward closed for each ε ≥ 0; (c) there exists a critical threshold ε*(H) for each subgroup H such that H ∈ ImpSpec_ε iff ε < ε*(H); and (d) ε*(H) ≤ ε*(K) whenever K ≤ H.

**Test**: For G = ℤ/2ℤ acting on the circle S^1 by the antipodal map, and Y = {point}, compute ε*(ℤ/2ℤ). The unique equivariant map would need f(-x) = -f(x) = -pt = pt = f(x), so f must be constant, which is equivariant. Thus ℤ/2ℤ ∉ ImpSpec and ε* = 0. Now take X = S^1, Y = interval [-1,1] with trivial ℤ/2ℤ-action. Any map f has defect sup d(f(-x), f(x)), and the minimum over all f gives ε*. Verify computationally.

**Impact**: Most real-world systems satisfy symmetry only approximately. Understanding the stability of impossibility under perturbation would provide practical engineering bounds: "how asymmetric must your solution be?" This connects to robust optimization and algorithmic fairness.

**Catalog References**: `Bridges/EquivariantImpossibilitySpectra.lean` (ImpossibilitySpectrum, impossibilitySpectrum_upward_closed), `Bridges/LorentzianConditionNumber.lean` (spectral_gap_preserved_under_small_operator_perturbation)

**Proof Strategy**: For (a)-(b), adapt the exact proofs using metric approximation arguments. For (c), use compactness of X to show the defect function is continuous, hence achieves its minimum, giving a well-defined ε*. For (d), use that K-equivariance is weaker than H-equivariance (fewer constraints to satisfy approximately), so the infimal defect can only decrease.

**Domain Bridges**: Equivariant impossibility ↔ metric geometry ↔ robust optimization ↔ algorithmic fairness

**Lineage**: Builds on impossibilitySpectrum_upward_closed, isSubgroupEquivariant_of_le from this cycle; connects to spectral_gap_preserved_under_small_operator_perturbation.

**Ambition**: extension

---

### Direction 4: Impossibility Spectra and Information-Theoretic Lower Bounds

**Conjecture**: For a finite group G acting on a finite set X of "inputs" and a finite set Y of "outputs", if H ∈ ImpSpec(G, X, Y), then any algorithm computing an H-equivariant function f : X → Y (if it existed) would require at least log₂(|H|/|Stab_H(x)|) bits of information about x beyond its H-orbit. This connects the impossibility spectrum to information-theoretic lower bounds on computation.

**Test**: For G = S_n acting on n-element sets X = Y = {1,...,n} by permutation, the identity function is G-equivariant, so G ∉ ImpSpec. But for Y = {1,...,n-1} (one fewer output), G ∈ ImpSpec because equivariant maps must preserve orbit structure and the single orbit of X cannot map equivariantly to Y. Verify the information-theoretic bound: log₂(n!/1) = log₂(n!) bits.

**Impact**: Would provide a new proof technique for computational lower bounds via symmetry analysis, connecting impossibility spectra to the information-efficient algorithm framework in the Catalog.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm, BSState), `Bridges/EquivariantImpossibilitySpectra.lean` (ImpossibilitySpectrum, fixedPoint_obstruction)

**Proof Strategy**: Model computation as a sequence of queries that each reveal one bit about the input's position within its orbit. The equivariance constraint forces the algorithm's behavior to be determined by the orbit data alone. If H ∈ ImpSpec, no amount of orbit information suffices, but for H ∉ ImpSpec, bound the number of bits needed by the logarithm of the orbit size ratio.

**Domain Bridges**: Impossibility theory ↔ information theory ↔ computational complexity ↔ algorithmic design

**Lineage**: Builds on ImpossibilitySpectrum and orbit theory from this cycle; extends InfoEfficientAlgorithm framework.

**Ambition**: extension

---

### Direction 5: Tropical Impossibility Spectra

**Conjecture**: The impossibility spectrum framework admits a tropical analogue. Replace G-sets with tropical G-semimodules (semimodules over the tropical semiring 𝕋 = (ℝ ∪ {-∞}, max, +) equipped with a G-action compatible with the tropical structure). Define the **tropical impossibility spectrum** as the set of subgroups for which no tropically linear equivariant map exists. Then: (a) the tropical spectrum is upward closed; (b) it strictly refines the set-theoretic spectrum (there exist pairs where a set-theoretic equivariant map exists but no tropical one does); (c) the tropical spectrum encodes valuative data about the original impossibility.

**Test**: For G = ℤ/2ℤ and 𝕋² with the swap action (g · (a,b) = (b,a)), compute the tropical impossibility spectrum for (𝕋², 𝕋¹) where 𝕋¹ has trivial action. A tropically linear equivariant map f : 𝕋² → 𝕋¹ must satisfy f(b,a) = f(a,b) and f(max(a,c), max(b,d)) = max(f(a,b), f(c,d)). Check if f(a,b) = max(a,b) works (it does — this is equivariant and tropically linear). So ℤ/2ℤ ∉ tropical ImpSpec for this pair.

**Impact**: Would connect impossibility theory to tropical geometry and the rapidly growing field of tropical combinatorics, potentially providing new tools for understanding classical impossibility through the "tropicalization" functor.

**Catalog References**: `Bridges/EquivariantImpossibilitySpectra.lean` (ImpossibilitySpectrum), `Tropical/` (tropical semiring infrastructure if available)

**Proof Strategy**: Define tropical G-semimodules using Mathlib's tropical semiring type. Adapt the upward closure proof (it's purely algebraic and doesn't depend on the Set category). For the refinement result, construct an explicit example where set-theoretic equivariant maps exist but tropical ones don't — this likely requires a pair where the tropical linearity constraint creates a strict additional obstruction.

**Domain Bridges**: Equivariant impossibility ↔ tropical geometry ↔ valuation theory ↔ combinatorial optimization

**Lineage**: Builds on impossibilitySpectrum_upward_closed from this cycle; connects to tropical semiring theory.

**Ambition**: extension
