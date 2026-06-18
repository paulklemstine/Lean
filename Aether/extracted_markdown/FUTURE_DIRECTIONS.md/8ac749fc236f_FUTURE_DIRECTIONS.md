# Future Directions: Isogeny-Based Cryptography

## Synthesis

This research cycle established a complete, sorry-free formalization of the algebraic foundations of CSIDH and CSI-FiSh in Lean 4. The key insight is that the security of isogeny-based cryptography reduces to pure group-theoretic properties — freeness, transitivity, and commutativity — independent of the specific elliptic curve instantiation. This abstraction opens three major avenues for future work.

First, the **degree map triviality theorem** (any ℕ-valued multiplicative degree map on a group is constant 1) reveals that the interesting computational structure of isogenies lives in the ideal *monoid*, not the class group quotient. Formalizing this distinction — between the monoid where degrees vary and the group where they collapse — could yield new insights into the hardness of GAIP by connecting it to the factorization structure of ideals.

Second, the **multi-party CSIDH correctness theorem** generalizes naturally to more complex protocol topologies. The permutation invariance proof via List.Perm.prod_eq suggests that Lean's list permutation library could be leveraged to formalize round-optimal multi-party protocols, threshold schemes, and even verifiable secret sharing over group actions.

Third, the **Cayley diameter conjecture** (diameter of ℤ/nℤ with {±1} is ⌊n/2⌋) is the simplest instance of a much deeper question: what is the diameter of the actual CSIDH isogeny graph? This connects directly to the security parameter of the scheme, as the diameter determines worst-case isogeny computation time. The most promising cross-domain bridge is between **graph expansion theory** and **class group arithmetic**, where spectral bounds on the Cayley graph could yield provable lower bounds on GAIP hardness.

---

### Direction 1: Ideal Monoid Degree Structure and GAIP Hardness

**Conjecture**: The computational hardness of GAIP is equivalent to the hardness of factoring elements of the ideal monoid into prime ideal factors of bounded norm. Specifically, if the ideal class [𝔞] ∈ Cl(𝒪) is represented by an ideal 𝔞 with N(𝔞) = ∏ ℓᵢ^{eᵢ}, then the difficulty of computing the isogeny [𝔞] · E₀ depends on the smoothness bound B = max(ℓᵢ).

**Test**: Formalize the ideal monoid (not just the class group) as a structure in Lean with a genuine multiplicative degree map deg : Ideal(𝒪) → ℕ where deg(𝔞 · 𝔟) = deg(𝔞) · deg(𝔟). Verify that the degree map descends to the constant-1 map on the class group quotient. Then state and attempt to prove: if there exists a polynomial-time algorithm that, given E₀ and E = [𝔞] · E₀, finds *any* representative ideal 𝔟 in the class [𝔞] with N(𝔟) ≤ B, then GAIP can be solved in time polynomial in B.

