# Future Research Directions

## Synthesis

This research cycle established the metric geometry of pitch class set (PCS) spaces over ℤ/12ℤ, proving three isometry theorems (transposition, inversion, complementation), introducing the intervallic fingerprint as a novel transposition invariant, and providing both computational and structural proofs of the hexachordal complementation theorem. The structural proof — using the "outflow = inflow" principle for bijections on finite sets — revealed that the hexachordal theorem is fundamentally a statement about the balance between set size and translational bijection, not specifically about twelve-tone music. It holds for all d (including d = 0), which is stronger than the classical statement.

The most significant cross-domain connection is between **coding theory** and **music theory**. The PCS space 𝒫(ℤ/12ℤ) is the Hamming cube {0,1}¹² with cyclic symmetry. The interval vector is precisely the autocorrelation function, and the hexachordal theorem is an instance of the MacWilliams identity relating the weight distribution of a binary code to its dual. This connects to the Catalog's algebraic structures (`Algebra/Berggren.lean`), group actions (`Cryptography/BerggrenGroupoidOrbit.lean`), and metric methods (`Bridges/HammingMetric.lean`). The outflow = inflow principle itself connects to ergodic theory and measure-preserving transformations.

The highest breakthrough potential lies in **Direction 1 (Fourier Infrastructure for Finite Abelian Groups)**, because formalizing the DFT on finite abelian groups would unlock not just the analytic hexachordal proof but also formal results in coding theory, signal processing, and number theory (e.g., Gauss sums, quadratic reciprocity via finite Fourier analysis).

---

### Direction 1: Discrete Fourier Analysis on Finite Abelian Groups in Lean

**Conjecture**: The hexachordal complementation theorem for ℤ/nℤ (any even n) can be proved in Lean using the discrete Fourier transform, specifically the identity 1̂_{Sᶜ}(k) = −1̂_S(k) for k ≠ 0 and the Parseval-type relationship between the autocorrelation (interval vector) and the power spectrum |1̂_S(k)|².

**Test**: Formalize the DFT on ZMod n as a linear map ℂ^n → ℂ^n, prove the convolution theorem (DFT of convolution = pointwise product of DFTs), and derive that |1̂_{Sᶜ}(k)|² = |1̂_S(k)|² for k ≠ 0. Then prove the generalized hexachordal theorem for all n via inverse DFT.

**Impact**: This would create reusable Lean infrastructure for discrete harmonic analysis that is currently absent from Mathlib. Applications beyond music theory include: formal proofs of coding theory bounds (Singleton, Hamming, Plotkin), the MacWilliams identity, and number-theoretic results depending on character sums.

**Catalog References**: `Catalog/EML/PersistentHarmony/PitchClass.lean` (existing PCS formalization), `Catalog/MachineLearning/FiniteAbelianHarmonicAnalysis/` (if it exists)

**Proof Strategy**:
1. Define `DFT (n : ℕ) : (ZMod n → ℂ) → (ZMod n → ℂ)` using roots of unity
2. Prove orthogonality: Σ_j ω^{jk} = n·δ_{k,0}
3. Prove Plancherel/Parseval: Σ_k |f̂(k)|² = n · Σ_j |f(j)|²
4. Prove convolution theorem
5. Define indicator functions, prove 1̂_{Sᶜ}(k) = −1̂_S(k) for k ≠ 0
6. Derive generalized hexachordal theorem

**Domain Bridges**: Music theory (interval vectors) ↔ Harmonic analysis (DFT, power spectrum) ↔ Coding theory (weight enumerators, MacWilliams) ↔ Number theory (character sums, Gauss sums)

**Lineage**: Builds on `hexachordal_structural` and `outflow_eq_inflow` from this cycle; extends the combinatorial proof to an analytic proof.

**Ambition**: grand_challenge

---

### Direction 2: MacWilliams Identity and Weight Enumerator Duality

**Conjecture**: The hexachordal theorem is a special case of the MacWilliams identity. Specifically, define the weight enumerator W_C(x,y) = Σ_{c ∈ C} x^{n-wt(c)} y^{wt(c)} for a binary code C ⊆ {0,1}^n. Then for C = {1_S} (the singleton code consisting of just the indicator of S) and its "dual" in an appropriate sense, the MacWilliams identity specializes to the hexachordal theorem.

**Test**: Formalize the weight enumerator polynomial for binary codes over ZMod 2, prove the MacWilliams identity W_{C⊥}(x,y) = |C|⁻¹ W_C(x+y, x-y), and show that specializing to indicator functions of half-size subsets yields the hexachordal interval vector identity.

**Impact**: This would connect music theory to algebraic coding theory in a formally verified way, opening the door to formal proofs of error-correcting code bounds using music-theoretic intuition and vice versa.

**Catalog References**: `Bridges/LawvereCodingTheorem.lean` (coding theory), `Cryptography/BerggrenDiophantineLattice.lean` (lattice methods)

**Proof Strategy**:
1. Define binary linear codes and weight enumerator polynomials
2. Prove the MacWilliams identity (likely needs Fourier analysis from Direction 1)
3. Define the appropriate "code" associated to a PCS S
4. Show the specialization gives IV_S = IV_{Sᶜ}

