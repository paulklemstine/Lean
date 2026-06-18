# Summary of changes for run 045251c0-cd0c-4eb0-883f-7f1a1bd17c8e
# Carmichael's Theorem for Fibonacci Numbers — Partial Formalization

## What Was Accomplished

### Lean 4 Formalization (`RequestProject/CarmichaelComputational.lean`)

I built a substantial formalization of Carmichael's primitive divisor theorem for Fibonacci numbers. The theorem states: for every composite n ≥ 13, F(n) has a **primitive prime divisor** — a prime p dividing F(n) but not dividing F(k) for any 0 < k < n.

**Proved lemmas (7 out of 8):**
1. `removeFactors_dvd` — the factor-removal function returns a divisor
2. `removeFactors_coprime` — the result is coprime to the removed factor
3. `removeFactors_le` — the result is ≤ the input  
4. `fibPrimPart_dvd_fib` — the primitive part divides the Fibonacci number
5. `fibPrimPart_coprime_proper_div` — the primitive part is coprime to F(d) for all proper divisors d of n
6. `fibPrimPart_gt_one_implies_primitive` — **Bridge Lemma**: if the primitive part exceeds 1, a primitive prime exists (uses `Nat.fib_gcd`)
7. `fibPrimPart_gt_one_le_100000` — **Computational verification**: all composite n in [13, 100000] have primitive part > 1 (via `native_decide`)

**Entry point theory (proved):**
- `fib_entry_exists` — every prime has a Fibonacci entry point (Pigeonhole argument)
- `fib_entry_dvd` — if p | F(n), then the entry point of p divides n (uses `Nat.fib_gcd` and minimality)

**Lucas companion lemmas (proved):**
- `gcd_lucas_fib_dvd_two` — gcd(L(m), F(m)) | 2 (key for the p=2 LTE case)
- `lucas_ge_three` — L(m) ≥ 3 for m ≥ 2

**Remaining sorry (1):**
- `fibPrimPart_gt_one_gt_100000` — For composite n > 100,000, the primitive part exceeds 1. This requires the **Lifting-the-Exponent lemma for Fibonacci** (the congruence F(pm)/F(m) ≡ ±p mod F(m) for odd primes p) and recursive analysis for multi-prime composites. This is deep number theory infrastructure not currently in Mathlib.

### Python Demos (`demos/`)
- `carmichael_demo.py` — Verifies the theorem computationally, shows entry point distribution, factorization examples
- `applications.py` — Demonstrates three applications: compositeness testing, Fibonacci factorization via entry points, Pisano period computation

### Research Paper (`research_paper.md`)
A self-contained paper explaining the proof architecture, the role of the strong divisibility sequence property, entry point theory, and the Lifting-the-Exponent lemma. Includes a Scientific American-style discussion section with an accessible analogy.

## What Remains

The main theorem `fib_composite_has_primitive` has **one remaining sorry** flowing from `fibPrimPart_gt_one_gt_100000`. Completing this requires formalizing the Lifting-the-Exponent lemma for Fibonacci numbers: for odd prime p and m ≥ 1, the congruence F(pm)/F(m) ≡ ±p (mod F(m)), which implies gcd(F(pm)/F(m), F(m)) | p. The proof proceeds via the Chebyshev recurrence D_{k+1} = L·D_k − (−1)^m·D_{k−1} modulo F(m), using the Cassini identity L² ≡ 4(−1)^m. This is a well-understood but technically demanding piece of algebraic number theory whose formalization would be a valuable addition to Mathlib.