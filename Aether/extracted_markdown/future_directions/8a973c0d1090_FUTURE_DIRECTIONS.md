# Future Research Directions: Cyclotomic-Alexander Bridge Extensions

## Synthesis

This research cycle deepened the cyclotomic bridge between Alexander polynomials of torus knots T(2,p) and cyclotomic polynomials Φ_{2p}. The **negation bridge** Φ_{2p}(X) = Φ_p(−X) revealed the structural origin of the correspondence: the alternating signs in the Alexander polynomial correspond exactly to the composition of the prime cyclotomic polynomial with the negation map X ↦ −X. This identity enabled an **irreducibility transfer** from cyclotomic number theory to knot theory, proving that Alexander polynomials of T(2,p) are algebraically prime. The **cyclotomic product decomposition** X^n + 1 = ∏_{d|n} Φ_{2d} for odd n generalized the bridge from prime to composite parameters, revealing the divisor lattice as the organizing principle for knot invariant factorization.

The most promising cross-domain connection is between the **Galois-knot bridge** and the existing spectral dichotomy from the Catalog (`Bridges/KnottedLightTopology.lean`). The Galois group Gal(ℚ(ζ_{2p})/ℚ) acts transitively on roots of the Alexander polynomial (all primitive 2p-th roots of unity on the unit circle — crystalline spectrum), and this group's cyclic structure of order p−1 encodes both the knot's topological complexity (Seifert genus = (p−1)/2) and the cyclotomic field's arithmetic. The product decomposition suggests that the **divisor lattice** itself may have a categorical interpretation connecting to the Catalog's tropical geometry (`Tropical/SpectralTheory.lean`) and matroid structures (`Pythagorean/ValuatedMatroidExchange.lean`). Direction 2 (higher torus knots T(m,n)) has the highest breakthrough potential because it would extend the bridge from a special family to the full torus knot spectrum, requiring genuinely new algebraic machinery.

---

### Direction 1: Negation Bridge for Composite Odd Numbers

**Conjecture**: For all odd n > 1, Φ_{2n}(X) = Φ_n(−X). This generalizes our prime-case result to arbitrary odd composite n, requiring a proof that doesn't use the explicit formula Φ_p = Σ X^i (which holds only for primes).

**Test**: Verify computationally for n = 9, 15, 21, 25, 35. Then attempt a proof using the product formula ∏_{d|m} Φ_d = X^m − 1 and the divisor partition of 2n for odd n. The key step is showing that the map d ↦ 2d on divisors of n is compatible with the Möbius inversion that defines cyclotomic polynomials.

**Impact**: If true, this would fully generalize the cyclotomic-Alexander bridge to all torus knots T(2,n) with odd n, not just those with prime n. It would show that the alternating Alexander polynomial equals a cyclotomic polynomial for every odd twist count, connecting divisor lattice structure to knot topology.

**Catalog References**: `Tropical/CyclotomicKnotSpectra.lean` (cyclotomic_torus_knot_identity), `Pythagorean/CyclotomicAlexanderBridge.lean` (cyclotomic_negation_bridge)

**Proof Strategy**: Use the Möbius inversion formula: Φ_n(X) = ∏_{d|n} (X^d − 1)^{μ(n/d)}. Then Φ_n(−X) = ∏_{d|n} ((−X)^d − 1)^{μ(n/d)}. For odd d, (−X)^d = −X^d, so (−X)^d − 1 = −(X^d + 1). Track the sign through the product using the fact that Σ_{d|n} μ(n/d) = 0 for n > 1.

**Domain Bridges**: Number theory (Möbius function) ↔ Knot theory (Alexander polynomial) ↔ Combinatorics (divisor lattice)

**Lineage**: Extends cyclotomic_negation_bridge from this cycle.

**Ambition**: extension

---

### Direction 2: Higher Torus Knots T(m,n) and Multivariable Cyclotomic Polynomials

