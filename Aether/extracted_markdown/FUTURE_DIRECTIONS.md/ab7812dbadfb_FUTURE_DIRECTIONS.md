# Future Research Directions: Cyclotomic Knot Spectra

## Synthesis

This research cycle established the **cyclotomic bridge**: the Alexander polynomial of the torus knot T(2,p) for odd prime p is identical to the cyclotomic polynomial Φ_{2p}. The proof chain flows through the **fundamental identity** (X+1)·A_n(X) = X^n+1, the **cyclotomic product formula** decomposition of X^{2p}-1, and cancellation in the integral domain ℤ[X]. The **spectral dichotomy** classifies palindromic quadratics into crystalline (unit-circle roots) and metallic (real roots) types via the single integer invariant b²−4. The **OAM channel identity** φ(2n) = φ(n) for odd n connects Euler's totient to information capacity.

The most promising cross-domain connection is between the **cyclotomic Galois structure** and **tropical geometry**: the Galois group Gal(ℚ(ζ_{2p})/ℚ) acts on roots of the Alexander polynomial by permutation, and this action has a natural tropicalization where the roots' arguments (phases) map to points on the tropical circle ℝ/ℤ. This connects to the Catalog's tropical spectral theory (`Tropical/SpectralTheory.lean`) and Berggren shell structures (`Tropical/BerggrenShellMesh.lean`), where unit-circle geometry intersects discrete arithmetic. Direction 1 (Jones polynomial spectral theory) has the highest breakthrough potential because the Jones polynomial encodes strictly more information than Alexander and connects to quantum computation via the Temperley-Lieb algebra.

---

### Direction 1: Jones Polynomial Spectral Theory via Temperley-Lieb Algebra

**Conjecture**: For torus knot T(2,p) with odd prime p, the Jones polynomial V_p(t) evaluated at roots of unity t = ζ_k yields values in the cyclotomic field ℚ(ζ_{2pk}), and the resulting "spectral matrix" S_{i,j} = V_p(ζ_{2p}^i · ζ_k^j) has rank equal to φ(2p) = p-1.

**Test**: Compute the Jones polynomial for T(2,3), T(2,5), T(2,7) using the skein relation, evaluate at ζ_3, ζ_5, ζ_7 respectively, and check whether the spectral matrix rank equals p-1. If the rank is consistently lower, the conjecture's rank prediction is wrong; if higher, the spectral channels are more numerous than predicted.

**Impact**: If true, this extends the cyclotomic bridge from Alexander to Jones polynomials and establishes that the additional quantum information in Jones (beyond Alexander) lives in specific cyclotomic extensions. This would connect knot theory to quantum error correction codes. If false, it reveals that the Jones polynomial breaks the cyclotomic pattern, which is equally informative.

**Catalog References**: `Tropical/SpectralTheory.lean` (cycle_gap_spectral_bound_at), `Cryptography/BerggrenDiophantineLattice.lean` (lorentzForm)

**Proof Strategy**: (1) Define Temperley-Lieb algebra TL_n(δ) in Lean as a quotient of the braid group algebra. (2) Construct the Jones representation ρ: B_n → TL_n. (3) Compute the Markov trace for T(2,p) closures. (4) Show that the Jones polynomial factors through cyclotomic polynomials when evaluated at roots of unity. Key lemma: the Markov trace of a T(2,p) braid closure at t = ζ_k is an algebraic integer in ℚ(ζ_{2pk}).

**Domain Bridges**: Knot topology <-> Quantum algebra (Temperley-Lieb) <-> Cyclotomic number theory <-> Quantum error correction

**Lineage**: Builds on cyclotomic bridge theorem (alexander_eq_cyclotomic_bridge) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Mahler Measure Rigidity and Hyperbolic Volume

**Conjecture**: For any fibered knot K whose Alexander polynomial Δ_K(t) is a product of cyclotomic polynomials, the Mahler measure M(Δ_K) = 1. Conversely, for any hyperbolic fibered knot K, M(Δ_K) > 1, and log M(Δ_K) is commensurable with the hyperbolic volume vol(S³ \ K).

