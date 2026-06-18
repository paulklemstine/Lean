# Future Directions: Galois Theory of Cellular Automata

## Synthesis

This research cycle established a rigorous algebraic framework for studying reversible cellular automata through the lens of group theory. The central discovery is that the **orbit type** — the multiset of orbit sizes under the shift action — is a complete invariant for the isomorphism type of the reversibility group, via the centralizer formula |G| = ∏ d^{a_d} · a_d!. This connects three mathematical traditions: group theory (centralizers, wreath products), combinatorics (Burnside's lemma, necklace counting), and number theory (Fermat's little theorem for orbit integrality).

The most promising cross-domain connection is between the **orbit centralizer algebra** and **tropical geometry**. The orbit type decomposition parallels tropical polynomial factorization, where multiplicities correspond to orbit sizes. The reversibility index (log |G| / log |S|) behaves like a tropical valuation, and its vanishing as n → ∞ suggests a tropical analogue of the Nullstellensatz. The Catalog's existing tropical optimization and cryptographic work (e.g., `Tropical/HashInversion.lean`) could provide the foundation for formalizing this connection.

The highest breakthrough potential lies in Direction 1 (Higher-Dimensional Orbit Theory), which would extend the one-dimensional orbit type invariant to ℤ^d lattices. The combinatorics of multi-dimensional necklaces is substantially more complex and connects to unsolved problems in polyhedral combinatorics and algebraic K-theory.

---

### Direction 1: Higher-Dimensional Orbit Type Theory

**Conjecture**: For CAs on ℤ^d/nℤ^d with alphabet α, the reversibility group G(n, d, α) satisfies

log₂|G| ~ C(d) · |α|^{n^d} / n^d

where C(d) depends only on the dimension. Specifically, for d = 2 (planar CAs), the orbit structure under the ℤ² shift action gives rise to a 2-dimensional necklace counting problem whose solution involves Burnside's lemma for the group ℤ/nℤ × ℤ/nℤ, yielding orbits classified by pairs of divisors of n.

**Test**: Compute the orbit type for 2D binary CAs on (ℤ/nℤ)² for n = 2, 3, 4, 5. Verify that the centralizer order matches the predicted formula using Burnside's lemma for ℤ/nℤ × ℤ/nℤ. Check whether the reversibility index RI(n, 2) vanishes faster or slower than RI(n, 1).

**Impact**: If true, this provides the first algebraic characterization of reversible 2D CAs, which are central to lattice gauge theory and quantum error correction. If false, the failure would reveal new constraints on higher-dimensional reversibility.

**Catalog References**: `Geometry/CellularAutomataGalois.lean`, `Geometry/CellularAutomataOrbits.lean`, `Geometry/CellularAutomataAlgebra.lean`

**Proof Strategy**: Extend the OrbitCentralizerData structure to accept a group action (not just cyclic). Formalize the Burnside count for ℤ/nℤ × ℤ/nℤ acting on (ZMod n × ZMod n → Bool). The key lemma is that the centralizer of a product action factors as a product of centralizers, up to a correction term from the interaction of orbit types.

**Domain Bridges**: Geometry (orbit types) ↔ Tropical (valuation-like behavior of RI) ↔ Physics (reversibility ↔ unitarity in lattice models)

**Lineage**: Builds on the orbit type formula and centralizerOrder computation from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Reversibility Valuation

**Conjecture**: Define the *tropical reversibility valuation* ν(G) = -log|G|/log|S| for a reversibility group G ⊆ S_N. Then ν satisfies the ultrametric inequality: for reversibility groups G₁, G₂ of CAs with different periods n₁, n₂,

ν(G₁ × G₂) ≥ min(ν(G₁), ν(G₂))

This would make ν a non-Archimedean valuation on the "ring" of reversibility groups under direct product and wreath product operations.

**Test**: Compute ν for n = 1, ..., 10. Check the ultrametric inequality for all pairs (n₁, n₂) where the product group is G(n₁) × G(n₂) ⊆ S_{2^{n₁} + 2^{n₂}}.

**Impact**: If true, this establishes a tropical structure on the space of reversible CAs, opening connections to tropical algebraic geometry. If false, the failure identifies where the product/wreath decomposition breaks down.

