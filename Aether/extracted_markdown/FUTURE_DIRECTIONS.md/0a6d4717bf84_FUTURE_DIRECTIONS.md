# Future Directions: Social Choice as Topology

## Synthesis

This research cycle established the **PreferenceSphere** as a formal bridge between discrete social choice theory (Arrow's impossibility) and continuous topology (Borsuk-Ulam). We proved 14 theorems about this structure in Lean 4, covering the antipodal involution, Kendall and Cayley metrics, decisive coalitions, and the connection to dictatorship. The single remaining sorry — Arrow's full impossibility theorem — is blocked by the difficulty of constructing permutations with specific pairwise properties in Lean 4, a challenge that future work on "profile construction lemmas" could unlock.

The most promising cross-domain connection is between the **Kendall tau metric on the PreferenceSphere** and **tropical geometry**. The Kendall distance has a natural interpretation as a tropical polynomial evaluation, and the decisive coalition structure parallels the cell decomposition of tropical varieties. The Catalog's existing work on tropical optimization (`Tropical/`) and operadic tropicalization (`Bridges/OperadicTropicalization.lean`) provides ready-made infrastructure for this bridge.

The direction with highest breakthrough potential is **Direction 1** (Tropical Arrow), which would unify three domains: social choice, topology, and tropical geometry. If the Kendall metric can be shown to arise naturally from a tropical semiring structure on the permutohedron, this would provide a completely new proof of Arrow's theorem using tropical methods — a genuinely novel contribution.

---

### Direction 1: Tropical Arrow's Theorem

**Conjecture**: The Kendall tau distance on the PreferenceSphere has a natural tropical (min-plus) semiring structure, and Arrow's impossibility theorem can be derived as a consequence of the non-existence of tropical linear maps on the permutohedron that are both Pareto-compatible and non-degenerate.

**Test**: Define the tropical permutohedron as the tropical convex hull of all n! rankings (viewed as vectors in ℝⁿ under the Kendall embedding). Check whether the decisive coalition structure corresponds to the face lattice of this tropical polytope. Specifically: compute the face lattice for n=3 (the tropical hexagon) and verify that its maximal chains correspond to dictatorial SWFs.

**Impact**: If true, this provides an entirely new proof of Arrow's theorem using tropical geometry — connecting social choice to algebraic geometry. It would also give a quantitative "tropical degree" measuring how close a SWF is to being dictatorial. If false, it would reveal that the tropical structure is insufficient to capture the full force of IIA, which itself would be informative about the limits of tropical methods.

**Catalog References**: `Bridges/OperadicTropicalization.lean` (tropical_profile_complete_for_bounded_architecture_congruence), `Tropical/` directory, `Applications/SocialChoiceTopology.lean` (PreferenceSphere, kendall_antipodal_maximal)

**Proof Strategy**: 
1. Define the tropical permutohedron Trop(Perm(n)) as the image of the Kendall embedding into tropical ℝⁿ
2. Show that the face lattice of Trop(Perm(n)) is isomorphic to the partition lattice
3. Define "tropical social welfare function" as a tropical-linear map on Trop(Perm(n))^m → Trop(Perm(n))
4. Show Pareto = tropical non-negativity, IIA = tropical linearity
5. Derive Arrow's theorem from the tropical Farkas lemma

**Domain Bridges**: Social Choice Theory <-> Tropical Geometry <-> Combinatorial Topology

**Lineage**: Builds on this cycle's PreferenceSphere and the Catalog's tropical infrastructure.

**Ambition**: grand_challenge

---

### Direction 2: Complete Lean Formalization of Arrow's Theorem

**Conjecture**: Arrow's impossibility theorem can be fully formalized in Lean 4 using the decisive coalition approach, with the key bottleneck being a "profile construction lemma" that, given n ≥ 3 distinct alternatives and a desired set of pairwise comparisons, constructs an Equiv.Perm (Fin n) realizing those comparisons.

**Test**: Prove the profile construction lemma: for any three distinct alternatives a, b, c ∈ Fin n (with n ≥ 3) and any desired strict ordering among them (e.g., a > b > c), there exists σ : Equiv.Perm (Fin n) with σ(a) < σ(b) < σ(c). Then use this lemma to prove the Field Expansion Lemma, which states that if a coalition S is semi-decisive for one pair (a,b), then S is decisive for ALL pairs.

**Impact**: A complete Lean 4 formalization of Arrow's theorem would be a significant contribution to the formal verification literature. Previous formalizations exist in Coq (Sozeau, 2009) and Mizar, but no complete Lean 4 version exists. Success would also validate our PreferenceSphere framework as the right abstraction level.

**Catalog References**: `Applications/SocialChoiceTopology.lean` (all definitions and partial results from this cycle)

**Proof Strategy**:
1. Prove the profile construction lemma using Equiv.swap compositions
2. Prove Field Expansion: SemiDecisive F S a b → Decisive F S (using profile construction + IIA + Pareto + transitivity)
3. Prove Ultrafilter Property: for any S, either S or Sᶜ is decisive
4. Prove Intersection Property: D₁ ∩ D₂ is decisive if D₁ and D₂ are
5. Conclude: minimal decisive set is a singleton = dictator

**Domain Bridges**: Formal Verification <-> Social Choice Theory <-> Algebra (ultrafilter theory)

**Lineage**: Direct continuation of this cycle's partial formalization.

**Ambition**: extension

---

### Direction 3: Gibbard-Satterthwaite via the PreferenceSphere

**Conjecture**: The Gibbard-Satterthwaite theorem (every non-dictatorial voting rule with ≥ 3 alternatives is manipulable) can be derived from Arrow's theorem via the PreferenceSphere, using the fact that strategy-proofness on the PreferenceSphere corresponds to a fixed-point property of the antipodal map.

**Test**: Define strategy-proofness as a condition on social choice functions (not SWFs) on the PreferenceSphere. Show that a strategy-proof SCF induces a SWF satisfying Pareto + IIA, then apply Arrow's theorem. The key step: show that the "manipulation" direction in preference space corresponds to moving toward or away from the antipodal point on the PreferenceSphere.

**Impact**: If true, this would unify Arrow and Gibbard-Satterthwaite under a single topological framework. The PreferenceSphere would serve as the universal object for impossibility theorems in social choice theory. If false, it would reveal a fundamental distinction between ordinal (Arrow) and strategic (G-S) impossibilities.

**Catalog References**: `Applications/SocialChoiceTopology.lean`, `Bridges/Pareto.lean` (exists_two_pareto_points)

**Proof Strategy**:
1. Define Social Choice Function (SCF) on PreferenceSphere: maps profiles to a single alternative
2. Define strategy-proofness: no voter can improve their outcome by misreporting
3. Show strategy-proof + onto + ≥ 3 alternatives → the SCF extends to a SWF satisfying IIA
4. Apply Arrow's theorem to conclude dictatorship

**Domain Bridges**: Game Theory <-> Social Choice <-> Topology

**Lineage**: Builds on this cycle's PreferenceSphere and Arrow formalization.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Theory of the Preference Graph

**Conjecture**: The eigenvalues of the adjacency matrix of the PreferenceSphere graph (where rankings are adjacent if they differ by a single adjacent transposition — the permutohedron graph) encode information about the "fairness" of social welfare functions: specifically, a SWF satisfying Pareto + IIA must have its "spectral projection" concentrated on the eigenspace corresponding to the largest eigenvalue.

**Test**: For n = 3 (6 vertices, hexagonal graph), compute the full spectrum of the adjacency matrix. For each Pareto + IIA SWF (there are exactly 2, the dictatorships), compute the spectral decomposition and verify the concentration property. For n = 4 (24 vertices), repeat computationally.

**Impact**: This would connect social choice theory to spectral graph theory, potentially providing quantitative bounds on "how close to dictatorial" a SWF must be. The spectral gap of the permutohedron graph is well-studied in combinatorics; connecting it to Arrow's theorem would be novel.

**Catalog References**: `Applications/SocialChoiceTopology.lean` (IsAdjacentTransposition, cayleyDist)

**Proof Strategy**:
1. Compute the spectrum of the permutohedron graph using representation theory of Sₙ
2. Define the "spectral projection" of a SWF as its Fourier decomposition on the permutohedron
3. Show Pareto constrains certain Fourier coefficients
4. Show IIA forces the projection to be rank-1 (=dictatorship)

**Domain Bridges**: Spectral Graph Theory <-> Social Choice <-> Representation Theory

**Lineage**: Builds on this cycle's PreferenceSphere graph structure.

**Ambition**: extension

---

### Direction 5: Persistent Homology of Preference Spaces

**Conjecture**: The persistent homology of the PreferenceSphere (filtered by Kendall distance) has a single persistent generator in dimension (n−2) that "dies" at the maximal filtration level n(n−1)/2. This generator corresponds to the topological obstruction captured by Arrow's theorem, and its persistence (= birth-death interval length) equals the "impossibility strength" of the social choice constraints.

**Test**: Compute the persistent homology of PS(3) (6 points, Kendall distance) and PS(4) (24 points). Check whether there is exactly one persistent (n−2)-dimensional cycle. For PS(3): expect a persistent 1-cycle (the hexagon). For PS(4): expect a persistent 2-cycle in the truncated octahedron.

**Impact**: If true, this would provide a completely new characterization of Arrow's theorem in terms of persistent homology — a key tool in topological data analysis (TDA). This would mean TDA methods could detect "impossibility-type" constraints in real-world voting data.

**Catalog References**: `Applications/SocialChoiceTopology.lean`, `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean` (barcode_satisfies_axioms)

**Proof Strategy**:
1. Construct the Vietoris-Rips filtration of PS(n) under Kendall distance
2. Compute persistent homology using the standard algorithm
3. Identify the persistent generator in dimension (n−2)
4. Show its persistence interval equals [0, n(n−1)/2]
5. Connect the generator to the fundamental class of the permutohedron as a (n−2)-manifold

**Domain Bridges**: Topological Data Analysis <-> Social Choice <-> Algebraic Topology

**Lineage**: Builds on this cycle's Kendall metric results and the Catalog's persistence work.

**Ambition**: grand_challenge