**Test**: Compute M(Δ_K) for the first 50 prime knots in the knot table. Verify M = 1 for all torus knots (which have cyclotomic Alexander polynomials). For hyperbolic knots (4_1, 5_2, 6_1, ...), compute the ratio log M(Δ_K) / vol(S³ \ K) and check if it takes only finitely many rational values.

**Impact**: If true, this establishes Mahler measure as a computable proxy for hyperbolic volume — a major open problem connecting algebraic and geometric knot invariants. The rigidity M = 1 for torus knots (proved in this cycle via A_p = Φ_{2p}) would be the base case of a broader classification. If false, the relationship between Mahler measure and volume is more subtle than commensurability.

**Catalog References**: `Tropical/CyclotomicKnotSpectra.lean` (alexander_eq_cyclotomic_bridge, mahler_measure_cyclotomic_trivial)

**Proof Strategy**: (1) Prove M(Φ_n) = 1 for all cyclotomic polynomials (classical, follows from Kronecker's theorem). (2) Prove that M(f·g) = M(f)·M(g) to extend to products of cyclotomic polynomials. (3) For the hyperbolic direction, formalize the Dehn surgery formula relating vol(S³ \ K) to the A-polynomial and show the connection to Mahler measure via the logarithmic Mahler integral.

**Domain Bridges**: Cyclotomic number theory <-> Hyperbolic geometry <-> Algebraic K-theory (Mahler measure appears in Borel regulators)

**Lineage**: Builds on spectral_dichotomy and alexander_eq_cyclotomic_bridge from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Alexander Polynomial and Newton Polytopes

**Conjecture**: The tropicalization of the Alexander polynomial A_n(X), obtained by replacing (×, +) with (+, min), yields a piecewise-linear function whose breakpoints are exactly at the integers 0, 1, 2, ..., n-1 with slopes alternating between +1 and -1. The resulting tropical curve is the tropical torus knot T_trop(2,n).

**Test**: Compute trop(A_n) for n = 3, 5, 7, 9, 11 by taking val(coeff_i) = 0 for all i (since all coefficients are ±1). The Newton polygon is the interval [0, n-1] with all lattice points occupied. Check that the tropical intersection number of trop(A_n) with the tropical line {y = 0} equals n-1 (the number of breakpoints).

**Impact**: If true, this provides a combinatorial (tropical) model of torus knot invariants that is purely piecewise-linear and hence amenable to computation and visualization without complex arithmetic. It would connect the Alexander polynomial to the Catalog's tropical geometry framework. If false, the tropicalization loses essential information about the knot.

**Catalog References**: `Tropical/SpectralTheory.lean`, `Tropical/TropicalFactoring.lean` (tropical_fundamental_theorem_of_arithmetic), `Tropical/MaxPlusLightCone.lean`

**Proof Strategy**: (1) Define the tropicalization map on ℤ[X] → TropicalPoly. (2) Show that for polynomials with all coefficients ±1 over ℤ, the tropicalization has valuation 0 at every term. (3) Prove that the tropical version of the fundamental identity becomes min(0, x) + trop(A_n)(x) = min(0, n·x), a piecewise-linear identity. (4) Count breakpoints using the change-of-slope formula.

**Domain Bridges**: Cyclotomic knot theory <-> Tropical geometry <-> Combinatorial optimization (min-plus algebra)

**Lineage**: Builds on alexanderTorusPoly definition and alexander_coeff theorem from this cycle. Connects to tropical_fundamental_theorem in the Catalog.

**Ambition**: extension

---

### Direction 4: Galois-Theoretic OAM Error Correction

**Conjecture**: The Galois group G = Gal(ℚ(ζ_{2p})/ℚ) ≅ (ℤ/2pℤ)* acts on OAM modes {e^{2πik/(2p)} : gcd(k,2p) = 1} by σ_a(ζ) = ζ^a. A linear code C ⊆ 𝔽_p^{p-1} constructed from the Galois orbits has minimum distance d ≥ (p-1)/2 and rate R = 1/2, achieving the Singleton bound asymptotically.

**Test**: For p = 5, 7, 11, 13, construct the Galois orbit code explicitly. Compute its minimum distance and compare to (p-1)/2. If for any p the minimum distance falls below (p-1)/2, the conjecture is false.

**Impact**: If true, this provides a new family of algebraic error-correcting codes with guaranteed distance properties derived from number theory, applicable to OAM-multiplexed optical communication. The codes would be "natural" in the sense that their structure comes from the same mathematics as the physical system they protect. If false, Galois symmetry alone is insufficient for good codes, and additional structure (e.g., from the Berggren tree) is needed.

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean` (lorentzForm), `Cryptography/BerggrenFingerprintRigidity.lean` (berggrenGen), `Tropical/CyclotomicKnotSpectra.lean` (totient_double_odd)

**Proof Strategy**: (1) Formalize the Galois group of ℚ(ζ_{2p}) as (ℤ/2pℤ)*. (2) Define Galois orbit codes. (3) Prove distance bounds using the fact that Galois automorphisms permute roots of cyclotomic polynomials. (4) Connect to the OAM channel count φ(2p) = φ(p) = p-1 from this cycle.

**Domain Bridges**: Cyclotomic number theory <-> Coding theory <-> Optical engineering <-> Cryptography (Berggren lattice)

**Lineage**: Builds on totient_double_odd and the CyclotomicKnotSpectrum structure from this cycle.

**Ambition**: extension

---

### Direction 5: Spectral Dichotomy for General Reciprocal Polynomials

**Conjecture**: For any monic reciprocal polynomial f(X) of degree 2d (i.e., f(X) = X^{2d} f(1/X)) over ℤ, the substitution Y = X + 1/X reduces f to a polynomial g(Y) of degree d, and the spectral class of f (whether all roots lie on the unit circle) is determined by whether all roots of g lie in [-2, 2]. The number of reciprocal polynomials of degree 2d with all roots on the unit circle is exactly the number of monic integer polynomials of degree d with all roots in [-2, 2], which equals the d-th Catalan number for the "totally positive" case.

**Test**: Enumerate all monic reciprocal polynomials of degree 4 (d=2) with integer coefficients in [-5,5]. For each, compute roots numerically and check unit circle membership. Count those with all roots on the unit circle and compare to the prediction. The Catalan number C_2 = 2, but this count may be larger since the Catalan prediction is for the "totally positive" subclass.

**Impact**: If true, this extends the spectral dichotomy from quadratics to arbitrary even-degree palindromes, providing a complete classification of Alexander polynomial root geometry for all torus knots. The Catalan number connection would be surprising and deep. If false (likely the Catalan part), the actual count provides information about the density of cyclotomic-type behavior among palindromic polynomials.

**Catalog References**: `Tropical/CyclotomicKnotSpectra.lean` (spectral_dichotomy, SpectralClass), `Algebra/Advanced.lean`

**Proof Strategy**: (1) Formalize the substitution Y = X + X⁻¹ for reciprocal polynomials. (2) Prove the equivalence: X on unit circle ↔ Y ∈ [-2,2]. (3) Show that g(Y) has integer coefficients when f(X) does. (4) Count totally real polynomials with roots in [-2,2] using lattice point enumeration in the coefficient space. (5) Attempt to connect the count to Catalan numbers via a bijection with Dyck paths or binary trees.

**Domain Bridges**: Spectral theory <-> Algebraic number theory (totally real fields) <-> Combinatorics (Catalan structures) <-> Knot theory (palindromic Alexander polynomials)

**Lineage**: Builds on spectral_dichotomy and palindromic_alexander from this cycle.

**Ambition**: extension
