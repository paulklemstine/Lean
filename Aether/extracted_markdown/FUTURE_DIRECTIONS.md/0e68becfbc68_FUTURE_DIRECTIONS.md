# Future Directions: Berggren Dynamics and Arithmetic Geometry

## Overview

The formal verification of the Berggren tree's free semigroup structure opens several precise, testable research directions at the intersection of number theory, dynamics, and algorithms. Each hypothesis below is stated concretely enough for a team to begin experimental validation and proof attempts immediately.

---

## Hypothesis 1: Exponential Depth-Growth Bound

**Conjecture:** There exists λ > 1 such that for every Berggren word w of length n,

    c(w) ≥ λⁿ · 5

where c(w) is the hypotenuse of the triple produced by applying w to the root (3,4,5).

**Current status:** We proved a *linear* lower bound: c(w) ≥ n + 5. Computational data suggests the minimal hypotenuse at depth n grows roughly as n² (subexponential), with min-hyp ratios decreasing toward 1. The B-branch alone grows exponentially (with ratio ≈ 5.83), but the A and C branches grow more slowly.

**Test protocol:**
1. Compute exact minimal hypotenuse at depth n for n ≤ 25 using BFS.
2. Fit candidate growth functions: λⁿ, n^α, exp(√n).
3. Identify the minimal-hypotenuse path at each depth and analyze its generator sequence.
4. Compare with eigenvalue analysis of the Berggren matrices (spectral radii ~5.83, ~1.17, ~1.17).

**Expected outcome:** The minimal growth is polynomial (≈ n²), not exponential. The exponential bound holds only for "generic" words (those avoiding the slow-growth A-path). A refined conjecture: c(w) ≥ C · n² for an explicit constant C.

**Proof strategy:** Analyze the A-only path, which produces the smallest hypotenuses. Show that repeated A-application gives quadratic growth via the recurrence structure. For generic words, use spectral theory of random matrix products.

---

## Hypothesis 2: Congruence Equidistribution of Hypotenuse Values

**Conjecture:** For any fixed odd modulus m, the distribution of hypotenuse values c(w) modulo m, taken over all words w at depth n, converges to equidistribution among admissible residue classes as n → ∞.

An "admissible" residue class is one that can appear as the hypotenuse of a primitive Pythagorean triple — namely, those c with every prime factor ≡ 1 (mod 4).

**Test protocol:**
1. For m ∈ {3, 5, 7, 11, 13}, enumerate all triples at depths 1–15.
2. Compute the residue distribution of hypotenuses mod m at each depth.
3. Perform χ² tests against the uniform distribution on admissible classes.
4. Plot deviation from uniformity as a function of depth.

**Expected outcome:** Rapid convergence to equidistribution for m coprime to 30, with slower convergence for m sharing factors with the matrix entries.

**Proof strategy:** The Berggren matrices modulo m generate a finite semigroup acting on (ℤ/mℤ)³. If this action is transitive on the light cone mod m, equidistribution follows from general results on random walks on finite groups. The key is to verify transitivity for each m.

---

## Hypothesis 3: Fixed-Hypotenuse Multiplicity Formula

**Conjecture:** The number of primitive Pythagorean triples (a, b, c) with a, b > 0 and fixed hypotenuse c > 0 equals

    2^(k-1)

where k is the number of distinct prime factors p of c with p ≡ 1 (mod 4).

**Refinement:** This counts ordered pairs (a,b) with a < b. Including a > b doubles it (for c > 1). The formula follows from the representation of c as a sum of two squares via Gaussian integer factorization.

**Test protocol:**
1. For c ≤ 10000, enumerate all primitive triples and count multiplicities.
2. Factor each c and compute k = #{p | c : p ≡ 1 mod 4, p prime}.
3. Verify the formula 2^(k-1) against actual counts.
4. Identify and classify any discrepancies.

**Expected outcome:** Exact agreement for all c that are products of primes ≡ 1 (mod 4). The formula also applies when c has prime factors ≡ 3 (mod 4) with even multiplicity, as long as gcd(a,b) = 1.

**Proof strategy:** Factor c in the Gaussian integers ℤ[i]. Each prime p ≡ 1 (mod 4) splits as p = π·π̄, giving a binary choice in the factorization of c. The 2^(k-1) formula counts the number of essentially distinct factorizations. Formalize this using Mathlib's `GaussianInt` and its unique factorization.

---

## Hypothesis 4: Automaticity of Residue-Class Path Properties

