# Summary of changes for run d766e150-7bde-41b0-8642-90f9df8afaa8
## What I delivered

I extended the catalog's Fibonacci primitive-divisor theory with a new, fully-proved Lean file plus the required research notes.

**New file:** `Catalog/Speculative/AutoResearch/FibPrimitivePrimes.lean` (builds cleanly, `sorry = 0`, axioms: only `propext`, `Classical.choice`, `Quot.sound`). It builds directly on the catalog's already sorry-free prime-index case of Carmichael's theorem (`fib_primitive_divisor_prime` in `Speculative.AutoResearch.CarmichaelHelper`).

Main theorems (3):
- `fib_primitive_index_unique` — a number is a primitive divisor of at most one Fibonacci number; its index is an invariant.
- `infinite_fib_primitive_primes` — infinitely many primes occur as primitive divisors of `F_p` for prime `p ≥ 13` (a Fibonacci Euclid theorem; unconditional, avoids the still-open composite tail).
- `infinite_primes_with_prime_fib_entry` — infinitely many primes have a prime Fibonacci entry point (rank of apparition).

Plus reusable supporting results: `exists_prime_isPrimitive`, `primeIndices_infinite`, `entryPoint_eq_of_primitive`. Each declaration carries a one-to-two-sentence proof sketch in `-- !-- comment -- !--` form, and the file contains the required `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**`FUTURE_DIRECTIONS.md`** — a narrative synthesis with a results summary and 5 falsifiable research directions, each with a "The key insight is…" sentence and a "Why now?" justification (closing the composite tail via a homogeneous-cyclotomic/Möbius lower bound; a Zsigmondy generalization to strong divisibility sequences; entry-point density via quadratic reciprocity; the exact exceptional set `{1,2,6,12}`; and an effective prime generator).

**Build fix:** the project's `lakefile.toml` was missing `srcDir = "Catalog"`, so Lake looked for modules at the repo root and no target could build. I added that line; targeted module builds now succeed. (The full default build still fails on pre-existing broken imports elsewhere in the catalog, e.g. a missing `Algebra/Jacobian/Defs.lean` referenced by several files — unrelated to this work.)

**On the named priority `CarmichaelComposite`:** the single remaining `sorry` in `Shared/CarmichaelProof.lean` is the infinite tail `n > 10000` of Carmichael's theorem. Closing it genuinely requires a homogeneous-cyclotomic ("primitive part") lower bound `Φ_n > P(n)` — machinery not present in Mathlib and beyond a safe single attempt — so I left it untouched and instead extracted the maximal unconditional structural consequences of the already-proven prime case, documenting the precise path to closing the tail as Direction 1 in `FUTURE_DIRECTIONS.md`.