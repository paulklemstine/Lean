# Future Directions: Collatz One-Way Functions

## Synthesis

This cycle established the mathematical foundations for Collatz-based cryptography by proving three key results: (1) the forward-inverse gap theorem showing that computing T^k(n) costs O(k) while inverting costs O(2^k), (2) superpolynomial security gap theorems proving k² + k < 2^k for k ≥ 5, and (3) complete preimage structure analysis showing each value has at most 2 preimages with exactly 1/6 having a second odd preimage. These results connect dynamical systems theory to cryptographic hardness in a novel way.

The most promising cross-domain connection is the bridge between Collatz preimage trees and tropical (min-plus) matrix one-way functions. Both rely on branching combinatorics for security: tropical OWFs branch through permutation weights, while Collatz OWFs branch through the even/odd preimage structure. The existing Catalog results on tropical hash collision bounds (`Cryptography/TropicalOneWayFoundations.lean`) and post-quantum key security from min-entropy (`Cryptography/LeftoverHash.lean`) provide ready-made tools that could be adapted to strengthen Collatz-based constructions. The direction with highest breakthrough potential is Direction 1 (p-adic bridge), because it would connect the well-understood p-adic analytic theory of the Collatz map to the well-developed tropical cryptographic framework, potentially yielding unconditional hardness results.

The results also connect naturally to the Catalog's computation theory: the forward-inverse asymmetry is a concrete instance of the information-efficient algorithm framework (`Computation/InfoEfficientAlgorithms.lean`), where forward Collatz evaluation achieves optimal information efficiency while inversion is provably inefficient.

---

### Direction 1: P-adic Collatz Bridge to Tropical Cryptography

**Conjecture**: The 2-adic representation of the Collatz map T : ℤ₂ → ℤ₂ is a contraction mapping in the 2-adic metric, and the contraction rate provides a quantitative lower bound on the preimage search cost that matches the tropical matrix OWF security parameter.

Specifically, define the "2-adic Collatz distance" d₂(n, m) = |T(n) - T(m)|₂ for n, m in ℤ₂. Conjecture: for n ≢ m (mod 2^k), we have d₂(T^k(n), T^k(m)) ≤ C · 2^{-αk} · d₂(n, m) for constants C, α > 0. This contraction rate α would serve as a "hardness exponent" analogous to the dimension parameter in tropical matrix OWFs.

**Test**: Compute d₂(T^k(n), T^k(m)) for 10,000 random pairs (n,m) with n ≡ m (mod 2^j) for j = 1,...,20 and k = 1,...,50. Fit the contraction rate α. If α ≤ 0 for any configuration, the conjecture fails.

**Impact**: If true, this establishes a formal bridge between p-adic analysis of Collatz dynamics and tropical/lattice cryptography. It would yield the first hardness result for Collatz inversion that comes with a quantitative security parameter derived from analytic number theory, rather than combinatorial tree counting.

**Catalog References**: `Cryptography/TropicalOneWayFoundations.lean` (tropical OWF framework), `Cryptography/TropicalPostQuantum.lean` (tropical key space exponential growth), `Computation/PadicValuationDepth.lean` (p-adic valuation measures)

**Proof Strategy**: (1) Formalize the 2-adic Collatz map using Mathlib's `Padic` library. (2) Prove the contraction estimate for the two branches separately (even branch contracts by factor 2, odd branch expands by factor ≈ 3). (3) Use the parity statistics of Collatz trajectories (Terras 1976: density of odd steps → log 2 / log 3) to get the average contraction rate. (4) Connect to tropical hardness via the "p-adic valuation bridge" from `Computation/PadicValuationDepth.lean`.

**Domain Bridges**: NumberTheory <-> Cryptography, PadicAnalysis <-> TropicalGeometry