**Conjecture:** For any fixed modulus m, the set of Berggren words w such that c(w) ≡ r (mod m) is recognized by a finite automaton (is a regular language over {A, B, C}).

**Anti-conjecture:** The set of words w such that c(w) is prime is NOT a regular language.

**Test protocol:**
1. For m ∈ {4, 5, 8, 12}, construct a DFA that tracks (a mod m, b mod m, c mod m) through the word.
2. Verify that the DFA correctly predicts c(w) mod m for all words up to length 10.
3. For the primality predicate, attempt the pumping lemma: find words w₁, w₂, w₃ such that w₁·w₂ⁿ·w₃ produces primes for n = 1,2,3 but not n = 4. This would not disprove regularity but suggests non-regularity.
4. Search for pumping obstructions systematically.

**Expected outcome:** The residue-class automaton exists with m³ states (tracking the full triple mod m). The primality predicate is provably non-regular by a counting argument: the number of prime-hypotenuse words at length n grows too irregularly for a regular language.

**Proof strategy:** The automaton construction is straightforward: define states as equivalence classes of (a, b, c) mod m. Transitions are given by the Berggren matrices mod m. For non-regularity of primality, use the prime number theorem in arithmetic progressions to show that the density of prime-producing words at length n oscillates in a way incompatible with the periodicity constraints of regular languages.

---

## Hypothesis 5: Canonical Energy Descent for Unique Parent Selection

**Conjecture:** There exists an explicit "energy" function E: ℤ³ → ℝ, polynomial in (a, b, c), such that:
1. E(a, b, c) > 0 for all Berggren-primitive triples except the root.
2. E decreases strictly under the unique-parent map: E(parent) < E(child) for every non-root triple.
3. E(3, 4, 5) = 0.

A natural candidate is E(a, b, c) = c - 5 (using the hypotenuse), but more interesting candidates include:
- E(a, b, c) = log(c) (logarithmic depth proxy)
- E(a, b, c) = a + b - c (triangle excess)
- E(a, b, c) = a·b (leg product)

**Test protocol:**
1. Compute E for all candidate energy functions on triples up to depth 10.
2. For each candidate, verify strict descent under the parent map.
3. Search for polynomial invariants of the form E = α·a + β·b + γ·c + δ·a² + ... that achieve strict descent.
4. Analyze the "gradient flow" structure: does the parent map always follow the steepest descent of some E?

**Expected outcome:** The hypotenuse c itself serves as the simplest strict descent function (already proved: Theorem E). More refined candidates like the triangle excess a + b - c may reveal additional structure about which branch (A, B, or C) the parent map selects.

**Proof strategy:** For a polynomial E, the descent condition E(parent) < E(child) reduces to verifiable polynomial inequalities for each of the three Berggren transformations, subject to the constraints a² + b² = c², a > 0, b > 0, c > 0. Use interval arithmetic or SOS (sum of squares) certificates to verify these inequalities.

---

## Cross-Cutting Research Themes

### Theme A: Thin Orbit Theory
The Berggren semigroup is a prototypical "thin" subgroup of O(2,1;ℤ) — infinite index, but with rich arithmetic structure. Our injectivity theorem provides the foundation for studying orbit growth, spectral gaps, and local-global phenomena in this concrete setting.

### Theme B: Certified Enumeration
The word-injectivity theorem, combined with hypotenuse monotonicity, yields a formally verified enumeration algorithm for primitive Pythagorean triples. This can be extended to certified search for triples with specific arithmetic properties (e.g., both legs prime, hypotenuse a perfect square).

### Theme C: Connections to Apollonian Packings
The Berggren tree is structurally analogous to the Apollonian gasket: both are generated by a finite set of integer matrices acting on a quadratic form's zero set. Our techniques (Lorentz form preservation, injectivity, descent) should transfer to the Apollonian setting with appropriate modifications.

### Theme D: Symbolic Dynamics
The canonical word encoding transforms number-theoretic questions about Pythagorean triples into combinatorial questions about words over {A, B, C}. This bridge enables techniques from formal language theory, automata theory, and ergodic theory to attack problems about the distribution of triples.

---

## Priority Ranking

1. **Hypothesis 3** (multiplicity formula) — most likely to yield a complete formal proof using existing Mathlib infrastructure.
2. **Hypothesis 1** (growth bound) — clear path via spectral analysis of Berggren matrices.
3. **Hypothesis 4** (automaticity) — concrete and computationally testable.
4. **Hypothesis 5** (energy descent) — foundational for algorithmic applications.
5. **Hypothesis 2** (equidistribution) — requires the deepest analytic tools.
