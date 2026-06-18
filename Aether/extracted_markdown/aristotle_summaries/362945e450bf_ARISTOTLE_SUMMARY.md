# Summary of changes for run 23925fdd-39b4-41f2-ae48-22def70f600d
## Summary

The target was the single open `sorry` in `Catalog/Shared/CarmichaelProof.lean`: the **composite, large-index tail of Carmichael's primitive-divisor theorem** for the Fibonacci sequence (every composite `n > 10000` makes `F n` have a primitive prime divisor). Investigation showed this `sorry` is the *unique* mathematical gap across the whole catalog's Carmichael development (`CarmichaelComposite`, `FibPrimitive`, `CarmichaelPrimitiveDivisor` all route through it), and that fully closing it is a research-grade formalization requiring two pieces absent from Mathlib: cyclotomic integrality of the Fibonacci primitive part and a Fibonacci lifting-the-exponent theorem.

### What was delivered (all verified, `sorry = 0`)

**New file `Catalog/Shared/CarmichaelReduction.lean` — 4 theorems:**
- `Nat.exists_prime_dvd_quot_of_dvd_lt` — every proper divisor sits under a maximal proper divisor `n/q` (`q` prime).
- `Nat.fib_dvd_fib_iff` — the strong divisibility law `F m ∣ F n ↔ m ∣ n` for `3 ≤ m`.
- `fib_nonprimitive_dvd_fib_maximal` — non-primitive prime divisors already divide some `F (n/q)`.
- `fib_primitive_iff_not_dvd_maximal` — **main reduction**: a primitive divisor exists iff some prime `p ∣ F n` divides none of the finitely many `F (n/q)` (collapsing an infinite condition to a finite one).

**New file `Catalog/Shared/CarmichaelSizeBound.lean` — 4 theorems (analytic foundations of the size estimate):**
- `goldenRatio_sq` (`φ² = φ + 1`), the two-sided Binet bounds `fib_le_goldenRatio_pow`/`goldenRatio_pow_le_fib` (`φ^(n-1) ≤ F(n+1) ≤ φ^n`), and the Möbius–totient identity `sum_moebius_mul_div_eq_totient` (`∑_{d∣n} μ(n/d)·d = φ(n)`).

**Build repairs:** set the package source root to `Catalog` in `lakefile.toml` (the project did not build at all before), added the thin re-export `Catalog/Shared/CarmichaelHelper.lean`, and fixed two pre-existing broken files in the Carmichael area (a malformed header in `FibPrimitive.lean` and a wrong import path in `CarmichaelPrimitiveDivisor.lean`). The Carmichael development now builds cleanly.

**Documentation:** `FUTURE_DIRECTIONS.md` with 5 falsifiable research directions (each with a "key insight" and a "why now"), and lab-notebook blocks in both new files.

### Status of the target `sorry`
It remains, now reduced and thoroughly documented in place. The honest reason: it is Carmichael's theorem, and its remaining analytic core (the Binet–Möbius lower bound on the primitive part, its cyclotomic integrality, and Fibonacci lifting-the-exponent with the `p = 2, 5` cases) is a large body of theory not present in Mathlib. The structural reduction and the analytic foundations needed for that core are now in place as the verified groundwork for a follow-up cycle; the remaining steps are spelled out in `FUTURE_DIRECTIONS.md` (Directions 1 and 2).