**Conjecture**: For coprime m, n with mn odd, the Alexander polynomial of T(m,n) factors as a product of cyclotomic polynomials Φ_d where d divides mn but not m or n individually. Specifically:
```
Δ_{T(m,n)}(t) = ∏_{d | mn, d ∤ m, d ∤ n} Φ_d(t) · (some correction factor)
```
The Alexander polynomial of T(m,n) is known to be (t^{mn} − 1)(t − 1) / ((t^m − 1)(t^n − 1)). The cyclotomic decomposition of this rational expression should yield a precise product of cyclotomic polynomials.

**Test**: Compute Δ_{T(3,5)} = (t^{15}−1)(t−1)/((t^3−1)(t^5−1)) and verify it equals ∏_{d|15, d∤3, d∤5} Φ_d = Φ_{15}. Check T(3,7), T(5,7) similarly. Formalize the general identity.

**Impact**: This would extend the cyclotomic bridge from the one-parameter family T(2,p) to the full two-parameter family T(m,n), vastly expanding the connection between knot theory and cyclotomic number theory. The irreducibility transfer would generalize: when is Δ_{T(m,n)} irreducible? Exactly when mn has at most two distinct prime factors (so the product has a single cyclotomic factor).

**Catalog References**: `Tropical/CyclotomicKnotSpectra.lean`, `Pythagorean/CyclotomicAlexanderBridge.lean` (cyclotomic_product_Xn_plus_one)

**Proof Strategy**: Express (t^{mn}−1)(t−1)/((t^m−1)(t^n−1)) = ∏_{d|mn} Φ_d · Φ_1 / (∏_{d|m} Φ_d · ∏_{d|n} Φ_d). Use inclusion-exclusion on divisor sets: {d : d|mn} = {d : d|m} ∪ {d : d|n} ∪ {d : d|mn, d∤m, d∤n} with {d:d|m} ∩ {d:d|n} = {d:d|gcd(m,n)} = {1} when gcd(m,n)=1.

**Domain Bridges**: Knot theory (torus knots) ↔ Number theory (cyclotomic polynomials) ↔ Algebra (polynomial rings) ↔ Combinatorics (inclusion-exclusion on divisor lattices)

**Lineage**: Generalizes all results from this cycle from T(2,p) to T(m,n).

**Ambition**: grand_challenge

---

### Direction 3: Tropical Degeneration of the Alexander Spectrum

**Conjecture**: The tropical Alexander polynomial, obtained by applying the valuation map ℤ[X] → 𝕋[X] (where 𝕋 = (ℝ ∪ {∞}, min, +) is the tropical semiring), has Newton polygon whose slopes encode the "tropical genus" — the number of lattice points below the polygon — and this equals the Seifert genus (p−1)/2 for T(2,p).

**Test**: Compute the tropical polynomial trop(alexanderPoly(p)) = min(0, v(−1)+x, 0+2x, ...) where v is the p-adic valuation. The coefficients of alexanderPoly are all ±1, so v(a_i) = 0 for all i. The tropical polynomial is min(0, x, 2x, ..., (p−1)x) = min_{i=0}^{p-1} ix. The Newton polygon is the segment from (0,0) to (p−1, 0), which is flat. This means the tropical degeneration is trivial for T(2,p) — all coefficients have the same valuation.

**Impact**: If the tropical degeneration is trivial (as the test suggests), this is an informative *negative* result: it shows that the cyclotomic bridge does not survive tropicalization, meaning the connection between knot theory and number theory is fundamentally a phenomenon of the "classical" (non-tropical) world. This would establish a boundary for the Catalog's tropical theory.

**Catalog References**: `Tropical/SpectralTheory.lean`, `Pythagorean/ValuatedMatroidExchange.lean` (tropical_descent_chain_bound), `Pythagorean/CyclotomicAlexanderBridge.lean`

**Proof Strategy**: Compute tropical valuations of Alexander polynomial coefficients (all zero for ±1 coefficients), show the Newton polygon is degenerate, prove the tropical genus is zero while the classical genus is (p−1)/2.