**Lineage**: Builds on `collatzStep_pos`, `collatzIter_pos`, `collatz_forward_inverse_gap` from this cycle, and `padic_val_pow_self` from `Cryptography/TropicalOneWayFoundations.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Quantum Lower Bounds for Collatz Inversion

**Conjecture**: Grover's algorithm applied to Collatz preimage search achieves at most a quadratic speedup, reducing the search cost from O(2^k) to O(2^{k/2}), and no quantum algorithm can do better. That is, any quantum algorithm inverting f_k(n) = T^k(n) requires Ω(2^{k/2}) queries to T.

More precisely: in the query model where T is given as a quantum oracle, the bounded-error quantum query complexity of finding n given T^k(n) is Θ(2^{k/2}).

**Test**: Implement a quantum circuit simulator for small k (k ≤ 15) and verify that Grover search over the preimage tree finds preimages in ~2^{k/2} queries. Show that quantum walk algorithms do not improve on this.

**Impact**: This would establish that Collatz-based cryptography provides provable post-quantum security with known security loss. Combined with the superpolynomial gap theorem (k² + k < 2^k), even the quantum search cost 2^{k/2} far exceeds the forward cost k for large k.

**Catalog References**: `Cryptography/PostIdempotentCrypto.lean` (quantum obstructions from idempotent algebra), `Cryptography/SPBQuantumCrypto.lean` (quantum cryptographic framework)

**Proof Strategy**: (1) Model the Collatz preimage search as an unstructured search problem (since the preimage tree has no exploitable algebraic structure). (2) Apply the BBBV lower bound (Bennett et al. 1997) for unstructured search. (3) The key challenge is proving that the Collatz preimage tree has no "quantum-exploitable structure" — formalize this as a spectral gap condition on the preimage graph.

**Domain Bridges**: Cryptography <-> QuantumComputation, DynamicalSystems <-> Complexity

**Lineage**: Builds on `collatz_forward_inverse_gap`, `security_gap_quadratic`, and the `CollatzPreimage` analysis from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Collatz Hash Function Collision Bounds

**Conjecture**: For a Collatz hash with m chains each of depth d, the expected number of collisions among N random inputs is at most N² · (2/3)^{md}. That is, the collision probability decreases exponentially in both the number of chains m and the depth d.

The key assumption is that the 1/6 probability of having two preimages creates an effective "branching entropy" of log₂(7/6) ≈ 0.22 bits per step, and this entropy accumulates multiplicatively across chains.

**Test**: For m ∈ {1, 2, 3, 4} and d ∈ {5, 10, 15, 20}, sample N = 100,000 random inputs from [1, 10^8] and count collisions. Fit the collision rate to A · B^{md} and estimate B. If B > 0.9, the exponential decay conjecture fails.

**Impact**: A proved collision bound would make the Collatz hash a theoretically grounded candidate for hash function construction, complementing existing constructions from lattice problems and tropical algebra.

**Catalog References**: `Cryptography/TropicalOneWayFoundations.lean` (`tropical_hash_collision_bound`), `Cryptography/LeftoverHash.lean` (`post_quantum_key_security_from_minEntropy`)

**Proof Strategy**: (1) Formalize the collision probability for a single chain using the preimage cardinality bound (|T^{-1}(m)| ≤ 2). (2) Show that the probability of two inputs x ≠ y satisfying T^d(x+s) = T^d(y+s) is bounded by the number of "matching branches" in their trajectory trees. (3) Use the independence of different seeds to multiply probabilities across chains. (4) The main lemma needed: the fraction of pairs (x,y) with T^d(x) = T^d(y) is at most C · r^d for some r < 1.

**Domain Bridges**: Cryptography <-> Combinatorics, DynamicalSystems <-> ProbabilityTheory

**Lineage**: Builds on `collision_requires_all_chains`, `collatzPreimage_card_le_two` (stated but not fully formalized), and `collatzStep_consecutive_differ` from this cycle.

**Ambition**: extension

---

### Direction 4: Collatz Map as Pseudorandom Generator

**Conjecture**: The parity sequence of a Collatz trajectory — the sequence (T^i(n) mod 2)_{i=0,...,k-1} — is computationally indistinguishable from a uniformly random binary string, under the assumption that Collatz inversion is hard.

More precisely: for any polynomial-time statistical test D, |Pr[D(parity(T^0(n),...,T^{k-1}(n))) = 1] - Pr[D(U_k) = 1]| < ε(k) where U_k is the uniform distribution on {0,1}^k and ε is negligible.

**Test**: Apply the NIST SP 800-22 randomness tests to parity sequences generated from random starting values n ∈ [10^6, 10^9] with trajectory length k = 1000. If any test fails at significance level 0.01 for more than 5% of seeds, the conjecture is refuted.

**Impact**: If the parity sequence is pseudorandom, then the Collatz map directly yields a pseudorandom generator (PRG). Combined with the Goldreich-Levin theorem, this would give a full cryptographic toolkit: PRG → PRF → encryption → signatures, all based on Collatz hardness.

**Catalog References**: `Cryptography/Security.lean` (`search_from_decision_coordinate`), `Cryptography/TropicalEntropy.lean` (`trop_post_quantum_key_security`)

**Proof Strategy**: (1) The key insight is that predicting the next parity bit is equivalent to distinguishing even from odd predecessors, which requires solving the preimage problem. (2) Formalize the Goldreich-Levin reduction: if the parity bit is predictable, then inversion is efficient. (3) Use the proved sensitivity theorem (`collatzStep_consecutive_differ`) to show that small input perturbations produce unpredictable parity changes. (4) The hard part is formalizing "computational indistinguishability" in Lean — the `Cryptography/Security.lean` framework provides a starting point.

**Domain Bridges**: Cryptography <-> DynamicalSystems, NumberTheory <-> Complexity

**Lineage**: Builds on `collatzStep_odd_gives_even`, `collatzStep_consecutive_differ`, and the `CollatzHashConfig` framework from this cycle.

**Ambition**: extension

---

### Direction 5: Generalized Collatz Maps and Parameter Space

**Conjecture**: The generalized Collatz map T_{a,b}(n) = n/2 if even, a·n+b if odd (with a odd, b even, gcd(a,b)=1) forms a one-way function family for any a ≥ 3 odd, with security parameter growing as (a/2)^k · 2^{-k} when a > 2.

The "3x+1" map is the special case a=3, b=1. The conjecture states that *all* maps in this family with a ≥ 3 exhibit one-way behavior, and the security parameter depends on the growth rate a/2 of the odd branch relative to the halving of the even branch.

**Test**: For (a,b) ∈ {(3,1), (5,1), (5,3), (7,1), (7,3), (7,5)}, compute the preimage tree of 1 to depth 30 and measure the branching factor. If any map with a ≥ 3 has a branching factor consistently below 1.0, the conjecture (or at least the universality claim) fails.

**Impact**: A parameterized family of one-way functions provides "key diversity" — different parameter choices give different functions, making cryptanalysis harder. This is analogous to how RSA security depends on the choice of modulus, or how elliptic curve cryptography depends on the curve parameters.

**Catalog References**: `Algebra/Advanced.lean` (`iterateB` — iterated map framework), `Cryptography/TropicalMinPlusOWF.lean` (`tropical_key_space_exponential` — parameterized security)

**Proof Strategy**: (1) Generalize the `collatzStep` definition to take parameters (a, b). (2) Prove the even preimage always exists (2m → m). (3) Characterize when the odd preimage exists: need a·n+b = m, i.e., n = (m-b)/a with n odd and positive. The fraction of m admitting odd preimages is 1/(2a). (4) Prove the forward-inverse gap as a function of a: the branching factor is 1 + 1/(2a), so the preimage tree size at depth k is approximately (1 + 1/(2a))^k. (5) Show this exceeds k for all k ≥ k₀(a).

**Domain Bridges**: DynamicalSystems <-> Cryptography, NumberTheory <-> ParameterizedComplexity

**Lineage**: Builds on the full `CollatzOneWay` formalization from this cycle. Directly generalizes `collatzStep`, `collatzIter`, `collatz_forward_inverse_gap`, and `CollatzHashConfig`.

**Ambition**: extension
