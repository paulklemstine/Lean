# Future Directions: Artin's Conjecture on Primitive Roots

## Synthesis

This research cycle established a rigorous structural theory of primitive roots in finite fields, formalizing the Order-GCD Duality (ord(g^k) = (p-1)/gcd(p-1,k)), the Coprimality Characterization (g^k is primitive root iff gcd(k,p-1) = 1), the Product Identity (product of all primitive roots is 1 for p ≥ 5), and the connection between primitive roots and quadratic non-residuosity. These results provide the algebraic backbone for Artin's conjecture — every step from defining the sieve weight w(p) = φ(p-1)/(p-1) to counting solutions of x^d = 1 in cyclic groups feeds into the analytic framework that Hooley used conditionally and Heath-Brown exploited unconditionally.

The most promising cross-domain connection is between the Artin sieve weight framework and the tropical sieve theory already present in the Catalog (`Tropical/TropicalSieveTheory.lean`). The sieve weight w(p) = φ(p-1)/(p-1) has a natural tropical interpretation: it measures the "defect" of the factorization of p-1 from being a prime power. If we can formalize how this defect interacts with the tropical valuation framework, we may obtain new lower bounds on the Artin counting function without GRH.

The highest breakthrough potential lies in Direction 1 (Heath-Brown Triple Separation), because unlike Artin's full conjecture, it asks a *finite* question about which of {2, 3, 5} dominates, potentially admitting a computational proof strategy combined with structural arguments. The Catalog's `Algebra/ArtinConjecture.lean` already defines the `ArtinTriple` structure and `heathBrownStatement`, providing direct starting points.

---

### Direction 1: Heath-Brown Triple Separation via Sieve Weights

**Conjecture**: Among {2, 3, 5}, the integer 2 has the largest Artin counting function π_a(x) for all sufficiently large x. Specifically, for all x ≥ 10^4, π₂(x) ≥ π₃(x) and π₂(x) ≥ π₅(x).

**Test**: Compute π_a(x) for a ∈ {2, 3, 5} up to x = 10^7 and verify the dominance of a = 2. Check whether the ratios π₂(x)/π₃(x) and π₂(x)/π₅(x) stabilize above 1.

**Impact**: If true, this would refine Heath-Brown's qualitative result (at least one of {2, 3, 5} is a primitive root infinitely often) into a quantitative prediction about *which* one dominates. A formal proof would require extending the sieve weight analysis to compare the correction factors in the Artin constant for different values of a.

**Catalog References**: `Algebra/ArtinConjecture.lean` (ArtinTriple, heathBrownStatement), `Algebra/ArtinDeepStructure.lean` (artinCountingFunction, artinSieveWeight)

**Proof Strategy**: 
1. Formalize the correction factor δ(a) that modifies the Artin constant for non-square-free a.
2. Show that δ(2), δ(3), δ(5) are all equal to 1 (since 2, 3, 5 are square-free primes), so the densities should be equal under GRH — making dominance a lower-order effect.
3. Analyze the second-order term in the asymptotic expansion of π_a(x) to identify which a wins.
4. Use computational verification to support the conjecture up to large bounds.

**Domain Bridges**: Number Theory (Artin conjecture) <-> Analytic Number Theory (sieve methods) <-> Computation (prime counting algorithms)

**Lineage**: Builds on this cycle's artinCountingFunction, artinSieveWeight, and the ArtinTriple structure from the Catalog.

**Ambition**: extension

---

### Direction 2: Unconditional Lower Bound on π_a(x) via Bombieri-Vinogradov

**Conjecture**: For a = 2 (or any fixed Artin candidate), there exists an unconditional lower bound π₂(x) ≥ x^{1/2} / (log x)^2 for sufficiently large x. More ambitiously, π₂(x) ≥ x / (log x)^3.

**Test**: Verify computationally for x up to 10^8 that π₂(x) exceeds these bounds. Plot π₂(x) · (log x)^2 / x^{1/2} and check whether it grows.

**Impact**: Any unconditional lower bound growing faster than (log x)^C would prove Artin's conjecture for a = 2. Even a weak bound of x^ε would be a major breakthrough. The Bombieri-Vinogradov theorem provides "GRH on average" and is the natural tool for unconditional results.

**Catalog References**: `Algebra/ArtinDeepStructure.lean` (artinCountingFunction_mono, order_of_power_eq), `Tropical/TropicalSieveTheory.lean` (eventual_lower_bound_gives_infinitely_many)

**Proof Strategy**:
1. Formalize the connection between π_a(x) and character sums: π_a(x) relates to sums over characters of (ℤ/qℤ)× for varying q.
2. Apply a formal version of the Bombieri-Vinogradov theorem (or establish the key estimate) to bound these character sums on average.
3. The main lemma needed: for most primes q < x^{1/2-ε}, the proportion of primes p ≤ x with p ≡ 1 (mod q) and a is a primitive root mod p is close to its expected value.
4. Sum over q to obtain the lower bound on π_a(x).

**Domain Bridges**: Number Theory (primitive roots) <-> Analytic Number Theory (Bombieri-Vinogradov) <-> Algebra (character theory)

**Lineage**: Extends the counting function framework from this cycle. The monotonicity result (artinCountingFunction_mono) is a prerequisite.

**Ambition**: grand_challenge

---

### Direction 3: Carmichael Lambda Function and Primitive Roots Modulo Prime Powers

**Conjecture**: For any prime p ≥ 3 and any primitive root g modulo p, either g or g + p is a primitive root modulo p² (and hence modulo all p^k). Formally: if ord_p(g) = p - 1, then ord_{p²}(g) = p(p-1) or ord_{p²}(g+p) = p(p-1).

