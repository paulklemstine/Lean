# Future Research Directions: Cyclotomic Knot Spectra

## Synthesis

This research cycle established a rigorous algebraic framework connecting Alexander polynomials of T(2,n) torus knots to cyclotomic number theory. The **fundamental identity** (X+1)·A_n(X) = X^n + 1 for odd n was proved using the geometric sum formula, providing the algebraic backbone from which all other results flow. The **cyclotomic bridge** A_p = Φ_{2p} for primes p = 3, 5, 7 was verified, linking knot topology to roots of unity. The **spectral dichotomy theorem** classifies palindromic Alexander polynomials into crystalline (unit-circle) and metallic (real-root) types via the single integer invariant b² − 4. The **OAM channel counting theorem** φ(2n) = φ(n) for odd n connects Euler's totient function to the information capacity of knotted light beams.

The most promising cross-domain connection is between the **cyclotomic Galois structure** and **structured light engineering**: the Galois group Gal(ℚ(ζ_{2p})/ℚ) ≅ (ℤ/2pℤ)* acts on OAM modes by permutation, suggesting that Galois-theoretic symmetries could be exploited for error-correcting codes in OAM-multiplexed communication. This connects to the Catalog's Berggren tree structures (`Cryptography/BerggrenDiophantineLattice.lean`), where the Lorentz form encodes geometric symmetries on the unit circle that parallel the cyclotomic root geometry.

Direction 1 (Jones Polynomial via Temperley-Lieb) has the highest breakthrough potential because the Jones polynomial is strictly stronger than Alexander and its quantum-group structure encodes polarization—doubling the potential information channels. Direction 3 (Mahler Measure Phase Transitions) offers the deepest connection to analytic number theory and could bridge to the Catalog's existing Mahler measure work.

---

### Direction 1: Jones Polynomial Spectral Theory via Temperley-Lieb Algebra

**Conjecture**: For a torus knot T(2,n) with n odd prime, the Jones polynomial V_{T(2,n)}(t) evaluated at t = e^{2πi/k} for k = 2n produces values whose absolute values equal the square root of the knot determinant n divided by the quantum dimension at level k.

**Test**: Compute V_{T(2,p)}(e^{2πi/2p}) numerically for p = 3, 5, 7, 11, 13 and verify whether |V| = √p / dim_q(2,p). If the formula holds for all tested primes, the conjecture gains strong computational support. If it fails for any prime, analyze which quantum-group correction is needed.

**Impact**: If true, this provides a direct formula connecting Jones polynomial evaluations at roots of unity to knot invariants, potentially yielding a quantum-information-theoretic interpretation of OAM spectra. It would also provide a spectral theory for polarization modes, doubling the channel count from φ(n) (Alexander) to 2φ(n) (Jones).

**Catalog References**: `Bridges/CyclotomicKnotSpectra.lean` (cyclotomic bridge, spectral dichotomy), `Bridges/KnottedLightTopology.lean` (OAM spectrum definition)

**Proof Strategy**: (1) Define the Temperley-Lieb algebra TL_n(δ) in Lean as a quotient of the braid group algebra. (2) Construct the Jones representation ρ: B_n → TL_n. (3) Compute the Markov trace on TL_n for the braid word of T(2,n). (4) Show the resulting polynomial matches the known formula V_{T(2,n)}(t) = (1 - t^{n+1})/(1 - t²) · t^{(n-1)/2}. Key lemma: the Kauffman bracket of the standard braid closure for T(2,n) satisfies a skein recurrence.

**Domain Bridges**: Knot Theory (Jones polynomial) <-> Quantum Groups (representation theory at roots of unity) <-> Structured Light (polarization-OAM coupling)

**Lineage**: Builds on the cyclotomic bridge theorem (this cycle) and OAM spectrum definition from KnottedLightTopology.lean.

**Ambition**: grand_challenge

---

