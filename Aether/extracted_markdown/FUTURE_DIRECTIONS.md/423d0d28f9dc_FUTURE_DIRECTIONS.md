# Future Directions: Equivariant Impossibility Spectra

## Synthesis

This research cycle established a formal algebraic framework connecting impossibility theorems through equivariant maps on group actions. The central contribution is the **impossibility spectrum** — the set of subgroups H ≤ G for which no H-equivariant map exists between two G-sets — together with its structural properties: upward closure in the subgroup lattice, fixed-point and orbit-theoretic obstructions, and a transfer principle under equivariant bijections.

The most promising cross-domain connection is between the impossibility spectrum and existing Catalog results on closure systems (`Bridges/AlgebraEMLClosureComputation.lean`) and equivariant impossibility (`Catalog/Bridges/Speculative/EquivariantImpossibility/Core.lean`). The spectrum's upward closure property makes it a filter-like object, which connects to closure operator theory. The orbit image theorem (equivariant maps send orbits exactly onto orbits) provides a concrete bridge to orbit-counting methods in combinatorics and the cardinality arguments in `Computation/InfoEfficientAlgorithms.lean`.

The direction with highest breakthrough potential is Direction 1 (Spectral Completeness), because proving that every upper set in the subgroup lattice is realizable as an impossibility spectrum would establish the spectrum as a *complete* classifying invariant, transforming impossibility theory from a collection of individual results into a systematic classification. Direction 3 (Approximate Equivariance) has strong application potential: most real-world systems satisfy symmetry only approximately, and understanding when "almost equivariant" maps exist would bridge the gap between idealized impossibility theorems and practical algorithm design.

---

### Direction 1: Spectral Completeness for Impossibility Spectra

**Conjecture**: For any finite group G and any upper set S in the subgroup lattice of G with ⊥ ∉ S, there exist finite G-sets X, Y such that the impossibility spectrum Spec(G, X, Y) = S.

Formally: given G finite, S ⊆ Sub(G) with IsUpperSet S and ⊥ ∉ S, construct X and Y as finite G-sets such that for each H ≤ G, H ∈ S iff there is no H-equivariant map X → Y.

**Test**: For G = Z/6Z (subgroups: {1}, Z/2Z, Z/3Z, Z/6Z), there are 7 upper sets not containing ⊥: ∅, {Z/6Z}, {Z/3Z, Z/6Z}, {Z/2Z, Z/6Z}, {Z/2Z, Z/3Z, Z/6Z}, {Z/3Z}, and additional combinations. For each, construct explicit G-sets X, Y and verify computationally (using GAP or SageMath) that the spectrum matches. If any upper set is unrealizable, the conjecture is false.

**Impact**: If true, this establishes the impossibility spectrum as a *complete* invariant — every conceivable pattern of impossibility across subgroups is actually achievable. This would mean impossibility theory has the same richness as the subgroup lattice itself. If false, the constraints on realizable spectra would reveal hidden structural dependencies between impossibility at different subgroup levels.

**Catalog References**: `Speculative/AutoResearch/EquivariantImpossibility/Core.lean` (spectrum_isUpperSet, bot_not_mem_spectrum_of_nonempty)

**Proof Strategy**: For each minimal element H_i of S, construct X_i = G/H_i (the coset space) with the natural G-action, and Y_i = a set with fewer orbits than X_i under H_i-action. Take X = ⊔ X_i and Y = ⊔ Y_i. The key lemma: the spectrum of a disjoint union relates to the intersection/union of individual spectra. The orbit-counting obstruction from free_action_orbit_card provides the mechanism.

**Domain Bridges**: Subgroup lattice theory (algebra) ↔ Impossibility classification (computation/economics) ↔ Equivariant topology (geometry)

**Lineage**: Builds on spectrum_isUpperSet, bot_not_mem_spectrum_of_nonempty, and free_action_orbit_card from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Categorical Impossibility Functor

