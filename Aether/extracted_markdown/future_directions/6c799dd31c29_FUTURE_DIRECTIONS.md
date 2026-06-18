# Future Directions: Substitution Spectra and Aperiodic Tiling Theory

## Synthesis

This research cycle established the **substitution spectrum** as a novel algebraic framework for studying parameterized families of aperiodic tiling systems. The key discovery is that the expansion factor — the fundamental invariant controlling aperiodicity — is locked in by the substitution matrix's trace and determinant and is therefore constant across any continuous family of geometric realizations. This spectral invariance, combined with the irrational expansion obstruction theorem (non-square discriminant ⟹ no rational eigenvalues), provides a purely algebraic O(1) certificate of aperiodicity.

The most significant cross-domain connection is between substitution tiling theory and **expander graph theory**. The algebraic condition for aperiodicity (irreducible characteristic polynomial from non-square discriminant) is identical to the Singer-like condition in GL₂(𝔽_q) that certifies spectral expansion of Cayley graphs. This means the same matrix that produces a non-repeating mosaic also generates a highly-connected communication network — aperiodicity and expansion are spectral siblings. The tropical symbolic dynamics bridge further extends this connection: the substitution matrix, viewed as a tropical transition matrix, induces projective contraction that guarantees symbolic mixing. These three domains — aperiodic tilings, expander graphs, and tropical dynamics — share a common algebraic root in the spectral properties of 2×2 integer matrices.

The highest breakthrough potential lies in **Direction 1 (Higher-Dimensional Spectral Classification)**, which would generalize the discriminant criterion from 2×2 to n×n substitution matrices, connecting to deep questions in algebraic number theory about Pisot-Vijayaraghavan numbers. Direction 3 (Spectral Completeness) addresses the most fundamental open question: is non-square discriminant *necessary* for aperiodicity, or merely sufficient?

---

### Direction 1: Higher-Dimensional Spectral Classification of Substitution Systems

**Conjecture**: For an n×n primitive substitution matrix M with positive integer entries, the tiling system is aperiodic if and only if the characteristic polynomial χ_M is irreducible over ℚ. In the n = 2 case, irreducibility over ℚ is equivalent to non-square discriminant, which we have fully formalized. The conjecture asserts this extends: irreducibility of the degree-n characteristic polynomial — equivalently, the Galois group of χ_M acting transitively on the roots — is the complete spectral certificate of aperiodicity for arbitrary tile alphabets.

**Test**: Formalize the n = 3 case. For a 3×3 substitution matrix, the characteristic polynomial is cubic: χ(X) = X³ - tr·X² + σ₂·X - det, where σ₂ is the second elementary symmetric function. Compute the cubic discriminant Δ₃ = 18·tr·σ₂·det - 4·tr³·det + tr²·σ₂² - 4·σ₂³ - 27·det². Show: if χ is irreducible over ℚ (checkable via the rational root theorem and then Eisenstein/reduction mod p), the dominant eigenvalue is an algebraic number of degree 3, forcing irrational tile-count ratios. Implement a computational check on the 3-tile Rauzy substitution (a→ab, b→ac, c→a) with matrix [[1,1,1],[1,0,0],[0,1,0]].

**Impact**: If true, this provides a uniform, purely algebraic classification of aperiodicity for substitution systems of arbitrary complexity. It would connect tiling theory to the deep arithmetic of algebraic number fields. If false, the failure case would identify specific n-tile systems where periodic tilings exist despite irreducible characteristic polynomial — these would be highly exotic counterexamples.

**Catalog References**: `FINAL/Pythagorean/GL2SpectralGap.lean` (irreducible_poly_no_root for the degree-2 analog), `Pythagorean/SubstitutionSpectrum/Defs.lean` (new: non-square discriminant criterion)

**Proof Strategy**: 
1. Define n×n SubstMatrix structure with positivity constraints
2. Prove the rational root theorem for monic integer polynomials of arbitrary degree
3. Show irreducibility implies the minimal polynomial of each root has degree n
4. Connect to the Perron-Frobenius theorem: primitive matrices have a unique dominant positive eigenvalue
5. Prove that if this eigenvalue has degree > 1 over ℚ, the eigenvector (limiting tile-count ratio) has irrational entries

