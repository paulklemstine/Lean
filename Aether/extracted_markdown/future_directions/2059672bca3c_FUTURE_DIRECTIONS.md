# Future Directions: Additive Prime Decomposition Framework

## Synthesis

The five directions below form an ascending hierarchy of ambition, unified by a single architectural principle: **certified additive decomposition as composable infrastructure**. Directions 1–2 extend the current framework horizontally (larger ranges, richer certificate formats). Direction 3 bridges vertically to analytic number theory via discrete Fourier analysis. Directions 4–5 are grand challenges that, if achieved, would represent fundamental advances in formal mathematics — the first machine-verified asymptotic density theorem for prime representations, and a formal proof of a weakened Goldbach statement from Vinogradov's theorem.

Each direction builds on specific formally verified theorems from this cycle, and each is falsifiable by explicit computation or formal experiment.

---

## Direction 1: Sparse Certificate Compression and Optimal Covering Sets

**Conjecture:** For sufficiently large N, there exists a set S of primes with |S| = O(√N / log N) such that every even n ∈ [4, N] can be written as p + q with p ∈ S and q prime.

**Test:** For N = 10⁶, construct the greedy covering set S (iteratively add the prime that covers the most uncovered evens). Measure |S| and compare against √N / log N ≈ 72. If |S| ≤ 100, the conjecture is consistent; if |S| > 200, it is likely false.

**Impact:** If true, this reduces certificate size from O(N) to O(√N / log N), enabling verification of dramatically larger ranges. It would also reveal structural rigidity in the Goldbach graph (a small vertex set dominates all edge sums).

**Catalog References:**
- `Algebra/Goldbach/Defs.lean`: `AdditiveBasisCertificate`, `goldbachPairsUpTo`
- `Algebra/Goldbach/Theorems.lean`: `certificate_implies_GoldbachUpTo`, `goldbach_graph_cover_iff`

**Proof Strategy:** Use the graph cover equivalence to formalize covering set properties. Prove that if S covers [4, N], then the certificate restricted to S-pairs is sound. The size bound likely requires probabilistic arguments (Lovász Local Lemma or second moment method on random prime subsets).

**Domain Bridges:** Combinatorial optimization (set cover), probabilistic combinatorics (Lovász Local Lemma), graph theory (dominating sets).

**Lineage:** Extends `goldbach_graph_cover_iff` and `certificate_implies_GoldbachUpTo` from the current cycle.

**Ambition:** ★★★☆☆ (Extension — requires nontrivial combinatorics but uses existing infrastructure)

---

## Direction 2: Least Witness Prime Bound — Toward a Formal Cramér-Granville Prediction

**Conjecture:** For all even n ≥ 4, the least prime p such that n − p is also prime satisfies p ≤ C · (log n)² for an absolute constant C ≤ 10.

**Test:** Compute leastGoldbachPrime(n) for all even n ∈ [4, 10⁸]. Plot p / (log n)² and determine whether the supremum stabilizes. A single n with p > 10 · (log n)² disproves the conjecture with C = 10. A weaker test: verify p ≤ 1000 for all even n ≤ 10⁷ (computationally, ~20 minutes).

**Impact:** This connects Goldbach verification to the Cramér-Granville conjecture on prime gaps. If the least witness prime is always small, it means Goldbach decompositions are not just plentiful but *efficiently findable* — the search algorithm `findGoldbachPair` terminates in O(polylog(n)) steps. This has implications for the complexity of Goldbach witness verification.

**Catalog References:**
- `Algebra/Goldbach/Defs.lean`: `findGoldbachPair`, `leastGoldbachPrime`
- `Algebra/Goldbach/Theorems.lean`: `findGoldbachPair_sound`