**Domain Bridges**: Tropical geometry ↔ Knot theory ↔ Number theory (p-adic valuations)

**Lineage**: Connects this cycle's results to the Catalog's tropical infrastructure.

**Ambition**: extension

---

### Direction 4: Knot L-Functions and Cyclotomic Zeta Values

**Conjecture**: Define the "knot zeta function" ζ_K(s) = ∏_p (1 − Δ_K(p^{−s}))^{−1} where the product runs over primes and Δ_K is the Alexander polynomial. For K = T(2,p) with odd prime p, ζ_K(s) = ∏_q L(s, χ_q) where the product is over certain Dirichlet characters χ_q modulo 2p. The special value ζ_K(1) relates to the knot's hyperbolic volume or Reidemeister torsion.

**Test**: Compute ζ_{T(2,3)}(s) = ∏_q (1 − (q² − q + 1)q^{−s})^{−1}. Check whether this factorizes as a product of Dirichlet L-functions. Compare with known values of L(1, χ) for characters modulo 6.

**Impact**: If the knot zeta function equals a product of Dirichlet L-functions, this would be a precise analogue of the Dedekind zeta function factoring as a product of L-functions. It would bring knot theory into the Langlands program framework, connecting to automorphic forms and reciprocity laws.

**Catalog References**: `Algebra/CyclotomicGaloisGroup.lean` (prime_cyclotomic_galois_group_cyclic), `Pythagorean/CyclotomicAlexanderBridge.lean` (alexander_irreducible)

**Proof Strategy**: Use the factorization of the Alexander polynomial via the cyclotomic bridge, combined with the product formula for Dedekind zeta functions of cyclotomic fields. The key insight is that Φ_{2p}(p^{−s}) factors over characters of (ℤ/2pℤ)*.

**Domain Bridges**: Knot theory ↔ Analytic number theory (L-functions) ↔ Representation theory (Dirichlet characters)

**Lineage**: Extends the Galois-knot bridge from this cycle into the analytic domain.

**Ambition**: grand_challenge

---

### Direction 5: Spectral Dichotomy for Higher-Degree Palindromic Polynomials

**Conjecture**: For a palindromic polynomial P(X) = X^{2g} + a_1 X^{2g-1} + ⋯ + a_1 X + 1 of degree 2g, the substitution Y = X + 1/X reduces P to a polynomial Q(Y) of degree g. The roots of P lie on the unit circle if and only if all roots of Q lie in [−2, 2]. For Alexander polynomials of T(2,p) (which are palindromic of degree p−1), all roots lie on the unit circle (crystalline spectrum) because they are roots of unity.

**Test**: For g=2 (the cinquefoil, p=5): P = X⁴−X³+X²−X+1, Q(Y) = Y²−Y−1. The roots of Q are (1±√5)/2. Since |(1+√5)/2| = 1.618 < 2 and |(1−√5)/2| = 0.618 < 2, all roots of Q are in [−2,2], confirming crystalline spectrum.

**Impact**: Extends the spectral dichotomy from quadratics (in the Catalog) to arbitrary even degree. Provides a complete criterion for when a palindromic Alexander polynomial has all roots on the unit circle — the key property for a knot to be "fibered."

**Catalog References**: `Bridges/KnottedLightTopology.lean` (palindromic_complex_roots_on_unit_circle, spectral_dichotomy_crystalline)

**Proof Strategy**: The Y = X + 1/X substitution is classical. For the real-analysis part, use the fact that |X| = 1 iff X + 1/X ∈ [−2, 2] (since X = e^{iθ} gives Y = 2cos θ). For the formalization, define the companion polynomial Q and prove the equivalence between roots of P on the unit circle and roots of Q in [−2,2].

**Domain Bridges**: Complex analysis (unit circle) ↔ Real analysis (bounded intervals) ↔ Knot theory (fibered knots) ↔ Number theory (cyclotomic roots)

**Lineage**: Extends the spectral dichotomy from the Catalog's quadratic case to the general palindromic case.

**Ambition**: extension
