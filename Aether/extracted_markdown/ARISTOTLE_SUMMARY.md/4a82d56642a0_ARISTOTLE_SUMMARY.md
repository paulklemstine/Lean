# Summary of changes for run b69f1c5d-4c93-4ea6-8f98-c271c18331fc
Delivered a self-contained, sorry-free Lean 4 development of the Fibonacci rank of apparition and two new research frontiers, plus the required research notes.

## New files
- `Catalog/Speculative/AutoResearch/FibonacciApparition.lean` — builds cleanly (verified via `lake build Speculative.AutoResearch.FibonacciApparition`), contains no `sorry`/`admit`, and uses only permitted axioms (`propext`, `Classical.choice`, `Quot.sound`; the Wall–Sun–Sun result additionally uses `Lean.ofReduceBool`/`Lean.trustCompiler` from `native_decide`).
- `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md` — synthesis, results table, and 5 falsifiable research directions, each with a "The key insight is..." sentence and a "Why now?" justification.

## Main theorems (all proved)
1. `fibEntry_exists` — unconditional existence of the rank of apparition for every modulus `m ≥ 1`, proved abstractly via the finite order of the Fibonacci shift permutation `fibStep` on `ZMod m × ZMod m` (a Pisano-free route to the period; this was the genuinely hard ingredient the catalog left only for primes).
2. `fib_dvd_iff_fibEntry_dvd` (and unconditional `fib_dvd_iff_fibEntry_dvd_of_pos`) — the law of apparition `m ∣ F n ↔ fibEntry m ∣ n`.
3. `prime_primitive_iff` — primitive prime divisors of `F n` are exactly the primes `p` with `fibEntry p = n`.
4. `fibEntry_not_exceptional` (Future Direction 5) — no prime has rank of apparition in `{1,2,6,12}`; equivalently `F 1, F 2, F 6, F 12` have no primitive prime divisor, the exact structural reason Carmichael's theorem excludes these indices.
5. `no_wallSunSun_prime_below_hundred` (Future Direction 3) — a fully decidable statement (no noncomputable objects) certifying there is no Wall–Sun–Sun prime below 100.

Supporting lemmas (`fibStep_iterate`, `dvd_fib_fibEntry`, `fibEntry_pos`, `fibEntry_min`, `fibEntry_ne_zero`, `fib_dvd_of_gcd`, `fibEntry_two`, `fibEntry_three`) and the catalog-synthesis discussion are included.

## Notes/format requirements met
- Brief proof sketches are given as `-- !-- ... -- !--` blocks before theorems.
- Lab Notebook `-- !-- ... -- !--` blocks (Hypothesis/Result/Insight/Failure analysis) appear in the file.
- The file is self-contained (`import Mathlib`) because the catalog's existing entry-point files depend on a missing `Shared/CarmichaelHelper.lean` and do not currently build; the docstring cites and synthesizes those parallel catalog threads (`CarmichaelComposite.fibEntryPt`, `FibonacciEntryPointCharacterization`, `RankOfApparition`, `FibApparitionExistence.fibStep`).

Note: the repository's overall default build target is pre-existingly broken (a missing referenced source file under Algebra/Jacobian and a missing Shared/CarmichaelHelper.lean), unrelated to this work; the new module was verified by building it directly.