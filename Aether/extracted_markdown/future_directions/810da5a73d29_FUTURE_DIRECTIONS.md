# Future Directions: Isogeny-Based Cryptography Formalization

## Synthesis

This cycle established the first complete, machine-verified formal framework for the algebraic security of CSIDH and CSI-FiSh at the abstract torsor level. The central discovery is the **Trivialization–Cohomology–Rigidity triad**: (1) every torsor trivializes to the standard G-action on itself via a basepoint-dependent bijection; (2) the connector map satisfies Čech 1-cocycle conditions that precisely characterize how different trivializations relate; (3) for abelian groups, the only equivariant endomorphisms are translations, eliminating hidden-symmetry attacks. Together, these three results form a closed algebraic argument that reduces CSIDH security entirely to the hardness of the Group Action Inverse Problem in the class group.

The most promising cross-domain connection from this cycle links the **connector cohomology** formalized here to the **Berggren tree structures** in the existing catalog (`Catalog/Cryptography/BerggrenFingerprintRigidity.lean`, `Catalog/Cryptography/BerggrenGroupoidOrbit.lean`). Both involve free actions of algebraic groups on structured mathematical objects — Berggren matrices on Pythagorean triples, ideal classes on supersingular curves — and the cocycle/coboundary framework could provide a unified treatment of "one-way functions from group actions" across these domains. The **tropical min-plus cryptography** (`Catalog/Cryptography/TropicalMinPlusCrypto.lean`) shares the theme of algebraic one-way functions and could benefit from the torsor-theoretic lens.

The direction with highest breakthrough potential is Direction 1 (Spectral Gap for Class Group Cayley Graphs), because proving expander properties for isogeny graphs would yield the first rigorous indistinguishability guarantee for the Decisional CSIDH assumption from pure algebra — currently the weakest link in the CSIDH security chain. Our formalization of Cayley graph regularity and diameter conjectures provides the scaffolding for this investigation.

---

### Direction 1: Spectral Gap for Class Group Cayley Graphs

**Conjecture**: For a free transitive action of a finite abelian group G on a set X with symmetric generator set S (|S| = d), the Cayley graph Cay(G, S) has spectral gap λ₁ − λ₂ ≥ d/|G|. For cyclic groups ℤ/nℤ with S = {1, −1}, the gap is exactly 2(1 − cos(2π/n)).

**Test**: (a) Compute eigenvalues of the adjacency matrix for ℤ/nℤ × ℤ/mℤ with product generators for small n, m (e.g., n = m = 5, 7, 11). Verify the spectral gap matches 2(1 − cos(2π/n)) + 2(1 − cos(2π/m)) − 4(1 − cos(2π/n))(1 − cos(2π/m))/4. (b) For non-cyclic abelian groups (e.g., ℤ/2ℤ × ℤ/2ℤ × ℤ/pℤ), compute the gap numerically and compare to the bound d/|G|.

