# Summary of changes for run d2012d6d-3bc0-4bcd-bd4e-12fbe2d1c941
## What I produced

This research cycle delivers a new, fully-proved Lean file plus a research-direction document, both required by the task.

### New Lean file: `Catalog/Speculative/AutoResearch/CarmichaelApparitionBridge.lean`
This **fuses** two previously disconnected catalog developments of the Fibonacci "rank of apparition":
- `FibApparition.apparitionRank` (the unconditional `Nat.find`-based rank, with the divisibility law `m ∣ F n ↔ apparitionRank m ∣ n`), from `Catalog/Novelty/FibApparitionExistence.lean`, and
- `FibonacciPrimitiveDivisors.IsPrimitive` (the minimality-based primitive-divisor predicate), from `Catalog/Applications/FibonacciPrimitiveDivisors.lean`.

It contains **5 theorems, all proved with `sorry = 0`**, using only the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`):
1. `isPrimitive_iff_apparitionRank_eq` — the two catalog notions of "primitive divisor" coincide: `IsPrimitive m n ↔ apparitionRank m = n` (for `0 < n`; I also showed positivity of `m` is unnecessary and removed that hypothesis).
2. `apparitionRank_dvd_of_dvd` — monotonicity under divisibility.
3. `apparitionRank_coprime_mul` — the lcm law: for coprime positive `m, n`, `apparitionRank (m·n) = lcm (apparitionRank m) (apparitionRank n)`.
4. `exists_primitive_prime_iff_exists_apparitionRank_eq` — primitive-prime-divisor existence ⇔ existence of a prime with given rank.
5. `carmichael_statement_iff_apparitionRank_surjective` — recasts Carmichael's primitive-divisor theorem as: `prime ↦ apparitionRank` is surjective onto `{n : 13 ≤ n}`.

The file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and per-theorem `-- !-- ... -- !--` proof sketches.

### Build-configuration repair
The package was misconfigured: the outer `lakefile.toml` was missing `srcDir = "Catalog"`, and neither lakefile registered the `Applications`/`Novelty` source trees as libraries, so those modules (including the catalog's existing Fibonacci work) were unreachable. I added `srcDir = "Catalog"` and `Applications`/`Novelty` `lean_lib` globs (and to `defaultTargets`) in both `lakefile.toml` and `Catalog/lakefile.toml`. The new file and its dependencies now build cleanly.

### `FUTURE_DIRECTIONS.md` (project root)
A freeform narrative with a Synthesis, a Results Summary, and 5 falsifiable research directions (prime-power recurrence for the rank; closing the composite tail via the cyclotomic primitive part Φ_n; a Fibonacci lifting-the-exponent theorem; surjectivity/density of self-ranked primes; generalization to Lucas sequences). Each direction includes a "The key insight is…" sentence, a "Why now?" justification, and a concrete falsifiable prediction.

### Note on the catalog's open holes
The existing `sorry` in `Catalog/Shared/CarmichaelProof.lean` (composite tail `n > 10000`) and the prime case are the genuinely infinite content of Carmichael's primitive-divisor theorem, which is not in Mathlib. Rather than fake those, this cycle reformulates them into the clean, fully-proved surjectivity statement above and lays out (in FUTURE_DIRECTIONS.md) the cyclotomic/LTE route to closing them next.