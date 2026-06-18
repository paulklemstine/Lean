# Future Research Directions: Cyclotomic Knot Spectra

## Synthesis

This research cycle established that the Alexander polynomials of T(2,n) torus knots are alternating sum polynomials satisfying the fundamental identity (X+1)·A_n(X) = X^n + 1 for odd n. The identification A_p = Φ_{2p} for prime p creates a precise bridge between cyclotomic number theory and the OAM spectral structure of knotted light beams. The spectral dichotomy theorem provides a complete algebraic classification: palindromic Alexander polynomials with |b| < 2 produce crystalline (unit-circle) spectra, while |b| > 2 gives metallic (real-root) spectra. The composite factorization A_15 = Φ_6 · Φ_{10} · Φ_{30} demonstrates how spectral structure decomposes under connected sums.

The most promising cross-domain connection is between **cyclotomic field theory** and **structured light engineering**: Euler's totient function φ(2n) directly computes the number of independent OAM channels available in a T(2,n) knotted beam. This connects the Catalog's Berggren tree structures (`Cryptography/BerggrenDiophantineLattice.lean`, which formalizes Lorentz forms and Pythagorean vectors on the unit circle) to the OAM mode geometry. The palindromic discriminant theory extends the Mahler measure framework in `Speculative/AutoResearch/MahlerMeasure.lean`.

The direction with highest breakthrough potential is Direction 1 (Jones Polynomial via Temperley-Lieb), because the Jones polynomial is strictly more powerful than the Alexander polynomial and its representation-theoretic structure (through quantum groups at roots of unity) would directly encode the polarization degrees of freedom that the Alexander polynomial misses — potentially doubling the information capacity of knotted light channels.

---

### Direction 1: Jones Polynomial Spectral Theory via the Temperley-Lieb Algebra

**Conjecture**: For a torus knot T(2,n) with n odd prime, the Jones polynomial V_{T(2,n)}(t) evaluated at t = e^{2πi/k} for k dividing 2n determines the polarization multiplicity of the corresponding OAM mode. Specifically, the Jones polynomial of T(2,n) can be written as a ratio of quantum integers [2n]_q / [2]_q, and the roots of the numerator — which are roots of unity of order 4n — give both OAM and polarization mode positions.

**Test**: Compute the Jones polynomial of the trefoil T(2,3) and verify that its roots at 4·3 = 12th roots of unity encode 4 polarization-weighted modes (compared to 2 modes from the Alexander polynomial alone). Verify computationally for T(2,5) and T(2,7).

**Impact**: If true, this doubles the spectral information extractable from knotted beams and connects to the topological quantum computing program (where Jones polynomial evaluation at roots of unity is BQP-complete). The Temperley-Lieb algebra TL_n(δ) would provide the algebraic structure for beam manipulation.

**Catalog References**: `Speculative/Knot/Alternating.lean` (Jones polynomial definitions), `Speculative/Knot/Defs.lean`, `Speculative/Knot/KauffmanBracket.lean`, `Bridges/KnottedLightTopology.lean`

**Proof Strategy**: (1) Formalize the Temperley-Lieb algebra TL_n(δ) in Lean 4 as a quotient of the free algebra on generators e_1,...,e_{n-1} by the relations e_i² = δ·e_i, e_i·e_{i±1}·e_i = e_i, and e_i·e_j = e_j·e_i for |i-j| ≥ 2. (2) Define the Jones polynomial via the Markov trace on TL_n. (3) Prove the closed form for T(2,n). (4) Analyze root structure at roots of unity.

**Domain Bridges**: Knot theory ↔ Quantum computing (Jones polynomial at roots of unity is BQP-complete) ↔ Photonics (polarization structure of knotted beams)

