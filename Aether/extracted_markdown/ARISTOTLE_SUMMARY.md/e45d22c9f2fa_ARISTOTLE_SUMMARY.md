# Summary of changes for run f15690b0-8cc0-4bcc-a8cc-fe1eab84c960
## Phase A research cycle — Novelty domain (strong divisibility / Fibonacci entry-point theory)

### New Lean file
`Catalog/Novelty/StrongDivIndexReconstruction.lean` — fully self-contained (`import Mathlib`), elaborates cleanly, **zero `sorry`**, and depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`), verified via `#print axioms`.

### What it proves (6 theorems, all complete)
This deepens the catalog's existing primitivity results (`StrongDivSeq.primitive_divisor_inj`, `fib_primitive_divisor_inj`, `mersenne_primitive_divisor_inj` in `Catalog/Novelty/FibonacciEntryPointInvariant.lean`). The catalog showed a modulus is a primitive divisor of *at most one* term; this cycle shows the *entire* index divisibility order is recoverable from the terms.

- `StrongDivIndex.lt_of_lt_index` — order envelope: monotone + strictly-increasing-on-`[2,∞)` sequences separate `u m` from all earlier terms for `m ≥ 3`.
- `StrongDivIndex.strongDiv_dvd_iff_index` — **main theorem**: for any strong divisibility sequence (`gcd(u m)(u n) = u(gcd m n)`) that is monotone and strictly increasing on `[2,∞)`, `u m ∣ u n ↔ m ∣ n` whenever `m ≥ 3`.
- `StrongDivIndex.isLeast_index_self` — self-apparition: `m` is the least positive `k` with `u m ∣ u k`; the rank of apparition of the term `u m` equals its own index.
- `fib_dvd_iff_index` — Fibonacci instance `fib m ∣ fib n ↔ m ∣ n` (`m ≥ 3`); its forward direction is not in Mathlib, which provides only the converse `Nat.fib_dvd`.
- `fib_index_boundary` — Critic's sharp boundary: the `m ≥ 3` threshold is necessary; the equivalence fails at `m = 2` since `fib 2 = 1` divides every Fibonacci number.
- `mersenne_dvd_iff_index` — cross-domain instance: `a^m - 1 ∣ a^n - 1 ↔ m ∣ n` for base `a ≥ 2`, the same abstract theorem transferred via `Nat.pow_sub_one_gcd_pow_sub_one`.

### Notes (first-class deliverables)
- A `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and proof-sketch docstrings are embedded in the file. Key recorded failure: assuming `StrictMono u` globally is false for Fibonacci (`fib 1 = fib 2`); the correct hypotheses are `Monotone u` + `StrictMonoOn u (Set.Ici 2)`, which also exposes the sharp threshold.
- `FUTURE_DIRECTIONS.md` (at project root) with the required `## Synthesis`, `## Results Summary`, and 5 falsifiable `## Research Directions`, each with a "Why now" justification and if-true/if-false analysis. Highlighted next target: closing the single open `sorry` in `Catalog/Shared/CarmichaelProof.lean` (the infinite composite tail of Carmichael's Fibonacci primitive-divisor theorem), for which the now-formal index bookkeeping (`isLeast_index_self`) supplies the index side.

I did not modify any pre-existing catalog files; the existing `Carmichael` tail `sorry` was left untouched and documented as the top future direction rather than altered.