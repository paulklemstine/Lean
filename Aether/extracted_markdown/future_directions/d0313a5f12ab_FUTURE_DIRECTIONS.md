# Future Directions: Benford Universality for Quadratic Dynamical Systems

This document identifies five specific, testable scientific hypotheses emerging from the formalized theory of Benford behavior in quadratic dynamical systems T_c(x) = x² + c. Each hypothesis is falsifiable and comes with a concrete computational protocol.

---

## Hypothesis 1: Prime-Height Equidistribution

**Conjecture.** For every integer c outside a finite exceptional set E, the sequence of fractional parts {2ⁿ · Λ_c(p)} is equidistributed modulo 1 as (p, n) ranges over primes p and positive integers n:

$$\lim_{X, N \to \infty} \frac{1}{\pi(X) \cdot N} \#\{(p, n) : p \le X \text{ prime}, 1 \le n \le N, \{2^n \Lambda_c(p)\} \in [a, b]\} = b - a$$

for all 0 ≤ a < b ≤ 1, where Λ_c(p) = lim_{n→∞} 2⁻ⁿ log|T_c⁽ⁿ⁾(p)| is the canonical height.

**Test.** For c ∈ {-10, ..., 10}, compute Λ_c(p) for all primes p ≤ 10⁶ using 50 iterations of the renormalized height sequence. For each c, compute the discrepancy D_N of the sequence {2ⁿ · Λ_c(p) mod 1} for n = 1, ..., 30 and primes up to X = 10⁵. The hypothesis predicts D_N = O(1/√(π(X)·N)).

**Refutation criterion.** If for any c ∉ E, the discrepancy D_N remains bounded away from zero as X, N → ∞, the hypothesis is falsified. Specifically, if D_N > 0.1 for X = 10⁵ and N = 30, the equidistribution fails for that c.

**Impact.** Combined with our Benford reduction theorem and logarithmic shadowing result, this would complete the proof of Benford universality for quadratic maps. It is the sole missing analytic input.

---

## Hypothesis 2: Semiconjugacy Rigidity

**Conjecture.** Persistent digit bias in the orbits of T_c occurs if and only if T_c is semiconjugate to a monomial map ±x^d via an integer-valued function φ satisfying φ(T_c(x)) = ±(φ(x))^d.

Formally: PersistentDigitBias(c) ⟺ HasMonomialSemiconjugacy(c).

**Test.** For each c ∈ {-100, ..., 100}:
1. Compute leading-digit frequencies for primes p ≤ 10⁴ and n ≤ 20. Flag c as "biased" if the KL divergence from Benford exceeds 0.005.
2. For each biased c, search for a semiconjugacy by testing polynomial candidates φ of degree ≤ 10 and checking the functional equation φ(x² + c) = ±(φ(x))^d modulo large primes.
3. Verify: every biased c has a semiconjugacy, and every unbiased c does not.

**Refutation criterion.** Finding a c with persistent digit bias but no semiconjugacy (or vice versa) falsifies the conjecture.

**Impact.** This would establish that digit anomalies are algebraic invariants, creating a new tool for detecting hidden structure in dynamical systems.

---

## Hypothesis 3: Base-Invariance

**Conjecture.** If the leading digits of |T_c⁽ⁿ⁾(p)| satisfy Benford's law in some base b ≥ 2 that is multiplicatively independent of 2 (i.e., log b / log 2 ∉ ℚ), then they satisfy Benford's law in every such base.

**Test.** For c ∈ {-10, ..., 10} and bases b ∈ {3, 5, 6, 7, 10, 11, 12, 15}:
1. Compute leading-digit frequencies in each base for primes p ≤ 10⁴ and n ≤ 15.
2. Compute KL divergence from the base-b Benford distribution for each (c, b) pair.
3. Check whether all bases with log b / log 2 ∉ ℚ give qualitatively similar results.

**Refutation criterion.** Finding a c and two multiplicatively independent bases b₁, b₂ (both independent of 2) such that Benford holds in b₁ but fails in b₂ would refute the hypothesis.

**Impact.** Base-invariance is predicted by the equidistribution mechanism (since equidistribution mod 1 is base-independent), so its failure would indicate a fundamentally different mechanism for digit statistics.

---

## Hypothesis 4: Entropy-Rate Decay

**Conjecture.** For generic c, the KL divergence between the empirical leading-digit distribution of {|T_c⁽ⁿ⁾(p)| : p ≤ X prime} and the Benford distribution decays exponentially in n:

$$D_{KL}(P_n \| B) \le C_c \cdot \rho^n$$

for constants C_c > 0 and 0 < ρ < 1 depending on c but not on X (for X sufficiently large).

**Test.** For c ∈ {0, 1, -1, 2, -2}:
1. For each n = 1, ..., 25, compute the leading-digit distribution of |T_c⁽ⁿ⁾(p)| for all primes p ≤ 10⁵.
2. Compute D_KL(P_n || B) for each n.
3. Fit a model D_KL = C · ρⁿ and estimate ρ by linear regression of log(D_KL) vs. n.

**Refutation criterion.** If D_KL does not decay exponentially (e.g., decays polynomially or oscillates) for any generic c, the hypothesis is falsified. Specifically, if the fitted ρ exceeds 0.99 for X = 10⁵, the exponential decay is too slow to be meaningful.

**Impact.** Exponential entropy-rate decay would connect Benford behavior to mixing properties of the doubling map, establishing an information-theoretic characterization of arithmetic chaos.

---

## Hypothesis 5: Exceptional-Set Finiteness

**Conjecture.** The exceptional set E = {c ∈ ℤ : Benford universality fails for T_c} is finite, and possibly empty.

**Test.** Scan c ∈ {-10⁶, ..., 10⁶} (or as large as computationally feasible):
1. For each c, compute the KL divergence from Benford for primes p ≤ 10³ and n ≤ 10 as a quick filter.
2. For any c flagged as potentially exceptional (KL > 0.01), refine with primes p ≤ 10⁵ and n ≤ 20.
3. Catalog all confirmed exceptional c values.

**Refutation criterion.** If the number of exceptional c values grows unboundedly with the search range (e.g., linearly in |c|), finiteness is falsified. Conversely, if no exceptions are found, the hypothesis that E is empty is supported.

**Impact.** Finiteness of E would mean that Benford behavior is a universal property of quadratic dynamics, not a special coincidence for particular parameters. This would be a foundational result in arithmetic dynamics.

---

## Summary

| # | Hypothesis | Key Observable | Refutation Signal |
|---|------------|---------------|-------------------|
| 1 | Prime-height equidistribution | Discrepancy D_N | D_N bounded away from 0 |
| 2 | Semiconjugacy rigidity | Bias ↔ semiconjugacy | Bias without semiconjugacy |
| 3 | Base-invariance | Cross-base KL divergence | Benford in b₁ but not b₂ |
| 4 | Entropy-rate decay | D_KL vs. n | Non-exponential decay |
| 5 | Exceptional-set finiteness | |E ∩ [-N,N]| vs. N | Unbounded growth |