**Impact**: If true, this would formalize the folklore belief that GAIP hardness is related to the smoothness of ideal representatives, providing a concrete reduction rather than a heuristic argument. If false (i.e., finding smooth representatives doesn't help), it would suggest that GAIP hardness has a fundamentally different source than factoring-type problems.

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean`, `Catalog/Cryptography/EllipticCurve/Basic.lean`

**Proof Strategy**: 
1. Define `IdealMonoid(𝒪)` as a Lean structure with multiplication and norm map.
2. Prove `norm_mul : norm(𝔞 · 𝔟) = norm(𝔞) · norm(𝔟)`.
3. Define the quotient map `IdealMonoid → ClassGroup` and show the norm descends to the constant map.
4. Formalize the "smooth representative" problem as a decision problem.
5. Build the reduction from GAIP to smooth representative finding.

**Domain Bridges**: Cryptography <-> NumberTheory, Algebra <-> Computation

**Lineage**: Builds on `IsogenyDegreeMap` and `degree_eq_one` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Expansion of Isogeny Cayley Graphs

**Conjecture**: For the Cayley graph of the class group Cl(𝒪) with generator set S = {[ℓ₁], [ℓ₁]⁻¹, ..., [ℓₖ], [ℓₖ]⁻¹} (the small prime ideals), the spectral gap λ₁ - λ₂ satisfies λ₁ - λ₂ ≥ c / log(|Cl(𝒪)|) for some absolute constant c > 0. This would make the graph a family of expander graphs.

**Test**: For the abstract Cayley graph formalized in this cycle, prove that the adjacency matrix of a |S|-regular graph on |G| vertices has second eigenvalue bounded in terms of |S| and |G|. As a concrete test: for ℤ/pℤ with generators {1, p-1}, compute the eigenvalues of the adjacency matrix for p = 5, 7, 11, 13, 17 and verify the spectral gap grows as predicted.

**Impact**: A formalized spectral gap bound would provide the first machine-verified proof that isogeny graphs are expanders, which is the key property underlying the security of hash functions derived from isogeny graphs (Charles-Lauter-Goren). It would also give rigorous mixing time bounds for random walks on the isogeny graph, relevant to key generation.

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean` (CayleyGraph structure), `Catalog/Algebra/Advanced.lean`

**Proof Strategy**:
1. Formalize the adjacency matrix of a CayleyGraph as a `Matrix (Fin |X|) (Fin |X|) ℝ`.
2. Prove the matrix is symmetric (from `adjacent_symm`) and has row sums = |S| (from `degree_eq_generators_of_free`).
3. For cyclic groups, compute eigenvalues explicitly as λₖ = Σ_{g ∈ S} exp(2πikφ(g)/n) where φ : G → ℤ/nℤ.
4. Bound the spectral gap using character theory.

**Domain Bridges**: Cryptography <-> Algebra, Computation <-> Geometry

**Lineage**: Builds on `CayleyGraph`, `degree_eq_generators_of_free`, and `CayleyDiameterConj` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Threshold CSI-FiSh Signatures

**Conjecture**: The CSI-FiSh signature scheme can be extended to a (t, n)-threshold scheme where any t out of n signers can produce a valid signature, but fewer than t signers cannot. The security reduces to GAIP under the same assumptions as standard CSI-FiSh, plus a discrete-log-style assumption in the class group.

**Test**: Formalize the following protocol in Lean: each signer i holds a share sᵢ of the secret s = Σᵢ sᵢ (using additive secret sharing in the class group). To sign, each signer i commits Rᵢ = rᵢ · x₀, reveals to other signers, and responds to challenges using Lagrange interpolation to reconstruct the full response without revealing individual shares. Prove that: (a) correctness holds (the combined signature verifies), and (b) the 2-special soundness extractor recovers s from two transcripts.

**Impact**: Threshold signatures are essential for multi-party custody of digital assets. A formalized threshold CSI-FiSh would be the first post-quantum threshold signature with machine-verified security.

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean` (csifish_2_special_soundness), `Catalog/Cryptography/SchnorrProtocol.lean`

**Proof Strategy**:
1. Define `SecretShare G n t` as a structure with shares sᵢ and reconstruction.
2. Prove `share_reconstruct : Σᵢ λᵢ sᵢ = s` for Lagrange coefficients λᵢ.
3. Define the threshold signing protocol as a sequence of actions.
4. Prove completeness by showing the combined response satisfies the verification equation.
5. Prove soundness by reducing to the standard CSI-FiSh extractor.

**Domain Bridges**: Cryptography <-> Algebra

**Lineage**: Builds on `csifish_2_special_soundness`, `extracted_key_is_connector`, `multiparty_csidh_correctness` from this cycle.

**Ambition**: extension

---

### Direction 4: Concrete CSIDH with Montgomery Curves

**Conjecture**: The CSIDH protocol can be instantiated with Montgomery curves y² = x³ + Ax² + x over 𝔽_p where p = 4 · ℓ₁ · ... · ℓₙ - 1, and the resulting scheme satisfies the abstract FreeTrans axioms. Specifically, the action of [ℓᵢ] on a Montgomery coefficient A can be computed via Vélu's formulas, and the composition of such actions satisfies act_mul.

**Test**: Formalize Montgomery curves as a Lean structure with coefficient A ∈ 𝔽_p. Implement the action of a single prime ideal [ℓ] as: (1) find a point P of order ℓ, (2) compute the isogeny kernel ⟨P⟩, (3) apply Vélu's formulas to get the new coefficient A'. Verify that for p = 419 = 4 · 3 · 5 · 7 - 1, the composition of [3] and [5] actions equals the [15] action (act_mul check).

**Impact**: This would bridge the gap between our abstract formalization and the concrete CSIDH implementation, providing end-to-end verified correctness from the algebraic specification to the finite field computation. It would be the first machine-verified implementation of CSIDH.

**Catalog References**: `Catalog/Cryptography/EllipticCurve/Basic.lean` (ecAdd, ShortWeierstrassModel), `Catalog/Cryptography/CSIFiSh.lean`

**Proof Strategy**:
1. Define `MontgomeryCurve 𝔽_p` with coefficient A and non-singularity.
2. Formalize Vélu's formulas for computing isogenies of prime degree.
3. Define the class group action using Vélu's formulas.
4. Prove act_one (identity isogeny maps A to A).
5. Prove act_mul by showing Vélu composition = product ideal action.
6. Prove freeness and transitivity for small instances.

**Domain Bridges**: Cryptography <-> Algebra, NumberTheory <-> Computation

**Lineage**: Builds on `CryptoGroupAction`, `FreeTrans`, and the elliptic curve formalization in the Catalog.

**Ambition**: extension

---

### Direction 5: Quantum Security of GAIP via Random Oracle Model

**Conjecture**: In the quantum random oracle model (QROM), the CSI-FiSh signature scheme achieves EUF-CMA security (existential unforgeability under chosen message attack) with security loss at most O(q_H · q_S) where q_H is the number of quantum hash queries and q_S is the number of signing queries, assuming GAIP is hard against quantum polynomial-time adversaries.

**Test**: Formalize the quantum random oracle model as a Lean structure where the hash function H is modeled as a function from messages to challenges, and the adversary has quantum superposition access. State the Don-Fehr-Majenz-Schaffner (DFMS) Fiat-Shamir security theorem in the QROM, and instantiate it with the CSI-FiSh identification scheme. The key lemma to prove is: if the CSI-FiSh identification scheme has *computational unique response* (CUR) — meaning that for any commitment R and challenge c, there is at most one valid response z — then the QROM Fiat-Shamir transform is EUF-CMA secure.

**Impact**: This would provide the first machine-verified quantum security proof for an isogeny-based signature scheme, addressing the gap between classical and quantum security models that has been a major concern in post-quantum standardization.

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean`, `Catalog/Cryptography/FOTransform.lean`

**Proof Strategy**:
1. Formalize the QROM as a Lean structure with superposition query access.
2. State the DFMS theorem as an axiom (its proof requires quantum information theory beyond current Mathlib).
3. Prove CUR for CSI-FiSh: for any R, c, there is at most one z satisfying verification. This follows directly from `unique_connector`.
4. Instantiate DFMS to obtain the security theorem.

**Domain Bridges**: Cryptography <-> Computation, Logic <-> Physics

**Lineage**: Builds on `csifish_2_special_soundness`, `unique_connector`, and the Fiat-Shamir formalization in the Catalog.

**Ambition**: grand_challenge
