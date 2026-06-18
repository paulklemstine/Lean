# Answers to Open Questions — Version 8

## Questions Answered in v8

### Q1: Does every even perfect number have Euclid's form?
**ANSWER: YES** ✓ Formally proved in `EulerDirectionComplete.lean`.

Every even perfect number n satisfies n = 2^(p-1)(2^p - 1) where 2^p - 1 is a Mersenne prime. The proof proceeds by decomposing n = 2^k · m with m odd, deriving the key equation (2^(k+1)-1)σ₁(m) = 2^(k+1)m, showing m = 2^(k+1)-1, and proving m is prime.

**Lean theorem**: `even_perfect_euclid_form`

### Q2: Must the exponent in a Mersenne prime 2^n - 1 be prime?
**ANSWER: YES** ✓ Formally proved in `EulerDirectionComplete.lean`.

If 2^n - 1 is prime and n = ab with a,b > 1, then (2^a - 1) | (2^n - 1) and 1 < 2^a - 1 < 2^n - 1, contradicting primality. Therefore n must be prime.

**Lean theorem**: `exponent_prime_of_mersenne_prime`

### Q3: What is σ₁(pq) for distinct primes p, q?
**ANSWER: σ₁(pq) = 1 + p + q + pq** ✓ Formally proved in `SigmaFactoringEquivalence.lean`.

The divisors of pq are exactly {1, p, q, pq}, giving σ₁(pq) = 1 + p + q + pq.

**Lean theorem**: `sigma1_semiprime_formula`

### Q4: Does Cassini's identity hold?
**ANSWER: YES** ✓ F(n)² - F(n-1)·F(n+1) = (-1)^(n+1), formally proved in `WallSunSun.lean`.

Proved by strong induction using the Fibonacci recurrence.

**Lean theorem**: `cassini_identity`

### Q5: What are the entry point bounds for Fibonacci modulo a prime?
**ANSWER: The entry point divides p-1 or p+1** ✓ Formally proved in `WallSunSun.lean`.

For every prime p ≠ 2, 5, there exists k > 0 with p | F(k) and (k | p-1 ∨ k | p+1). The proof uses Cassini's identity and F(p) ≡ ±1 (mod p).

**Lean theorem**: `entry_point_bound`

---

## Questions Partially Answered in v8

### Q6: Can σ₁(n) = n + 1 characterize primes?
**PARTIALLY ANSWERED** ✓ One direction proved: σ₁(n) = n+1 and n > 1 implies n is prime.

**Lean theorem**: `prime_of_sigma1`

The converse (n prime implies σ₁(n) = n+1) is also proved as `sigma1_prime`.

### Q7: Are Fibonacci pseudoprimes a proper subset of composites?
**PARTIALLY ANSWERED** ✓ Proved that pseudoprimes ⊆ composites. Density bounds remain open.

**Lean theorem**: `fib_pseudo_subset_composite`

### Q8: Are 1093 and 3511 Wieferich primes?
**PARTIALLY ANSWERED** ✓ Their primality is verified. The divisibility 1093² | 2^1092 - 1 is stated but the computation is too large for Lean's `native_decide`.

**Lean theorems**: `wieferich_1093`, `wieferich_3511` (with sorry for large computation)

---

## Questions Remaining Open

### Q9: Do odd perfect numbers exist?
**STILL OPEN**. No odd perfect number is known. It's proven that none exist below 10^1500. Our formalization verifies that no odd number below 100 is perfect (`no_small_odd_perfect` from v7).

### Q10: Do Wall-Sun-Sun primes exist?
**STILL OPEN**. No WSS prime found below 10^13. We formalized the definition and proved no prime below 20 is WSS.

### Q11: What is the density of Fibonacci pseudoprimes?
**STILL OPEN**. Computational experiments suggest density → 0. Requires Carmichael's primitive divisor theorem for a formal proof.

### Q12: Can Hurwitz quaternion factoring be made polynomial-time?
**STILL OPEN**. We verified the mathematical foundations (norm multiplicativity, Euler identity, Lagrange). The algorithm design and complexity analysis remain.

### Q13: Can persistent homology detect factors?
**STILL OPEN**. We formalized the sublevel filtration and birth time framework. Computing actual barcodes and connecting them to factoring remains future work.

### Q14: Is there a polynomial-time algorithm for computing Pisano periods?
**STILL OPEN**. This is related to the discrete logarithm problem. We proved π(p) | p²-1 for primes, but efficient computation for composites is unknown.

### Q15: Can quantum algorithms exploit four-square representations?
**STILL OPEN**. The Euler identity provides product structure that could potentially be exploited by quantum period-finding, but this is speculative.

---

## New Questions Discovered in v8

### Q16: Can the Cassini identity be generalized to detect composite structure?
For composite n = pq, does F(n)² - F(n-1)F(n+1) reveal information about p and q beyond what F(n) mod n gives? The answer relates to the Fibonacci entry points of p and q.

### Q17: What is the relationship between energy landscape moments and τ(N)?
We proved Σ E(N,x) ≤ N² and Σ E(N,x)² ≤ N³. Can tighter bounds be expressed in terms of τ(N)?

### Q18: Can the σ₁ primality characterization be made efficient?
We proved σ₁(n) = n+1 ↔ n prime. But computing σ₁(n) exactly requires knowing all divisors. Can an approximation suffice?

### Q19: What is the structure of Fibonacci pseudoprime sets?
Are there infinite families of Fibonacci pseudoprimes with special structure (e.g., products of specific primes)?

### Q20: Can entry point factoring compete with Pollard's rho?
The entry point α(N) satisfies gcd(F(α(N)), N) > 1. How does computing α(N) compare to other factoring methods in practice?

---

## Summary Statistics

| Category | v7 | v8 | Change |
|----------|-----|-----|--------|
| Total theorems | 130+ | 145+ | +15+ |
| Files | 7 | 13 | +6 |
| Answered questions | 18 | 23 | +5 |
| Open questions | 10 | 15+ | +5 new |
| Python demos | 14 | 17 | +3 |
| SVG visuals | ~12 | ~16 | +4 |
| Sorry count | ~4 | ~10 | +6 (more ambitious statements) |
