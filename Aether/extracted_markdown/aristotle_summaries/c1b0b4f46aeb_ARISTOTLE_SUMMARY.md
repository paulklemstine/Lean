# Summary of changes for run f66ba2a7-055b-4a86-a6d8-1b59dc7d6510
## Summary of Work: Carmichael's Theorem — Composite Case

### What was accomplished

I built a substantial formalization toward Carmichael's theorem (that every Fibonacci number F_n with n > 12 and n composite has a primitive prime divisor) in Lean 4 with Mathlib, along with Python demonstrations and a research paper.

### Lean Formalization (3 files)

**`RequestProject/FibEntry.lean`** — ✅ Fully proved (0 sorry)
- Entry point existence: every prime p has a smallest k > 0 with p | F_k (proved via pigeonhole)
- Entry point divides: if p | F_n then α(p) | n (proved using `Nat.fib_gcd`)
- The clean equivalence p | F_n ↔ α(p) | n

**`RequestProject/CarmichaelHelpers.lean`** — ✅ Fully proved (0 sorry)
- **Quotient GCD bound**: gcd(F_{km}/F_m, F_m) | k — the key algebraic lemma proved via the congruence F_{km} ≡ k·F_m·F_{m-1}^{k-1} (mod F_m²)
- **Growth bounds**: F_{km} > F_m for k ≥ 2, m ≥ 2; F_n > 1 for n ≥ 3
- **Coprime product**: gcd(a,b) = 1 implies F_a·F_b | F_{ab}

**`RequestProject/CarmichaelProof.lean`** — 2 sorry remaining
- ✅ Proved: reduction from "p ∤ F_k for all k" to "p ∤ F_d for all proper divisors d | n" (using `Nat.fib_gcd`)
- ✅ Proved: the main theorem follows from the helper lemma `fib_quotient_has_new_prime`
- ❌ Open: `fib_quotient_has_new_prime` — showing that F_{pm}/F_m has a prime factor ≠ p. This requires proving the quotient is not a pure prime power, which needs either the Lifting-the-Exponent lemma for Lucas sequences or cyclotomic theory beyond current Mathlib coverage.

### Python Demos (`demos/`)
- `carmichael_demo.py`: Comprehensive demo showing:
  - Computational verification of the theorem for composite n from 14 to 50
  - Entry point tables for primes up to 97
  - Verification of the GCD identity gcd(F_m, F_n) = F_{gcd(m,n)}
  - Verification of the quotient GCD bound
  - Matplotlib visualizations saved to `demos/carmichael_visualization.png`

### Research Paper (`paper/carmichael_paper.md`)
- Complete mathematical paper with: abstract, mathematical framework, formalization details, computational verification, accessible discussion section, applications (cryptography, primality testing, combinatorics), and future directions.

### Key Mathematical Insight
The proof architecture reduces Carmichael's theorem to a single algebraic fact: the quotient F_{pm}/F_m (where p is the smallest prime factor of composite n and m = n/p) always has a prime factor different from p. This follows from the quotient GCD bound gcd(Q, F_m) | p combined with showing Q is not a pure power of p — a fact that requires the Lifting-the-Exponent framework for Lucas sequences.