### Direction 2: Higher Torus Knot Alexander Polynomials T(p,q)

**Conjecture**: For coprime p, q with p < q, the Alexander polynomial of T(p,q) satisfies the identity

(X^{pq} - 1)(X - 1) / ((X^p - 1)(X^q - 1)) = Σ_{i,j} (-1)^{i+j} X^{iq + jp}

where the sum ranges over appropriate index sets, and this polynomial factors as a product of cyclotomic polynomials Φ_d where d divides pq but does not divide p or q alone.

**Test**: Compute the Alexander polynomial for T(3,5), T(3,7), T(5,7) using the formula and verify the cyclotomic factorization. Specifically, check that A_{T(3,5)} = Φ_15 · Φ_5 · Φ_3 (or the correct factorization).

**Impact**: Extends the cyclotomic bridge from T(2,n) to all torus knots, providing a complete dictionary between torus knot topology and cyclotomic arithmetic. Would yield channel counting formulas for general torus knot beams.

**Catalog References**: `Bridges/CyclotomicKnotSpectra.lean` (alexanderT2n, fundamental identity), `Algebra/CyclotomicGaloisGroup.lean`

**Proof Strategy**: (1) Define the bivariate Alexander polynomial formula for T(p,q). (2) Prove the factorization using the multiplicative property of cyclotomic polynomials: X^n - 1 = ∏_{d|n} Φ_d(X). (3) The key step is showing that the numerator (X^{pq}-1)(X-1) and denominator (X^p-1)(X^q-1) share exactly the cyclotomic factors Φ_d where d|p or d|q (but not d|pq with d∤p and d∤q).

**Domain Bridges**: Knot Theory (general torus knots) <-> Number Theory (cyclotomic factorization) <-> Combinatorics (lattice point counting in rectangles)

**Lineage**: Direct extension of the T(2,n) theory from this cycle.

**Ambition**: extension

---

### Direction 3: Mahler Measure Phase Transitions in Knot Polynomials

**Conjecture**: The Mahler measure M(A_n) of the Alexander polynomial of T(2,n) equals 1 for all n (since A_n is cyclotomic for prime n, and products of cyclotomic polynomials for composite n). However, for Alexander polynomials of non-torus knots (e.g., twist knots), M(Δ_K) > 1, and there exists a minimal Mahler measure strictly greater than 1 among all knot Alexander polynomials, achieved by a specific infinite family of knots.

**Test**: Compute M(Δ_K) for twist knots K_n with 3 ≤ n ≤ 20 crossings. Verify M = 1 for all torus knots T(2,n) with n ≤ 31. Identify the knot with smallest M > 1 and check if it matches the Lehmer number (the minimal known Mahler measure of an integer polynomial, approximately 1.17628).

**Impact**: Would establish a sharp boundary between "cyclotomic" knots (M = 1, all torus knots) and "transcendental" knots (M > 1). If the Lehmer number appears as a knot Mahler measure, it would connect the unsolved Lehmer's conjecture to knot theory.

**Catalog References**: `Speculative/AutoResearch/MahlerMeasure.lean` (Mahler measure framework), `Bridges/CyclotomicKnotSpectra.lean` (cyclotomic identification)

**Proof Strategy**: (1) Use the existing Mahler measure framework. (2) Prove M(Φ_n) = 1 using Kronecker's theorem (all roots on unit circle implies M = 1). (3) For twist knots, compute the Alexander polynomial explicitly and bound the Mahler measure using Jensen's formula. (4) Show M(Δ_{figure-eight}) = golden ratio φ ≈ 1.618.