**Test**: For each prime p < 1000 and its smallest primitive root g, compute g^{p-1} mod p² and check whether it equals 1. If g^{p-1} ≡ 1 (mod p²), verify that (g+p)^{p-1} ≢ 1 (mod p²).

**Impact**: This "lifting" result is classical (attributed to various authors) but has never been machine-verified. It connects to the Carmichael lambda function λ(p^k) = p^{k-1}(p-1) and to Wieferich primes (primes p where 2^{p-1} ≡ 1 mod p²). A formalization would bridge the gap between our mod-p results and the full Artin conjecture for prime power moduli.

**Catalog References**: `Algebra/ArtinDeepStructure.lean` (primroot_test', order_of_power_eq), `Algebra/ArtinConjecture.lean` (safe_prime_order_options)

**Proof Strategy**:
1. Formalize ZMod (p^2) and the canonical surjection ZMod (p^2) → ZMod p.
2. Show that if g has order p-1 mod p, then g has order p-1 or p(p-1) mod p².
3. The lifting criterion: ord_{p²}(g) = p(p-1) iff g^{p-1} ≢ 1 (mod p²).
4. Prove that if g^{p-1} ≡ 1 (mod p²), then (g+p)^{p-1} ≢ 1 (mod p²) using the binomial theorem modulo p².

**Domain Bridges**: Algebra (ZMod, cyclic groups) <-> Number Theory (Hensel lifting, Wieferich primes) <-> Cryptography (discrete logarithm over Z/p^kZ)

**Lineage**: Directly extends the primitive root theory from this cycle to higher prime powers.

**Ambition**: extension

---

### Direction 4: Tropical Artin Sieve — Connecting Sieve Weights to Tropical Geometry

**Conjecture**: The Artin sieve weight w(p) = φ(p-1)/(p-1) can be expressed as a tropical rational function in the prime factorization of p-1. Specifically, if p - 1 = ∏ qᵢ^{aᵢ}, then w(p) = ∏(1 - 1/qᵢ), which in the tropical semiring corresponds to min_i(v_{qᵢ}(p-1)) where v_q is the q-adic valuation.

**Test**: Formalize the product formula w(p) = ∏_{q|p-1} (1 - 1/q) and verify it matches the direct computation of φ(p-1)/(p-1) for all primes p < 10000. Then express the Artin constant C = ∏_q (1 - 1/(q(q-1))) as a "tropical product" and check whether the resulting tropical sieve captures the correct density.

**Impact**: If the tropical framework provides a natural language for sieve weights, it could open a new avenue for proving unconditional density results. The tropical perspective naturally handles the multiplicative structure of p-1, which is the central difficulty in Artin's conjecture.

**Catalog References**: `Tropical/TropicalSieveTheory.lean` (eventual_lower_bound_gives_infinitely_many), `Algebra/ArtinDeepStructure.lean` (artinSieveWeight, artinSieveWeight_mem_Icc)

**Proof Strategy**:
1. Formalize the product formula for Euler's totient: φ(n)/n = ∏_{q|n} (1 - 1/q).
2. Express this in the tropical semiring framework from `TropicalSieveTheory.lean`.
3. Define a "tropical Artin weight" and show it equals the classical sieve weight.
4. Investigate whether tropical convexity gives natural bounds on the average sieve weight.

**Domain Bridges**: Number Theory (Artin sieve) <-> Tropical Geometry (tropical semirings, valuations) <-> Algebra (Euler's totient product formula)

**Lineage**: Bridges this cycle's Artin sieve framework with the existing tropical sieve theory in the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Primitive Root Distribution in Arithmetic Progressions

**Conjecture**: For any Artin candidate a and any modulus m coprime to a, the primes p for which a is a primitive root are equidistributed among the residue classes modulo m that are compatible (i.e., classes r mod m where there exists a prime p ≡ r mod m with a a primitive root mod p). Specifically, for each admissible class r, the density of {p ≡ r (mod m) : a is a primitive root mod p} equals C_a / φ(m) where C_a is the Artin constant for a.

**Test**: For a = 2 and m = 4, compute the proportion of Artin primes (primes where 2 is a primitive root) in each class mod 4. The conjecture predicts equal distribution between p ≡ 1 (mod 4) and p ≡ 3 (mod 4). Verify for primes up to 10^6.

**Impact**: Equidistribution of Artin primes in progressions would have applications to cryptographic prime generation (finding primes p where a given base is a primitive root, with additional congruence constraints). It would also connect to the Chebotarev density theorem and its relationship to Artin's conjecture via Galois representations.

**Catalog References**: `Algebra/ArtinDeepStructure.lean` (artinCountingFunction, power_is_primroot_iff_coprime), `MachineLearning/PrimeGapFramework.lean` (infinitely_many_primes_with_gap_le_self)

**Proof Strategy**:
1. Formalize the splitting behavior of the Artin primes in arithmetic progressions.
2. Connect to the Chebotarev density theorem: the density of primes splitting in a given way in the extension ℚ(ζ_n, a^{1/n})/ℚ is determined by the Frobenius distribution.
3. Show that the additional congruence constraint p ≡ r (mod m) is asymptotically independent of the primitive root condition (under GRH).
4. Establish the quantitative equidistribution result.

**Domain Bridges**: Number Theory (Artin conjecture) <-> Algebraic Number Theory (Chebotarev, Frobenius) <-> Cryptography (constrained prime generation)

**Lineage**: Extends the density framework from this cycle to arithmetic progressions.

**Ambition**: extension
