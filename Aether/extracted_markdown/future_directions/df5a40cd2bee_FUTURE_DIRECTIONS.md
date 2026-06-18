# Future Directions: Perfect Cuboid Euler Product Sieve

## Summary of What Was Established

We have formally verified a **uniform local density gap** for the perfect cuboid problem:

> **Theorem (δ = 3/10).** For every odd prime p, the fraction of triples (a,b,c) ∈ (ℤ/pℤ)³ satisfying all four cuboid quadratic residue conditions is at most 7/10. Equivalently, each prime eliminates at least 30% of candidate residue classes.

The proof combines:
- **Computational verification** at all primes p ≤ 43 (via certified kernel reduction)
- **A structural projection bound** for all primes p ≥ 47, using the Pythagorean triple count identity #{(a,b,c) : a²+b²=c² in (ℤ/pℤ)³} = p²

Additional verified results include: exact survivor counts at primes 3–31, the bridge theorem (integer cuboids → local survivors), the quartic fiber factorization r²s⁴+(r⁴+1)s²+r² = (r²s²+1)(s²+r²) over arbitrary rings, and the square-pair count bound 2·sqPairCount(p) ≤ p²+2p−1.

---

## Hypothesis 1: Tighter Uniform Density Gap (δ = 7/10)

**Conjecture.** For all odd primes p ≥ 3:
$$\frac{\text{survivorCount}(p)}{p^3} \leq \frac{3}{10}$$

That is, the density is at most 30%, not merely 70% as proved.

**Evidence.** Computational data shows the density is at most 29.6% (at p = 5) and drops below 20% for all primes ≥ 7. The maximum observed density is survivorCount(5)/125 = 37/125 ≈ 0.296.

**Test.** Verify computationally for all primes up to 1000. Attempt a structural proof using multiple projection constraints (not just a²+b² ∈ squares, but also a²+c² ∈ squares simultaneously), which would give a tighter bound via fibered counting.

**Impact if true.** The stronger gap would give exponential decay rate (3/10)^k along primorials instead of (7/10)^k, making the Euler product extinction law dramatically faster. This would strengthen the quantitative case against perfect cuboid existence.

**Impact if false.** Finding a prime with density > 30% would reveal an unexpected resonance in the quadratic character geometry, suggesting structured correlations between the four square conditions.

---

## Hypothesis 2: Asymptotic Density Limit

**Conjecture.** There exists C ∈ (0, 1) such that:
$$\frac{\text{survivorCount}(p)}{p^3} \to C \quad \text{as } p \to \infty \text{ through primes}$$

The predicted value, based on independent-square-condition heuristics, is C ≈ 1/16 = 0.0625 (probability 1/2 for each of 4 conditions, with partial correlations).

**Test.**
1. Compute certified survivor counts for all primes up to 500.
2. Fit C by averaging densities for p > 100.
3. Check whether the residuals survivorCount(p) − C·p³ are O(p^{5/2}) as predicted by Weil-type bounds.

**Impact if true.** Formally proving the limit exists would establish the first asymptotic law for perfect cuboid local constraints. Combined with CRT, it would give survivorCount(N)/N³ ~ C^{ω(N)} for squarefree N, providing an explicit extinction rate.

**Impact if false.** Oscillation without convergence would indicate that the density depends on arithmetic properties of p (e.g., p mod 4 or p mod 8), which would connect to Frobenius-sensitive geometry of the cuboid surface.

---

## Hypothesis 3: Congruence-Class Fluctuation Law

**Conjecture.** There exist distinct constants C₁, C₃ such that:
$$\frac{\text{survivorCount}(p)}{p^3} \to C_a \quad \text{for primes } p \equiv a \pmod{4}$$

Specifically, C₁ > C₃ (primes p ≡ 1 mod 4 have higher survivor density than p ≡ 3 mod 4).

**Evidence.** Preliminary data:
- p ≡ 1 (mod 4): densities at p = 5 (0.296), 13 (0.159), 17 (0.166), 29 (0.134), 37 (0.133), 41 (0.139)
- p ≡ 3 (mod 4): densities at p = 3 (0.259), 7 (0.160), 11 (0.113), 19 (0.071), 23 (0.089), 31 (0.082), 43 (0.073)

