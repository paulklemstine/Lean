# Summary of changes for run bc29db2d-3e0e-4222-8f47-311200ec24ad
Delivered a new, self-contained Lean 4 development plus a research-directions file, building on (and de-duplicating) the catalog's many parallel Fibonacci apparition threads.

## New Lean file: `Catalog/Applications/RankOfApparition.lean` (0 `sorry`; axioms = propext / Classical.choice / Quot.sound)

It isolates the *rank of apparition* `fibRank m` (least positive `k` with `m ∣ F k`) as the load-bearing object and proves:

- `hasFibRank_of_pos` — every positive modulus has a rank (pigeonhole on the reversible Fibonacci shift over `(ZMod m)²`).
- `fibRank_dvd_iff` (the spine) — `m ∣ F n ↔ fibRank m ∣ n`, with **no primitivity hypothesis**, generalizing the catalog's `dvd_fib_iff_index_dvd_of_primitive`.
- `fibRank_dvd_of_dvd` — the order-morphism law with existence: `b ∣ a → 0 < a → fibRank b ∣ fibRank a`.
- `fibRank_fib` (new) — `fibRank (F k) = k` for `k ≥ 3`; the rank pins Fibonacci values exactly. Absent from the catalog and Mathlib.
- `fib_dvd_fib_iff` (new corollary) — `F a ∣ F b ↔ a ∣ b` for `a ≥ 3`. Mathlib has only the forward `Nat.fib_dvd`; the biconditional was missing.
- `fib_prime_index_has_primitive` — Carmichael's prime case for **all** primes `p ≥ 3`, sharpening the catalog's `p ≥ 5` version, derived in a few lines from the spine.

The existence/spine core was reused from the verified technique in `Catalog/Novelty/FibApparitionExistence.lean`; because the catalog's build graph is fragmented (its `Applications`/`Novelty` directories are not lake targets and the package source directory is misconfigured in this environment), the file is deliberately self-contained against Mathlib so it compiles independently, while citing the related catalog files by name. Each theorem carries a `!--` proof sketch and a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis).

I verified the file compiles (`lake env lean`), contains no `sorry`, and that all six results depend only on the standard axioms.

## `FUTURE_DIRECTIONS.md`

A narrative with 5 falsifiable directions (primitivity-free composite Carmichael case via a cyclotomic/totient lower bound; transporting the exact join-morphism laws to the new spine; prime-power ranks and a Lifting-the-Exponent law; abstracting the spine to all strong divisibility sequences; and exact arithmetic-progression density of apparition indices), each including a "The key insight is…" sentence and a "Why now?" justification grounded in specific catalog results.