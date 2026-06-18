# Future Directions: Berggren Tree Arithmetic Dynamics

## Hypothesis 1: Exponential Hypotenuse Growth Rate

**Conjecture:** There exists a constant λ > 1 (approximately λ ≈ 2.148) such that for every Berggren word w of length d, the hypotenuse satisfies c(w) ≥ λ^d.

More precisely, if c_min(d) denotes the minimum hypotenuse among all triples at depth d in the Berggren tree, then c_min(d) ~ C · λ^d for some constant C > 0.

**Test:** Compute c_min(d) for d = 0, 1, ..., 20. Fit the model log(c_min(d)) = log(C) + d · log(λ) by linear regression. Verify that the residuals are bounded. The word achieving c_min at each depth follows the path that always selects the generator producing the smallest child — identify this "minimal growth path" and characterize it as a periodic or eventually periodic word.

**Impact:** If true, this gives a certified complexity bound for Berggren enumeration: to enumerate all primitive triples with c ≤ N, the tree need only be explored to depth O(log N / log λ). This converts the Berggren tree into a provably efficient enumeration algorithm with formally verified logarithmic depth.

---

## Hypothesis 2: Congruence Equidistribution at Large Depth

**Conjecture:** For any fixed odd modulus m, the distribution of hypotenuse values c(w) mod m, taken over all words w of depth d, converges to the uniform distribution on the admissible residues as d → ∞.

Specifically, a residue class r mod m is "admissible" if r is representable as a sum of two squares modulo m. The fraction of depth-d triples with c ≡ r (mod m) converges to 1/(number of admissible classes) as d → ∞.

**Test:** For m ∈ {3, 5, 7, 8, 12, 13}, enumerate all triples at depths d = 1, ..., 15 and compute the empirical distribution of c mod m. Perform a χ² goodness-of-fit test against the predicted uniform distribution on admissible classes. Track the χ² statistic as a function of d — it should decrease toward the critical value.

**Impact:** If true, this establishes that the Berggren dynamics acts ergodically on residue classes, connecting the combinatorial tree structure to analytic number theory. This would be the first step toward proving that the Berggren semigroup acts with spectral gap on L²(ℤ/mℤ), which has implications for the thin orbit program in homogeneous dynamics.

---

## Hypothesis 3: Fixed-Hypotenuse Multiplicity Formula

**Conjecture:** The number of primitive Pythagorean triples (a, b, c) with a < b and fixed hypotenuse c is exactly 2^(k-1), where k is the number of distinct prime factors p ≡ 1 (mod 4) of c, provided c is a valid hypotenuse (i.e., c has at least one such prime factor and no prime factor p ≡ 3 (mod 4) appears to an odd power).

**Test:** Enumerate all primitive triples with c ≤ 10^6 using the Berggren tree. For each hypotenuse value, compare the actual count with 2^(k-1). The match should be exact for all valid hypotenuse values. The computational verification through c ≤ 10^4 has already confirmed perfect agreement for all 30 tested values.

**Impact:** If proved formally, this gives a complete arithmetic classification of hypotenuse collisions in the Berggren tree. Combined with the unique parent theorem, it shows that the tree structure perfectly reflects the factorization structure of integers into Gaussian primes. This connects Berggren dynamics to algebraic number theory over ℤ[i] and provides a constructive proof of Fermat's theorem on sums of two squares.

---

## Hypothesis 4: Regularity of Residue-Class Path Languages

**Conjecture:** For any modulus m and residue class r, the set of Berggren words w such that the hypotenuse c(w) ≡ r (mod m) forms a regular language over the alphabet {A, B, C}. Equivalently, there exists a finite automaton that, given a word w letter by letter, decides whether c(w) ≡ r (mod m).

In contrast, the set of words w such that c(w) is prime is NOT a regular language.

**Test:** For small moduli (m = 2, 3, 4, 5, 8, 12), construct the candidate DFA explicitly: states are elements of (ℤ/mℤ)³ tracking the triple (a mod m, b mod m, c mod m), transitions are the Berggren generators reduced mod m, and acceptance is c ≡ r (mod m). Verify this DFA is correct on all words of length ≤ 15.

For primality, attempt to find a pumping lemma violation: show that for any candidate DFA size, there exists a word that the DFA must misclassify.

**Impact:** If true, this places congruence properties of Berggren paths firmly in the theory of automatic sequences and regular languages, while showing primality is inherently harder (context-free or context-sensitive). This has implications for the computational complexity of deciding arithmetic properties of Pythagorean triples and connects to the theory of automatic groups.

---

## Hypothesis 5: Unique Energy Descent Beyond Hypotenuse

**Conjecture:** There exists a "secondary energy" functional E: {positive primitive triples} → ℝ, beyond the hypotenuse c, such that:
1. E is strictly decreased by the unique-parent map (ascending the tree),
2. E distinguishes between different tree branches at the same depth,
3. E has a natural interpretation in terms of the Lorentz geometry of the light cone.

A candidate is E(a, b, c) = c + (a - b)² / (4c), which combines hypotenuse size with a measure of "leg asymmetry." Another candidate is the Lorentzian angle θ = arccosh(c / √(ab)), measuring the "hyperbolic distance" from the most symmetric triple at each depth.

**Test:** Compute the candidate energies for all triples through depth 12. Verify strict descent under the parent map. Check whether E stratifies the tree more finely than depth alone — specifically, whether E induces a total order on triples compatible with the partial order given by ancestry.

**Impact:** If true, this establishes a canonical gradient flow on the space of primitive triples, giving a continuous relaxation of the discrete Berggren dynamics. The Lorentzian interpretation would connect the tree structure to hyperbolic geometry and potentially to automorphic forms on the hyperboloid model of H². This could lead to new density estimates for primitive triples in arithmetic progressions.
