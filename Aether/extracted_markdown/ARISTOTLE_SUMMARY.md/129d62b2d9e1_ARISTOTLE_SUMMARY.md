# Summary of changes for run e84ef49d-4465-45f9-b4f5-f9c99f679e3e
Delivered a new, fully-verified research contribution in the Cryptography domain plus the required notes and future-directions document.

**New Lean file** — `Catalog/Cryptography/StrongDivisibilityRankSecurity.lean` (0 sorries; every theorem checked to depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` — no `native_decide`/`ofReduceBool`). It builds a general **strong divisibility sequence (SDS)** framework (`IsSDS u : u (gcd m n) = gcd (u m) (u n)`) that abstracts and connects the catalog's single-index Fibonacci entry-point / rank-of-apparition and Carmichael primitive-divisor work to a cross-index, counting level:

- SDS-driven structure: `IsSDS.dvd_of_dvd`, `IsSDS.dvd_gcd_index`, and the CRT-style `IsSDS.coprime_of_coprime_index` (normalised SDS send coprime indices to coprime terms).
- Primitivity combinatorics: `IsPrimitivePrime.unique_index` (a prime is a primitive divisor at at most one index), `primitivePrimes_disjoint`, and the smoothness lower bound `card_le_primeFactors_prod` ( |S| ≤ ω(∏_{n∈S} uₙ) ).
- Instances: `fib_isSDS`, `fib_coprime_of_coprime`, the concrete `fib_distinct_primes_ge_four` (proved through the general bound, not by brute force), and the Mersenne family `mersenne_isSDS`, `mersenne_dvd_of_dvd`, `mersenne_two_coprime_of_coprime`.

**Lab Notes** are embedded inline (`-- !-- Lab Notes -- !--`). A key documented finding: the disjointness/counting results were initially hypothesised to need the SDS gcd-law, but experimentation refuted this — they hold for arbitrary sequences from rank minimality alone, so the spurious hypothesis was dropped, strengthening the theorems. The genuinely sequence-specific content is primitive-divisor *existence* (Carmichael/Zsygmondy) and *coprimality transfer*.

**FUTURE_DIRECTIONS.md** — `Catalog/Cryptography/FUTURE_DIRECTIONS.md` lists 5 bold, falsifiable conjectures (abstract Carmichael/Zsygmondy existence for normalised growing SDS; linear-growth smoothness of Fibonacci products; a lifting-the-exponent multiset upgrade of the bound; cross-sequence CRT independence of entry points; and a conditional factoring-hardness packaging via primitive-prime congruences).

**Build fix:** the project's `lakefile.toml` was missing `srcDir`, so no `Catalog/*` module could be located (the build failed looking for `/Algebra`). Added `srcDir = "Catalog"`, after which the new module compiles against the cached Mathlib. The new file was verified with a targeted build (clean, no warnings, no sorries).