# Future Directions: Equivariant Impossibility Spectra

## Synthesis

This research cycle established a complete formal framework for the **impossibility spectrum** — the set of subgroups H ≤ G for which no H-equivariant map exists between two G-sets. We proved its fundamental structural properties: upward closure in the subgroup lattice, fixed-point and quantitative (pigeonhole) obstruction mechanisms, the transfer principle under equivariant bijections, target covariance under equivariant surjections, and the upper set structure. We introduced the **obstruction filter** as a novel algebraic structure axiomatizing these properties (upward closure + bottom exclusion + conjugation invariance).

The most promising cross-domain connection is between the obstruction filter structure and existing Catalog results on closure systems (`Bridges/AlgebraEMLClosureComputation.lean`). The complement of an impossibility spectrum — the "possibility set" — is a lower set (downward closed), dual to a closure operator's image. This connects the equivariant impossibility theory to the broader algebraic framework of closure operators and their lattice-theoretic properties. The quantitative fixed-point obstruction theorem connects to cardinality arguments in `Computation/InfoEfficientAlgorithms.lean`, suggesting that impossibility spectra could encode computational lower bounds when group actions model input symmetries.

The direction with highest breakthrough potential is **Spectral Completeness** (Direction 1). Proving that every obstruction filter is realizable as the impossibility spectrum of some pair of finite G-sets would transform the theory from a collection of individual impossibility results into a complete classification. The Burnside ring provides the natural algebraic framework for this, as the marks homomorphism translates fixed-point conditions into integer linear constraints.

---

### Direction 1: Spectral Completeness via the Burnside Ring

**Conjecture**: Every obstruction filter F on a finite group G is the impossibility spectrum of some pair (X, Y) of finite G-sets. That is, for the pair (X, Y), the set of subgroups H with no H-equivariant map X → Y is exactly F.

**Test**: Enumerate all obstruction filters on the symmetric group S₃ (which has 6 conjugacy classes of subgroups). For each filter, attempt to construct G-sets X and Y whose impossibility spectrum equals the filter. A single non-realizable filter would disprove the conjecture. Computationally verify for all groups of order ≤ 12.

**Impact**: If true, this provides a complete classification of equivariant impossibility — any pattern of "which symmetries obstruct" that satisfies the three axioms actually occurs. This would parallel Stone's representation theorem for Boolean algebras. If false, the additional constraints characterizing realizable filters would reveal new structural phenomena.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (closure systems), `Computation/InfoEfficientAlgorithms.lean` (cardinality bounds)

**Proof Strategy**: Use the marks homomorphism φ : B(G) → ∏_{(H)} ℤ of the Burnside ring. Given an obstruction filter F, we need G-sets X, Y with |X^H| > 0, |Y^H| = 0 for H ∈ F and |Y^H| > 0 for H ∉ F. This translates to a system of integer linear constraints on the marks. Key lemma: the image of the marks homomorphism is a full-rank sublattice of ∏ ℤ, characterized by divisibility conditions (tom Dieck). Feasibility of the constraint system determines realizability.

**Domain Bridges**: Burnside ring (algebra) <-> impossibility spectrum (equivariant topology) <-> integer programming (optimization)

**Lineage**: Builds on the impossibility spectrum framework (this cycle) and obstruction filter axiomatization.

**Ambition**: grand_challenge

---

### Direction 2: Approximate Equivariance and Metric Spectra

**Conjecture**: For a finite group G acting by isometries on metric spaces (X, dₓ) and (Y, d_Y), define the ε-impossibility spectrum as the set of subgroups H for which no function f : X → Y satisfies d_Y(f(h·x), h·f(x)) ≤ ε for all h ∈ H, x ∈ X. Then the ε-impossibility spectrum converges to the (exact) impossibility spectrum in the Hausdorff metric on subsets of Sub(G) as ε → 0.

**Test**: For G = Z/2 acting on the circle S¹ by reflection and on the interval [0,1] by x ↦ 1-x, compute the ε-spectrum for ε = 0.1, 0.01, 0.001. Verify that it stabilizes to the exact spectrum for small ε. Find the critical ε where the spectrum "jumps."

**Impact**: Connects the algebraic impossibility theory to practical approximate symmetry in machine learning (where equivariance is approximately satisfied). Would provide a principled framework for studying "how far from equivariant" a map must be.

**Catalog References**: `MachineLearning/EquivariantImpossibility/Core.lean` (existing equivariant impossibility result)

**Proof Strategy**: For the convergence, use compactness of the space of Lipschitz maps (Arzelà-Ascoli). The ε-equivariance condition is closed, so the limit of approximately equivariant maps is equivariant. For the "jump" phenomenon, relate to the modulus of equivariance — the infimum of sup_{h,x} d(f(h·x), h·f(x)) over all f.

