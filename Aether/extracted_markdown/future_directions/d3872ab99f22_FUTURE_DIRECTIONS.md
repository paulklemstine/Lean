# Future Directions: Equivariant Impossibility Spectra

## Synthesis

This research cycle established the formal algebraic framework of **impossibility spectra** — the set of subgroups H ≤ G for which no H-equivariant map exists between two G-sets X and Y. We proved the core structural theorems: upward closure in the subgroup lattice, fixed-point and orbit obstructions, stabilizer monotonicity, conjugation invariance, and the transfer principle for isomorphic G-sets. We also introduced the equivariance defect as a quantitative measure of symmetry breaking and proved its basic properties.

The most promising cross-domain connections emerge from three observations. First, the upward closure property makes the impossibility spectrum a **filter-like object** in the subgroup lattice, connecting to the theory of closure systems developed in `Bridges/AlgebraEMLClosureComputation.lean`. An impossibility spectrum is an upper set, and the collection of all possible spectra for a fixed group G forms a lattice under inclusion — this lattice structure is itself an invariant of G worth studying. Second, the orbit-counting obstructions connect directly to Burnside-type arguments and the cardinality-based reasoning in `Computation/InfoEfficientAlgorithms.lean`. Third, the equivariance defect bridges to the spectral gap concepts in `Physics/SpectralGap.lean` and `Physics/CharacterExpansionMassGap.lean` — the minimum defect over all maps when the spectrum is nonempty is a kind of "equivariant spectral gap."

The direction with highest breakthrough potential is **Spectral Completeness** (Direction 1): proving that every upper set in the subgroup lattice (not containing ⊥) arises as the impossibility spectrum of some pair of G-sets would transform the spectrum from a useful tool into a complete classification. The construction likely requires building G-sets with carefully controlled orbit and fixed-point structures, which connects to the combinatorics of group actions that appears throughout the Catalog.

---

### Direction 1: Spectral Completeness Theorem

**Conjecture**: For any finite group G and any upper set S in the subgroup lattice Sub(G) with ⊥ ∉ S, there exist finite G-sets X and Y such that Σ(X, Y) = S.

**Test**: Verify computationally for all groups G with |G| ≤ 12. For each G, enumerate all upper sets in Sub(G), and for each upper set S, attempt to construct G-sets X, Y with Σ(X, Y) = S. A single non-realizable upper set would disprove the conjecture.

**Impact**: If true, this establishes the impossibility spectrum as a *complete* invariant — every algebraically possible pattern of equivariant obstruction is geometrically realized. This would be analogous to the Eilenberg-Steenrod axioms characterizing homology: the spectrum wouldn't just detect impossibility, it would *classify* it. If false, the characterization of which upper sets are realizable would itself be a deep structural result.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (closure systems), `Bridges/EquivariantSpectrum/Core.lean` (upward closure theorem)

**Proof Strategy**: For each subgroup H in the complement of S (i.e., H ∉ S), construct a G-set X_H where H acts with a fixed point but every K ∈ S acts freely. The product ∏ X_H serves as the source. The target Y must be chosen so that its fixed-point structure exactly matches the complement of S. The key technical lemma: for each pair (H, K) with H ∉ S and K ∈ S, there exists a G-set where H has a fixed point but K acts freely. This requires careful use of induced representations and the transitive G-sets G/H.

**Domain Bridges**: Group action combinatorics ↔ Closure operator theory ↔ Topological obstruction theory

**Lineage**: Builds on the upward closure theorem and fixed-point obstruction from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Representation-Theoretic Spectrum

**Conjecture**: For a finite group G and finite-dimensional complex representations V, W, the impossibility spectrum Σ_lin(V, W) (subgroups H for which no H-equivariant *linear* map V → W exists) equals the set of subgroups H such that Hom_H(V, W) = 0, i.e., V and W share no irreducible H-representation in common.

**Test**: Compute Σ_lin(V, W) for all irreducible representations of S_4 and compare with the Schur orthogonality predictions. The representations of S_4 are well-tabulated and small enough for exhaustive verification.

**Impact**: This connects the impossibility spectrum to classical representation theory, giving a complete characterization in the linear case via character theory. It would provide efficient (polynomial-time) algorithms for computing the linear impossibility spectrum, in contrast to the exponential-time brute-force algorithm for the general (set-theoretic) case.

**Catalog References**: `Bridges/EquivariantSpectrum/Core.lean`, `Bridges/EquivariantSpectrum/Obstructions.lean`

**Proof Strategy**: The forward direction follows from Schur's lemma: if V and W share no irreducible H-representation, then Hom_H(V, W) = 0 by semisimplicity. The reverse requires showing that a nonzero H-equivariant linear map always exists when V and W share an irreducible component, which follows from the projection formula in representation theory. Formalize Maschke's theorem and the decomposition of Hom spaces in Lean.

**Domain Bridges**: Representation theory ↔ Equivariant impossibility ↔ Harmonic analysis on groups

**Lineage**: Extends the set-theoretic spectrum to the linear category.

**Ambition**: extension

---

### Direction 3: Approximate Equivariance and Spectral Gaps

