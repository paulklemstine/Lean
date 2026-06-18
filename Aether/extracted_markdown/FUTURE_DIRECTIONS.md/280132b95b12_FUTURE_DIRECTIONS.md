# Future Directions: Odd Perfect Number Obstruction Theory

## Hypothesis 1: Support-Growth Monotonicity

**Conjecture:** For any odd prime p and any odd exponent a ≥ 1, define the support growth function
```
G(p, a, k) = |{odd primes q ≠ p : q appears in the k-level cascade of sigmaPP(p, a)}|
```
Then G(p, a, k) is strictly increasing in k for all (p, a) surviving the 2-adic constraint v₂(sigmaPP(p, a)) = 1, and G(p, a, k) → ∞ as k → ∞.

**Test:** Compute G(p, a, k) for all odd primes p < 1000 and odd a ≤ 21, for k = 0, 1, ..., 10. Check:
- Is G(p, a, k+1) > G(p, a, k) for all tested (p, a, k)?
- Does G(p, a, k) grow at least linearly in k?
- Are there (p, a) pairs where growth stalls?

**Impact:** If true, this would formally establish that any odd perfect number requires infinitely many prime factors in a precise cascade sense — not quite a proof of nonexistence, but a strong structural barrier. If false, the exceptions identify the most "dangerous" Euler candidates that deserve focused computational attack.

## Hypothesis 2: Valuation Absorption Depth

**Conjecture:** For any odd prime p ≡ 1 (mod 4) and odd a with v₂(sigmaPP(p, a)) = 1, every prime divisor q of sigmaPP(p, a) / 2 (the odd part) satisfies:
```
v_q(sigmaPP(p, a)) ≤ v_q(m²) = 2 · v_q(m)
```
and in particular, if v_q(sigmaPP(p, a)) ≥ 3, then v_q(m) ≥ 2, forcing q^4 | n. More precisely, the "valuation debt" of sigmaPP(p, a) at q must be "repaid" by m with at least half the exponent.

**Test:** For p < 500 and a ∈ {1, 5, 9, 13}, compute the factorization of sigmaPP(p, a) and identify primes q with high valuations (v_q ≥ 3). For each such q, verify that the constraint v_q(m) ≥ ⌈v_q(sigmaPP)/2⌉ is consistent with further cascade constraints (i.e., that it doesn't create an immediate contradiction).

**Impact:** If the valuation debt creates contradictions for specific (p, a) pairs, those are eliminated as Euler candidates. This provides a finer-grained obstruction than simple prime injection, potentially eliminating many surviving candidates.

## Hypothesis 3: Iterated Radical Explosion

**Conjecture:** Define the operator T on odd squarefree-times-prime-power numbers:
```
T(n) = rad(σ₁(n)) / gcd(rad(σ₁(n)), rad(n))
```
This operator extracts "genuinely new" prime content from σ₁. For any n of Euler form n = p^a · m² with odd perfectness constraints:
```
|primeFactors(T^k(n))| → ∞ as k → ∞
```
where T^k denotes k-fold iteration.

**Test:**
1. Start with small Euler-form candidates (e.g., n = 5^1 · 3² · 13² · ...).
2. Compute T(n), T²(n), ..., T^10(n), tracking the number of new prime factors introduced at each step.
3. Check whether the new-prime count stabilizes or grows.

**Impact:** If the iteration always generates new primes, it provides a dynamical obstruction to odd perfectness: the system cannot reach a fixed point. Formalizing this would convert the odd perfect number problem into a statement about the dynamics of arithmetic functions on exponent lattices.

## Hypothesis 4: Modular Obstruction Completeness

**Conjecture:** For modulus M = 120 (= 2³ · 3 · 5), the combined modular constraints on (p mod M, a mod M, sigmaPP(p, a) mod M) are sufficient to eliminate all but at most 5% of (p, a) pairs that survive the 2-adic constraint alone.

More precisely: define a (p, a) pair as "mod-M compatible" if:
- p ≡ 1 (mod 4) and p is odd
- a is odd
- v₂(sigmaPP(p, a)) = 1
- sigmaPP(p, a) mod M is consistent with the absorption and cascade constraints modulo M

Then the density of mod-M compatible pairs among all surviving pairs approaches 0 as M → ∞.

**Test:**
1. For M = 4, 8, 12, 24, 60, 120, tabulate the compatible residue classes.
2. Compute the fraction of (p, a) pairs (with p < 10000) that pass all mod-M tests.
3. Plot the survival rate versus M.

**Impact:** If the survival rate decays exponentially in log(M), this suggests that purely local (modular) constraints may be sufficient to eliminate all candidates — approaching a proof of nonexistence via local obstruction certificates. Even polynomial decay would be a significant theoretical result.

## Hypothesis 5: Cascade Contradiction for Small Support

**Conjecture:** No odd perfect number can have fewer than 8 distinct prime factors. More precisely: if n = p^a · m² is odd perfect with gcd(p, m) = 1 and |primeFactors(n)| ≤ 7, then the cascade of forced prime factors from sigmaPP(p, a) generates a contradiction.

**Test:**
1. Enumerate all possible support sets S with |S| ≤ 7 consisting of odd primes.
2. For each S, check if there exists p ∈ S, a odd, and exponents {e_q : q ∈ S} such that:
   - n = p^a · ∏_{q ∈ S\{p}} q^(2e_q) satisfies σ₁(n) = 2n
   - All cascade constraints from Theorems 5.1-5.3 are satisfied
3. This is a finite (though large) computation.

**Impact:** The current best lower bound on the number of prime factors is 101 (Nielsen 2015), but that proof is computational and unverified. A formally verified bound of even 8 would be a significant achievement, and the framework developed here provides the tools to attempt it. Success at 8 would establish the methodology for pushing toward the full bound.

---

## Experimental Protocol

Each hypothesis should be tested with the following protocol:

1. **Computational sweep:** Run the relevant computation for all parameters in the specified range.
2. **Counterexample search:** Actively seek (p, a) pairs that violate the conjecture.
3. **Formal statement:** If no counterexample is found, formalize the conjecture as a Lean theorem with `sorry`.
4. **Decomposition:** Break the conjecture into lemmas addressable by the theorem-proving infrastructure.
5. **Verification:** Prove the lemmas and verify the full theorem.

The expected timeline for each hypothesis is 1-3 research cycles, with Hypothesis 5 potentially requiring the most computational resources and Hypothesis 1 being the most accessible starting point.
