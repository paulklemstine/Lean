# Future Directions: Isogeny-Based Cryptography Formalization

## Synthesis

This cycle established a complete formal framework for the security of CSIDH and CSI-FiSh at the abstract group action level. The key insight is that free transitive group actions (torsors) provide a clean, self-contained foundation for isogeny-based cryptographic proofs: bijectivity of the one-way function, correctness of key exchange, special soundness of identification protocols, and multi-party key agreement all follow from a small set of algebraic axioms without any appeal to the specifics of elliptic curves or isogenies.

The most promising cross-domain connection is between the **group action morphism category** formalized here and the **Berggren tree structures** in the existing catalog (`Cryptography/BerggrenFingerprintRigidity.lean`, `Cryptography/BerggrenGroupoidOrbit.lean`). Both involve group actions on structured mathematical objects — Berggren matrices act on Pythagorean triples, ideal classes act on elliptic curves — and the morphism framework could provide a unified treatment. The connector algebra (cocycle property) also connects to the **tropical min-plus cryptography** (`Cryptography/TropicalMinPlusCrypto.lean`) through the shared theme of one-way functions built from algebraic structures.

The direction with highest breakthrough potential is Direction 1 (Expander Graphs and Mixing Times), because proving spectral gap bounds for isogeny Cayley graphs would immediately yield concrete security guarantees for the Decisional CSIDH assumption — currently the weakest link in the security chain. If achieved, this would be the first formal proof of a cryptographic indistinguishability assumption from spectral graph theory.

---

### Direction 1: Expander Graph Properties of Isogeny Cayley Graphs

**Conjecture**: For a free transitive action of a finite abelian group G on a set X with generator set S closed under inverses, the Cayley graph Cay(G, S) has spectral gap λ₁ - λ₂ ≥ |S|/(2·|G|²), where λ₁, λ₂ are the two largest eigenvalues of the adjacency matrix.

**Test**: Compute the spectrum of Cay(ℤ/nℤ, {±1}) for n = 5, 7, 11, 13, 17, 19, 23 and verify the bound. The eigenvalues of this circulant graph are 2cos(2πk/n) for k = 0, ..., n-1, so λ₁ = 2, λ₂ = 2cos(2π/n), and the spectral gap is 2(1 - cos(2π/n)). Check whether this exceeds 2/(2n²) = 1/n².

**Impact**: A formal spectral gap bound would immediately give a mixing time bound O(n² log n) for random walks on the Cayley graph. This translates to a proof that the output distribution of CSIDH with sufficiently long random walks is statistically close to uniform — the core assumption underlying the Decisional CSIDH problem. This would be the first machine-verified proof connecting spectral graph theory to post-quantum cryptographic security.

**Catalog References**: `Cryptography/CSIFiShDeep.lean` (Cayley graph structures), `Cryptography/HexHoneycomb/Basic.lean` (graph-theoretic formalization patterns)

**Proof Strategy**: (1) Formalize the adjacency matrix of a Cayley graph as a matrix over ℝ. (2) Use the representation theory of finite abelian groups: eigenvalues are character sums ∑_{s∈S} χ(s) for characters χ of G. (3) For abelian groups, all characters are degree-1, giving explicit eigenvalue formulas. (4) Bound the second-largest eigenvalue using the structure of the character group. Key Mathlib lemmas needed: `ZMod.charFun`, `Matrix.eigenvalues`, `Real.cos_lt_one_of_ne_zero`.

**Domain Bridges**: Cryptography <-> Algebra, Graph Theory <-> Number Theory

**Lineage**: Builds on the Cayley graph formalization in `Cryptography/CSIFiShDeep.lean` and the `cayleyDiameterConjecture`.

**Ambition**: grand_challenge

---

### Direction 2: Security Reduction from D-CSIDH to GAIP

**Conjecture**: The Decisional CSIDH problem is at least as hard as the computational GAIP, with a polynomial security loss: any algorithm solving D-CSIDH with advantage ε can be used to solve GAIP with probability ≥ ε²/(2|G|).

