# Future Directions: Witness Geometry in Primality Testing

## Synthesis

The unified witness framework developed here reveals that primality testing is not a collection of isolated algorithms but a coherent geometric theory. Miller–Rabin witnesses probe multiplicative dynamics in (ℤ/nℤ)×, AKS witnesses probe polynomial identities in (ℤ/nℤ)[X]/(X^r − 1), and spectral witnesses probe additive-combinatorial regularity of residue sets. The five directions below form a research program connecting these three views: the first two directions deepen the algebraic foundations (completing the quarter bound and establishing the spectral conjecture), the middle direction connects to complexity theory (derandomization), and the final two push into new mathematical territory (dynamical systems and coding theory). Together, they aim to transform formal number theory from a repository of isolated lemmas into an engine for certified complexity-theoretic arithmetic.

---

## Direction 1: Complete Formalization of the Rabin–Monier Quarter Bound

**Conjecture**: The theorem `strongLiarSet_card_le_quarter'` — that for odd composite n ≥ 3, at most 1/4 of coprime bases are strong Miller–Rabin liars — can be fully formalized in Lean 4 using Mathlib's existing library of finite group theory and Chinese Remainder Theorem infrastructure.

**Test**: Decompose the proof into three separately verifiable Lean lemmas:
1. For n = ab with gcd(a,b) = 1 and a,b > 1: the CRT isomorphism (ℤ/nℤ)× ≅ (ℤ/aℤ)× × (ℤ/bℤ)× maps the liar set into a proper subgroup of index ≥ 4.
2. For n = p^k with k ≥ 2 and p odd prime: the cyclic structure of (ℤ/p^kℤ)× constrains liars to a subgroup of index ≥ 4.
3. Any odd composite n ≥ 9 satisfies one of these cases.

Verify each lemma compiles without sorry in Lean 4 with Mathlib.

**Impact**: Eliminates the only remaining sorry in the framework, making all 10 theorems fully machine-verified. This would be the first complete machine-checked proof of the Rabin–Monier theorem in any proof assistant.