**Conjecture**: The assignment (X, Y) ↦ Spec(G, X, Y) extends to a contravariant functor from the category G-Set² (pairs of G-sets with equivariant maps) to the category of upper sets in Sub(G) (with inclusion-reversing maps).

More precisely: if φ : X₁ → X₂ is G-equivariant, then Spec(G, X₂, Y) ⊆ Spec(G, X₁, Y). Dually, if ψ : Y₁ → Y₂ is G-equivariant and surjective, then Spec(G, X, Y₁) ⊆ Spec(G, X, Y₂). These functoriality properties make Spec a bifunctor, contravariant in the first argument and covariant in the second (with appropriate morphism conditions).

**Test**: Construct three G-sets X₁ ← X₂ with a G-equivariant map and a fixed target Y. Compute spectra for both and verify the inclusion Spec(G, X₂, Y) ⊆ Spec(G, X₁, Y). Use G = S₃ and concrete small G-sets for computational verification.

**Impact**: Functoriality would mean the spectrum respects the categorical structure of G-sets, enabling systematic computation via functorial methods. It would unify the transfer principle (already proved for bijections) with more general morphism conditions, and potentially connect to the Galois obstruction framework in `Algebra/GaloisObstruction.lean`.

**Catalog References**: `Speculative/AutoResearch/EquivariantImpossibility/Core.lean` (transfer_impossibility), `Algebra/GaloisObstruction.lean`

**Proof Strategy**: For contravariance in X: given equivariant φ : X₁ → X₂ and H ∈ Spec(G, X₂, Y), assume f : X₁ → Y is H-equivariant. Need to construct an H-equivariant map X₂ → Y. This requires φ to be surjective (or have a section). Identify exactly which morphism conditions on φ are needed. The transfer principle (already proved for bijections) is the special case where φ is an isomorphism.

**Domain Bridges**: Category theory (algebra) ↔ Impossibility transfer (computation) ↔ Galois theory (number theory)

**Lineage**: Direct extension of transfer_impossibility and equivariant_restrict_subgroup from this cycle.

**Ambition**: extension

---

### Direction 3: ε-Equivariance and Spectral Stability

**Conjecture**: For finite G-sets X, Y with a metric on Y, define an ε-equivariant map as f : X → Y satisfying d(f(g·x), g·f(x)) ≤ ε for all g, x. Define the ε-spectrum as the set of subgroups H with no ε-equivariant map. Then for sufficiently small ε > 0, the ε-spectrum equals the exact spectrum.

Formally: if Spec(G, X, Y) is the exact impossibility spectrum, then there exists ε₀ > 0 such that for all 0 < ε < ε₀, the ε-impossibility spectrum equals Spec(G, X, Y).

**Test**: For G = Z/2Z acting on X = {0,1} by flip and Y = {0,1,2} with trivial action, compute the exact spectrum (should be {Z/2Z} since no Z/2Z-equivariant map exists: it would need f(0) = f(1) but need surjectivity-like constraints). Then compute the ε-spectrum for decreasing ε and check convergence.

**Impact**: If true, this stability result means impossibility is not a knife-edge phenomenon — it persists under small perturbations. This bridges the gap between idealized mathematical impossibility and practical computation, where symmetry is always approximate. It connects to the spectral gap results in `Speculative/AutoResearch/BourgainGamburd/Machine.lean` (spectral_gap_from_l2_decay).

**Catalog References**: `Speculative/AutoResearch/BourgainGamburd/Machine.lean` (spectral_gap_from_l2_decay), `Bridges/GL2SpectralDecomposition.lean` (familywise_spectral_gap_of_bounds)

**Proof Strategy**: For finite sets, ε-equivariance is vacuous for large ε (take ε ≥ diam(Y)) and equivalent to exact equivariance for ε = 0. The key is showing there's a gap: either an exact equivariant map exists, or the closest map has equivariance defect bounded away from 0. Use compactness of the finite function space and continuity of the equivariance defect functional. The spectral gap connects to the spectral gap in expander graph theory via the group's Cayley graph.