**Domain Bridges**: Music theory (PCS, interval vectors) ↔ Coding theory (weight enumerators, MacWilliams) ↔ Algebra (polynomial rings, group rings)

**Lineage**: Builds on the interval vector formalization and hexachordal theorem from this cycle; requires Direction 1 as infrastructure.

**Ambition**: grand_challenge

---

### Direction 3: Persistent Homology of Chord Clouds

**Conjecture**: The Vietoris-Rips complex of a chord cloud (finite collection of PCS with Hamming distance) undergoes topologically significant transitions at specific Hamming distance thresholds. Specifically, for the chord cloud consisting of all 12 major triads, the first Betti number β₁ achieves its maximum at a critical threshold ε* that corresponds to the minimum voice-leading distance between non-adjacent triads in the circle of fifths.

**Test**: Compute the Vietoris-Rips filtration for the 12 major triads in Hamming space. Track β₀ (connected components) and β₁ (loops) as ε increases from 0 to 24. Identify the critical thresholds and compare with music-theoretic predictions (circle of fifths adjacency).

**Impact**: This would provide the first rigorous topological analysis of chord space, potentially revealing hidden structure in musical harmony that is invisible to purely metric analysis.

**Catalog References**: `Catalog/EML/PersistentHarmony/PitchClass.lean` (existing PCS + Rips definitions), `Catalog/Geometry/PrimewisePersistence.lean` (persistence methods)

**Proof Strategy**:
1. Compute all pairwise Hamming distances between the 12 major triads
2. Build the Rips complex at each threshold
3. Compute homology (possibly via discrete Morse theory or Smith normal form)
4. Formalize the persistence diagram computation
5. Compare with the known topology of the circle-of-fifths graph

**Domain Bridges**: Music theory (chord progressions, voice leading) ↔ Topology (persistent homology, Rips complexes) ↔ Geometry (metric spaces, Hamming distance)

**Lineage**: Builds on `hammingDist`, `ripsEdge_monotone`, and the chord cloud infrastructure from the Catalog's PitchClass.lean.

**Ambition**: extension

---

### Direction 4: Hexachordal Theorem for Non-Abelian Groups

**Conjecture**: The hexachordal complementation theorem generalizes to subsets of non-abelian groups: for any finite group G of even order and any subset S ⊆ G with |S| = |G|/2, the function R_S(g) = |{a ∈ S : ag ∈ S}| equals R_{Sᶜ}(g) for all g ≠ e.

**Test**: Verify computationally for S₃ (order 6, |S| = 3), D₄ (order 8, |S| = 4), and Q₈ (quaternion group, order 8, |S| = 4). If the conjecture fails, characterize which groups admit the hexachordal property.

**Impact**: If true, this extends the hexachordal theorem from cyclic groups to all finite groups, revealing it as a universal phenomenon in finite group theory. If false, the counterexamples would identify what special property of abelian groups is needed — likely commutativity of the group ring, which enables the DFT approach.

**Catalog References**: `Algebra/Berggren.lean` (group actions), `Cryptography/BerggrenGroupoidOrbit.lean` (orbit structure)

**Proof Strategy**:
1. Define the autocorrelation R_S for subsets of arbitrary finite groups
2. Formalize the representation-theoretic DFT for non-abelian groups (Peter-Weyl)
3. The key question: does 1̂_{Sᶜ}(π) = −1̂_S(π) hold for non-trivial irreps π?
4. If not, characterize the obstruction

**Domain Bridges**: Music theory (generalized transposition) ↔ Representation theory (Peter-Weyl, non-abelian Fourier) ↔ Group theory (finite groups, normal subgroups)

**Lineage**: Direct generalization of `hexachordal_structural` to non-cyclic groups.

**Ambition**: grand_challenge

---

### Direction 5: Intervallic Fingerprint as a Complete Invariant

**Conjecture**: The intervallic fingerprint IF(S) = {IV_S(1), ..., IV_S(6)} is a *complete* transposition invariant for "generic" PCS: two PCS S, T have IF(S) = IF(T) if and only if T = T_k(S) for some k, provided S satisfies a genericity condition (e.g., S has trivial stabilizer under transposition).

**Test**: Enumerate all 4096 PCS up to transposition (there are 352 equivalence classes). For each class, compute IF and check injectivity. Count the number of collisions — pairs of non-transposition-related PCS with the same fingerprint.

**Impact**: If the fingerprint is (generically) complete, it provides an efficient O(n) algorithm for testing transposition equivalence, replacing the naïve O(n²) approach. The collisions, if any, would identify the "Z-related" pairs studied by Forte — a central open problem in music theory.

**Catalog References**: `Geometry/PCSMetricGeometry.lean` (intervallic fingerprint definition, `fingerprint_transpose_invariant`)

**Proof Strategy**:
1. Enumerate transposition equivalence classes computationally
2. Compute IF for each and check for collisions
3. If collisions exist, formalize the characterization of Z-related pairs
4. If no collisions for generic PCS, prove completeness under the genericity hypothesis

**Domain Bridges**: Music theory (Forte's classification, Z-relation) ↔ Combinatorics (multiset invariants, orbit counting) ↔ Algorithms (isomorphism testing, canonical forms)

**Lineage**: Builds on `intervallicFingerprint` and `fingerprint_transpose_invariant` from this cycle.

**Ambition**: extension
