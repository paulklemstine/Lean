# Summary of changes for run d978a447-4138-48b1-bae7-9d71920b3d72
Delivered a new, self-contained Lean 4 research file plus the required research notes, on the theme "Fibonacci Apparition as a Local-to-Global Sheaf" (Shared domain), building on—rather than duplicating—the catalog's existing rank-of-apparition threads.

New file: `Catalog/Shared/FibonacciApparitionSheaf.lean` (imports Mathlib only, fully self-contained). It contains **four main theorems, all proved with zero `sorry`**, depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`):

1. `fib_dvd_iff_fibRank_dvd` — the law of apparition `m ∣ F n ↔ rank m ∣ n`. Existence of the rank is proved from scratch by exhibiting the Fibonacci shift `(a,b) ↦ (b, a+b)` as an honest permutation of the finite type `(ZMod m)²`, whose finite order forces the orbit of `(0,1)` to return.
2. `isPrimitive_iff_fibRank_eq` — a bridge to Carmichael's primitive-divisor theory: a prime is a primitive divisor of `F n` iff its rank equals `n` (primitivity = rank-maximality), recasting the global `CarmichaelProof` statement as a local/stalk condition.
3. `fibRank_mul_coprime` — CRT gluing of stalks: `rank(ab) = lcm(rank a, rank b)` for coprime moduli.
4. `fibRank_eq_factorization_lcm` — full local-to-global reconstruction: `rank n = lcm` of the prime-power stalk ranks `rank(p^{v_p(n)})`, strictly generalizing the binary gluing law.

Each theorem carries a brief `-- !-- … -- !--` proof sketch, and the file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

Also added `FUTURE_DIRECTIONS.md`: a synthesis, a results-summary table, and five falsifiable research directions (closing the infinite tail of Fibonacci Carmichael via the stalk bridge; the gcd/meet defect as a cohomological obstruction; rank vs. Pisano period as the global period sheaf; generalization to arbitrary Lucas sequences; and the inverse/fiber problem for `rank` via the primitive part). Each direction states a "The key insight is…" sentence and a "Why now?" justification.

Note: the pre-existing project-wide `lake` build configuration is independently broken (the lib globs do not match the `Catalog/…` source layout, and `Catalog/Shared/CarmichaelProof.lean` imports a missing `Shared.CarmichaelHelper`); these issues predate this work and were left untouched. The new file was therefore verified by full elaboration in a clean Mathlib environment rather than via the broken default `lake` targets.