**Domain Bridges**: Metric geometry ↔ Impossibility theory (algebra) ↔ Spectral graph theory (combinatorics)

**Lineage**: Extends the exact impossibility spectrum from this cycle. Connects to spectral_gap_from_l2_decay and familywise_spectral_gap_of_bounds.

**Ambition**: grand_challenge

---

### Direction 4: Product Composition of Impossibility Spectra

**Conjecture**: For G-sets X₁, X₂, Y, the impossibility spectrum of the product satisfies:
$$\text{Spec}(G, X_1 \times X_2, Y) \subseteq \text{Spec}(G, X_1, Y) \cap \text{Spec}(G, X_2, Y)$$

with equality when the G-action on Y has certain "separation" properties (e.g., distinct orbits are well-separated in a metric).

**Test**: For G = Z/3Z, construct X₁ = G (regular representation), X₂ = G (regular representation), Y = {0, 1} (trivial action). Compute Spec(G, X₁, Y), Spec(G, X₂, Y), and Spec(G, X₁ × X₂, Y). Verify the inclusion and check whether equality holds.

**Impact**: Product composition rules would enable decomposition of complex impossibility problems into simpler components. This connects to the closure-under-products property in `Bridges/AlgebraEMLClosureComputation.lean` (ClosureSemimoduleSystem). If the inclusion is strict, it reveals that product spaces can have "emergent possibilities" — maps that work on the product but not on either factor.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (ClosureSemimoduleSystem), `Speculative/AutoResearch/EquivariantImpossibility/Core.lean` (equivariant_map_orbit_image)

**Proof Strategy**: For the inclusion: if H ∉ Spec(G, X₁, Y) ∩ Spec(G, X₂, Y), then there exists an H-equivariant map from X₁ or X₂ to Y. Compose with the projection X₁ × X₂ → X_i to get an H-equivariant map from the product. But projections are equivariant, so the composition is equivariant by isEquivariantMap_comp. For the reverse inclusion, the "separation" condition on Y prevents the equivariant map from collapsing the product structure.

**Domain Bridges**: Product structures (algebra) ↔ Closure systems (combinatorics) ↔ Decomposition methods (computation)

**Lineage**: Builds on isEquivariantMap_comp and equivariant_map_orbit_image from this cycle.

**Ambition**: extension

---

### Direction 5: Impossibility Spectra for Infinite Groups and Profinite Completions

**Conjecture**: For a finitely generated group G and G-sets X, Y, the impossibility spectrum Spec(G, X, Y) is determined by the spectra of the finite quotients: H ∈ Spec(G, X, Y) if and only if the image of H in every finite quotient G/N witnesses impossibility for the induced action.

**Test**: For G = Z (the integers under addition) acting on X = Z by translation and Y = Z/nZ by the induced action, compute the impossibility spectrum. The spectrum should consist of all subgroups nZ with n ≥ 2 (or some explicit characterization). Verify by computing spectra for the finite quotients Z/mZ for increasing m and checking convergence.

**Impact**: This would extend the impossibility spectrum from finite groups to infinite groups via a profinite approximation, connecting impossibility theory to profinite group theory and number-theoretic methods. It would enable impossibility results for continuous symmetry groups (Lie groups) via their finite quotients, bridging algebra and analysis.

**Catalog References**: `Algebra/GaloisObstruction.lean`, `Speculative/AutoResearch/EquivariantImpossibility/Core.lean`

**Proof Strategy**: Use the fact that for finitely generated residually finite groups, the profinite completion Ĝ = lim G/N captures the group's finite-dimensional structure. The key lemma: an equivariant map for G exists iff equivariant maps for all finite quotients are compatible (a pro-equivariance condition). This requires a limit argument and potentially ultrafilter methods (connecting to `Logic/` results).

**Domain Bridges**: Profinite groups (number theory) ↔ Impossibility theory (computation) ↔ Inverse limits (category theory)

**Lineage**: Extends the finite group theory of this cycle to infinite groups. Connects to Galois obstruction framework.

**Ambition**: grand_challenge
