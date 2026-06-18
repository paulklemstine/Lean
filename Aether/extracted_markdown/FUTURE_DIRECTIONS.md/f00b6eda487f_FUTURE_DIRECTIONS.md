# Future Directions: Gap Transition System Theory

## Synthesis

This research cycle introduced the **Gap Transition System** (GTS), a finite-state automaton whose states are coprime residue classes modulo a primorial M and whose transitions are driven by additive prime gaps. We proved four main structural theorems — transition composition, cycle sum divisibility, uniform admissibility, and gap forcing — and verified them both formally (Lean 4, zero sorry) and computationally (100,000+ primes).

The most important insight is that prime gaps are not independent random variables but rather drive transitions in a deterministic machine with strong algebraic constraints. The GTS perspective unifies several classical observations (no-prime-triplet theorem, gap parity constraints, residue class distribution) into a single algebraic object. The strongest cross-domain connection is to **symbolic dynamics**: the GTS defines a subshift of finite type, connecting prime gap analysis to the entropy/mixing machinery developed in `Tropical/SpectralDynamics.lean` and related catalog entries.

The highest-breakthrough-potential direction is **Direction 1** (Entropy-Hardy-Littlewood Bridge), because it would provide the first rigorous connection between the combinatorial (automaton) and analytic (singular series) perspectives on prime gaps. If successful, it would establish that the GTS is not merely a combinatorial curiosity but an approximation scheme that converges to the deep analytic structure of primes.

---

### Direction 1: GTS Entropy and the Hardy-Littlewood Singular Series

**Conjecture**: Let A_M be the φ(M) × φ(M) adjacency matrix of GTS(M) restricted to gaps in {2, 4, 6, ..., 2M}. Let λ₁(M) be its largest eigenvalue. Then as M → ∞ through primorials, the normalized spectral radius λ₁(M)/φ(M) converges to a limit related to the Hardy-Littlewood singular series: specifically, for each gap g, the (s, s+g mod M) entry of the normalized transition matrix A_M/φ(M) converges to 𝔖(g) · C for an explicit constant C.

**Test**: Compute A_M for M ∈ {6, 30, 210, 2310, 30030} and compare the spectral radii and entry-wise convergence to known values of 𝔖(g) for small gaps g ∈ {2, 4, 6}. If the convergence is not monotone or the limiting values don't match known singular series values, the conjecture is false.

**Impact**: If true, this provides a purely combinatorial derivation of the Hardy-Littlewood singular series, bridging number theory and symbolic dynamics. If false, the failure mode reveals what analytic information the GTS cannot capture.

**Catalog References**: `Tropical/SpectralDynamics.lean` (entropy bridge), `FINAL/Pythagorean/CertificateSampling.lean` (spectral gap bounds)

**Proof Strategy**: 
1. Define the adjacency matrix A_M formally in Lean for GTS(M) restricted to even gaps ≤ 2M.
2. Prove that A_M is a non-negative matrix with positive spectral radius (Perron-Frobenius).
3. Show that the rows of A_M/φ(M) converge entry-wise to the singular series values as M → ∞.
4. Key lemma: The (s,t) entry of A_M counts the number of even gaps g ≤ 2M with (s+g) mod M = t and gcd(t, M) = 1. This count is related to the inclusion-exclusion sieve, which in the limit gives the singular series.

**Domain Bridges**: Number Theory (prime gaps, singular series) ↔ Symbolic Dynamics (entropy, subshifts) ↔ Spectral Theory (Perron-Frobenius, adjacency matrices)

**Lineage**: Builds on this cycle's GTS definition, cycle sum divisibility, and uniform admissibility theorems.

**Ambition**: grand_challenge

---

### Direction 2: Forcing Profile Growth and Cramér's Conjecture