**Impact**: If true, this directly implies rapid mixing of random walks on isogeny graphs, which yields: (i) security of hash functions based on random isogeny walks; (ii) pseudorandomness of CSIDH public keys; (iii) indistinguishability of the Decisional CSIDH assumption from random. If false (gap is smaller than d/|G|), it identifies specific group structures where CSIDH may be weak.

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean`, `FINAL/Tropical/MixingTheory.lean` (tropical_cycle_gap_mixing_lower_bound), `Catalog/Bridges/GL2SpectralDecomposition.lean` (familywise_spectral_gap_of_bounds)

**Proof Strategy**: 
1. Formalize the character theory of finite abelian groups (characters χ : G → ℂ*).
2. Prove eigenvalues of Cay(G, S) are ∑_{s ∈ S} χ(s) for each character χ.
3. For cyclic groups, characters are χ_k(g) = exp(2πikg/n), giving eigenvalues 2cos(2πk/n).
4. The spectral gap is the minimum over non-trivial characters of d − Re(∑ χ(s)).
5. For the Alon-Boppana bound approach, use representation theory of abelian groups.

**Domain Bridges**: Cayley graph spectral theory ↔ Tropical mixing theory (spectral gap → mixing time), Torsor trivialization ↔ Character theory (trivializations = characters in dual)

**Lineage**: Builds on this cycle's formalization of Cayley graph regularity (cayley_regular) and diameter conjecture (cayleyDiamConj), plus existing tropical mixing results.

**Ambition**: grand_challenge

---

### Direction 2: Decisional CSIDH from Computational CSIDH

**Conjecture**: Under the computational GAIP assumption, the Decisional CSIDH problem (distinguishing (x₀, a·x₀, b·x₀, ab·x₀) from (x₀, a·x₀, b·x₀, c·x₀)) is hard for abelian group actions with sufficiently large groups. Specifically, the advantage of any adversary against DCSIDH is at most O(√(ε_GAIP · |G|)) where ε_GAIP is the GAIP advantage.

**Test**: Implement the random self-reduction: given a DCSIDH instance (x₀, A, B, C), rerandomize by choosing random r, s and forming (x₀, r·A, s·B, rs·C). Check that rerandomization preserves the real/random distinction but hides the specific instance.

**Impact**: A formal proof that DCSIDH reduces to GAIP would close the main gap in CSIDH security analysis: currently, ElGamal-type encryption requires DCSIDH, but only GAIP is believed hard. The reduction would also apply to all CSIDH-derived schemes (CSI-FiSh signatures, CSURF key exchange).

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean` (GAIP, DCSIDH structures), `Catalog/Cryptography/IsogenyFoundations.lean` (DCSDInstance, real_instance_valid)

**Proof Strategy**: 
1. Formalize random self-reducibility of GAIP: given an oracle solving GAIP with advantage ε, solve any GAIP instance with advantage ε by rerandomizing.
2. Prove the Galbraith-Vercauteren reduction: a DCSIDH distinguisher D with advantage δ yields a GAIP solver with advantage Ω(δ²/|G|).
3. The key lemma is: if D distinguishes real from random, then querying D on rerandomized instances and aggregating yields a GAIP solver.
4. Formalize the hybrid argument: (x₀, A, B, AB) → (x₀, A, B, rAB) → (x₀, A, B, R).

**Domain Bridges**: DCSIDH reduction ↔ Leftover Hash Lemma (entropic extraction), Connector algebra ↔ Hybrid arguments (coboundary = hybrid step)

**Lineage**: Builds on this cycle's DCSDInstance formalization and real_instance_valid theorem.

**Ambition**: grand_challenge

---

### Direction 3: Torsor-Theoretic One-Way Functions Across Domains

**Conjecture**: The torsor trivialization framework provides a unified treatment of one-way functions across three domains: (a) CSIDH (class group on curves), (b) Berggren tree navigation (matrix group on Pythagorean triples), (c) tropical min-plus cryptography (tropical semiring on vectors). In each case, the one-way function is the "untrivialization" g ↦ g · x₀, collision resistance follows from freeness, and preimage resistance from the GAIP.

**Test**: (a) Formalize the Berggren action as a CGA and verify it satisfies the torsor axioms (or identify which axiom fails — the Berggren action is free but NOT transitive on all triples, only on primitives). (b) Check whether the tropical min-plus action satisfies freeness. (c) Compute collision-resistance bounds in all three settings.

**Impact**: A unified framework would enable transfer of security reductions across domains. Techniques developed for CSIDH security (spectral gap bounds, parallel repetition) could be automatically applied to Berggren-based and tropical-based cryptosystems.

**Catalog References**: `Catalog/Cryptography/BerggrenFingerprintRigidity.lean`, `Catalog/Cryptography/BerggrenGroupoidOrbit.lean`, `Catalog/Cryptography/TropicalMinPlusCrypto.lean`, `Catalog/Cryptography/TropicalOneWayFoundations.lean`

**Proof Strategy**: 
1. Define a "partial torsor" structure: free action that is transitive on a specific orbit.
2. Show Berggren matrices act freely on primitive Pythagorean triples (each triple has a unique Berggren word).
3. Verify the connector and cocycle properties hold within each orbit.
4. Define a "torsor morphism" between two torsors and prove that morphisms preserve collision resistance.