**Catalog References**: `Tropical/HashInversion.lean`, `Geometry/CellularAutomataAlgebra.lean`

**Proof Strategy**: Use the orbit type formula to express ν in terms of orbit counts. The ultrametric inequality should follow from the multiplicativity of the centralizer order under direct products.

**Domain Bridges**: Geometry (CAs) ↔ Tropical (valuations) ↔ Cryptography (hash function reversibility)

**Lineage**: Builds on reversibilityIndex and centralizerOrder from this cycle, connects to existing tropical work.

**Ambition**: grand_challenge

---

### Direction 3: Quantum Cellular Automata and Unitary Orbits

**Conjecture**: The quantum analogue of the reversibility group — the group of shift-equivariant unitary operators on (ℂ^d)^{⊗n} — has order related to the classical centralizer order by a quantum correction factor:

|G_quantum| / |G_classical| = ∏_{d|n} |U(d)|^{a_d}

where |U(d)| is the volume of the unitary group U(d) and a_d is the classical orbit count.

**Test**: For n = 2, d = 2 (two-qubit systems), compute the dimension of the space of shift-equivariant unitaries and compare to the classical centralizer order of 4.

**Impact**: Connects reversible computation to quantum computing and establishes whether classical reversibility constraints persist in the quantum setting.

**Catalog References**: `Physics/TropicalProofThermodynamics.lean` (reversibility and entropy), `Geometry/CellularAutomataGalois.lean`

**Proof Strategy**: Model quantum CAs as equivariant unitaries on the tensor product. Use Schur's lemma to decompose the representation into irreducibles, then count the equivariant unitaries in each isotypic component.

**Domain Bridges**: Geometry (CAs) ↔ Physics (quantum information) ↔ Algebra (representation theory)

**Lineage**: Extends the classical reversibility group to the quantum setting.

**Ambition**: extension

---

### Direction 4: Automaton Groups and the Grigorchuk Connection

**Conjecture**: The reversibility group G(n, {0,1}) for n = 2^k contains the Grigorchuk group (or a quotient thereof) as a subgroup, via the natural embedding of automaton groups into the centralizer of the shift.

**Test**: For n = 4, 8, 16, check whether the reversibility group contains elements of intermediate growth (neither polynomial nor exponential). Compute the growth function of G(n, {0,1}) for small n and compare to known growth rates.

**Impact**: If true, this would connect reversible CAs to one of the most important constructions in geometric group theory — groups of intermediate growth. This would be a major cross-domain bridge.

**Catalog References**: `Geometry/CellularAutomataGalois.lean`, `Bridges/GaloisDeepLearning.lean` (Galois group structure)

**Proof Strategy**: The Grigorchuk group acts on the binary tree, which can be identified with configurations on Z/2^k Z via binary encoding. Check whether this identification preserves shift-equivariance.

**Domain Bridges**: Geometry (CAs) ↔ Algebra (geometric group theory) ↔ Computation (decidability of word problem)

**Lineage**: Builds on the reversibility subgroup structure from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Spectral Theory of the Orbit Partition

**Conjecture**: The eigenvalues of the adjacency matrix of the orbit graph (where orbits are vertices, connected if a reversible CA maps one to the other) are algebraic integers whose minimal polynomials have coefficients determined by the orbit type.

**Test**: For n = 3, 4, 5, construct the orbit graph, compute its spectrum, and check whether the eigenvalues are roots of polynomials with coefficients in ℤ[a_1, a_2, ...].

**Impact**: Would connect the combinatorial orbit structure to spectral graph theory, potentially giving new invariants for classifying CAs.

**Catalog References**: `Geometry/CellularAutomataOrbits.lean`, `EML/EMLv17Core.lean` (spectral methods)

**Proof Strategy**: The orbit graph is a Cayley-like graph for the reversibility group acting on orbits. Use the representation theory of the wreath product to decompose the adjacency matrix.

**Domain Bridges**: Geometry (orbits) ↔ EML (spectral theory) ↔ Algebra (representation theory)

**Lineage**: Builds on orbit_decomposition and equivariant_perm_preserves_orbit_card.

**Ambition**: extension