**Conjecture**: For a finite group G acting isometrically on a compact metric space X and a finite metric space Y, if H ∈ Σ(X, Y), then the infimum of the equivariance defect δ_H(f) = sup_{x} sup_{h ∈ H} d(f(h·x), h·f(x)) over all continuous f : X → Y is bounded below by a positive constant depending only on the group action structure (orbit sizes and stabilizer indices), not on the metric.

**Test**: Compute the infimum numerically for Z/n acting by rotation on the unit circle in R² and Y = {±1} with trivial action, for n = 2, 3, 4, 5. If the infimum scales as 1/n, the conjecture about metric-independence is false. If it stays bounded away from 0, that supports metric-independence.

**Impact**: A positive spectral gap for the equivariance defect would mean that approximate equivariance has a quantitative cost — you can't be "almost equivariant" in an impossible situation. This bridges impossibility theory to the quantitative world of approximation algorithms and would have applications in equivariant machine learning (bounding the error of approximately equivariant networks).

**Catalog References**: `Physics/SpectralGap.lean` (spectral gap persistence), `Physics/CharacterExpansionMassGap.lean` (spectral gaps from character theory), `Bridges/EquivariantSpectrum/Obstructions.lean` (equivariance defect)

**Proof Strategy**: Use the compactness of X and continuity of f to extract a convergent subsequence from any minimizing sequence. The limit function f* achieves the infimum. If δ_H(f*) = 0, then f* is H-equivariant, contradicting H ∈ Σ. The bound in terms of orbit structure likely comes from an averaging argument: the defect at a point x propagates through the H-orbit of x, creating a system of constraints whose incompatibility has a quantifiable cost.

**Domain Bridges**: Equivariant impossibility ↔ Spectral gap theory ↔ Approximation theory ↔ Equivariant neural networks

**Lineage**: Extends the equivariance defect from this cycle to a gap theorem.

**Ambition**: grand_challenge

---

### Direction 4: Impossibility Spectra for Infinite Groups

**Conjecture**: For a compact Lie group G acting smoothly on smooth manifolds X and Y, the smooth impossibility spectrum (subgroups H for which no smooth H-equivariant map exists) coincides with the continuous impossibility spectrum (subgroups for which no continuous equivariant map exists) when X is compact.

**Test**: Verify for G = SO(3) acting on S² and Y = R¹ with trivial action. The continuous spectrum should include all of SO(3) (since any continuous function on S² has a critical point, and SO(3)-equivariance forces constancy by transitivity). Check whether the smooth spectrum matches.

**Impact**: If smooth and continuous spectra coincide for compact group actions, it provides a powerful bridge between algebraic topology (which detects continuous obstructions) and differential geometry (where smooth equivariance is the natural condition). This would justify using topological methods (equivariant cohomology, Borel construction) for smooth impossibility problems.

**Catalog References**: `Bridges/EquivariantSpectrum/Core.lean`, `Physics/SpectralTheory.lean`

**Proof Strategy**: The continuous → smooth direction requires an equivariant smoothing theorem (e.g., equivariant approximation on compact G-manifolds). The smooth → continuous direction is trivial (smooth maps are continuous). The key technical tool is the slice theorem for compact group actions, which reduces the problem to linear actions on tangent spaces, where Direction 2's representation-theoretic methods apply.

**Domain Bridges**: Smooth manifold theory ↔ Equivariant algebraic topology ↔ Impossibility spectra

**Lineage**: Generalizes the finite group framework to Lie groups.

**Ambition**: extension

---

### Direction 5: Categorical Spectrum and Functoriality

**Conjecture**: The assignment (X, Y) ↦ Σ(X, Y) extends to a contravariant-covariant bifunctor from the category of G-sets to the category of upper sets in Sub(G), and this functor preserves finite limits in the first argument and finite colimits in the second.

**Test**: Verify the functor properties for G = Z/2 × Z/2 (Klein four-group), which has a rich subgroup lattice (5 subgroups) but small enough for exhaustive computation. Check that Σ(X₁ × X₂, Y) = Σ(X₁, Y) ∩ Σ(X₂, Y) (product in source gives intersection of spectra).

**Impact**: Establishing functoriality would unlock powerful categorical tools: exact sequences of spectra, spectral sequences (in the homological algebra sense), and Kan extension-based universal properties. It would connect the impossibility spectrum to equivariant K-theory and equivariant stable homotopy theory.

**Catalog References**: `Bridges/EquivariantSpectrum/Core.lean` (transfer principle, monotonicity)

**Proof Strategy**: Contravariance in X uses composition: if φ: X' → X is equivariant and H ∈ Σ(X, Y), then H ∈ Σ(X', Y) (any equivariant f: X' → Y composed with φ⁻¹ would give f: X → Y). Covariance in Y uses composition in the other direction. The limit/colimit preservation requires checking universal properties directly. The product formula Σ(X₁ × X₂, Y) = Σ(X₁, Y) ∩ Σ(X₂, Y) follows from the observation that projection X₁ × X₂ → X₁ is equivariant, so an equivariant map X₁ → Y lifts to X₁ × X₂ → Y.

**Domain Bridges**: Category theory ↔ Equivariant homotopy theory ↔ Impossibility spectra ↔ K-theory

**Lineage**: Extends the transfer principle and monotonicity results from this cycle to a full categorical framework.

**Ambition**: extension