**Domain Bridges**: Aperiodic Tilings ↔ Algebraic Number Theory (Pisot numbers), Substitution Dynamics ↔ Ergodic Theory (unique ergodicity of substitution shifts)

**Lineage**: Extends the 2×2 discriminant criterion (subst_no_rational_eigenvalue) from this cycle

**Ambition**: grand_challenge

---

### Direction 2: Tropical Spectral Gap from Substitution Discriminant

**Conjecture**: For a 2×2 unimodular substitution matrix M with trace t ≥ 3, the Hilbert projective contraction rate of the induced tropical dynamics is ρ = (t - √(t²-4))/(t + √(t²-4)) = 1/λ₁², where λ₁ = (t + √(t²-4))/2 is the dominant eigenvalue. Specifically, the contraction rate satisfies ρ ≤ 1/(t-1)², providing an explicit, computable bound on the mixing time.

**Test**: Formalize the connection between the SubstMatrix discriminant and the Hilbert projective distance contraction. Show that the Birkhoff-Hopf theorem applied to the 2×2 positive matrix gives contraction rate equal to the ratio of subdominant to dominant eigenvalue. Verify computationally for the Penrose matrix (ρ = 1/φ² ≈ 0.382), Ammann-Beenker (ρ = (3-2√2)/(3+2√2) ≈ 0.029), and Silver Ratio (ρ = (2-√3)/(2+√3) ≈ 0.072).

**Impact**: This would quantify the "aperiodicity strength" of a substitution — not just whether it's aperiodic, but how quickly the tiling statistics converge. Larger discriminant = faster mixing = stronger aperiodicity. This connects directly to the `tropical_spectral_gap_implies_mixing_and_extraction` theorem.

**Catalog References**: `Tropical/SymbolicDynamics/Core.lean` (hasTropicalSpectralGap, hilbertProjectiveDist), `Pythagorean/SubstitutionSpectrum/Bridge.lean` (new: subst_disc_mono_in_tr)

**Proof Strategy**:
1. Formalize the Birkhoff-Hopf contraction theorem for 2×2 positive matrices
2. Compute the Hilbert projective diameter of the image simplex under M
3. Show the contraction rate equals the ratio of eigenvalues in absolute value
4. Derive the bound ρ ≤ 1/(t-1)² from the quadratic formula

**Domain Bridges**: Substitution Spectrum ↔ Tropical Geometry (Hilbert projective metric), Aperiodic Tilings ↔ Markov Chain Mixing Times

**Lineage**: Bridges subst_disc_mono_in_tr and tropical_spectral_gap_implies_mixing_and_extraction

**Ambition**: extension

---

### Direction 3: Spectral Completeness — Is Non-Square Discriminant Necessary?

**Conjecture**: For 2-tile substitution systems, non-square discriminant is not merely sufficient but *necessary* for aperiodicity. Specifically: if Δ(M) = k² for some integer k (square discriminant), then the substitution system admits a periodic tiling.

**Test**: Analyze the case Δ = k². Then eigenvalues are λ₁ = (t+k)/2 and λ₂ = (t-k)/2, both rational (in fact integers when t and k have the same parity). Construct explicit periodic tilings for small examples: M = [[2,1],[1,2]] has Δ = 4, eigenvalues 1 and 3. Show a periodic arrangement of tiles with integer-ratio counts exists. Then attempt to prove the general statement: rational eigenvalues imply the existence of a periodic point for the substitution map on symbol sequences.

**Impact**: If true, the discriminant criterion is a complete invariant: aperiodic ⟺ non-square discriminant. This would be a clean classification theorem with no gaps. If false (there exist periodic substitutions with irrational expansion), the counterexample would reveal a fundamentally different mechanism for periodicity beyond the spectral one — this would be equally informative.

**Catalog References**: `Pythagorean/SubstitutionSpectrum/Defs.lean` (subst_no_rational_eigenvalue, five_not_square)