**Domain Bridges**: Metric geometry <-> equivariant topology <-> machine learning (approximate equivariance)

**Lineage**: Extends impossibility spectrum to the approximate setting; builds on `MachineLearning/EquivariantImpossibility/Core.lean`.

**Ambition**: extension

---

### Direction 3: Impossibility Spectra for Infinite Groups and Profinite Completion

**Conjecture**: For a profinite group G = lim←G/N (inverse limit over open normal subgroups), the impossibility spectrum of continuous G-sets X and Y equals the union of the impossibility spectra of the finite quotient actions. Formally: ImpSpec(G, X, Y) = ⋃_N ImpSpec(G/N, X^N, Y^N) (pulled back to Sub(G)).

**Test**: Verify for the profinite integers Ẑ acting on Ẑ/nẐ for various n. The subgroup lattice of Ẑ is isomorphic to the divisibility poset of positive integers. Compute impossibility spectra for pairs (Ẑ/mẐ, Ẑ/nẐ) and verify the union formula.

**Impact**: Would extend the entire framework to infinite groups in a structurally controlled way. Opens the door to applications in number theory (Galois groups) and infinite-dimensional representation theory.

**Catalog References**: None directly; requires new infrastructure for profinite groups.

**Proof Strategy**: The forward inclusion follows from the universal property of the inverse limit. The reverse inclusion requires a compactness argument: if no continuous equivariant map exists at the profinite level, then some finite quotient already obstructs it. Use the fact that continuous maps from compact to Hausdorff spaces factor through finite quotients.

**Domain Bridges**: Profinite groups (number theory) <-> impossibility spectra (equivariant algebra) <-> inverse limits (category theory)

**Lineage**: Independent extension of the finite-group framework to the profinite setting.

**Ambition**: grand_challenge

---

### Direction 4: Orbit-Type Decomposition and Spectral Refinement

**Conjecture**: For finite G-sets, H ∈ ImpSpec(G, X, Y) if and only if there exists an H-orbit type (H/K) that appears in the H-orbit decomposition of X but not in any H-equivariant image of that orbit in Y. That is, the spectrum is fully determined by the "orbit type mismatch" between X and Y.

**Test**: For G = S₃ acting on various permutation representations, compute the orbit type decompositions and verify that the orbit type mismatch criterion exactly characterizes the impossibility spectrum. Find examples where the fixed-point obstruction is insufficient but the orbit type criterion succeeds.

**Impact**: Would give a purely combinatorial characterization of the impossibility spectrum for finite G-sets, reducing the existence question to a matching problem on orbit types. This is more refined than the fixed-point obstruction (which only uses the trivial orbit type H/H).

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (algorithmic complexity of orbit computations)

**Proof Strategy**: The forward direction uses the fact that equivariant maps preserve orbit types. For the reverse, construct an equivariant map by matching orbits of compatible type — this is a Hall-type marriage theorem argument on the poset of orbit types.

**Domain Bridges**: Combinatorics (Hall's theorem) <-> equivariant algebra (orbit types) <-> representation theory (decomposition)

**Lineage**: Refines the fixed-point obstruction mechanism from this cycle into a complete orbit-type criterion.

**Ambition**: extension

---

### Direction 5: Impossibility Spectra as Invariants of Equivariant Homotopy Type

**Conjecture**: Two pairs of G-CW-complexes (X₁, Y₁) and (X₂, Y₂) have the same impossibility spectrum if and only if they have the same system of equivariant homotopy groups π_n^H(X_i) and π_n^H(Y_i) for all n and H.

**Test**: Compute impossibility spectra for pairs of G-CW-complexes with known equivariant homotopy types. Start with G = Z/2: compare S¹ with antipodal action vs. S¹ with trivial action as sources, paired with ℝ² (trivial action) as target. Compute equivariant homotopy groups and verify the conjecture.

**Impact**: Would establish the impossibility spectrum as a complete equivariant homotopy invariant, connecting the algebraic framework to the topological one. Would subsume the Borsuk-Ulam theorem and its generalizations as special cases.

**Catalog References**: None directly; requires equivariant homotopy theory infrastructure.

**Proof Strategy**: The forward direction (same homotopy type → same spectrum) follows from the homotopy invariance of equivariant maps. The reverse direction is the hard part — it would require constructing equivariant maps or showing their nonexistence using homotopy-theoretic tools (equivariant obstruction theory, Bredon cohomology).

**Domain Bridges**: Equivariant homotopy theory <-> impossibility spectra <-> Bredon cohomology

**Lineage**: Extends the algebraic impossibility spectrum to the topological setting.

**Ambition**: grand_challenge