**Test**: Formalize the reduction for the concrete case G = ℤ/nℤ and verify that the reduction preserves the advantage bound. Specifically, implement a reduction oracle that uses a D-CSIDH solver to break GAIP, and verify the advantage bound computationally for n = 7, 11, 13.

**Impact**: This would establish the first formally verified computational-to-decisional reduction in isogeny-based cryptography. Currently, the D-CSIDH assumption is used in several protocols but lacks a formal connection to GAIP. Proving or disproving this reduction would clarify the security landscape of commutative group action cryptography.

**Catalog References**: `Cryptography/CSIFiShDeep.lean` (D-CSIDH formalization, `DecisionalCSIDH.isReal`), `Cryptography/CollatzOWF.lean` (one-way function formalization patterns)

**Proof Strategy**: (1) Given a D-CSIDH oracle O, construct a GAIP solver as follows: on input (x₀, y), query O(x₀, y, r·x₀, ?) for random r and multiple targets. If O says "real" for target y' = act(c, x₀), then c = connector(x₀, y) · r (from the real instance structure). (2) The success probability depends on the advantage of O. (3) Use a hybrid argument over the number of queries. Key challenge: formalizing probabilistic arguments in Lean.

**Domain Bridges**: Cryptography <-> Computation, Algebra <-> Probability

**Lineage**: Builds on the D-CSIDH formalization in this cycle and the OWF structure.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Group Action Cryptography

**Conjecture**: The tropical semiring (ℤ, min, +) admits a free transitive action on a finite quotient ℤ/nℤ that is computationally hard to invert under the tropical shortest-vector assumption.

**Test**: Define the tropical action act(g, x) = min(g + x, n) mod n on ℤ/nℤ. Check whether this action is free and transitive for n = 7, 11, 13. If not, characterize the stabilizers and orbit structure. Compute the "tropical connector" (shortest-path distance) for random pairs and verify hardness heuristically.

**Impact**: Connecting tropical algebra to isogeny-like group actions would create a new family of post-quantum cryptographic primitives. The tropical semiring has different algebraic properties from rings of integers, potentially leading to schemes resistant to different classes of attacks. If the action has good cryptographic properties, it could yield a "tropical CSIDH" — a key exchange protocol based on tropical geometry rather than algebraic geometry.

**Catalog References**: `Cryptography/TropicalMinPlusCrypto.lean` (tropical one-way functions, `tropMV_one_sided_bound`), `Cryptography/CSIFiShDeep.lean` (group action framework)

**Proof Strategy**: (1) Define a `TropicalGroupAction` structure extending `CryptoGroupAction` with tropical-specific axioms. (2) Check freeness and transitivity conditions. (3) If the naive action fails to be free, modify it using a tropical analogue of the ideal class group construction. (4) Prove key space size bounds analogous to `csidh_keyspace_mono_B` and `csidh_keyspace_mono_n`.

**Domain Bridges**: Cryptography <-> Tropical, Algebra <-> Combinatorics

**Lineage**: Bridges the tropical min-plus cryptography (`tropMV_one_sided_bound`) with the group action framework from this cycle.

**Ambition**: extension

---

### Direction 4: Berggren Action as Cryptographic Group Action

**Conjecture**: The Berggren tree action on primitive Pythagorean triples, formalized in the catalog as `berggrenA`, `berggrenB`, `berggrenC`, can be cast as a `CryptoGroupAction` of the free monoid on 3 generators acting on the set of primitive triples. Furthermore, the action satisfies a "quasi-free" property: the stabilizer of (3, 4, 5) under this action is trivial (formalized as `evalBergWord_eq_one_iff`), establishing a one-way function from Berggren words to Pythagorean triples.

**Test**: (1) Verify that the `evalBergWord_eq_one_iff` theorem from the catalog indeed implies trivial stabilizer. (2) Check whether the Berggren action is transitive on all primitive triples (it should be, by the Berggren theorem). (3) Compute the "Berggren connector" — the unique word mapping (3,4,5) to a given triple — for triples up to hypotenuse 1000.