**Lineage**: Builds on the cyclotomic identification theorems (trefoil_is_cyclotomic6, cinquefoil_is_cyclotomic10, t27_is_cyclotomic14) from this cycle and the adequate knot Jones polynomial framework in `Speculative/Knot/Alternating.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Mahler Measure of Alexander Polynomials and Spectral Entropy

**Conjecture**: The logarithmic Mahler measure m(Δ_K) of the Alexander polynomial of a knot K equals the topological entropy of the OAM spectrum: m(Δ_K) = h_top(σ_K), where σ_K is the shift dynamical system on the set of OAM modes weighted by root magnitudes. For knots whose Alexander polynomial is cyclotomic (all roots on unit circle), m(Δ_K) = 0 and the spectrum has zero entropy. For knots like the figure-eight (with real roots off the unit circle), m(Δ_K) > 0 and the spectrum has positive entropy.

**Test**: Compute m(Δ_{4_1}) = log φ ≈ 0.4812 where φ is the golden ratio, and verify this equals the entropy of the golden-ratio shift. Compare with m(Δ_{T(2,3)}) = 0 (trefoil, cyclotomic). Verify computationally for the first 10 knots in the knot table.

**Impact**: If true, this provides a dynamical interpretation of the Mahler measure, connecting it to information-theoretic quantities. It would also provide a computable measure of "spectral complexity" for knotted beams, relevant to OAM-based communication systems.

**Catalog References**: `Speculative/AutoResearch/MahlerMeasure.lean` (positive_logMahler_of_root_outside_unit_circle), `Bridges/KnottedLightTopology.lean`

**Proof Strategy**: (1) Extend the Mahler measure formalization in MahlerMeasure.lean to handle cyclotomic polynomials (prove m(Φ_n) = 0 for all n). (2) Define topological entropy via the growth rate of periodic orbits in the OAM shift system. (3) Prove the equality for palindromic quadratics as a test case, using the explicit formula m(t² + bt + 1) = max(0, log|r|) where r is the larger root.

**Domain Bridges**: Mahler measure (number theory) ↔ Topological entropy (dynamics) ↔ Information capacity (photonics) ↔ Spectral complexity (knot theory)

**Lineage**: Directly extends positive_logMahler_of_root_outside_unit_circle from MahlerMeasure.lean and the spectral dichotomy theorems from this cycle.

**Ambition**: extension

---

### Direction 3: General Torus Knot Cyclotomic Factorization T(p,q)

**Conjecture**: For coprime p, q ≥ 2, the Alexander polynomial of T(p,q) factors over ℚ as:
$$\Delta_{T(p,q)}(t) = \prod_{d | pq,\, d \nmid p,\, d \nmid q} \Phi_d(t)$$
The total degree is (p-1)(q-1)/2 (twice the Seifert genus), and the number of cyclotomic factors is #{d | pq : d ∤ p and d ∤ q}.

**Test**: Verify for T(3,5): the Alexander polynomial should factor as Φ_15 · Φ_5 · Φ_3... actually the correct formula involves Φ_d for d | pq with appropriate conditions. Compute explicitly for T(3,4), T(3,5), T(4,5) and verify against known Alexander polynomials from knot tables.

**Impact**: This would extend our T(2,n) results to all torus knots, providing a complete cyclotomic classification. The Euler totient sum identity Σ φ(d) = n (sum over d|n) would then have a direct knot-theoretic interpretation as a mode-counting formula.

**Catalog References**: `Speculative/AutoResearch/KnotPolynomialSpectra.lean` (alternatingPoly, cyclotomic identification theorems), `Bridges/KnottedLightTopology.lean`

**Proof Strategy**: (1) Define the general torus knot Alexander polynomial Δ_{T(p,q)} = (t^{pq}-1)(t-1)/((t^p-1)(t^q-1)) as a polynomial (prove it actually is polynomial when gcd(p,q)=1). (2) Use the cyclotomic factorization X^n - 1 = ∏_{d|n} Φ_d to decompose numerator and denominator. (3) Cancel common factors. (4) Verify the mode count equals (p-1)(q-1)/2.

**Domain Bridges**: Torus geometry ↔ Cyclotomic fields ↔ OAM spectral engineering

**Lineage**: Generalizes all cyclotomic identification theorems from this cycle (trefoil_is_cyclotomic6, cinquefoil_is_cyclotomic10, t27_is_cyclotomic14, t2_15_cyclotomic_factorization).

**Ambition**: extension

---

### Direction 4: Arithmetic Galois Action on OAM Modes

**Conjecture**: The Galois group Gal(ℚ(ζ_{2n})/ℚ) ≅ (ℤ/2nℤ)× acts naturally on the OAM mode set of a T(2,n) knotted beam, permuting modes according to the multiplication action on roots of unity. For prime n, this action is transitive on the φ(2n) = n-1 modes. For composite n, the orbit structure under Gal reflects the cyclotomic factorization of the Alexander polynomial.

**Test**: For T(2,15), the Galois group (ℤ/30ℤ)× has order φ(30) = 8. The OAM modes (14 total) decompose into three Galois orbits of sizes 2, 4, 8, corresponding to the factors Φ_6, Φ_{10}, Φ_{30}. Verify this orbit structure computationally.

**Impact**: If true, this gives the OAM spectrum a natural arithmetic symmetry group, connecting beam manipulation operations to Galois theory. The Frobenius elements at different primes would correspond to specific mode permutations, potentially useful for multiplexing in OAM-based communication.

**Catalog References**: `Speculative/AutoResearch/KnotPolynomialSpectra.lean`, `Cryptography/BerggrenDiophantineLattice.lean` (Lorentz forms, which involve similar arithmetic structure on the unit circle)

**Proof Strategy**: (1) Formalize the Galois group action on roots of cyclotomic polynomials using Mathlib's Galois theory. (2) Define the OAM mode set as the set of primitive 2d-th roots of unity for d | n. (3) Show the Galois action preserves each cyclotomic orbit. (4) Prove transitivity for prime n using the fact that Gal(ℚ(ζ_{2p})/ℚ) acts transitively on primitive roots.

**Domain Bridges**: Galois theory ↔ Cyclotomic fields ↔ OAM mode symmetry ↔ Photonic multiplexing

**Lineage**: Builds on t2_15_cyclotomic_factorization and the cyclotomic identification theorems.

**Ambition**: grand_challenge

---

### Direction 5: Tropical Alexander Polynomials and Knot Invariants

**Conjecture**: The tropicalization of the Alexander polynomial — obtained by replacing (×, +) with (+, min) — yields a piecewise-linear invariant Δ_K^{trop}(t) whose breakpoints correspond to the crossing structure of the knot. For T(2,n), the tropical Alexander polynomial is a piecewise-linear function with exactly n-1 breakpoints at t = 0, 1, ..., n-2, and the tropical discriminant classifies the spectral dichotomy in the tropical semiring.

**Test**: Compute the tropical Alexander polynomial of the trefoil: trop(X² - X + 1) under the map a·X^k ↦ val(a) + k·t, and verify it has 2 breakpoints. Compare with the figure-eight knot.

**Impact**: This would create a bridge between tropical geometry (already formalized in `Tropical/`) and knot theory, potentially giving combinatorial algorithms for computing knot invariants. The tropical Mahler measure would connect to the spectral entropy direction (Direction 2).

**Catalog References**: `Tropical/TropicalFactoring.lean` (tropical_fundamental_theorem_of_arithmetic), `Speculative/AutoResearch/SpectralTropicalEntropy.lean` (tropical_spectral_entropy_bound), `Bridges/KnottedLightTopology.lean`

**Proof Strategy**: (1) Define the tropicalization functor from ℤ[X] to the tropical semiring Trop[X] using existing Mathlib tropical infrastructure. (2) Compute the tropical Alexander polynomial for T(2,n) explicitly. (3) Prove the breakpoint count equals n-1. (4) Define the tropical discriminant and prove the spectral classification.

**Domain Bridges**: Tropical geometry ↔ Knot theory ↔ Combinatorial optimization ↔ Spectral analysis

**Lineage**: Builds on tropical_fundamental_theorem_of_arithmetic and tropical_spectral_entropy_bound from the Catalog, combined with the Alexander polynomial framework from this cycle.

**Ambition**: extension
