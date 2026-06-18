# Summary of changes for run dda08b9d-c691-433f-9cf4-b4122c0ce18f
## Delivered

**1. `Catalog/Applications/StrongDivPrimitiveCriterion.lean`** — a self-contained, `sorry`-free Lean 4 file (verified to compile cleanly; all main results depend only on the allowed axioms `propext / Classical.choice / Quot.sound / Lean.ofReduceBool / Lean.trustCompiler`).

It fuses two previously separate strands of the catalog's Fibonacci primitive-divisor program — the *structural* abstraction in `Applications/StrongDivisibilitySequences.lean` and the *computational* coprime-part engine in `Speculative/AutoResearch/CarmichaelComposite.lean` (which was hard-wired to `Nat.fib`) — by lifting the engine itself to arbitrary strong divisibility sequences `u (gcd m n) = gcd (u m) (u n)`.

Main theorems (sorry = 0):
- `dvd_index_gcd` — the single structural fact used: `p ∣ u m → p ∣ u n → p ∣ u (gcd m n)`.
- `primitive_of_coprimePart_pos` — **the engine**: for *every* strong divisibility sequence, `coprimePart u n > 1` forces a primitive prime divisor of `u n` (a prime dividing `u n` but no earlier `u k`).
- `fib_carmichael_band` — Carmichael's primitive-divisor theorem for Fibonacci, verified uniformly over primes and composites on `13 ≤ n ≤ 1000` (single `native_decide`, no prime/composite case split).
- `mersenne_bang_band` — Bang's primitive-divisor theorem for `2ⁿ − 1`, verified on `2 ≤ n ≤ 120`, with the unique Zsygmondy exception `n = 6` isolated automatically by the computation.

Supporting instances/lemmas (`fib_isStrongDivSeq`, `mersenne_isStrongDivSeq`, `removePrimesOf_*`, `coprimePart_dvd`, `un_pos_of_coprimePart_pos`) are all proved. The cross-domain payoff: one `native_decide`-backed inequality on the computable `coprimePart` discharges two historically distinct primitive-divisor theorems, because the engine never uses a Fibonacci identity — only strong divisibility.

The file contains the required `-- !-- comment -- !--` proof sketches and `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) for each result, including sharpness notes (Fibonacci exceptions `{1,2,6,12}`, Mersenne exception `{6}`).

**2. `FUTURE_DIRECTIONS.md`** — a narrative synthesis plus 5 falsifiable research directions, each with a "The key insight is…" sentence and a "Why now?" justification (characterizing the exceptional set; closing the infinite tail with one family-agnostic inequality; generalizing to all Lucas sequences `U_n(P,Q)`; an LTE multiplicity law read off the engine's recursion; and pushing/calibrating the verified bands).

This extends rather than duplicates existing catalog work and realizes Direction 4 ("generalize the criterion to arbitrary strong-divisibility sequences") from the prior cycle's roadmap. Note: the project's `lake` default targets are misconfigured at the repository level (independent of this contribution), so the new file was verified directly with `lake env lean`, which reports zero errors.