**Impact**: Unifying the Berggren tree with the CSIDH framework would create a bridge between number-theoretic cryptography (Pythagorean triples, Lorentz forms) and isogeny-based cryptography (group actions, torsors). The Berggren action is a *free monoid* action rather than a group action, which requires extending the framework to handle non-invertible actions — a mathematically rich generalization.

**Catalog References**: `Cryptography/BerggrenFreeMonoid.lean` (`evalBergWord_eq_one_iff`), `Cryptography/BerggrenGroupoidOrbit.lean` (`berggrenA`, `berggrenB`, `berggrenC`), `Cryptography/BerggrenFingerprintRigidity.lean` (`berggren_word_action_injective`), `Cryptography/CSIFiShDeep.lean` (group action framework)

**Proof Strategy**: (1) Define `MonoidCryptoAction` extending `CryptoGroupAction` to the monoid case (dropping invertibility). (2) Show the Berggren generators satisfy the action axioms using catalog theorems. (3) Prove transitivity using the Berggren theorem (every primitive triple has a unique Berggren representation). (4) Define the one-way function from Berggren words to triples and prove injectivity using `berggren_word_action_injective`. (5) Show that inverting this function requires factoring the triple's representation — connecting to computational hardness.

**Domain Bridges**: Cryptography <-> Number Theory, Algebra <-> Geometry

**Lineage**: Builds on `berggren_word_action_injective` and `evalBergWord_eq_one_iff` from the catalog, extending with the group action framework from this cycle.

**Ambition**: extension

---

### Direction 5: Formal Verification of CSIDH Parameter Security

**Conjecture**: For the CSIDH-512 parameter set (p = 4 · ∏ℓᵢ - 1 with 74 primes ℓᵢ, exponent bound B = 5), the key space size (2·5+1)⁷⁴ = 11⁷⁴ ≈ 2²⁵⁶ provides at least 128-bit post-quantum security, formalized as: for any quantum algorithm A making at most 2⁶⁴ queries to a GAIP oracle, Pr[A solves GAIP] ≤ 2⁻¹²⁸.

**Test**: (1) Verify that 11⁷⁴ > 2²⁵⁵ (key space size lower bound). (2) Verify the meet-in-the-middle attack complexity: √(11⁷⁴) ≈ 2¹²⁸. (3) Check that the quantum speedup via Grover's algorithm gives at most cubic root improvement for group action problems, yielding ∛(11⁷⁴) ≈ 2⁸⁵ — still above 64-bit security.

**Impact**: Formally verified parameter security would provide the first machine-checked proof that a specific CSIDH instantiation meets a concrete security level. This goes beyond the abstract security reductions formalized in this cycle by connecting to actual parameter choices. If the conjecture is disproven (e.g., by a better attack), it would identify exactly where the parameter selection breaks down.

**Catalog References**: `Cryptography/CSIFiShDeep.lean` (`csidh_keyspace_size`, `csidh_keyspace_mono_B`, `csidh_keyspace_mono_n`), `Computation/InfoEfficientAlgorithms.lean` (algorithmic complexity framework)

**Proof Strategy**: (1) Prove 11⁷⁴ > 2²⁵⁵ as a concrete numerical bound (this requires careful handling of large numbers in Lean). (2) Formalize the meet-in-the-middle attack as an `InfoEfficientAlgorithm` with time complexity O(√|G|). (3) Prove that the optimal classical attack has complexity Ω(√|G|) using the generic group action model. (4) Extend to the quantum setting using the quantum generic group action model.

**Domain Bridges**: Cryptography <-> Computation, Number Theory <-> Algorithm Design

**Lineage**: Builds on key space analysis from this cycle and the algorithmic framework in `Computation/InfoEfficientAlgorithms.lean`.

**Ambition**: extension