**Conjecture**: Let μ_max(M) = max_{s ∈ S_M} μ(s) be the maximum minimum admissible gap across all states of GTS(M), where M ranges over primorials. Then μ_max(M) = Θ(log M), and more precisely, μ_max(M) / log M → 1 as M → ∞ through primorials. This would mean the GTS forcing bound grows at the same rate as the conjectured maximal prime gap (Cramér's conjecture: max gap near x is ~(log x)²; the GTS bound grows as log of the primorial, which is ~x by the prime number theorem).

**Test**: Compute μ_max(M) for M ∈ {6, 30, 210, 2310, 30030, 510510} and plot μ_max(M) / log(M). If the ratio does not stabilize near 1, the conjecture needs revision.

**Impact**: If true, this proves that the GTS forcing profile provides a non-trivial lower bound on prime gaps that grows logarithmically — the same order as the elementary lower bound from sieve theory. If the growth rate is faster than log M, it would suggest the GTS captures more structure than the simple sieve.

**Catalog References**: `FINAL/Pythagorean/BoundedBetaTheorems.lean` (finite states of bounded beta), `FINAL/Pythagorean/SSHNewtonOrder.lean` (gap bounds)

**Proof Strategy**:
1. Formalize μ_max(M) as a function of primorials in Lean.
2. Prove μ_max(M) ≥ p_{k+1} − 1 where p_{k+1} is the smallest prime not dividing M (since the residues 1, 2, ..., p_{k+1}−1 are all non-coprime to M from state 1).
3. By Bertrand's postulate, p_{k+1} ≤ 2p_k, giving μ_max ≥ 2p_k − 1 ≈ 2 log M.
4. For the upper bound, show that for any state s, the gap g = p_{k+1} (the next prime after M's largest factor) always gives gcd(s + g, M) = 1 in some carefully constructed case.

**Domain Bridges**: Gap Transition Theory ↔ Sieve Methods ↔ Cramér's random model for primes

**Lineage**: Extends this cycle's forcing theorems (gts30_gap_lt6_inadmissible_from_1, gts30_gap6_admissible_from_1).

**Ambition**: grand_challenge

---

### Direction 3: GTS Mixing and the Twin Prime Conjecture

**Conjecture**: The GTS(30) subshift restricted to gaps in {2, 4, 6} is topologically mixing. More precisely, for any two admissible words u, v of the subshift, there exists N such that for all n ≥ N, there exists a word w of length n with uwv admissible.

**Test**: Verify computationally that the adjacency matrix A restricted to gap-2, gap-4, gap-6 transitions has A^k with all positive entries for some finite k. If A^k has zero entries for all reasonable k, the subshift is not mixing.

**Impact**: If mixing is established, it implies that every admissible gap pattern occurs infinitely often in the GTS-allowed sequences. While this does not prove the twin prime conjecture (which requires the actual prime gaps to realize all GTS-admissible patterns), it would show that the *algebraic framework* is compatible with twin primes occurring infinitely often. A non-mixing result would identify specific obstructions.

**Catalog References**: `FINAL/Tropical/SpectralDynamics.lean` (strict_cycle_gap_entropy_bridge), `Shared/SymbolicDynamics.lean`

**Proof Strategy**:
1. Construct the 8×8 adjacency matrix for gap-{2,4,6} transitions in GTS(30).
2. Compute A^k for k = 1, 2, 3, ... until all entries are positive (or prove it's impossible).
3. Apply Perron-Frobenius theory: a non-negative irreducible aperiodic matrix has all-positive powers.
4. Formalize in Lean using matrix powers and Finset.sum.

**Domain Bridges**: Gap Transition Theory ↔ Symbolic Dynamics (mixing, SFT classification) ↔ Markov Chain Theory

**Lineage**: Extends this cycle's transition_assoc and coprime_shift_count theorems.

**Ambition**: extension

---

### Direction 4: GTS over Function Fields

**Conjecture**: The Gap Transition System generalizes to polynomial rings over finite fields. For F_q[x] with q a prime power, define GTS_q(M) where M is a product of distinct irreducible polynomials of small degree. The analog of the uniform admissibility theorem holds: from any coprime residue class, exactly Φ(M) gaps (polynomials) in a complete residue period are admissible, where Φ is the polynomial analog of Euler's totient.

**Test**: Implement GTS for F_2[x] with M = x(x+1)(x²+x+1) (the analog of 30 = 2·3·5 for F_2[x]) and verify uniform admissibility computationally. Compare the forcing profile to the integer case.

**Impact**: Function field analogs of number-theoretic results are often easier to prove (cf. the Riemann Hypothesis for function fields). If the GTS framework transfers cleanly, it could provide a testing ground for conjectures about prime gaps that are intractable over ℤ.

**Catalog References**: `FINAL/Pythagorean/TropicalBerggrenZeta.lean` (zeta function connections), `Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**:
1. Define polynomial GTS over F_q[x] using Mathlib's `Polynomial` and `ZMod` infrastructure.
2. Adapt the uniform admissibility proof — the key bijection (shift by s) works identically in polynomial rings.
3. The forcing profile may differ due to the different structure of irreducible polynomials.

**Domain Bridges**: Number Theory (prime gaps) ↔ Algebraic Geometry (function fields) ↔ Finite Field Combinatorics

**Lineage**: Generalizes all four main theorems from this cycle to the function field setting.

**Ambition**: extension

---

### Direction 5: Hierarchical GTS and Primorial Tower

**Conjecture**: The GTS systems for increasing primorials (M = 6, 30, 210, 2310, ...) form a projective system: there is a natural surjection π: S_{M·p} → S_M (reduction mod M) that commutes with transitions. The inverse limit of this system captures, in a precise sense, all modular constraints on prime gaps simultaneously.

**Test**: Verify that the surjection π preserves cycle sum divisibility and forcing lower bounds. Specifically, check that μ_max(M·p) ≥ μ_max(M) for primorials M and primes p.

**Impact**: If the projective system is well-behaved, the inverse limit GTS is an infinite profinite automaton that encodes all algebraic constraints on prime gaps. The Cycle Sum Divisibility theorem would lift to: the sum of gaps in any cycle is divisible by *every* primorial — i.e., the gap sum is 0. This would be a new proof that the only cycle in the full (infinite) GTS is the empty one, reflecting the fact that primes do not repeat.

**Catalog References**: `FINAL/Pythagorean/AdelicPersistentHomology.lean` (catalog_connection, adelic structure), `Cryptography/BerggrenGroupoidOrbit.lean`

**Proof Strategy**:
1. Formalize the projection map π: GTS(M·p).states → GTS(M).states as s ↦ s mod M.
2. Prove π ∘ δ_{M·p}(s, g) = δ_M(π(s), g) (transition commutes with projection).
3. Prove that π maps cycles to cycles and preserves gap sums modulo M.
4. Define the inverse limit as a type in Lean using dependent products.
5. Prove the inverse limit has no non-trivial cycles (gap sum must be divisible by all primorials, hence = 0 or infinite).

**Domain Bridges**: Gap Transition Theory ↔ Profinite Groups (inverse limits) ↔ Adelic Number Theory (completion at all primes)

**Lineage**: Extends the cycle_sum_divisible theorem and the projection structure implicit in all GTS results.

**Ambition**: grand_challenge
