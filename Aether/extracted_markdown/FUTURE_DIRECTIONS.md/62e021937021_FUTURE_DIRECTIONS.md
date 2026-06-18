# Future Research Directions

## Synthesis

This research cycle established a rigorous foundation for isogeny-based cryptographic security by proving the random self-reducibility of GAIP, the complete connector transport algebra, t-special soundness for CSI-FiSh, and the forgery-to-GAIP reduction. The most promising cross-domain connection emerges between **tropical cryptography** (existing in the Catalog as `TropicalMinPlusCrypto.lean`, `TropicalCryptoPrimitives.lean`) and **isogeny-based cryptography**: both involve group actions on algebraic structures where the hardness of inverting the action is the security foundation. The tropical semiring (min, +) action shares the same abstract framework as the class group action, suggesting that security reductions might transfer between settings.

The subgroup orbit decomposition result connects to the **Berggren tree** work (e.g., `BerggrenGroupoidOrbit.lean`, `BerggrenDiophantineLattice.lean`) through the common theme of group orbits on structured sets. The Berggren matrices generate a free monoid acting on Pythagorean triples — a non-commutative analog of the class group action — and understanding the orbit structure in both settings could reveal universal patterns in cryptographic group actions.

The highest breakthrough potential lies in Direction 1 (Decisional CSIDH), as proving a formal separation between computational and decisional variants would have immediate impact on the security analysis of real-world isogeny-based protocols. Direction 2 (Tropical-Isogeny Bridge) offers the most novel cross-domain connection, potentially unifying two separate branches of post-quantum cryptography under a common algebraic framework.

---

### Direction 1: Decisional CSIDH Hardness from Computational GAIP

**Conjecture**: In any free transitive abelian group action (G, X) with |G| = n, if GAIP is hard (no polynomial-time algorithm solves connector(x₀, y) for random y), then the Decisional CSIDH Problem is also hard: no efficient distinguisher can tell apart (g·x₀, h·x₀, (gh)·x₀) from (g·x₀, h·x₀, r·x₀) for random g, h, r ∈ G.

**Test**: Formalize the decisional-to-computational reduction. As a concrete test: for Z/pZ with p prime, implement a distinguisher and verify it fails (has advantage ≤ 1/p) on random instances for p ∈ {101, 1009, 10007}.

**Impact**: This would establish the full chain of CSIDH security reductions: GAIP hardness → OWF → key indistinguishability → CPA security. Currently, the decisional variant is assumed separately in the literature; a formal reduction would strengthen the security foundation.

**Catalog References**: `Catalog/Cryptography/CSIFiShDeep.lean` (DecisionalCSIDH structure), `Catalog/Cryptography/CSIFiSh.lean` (FreeTrans, GAIP)

**Proof Strategy**: Use the random self-reducibility of GAIP (proved in this cycle) to show that any decisional distinguisher can be converted to a computational GAIP solver. The key insight is that in a free transitive action, the joint distribution of (g·x₀, h·x₀, (gh)·x₀) can be rerandomized to any other triple, so a distinguisher working on random instances works on all instances.

**Domain Bridges**: Isogeny Cryptography <-> Computational Complexity (average-case hardness)

**Lineage**: Builds on `rerandomization_preserves_solution` and `worst_case_average_case` from this cycle's `CSIFiShIsogeny.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical-Isogeny Unification via Abstract Group Actions

**Conjecture**: The one-way function structure of tropical min-plus matrix multiplication (as formalized in `TropicalMinPlusCrypto.lean`) and the CSIDH one-way function are instances of a common abstract framework — a "Cryptographic Group Action" with specific hardness properties — and security reductions in one setting transfer to the other via this abstraction.

**Test**: Define an abstract `CryptoHardAction` structure that subsumes both the CSIDH `FreeTrans` and the tropical action. Prove that the `tropMV_one_sided_bound` theorem from `TropicalMinPlusCrypto.lean` can be restated as a property of the abstract action, and verify that the random self-reducibility proof carries over.

**Impact**: If successful, this would create a unified theory of post-quantum cryptographic group actions, allowing results from isogeny-based cryptography to inform tropical cryptography and vice versa. This could reveal new attacks or new hardness results in both settings.

**Catalog References**: `Catalog/Cryptography/TropicalMinPlusCrypto.lean` (`tropMV_one_sided_bound`), `Catalog/Cryptography/TropicalCryptoPrimitives.lean`, `Cryptography/CSIFiShIsogeny.lean` (this cycle)

**Proof Strategy**: Start with the `CryptoGroupAction` structure from `CSIFiShIsogeny.lean`. Add a "hardness amplification" axiom that captures the essential property shared by both tropical and isogeny settings. Then prove that the rerandomization lemma holds in this generalized setting. The tropical case will require showing that min-plus matrix multiplication acts on a set of vectors in a way that preserves the one-sided bound.

**Domain Bridges**: Isogeny Cryptography <-> Tropical Algebra <-> Complexity Theory

**Lineage**: Builds on `tropMV_one_sided_bound` from `TropicalMinPlusCrypto.lean` and `rerandomization_preserves_solution` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Cayley Graph Expansion and Mixing Time