**Catalog References**: `Catalog/Speculative/PrimalityTesting/WitnessTheorems.lean` (strongLiarSet_card_le_quarter')

**Proof Strategy**: Use Mathlib's `ZMod.chineseRemainder` for the CRT decomposition. The key is formalizing that nontrivial square roots of unity exist for composites with coprime factors, and that these split the liar set into at most 1/4 of the unit group. For the prime power case, use Mathlib's `IsCyclic` instance for (ℤ/p^kℤ)×.

**Domain Bridges**: Finite group theory → algebraic number theory → computational number theory

**Lineage**: Direct continuation of Rabin (1980), Monier (1980)

**Ambition**: Extension — completes a known theorem in formal mathematics

---

## Direction 2: Spectral Sparsity Conjecture for Strong Liar Sets

**Conjecture**: There exists ε > 0 such that for infinitely many odd composite non-prime-powers n, the additive energy of the strong liar set satisfies:
```
E(StrongLiarSet(n)) ≤ C · |StrongLiarSet(n)|^(3 − ε)
```
for a universal constant C. In other words, liar sets are additively "sparser" than generic sets of the same density.

**Test**: For all odd composite n ≤ 10,000:
1. Compute StrongLiarSet(n) and its additive energy E(L)
2. Compute the ratio E(L) / |L|³
3. Check whether this ratio is bounded away from 1 and decreasing as n grows
4. Compare Carmichael numbers vs. non-Carmichael composites
5. Fit a power law: does E(L) ~ |L|^α for some α < 3?

Expected outcome: α ≈ 2.7 ± 0.2 based on preliminary computations.

**Impact**: Would give a fundamentally new explanation for Miller–Rabin's effectiveness, grounded in additive combinatorics rather than group theory. Opens the door to spectral primality tests.

**Catalog References**: `Catalog/FINAL/Algebra/Transfer.lean` (spectral_energy_modular_collision_bound), `Catalog/Speculative/PrimalityTesting/WitnessTheorems.lean` (many_strong_liars_force_collision_obstruction')

**Proof Strategy**: Use the Plünnecke-Ruzsa inequality to bound |L + L| in terms of |L|, then apply Balog-Szemerédi-Gowers to extract a large structured subset. The CRT decomposition of L should reveal that L decomposes into "fibers" with limited cross-fiber interaction, which constrains additive energy.

**Domain Bridges**: Additive combinatorics → harmonic analysis → primality testing

**Lineage**: Tao-Vu additive combinatorics, Bourgain sum-product estimates

**Ambition**: Grand challenge — would establish a new research program linking additive combinatorics to computational number theory

---

## Direction 3: Deterministic Hitting Sets for Miller–Rabin Bases

**Conjecture**: For every B > 0, there exists an explicit set H ⊂ {2, …, B} with |H| = O(log B · log log B) such that for every odd composite n ≤ B, at least one a ∈ H is a Miller–Rabin witness for n.

**Test**: For B = 10^6:
1. Use the greedy algorithm to construct a hitting set H
2. Verify |H| ≤ 20 (compared to the trivial bound of B)
3. Compare with known results: for n < 3.3 × 10^24, the set {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37} suffices
4. Analyze the growth rate of |H| as B increases

For each candidate H, verify in Python that every odd composite n ≤ B has at least one witness in H.

**Impact**: Transforms Miller–Rabin from a probabilistic algorithm to a deterministic one for bounded inputs. Connects to the GRH-conditional result of Miller (1976) that bases up to O(log²n) suffice.

**Catalog References**: `Catalog/Speculative/PrimalityTesting/WitnessTheorems.lean` (liarTupleSet_card_le_pow')

**Proof Strategy**: Use the probabilistic method: since each composite has ≥ 3/4 witnesses, a random set of O(log B) bases hits all composites with high probability. Make this constructive using the Lovász Local Lemma or explicit expander constructions.

**Domain Bridges**: Computational complexity → derandomization → combinatorial design theory

**Lineage**: Miller (1976), Erdős-Selfridge, Alford-Granville-Pomerance

**Ambition**: Grand challenge — would resolve the practical derandomization of primality testing

---

## Direction 4: Dynamical Systems Perspective on Repeated Squaring

**Conjecture**: For odd composite n, the orbit structure of the repeated squaring map x ↦ x² in (ℤ/nℤ) exhibits characteristic "bifurcation signatures" that distinguish composites from primes with probability 1 − o(1) using a single random starting point.

**Test**: For n ≤ 1000 (both primes and composites):
1. Compute the repeated squaring orbit of random bases a: a, a², a⁴, a⁸, …
2. Record the pre-period (ρ) and period (λ) of each orbit
3. Plot the distribution of (ρ, λ) pairs for primes vs. composites
4. Test whether the Pollard-rho-like bifurcation pattern (multiple cycles meeting at nontrivial square roots of unity) is a reliable compositeness indicator
5. Compare orbit complexity (number of distinct elements) across number types

**Impact**: Connects primality testing to the theory of finite dynamical systems, potentially yielding new algorithms based on orbit structure rather than algebraic identities.

**Catalog References**: `Catalog/Speculative/PrimalityTesting/WitnessTheorems.lean` (repeatedSquaring_orbit_eventually_periodic')

**Proof Strategy**: Use the CRT decomposition: orbits in (ℤ/nℤ) decompose as products of orbits in (ℤ/p^kℤ) for each prime power factor. Primes have simple orbit structure (single cycle of length dividing p−1), while composites have "product orbits" with characteristic interference patterns.

**Domain Bridges**: Finite dynamical systems → ergodic theory → primality testing

**Lineage**: Pollard's rho algorithm, Floyd's cycle detection

**Ambition**: Extension — applies known dynamical systems theory to a new domain

---

## Direction 5: Certificate Complexity and Error-Detecting Codes

**Conjecture**: The AKS certificate can be viewed as a codeword in an error-detecting code over (ℤ/nℤ)[X], where:
- The "message" is the claim "n is prime"
- The "codeword" is the tuple of polynomial congruences (X+1)^n, (X+2)^n, …, (X+amax)^n mod (X^r−1)
- The "minimum distance" (number of failing congruences for any composite) is at least amax − O(√φ(r) · log n)

**Test**: For composites n ≤ 500 and r ∈ {5, 7, 11, 13}:
1. Compute how many values of a ∈ {1, …, r−1} satisfy the AKS congruence
2. Determine the "Hamming weight" (number of failures) for each composite
3. Plot minimum distance as a function of r and n
4. Verify that the minimum distance grows with r

**Impact**: Establishes a formal connection between primality certificates and coding theory. Could lead to new certificate schemes with optimal redundancy.

**Catalog References**: `Catalog/Speculative/PrimalityTesting/WitnessTheorems.lean` (AKSCertificate', aks_prime_satisfies_congruence')

**Proof Strategy**: Use the fact that for composite n with a factor p, the polynomial (X+a)^n − X^n − a has degree n and at most n roots mod p, so in the quotient ring (ℤ/pℤ)[X]/(X^r−1) (which has dimension r), at most r values of a can satisfy the congruence. For r ≫ log²n, this leaves most values as witnesses.

**Domain Bridges**: Coding theory → polynomial identity testing → algebraic complexity theory

**Lineage**: AKS (2002), Schwartz-Zippel lemma, algebraic geometry codes

**Ambition**: Extension — applies existing coding theory to formalize certificate properties