**Proof Strategy**:
1. Show that rational eigenvalues imply rational eigenvectors
2. Rational eigenvectors give rational tile-count ratios
3. Rational ratios allow decomposition of the tiling into finite patches with integer counts
4. Use the periodicity of integer-ratio tilings (a combinatorial argument)

**Domain Bridges**: Number Theory (rational points on varieties) ↔ Symbolic Dynamics (periodic orbits), Tiling Theory ↔ Combinatorics (finite patch counting)

**Lineage**: Directly extends the irrational expansion obstruction from this cycle

**Ambition**: grand_challenge

---

### Direction 4: Substitution Spectrum and Quantum Error Correction

**Conjecture**: The substitution spectrum of a 2-tile system determines the parameters of a quantum error-correcting code constructed from the tiling. Specifically, a substitution with expansion factor λ and determinant d yields a [[n, k, d_min]] stabilizer code where the code distance d_min grows as λᵏ and the rate k/n converges to 1 - 1/λ.

**Test**: Construct the *tiling graph code*: vertices are tiles after k substitution steps, edges connect tiles sharing an edge in the tiling. The kernel of the adjacency matrix over 𝔽₂ gives the codespace. Compute code parameters for the Penrose substitution at levels k = 1, 2, 3, 4 and verify the conjectured scaling. Compare with the `certificate_mixing_time_bound` theorem which bounds mixing time of related random walks.

**Impact**: This would create a new family of quantum codes from aperiodic tilings, with code parameters controlled by a 2×2 integer matrix. The aperiodicity ensures the codes have no short periodic patterns (which would create degenerate stabilizers), while the Pisot condition ensures exponentially growing distance.

**Catalog References**: `FINAL/Pythagorean/CertificateSampling.lean` (certificate_mixing_time_bound), `Pythagorean/SubstitutionSpectrum/Bridge.lean` (subst_iterMatrix_det)

**Proof Strategy**:
1. Define the tiling graph at level k
2. Compute its adjacency matrix in terms of M^k
3. Analyze the kernel over 𝔽₂ using the Smith normal form
4. Relate code distance to the spectral gap of the adjacency matrix

**Domain Bridges**: Aperiodic Tilings ↔ Quantum Error Correction, Substitution Spectrum ↔ Coding Theory (code distance from expansion)

**Lineage**: Extends subst_iterMatrix_det and the spectral gap bridge

**Ambition**: extension

---

### Direction 5: Non-Commutative Substitution Spectra

**Conjecture**: For substitution systems on n ≥ 3 tile types, the *non-commutative* structure of the substitution monoid (generated by permutations of the substitution rule) contains additional aperiodicity information beyond the characteristic polynomial. Specifically, for n = 3, there exist pairs of substitution matrices with identical characteristic polynomials but different aperiodicity behavior, detected by the non-commutative invariant [M, σ·M·σ⁻¹] where σ is a permutation matrix.

**Test**: Search computationally for 3×3 positive integer matrices with matching characteristic polynomials but different dynamical behavior. Compute the commutator [M, PMP⁻¹] for all permutation matrices P and check whether its rank/trace/determinant distinguishes the dynamics. Start with the Rauzy substitution matrix [[1,1,1],[1,0,0],[0,1,0]] and its permutation variants.

**Impact**: This would show that the characteristic polynomial is *incomplete* for n ≥ 3, motivating a richer invariant theory. The non-commutative residue would be a genuinely novel algebraic object — not studied in classical tiling theory.

**Catalog References**: `FINAL/Pythagorean/SemidirectUniversality.lean` (obstruction_polynomial_of_orbit_polynomial — orbit polynomials as algebraic invariants)

**Proof Strategy**:
1. Implement computational search over 3×3 matrices with bounded entries
2. For candidate pairs, analyze the substitution dynamics on 3-symbol sequences
3. Formalize the non-commutative invariant and prove it detects the difference
4. Connect to the orbit polynomial machinery in SemidirectUniversality.lean

**Domain Bridges**: Non-Commutative Algebra ↔ Symbolic Dynamics, Representation Theory ↔ Tiling Theory

**Lineage**: Generalizes the 2×2 spectral classification where the charpoly is complete

**Ambition**: grand_challenge