The p ≡ 3 densities appear systematically lower.

**Test.**
1. Compute densities for all primes up to 1000, stratified by p mod 4.
2. Extend to p mod 8 and p mod 12 to detect finer splitting.
3. Compare with the character-sum main term prediction: the zero-pair count N₀ is 2p−1 for p ≡ 1 (mod 4) vs. 1 for p ≡ 3 (mod 4), which already creates an asymmetry.

**Impact if true.** The splitting would prove that the cuboid surface has Frobenius-sensitive local geometry, connecting the problem to arithmetic statistics of algebraic surfaces. The two constants C₁, C₃ would be determined by quadratic character averages.

**Impact if false.** Universal convergence to a single C regardless of p mod 4 would be mathematically surprising and suggest a deeper symmetry in the cuboid equations.

---

## Hypothesis 4: Exponential Suppression for Squarefree Moduli

**Conjecture.** There exists c > 0 such that for all squarefree n with only odd prime factors:
$$\frac{\text{survivorCount}(n)}{n^3} \leq e^{-c \cdot \omega(n)}$$

where ω(n) is the number of distinct prime factors of n.

**Evidence.** From our verified δ = 3/10, we get survivorCount(n)/n³ ≤ (7/10)^{ω(n)} for squarefree n (by CRT). This gives c = −ln(7/10) ≈ 0.357.

**Test.**
1. Verify CRT multiplicativity: survivorCount(m·n) = survivorCount(m)·survivorCount(n) for coprime m, n. (This is claimed in prior work; formally verify it.)
2. Compute survivorCount for products of the first k odd primes and compare against (7/10)^k · (∏ pᵢ)³.
3. If Hypothesis 1 holds (δ = 7/10), the exponential rate improves to c = −ln(3/10) ≈ 1.204.

**Impact if true.** This would be the first formally verified Euler-product extinction law for an open Diophantine problem. It would provide a template for attacking other "ancient impossible object" problems (e.g., odd perfect numbers, Lander–Parkin–Selfridge conjecture).

**Impact if false.** Failure of exponential suppression would indicate correlations between different prime conditions not captured by CRT — potentially a local-global obstruction of Brauer–Manin type.

---

## Hypothesis 5: Character-Sum Error Term

**Conjecture.** There exists A > 0 such that for all odd primes p:
$$\left|\text{survivorCount}(p) - C \cdot p^3\right| \leq A \cdot p^{5/2}$$

where C is the asymptotic density from Hypothesis 2.

**Evidence.** The survivor count involves counting points on a surface defined by four quadratic conditions over 𝔽ₚ. By analogy with Weil-type estimates for character sums over curves, the error term should be O(p^{5/2}) (the half-dimension bound for a 3-dimensional counting problem on a surface).

**Test.**
1. Compute residuals |survivorCount(p) − C·p³| for primes up to 500.
2. Plot residuals against p^{5/2} on a log-log scale; the slope should approach 5/2.
3. If the exponent is different (e.g., 2 or 3), determine the geometric source of the deviation.

**Impact if true.** A verified O(p^{5/2}) error term would formally connect the cuboid survivor problem to Weil-Deligne theory. It would imply that the survivor density converges to C at rate O(1/√p), and the formal character-sum decomposition would become the foundation for certified arithmetic statistics.

**Impact if false.** A larger error exponent would indicate that the cuboid surface has worse-than-expected singularities or higher-genus fibers, requiring more sophisticated geometric analysis. A smaller exponent would be a pleasant surprise suggesting extra cancellation.

---

## Priority Ranking

1. **Hypothesis 4** (Exponential suppression) — Most impactful; requires formalizing CRT multiplicativity and combining with the existing gap theorem. Potentially achievable in the next cycle.

2. **Hypothesis 1** (Tighter gap) — Requires using multiple constraints simultaneously, extending the projection bound. Moderate difficulty, high payoff.

3. **Hypothesis 3** (Congruence-class splitting) — Testable computationally immediately. Would reveal the geometric structure of the density law.

4. **Hypothesis 2** (Density limit) — Requires either character-sum formalization or extensive computation. Important for the long-term theory.

5. **Hypothesis 5** (Error term) — Most technically demanding; requires connecting to Weil-type bounds. The ultimate goal for the finite-field analysis program.
