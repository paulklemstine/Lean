# Summary of changes for run 0483a781-ca8e-4691-9689-830fabfe9f54
## Summary of Work on Carmichael's Primitive Divisor Theorem

### What was accomplished

**1. New fully-verified Lean 4 file: `Shared/CarmichaelLargeCase.lean` (no sorries)**

This file proves the key case of Carmichael's theorem: for n = 2p where p is prime ≥ 5, F(n) has a primitive prime divisor. The proof uses the Lucas companion number L(m) = 2F(m+1) − F(m) and consists of 8 fully verified lemmas:

- `gcd_fib_lucas_dvd_two`: gcd(F(m), L(m)) divides 2
- `lucasCompanion_gt_two`: L(m) > 2 for m ≥ 3
- `lucasCompanion_odd`: L(m) is odd when 3 does not divide m
- `exists_odd_prime_dvd_lucas`: L(m) has an odd prime factor when 3 ∤ m and m ≥ 3
- `not_dvd_fib_of_dvd_of_not_dvd`: Transitivity of non-divisibility through Fibonacci divisibility
- `three_not_dvd_prime`: 3 does not divide primes ≥ 5
- `dvd_two_mul_prime`: Divisor structure of 2p for prime p ≥ 5
- `bridge_to_primitive`: Converts "no proper divisor divides" to full primitivity
- **`primitive_prime_two_mul_prime`**: The complete theorem for n = 2p

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

**2. Partial progress on `fib_carmichael_large` in `Speculative/AutoResearch/CarmichaelComposite.lean`**

The sorry was reduced from one monolithic sorry to a structured proof that handles the n = 2p case completely and identifies two remaining sub-goals:
- Even composite n > 10000 where n/2 is composite (requires the Lifting the Exponent Lemma for Fibonacci numbers)
- Odd composite n > 10000 (same requirement)

**3. Partial progress on `fib_carmichael_composite` in `Shared/CarmichaelProof.lean`**

Same structure: the n = 2p case is now fully proved, with clear remaining sorries for the other cases.

**4. Python demonstration** (`Speculative/AutoResearch/carmichael_demo.py`)

Interactive demo showing primitive prime divisors, the Lucas companion argument, entry point distributions, and visualizations.

**5. Research paper** (`Speculative/AutoResearch/carmichael_paper.md`)

Mathematical paper explaining the proof strategy, key results, connections to Zsygmondy's theorem, and a Scientific American-style discussion section.

### What remains (the two sorries)

The remaining sorries both require formalizing the **Lifting the Exponent Lemma (LTE) for Fibonacci numbers**: for odd prime r with entry point z(r) dividing n, v_r(F(n)) = v_r(F(z(r))) + v_r(n/z(r)). This is substantial number-theoretic infrastructure not present in Mathlib. Combined with bounds on the cyclotomic primitive part, the LTE would complete the proof for all composite n.

### Files modified/created
- **Created**: `Catalog/Shared/CarmichaelLargeCase.lean` (80 lines, fully verified)
- **Modified**: `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` (sorry reduced to 2 targeted sub-goals)
- **Modified**: `Catalog/Shared/CarmichaelProof.lean` (sorry reduced to 2 targeted sub-goals)
- **Created**: `Catalog/Speculative/AutoResearch/carmichael_demo.py`
- **Created**: `Catalog/Speculative/AutoResearch/carmichael_paper.md`