**Domain Bridges**: Torsor trivialization ↔ Berggren word problem (unique decomposition = freeness), Connector cohomology ↔ Tropical cocycles (min-plus analogues of cocycle conditions)

**Lineage**: Builds on this cycle's Torsor, EquivariantMap, and connector cohomology, plus existing Berggren and tropical catalog entries.

**Ambition**: extension

---

### Direction 4: Quantum Security of the Group Action Inverse Problem

**Conjecture**: The GAIP for the class group Cl(O_K) where K = ℚ(√−p) requires Ω(|Cl(O_K)|^{1/3}) quantum queries to the group action oracle, even for quantum adversaries with access to a quantum random oracle.

**Test**: (a) Verify the lower bound for small class groups (|Cl| ≤ 100) by exhaustive search over all quantum algorithms with bounded query complexity. (b) Implement Kuperberg's hidden shift algorithm and verify its query complexity matches the conjectured O(|Cl|^{1/2 + o(1)}).

**Impact**: A tight quantum lower bound would definitively establish CSIDH's quantum security level. Current estimates range from 2^{64} to 2^{128} depending on the assumed quantum algorithm, and a formal lower bound would resolve this uncertainty.

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean`, `Catalog/Cryptography/IsogenyFoundations.lean`, `FINAL/Shared/EntropyAlgebraCrypto.lean` (key_derivation_entropy_gap)

**Proof Strategy**: 
1. Formalize the quantum query model for group actions.
2. Prove a polynomial method lower bound: any quantum algorithm solving GAIP with advantage ε makes at least Ω(|G|^{1/3} · ε) queries.
3. The key technical ingredient is a quantum version of the birthday bound adapted to group actions.
4. For the upper bound, formalize Kuperberg's sieve algorithm as a sequence of group-theoretic operations.

**Domain Bridges**: Quantum query complexity ↔ Entropy algebra (query complexity ↔ min-entropy), GAIP lower bounds ↔ Spectral gap (mixing time ↔ query complexity)

**Lineage**: Builds on this cycle's GAIP formalization and security amplification results.

**Ambition**: grand_challenge

---

### Direction 5: Formal Proof of CSI-FiSh EUF-CMA Security

**Conjecture**: CSI-FiSh (CSIDH-based Fiat-Shamir signature scheme) achieves EUF-CMA security in the random oracle model, with a tight reduction to the GAIP. The security loss is at most Q_H / 2^λ where Q_H is the number of hash queries and λ is the challenge length.

**Test**: (a) Formalize the Fiat-Shamir transform for sigma protocols with 2-special soundness. (b) Prove the forking lemma in Lean 4. (c) Apply to CSI-FiSh to derive concrete security bounds.

**Impact**: This would be the first machine-verified proof of a post-quantum signature scheme's unforgeability. Current security proofs for CSI-FiSh are paper-based and involve subtle rewinding arguments that are error-prone.

**Catalog References**: `Catalog/Cryptography/CSIFiSh.lean` (sigma_special_soundness), `Catalog/Cryptography/SchnorrProtocol.lean`, `Catalog/Cryptography/CommitmentProtocol.lean`

**Proof Strategy**: 
1. Formalize the random oracle model as an abstract hash function interface.
2. Prove the general forking lemma: if an adversary produces a valid forgery with probability ε, then rewinding produces two forgeries with the same commitment and different challenges with probability ≥ ε²/Q_H − 1/|challenge_space|.
3. Apply special soundness (already formalized in this cycle) to extract the secret key from the two forgeries.
4. Conclude: any EUF-CMA adversary with advantage ε can be converted to a GAIP solver with advantage ≥ ε²/Q_H.

**Domain Bridges**: Fiat-Shamir transform ↔ Sigma protocol algebra (special soundness → unforgeability), Forking lemma ↔ Security amplification (rewinding ↔ parallel repetition)

**Lineage**: Builds on this cycle's sigma_special_soundness and extraction_yields_secret theorems.

**Ambition**: extension