**Domain Bridges**: Knot Theory (Alexander polynomials) <-> Number Theory (Mahler measure, Lehmer's conjecture) <-> Dynamical Systems (entropy of knot complements)

**Lineage**: Extends the cyclotomic bridge to non-torus knots via Mahler measure.

**Ambition**: grand_challenge

---

### Direction 4: Galois-Theoretic Error Correction for OAM Channels

**Conjecture**: The Galois group G = Gal(ℚ(ζ_{2p})/ℚ) ≅ (ℤ/2pℤ)* acts on the OAM modes of a T(2,p) knotted beam by permutation. The orbits of this action partition the p-1 OAM channels into classes of size dividing φ(2p)/(number of subgroups). A G-invariant error-correcting code on these channels achieves a minimum distance equal to the smallest non-trivial orbit size.

**Test**: For p = 7, compute the Galois group action on the 6 OAM channels and determine the orbit structure. Design a G-invariant code and compute its minimum distance. Compare with the best known classical code of the same parameters.

**Impact**: Would provide a new family of algebraically structured error-correcting codes for OAM-multiplexed optical communication, where the code structure is intrinsically adapted to the topology of the beam.

**Catalog References**: `Bridges/CyclotomicKnotSpectra.lean` (OAM channels, cyclotomic bridge), `Cryptography/BerggrenDiophantineLattice.lean` (Lorentz form, unit circle geometry)

**Proof Strategy**: (1) Explicitly compute the Galois action on roots of Φ_{2p} for small primes. (2) Identify the orbit structure using the Chinese Remainder Theorem. (3) Construct a linear code over GF(p) whose generator matrix is invariant under the Galois action. (4) Bound the minimum distance using the BCH bound adapted to the cyclotomic structure.

**Domain Bridges**: Number Theory (Galois groups) <-> Coding Theory (algebraic codes) <-> Optics (OAM multiplexing) <-> Cryptography (Berggren lattice)

**Lineage**: Builds on OAM channel counting (this cycle) and Berggren lattice structure from the Catalog.

**Ambition**: extension

---

### Direction 5: Spectral Decomposition of Composite Alexander Polynomials

**Conjecture**: For n = p₁^{a₁} · p₂^{a₂} · ⋯ · p_k^{a_k} with all p_i odd primes, the Alexander polynomial A_n of T(2,n) factors as

A_n = ∏_{d | 2n, d ∤ 2, d > 1} Φ_d^{μ(d)}

where μ is a specific multiplicity function determined by the Möbius function on divisors. Each cyclotomic factor Φ_d contributes φ(d) independent spectral channels, and the total channel count satisfies Σ φ(d) = φ(n) = φ(2n).

**Test**: Verify the factorization for n = 9 (= 3²), n = 15 (= 3·5), n = 21 (= 3·7), n = 35 (= 5·7), and n = 45 (= 3²·5). Check that the channel counts sum correctly.

**Impact**: Would provide a complete spectral decomposition theory for all T(2,n) torus knots, not just those with prime n. This enables engineering of composite knotted beams with prescribed multi-channel spectral properties.

**Catalog References**: `Bridges/CyclotomicKnotSpectra.lean` (alexanderT2n, fundamental identity), `Algebra/DihedralCyclotomic/`

**Proof Strategy**: (1) Use the identity X^n + 1 = ∏_{d | 2n, d ∤ n} Φ_d(X) (which holds because X^{2n} - 1 = (X^n - 1)(X^n + 1)). (2) Combined with X + 1 = Φ_2(X), derive A_n = (X^n + 1)/(X + 1) = ∏_{d | 2n, d ∤ n, d ≠ 2} Φ_d(X). (3) Identify which d divide 2n but not n: these are exactly the d where v_2(d) = 1 (i.e., d is divisible by 2 but not by 4, or d is an odd divisor of n multiplied by 2). (4) Verify the channel count identity using the formula X^n + 1 = ∏ Φ_d · (X + 1).

**Domain Bridges**: Number Theory (Möbius function, cyclotomic factorization) <-> Knot Theory (composite knots) <-> Signal Processing (multi-channel decomposition)

**Lineage**: Direct extension of Theorems 1-2 from this cycle.

**Ambition**: extension