**Conjecture**: For the Cayley graph of the class group action with generators {l₁, l₁⁻¹, ..., lₙ, lₙ⁻¹} (the small prime ideals and their inverses), the spectral gap is at least c/n for some absolute constant c > 0. Equivalently, the mixing time of a random walk on the isogeny graph is O(n · log(h)) where h is the class number.

**Test**: For Z/pZ with generators {1, -1} (n=1 case), compute the spectral gap exactly: it is 2 - 2cos(2π/p) ≈ 4π²/p². Verify this for p ∈ {5, 7, 11, 13, 17, 23, 29, 37, 41, 97}. For the multi-generator case, simulate random walks and measure the total variation distance to uniformity.

**Impact**: A formal bound on the mixing time would have direct cryptographic applications: it determines how quickly CSIDH key distributions converge to uniform, affecting the security of protocols that rely on key uniformity.

**Catalog References**: `Cryptography/CSIFiShIsogeny.lean` (`IsogenyGraph`, `regular_of_free`), `Catalog/Cryptography/CSIFiShAdvanced.lean` (CayleyGraph)

**Proof Strategy**: For the single-generator case (Z/nZ), the eigenvalues of the adjacency matrix are 2cos(2πk/n) for k = 0, ..., n-1. The spectral gap is 2 - 2cos(2π/n). Formalize this using Mathlib's `Matrix.eigenvalues` or direct computation. For the multi-generator case, use the fact that the spectral gap of a product graph is the minimum of the individual spectral gaps.

**Domain Bridges**: Graph Theory <-> Number Theory <-> Cryptography

**Lineage**: Builds on `cayleyDiameterConj` and `IsogenyGraph.regular_of_free` from this cycle.

**Ambition**: extension

---

### Direction 4: Subgroup Orbit Partition and CSIDH Parameter Security

**Conjecture**: For the CSIDH class group action, if the secret key exponents are restricted to a subgroup H ≤ Cl(𝒪) of index [Cl(𝒪):H] = m, then the public key distribution concentrates on a single H-orbit of size |H|, and the security level drops from log₂(h) to log₂(|H|) = log₂(h/m) bits.

**Test**: For Z/105Z ≅ Z/3Z × Z/5Z × Z/7Z, compute the orbits of the subgroup H = Z/3Z × {0} × {0} (|H| = 3). Verify that there are exactly 105/3 = 35 distinct orbits, each of size 3. Check that restricting keys to H reduces the effective key space from 105 to 3.

**Impact**: This directly addresses CSIDH parameter security: choosing small exponent bounds restricts the effective key space to a subgroup, and understanding the orbit structure quantifies the security loss. This analysis is crucial for CSIDH-512 and CSIDH-1024 parameter sets.

**Catalog References**: `Cryptography/CSIFiShIsogeny.lean` (`subgroupOrbit_card`, `mem_subgroupOrbit_iff`), `Catalog/Cryptography/CSIFiShAdvanced.lean` (key space analysis)

**Proof Strategy**: Use the `subgroupOrbit_card` theorem (proved this cycle) to establish that each H-orbit has exactly |H| elements. Then prove that distinct H-orbits are disjoint (using the orbit equivalence lemma), yielding a partition of X into |X|/|H| = |G|/|H| = [G:H] orbits. The security reduction follows from the fact that the public key reveals which orbit the secret key lies in.

**Domain Bridges**: Group Theory <-> Cryptographic Parameter Selection

**Lineage**: Builds on `subgroupOrbit_card` and `subgroupOrbit_map_injective` from this cycle.

**Ambition**: extension

---

### Direction 5: Non-Commutative Group Actions and SIDH Security

**Conjecture**: The random self-reducibility of GAIP fundamentally requires commutativity of the group action. In a free transitive *non-commutative* group action, GAIP can have instances of varying difficulty, and the worst-case ≠ average-case.

**Test**: Construct a concrete non-commutative group action (e.g., S₃ acting on a 6-element set) and exhibit two GAIP instances with different difficulty (one solvable by inspection, one requiring exhaustive search). Verify computationally that the rerandomization lemma fails: connector(r·x, r·y) ≠ connector(x, y) for some r.

**Impact**: This would formally separate the security of CSIDH (commutative, random self-reducible) from SIDH/SIKE (non-commutative, not random self-reducible), providing a mathematical explanation for why SIDH was broken (Castryck-Decru 2022) while CSIDH remains secure.

**Catalog References**: `Catalog/Cryptography/BerggrenGroupoidOrbit.lean` (non-commutative group actions), `Catalog/Cryptography/BerggrenFingerprintRigidity.lean` (free monoid actions)

**Proof Strategy**: The key step is to show that the proof of `rerandomization_preserves_solution` uses `mul_comm` essentially — without it, the chain of equalities breaks. Construct an explicit counterexample in S₃ ⋊ Z/6Z where the connector changes under rerandomization. Then prove that in any non-abelian group, there exist x, r such that connector(r·x, r·(s·x)) ≠ s for some s.

**Domain Bridges**: Abstract Algebra <-> Cryptanalysis <-> Post-Quantum Security

**Lineage**: Builds on `rerandomization_preserves_solution` from this cycle and the Berggren non-commutative action theory.

**Ambition**: extension