**Proof Strategy:** A formal proof would require estimates on primes in short intervals (Bertrand-type bounds, or Heath-Brown's theorem on primes in short intervals). The framework's `findGoldbachPair_sound` theorem ensures that any computational bound on the least witness prime transfers automatically to a bound on algorithm runtime.

**Domain Bridges:** Analytic number theory (prime gaps, zero-free regions), computational complexity (search algorithm analysis), probability theory (random models for primes).

**Lineage:** Extends `findGoldbachPair_sound` from the current cycle. Connects to Cramér's random model for primes.

**Ambition:** ★★★☆☆ (Extension — computationally testable, analytically deep)

---

## Direction 3: Discrete Circle Method via Finite Fourier Analysis

**Conjecture:** The Goldbach representation count r(n) can be expressed as a finite Fourier transform over roots of unity of order n, and the "major arc" contribution (from rational approximants with small denominators) accounts for ≥ 99% of r(n) for n ≥ 10⁴.

**Test:** For n = 10⁴, compute:
1. The exact representation count r(n) by exhaustive search.
2. The finite Fourier sum S(n) = Σ_{k=0}^{n-1} |Σ_{p prime, p≤n} e^{2πikp/n}|² · e^{-2πikn/n}.
3. The "major arc" partial sum restricting k to values where k/n is close to a rational with denominator ≤ √n.
Verify that the major arc contribution is ≥ 0.99 · r(n).

**Impact:** This would create the first formally verifiable discrete analogue of the Hardy-Littlewood circle method. Unlike the continuous circle method (which requires contour integration and analytic estimates), the discrete version operates on finite sums and is in principle fully computable and formalizable.

**Catalog References:**
- `Algebra/Goldbach/Defs.lean`: `TwoPrimeRepresentable`, `goldbachPairsUpTo`
- `Algebra/Goldbach/Theorems.lean`: `goldbach_graph_cover_iff`

**Proof Strategy:** Define discrete exponential sums in Lean (using Mathlib's `Complex.exp` and `Finset.sum`). Prove the Fourier inversion identity r(n) = (1/n) Σ_k |S_P(k/n)|² ω^{-kn} where S_P is the prime exponential sum. Then define "major" and "minor" arcs as subsets of [0, n) based on rational approximation quality.

**Domain Bridges:** Harmonic analysis (Fourier transforms), analytic number theory (circle method), signal processing (spectral decomposition), computational algebra.

**Lineage:** Builds on the convolution identity for goldbachCount (established in Catalog/MachineLearning/Goldbach/Advanced.lean) and the graph cover equivalence from the current cycle.

**Ambition:** ★★★★☆ (Grand challenge — formalizing discrete circle method is unprecedented)

---

## Direction 4: Formal Asymptotic Density of Goldbach Representations

**Conjecture:** For even n → ∞, the representation count r(n) satisfies r(n) ~ 2C₂ · S(n) · n / (ln n)², where C₂ is the twin prime constant and S(n) is the singular series.

**Test:** Compute r(n) and the Hardy-Littlewood prediction for all even n ∈ [10⁴, 10⁶]. Fit the ratio r(n) / HL(n) and verify it converges to 1.0 ± 0.01 for n > 10⁵. Any systematic deviation > 5% for large n would challenge the conjecture.

**Impact:** This would be the first formally verified asymptotic density theorem for a non-trivial additive representation problem. It would require formalizing: the Prime Number Theorem in Mathlib, Mertens' theorems, and the singular series for the Goldbach problem. Each of these is a major formalization milestone in its own right.

**Catalog References:**
- `Algebra/Goldbach/Defs.lean`: `TwoPrimeRepresentable`
- `Algebra/Goldbach/Theorems.lean`: all parity theorems (for the singular series at p = 2)
- Catalog/MachineLearning/Goldbach/Advanced.lean: `goldbachCount_eq_convolution`

**Proof Strategy:** The singular series S(n) is a product over primes p of local factors encoding the density of representations mod p. The parity obstruction theorems from the current cycle compute the factor at p = 2 exactly. Remaining factors require character sum estimates. The Prime Number Theorem (available in Mathlib as `Nat.Prime.counting_asymptotics` or similar) provides the baseline density.

**Domain Bridges:** Analytic number theory, complex analysis (L-functions), probability theory (probabilistic models for primes), formal analysis (Mathlib's measure theory and asymptotics).

**Lineage:** Extends the parity obstruction layer and representation counting from the current cycle toward genuine asymptotic analysis.

**Ambition:** ★★★★★ (Grand challenge — would represent a landmark in formal mathematics)

---

## Direction 5: Ternary Goldbach from Vinogradov via Formal Analysis

**Conjecture:** Using the current framework's binary-to-ternary transfer, combined with a formal verification of GoldbachUpTo(10⁷), one can reduce the full ternary Goldbach theorem to an explicit finite computation verifiable in Lean.

**Test:** Formalize the following chain:
1. By Helfgott (2013), every odd n > 10²⁷ is a sum of three primes.
2. By the transfer theorem, if GoldbachUpTo(N), then ThreePrimeRepresentable(n) for all odd n > 5 with n - 3 ≤ N, i.e., n ≤ N + 3.
3. For odd n ∈ (5, 10²⁷], either n ≤ N + 3 (handled by transfer) or we need direct verification.
4. With N = 10²⁷ - 3, this is computationally infeasible. BUT: Helfgott's bound can be lowered to ≈ 10⁷ with sufficient minor arc estimates, making direct verification feasible.

Falsification: if Helfgott's effective bound cannot be lowered below 10⁸, the approach requires more computational resources than currently available.

**Impact:** A formal proof of the ternary Goldbach conjecture would be a historic achievement in formal mathematics. The framework's `binary_implies_ternary_goldbach` theorem provides the key structural reduction; what remains is (a) formal analysis for the large case and (b) certified computation for the small case.

**Catalog References:**
- `Algebra/Goldbach/Theorems.lean`: `binary_implies_ternary_goldbach`, `GoldbachUpTo.extend`
- `Algebra/Goldbach/Defs.lean`: `ThreePrimeRepresentable`, `GoldbachUpTo`

**Proof Strategy:** The framework already proves that binary Goldbach implies ternary Goldbach. The remaining challenge is either (a) formalizing enough of Helfgott's analysis to lower the effective bound, or (b) extending verified computation to cover the gap. The monotone extension theorem makes (b) feasible as a distributed computation campaign.

**Domain Bridges:** Analytic number theory (circle method, exponential sums), formal analysis (integration, Fourier analysis in Mathlib), large-scale certified computation, distributed verification.

**Lineage:** Direct extension of `binary_implies_ternary_goldbach` and the monotone extension architecture from the current cycle.

**Ambition:** ★★★★★ (Grand challenge — paradigm-shifting if achieved)
